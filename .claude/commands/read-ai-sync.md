# /read-ai-sync

Trae las reuniones nuevas de Read.ai al vault: guarda el original en `archive/` y crea la estrella `meeting` en `stars/reuniones/` directamente en `fase: activa`.

Se puede correr a mano o desde la tarea programada. Es idempotente: una reunión que ya existe en el vault (por `fuente_id`) nunca se vuelve a crear.

**Aprobación automática.** Las reuniones de este flujo no pasan por `/aprobar`: el author dejó aprobado el paso `formacion → activa` por política (CLAUDE.md §8; registra la decisión como un `changelog` en tu vault). A cambio, cada estrella pasa el gate de calidad del paso 6.5; si no lo pasa, se queda en `formacion` y se reporta.

**El vault es local.** El comando solo lee de Read.ai (entrada) y escribe en disco. No hace commits, no hace `push`, no publica nada (CLAUDE.md §14). Las estrellas activas sin commitear se versionan cuando el usuario pide versionar el backlog, incluyendo la carpeta de `fuente_archivo`.

## Uso

```
/read-ai-sync                      # reuniones desde la última sincronización
/read-ai-sync desde YYYY-MM-DD     # fuerza la ventana de búsqueda
/read-ai-sync <ULID>               # una reunión específica
/read-ai-sync archivar-existentes  # solo guarda originales de estrellas read_ai que no tienen carpeta en archive/
```

## Configuración y estado

- Configuración: sección `read_ai_sync` de `nova.config.yaml`.
- Estado: `.claude/read-ai-sync-state.json`. Si no existe, créalo:

```json
{
  "ultima_sincronizacion": null,
  "pendientes": {},
  "omitidas": {}
}
```

`pendientes` guarda reuniones que Read.ai todavía no termina de procesar (se reintentan). `omitidas` guarda las que se descartaron por regla, con la razón, para no reevaluarlas.

## Instrucciones

### 1. Ventana de búsqueda

- Si hay `ultima_sincronizacion`: desde esa fecha menos `solape_horas`.
- Si no hay: hoy menos `ventana_inicial_dias`.
- Si el usuario pasó `desde`, usa esa fecha.

Llama `list_meetings` del conector Read.ai con `start_datetime_gte` = inicio de la ventana y `limit: 10`, sin `expand`. Pagina con `cursor` (= `id` de la última reunión de la página) mientras `has_more` sea `true`. Agrega los IDs que estén en `pendientes` aunque caigan fuera de la ventana.

### 2. Filtrar

Para cada reunión, en este orden:

1. **Ya existe:** busca el `id` con Grep en `stars/`, `archive/` e `inbox/`. Si aparece, sáltala sin reportarla.
2. **Ya omitida:** si está en `omitidas`, sáltala.
3. **Reglas de exclusión** (agrégala a `omitidas` con la razón):
   - duración (`end_time_ms - start_time_ms`) menor a `duracion_minima_min`
   - menos de `asistentes_minimos` participantes con `attended: true`
   - título que coincide con algún patrón de `excluir_titulos` (sin distinguir mayúsculas)
4. **Sin procesar:** pide `get_meeting_by_id` con `expand: ["summary", "action_items"]`. Si `summary` viene vacío y la reunión terminó hace menos de 24 horas, agrégala a `pendientes` y sigue con la siguiente. Si pasaron más de 24 horas y sigue vacía, muévela a `omitidas` con razón `sin resumen de Read.ai`.

### 3. Traer el contenido completo

`get_meeting_by_id` con `expand: ["summary", "chapter_summaries", "action_items", "key_questions", "topics", "transcript"]`.

Calcula la fecha local de la reunión con `date -d @<start_time_ms/1000> +%F` (Bash, zona horaria de la máquina). No uses la fecha UTC.

### 4. Nombre

`<slug-del-titulo>-<YYYY-MM-DD>`, en kebab-case, sin tildes ni caracteres especiales (CLAUDE.md §4). Antes de inventar un slug, revisa si ya hay estrellas de la misma serie en `stars/reuniones/` (mismo título en otra fecha) y reutiliza ese prefijo. Ejemplo: si existe `daily-equipo-2026-10-01.md`, la siguiente "Daily del Equipo" es `daily-equipo-2026-10-08`.

Si el nombre ya está ocupado por otra reunión, agrega un sufijo `-2`.

### 5. Guardar el original en `archive/`

Crea la carpeta `archive/<nombre>/` con tres archivos. El contenido va **tal como lo entregó Read.ai**: sin glosario, sin corregir nombres, sin resumir. Es la copia fiel.

**`Recap.txt`**

```
<título>
<fecha local legible>

Summary:

<summary>

Chapters:

<por capítulo: título y resumen>

Action Items:

* <cada action item>

Key Questions:

* <cada pregunta>

Topics:

* <cada tema>
```

Omite las secciones que vengan vacías.

**`Transcript.txt`**: una línea por turno, `<Nombre del hablante> (mm:ss): <texto>`, con el tiempo relativo al inicio de la reunión. Si el transcript trae otra estructura, conserva hablante, tiempo y texto en ese orden.

**`meeting.json`**: los metadatos de la reunión (`id`, `title`, `start_time_ms`, `end_time_ms`, `scheduled_start_time_ms`, `scheduled_end_time_ms`, `participants`, `owner`, `report_url`, `platform`, `platform_id`, `folders`) más `"archivado": "<fecha de hoy>"`. Sin transcript ni resumen, para no duplicar.

