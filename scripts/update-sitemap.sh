#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEB_DIR="$ROOT_DIR/web"

today=$(date +%Y-%m-%d)

for sitemap in "$WEB_DIR"/sitemap*.xml; do
  if [ -f "$sitemap" ]; then
    sed -i "s/<lastmod>[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}<\/lastmod>/<lastmod>$today<\/lastmod>/g" "$sitemap"
    echo "Updated lastmod in $sitemap"
  fi
done
