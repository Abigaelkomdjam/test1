#!/usr/bin/env python3
import os
import sys
import json
import requests

def call_gemini(errors: str, api_key: str) -> str:
    if not api_key:
        return "GEMINI_API_KEY manquant dans les secrets GitHub."

    prompt = f"""Tu es un expert Python. Corrige ces erreurs (mypy + pylint).

Pour chaque erreur :
- Fichier + ligne
- Problème
- Correction (code)
- Explication courte

Style : direct, brutal, en français.

Erreurs :
{errors}
"""

    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key={api_key}"
    payload = {
        "contents": [{
            "parts": [{"text": prompt}]
        }],
        "generationConfig": {"temperature": 0.2}
    }

    try:
        response = requests.post(url, json=payload, timeout=30)
        data = response.json()

        if 'candidates' in data and data['candidates']:
            text = data['candidates'][0]['content']['parts'][0]['text']
            return text.strip()
        else:
            return f"Erreur API Gemini : {data.get('error', 'Réponse vide')}"
    except Exception as e:
        return f"Exception : {str(e)}"

if __name__ == "__main__":
    errors = sys.stdin.read().strip()
    api_key = os.getenv("GEMINI_API_KEY", "")
    result = call_gemini(errors, api_key)
    print(result)
