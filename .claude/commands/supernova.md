# /supernova

Re-enriquece una estrella `activa` que fue modificada significativamente.

## Uso

```
/supernova [path o título de la estrella]
```

Si no se especifica una estrella, busca en `stars/` estrellas `activa` que tengan el campo `updated` más reciente que la fecha de su último re-enriquecimiento (inferido del historial).

## Instrucciones

### 1. Verificación

Lee la estrella indicada. Confirma que:
- `fase: activa` (si está en otro estado, informa al usuario y detente)
- Es un tipo que se enriquece con LLM: `query`, `code`, `endpoint`

Si el tipo no se enriquece con LLM (ej: `meeting`, `concept`), informa al usuario y ofrece solo actualizar los links.

### 2. Determinar si el cambio es significativo

Un cambio es **significativo** si:
- La lógica central del query/código cambió (no solo comentarios o formato)
- Se agregaron o eliminaron tablas/dependencias
- El propósito del script cambió

Un cambio es **menor** si:
- Solo se corrigieron typos o se mejoró documentación
- Se actualizó un link o tag

Si el cambio es menor: actualiza `updated` en el frontmatter y confirma al usuario. No cambies `fase`.

### 3. Re-enriquecimiento (cambios significativos)

Re-ejecuta el análisis:
- Extrae tablas, dependencias, imports actualizados
- Genera nuevo `summary` con exactamente 2 oraciones
- Compara con el `summary` anterior — informa al usuario qué cambió

Actualiza el frontmatter:
- `summary`: nuevo valor
- `tablas` / `dependencies`: actualizado
- `updated`: fecha actual
- `fase`: cambia de `activa` → `formacion`

### 4. Verificar links

Revisa si los nuevos `dependencies` en el frontmatter tienen estrellas existentes en el vault. Si hay dependencias referenciadas que no tienen estrella:
- Indica cuáles faltan
- Pregunta al usuario si quiere crear las estrellas faltantes

### 5. Manejo de conflictos

Si detectas situaciones que no puedes resolver automáticamente:
- Dependencias ambiguas (una referencia que puede ser varias cosas)
- Cambios que afectan a múltiples estrellas conectadas
- El nuevo contenido contradice otra estrella `activa`

En estos casos: NO muevas el archivo al inbox. Deja el archivo donde está con `fase: formacion` y describe el conflicto al usuario para resolución manual.

### 6. Reporte

```
✦ Supernova: [nombre-estrella.md]
   Fase: activa → formacion (pendiente de re-aprobación)
   Summary anterior: "[anterior]"
   Summary nuevo:    "[nuevo]"
   Dependencias actualizadas: +[[nueva]], -[[eliminada]]
   Conflictos: ninguno / [descripción si hay]
   Acción: Revisar cambios y cambiar fase → activa cuando esté conforme
```

---

**Notas:**
- La fase regresa a `formacion` automáticamente. El usuario aprueba explícitamente.
- No hay supernova automática — siempre es invocado explícitamente por el usuario o como parte de otro comando.
- Para re-aprobar: cambiar `fase: formacion` → `fase: activa` en el frontmatter.
