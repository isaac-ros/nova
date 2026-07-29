# /nebula-process

Procesa el contenido del `inbox/` y convierte nebulosas en estrellas estructuradas.

## Instrucciones

Lee todos los archivos en `inbox/` con `fase: nebula` (o sin frontmatter).

Para cada archivo, ejecuta el siguiente pipeline en una sola pasada:

### 1. Clasificación

Determina el `type` basándote en el contenido y extensión:
- `.sql` o `.dax` → `type: query`
- `.py`, `.ipynb`, `.js`, `.ts` → `type: code`
- `.xlsx`, `.csv` → autoclasifica: puede ser `dataset`, `concept`, o insumo de dataset existente. Si es datos crudos → `dataset`. Si define métricas → `concept`.
- `.pdf` → autoclasifica según contenido: `brd`, `concept`, `runbook`, `dataset`
- `.md` sin tipo → infiere por el contenido

### 2. Enriquecimiento LLM (solo para `query`, `code`, `endpoint`)

Analiza el contenido en profundidad y extrae:
- Para `query`: tablas referenciadas, base de datos, tipo de operación (SELECT/INSERT/UPDATE)
- Para `code`: lenguaje, imports, servicios o APIs que llama, outputs
- Para `endpoint`: método HTTP, URL, servicio que lo expone, parámetros clave

Genera el `summary` con **exactamente 2 oraciones**:
- Oración 1: qué hace
- Oración 2: qué toca / qué usa
- Ejemplo: "Script que carga el catálogo de productos desde el archivo CSV fuente. Lee `productos_raw.csv` y escribe en la tabla `dim_producto` del warehouse."

### 3. Construcción del archivo

Aplica el template de `templates/[type].md` como base.

Escribe el frontmatter completo:
```yaml
---
type: [tipo detectado]
fase: formacion
cumulo: [según nova.config.yaml cumulo_default]
tags:
  - [tags inferidos del contenido]
constellations:
  - "[[Constelacion_Relevante]]"   # Inferir de qué constelación corresponde
created: [fecha actual]
updated: [fecha actual]
author: [si se puede inferir del contenido, sino: por_asignar]
owner: por_asignar
# campos adicionales según tipo
---
```

Estructura el contenido del archivo según el template del tipo.

### 4. Naming del archivo

Usa `kebab-case` en español, sin tildes en el nombre de archivo. Descriptivo y único.
- Ejemplo: `query-costo-nomina-mensual.md`, `script-carga-inventario.md`

### 5. Links y dependencias

- Busca estrellas existentes en `stars/` que sean dependencias directas
- Agrega wikilinks en el cuerpo y en el campo `dependencies` del frontmatter
- Agrega el link a la constelación correspondiente en `constellations/`
- Actualiza el campo `constellations` en el frontmatter de la constelación si es necesario

### 6. Mover el archivo

Mueve el archivo procesado de `inbox/` a la carpeta correcta según `nova.config.yaml` (type_folder_map).
El archivo queda con `fase: formacion`.

### 7. Reporte al usuario

Al terminar cada archivo (o el lote), presenta:

```
✦ Procesado: [nombre_original] → [nombre_final.md]
   Tipo: [type]
   Constelación: [constelacion]
   Summary: "[summary generado]"
   Links creados: [[estrella1]], [[estrella2]]
   Acción pendiente: Revisar y cambiar fase: formacion → activa
```

Si hay archivos ambiguos o con conflictos que no puedes resolver, repórtalos por separado con la razón.

### 8. Aprobación humana

Recuerda al usuario:
- Las estrellas con `fase: formacion` (ya en su carpeta destino) están listas para revisión
- Para aprobar y publicar: `/aprobar [nombre-archivo]` (cambia la fase, hace commit y push)

---

**Notas:**
- No proceses archivos con `fase: formacion` o superior — ya fueron procesados
- Si el `inbox/` está vacío, confirma al usuario que no hay nebulosas pendientes
- El procesamiento puede ser en lote (todos los archivos) o individual: `/nebula-process [nombre-archivo]`
