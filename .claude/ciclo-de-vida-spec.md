# Spec: cierre del ciclo de vida de estrellas en Nova

Documento de diseño. Estado: propuesta para revisión de Isaac. No se ha modificado ningún prompt todavía.

Autor del spec: Claude Code · Fecha: 2026-07-24

---

## 1. Contexto y objetivo

Nova cubre bien la creación de conocimiento (`/nebula-process`, `/supernova`) pero deja abierto el cierre del ciclo de vida para usuarios no técnicos: aprobar una estrella (`formacion` → `activa`), versionarla (commit) y sincronizarla (push/pull). Esa parte hoy se hace a mano y se traba.

Evidencia del vault al 2026-07-24 (auditoría de solo lectura):

| Síntoma | Dato |
|---|---|
| Estrellas atascadas en `formacion` | 31, la más antigua 155 días |
| Archivos sin commitear | 118 |
| Estrellas nunca versionadas | ~53 |
| Mecanismo de pull al iniciar | ninguno |
| `dark-matter` Check 2 | busca stale en `inbox/`, donde ya no viven; ciego al backlog real |

Objetivo: agregar un set pequeño de piezas que cierren el ciclo, y alinear los dos prompts que quedaron en el modelo viejo de carpetas. No se toca la lógica de enriquecimiento ni la metáfora del sistema.

Piezas del paquete:

1. Comando nuevo `/aprobar` (sección 2)
2. Hook `SessionStart` de sincronización (sección 3)
3. Comando `/sync` recomendado para el backlog (sección 4)
4. Fixes de consistencia en `dark-matter` y `big-bang` (sección 5)
5. Bloque `health_thresholds` en `nova.config.yaml` (sección 6)
6. Sección de ciclo de vida y git en `CLAUDE.md` (sección 7)
7. Limpieza menor opcional (sección 8)

---

## 2. Comando nuevo: `/aprobar`

Archivo destino: `.claude/commands/aprobar.md`

Verbo diario para pasar una estrella de `formacion` a `activa` y publicarla (commit + push con confirmación). Pensado para que un usuario no técnico cierre el ciclo sin tocar git a mano.

### Uso

```
/aprobar                  # interactivo: lista todas las estrellas en formacion y el usuario elige
/aprobar [nombre|path]    # aprueba una estrella específica
/aprobar todas            # aprueba todas las que estén en formacion
```

### Pasos

**1. Descubrir estrellas en formación.**
Busca en `stars/` (todas las subcarpetas) archivos con `fase: formacion`. No busques en `inbox/`: el modelo actual las tiene ya en su carpeta destino. Si se pasó un nombre o path, filtra a esa estrella. Si no hay ninguna, informa "No hay estrellas en formación pendientes" y detente.

**2. Presentar para revisión.**
Muestra una tabla: nombre, tipo, carpeta, resumen corto (summary o la definición del blockquote), días en formación, `updated`. Marca como stale las que superen `STALE_DRAFT_DAYS`. Si la invocación fue sin argumento, pregunta cuáles aprobar: "todas", una lista específica, o cancelar.

**3. Gate de calidad (antes de activar cada estrella).**
Una estrella `activa` es fuente de verdad, así que valida lo mínimo antes de promoverla:

- Frontmatter obligatorio completo: `type`, `fase`, `tags`, `cumulo`, `created`, `updated`, `author`, `owner`.
- `author` / `owner`: si están en `por_asignar`, adviértelo (no bloquea). Nota: hoy ~40% del vault los tiene en placeholder.
- Constelación: al menos una en `constellations`, o el tag `sin-constelacion` (regla CLAUDE.md §5.2).
- Wikilinks del cuerpo: que resuelvan a un archivo existente. Reporta rotos (ejemplo actual: `[[fernando-urrutia]]`).

Si algo falla, repórtalo y pregunta: aprobar de todas formas o corregir primero. Nunca auto-corrijas contenido sustantivo sin permiso.

