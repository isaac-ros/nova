# Nova — Reglas del Sistema para Claude Code

Este archivo define cómo Claude Code debe procesar, clasificar, enriquecer y mantener el vault Nova. Estas reglas son la fuente de verdad del comportamiento del sistema.

---

## 1. Principios Fundamentales

1. **Una estrella, una idea.** Si una nota habla de dos cosas, se parte en dos estrellas. Siempre.
2. **Archivos markdown como fuente de verdad.** Sin base de datos propietaria. El vault es carpetas de texto.
3. **Eficiencia de tokens.** Nunca cargues el vault completo al contexto. Busca, filtra, entrega solo lo relevante.
4. **El MCP es el telescopio.** Cuando está disponible, usa `search_stars` antes de leer archivos directamente.
5. **Las constelaciones son perspectivas, no contenedores.** Una estrella puede pertenecer a múltiples constelaciones. Las constelaciones no son carpetas.
6. **Transparencia de fases.** Nunca trates una estrella `muriendo` como verdad vigente. Siempre indica su estado al usuario.
7. **Ambos lados del link.** Si A depende de B, actualiza `dependencies` en el frontmatter de A Y agrega el backlink en B.

---

## 2. Estructura del Vault

Lee `nova.config.yaml` para obtener el mapeo canónico `type → carpeta`. El mapeo es:

| Tipo | Carpeta |
|---|---|
| `concept` | `stars/conceptos/` |
| `adr` | `stars/decisiones/` |
| `query` | `stars/consultas/` |
| `code` | `stars/codigo/` |
| `endpoint` | `stars/endpoints/` |
| `meeting` | `stars/reuniones/` |
| `project` | `stars/proyectos/` |
| `person` | `stars/personas/` |
| `system` | `stars/sistemas/` |
| `dataset`, `database`, `table`, `pipeline` | `stars/datos/` |
| `dashboard_spec`, `brd` | `stars/specs/` |
| `runbook` | `stars/runbooks/` |
| `changelog`, `claude_conversation` | `stars/registros/` |
| `constellation` | `constellations/` |

Las fases `muerta` y `remanente` se mueven a `archive/`.
Las fases `nebula` y `formacion` viven en `inbox/`.

---

## 3. Frontmatter Obligatorio

Toda estrella debe tener este frontmatter base:

```yaml
---
type: <ver tipos válidos abajo>
fase: nebula | formacion | activa | muriendo | muerta | remanente
tags:
  - tag1
cumulo: <nombre del cúmulo según nova.config.yaml>
created: YYYY-MM-DD
updated: YYYY-MM-DD
author: Nombre_Apellido
owner: Nombre_Apellido
---
```

Campos opcionales pero importantes:
```yaml
constellations:
  - "[[Nombre_Constelacion]]"
wormholes:
  - target: "[[Estrella en otro cumulo]]"
    reason: "Por qué esta conexión importa"
```

### Tipos válidos
`concept`, `adr`, `query`, `code`, `endpoint`, `meeting`, `project`, `person`, `system`, `dataset`, `database`, `table`, `pipeline`, `dashboard_spec`, `brd`, `runbook`, `changelog`, `claude_conversation`

### Campos adicionales por tipo técnico

**`query`:**
```yaml
database: nombre_base_de_datos
tablas:
  - tabla1
  - tabla2
dependencies:
  - "[[tabla1]]"
summary: "Qué hace este query + qué toca. Máx 2 oraciones."
```

**`code`:**
```yaml
lenguaje: python | dax | bash | typescript | sql
dependencies:
  - "[[servicio_x]]"
summary: "Qué hace este código + qué usa. Máx 2 oraciones."
```

**`endpoint`:**
```yaml
method: GET | POST | PUT | DELETE | PATCH
url: /api/v1/recurso
servicio: nombre_del_servicio
dependencies:
  - "[[estrella_consumidora]]"
summary: "Qué hace este endpoint + qué servicio lo expone. Máx 2 oraciones."
```

---

## 4. Reglas de Naming

