# Einismen Web

Det här repot innehåller den statiska webbplatsen för Einismen och konfiguration för att bygga, publicera och deploya den till Kubernetes med Helm.

Webbplatsen ska fungera både på desktop och mobiltelefon.

Dokumentationen ska hållas aktuell. Uppdatera därför `README.md` och annan relevant dokumentation innan varje commit när struktur, drift eller arbetssätt förändras.

När nya förbättringar, uppföljningar eller arbetsuppgifter identifieras ska de vid behov skrivas som issues i repot `lek/einismen`.

Om användaren ber om att kontrollera issues i Gitea ska issues i `lek/einismen` granskas. Om en issue har labeln `opencode` ska den arbetas på, och när arbetet är klart ska en kommentar lämnas på issuen innan den stängs.

Även uppgifter som användaren ger direkt i chatten ska vid behov registreras som en issue i `lek/einismen` med labeln `opencode`.

Issues ska skrivas som user stories eller med formuleringar som ligger mycket nära hur användaren själv beskrev uppgiften.

Allt arbete som utförs i projektet ska ha en motsvarande issue i `lek/einismen`.

Issues får gärna skrivas om för att bli tydligare och lättare att följa, men de ska skrivas som user stories eller rena tickets. Undvik formuleringar som "användaren vill" och skriv i stället som en konkret beställning eller arbetsuppgift.

Tickets och issues på svenska ska använda riktig Unicode, inklusive `å`, `ä` och `ö`.

Gitea-issues får gärna använda HTML när det gör strukturen tydligare, snyggare och lättare att följa.

När arbetet är klart ska issuekommentaren i sak motsvara samma klarsammanfattning som ges till användaren.

## Arbetsflöde

Projektet använder ett branch- och PR-baserat flöde:

- skapa issue om den inte redan finns
- skapa en branch från `main`
- skriv branchnamnet i issuen
- genomför ändringar
- uppdatera issue med vad som gjorts
- skapa pull request till `main`
- verifiera att ändringarna ser bra ut
- mergea pull requesten till `main`
- ta bort arbetsbranchen lokalt och på remote
- deploya därefter `main`
- kommentera resultatet och stäng issue

### Standardkommandon

Skapa issue:

```bash
tea-cli issues create --repo lek/einismen --title "..." --description "..." --labels opencode
```

Kommentera och stäng issue:

```bash
tea-cli comment --repo lek/einismen <issue-index> "..."
tea-cli issues close --repo lek/einismen <issue-index>
```

Skapa branch från `main`:

```bash
git checkout -b "opencode/issue-<nummer>-<kort-namn>"
```

Skriv branchnamnet i issuen:

```bash
tea-cli comment --repo lek/einismen <issue-index> "Arbetar i branch: opencode/issue-<nummer>-<kort-namn>"
```

Commit med etablerad identitet:

```bash
git add <filer>
GIT_AUTHOR_NAME="Ein Andersson" \
GIT_AUTHOR_EMAIL="einand@k0.nu" \
GIT_COMMITTER_NAME="Ein Andersson" \
GIT_COMMITTER_EMAIL="einand@k0.nu" \
git commit -m "..."
```

Pusha branch:

```bash
git push -u origin "opencode/issue-<nummer>-<kort-namn>"
```

Skapa pull request:

```bash
tea-cli pulls create --repo lek/einismen --head <branch> --base main --title "..." --description "..."
```

Mergea pull request:

```bash
tea-cli pr merge --repo lek/einismen --style merge --message "..." <pr-index>
```

Ta bort arbetsbranch efter merge:

```bash
git branch -d "opencode/issue-<nummer>-<kort-namn>"
git push origin --delete "opencode/issue-<nummer>-<kort-namn>"
```

Uppdatera lokal `main` och deploya:

```bash
git checkout main && git pull --ff-only origin main
./scripts/deploy.sh
```

## Innehåll

- Webbplatsfiler finns i `web/`
- Engelska versionen finns under `web/en/`
- Nginx-konfiguration finns i `nginx/default.conf`
- Container byggs från `Dockerfile`
- Helm-chart finns i `helm/einismen`
- Deploy-script finns i `scripts/deploy.sh`

Webbplatsen använder rena URL:er utan `.html`, till exempel `/texter` och `/fragor-svar`.

Den svenska versionen ligger kvar på roten `/` medan den engelska versionen ligger under `/en/`.

## Arkitektur

Webbplatsen är byggd som en liten statisk sajt med server-side includes och körs i Kubernetes.

Flödet ser ut så här:

- HTML, CSS, SVG och SSI-partials finns i `web/`
- katalogstrukturen i `web/` följer menystrukturen för webbplatsen
- den engelska speglingen ligger i `web/en/` med översatta URL-segment och en egen SSI-header
- Nginx serverar innehållet och hanterar SSI, rena URL:er och säkerhetsheaders
- toppmenyn är en ren CSS-lösning med dropdown för undersidor
- `Texter` används för längre primärtexter medan `I detalj` fungerar som en mer systematisk uppslagsstruktur
- `Praktik` samlar vardag, arbete och etik under en gemensam tillämpningsnivå
- containern byggs från `Dockerfile`
- Helm deployar `Deployment`, `Service`, `Ingress` och `NetworkPolicy`
- Kubernetes kör webbservern i namespace `einsimen`
- ingress-nginx publicerar sajten på `einismen.k3s.k0.nu`
- cert-manager skapar TLS-certifikatet via Let's Encrypt

Kort sagt:

```text
web/ -> nginx -> container -> Helm -> Kubernetes -> ingress-nginx -> internet
```

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
- meny och gemensam header: `web/partials/header.html`
- webbserver: `nginx/default.conf`
- imagebygge: `Dockerfile`
- deployment: `helm/einismen`
- deploy-script: `scripts/deploy.sh`

## Innehållsstruktur

- startsidan fungerar som kort ingång med länkar vidare till huvuddelarna
- `Texter` samlar längre primärtexter
- `I detalj` bryter ned filosofin i tematiska undersidor
- `Praktik` samlar tillämpningssidorna `Vardagen`, `Arbete` och `Etik`
- `Frågor` är grupperad i ämnesblock för snabbare översikt
- den engelska strukturen speglar samma innehåll under `/en/` med `Texts`, `In detail`, `Pillars`, `Practice` och `Questions`

## Tvåspråkig struktur

- svenska ligger på roten, till exempel `/`, `/pelare` och `/i-detalj`
- engelska ligger under `/en/`, till exempel `/en/`, `/en/pillars` och `/en/in-detail`
- språkväljaren finns i både `web/partials/header.html` och `web/en/partials/header.html`
- `web/styles.css` och `web/media/` delas mellan båda språken
- `nginx/default.conf` omdirigerar `/en` till `/en/` och låter rena URL:er fungera för båda språken

## Mobilstöd

När du ändrar webbplatsen ska du behålla responsiv layout för mobil.

Det gäller särskilt:

- navigation
- knappar
- sektioner och kolumner
- bilder och mellanrum
