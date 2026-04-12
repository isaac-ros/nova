# /big-bang

Migración masiva supervisada desde fuentes externas al vault Nova.

## Uso

```
/big-bang [carpeta-con-contenido-crudo]
/big-bang --tipo queries --fuente gitlab
/big-bang --revisar    # revisar lote procesado sin mover a activa
```

**Siempre supervisado. No corre desatendido. El autor revisa lote por lote.**

## Instrucciones

### Fase 1: Inventario

Antes de procesar nada, presenta al usuario un inventario de lo que hay en la carpeta fuente:

```
Inventario de [carpeta]:
- X archivos .sql → type: query
- Y archivos .py → type: code
- Z archivos .md → tipo a inferir
- W archivos .xlsx → type: dataset o concept
- V archivos .pdf → tipo a inferir

Total: N archivos
Tiempo estimado de procesamiento: [N × tiempo por archivo]

¿Procesamos todo el lote o quieres seleccionar tipos específicos?
```

Espera confirmación del usuario.

### Fase 2: Depósito en inbox

Para cada archivo confirmado:
1. Copia el archivo a `inbox/` con un nombre descriptivo en `kebab-case`
2. Agrega metadata mínimo como comentario o frontmatter básico:
   ```yaml
   ---
   fase: nebula
   source: [ruta o descripción del origen]
   tipo_probable: [inferido por extensión]
   big_bang_batch: [fecha]
   ---
   ```

### Fase 3: Procesamiento por lotes

Ejecuta `/nebula-process` en el lote depositado.

Procesa en grupos de 10-15 archivos para que el usuario pueda revisar sin abrumarse.

Después de cada lote, presenta el reporte de procesamiento y pregunta:
- "¿Continuamos con el siguiente lote?"
- "¿Quieres ajustar algún archivo antes de continuar?"

### Fase 4: Revisión y aprobación

Presenta un dashboard de lo procesado:

```
# Big Bang — Reporte de lote YYYY-MM-DD

## Procesados exitosamente (X)
| Archivo original | Estrella creada | Tipo | Constelación |
|---|---|---|---|
| ventas_q1.sql | [[query-ventas-trimestral]] | query | Mi_Constelacion |

## Requieren revisión (Y)
| Archivo | Problema | Acción sugerida |
|---|---|---|
| archivo.xlsx | No claro si es dataset o concept | Revisar manualmente |

## Descartados (Z)
| Archivo | Razón |
|---|---|
| test.sql | Archivo de prueba, sin valor de conocimiento |

---
Acción: Revisa los archivos en inbox/ con fase: formacion.
Para aprobar en bulk: /big-bang aprobar-lote
Para aprobar individual: cambiar fase en el frontmatter del archivo.
```

### Fase 5: Aprobación en bulk

Cuando el usuario ejecuta `/big-bang aprobar-lote`:

1. Lista todas las estrellas en `inbox/` con `fase: formacion` del batch actual
2. Muestra un resumen rápido de cada una (título + summary)
3. Pregunta: "¿Aprobamos todas o quieres revisar algunas individualmente?"
4. Si aprueba todas: cambia `fase: formacion → activa` y mueve cada archivo a su carpeta correcta según `nova.config.yaml`
5. Actualiza las constelaciones correspondientes

### Fase 6: Reporte final

```
# Big Bang completado — YYYY-MM-DD

## Resultado
- Estrellas creadas: X
- Estrellas en revisión: Y (en inbox/ con fase: formacion)
- Archivos descartados: Z

## Nuevas estrellas por constelación
- [[Constelacion_A]]: +X estrellas
- [[Constelacion_B]]: +Y estrellas

## Próximos pasos sugeridos
1. Ejecutar /dark-matter para detectar conexiones faltantes entre las nuevas estrellas
2. Revisar las X estrellas pendientes de aprobación en inbox/
3. Git commit: [big-bang] ingesta [fuente] — X estrellas creadas
```

---

**Reglas:**
- El Big Bang nunca corre desatendido. Cada lote requiere confirmación.
- Los archivos originales en la fuente NO se eliminan — son la copia de seguridad.
- Si un archivo ya existe en el vault (mismo nombre o contenido idéntico), reportarlo como posible duplicado antes de procesar. No crear duplicados silenciosamente.
- Máximo recomendado por sesión de Big Bang: 50-100 archivos. Para volúmenes mayores, dividir en sesiones.
- Contenido sensible: se acepta en el vault sin filtrado.