- Archivos: `kebab-case.md` — sin espacios, sin caracteres especiales, sin tildes en el nombre del archivo
- Títulos en el documento: español (o el idioma del vault), con tildes si aplica
- Tags: `snake_case`
- Wikilinks: `[[kebab-case]]` — usar nombre del archivo, no título H1

---

## 5. Reglas de Linking (Gravedad)

Cuando creas o modificas una estrella, aplica estas reglas:

1. **Dependencia directa**: Si una estrella referencia explícitamente a otra (una query usa una tabla, un código llama a un endpoint), crea el wikilink `[[target]]` en el cuerpo Y agrega el entry en `dependencies` del frontmatter.

2. **Pertenencia a constelación**: Toda estrella `activa` debe linkear a al menos una constelación. Si no existe constelación adecuada, marca con tag `sin-constelacion` y repórtalo.

3. **Bidireccionalidad**: Si A → B, verifica que B tenga mención o backlink hacia A (Obsidian lo genera automáticamente, pero el frontmatter `dependencies` es manual para el MCP).

4. **Actualizar ambos lados**: Cuando agregas una estrella a una constelación, actualiza el campo `constellations` en el frontmatter de la estrella Y agrega el link en el archivo de la constelación.

5. **Wormholes**: Son links cross-cúmulo de alta importancia. Solo se crean cuando la conexión es genuinamente crítica y no obvia. Siempre incluyen un `reason`.

---

## 6. Pipeline de Enriquecimiento (Formación Estelar)

Cuando procesas contenido del inbox (`fase: nebula`):

### Paso 1: Clasificación
- Lee el contenido crudo
- Determina el `type` correcto según el contenido
- Para archivos `.sql` → `type: query`; para `.py` / notebooks → `type: code`; para texto narrativo → `concept`, `runbook`, o el tipo que mejor encaje
- Para XLSXs: autoclasifica — puede ser `dataset`, `concept`, o insumo de un dataset existente

### Paso 2: Enriquecimiento (solo tipos técnicos)
Para `query`, `code`, `endpoint`:
1. Analiza el contenido en profundidad
2. Extrae: tablas/servicios/dependencias referenciadas
3. Genera el `summary`: **exactamente 2 oraciones**. Formato: "Qué hace + qué toca/usa."
   - Ejemplo: "Script que carga el catálogo de productos desde el archivo CSV fuente. Lee `productos_raw.csv` y escribe en la tabla `dim_producto` del warehouse."
   - Evitar: resúmenes vagos, más de 2 oraciones, información redundante con el título

### Paso 3: Estructura del archivo
- Aplica el template del tipo correspondiente (ver `templates/`)
- Escribe el frontmatter completo
- Estructura el contenido (título H1, secciones)
- Deja `fase: formacion` — el humano la aprueba y cambia a `activa`

### Paso 4: Links y constelaciones
- Identifica qué constelaciones son relevantes y agrega al campo `constellations`
- Crea links a estrellas existentes que sean dependencias directas
- Si detectas links faltantes o huérfanas, repórtalo al usuario

---

## 7. Supernova (Re-enriquecimiento)

Cuando una estrella `activa` se modifica significativamente:

1. Su `fase` regresa automáticamente a `formacion`
2. Si es tipo técnico, re-ejecuta el enriquecimiento (summary + dependencies)
3. Regenera los embeddings (vía `index_star` del MCP si está disponible)
4. Solo envía a `inbox/` si hay conflictos que no puedes resolver: dependencias ambiguas, cambios que afectan múltiples estrellas conectadas

Cambios menores (typos, actualización de links) NO son supernova — no cambian `fase`.

---

## 8. Reglas de Fase

| Acción | Regla |
|---|---|
| `nebula → formacion` | Claude Code procesa el contenido |
| `formacion → activa` | El `author` aprueba explícitamente |
| `activa → muriendo` | El `author` u `owner` decide deprecar |
| `muriendo → muerta` | El `author` u `owner` archiva |
| `muerta → activa` | Reactivación — requiere revisión completa |
| `* → remanente` | Solo el comando `/fusion` |

