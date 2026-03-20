# Gemini API-nyckel

Denna guide förklarar hur du skapar en API-nyckel för att använda Googles Gemini AI för översättningar.

## Google AI Studio (rekommenderat)

### Steg 1: Öppna Google AI Studio

Gå till: https://aistudio.google.com/

### Steg 2: Logga in

Logga in med ditt Google-konto.

### Steg 3: Skapa API-nyckel

1. Klicka på **"Get API Key"** i vänstermenyn
2. Eller navigera direkt till: https://aistudio.google.com/app/apikey
3. Klicka på **"Create API Key"**
4. Välj ett projekt eller skapa ett nytt
5. Kopiera den genererade nyckeln

### Steg 4: Spara nyckeln

Skapa en `.env`-fil i projektroten:

```bash
GEMINI_API_KEY=din-api-nyckel-har
```

**Viktigt:** Lägg till `.env` i din `.gitignore` om det inte redan finns där.

---

## Google Cloud Console (alternativt)

### Steg 1: Öppna Google Cloud Console

Gå till: https://console.cloud.google.com/

### Steg 2: Skapa eller välj projekt

1. Klicka på projektväljaren längst upp
2. Välj "New Project" eller befintligt projekt

### Steg 3: Aktivera Gemini API

1. Sök efter "Gemini API" i sökfältet
2. Klicka på "Enable"

### Steg 4: Skapa API-nyckel

1. Gå till **"Credentials"** i sidomenyn
2. Klicka **"Create Credentials"**
3. Välj **"API Key"**
4. Kopiera nyckeln

---

## Testa din API-nyckel

Kör testskriptet:

```bash
./scripts/test-gemini-key.sh
```

Eller manuellt med curl:

```bash
curl -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-pro:generateContent?key=${GEMINI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"contents":[{"parts":[{"text":"Respond with OK if you can read this."}]}]}'
```

Förväntat svar innehåller "OK".

---

## Gratis tier

- Gemini 3.1 Pro: 1 miljon tokens per månad (kostnadsfritt)
- Gemini Flash: Ännu mer generös gratis tier
- Mer info: https://ai.google.dev/pricing

---

## Felsökning

| Problem | Lösning |
|---------|---------|
| "API key not valid" | Kontrollera att nyckeln är kopierad korrekt |
| "Quota exceeded" | Vänta till nästa månad eller använd Flash-modellen |
| "Access denied" | Säkerställ att Gemini API är aktiverat |
