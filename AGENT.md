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

- Efter användarens revisioner ska ändringar hanteras via branch och pull request innan de hamnar i `main`.
- Commit-meddelanden ska vara passande för ändringarna.
- Innan varje commit ska dokumentationen uppdateras så att den beskriver aktuell struktur, drift och arbetssätt.
- Nya arbetsuppgifter, förbättringar och uppföljningar ska skrivas som issues i `lek/einismen` när det är relevant.
- När användaren ber om att kontrollera issues i Gitea ska issues i `lek/einismen` granskas.
- **VIKTIGT: Arbeta bara på issues som har labeln `opencode`. Issues utan denna label ska inte prioriteras, genomföras eller ens påbörjas förrän användaren explicit sätter labeln.**
- Om en issue har labeln `opencode` ska den prioriteras, genomföras och därefter kommenteras och stängas när arbetet är klart.
- Även när användaren ger en uppgift direkt i chatten ska en issue skapas i `lek/einismen` med labeln `opencode` innan eller i samband med att arbetet utförs.
- Issues ska skrivas som user stories eller så nära användarens egen formulering som möjligt.
- Allt arbete som utförs i projektet ska ha en motsvarande issue i `lek/einismen`.
- Issues får gärna skrivas om för att bli tydligare och lättare att följa, men de ska formuleras som user stories eller rena tickets.
- Undvik formuleringar som "användaren vill" i issues. Skriv i stället som en beställning eller arbetsbeskrivning.
- Svenska tickets och issues ska använda riktig Unicode, inklusive `å`, `ä` och `ö`.
- När en sida ändras på ett språk ska motsvarande sida på alla andra språk som finns också uppdateras, om en sådan motsvarighet finns.
- Flödet är: skapa issue om den inte finns, skapa branch från `main`, gör ändringar, uppdatera issue, skapa pull request till `main`, verifiera, mergea pull request, deploya `main`, kommentera resultat och stäng issue.
- Efter merge ska arbetsbranchen tas bort både lokalt och på remote när det är lämpligt.
- När en arbetsbranch skapas ska branchnamnet också skrivas i den relevanta issuen i Gitea.
- Gitea-issues får gärna använda HTML när det gör strukturen tydligare, snyggare och lättare att följa.
- Issuekommentaren när arbetet är klart ska i sak motsvara samma klarsammanfattning som ges till användaren.

## Standardkommandon

- Skapa issue: `tea-cli issues create --repo lek/einismen --title "..." --description "..." --labels opencode`
- Kommentera issue: `tea-cli comment --repo lek/einismen <issue-index> "..."`
- Stäng issue: `tea-cli issues close --repo lek/einismen <issue-index>`
- Skapa branch: `git checkout -b "opencode/issue-<nummer>-<kort-namn>"`
- Kommentera branchnamn på issue: `tea-cli comment --repo lek/einismen <issue-index> "Arbetar i branch: opencode/issue-<nummer>-<kort-namn>"`
- Visa status: `git status --short --branch`
- Commit: `git add <filer> && GIT_AUTHOR_NAME="Ein Andersson" GIT_AUTHOR_EMAIL="einand@k0.nu" GIT_COMMITTER_NAME="Ein Andersson" GIT_COMMITTER_EMAIL="einand@k0.nu" git commit -m "..."`
- Pusha branch: `git push -u origin "opencode/issue-<nummer>-<kort-namn>"`
- Skapa PR: `tea-cli pulls create --repo lek/einismen --head <branch> --base main --title "..." --description "..."`
- Mergea PR: `tea-cli pr merge --repo lek/einismen --style merge --message "..." <pr-index>`
- Uppdatera lokal main: `git checkout main && git pull --ff-only origin main`
- Ta bort branch lokalt: `git branch -d "opencode/issue-<nummer>-<kort-namn>"`
- Ta bort branch på remote: `git push origin --delete "opencode/issue-<nummer>-<kort-namn>"`
- Deploya main: `./scripts/deploy.sh`

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