**Nunca cambies `fase: activa` a `fase: formacion` sin razón técnica documentada.**
**Nunca muevas archivos entre carpetas sin actualizar el frontmatter.**

---

## 9. Comportamiento con Estrellas según Fase

| Fase | Cómo tratarla |
|---|---|
| `activa` | Fuente de verdad. Citar directamente. |
| `formacion` | Indicar que está pendiente de verificación. Útil como referencia, no como verdad definitiva. |
| `muriendo` | Advertir explícitamente: "Esta información está marcada como deprecada." Buscar alternativa más reciente. |
| `muerta` | Solo referenciar si no hay alternativa. Indicar que está archivada. |
| `remanente` | Redirigir siempre a la estrella fusionada. No citar el contenido del remanente. |
| `nebula` | No existe para el usuario. Solo existe para Claude Code durante el procesamiento. |

---

## 10. Health Check — Señales de Alerta

Durante cualquier operación, reporta al usuario si detectas:

- **Huérfanas**: Estrellas sin ningún link entrante ni saliente (después de `ORPHAN_ALERT_DAYS` días)
- **Stale en formacion**: Estrellas en `formacion` desde hace más de `STALE_DRAFT_DAYS` días sin aprobarse
- **Co-ocurrencia de tags**: Dos estrellas con 3+ tags en común y sin link entre sí → posible conexión faltante
- **Constelación sobrepoblada**: Una constelación con más de `CONSTELLATION_MAX_STARS` estrellas → sugerir dividir
- **Constelación vacía**: Una constelación con menos de 3 estrellas → sugerir fusionar con otra
- **Posibles duplicados**: Estrellas con similitud semántica >= `FUSION_THRESHOLD` → candidatos a `/fusion`

---

## 11. Constelaciones

### Estructura de una constelación
```markdown
---
type: constellation
cumulo: <nombre del cúmulo>
fase: activa
created: YYYY-MM-DD
updated: YYYY-MM-DD
maintainer: Nombre_Apellido
---

# Nombre de la Constelación

Descripción del patrón de conocimiento que esta constelación representa.

## Estrellas en esta constelación

### Categoría A
- [[Estrella 1]]
- [[Estrella 2]]

## Conexiones con otras constelaciones
- [[Otra_Constelacion]] — por qué están relacionadas
```

### Reglas para constelaciones
- Las constelaciones NO son carpetas. No muevas estrellas entre carpetas para organizarlas — agrega links en la constelación.
- Una misma estrella puede pertenecer a múltiples constelaciones — esto es deseable.
- La fuente de verdad de qué estrellas tiene una constelación es el archivo de la constelación. En caso de discrepancia con el frontmatter de la estrella, la constelación gana.
- El `maintainer` es el `owner` de la estrella con mayor número de backlinks en el cluster.

---

## 12. Uso del MCP (cuando está disponible)

Flujo recomendado para buscar conocimiento:

1. `search_stars(query, detail_level="summary", max_results=10)` — screening inicial
2. Evalúa los summaries y selecciona los 2-3 más relevantes
3. `search_stars(query, detail_level="standard")` de los seleccionados — confirmar relevancia
4. `get_star(path, detail_level="full")` de 1-2 estrellas específicas — trabajar con el contenido
5. Solo usa `detail_level="complete"` para problemas complejos que requieren el grafo completo

**Siempre filtra por `fase_filter="activa"` salvo que el usuario pida explícitamente ver otros estados.**

---

## 13. Convención de Commits Git

```
[star] descripción breve de la estrella creada o modificada
[constellation] qué constelación se actualizó
[fix] corrección de links rotos, frontmatter incorrecto, etc.
[fusion] resultado de fusión de estrellas
[big-bang] ingesta masiva desde fuente externa
```

---

*Estas reglas se aplican en todos los slash commands del vault. Si hay conflicto entre estas reglas y una instrucción específica del usuario, el usuario tiene prioridad — pero registra la excepción como un `changelog`.*
