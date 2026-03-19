# Einismen Web

Det här repot innehåller den statiska webbplatsen för Einismen och konfiguration för att bygga, publicera och deploya den till Kubernetes med Helm.

## Innehåll

- Webbplatsfiler finns i `web/`
- Nginx-konfiguration finns i `nginx/default.conf`
- Container byggs från `Dockerfile`
- Helm-chart finns i `helm/einismen`
- Deploy-script finns i `scripts/deploy.sh`

## Krav

För att deploya själv behöver du ha:

- `docker`
- `kubectl`
- `helm`
- tillgång till Kubernetes-klustret via en fungerande `kubeconfig`
- inloggning till container-registret `harbor.k3s.k0.nu`
- cert-manager installerat i klustret
- `ClusterIssuer` `letsencrypt-prod` installerad om du vill ha HTTPS

## Automatisk taggning

Deploy-scriptet skapar automatiskt en image-tagg i formatet:

```text
YYYYMMDD-HHMMSS-gitsha
```

Exempel:

```text
20260319-145500-abc1234
```

Du kan också sätta en egen tagg via miljövariabeln `IMAGE_TAG`.

## Bygg container manuellt

Bygg imagen lokalt:

```bash
docker build -t einismen-web:latest .
```

Tagga imagen för Harbor:

```bash
docker tag einismen-web:latest harbor.k3s.k0.nu/lek/einismen-web:<tagg>
```

Exempel:

```bash
docker tag einismen-web:latest harbor.k3s.k0.nu/lek/einismen-web:20260319-1442
```

Pusha imagen:

```bash
docker push harbor.k3s.k0.nu/lek/einismen-web:<tagg>
```

## Deploya med script

Production:

```bash
./scripts/deploy.sh
```

Staging:

```bash
./scripts/deploy.sh staging
```

Med egen image-tagg:

```bash
IMAGE_TAG=manual-test ./scripts/deploy.sh
```

Scriptet gör detta:

- bygger imagen
- pushar imagen till Harbor
- deployar med Helm
- väntar på rollout

## Deploya med Helm manuellt

Skapa eller uppdatera releasen i namespace `einsimen`:

```bash
helm upgrade --install einismen ./helm/einismen \
  --namespace einsimen \
  --create-namespace \
  --set image.repository=harbor.k3s.k0.nu/lek/einismen-web \
  --set image.tag=<tagg>
```

Exempel:

```bash
helm upgrade --install einismen ./helm/einismen \
  --namespace einsimen \
  --create-namespace \
  --set image.repository=harbor.k3s.k0.nu/lek/einismen-web \
  --set image.tag=20260319-1442
```

## Kontrollera deploymenten

Kontrollera att resurserna finns:

```bash
kubectl -n einsimen get deploy,svc,ingress,pods
```

Vänta på rollout:

```bash
kubectl -n einsimen rollout status deployment/einismen
```

## HTTPS

HTTPS sätts upp automatiskt via ingressen i Helm-chartet.

Det bygger på att:

- `ingress.annotations.cert-manager.io/cluster-issuer` är satt till `letsencrypt-prod`
- `ingress.tls.secretName` är satt, i detta fall `einismen-tls`

När ingressen deployas skapar cert-manager automatiskt:

- ett `Certificate`
- ett TLS-secret

Kontrollera certifikatet:

```bash
kubectl -n einsimen get certificate,secret
```

Vänta tills certifikatet är klart:

```bash
kubectl -n einsimen wait --for=condition=Ready certificate/einismen-tls --timeout=180s
```

## Domän

Nuvarande host är:

```text
einismen.k3s.k0.nu
```

Om du byter domän behöver du även uppdatera hostnamnet i `helm/einismen/values.yaml`.

För staging används `helm/einismen/values-staging.yaml`.

## Verifiera sidan

Testa HTTP/HTTPS:

```bash
curl -I https://einismen.k3s.k0.nu/
```

## Vanliga filer att ändra

- webbplatsens innehåll: `web/`
- webbserver: `nginx/default.conf`
- imagebygge: `Dockerfile`
- deployment: `helm/einismen`
- staging-värden: `helm/einismen/values-staging.yaml`
- deploy-script: `scripts/deploy.sh`