**4. Aplicar la transición.**
Para cada estrella aprobada:
- `fase: formacion` → `fase: activa`
- `updated`: fecha actual
- No muevas archivos: ya están en su carpeta destino.

**5. Publicar (commit + push con confirmación).**
- `git add` SOLO de los archivos aprobados más los de constelación que hayan cambiado en este flujo. Nunca `git add -A`: eso barrería `.obsidian/`, `.claude/worktrees/`, borrados y otro ruido no relacionado.
- Mensaje de commit según convención §13: `[star] aprobar: <nombres o "N estrellas">`.
- Muestra al usuario exactamente qué archivos se van a commitear y a qué remoto se empuja (`origin/main`). Pide confirmación explícita.
- Al confirmar: `git commit` y luego `git push`.
- Si el push falla porque el remoto está adelantado, avisa y sugiere correr `/sync` primero.

**6. Cerrar el ciclo hacia arriba (gravedad bidireccional, CLAUDE.md §1.8).**
Para las estrellas recién activadas, evalúa si alguna deja stale a otra estrella `activa` (agrega hechos, contradice un estado, documenta una integración nueva). Reporta candidatos a `/supernova`. Regla por defecto: reportar, no editar.

**7. Reporte final.**
```
✦ Aprobadas: N estrellas → activa
   - [[estrella-1]] (tipo)
   - [[estrella-2]] (tipo)
   Commit: <hash corto> "[star] aprobar: ..."
   Push: ✓ origin/main   (o: ✗ remoto adelantado, corre /sync)
   Candidatos a supernova (hacia arriba): [[destino]] — razón   (o: ninguno)
   Advertencias: [author/owner en por_asignar: X · wikilinks rotos: Y]
```

### Reglas

- El usuario aprueba. Claude nunca auto-aprueba.
- `/aprobar` solo toca estrellas en `formacion`. El backlog de estrellas ya `activa` pero sin versionar se resuelve con `/sync` (sección 4).
- Push requiere credenciales configuradas en la máquina. Si falla la autenticación, reporta y pide al usuario configurarlas (no manejes credenciales).

---

## 3. Hook `SessionStart`: sincronización al iniciar

Al abrir una sesión de Claude Code en el vault, sincroniza con el remoto de forma segura y sin acción del usuario.

### Script

Archivo: `.claude/hooks/vault-sync.sh` (bash, funciona en Git Bash en Windows y en Mac/Linux para los compañeros de equipo).

Lógica:
1. Salir en silencio si el directorio no es un repo git con `origin`.
2. `git fetch origin` en modo quiet.
3. Comparar `main` local contra `origin/main`:
   - Detrás y árbol limpio → `git pull --ff-only`, imprime `✓ Vault actualizado: N commits nuevos`.
   - Detrás y árbol sucio → imprime `⚠ N commits nuevos en remoto y tienes cambios locales sin commitear. Corre /aprobar o /sync antes de continuar.` (No hace pull para evitar conflictos.)
   - Al día → `✓ Vault al día`.
   - Adelantado (commits locales sin empujar) → `↑ Tienes N commits locales sin empujar. Corre /sync para publicarlos.`
4. Nunca hace nada destructivo: sin `reset`, sin `merge` con conflictos, sin `stash` sorpresa.

Borrador del script:

```bash
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
```

### Registro en settings

Va en `.claude/settings.json` (versionado, para que el equipo lo herede) y no en `settings.local.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/vault-sync.sh" }
        ]
      }
    ]
  }
}
```

Notas:
- La salida del hook se inyecta como contexto de la sesión, así que Claude ve el estado y puede relanzarlo al usuario en su primer mensaje.
- Al ser un hook de proyecto, cada compañero recibe una confirmación de confianza la primera vez que abre el vault. Es el comportamiento esperado de Claude Code.
- Requiere Git Bash en Windows (ya disponible en el entorno del equipo).

