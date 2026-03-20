#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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

load_env

if [[ -z "${GEMINI_API_KEY:-}" ]]; then
    echo "Fel: GEMINI_API_KEY är inte inställd."
    echo ""
    echo "Sätt din API-nyckel i .env-filen:"
    echo "  echo 'GEMINI_API_KEY=din-nyckel' > .env"
    echo ""
    echo "Se GEMINI-HOWTO.md för instruktioner."
    exit 1
fi

echo "Testar Gemini API-nyckel..."

RESPONSE=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-pro:generateContent?key=${GEMINI_API_KEY}" \
    -H "Content-Type: application/json" \
    -d '{"contents":[{"parts":[{"text":"Respond with exactly OK if you can read this."}]}]}' \
    --max-time 30)

if echo "$RESPONSE" | grep -q "error"; then
    ERROR_TYPE=$(echo "$RESPONSE" | grep -o '"error":[^{]*' | head -1)
    if echo "$RESPONSE" | grep -q "API_KEY_INVALID\|INVALID_ARGUMENT"; then
        echo "Fel: API-nyckeln är ogiltig."
    elif echo "$RESPONSE" | grep -q "RESOURCE_EXHAUSTED\|quota"; then
        echo "Fel: Rate limit nådd eller kvoten är slut."
    else
        echo "Fel: API-förfrågan misslyckades."
        echo "$RESPONSE"
    fi
    exit 1
fi

if echo "$RESPONSE" | grep -q '"text"' | grep -q "OK\|ok"; then
    echo "OK: API-nyckeln fungerar!"
    exit 0
fi

echo "Kunde inte verifiera svar från API."
echo "Response: $RESPONSE"
exit 1
