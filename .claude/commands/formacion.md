# /formacion

Auditoría de las estrellas en `fase: formacion`. Presenta una tabla de revisión con importancia y señales de calidad, para que el usuario decida qué aprobar con `/aprobar` y qué corregir o descartar antes.

Es de solo lectura: no cambia `fase`, no mueve archivos, no commitea. Es el paso previo a `/aprobar`, no un sustituto.

## Uso

```
/formacion                # audita todas las estrellas en formacion
/formacion [carpeta|tipo] # acota a una carpeta de stars/ o a un type
```

## Instrucciones

### 1. Descubrir estrellas en formación

Busca en `stars/` (todas las subcarpetas) los archivos con `fase: formacion`. No busques en `inbox/` (CLAUDE.md §2).

Si no hay ninguna, informa "No hay estrellas en formación pendientes" y detente.

### 2. Gate de calidad — por estrella

Igual que el paso 3 de `/aprobar`, pero solo para reportar:

- **Frontmatter obligatorio completo**: `type`, `fase`, `tags`, `cumulo`, `created`, `updated`, `author`, `owner`.
- **`author` / `owner` en `por_asignar`**: adviértelo.
- **Constelación**: al menos una entrada en `constellations`, o tag `sin-constelacion`.
- **Wikilinks del cuerpo**: que resuelvan a un archivo existente en `stars/`, `constellations/` o `archive/`. Reporta los rotos.

### 3. Señal de fundamento — detectar contenido hueco o mal derivado

El usuario puede sospechar que una estrella nació de una conversación con un LLM y se promovió por error, sin un origen real en el vault (una reunión, una tabla, un sistema, un requerimiento). Evalúa cada estrella contra estas señales:

- **Sin anclaje**: cero wikilinks salientes (`dependencies` vacío y sin `[[...]]` en el cuerpo) y cero entrantes. No cuelga de nada del vault.
- **Sin trazabilidad de origen**: no cita una sesión (`source`), una tabla, un sistema, o fechas/nombres concretos — es prosa genérica sin datos verificables (nombres de columnas, personas reales, números, IDs de sistema).
- **Contenido mínimo**: menos de ~15 líneas de cuerpo sin sustancia técnica ni decisiones.
- **Posible duplicado**: título o alcance casi idéntico a otra estrella ya `activa` — puede ser el resultado de reprocesar el mismo insumo dos veces.

Clasifica el veredicto de cada estrella:
- **Fundamentada** — pasa las señales, tiene anclaje real.
- **Revisar** — dispara 1 señal, no es concluyente, pídele al usuario que la mire.
- **Posible error** — dispara 2+ señales, recomienda no aprobar sin que el usuario confirme el origen.

No borres ni cambies nada por tu cuenta. Esto es diagnóstico, no acción.

### 4. Importancia — por estrella

Estima la importancia relativa dentro del vault:

- **Crítica**: la referencian 5+ estrellas (`dependencies` o wikilinks entrantes), o es tipo `brd`/`adr`/regla de negocio (`concept` citado como fuente de una decisión), o es infraestructura de la que depende un pipeline activo.
- **Alta**: pertenece a un proyecto (`project`) activo o a una constelación con actividad reciente, y tiene 2-4 referencias entrantes.
- **Media**: técnica o operativa (código, runbook, dataset) con 1 referencia entrante.
- **Baja**: sin referencias entrantes, o tipo `person`/`document` de apoyo puntual.

### 5. Presentar la tabla

```
# Auditoría de Formación — YYYY-MM-DD

N estrellas en formación · X días promedio de espera

| # | Estrella | Tipo | Carpeta | Resumen | Días | Importancia | Fundamento | Advertencias |
|---|---|---|---|---|---|---|---|---|
| 1 | [[nombre]] | concept | conceptos | resumen corto | 5 | Crítica | Fundamentada | — |
```

Después de la tabla:

```
## Resumen
- ✅ Fundamentadas: N — listas para /aprobar
- 🟡 Revisar: N — [[lista]]
- 🔴 Posible error: N — [[lista]] · señales: <cuáles disparó cada una>
- ⚠️ Advertencias de frontmatter: author/owner en por_asignar (N) · wikilinks rotos (N) · sin constelación (N)

## Recomendación
- Aprobar directo: [[a]], [[b]], ...
- Revisar antes de aprobar: [[c]] — <por qué>
- Confirmar origen o descartar: [[d]] — <señales que disparó>
```

Marca como stale (mención aparte, no bloqueante) las que superen `STALE_DRAFT_DAYS` de `health_thresholds` en `nova.config.yaml`.

### 6. Siguiente paso

Termina el reporte sugiriendo el comando exacto, por ejemplo:

```
Siguiente paso sugerido: /aprobar [[a]] [[b]] [[c]]   (o /aprobar todas si no hay "Posible error" pendientes)
```

No ejecutes `/aprobar` tú mismo — el usuario decide y lo invoca aparte.

---

**Reglas:**
- Solo lectura. Nunca cambia `fase`, nunca mueve archivos, nunca commitea.
- No es un juicio sobre el autor — el veredicto de fundamento es sobre el contenido, no sobre quién lo escribió.
- Si el usuario pide "audita solo lo sospechoso", corre igual el paso 1 completo pero en la tabla filtra a `Revisar` y `Posible error`.