---

## 4. Comando recomendado: `/sync`

Archivo destino: `.claude/commands/sync.md`

El hook de la sección 3 solo cubre el lado de lectura (pull). El backlog actual de ~53 estrellas ya `activa` pero sin versionar necesita un camino explícito de push. `/sync` lo resuelve. Recomiendo incluirlo aunque la decisión fue "hook automático", porque sin él el backlog no tiene salida.

### Uso

```
/sync            # pull si hay remoto nuevo, luego ofrece commitear y empujar el backlog local
/sync --push     # va directo a revisar y publicar cambios locales sin commitear
```

### Pasos

1. `git fetch` y aplica la misma lógica de pull segura del hook (pull --ff-only si limpio, avisa si sucio).
2. Lista el trabajo local sin publicar, agrupado:
   - Estrellas nuevas sin trackear (`??`) dentro de `stars/`, `constellations/`, `inbox/`, `archive/`.
   - Estrellas modificadas sin commitear (`M`).
   - Borrados (`D`).
   - Ignora ruido de tooling: `.claude/worktrees/`, archivos temporales.
3. Advierte de archivos sueltos fuera del pipeline (raíz del repo, material crudo en `archive/`) para que el usuario decida si entran o se mueven a `inbox/`.
4. Propone un commit con `git add` selectivo (solo contenido de vault) y mensaje según convención. Pide confirmación.
5. Al confirmar: commit + push. Reporta resultado.

Regla: `/sync` nunca hace `git add -A` a ciegas. Siempre muestra la lista y confirma.

---

## 5. Fixes de consistencia con el modelo nuevo de carpetas

Cuando se cambió la regla "formación vive en su carpeta destino" (CLAUDE.md §2), se propagó a `nebula-process` y `supernova` pero no a estos dos.

### 5.1 `dark-matter` Check 2 (bug real)

Actual (`.claude/commands/dark-matter.md`, Check 2):
> Busca archivos en `inbox/` con `fase: formacion` cuyo `created` o `updated` tiene más de `STALE_DRAFT_DAYS` días.

Problema: las 31 estrellas en formación viven en `stars/`, no en `inbox/`. El check nunca las encuentra.

Cambio propuesto:
> Busca en `stars/` (todas las subcarpetas) archivos con `fase: formacion` cuyo `created` o `updated` tenga más de `STALE_DRAFT_DAYS` días. Estas están listas para revisión: sugiere `/aprobar`.

### 5.2 `big-bang` Fase 5 (doble movimiento)

Actual (`.claude/commands/big-bang.md`, Fase 5, paso 4):
> Si aprueba todas: cambia `fase: formacion → activa` y mueve cada archivo a su carpeta correcta según `nova.config.yaml`.

Problema: bajo el modelo nuevo, `/nebula-process` ya movió los archivos a su carpeta destino en fase `formacion`. Moverlos de nuevo al aprobar es redundante.

Cambio propuesto: la aprobación en bulk solo cambia `fase: formacion → activa` en su lugar, sin mover. Delega a `/aprobar todas`. Reemplaza la referencia `/big-bang aprobar-lote` por `/aprobar todas`. El commit del lote se hace vía el push de `/aprobar`.

### 5.3 `nebula-process` §8 (apuntar al verbo nuevo)

Actual:
> O ejecutar: `/nebula-process aprobar [nombre-archivo]` para que Claude haga el cambio.

Cambio propuesto:
> Para aprobar y publicar: `/aprobar [nombre-archivo]` (cambia la fase, hace commit y push).

Elimina el uso sobrecargado de `/nebula-process` como comando de aprobación.

---

## 6. `nova.config.yaml`: bloque `health_thresholds`

