#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEB_DIR="$ROOT_DIR/web"

git_sha="$(git -C "$ROOT_DIR" rev-parse --short HEAD 2>/dev/null || echo "dev")"
version="${VERSION:-$git_sha}"

echo "Uppdaterar CSS-version till: $version"

find "$WEB_DIR" -name "*.html" -type f -exec sed -i "s|styles\.css?v=[^\"]*|styles.css?v=$version|g" {} \;

echo "Klart"