### 6. Crear la estrella

Sigue `/nebula-process` (`.claude/commands/nebula-process.md`) para una estrella `type: meeting`, usando el template `templates/meeting.md`. Puntos específicos de este flujo:

- **Glosario (obligatorio):** lee `glosario.md` completo antes de redactar y aplica el paso 1.5 de `/nebula-process` a todo lo que escribas en la estrella: título, cuerpo, tabla de acciones y frontmatter. El original en `archive/` nunca se corrige. Usa los alias y la sección "Personas distintas con nombres parecidos" para decidir a qué persona o sistema enlazar. Cierra el cuerpo con la línea `> Correcciones de transcripción (glosario): ...`; si no hubo correcciones, escribe `> Correcciones de transcripción (glosario): ninguna.` para que quede constancia de que el check corrió.
- **Participantes:** solo los que tienen `attended: true`. Enlaza a `stars/personas/` comparando por correo y nombre completo. No asignes un wikilink por similitud fonética: si no hay match claro, escribe el nombre en texto plano y repórtalo. Los invitados que no asistieron van en una línea aparte, como en las estrellas existentes.
- **Frontmatter:**
  ```yaml
  fase: formacion   # se cambia a activa en el paso 6.5 si pasa el gate
  author: <owner de la config>
  owner: <owner de la config>
  fecha: <fecha local>
  fuente: read_ai
  fuente_id: "<id>"
  fuente_url: "<report_url>"
  fuente_archivo: "archive/<nombre>/"
  ```
- **Cuerpo:** objetivo, puntos discutidos (a partir de los capítulos y el transcript, no solo del summary), decisiones, tabla de acción items con responsable enlazado y próxima reunión si se mencionó. Usa el transcript para precisar cifras, nombres de sistemas y acuerdos que el summary aplana.
- **Constelaciones y dependencias:** pasos 5 y 5.5 de `/nebula-process`. Reporta candidatos a supernova; no edites estrellas destino.

### 6.5. Gate de calidad y activación

Aplica el gate del paso 3 de `/aprobar` (`.claude/commands/aprobar.md`) a la estrella recién creada:

- frontmatter obligatorio completo, más `fecha`, `fuente_id` y `fuente_archivo`
- al menos una constelación en `constellations` (no vale el tag `sin-constelacion` para activar)
- todos los wikilinks del cuerpo y del frontmatter resuelven a un archivo existente
- la carpeta de `archive/` existe con `Recap.txt`, `Transcript.txt` y `meeting.json`
- **check del glosario:** existe la línea `> Correcciones de transcripción (glosario)`, y una búsqueda (Grep) de cada error con regla `auto` de las secciones confirmadas no encuentra ninguno en la estrella, ignorando esa misma línea de auditoría (mismo criterio que el check 8 de `/dark-matter`). Si dejaste algún error `contextual` sin corregir porque el contexto no alcanzaba para decidir, la estrella se queda en `formacion` y el reporte muestra la línea de contexto. Los usos legítimos de una palabra `contextual` no bloquean

Si pasa: `fase: activa`. En las constelaciones, enlázala en la sección principal de reuniones, no en la de sesiones en formación.

Si no pasa: déjala en `formacion` y repórtala con la razón. El usuario la cierra con `/aprobar`.

### 7. Actualizar el estado

- `ultima_sincronizacion` = fecha y hora de inicio de esta corrida (ISO 8601). Solo avánzala si la corrida terminó sin errores del conector.
- Quita de `pendientes` las que se procesaron.

### 8. Reporte

```
═══ Read.ai → Nova ═══
Ventana: <inicio> → <ahora>
Encontradas: N   Nuevas: X   Ya en el vault: Y   Pendientes: P   Omitidas: O

✦ activa      <nombre>.md   (<participantes>)   → [[constelacion]]
   Original: archive/<nombre>/
   Glosario: <"Variante" → Correcto, ...> | ninguna
✧ formacion   <nombre>.md   no pasó el gate: <razón>
   Glosario: <"Variante" → Correcto, ...> | dudas: <término contextual y su línea>
...

○ Pendientes (Read.ai sin procesar): <título> (<fecha>)
⊘ Omitidas: <título> (<fecha>): <razón>

? Nombres sin estrella en personas/: ...
? Posibles errores de transcripción fuera del glosario: ...

∆ Candidatos a supernova:
   [[destino]]: <qué cambió>
```

No hagas commit. Las reuniones activas quedan en el backlog sin commitear; las que se quedaron en `formacion` se cierran con `/aprobar`, que también versiona su carpeta de `archive/`.

## Modo `archivar-existentes`

Para estrellas `fuente: read_ai` que ya están en el vault pero no tienen original:

1. Lista las estrellas de `stars/reuniones/` con `fuente: read_ai` y sin `fuente_archivo`, o cuya carpeta en `archive/` no existe.
2. Para cada una, ejecuta los pasos 3 y 5 con su `fuente_id`, usando el nombre del archivo de la estrella como `<nombre>`.
3. Agrega `fuente_archivo` al frontmatter de la estrella. Es un cambio menor: no cambia `fase` ni `updated` (CLAUDE.md §7).
4. Procesa en lotes de 10 y reporta avance entre lotes.
