# /dark-matter

Health check del vault. Detecta problemas, conexiones faltantes y oportunidades de organización.

## Uso

```
/dark-matter
/dark-matter --solo-criticos
/dark-matter --tipo orphans
```

## Instrucciones

Ejecuta los siguientes checks y presenta un reporte consolidado.

### Check 1: Estrellas huérfanas (Orphans)

Busca estrellas en `stars/` con `fase: activa` que:
- No tienen ningún link saliente (`dependencies` vacío Y sin wikilinks `[[]]` en el cuerpo)
- No tienen ningún link entrante (ninguna otra nota las referencia)

Umbral: reportar si llevan más de `ORPHAN_ALERT_DAYS` días sin conexiones (default: 7 días).

### Check 2: Estrellas stale en formacion

Busca archivos en `inbox/` con `fase: formacion` cuyo `created` o `updated` tiene más de `STALE_DRAFT_DAYS` días (default: 30 días) sin aprobarse.

### Check 3: Candidatos a Fusión Estelar

Busca pares de estrellas con similitud semántica >= `FUSION_THRESHOLD` (default: 0.9).

Si el MCP está disponible: usa `report_dark_matter(check_fusion_candidates=true)`.

Si no hay MCP: busca estrellas con el mismo título o títulos muy similares, o estrellas con exactamente los mismos tags y mismo tipo.

Agrupa en clusters de 3+ estrellas cuando aplique — son candidatos a `/fusion`.

### Check 4: Materia oscura — conexiones implícitas faltantes

Busca pares de estrellas con 3+ tags en común que no están conectadas entre sí. Estos son links probablemente faltantes.

### Check 5: Constelaciones en mal estado

**Sobrepobladas**: constelaciones con más de `CONSTELLATION_MAX_STARS` estrellas (default: 35) → sugerir dividir.

**Vacías o infrapobladas**: constelaciones con menos de 3 estrellas → sugerir fusionar con otra o eliminar.

**Estrellas sin constelación**: estrellas `activa` que no aparecen en ninguna constelación y no tienen `constellations` en su frontmatter.

### Check 6: Constelaciones emergentes

Detecta clusters de estrellas que comparten múltiples tags y no tienen constelación propia, con al menos `CONSTELLATION_MIN_CLUSTER` estrellas (default: 5).

Para cada cluster, propone:
- Nombre sugerido de la constelación (inferido de los tags comunes)
- Lista de estrellas candidatas
- `maintainer` sugerido: el `owner` de la estrella con más backlinks en el cluster

### Check 7: Wormholes sugeridos

Busca pares de estrellas de diferentes `cumulo` que se referencian entre sí pero no tienen `wormholes` documentados. (Cuando haya múltiples cúmulos activos.)

Por ahora: busca estrellas de `stars/consultas/` que referencian a `stars/sistemas/` — estas conexiones son candidatas a wormholes.

---

## Formato del reporte

```
# Reporte de Materia Oscura — YYYY-MM-DD

## Resumen
- 🔴 Crítico: X problemas
- 🟡 Atención: Y situaciones
- 🟢 Oportunidades: Z sugerencias

---

## 🔴 Estrellas huérfanas (X)
- [[estrella-huerfana]] — X días sin conexiones

## 🔴 Estrellas stale en formacion (X)
- [[archivo]] — X días sin aprobarse

## 🟡 Candidatos a Fusión Estelar (X pares / Y clusters)
- [[estrella-a]] ↔ [[estrella-b]] — similitud: 0.94
  Cluster: [[a]], [[b]], [[c]] → candidatos a /fusion

## 🟡 Conexiones implícitas faltantes (X)
- [[estrella-x]] ↔ [[estrella-y]] — 4 tags en común: tag1, tag2, tag3, tag4

## 🟡 Constelaciones en mal estado (X)
- [[Mi_Constelacion]]: 38 estrellas → considerar dividir en dos constelaciones hermanas
- [[Nombre]]: 2 estrellas → considerar fusionar con [[Otra]]

## 🟢 Estrellas sin constelación (X)
- [[estrella-sin-moc]] — tipo: query, tags: sql, reportes

## 🟢 Constelaciones emergentes sugeridas (X)
- Sugerencia: "Nombre_Sugerido" — 6 estrellas candidatas: [[a]], [[b]]...
  Maintainer sugerido: [[Nombre_Apellido]]

## 🟢 Wormholes sugeridos (X)
- [[query-ventas]] ↔ [[Sistema_ERP]] — conexión directa no documentada como wormhole

---

## Acciones recomendadas

1. Ejecutar `/fusion` para el cluster: [[a]], [[b]], [[c]]
2. Aprobar o descartar estrellas stale en inbox/
3. Crear constelación "Integraciones_SAP" — responder: sí/no
4. Agregar links faltantes entre [[x]] ↔ [[y]]
```

---

**Notas:**
- El reporte es de solo lectura. Para ejecutar fusiones: usar `/fusion`.
- Para crear constelaciones emergentes: el usuario confirma y Claude ejecuta.
- Sin MCP disponible, los checks de similitud semántica son aproximados (basados en título y tags).
