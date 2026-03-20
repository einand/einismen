#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

declare -A LANGUAGES=(
    [da]="danska" [fi]="finska" [de]="tyska" [fr]="franska"
    [el]="grekiska" [hu]="ungerska" [ga]="iriska" [it]="italienska"
    [lv]="lettiska" [lt]="litauiska" [mt]="maltesiska" [nl]="nederländska"
    [pl]="polska" [pt]="portugisiska" [ro]="rumänska" [sk]="slovakiska"
    [sl]="slovenska" [es]="spanska" [cs]="tjeckiska" [hr]="kroatiska"
    [bg]="bulgarska" [et]="estniska"
)

declare -A LOCALES=(
    [da]="da_DK" [fi]="fi_FI" [de]="de_DE" [fr]="fr_FR"
    [el]="el_GR" [hu]="hu_HU" [ga]="ga_IE" [it]="it_IT"
    [lv]="lv_LV" [lt]="lt_LT" [mt]="mt_MT" [nl]="nl_NL"
    [pl]="pl_PL" [pt]="pt_PT" [ro]="ro_RO" [sk]="sk_SK"
    [sl]="sl_SI" [es]="es_ES" [cs]="cs_CZ" [hr]="hr_HR"
    [bg]="bg_BG" [et]="et_EE"
)

load_env() {
    if [[ -f "$ROOT_DIR/.env" ]]; then
        while IFS='=' read -r key value; do
            [[ "$key" =~ ^[[:space:]]*# ]] && continue
            [[ -z "$key" ]] && continue
            key=$(echo "$key" | tr -d '[:space:]')
            value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            export "$key=$value"
        done < "$ROOT_DIR/.env"
    fi
}

check_api_key() {
    "$SCRIPT_DIR/test-gemini-key.sh" > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo "Fel: GEMINI_API_KEY är inte giltig."
        echo "Kör ./scripts/test-gemini-key.sh för mer info."
        exit 1
    fi
}

validate_lang_code() {
    local lang_code="$1"
    if [[ ! -v "LANGUAGES[$lang_code]" ]]; then
        echo "Fel: Ogiltig språkkod '$lang_code'"
        echo ""
        echo "Giltiga språkkoder:"
        for code in "${!LANGUAGES[@]}"; do
            printf "  %-4s %s\n" "$code" "${LANGUAGES[$code]}"
        done | sort -k2
        exit 1
    fi
}

translate_text() {
    local lang_code="$1"
    local lang_name="${LANGUAGES[$lang_code]}"
    local text="$2"
    
    local escaped_text=$(echo "$text" | python3 -c '
import sys
import json
text = sys.stdin.read()
print(json.dumps(text))
' 2>/dev/null || echo "\"$text\"")

    local escaped_lang=$(python3 -c "print(json.dumps('$lang_name'))" 2>/dev/null || echo "'$lang_name'")

    local response=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-pro:generateContent?key=${GEMINI_API_KEY}" \
        -H "Content-Type: application/json" \
        -d "{
            \"contents\": [{
                \"parts\": [{
                    \"text\": \"Translate the following HTML content to $escaped_lang. Preserve all HTML tags. Keep the text short, simple and ascetic. Translate only visible text, not attributes like alt or title unless critical. Return only the translated content.\n\n\" + $escaped_text
                }]
            }]
        }" \
        --max-time 60)

    local translated=$(echo "$response" | python3 -c '
import sys
import json
try:
    data = json.load(sys.stdin)
    print(data["candidates"][0]["content"]["parts"][0]["text"])
except:
    print("")
' 2>/dev/null)

    if [[ -z "$translated" ]]; then
        echo "Fel: Kunde inte översätta text."
        echo "Response: $response"
        exit 1
    fi

    echo "$translated"
}

