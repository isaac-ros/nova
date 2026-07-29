#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
git remote get-url origin >/dev/null 2>&1 || exit 0

git fetch origin --quiet 2>/dev/null || { echo "⚠ No se pudo hacer fetch (sin red o sin credenciales)"; exit 0; }

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
LOCAL="$(git rev-parse @ 2>/dev/null)"
REMOTE="$(git rev-parse "origin/$BRANCH" 2>/dev/null || echo "")"
[ -z "$REMOTE" ] && exit 0
BASE="$(git merge-base @ "origin/$BRANCH" 2>/dev/null || echo "")"
DIRTY="$(git status --porcelain | wc -l | tr -d ' ')"

if [ "$LOCAL" = "$REMOTE" ]; then
  echo "✓ Vault al día"
elif [ "$LOCAL" = "$BASE" ]; then
  AHEAD="$(git rev-list --count @..origin/$BRANCH)"
  if [ "$DIRTY" = "0" ]; then
    git pull --ff-only --quiet && echo "✓ Vault actualizado: $AHEAD commits nuevos"
  else
    echo "⚠ $AHEAD commits nuevos en remoto y tienes $DIRTY cambios locales sin commitear. Corre /aprobar o /sync antes de continuar."
  fi
elif [ "$REMOTE" = "$BASE" ]; then
  BEHINDLOCAL="$(git rev-list --count origin/$BRANCH..@)"
  echo "↑ Tienes $BEHINDLOCAL commits locales sin empujar. Corre /sync para publicarlos."
else
  echo "⚠ Historias divergentes (local y remoto avanzaron por separado). Requiere revisión manual."
fi
