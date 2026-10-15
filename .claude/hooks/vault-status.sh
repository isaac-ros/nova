#!/usr/bin/env bash
# Reporte de estado del vault al iniciar sesión.
# Solo lectura y solo local: no hace fetch, pull, push ni ningún acceso a red.
set -euo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0

FORMACION="$(grep -rl --include='*.md' '^fase: formacion' stars/ 2>/dev/null | wc -l | tr -d ' ')"
DIRTY="$(git status --porcelain -- stars/ constellations/ inbox/ archive/ 2>/dev/null | wc -l | tr -d ' ')"

if [ "$FORMACION" = "0" ] && [ "$DIRTY" = "0" ]; then
  echo "✓ Vault al día (local) — sin estrellas en formación ni cambios sin commitear"
  exit 0
fi

[ "$FORMACION" != "0" ] && echo "✦ $FORMACION estrellas en formación esperando revisión. Corre /aprobar."
[ "$DIRTY" != "0" ] && echo "○ $DIRTY archivos de vault con cambios sin commitear en el historial local."
