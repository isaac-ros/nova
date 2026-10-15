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

### 1.5. Normalización de términos (glosario)

Si existe `glosario.md` en la raíz del vault, léelo antes de escribir la estrella. Aplica solo las secciones confirmadas; ignora "Por confirmar" y "Sin resolver".

- **Errores con regla `auto`:** reemplázalos por la forma correcta en todo el cuerpo y el frontmatter.
- **Errores con regla `contextual`:** reemplázalos solo si el contexto confirma el significado indicado en la columna Contexto. Si hay duda, deja el término como está.
- **Alias:** no se reemplazan en el texto. Úsalos para identificar a qué estrella enlazar.
- Si la columna Estrella tiene un wikilink, enlaza la primera mención.
- Revisa la sección "Personas distintas con nombres parecidos" antes de enlazar a una persona.

Agrega al final del cuerpo de la estrella una línea con lo que se corrigió, para que el cambio sea auditable:

```
> Correcciones de transcripción (glosario): "Variante" → Correcto; "Otra" → Correcto.
```

Si encuentras palabras que parecen errores de transcripción y no están en el glosario (nombres que no coinciden con ninguna estrella, siglas que solo aparecen en esta fuente, términos que suenan parecido a un sistema o persona conocida), no las corrijas. Repórtalas como candidatas en el reporte final (paso 7).

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

### 5.5. Propagación de conocimiento (candidatos a supernova)

Aplica el principio §1.8 (**Gravedad bidireccional del conocimiento**) y la regla §5.6 (**Impacto hacia arriba**) del CLAUDE.md.

Para **cada wikilink destino** en la nueva estrella, compara el contenido nuevo contra el contenido vigente del destino:

- ¿La nueva estrella agrega **hechos**, **números** o **fechas** ausentes del destino?
- ¿Contiene **integraciones**, **dependencias** o **roles** no documentados?
- ¿**Contradice** afirmaciones del destino (estado, propietario, estructura)?
- ¿**Actualiza** un estado del destino (p. ej. "en desarrollo" → "en producción")?

Si la respuesta es sí para **alguno**, marca el destino como **candidato a supernova** y agrégalo a la lista en el reporte final con una línea de diff descriptivo. Formato:

```
∆ Candidato a supernova: [[nombre-destino]]
   Razón: [qué cambió / qué falta en el destino]
   Sugerencia: /supernova nombre-destino
```

**Regla por defecto:** *reportar, no editar*. No modifiques la estrella destino automáticamente — el usuario decide.

Excepciones en que sí puedes editar directamente:
- Agregar un wikilink nuevo desde el destino a la nueva estrella (backlink explícito, §5.3)
- Agregar el link a la constelación correspondiente (§5.4)

### 6. Mover el archivo

Mueve el archivo procesado de `inbox/` a la carpeta destino según `nova.config.yaml` (`type_folder_map`).
El archivo queda con `fase: formacion` ya en su carpeta final — no requiere movimiento posterior cuando se apruebe.

### 7. Reporte al usuario

Al terminar **cada archivo**, presenta:

```
✦ Procesado: [nombre_original] → [nombre_final.md]
   Tipo: [type]
   Carpeta: [stars/<carpeta>/]
   Constelación: [[constelacion]]
   Summary: "[summary generado]"
   Links creados: [[estrella1]], [[estrella2]]
   Acción pendiente: Revisar y cambiar fase: formacion → activa
```

Al final del lote, presenta también una **tabla resumen agrupada por carpeta** para que el usuario vea de un vistazo qué se creó y dónde quedó (sin mover nada manualmente):

```
═══ Resumen del lote ═══
Total: N archivos procesados

stars/<carpeta-A>/   (X)
   - [nombre-1.md]
   - [nombre-2.md]

stars/<carpeta-B>/   (Y)
   - [nombre-3.md]

inbox/ (sin procesar)   (Z)
   - [archivo.ext] — razón
```

Después de la tabla resumen, agrega una **sección consolidada de candidatos a supernova** con todas las estrellas destino detectadas en el paso 5.5:

```
∆ Candidatos a supernova detectados:
   - [[estrella-destino-1]] — razón breve del diff
   - [[estrella-destino-2]] — razón breve del diff
   Sugerencia: /supernova [nombre] para re-enriquecer
```

Si no hay candidatos, omite esa sección.

Si el paso 1.5 encontró términos sospechosos fuera del glosario, agrega una sección con ellos para que el usuario los confirme y se sumen a `glosario.md`:

```
◇ Candidatos al glosario:
   - "Término visto" → ¿Forma correcta? — [archivo de origen]
```

Si hay archivos ambiguos o con conflictos que no puedes resolver, repórtalos en la sección `inbox/ (sin procesar)` de la tabla resumen con la razón.

### 8. Aprobación humana

Recuerda al usuario:
- Las estrellas con `fase: formacion` (ya en su carpeta destino) están listas para revisión
- Para aprobar: `/aprobar [nombre-archivo]` (cambia la fase y hace un commit local)

---

**Notas:**
- No proceses archivos con `fase: formacion` o superior — ya fueron procesados
- Si el `inbox/` está vacío, confirma al usuario que no hay nebulosas pendientes
- El procesamiento puede ser en lote (todos los archivos) o individual: `/nebula-process [nombre-archivo]`
