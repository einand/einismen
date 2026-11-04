#!/usr/bin/env python3
"""Convert the existing static pages into Hugo Markdown content."""
from pathlib import Path
import html
import posixpath
import re
import textwrap

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "web"
CONTENT = ROOT / "content"

def front_matter(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"').replace("\n", " ").strip()

def convert_page(source: Path) -> None:
    relative = source.relative_to(SOURCE)
    language, *slug_parts, _ = relative.parts
    if language not in {"sv", "en", "fi"}:
        return
    raw = source.read_text(encoding="utf-8")
    title_match = re.search(r"<title>(.*?)</title>", raw, re.I | re.S)
    title = html.unescape(title_match.group(1)).strip() if title_match else " ".join(slug_parts).title()
    title = re.sub(r"\s*\|\s*Einismen\s*$", "", title)
    if title.startswith("Einismen |"):
        title = title.split("|", 1)[0].strip()
    main_match = re.search(r"<main\b[^>]*>\s*(.*?)\s*</main>", raw, re.I | re.S)
    if not main_match:
        raise RuntimeError(f"No main element in {source}")
    body = main_match.group(1).strip()
    def inline_svg(match: re.Match[str]) -> str:
        asset = SOURCE / match.group(1).lstrip("/")
        if not asset.exists():
            raise RuntimeError(f"Missing included asset: {asset}")
        return asset.read_text(encoding="utf-8").strip()
    body = re.sub(r'<!--#\s*include\s+virtual="(/media/[^"]+)"\s*-->', inline_svg, body)
    body = re.sub(r"<!--#.*?-->", "", body, flags=re.S).replace("\r\n", "\n")
    body = textwrap.dedent(body).strip()
    current_dir = "/".join((language, *slug_parts))
    def relative_url(match: re.Match[str]) -> str:
        attribute, target = match.group(1), match.group(2)
        return f'{attribute}="{posixpath.relpath(target.lstrip("/"), current_dir + "/")}"'
    body = re.sub(r'(href|src)="(/(?:sv|en|fi|media)/[^"]*)"', relative_url, body)
    destination = CONTENT / language / Path(*slug_parts) / "_index.md"
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(f'---\ntitle: "{front_matter(title)}"\nlanguage: {language}\nlayout: page\n---\n\n{body}\n', encoding="utf-8")

def main() -> None:
    if not SOURCE.exists():
        raise SystemExit("web/ is missing; the migration source has already been removed")
    if CONTENT.exists():
        for path in CONTENT.rglob("*.md"):
            path.unlink()
    for source in sorted(SOURCE.glob("*/**/index.html")):
        convert_page(source)

if __name__ == "__main__":
    main()
