cat > .github/workflows/ci-quality-gate.yml << 'EOF'
name: Quality Gate + AI Feedback

on:
  push:
    branches: [ main, develop, test-ci-quality-gate ]
  pull_request:
    branches: [ main, develop ]

jobs:
  quality-check:
    runs-on: ubuntu-latest
    outputs:
      has_errors: ${{ steps.check.outputs.has_errors }}
      error_details: ${{ steps.check.outputs.error_details }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Install tools
        run: |
          python -m pip install --upgrade pip
          pip install mypy pylint types-requests

      - name: Run mypy
        id: mypy
        continue-on-error: true
        run: |
          mypy . --strict --pretty > mypy_output.txt
          cat mypy_output.txt

      - name: Run pylint
        id: pylint
        continue-on-error: true
        run: |
          pylint $(git ls-files '*.py') --score=n > pylint_output.txt
          cat pylint_output.txt

      - name: Check errors
        id: check
        run: |
          server_address: ${{ secrets.SMTP_SERVER }}
          password: ${{ secrets.SMTP_PASS }}
          subject: "CI BLOQUÉ – ${{ github.actor }}"
          to: ${{ secrets.EMAIL_TO }}
          from: "GitHub CI <no-reply@github.com>"
          secure: true
          body: |
            Salut ${{ github.actor }},

            Ton code est bloqué.

            Lien : ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}

            ERREURS :
            ${{ needs.quality-check.outputs.error_details }}

            CORRECTIONS IA :
            $(cat ai_fix.txt)

            — Quality Gate
EOF          username: ${{ secrets.SMTP_USER }}
          server_port: ${{ secrets.SMTP_PORT }}
          ERROR=""
        with:
        uses: dawidd6/action-send-mail@v3
          HAS_ERROR="false"
      - name: Send email
        with:

          name: ai-fix

          if grep -q "error:" mypy_output.txt 2>/dev/null; then
        uses: actions/download-artifact@v3
            ERROR="${ERROR}=== MYPY ===\n$(cat mypy_output.txt)\n\n"
    steps:
      - name: Download AI fix

            HAS_ERROR="true"
          fi

    runs-on: ubuntu-latest
    if: ${{ needs.quality-check.outputs.has_errors == 'true' }}
          if grep -q "rated at" pylint_output.txt 2>/dev/null; then
            SCORE=$(tail -n1 pylint_output.txt | grep -o "[0-9.]*" | head -1)
            if (( $(echo "$SCORE < 9.0" | bc -l) )); then
              ERROR="${ERROR}=== PYLINT (score: $SCORE) ===\n$(cat pylint_output.txt)\n"
    needs: [quality-check, ai-feedback]
  send-email:
              HAS_ERROR="true"
            fi
          fi


          name: ai-fix
          path: ai_fix.txt
          echo "has_errors=$HAS_ERROR" >> $GITHUB_OUTPUT
          echo "error_details<<EOF" >> $GITHUB_OUTPUT
          echo "$ERROR" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT
        with:

        uses: actions/upload-artifact@v3
  ai-feedback:
    needs: quality-check
    if: ${{ needs.quality-check.outputs.has_errors == 'true' }}
      - name: Upload AI fix
    runs-on: ubuntu-latest
    env:
      GROK_API_KEY: ${{ secrets.GROK_API_KEY }}

      DEVELOPER: ${{ github.actor }}

    steps:
      - name: Checkout code
          jq -r '.choices[0].message.content' ai.json > ai_fix.txt
        uses: actions/checkout@v4

      - name: Install jq
        run: sudo apt-get update && sudo apt-get install -y jq bc


      - name: Get profile
        id: profile
            > ai.json
        run: |
          if [ -f dev_profiles.json ]; then
            echo "style=$(jq -r '."$DEVELOPER" // "direct, brutal"' dev_profiles.json)" >> $GITHUB_OUTPUT
          else
            echo "style=direct, brutal" >> $GITHUB_OUTPUT
          fi

      - name: Generate AI fix
        run: |
          ERR="${{ needs.quality-check.outputs.error_details }}"
          STYLE="${{ steps.profile.outputs.style }}"
            -d "{\"model\": \"grok-beta\", \"messages\": [{\"role\": \"user\", \"content\": \"$PROMPT\"}], \"temperature\": 0.2}" \

          PROMPT="Analyse ces erreurs Python :

$ERR
            -H "Content-Type: application/json" \

          curl -X POST https://api.x.ai/v1/chat/completions \
            -H "Authorization: Bearer $GROK_API_KEY" \
Donne pour chaque erreur :
- Fichier + ligne
- Problème