copy_and_convert_structure() {
    local lang_code="$1"
    
    cp -r "$ROOT_DIR/web/sv" "$ROOT_DIR/web/$lang_code"
    
    find "$ROOT_DIR/web/$lang_code" -type f -name "*.html" | while read -r file; do
        sed -i "s|/sv/|/$lang_code/|g" "$file"
        sed -i 's|<html lang="sv">|<html lang="'"$lang_code"'">|g' "$file"
        sed -i 's|og:locale" content="sv_SE"|og:locale" content="'"${LOCALES[$lang_code]}"'"|g' "$file"
        sed -i 's|og:locale" content="sv"|og:locale" content="'"${LOCALES[$lang_code]}"'"|g' "$file"
        sed -i 's|hreflang="sv"|hreflang="'"$lang_code"'"|g' "$file"
        sed -i "s|aistudio.google.com/apikey|aistudio.google.com/apikey|g" "$file"
    done
}

translate_html_file() {
    local lang_code="$1"
    local file="$2"
    
    local tmp_file=$(mktemp)
    
    python3 -c "
import sys
import re

with open('$file', 'r', encoding='utf-8') as f:
    content = f.read()

text_parts = []
html_tags = []

def extract_text(html):
    parts = []
    text = ''
    in_tag = False
    for char in html:
        if char == '<':
            if text.strip():
                parts.append(('text', text.strip()))
                text = ''
            in_tag = True
            html_tags.append(char)
        elif char == '>':
            in_tag = False
            html_tags.append(char)
        elif in_tag:
            html_tags.append(char)
        else:
            text += char
    if text.strip():
        parts.append(('text', text.strip()))
    return parts

text_content = extract_text(content)
print('TEXT_START')
for part_type, part_text in text_content:
    if part_type == 'text':
        print(part_text)
print('TEXT_END')
" > "$tmp_file"
    
    TEXT=$(sed -n '/TEXT_START/,/TEXT_END/p' "$tmp_file" | sed '1d;$d')
    
    rm "$tmp_file"
    
    if [[ -n "$TEXT" ]]; then
        TRANSLATED=$(translate_text "$lang_code" "$TEXT")
        
        python3 << PYEOF
import re

with open('$file', 'r', encoding='utf-8') as f:
    content = f.read()

text_lines = '''$TEXT'''.strip().split('\n')
translated_lines = '''$TRANSLATED'''.strip().split('\n')

if len(text_lines) != len(translated_lines):
    print(f"Varning: Antal rader matchar inte ({len(text_lines)} vs {len(translated_lines)})")
    exit(1)

replacements = list(zip(text_lines, translated_lines))

for old, new in replacements:
    content = content.replace(old, new, 1)

with open('$file', 'w', encoding='utf-8') as f:
    f.write(content)
PYEOF
    fi
}

translate_header_partial() {
    local lang_code="$1"
    local header_file="$ROOT_DIR/web/$lang_code/partials/header.html"
    
    if [[ -f "$header_file" ]]; then
        python3 << PYEOF
import re

with open('$header_file', 'r', encoding='utf-8') as f:
    content = f.read()

translations = {
    'Skip to content': 'Hoppa till innehåll',
    'Menu': 'Meny',
    'Home': 'Hem',
    'Texts': 'Texter',
    'Subpages': 'Underrubriker',
    'Basics': 'Grunder',
    'Method': 'Metod',
    'Life stance': 'Livshållning',
    'Manifesto': 'Manifest',
    'Foundation document': 'Grunddokument',
    'In detail': 'I detalj',
    'About the philosophy': 'Om filosofin',
    'Core ideas': 'Kärnidéer',
    'Values': 'Värderingar',
    'Goals and ideals': 'Mål och ideal',
    'Ethics and principles': 'Etik och principer',
    'Practical application': 'Praktisk tillämpning',
    'Reasoning and logic': 'Resonemang och logik',
    'Examples': 'Exempel',
    'Criticism and objections': 'Kritik och invändningar',
    'Summary': 'Sammanfattning',
    'What is Einismen?': 'Vad är Einismen?',
    'Pillars': 'Pelare',
    'Accept chaos': 'Acceptera kaoset',
    'Inner strength': 'Inre styrka',
    'Freedom': 'Frihet',
    'Weight of words': 'Ordens värde',
    'Change': 'Förändring',
    'Practice': 'Praktik',
    'Everyday life': 'Vardagen',
    'Work and leadership': 'Arbete och ledarskap',
    'Ethics': 'Etik',
    'Questions and answers': 'Frågor och svar',
    'Einismen': 'Einismen',
    'Clarity in a chaotic world': 'Klarhet i en kaotisk värld',
}

for eng, swe in translations.items():
    if 'Swedish' in content or 'sv_SE' in content:
        pass
    else:
        pass

with open('$header_file', 'w', encoding='utf-8') as f:
    f.write(content)
PYEOF
    fi
}

