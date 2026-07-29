# /supernova

Re-enriquece una estrella `activa` que fue modificada significativamente. **Aplica a cualquier tipo de estrella** — no solo a código.

## Uso

```
/supernova [path o título de la estrella]
```

Si no se especifica una estrella, busca en `stars/` estrellas `activa` cuyo `updated` sea más reciente que la fecha de su último re-enriquecimiento (inferido del historial).

## Instrucciones

### 1. Verificación y selección de ruta

Lee la estrella indicada. Confirma que:
- `fase: activa` — si está en otro estado, informa al usuario y detente.

Identifica el `type` y selecciona la **ruta de enriquecimiento**. Ya no se rechaza ningún tipo; el re-enriquecimiento se adapta:

- **Ruta técnica** — tipos en `llm_enrichment_types` de `nova.config.yaml` (`query`, `code`, `endpoint`): extracción de metadata estructurada.
- **Ruta de conocimiento** — el resto (`concept`, `system`, `meeting`, `project`, `dataset`, `database`, `table`, `pipeline`, `brd`, `dashboard_spec`, `runbook`, `document`, `person`, `adr`, `changelog`, `constellation`): re-evaluación de contenido narrativo, resumen, links y secciones.

### 2. Determinar si el cambio es significativo

Un cambio es **significativo** (genérico, cualquier tipo) si:
- Cambió el contenido sustantivo, no solo formato o redacción.
- Se agregaron o eliminaron **dependencias, integraciones, secciones, hechos, números o fechas**.
- Cambió el **propósito, estado o alcance** de la estrella.
- El contenido nuevo **contradice o supera** lo previo.

Señales adicionales por ruta:
- **Técnica**: cambió la lógica central del query/código; cambiaron tablas, imports, servicios o el output.
- **Conocimiento**: se agregaron hechos/roles/integraciones o secciones nuevas; cambió un estado documentado (p. ej. "en desarrollo" → "en producción"); el resumen/definición ya no refleja el contenido.

Un cambio es **menor** si: solo se corrigieron typos, se mejoró redacción, o se actualizó un link o tag.
→ Actualiza `updated` en el frontmatter, **no cambies `fase`**, y confirma al usuario. (No continúes a los pasos 3–5.)

### 3. Re-enriquecimiento (cambios significativos)

**Ruta técnica (`query` / `code` / `endpoint`):**
- Extrae tablas, dependencias, imports y servicios actualizados.
- Regenera el `summary` con **exactamente 2 oraciones** (qué hace + qué toca/usa).
- Actualiza los campos específicos del tipo (`database`/`tablas`, `lenguaje`, `method`/`url`/`servicio`).

**Ruta de conocimiento (resto de tipos):**
- Re-lee el contenido completo e identifica con precisión **qué cambió**.
- Regenera el campo de resumen que el tipo tenga, sin inflarlo:
  - `summary` (si el frontmatter lo usa, p. ej. `document`, `dataset`): 1–2 oraciones.
  - `concept`: la oración-definición del blockquote inicial.
  - `system`: la descripción / línea de estado.
  - `meeting`: el blockquote de objetivo y, si aplica, decisiones/acción items.
  - `project` / `brd` / `runbook`: el resumen ejecutivo o de propósito.
- Actualiza `tags` para reflejar los temas nuevos.
- **No reescribas lo que no cambió.** Agrega o actualiza solo las secciones afectadas (p. ej. una sub-sección fechada con la fuente del cambio).

En **ambas rutas**, actualiza el frontmatter:
- `dependencies` / `constellations`: agrega los wikilinks nuevos detectados.
- `updated`: fecha actual.
- `fase`: `activa` → `formacion`.

### 4. Verificar links

Revisa que los wikilinks (en el cuerpo y en `dependencies` / `constellations`) tengan estrella existente en el vault. Si alguno no existe:
- Indica cuáles faltan.
- Pregunta al usuario si quiere crear las estrellas faltantes.

### 5. Propagación hacia arriba (gravedad bidireccional)

Aplica el §1.8 y la regla §5.6 del `CLAUDE.md`. Para **cada wikilink destino** de la estrella re-enriquecida, evalúa si el contenido nuevo deja **stale** a esa estrella destino (agrega hechos/números/fechas ausentes, integraciones/roles no documentados, o contradice/actualiza un estado).

Si es así, márcala como **candidata a supernova** y repórtala con un diff descriptivo:

```
∆ Candidato a supernova: [[nombre-destino]]
   Razón: [qué cambió / qué falta en el destino]
   Sugerencia: /supernova nombre-destino
```

**Regla por defecto: reportar, no editar.** Solo puedes editar el destino para (a) agregar un backlink wikilink hacia la estrella re-enriquecida (§5.3) o (b) agregar el link a la constelación correspondiente (§5.4).

### 6. Manejo de conflictos

Si detectas situaciones que no puedes resolver automáticamente:
- Dependencias ambiguas (una referencia que puede ser varias cosas).
- Cambios que afectan a múltiples estrellas conectadas.
- El nuevo contenido contradice otra estrella `activa`.

En estos casos: **NO** muevas el archivo al inbox. Deja el archivo donde está con `fase: formacion` y describe el conflicto al usuario para resolución manual.

### 7. Reporte

```
✦ Supernova: [nombre-estrella.md]
   Tipo / Ruta: [type] / [técnica | conocimiento]
   Fase: activa → formacion (pendiente de re-aprobación)
   Resumen anterior: "[anterior]"
   Resumen nuevo:    "[nuevo]"          # o "Secciones actualizadas: [...]"
   Dependencias: +[[nueva]], -[[eliminada]]
   Candidatos a supernova (hacia arriba): [[destino]] — razón  (o: ninguno)
   Conflictos: ninguno / [descripción si hay]
   Acción: Revisar cambios y cambiar fase → activa cuando esté conforme
```

---

**Notas:**
- Aplica a **cualquier tipo** de estrella. La diferencia entre rutas es solo qué se re-enriquece (metadata técnica vs. contenido/resumen narrativo).
- La fase regresa a `formacion` automáticamente en cambios significativos. El usuario aprueba explícitamente.
- No hay supernova automática — siempre es invocado explícitamente por el usuario o como parte de otro comando.
- Para re-aprobar: cambiar `fase: formacion` → `fase: activa` en el frontmatter.
- Cambios menores (typos, links, tags) no son supernova: solo actualizan `updated`.
