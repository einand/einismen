# AGENT Rules

## Svenska och Unicode

- När innehåll skrivs på svenska ska riktig Unicode alltid användas.
- Använd alltid svenska tecken direkt i text: `å`, `ä`, `ö`, `Å`, `Ä`, `Ö`.
- Undvik ASCII-ersättningar i svensk brödtext, svenska rubriker och svenska svar.

## Filnamn och länkar

- Filnamn får inte innehålla `å`, `ä` eller `ö`.
- Länkar, URL-segment och `href`-mål får inte innehålla `å`, `ä` eller `ö`.
- Använd ASCII i filnamn och länkar, till exempel `fragor-svar.html` i stället för `frågor-svar.html`.

## Webbplats för Einismen

- Webbplatsen ska ha en asketisk design.
- Texterna ska vara korta, enkla och lätta att ta till sig.
- Flera sidor får användas när det gör innehållet tydligare och mer lättöverskådligt.
- Dokumentationen i repot ska användas brett som grund för innehållet.
- Hela webbplatsen måste fungera bra på mobiltelefoner.

## Arbetsflöde

- Efter användarens revisioner ska ändringar committas och pushas automatiskt.
- Commit-meddelanden ska vara passande för ändringarna.
- Innan varje commit ska dokumentationen uppdateras så att den beskriver aktuell struktur, drift och arbetssätt.
- Nya arbetsuppgifter, förbättringar och uppföljningar ska skrivas som issues i `lek/einismen` när det är relevant.
- När användaren ber om att kontrollera issues i Gitea ska issues i `lek/einismen` granskas.
- Om en issue har labeln `opencode` ska den prioriteras, genomföras och därefter kommenteras och stängas när arbetet är klart.
- Även när användaren ger en uppgift direkt i chatten ska en issue skapas i `lek/einismen` med labeln `opencode` innan eller i samband med att arbetet utförs.

## Deploymentstatus

- Webbplatsen är containeriserad med `nginx` via `Dockerfile` och `nginx/default.conf`.
- Helm-chart finns i `helm/einismen`.
- Webbplatsen deployas till namespace `einsimen`.
- Ingress-host är `einismen.k3s.k0.nu`.
- Webbplatsen använder rena URL:er utan `.html` i länkarna.
- Webbplatsen är organiserad i undermappar som följer menystrukturen.
- HTTPS är aktiverat via cert-manager och `ClusterIssuer` `letsencrypt-prod`.
- TLS-certifikatet skapas automatiskt av cert-manager via ingress-shim när ingressen har rätt annotation och `tls.secretName`.
- Container-imagen pushas till `harbor.k3s.k0.nu/lek/einismen-web`.
- Deploy-script finns i `scripts/deploy.sh` och bygger, pushar och deployar med automatiska image-taggar.
- Runtime är härdad med unprivileged Nginx, read-only root filesystem, droppade capabilities, avstängd privilege escalation och ingen monterad service account-token.
- Nginx accepterar bara `GET` och returnerar `405` för andra metoder.
- `NetworkPolicy` används för att begränsa ingress till ingress-nginx och blockera egress.
- Resource requests och limits finns definierade i Helm-värdena.

## Arkitekturöversikt

- Webbplatsens filer ligger i `web/`.
- Menystrukturen speglas i katalogstrukturen under `web/`.
- Gemensamma delar återanvänds via Nginx SSI-partials.
- Menyn är helt CSS-baserad med dropdown för undersidor och utan JavaScript.
- `Texter` används för primärtexter medan `I detalj` används för systematisk genomgång ämne för ämne.
- `Praktik` används som samlingssida för vardag, arbete och etik.
- Nginx serverar rena URL:er, SSI och security headers.
- Containern byggs från `Dockerfile`.
- Helm deployar till Kubernetes i namespace `einsimen`.
- ingress-nginx exponerar sajten externt.
- cert-manager hanterar HTTPS-certifikatet.

## Praktisk sammanfattning

- Svenska texter: Unicode.
- Filnamn och länkar: ASCII.
- Design: asketisk.
- Innehåll: kort, enkelt och dokumentationsbaserat.
- Mobilstöd: obligatoriskt.
- Deploy: Docker + Helm + Kubernetes.
- Dokumentation: ska uppdateras före varje commit.
