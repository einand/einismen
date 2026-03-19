# Einismen Web

Det här repot innehåller den statiska webbplatsen för Einismen och konfiguration för att bygga, publicera och deploya den till Kubernetes med Helm.

Webbplatsen ska fungera både på desktop och mobiltelefon.

## Innehåll

- Webbplatsfiler finns i `web/`
- Nginx-konfiguration finns i `nginx/default.conf`
- Container byggs från `Dockerfile`
- Helm-chart finns i `helm/einismen`
- Deploy-script finns i `scripts/deploy.sh`

Webbplatsen använder rena URL:er utan `.html`, till exempel `/texter` och `/fragor-svar`.

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

```bash
./scripts/deploy.sh
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

## Säkerhetshärdning

Deploymenten är härdad för att köra en liten statisk webbplats med så liten attackyta som möjligt.

Detta gäller nu:

- containern kör `nginxinc/nginx-unprivileged`
- podden kör som icke-root
- root-filsystemet är read-only
- alla Linux capabilities droppas
- privilege escalation är avstängd
- service account-token mountas inte in i podden
- `seccompProfile` är satt till `RuntimeDefault`
- endast ett skrivbart `emptyDir` på `/tmp` används
- Nginx accepterar bara `GET`
- andra metoder, som `POST`, returnerar `405`
- security headers skickas för alla svar
- `NetworkPolicy` begränsar ingress till ingress-nginx
- `NetworkPolicy` blockerar egress
- CPU- och minnesgränser finns i Helm-värdena

Kontrollera poddens säkerhetsinställningar:

```bash
kubectl -n einsimen get pod -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.automountServiceAccountToken}{" "}{.spec.containers[0].securityContext.readOnlyRootFilesystem}{"\n"}{end}'
```

Kontrollera att `POST` blockeras:

```bash
curl -s -o /dev/null -X POST -w "%{http_code}\n" https://einismen.k3s.k0.nu/
```

Kontrollera headers:

```bash
curl -s -D - -o /dev/null https://einismen.k3s.k0.nu/
```

## Domän

Nuvarande host är:

```text
einismen.k3s.k0.nu
```

Om du byter domän behöver du även uppdatera hostnamnet i `helm/einismen/values.yaml`.

## Rena URL:er

Nginx är konfigurerat för att servera HTML-filer utan att `.html` syns i länkarna.

Exempel:

```text
/
/texter
/vad-ar-einismen
/pelare
/fragor-svar
```

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
- deploy-script: `scripts/deploy.sh`

## Mobilstöd

När du ändrar webbplatsen ska du behålla responsiv layout för mobil.

Det gäller särskilt:

- navigation
- knappar
- sektioner och kolumner
- bilder och mellanrum
