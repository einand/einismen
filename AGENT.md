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

## Arbetsflöde

- Efter användarens revisioner ska ändringar committas och pushas automatiskt.
- Commit-meddelanden ska vara passande för ändringarna.

## Deploymentstatus

- Webbplatsen är containeriserad med `nginx` via `Dockerfile` och `nginx/default.conf`.
- Helm-chart finns i `helm/einismen`.
- Staging-värden finns i `helm/einismen/values-staging.yaml`.
- Webbplatsen deployas till namespace `einsimen`.
- Staging deployas till namespace `einsimen-staging`.
- Ingress-host är `einismen.k3s.k0.nu`.
- Staging-host är `staging-einismen.k3s.k0.nu`.
- HTTPS är aktiverat via cert-manager och `ClusterIssuer` `letsencrypt-prod`.
- TLS-certifikatet skapas automatiskt av cert-manager via ingress-shim när ingressen har rätt annotation och `tls.secretName`.
- Container-imagen pushas till `harbor.k3s.k0.nu/lek/einismen-web`.
- Deploy-script finns i `scripts/deploy.sh` och bygger, pushar och deployar med automatiska image-taggar.

## Praktisk sammanfattning

- Svenska texter: Unicode.
- Filnamn och länkar: ASCII.
- Design: asketisk.
- Innehåll: kort, enkelt och dokumentationsbaserat.
- Deploy: Docker + Helm + Kubernetes.