update_language_map() {
    local lang_code="$1"
    
    if [[ ! -f "$ROOT_DIR/LANGUAGE_MAP.md" ]]; then
        return
    fi
    
    cat >> "$ROOT_DIR/LANGUAGE_MAP.md" << EOF

## Generated Languages

| Svenska | ${LANGUAGES[$lang_code]} |
| --- | --- |
EOF
    
    python3 << PYEOF
import re

sv_pages = []
with open('$ROOT_DIR/LANGUAGE_MAP.md', 'r', encoding='utf-8') as f:
    for line in f:
        match = re.match(r'\|\s*/sv/([^`]+)\s*\|', line)
        if match:
            sv_pages.append(match.group(1))

with open('$ROOT_DIR/LANGUAGE_MAP.md', 'a', encoding='utf-8') as f:
    for page in sv_pages:
        if page:
            f.write(f"| `/sv/{page}` | `/{'$lang_code'}/{page}` |\n")
PYEOF
}

update_sitemaps() {
    local lang_code="$1"
    
    if [[ -f "$ROOT_DIR/web/sitemap.xml" ]]; then
        cp "$ROOT_DIR/web/sitemap.xml" "$ROOT_DIR/web/sitemap-${lang_code}.xml"
        sed -i "s|/sv/|/${lang_code}/|g" "$ROOT_DIR/web/sitemap-${lang_code}.xml"
    fi
}

main() {
    if [[ $# -ne 1 ]]; then
        echo "Användning: $0 <språkkod>"
        echo ""
        echo "Giltiga språkkoder:"
        for code in "${!LANGUAGES[@]}"; do
            printf "  %-4s %s\n" "$code" "${LANGUAGES[$code]}"
        done | sort -k2
        exit 1
    fi
    
    local lang_code="$1"
    
    echo "Översätter till ${LANGUAGES[$lang_code]} ($lang_code)..."
    
    load_env
    check_api_key
    validate_lang_code "$lang_code"
    
    if [[ -d "$ROOT_DIR/web/$lang_code" ]]; then
        echo "Fel: Mappen web/$lang_code finns redan."
        exit 1
    fi
    
    echo "1. Skapar mappstruktur..."
    copy_and_convert_structure "$lang_code"
    
    echo "2. Översätter HTML-filer..."
    find "$ROOT_DIR/web/$lang_code" -type f -name "*.html" | while read -r file; do
        echo "   - $(basename "$file")"
        translate_html_file "$lang_code" "$file" || exit 1
    done
    
    echo "3. Uppdaterar LANGUAGE_MAP.md..."
    update_language_map "$lang_code"
    
    echo "4. Uppdaterar sitemaps..."
    update_sitemaps "$lang_code"
    
    echo ""
    echo "Översättning klar!"
    echo "Filer finns i: web/$lang_code/"
    echo ""
    echo "Nästa steg:"
    echo "  1. Granska filerna"
    echo "  2. git add -A && git commit"
    echo "  3. ./scripts/deploy.sh"
}

main "$@"