`dark-matter` referencia `ORPHAN_ALERT_DAYS`, `STALE_DRAFT_DAYS`, `FUSION_THRESHOLD`, `CONSTELLATION_MAX_STARS`, `CONSTELLATION_MIN_CLUSTER`, pero ninguna está definida en `nova.config.yaml` (usa defaults inline). Agregar el bloque las vuelve knobs reales:

```yaml
# Umbrales de health check (usados por /dark-matter)
health_thresholds:
  ORPHAN_ALERT_DAYS: 7
  STALE_DRAFT_DAYS: 30
  FUSION_THRESHOLD: 0.9
  CONSTELLATION_MAX_STARS: 35
  CONSTELLATION_MIN_CLUSTER: 5
```

`dark-matter` leería estos valores en vez de los defaults hardcodeados.

---

## 7. `CLAUDE.md`: sección de ciclo de vida y git

Agregar una sección corta que formalice el ciclo completo para que el comportamiento sea fuente de verdad:

- El verbo de aprobación es `/aprobar` (`formacion` → `activa` + commit + push con confirmación).
- Las sesiones inician con auto-sync vía hook `SessionStart`; el push del backlog se hace con `/sync`.
- Reafirmar la convención de commits §13 (ya existe) y agregar quién dispara el commit: los comandos `/aprobar`, `/sync`, `/fusion`, `/big-bang` proponen y ejecutan el commit tras confirmación; fuera de ellos, Claude no commitea.

Mantener mínima. No renumerar secciones existentes para no romper las referencias cruzadas (`§1.8`, `§5.6`) que ya usan `nebula-process` y `supernova`.

---

## 8. Limpieza menor opcional (fuera del alcance central)

Estos no son de prompt sino de higiene. Los listo para decidir aparte:

- Templates con `fase` por defecto inconsistente: `person`, `system`, `runbook`, `database`, `table`, `changelog`, `claude_conversation`, `constellation` arrancan en `activa`; el resto en `formacion`. Normalizar a `formacion` (salvo `changelog`/`claude_conversation`, que son registros generados por el sistema) evita que una estrella creada a mano desde template se salte el gate de aprobación.
- Wikilink roto `[[fernando-urrutia]]` referenciado en 13 archivos: la persona nunca se creó. Crear la estrella o corregir los links.
- ~14 archivos crudos sueltos en la raíz del repo y en `archive/`: moverlos a `inbox/` para procesarlos con `/nebula-process`, o descartarlos.
- `author`/`owner: por_asignar` en ~40% de las estrellas: campaña de asignación aparte.

---

## 9. Orden de implementación sugerido

1. `nova.config.yaml`: bloque `health_thresholds` (sin dependencias, bajo riesgo).
2. `.claude/commands/aprobar.md`: comando nuevo (resuelve pain #1 y #2).
3. `.claude/hooks/vault-sync.sh` + registro en `.claude/settings.json` (resuelve pain #3).
4. `.claude/commands/sync.md`: comando de backlog/push.
5. Fixes en `dark-matter.md`, `big-bang.md`, `nebula-process.md` (sección 5).
6. Sección de ciclo de vida en `CLAUDE.md` (sección 7).
7. Probar en seco: correr `/aprobar` sobre 1 estrella en formación (con confirmación) y verificar commit selectivo + push.

Nota: nada de esto se commitea sin tu consentimiento explícito.

---

## 10. Riesgos y casos borde

- **Push sin credenciales:** el comando reporta y se detiene; no maneja secretos.
- **`git add` selectivo:** protege contra barrer `.obsidian/`, `.claude/worktrees/` y borrados no relacionados. Es la razón de no usar `git add -A`.
- **Hook con árbol sucio:** no hace pull; solo avisa. Evita conflictos automáticos que un usuario no técnico no sabría resolver.
- **Historias divergentes:** el hook las detecta y pide revisión manual en vez de intentar merge.
- **Hook en Windows:** depende de Git Bash. Si un compañero no lo tiene, el hook falla en silencio (el `exit 0` inicial lo cubre).
