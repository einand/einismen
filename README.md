# Einismen

Einismen är en statisk flerspråkig webbplats byggd med Hugo och publicerad via
GitHub Pages.

## Projektstruktur

- `content/sv/`, `content/en/` och `content/fi/` innehåller sidinnehållet som Markdown.
- `layouts/` innehåller Hugo-mallar och språkvisa navigationer.
- `static/` innehåller CSS, SVG, ikoner och övriga publika filer.
- `hugo.toml` innehåller språk- och publiceringskonfiguration.
- `.github/workflows/hugo.yml` bygger och publicerar `public/` till GitHub Pages.

## Lokal build

Installera Hugo Extended och kör:

```bash
hugo --gc --minify
```

Resultatet finns i `public/`.

GitHub Actions bygger automatiskt när `main` uppdateras. GitHub Pages ska vara
konfigurerat med `GitHub Actions` som källa under repositoryts Pages-inställningar.
