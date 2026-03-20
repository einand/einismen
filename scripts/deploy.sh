#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

KUBECONFIG_PATH="${KUBECONFIG:-${HOME}/.kube/config}"

echo "Uppdaterar cache-bust version..."
"$ROOT_DIR/scripts/update-cache-bust.sh"

echo "Uppdaterar sitemap lastmod..."
"$ROOT_DIR/scripts/update-sitemap.sh"
REGISTRY_REPO="${REGISTRY_REPO:-harbor.k3s.k0.nu/lek/einismen-web}"

timestamp="$(date +%Y%m%d-%H%M%S)"
git_sha="$(git -C "$ROOT_DIR" rev-parse --short HEAD)"
image_tag="${IMAGE_TAG:-${timestamp}-${git_sha}}"

release_name="einismen"
namespace="einsimen"
values_file="$ROOT_DIR/helm/einismen/values.yaml"

image_ref="${REGISTRY_REPO}:${image_tag}"

echo "Bygger image: ${image_ref}"
docker build -t "${image_ref}" "$ROOT_DIR"

echo "Pushar image: ${image_ref}"
docker push "${image_ref}"

echo "Deployar ${release_name} till namespace ${namespace}"
helm upgrade --install "$release_name" "$ROOT_DIR/helm/einismen" \
  --kubeconfig "$KUBECONFIG_PATH" \
  --namespace "$namespace" \
  --create-namespace \
  -f "$values_file" \
  --set image.repository="$REGISTRY_REPO" \
  --set image.tag="$image_tag"

echo "Väntar på rollout"
kubectl --kubeconfig "$KUBECONFIG_PATH" -n "$namespace" rollout status deployment/$release_name --timeout=180s

echo "Klart"
echo "Release: $release_name"
echo "Namespace: $namespace"
echo "Image: $image_ref"
