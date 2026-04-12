# /fusion

Fusiona estrellas duplicadas o parciales en una sola estrella definitiva.

## Uso

```
/fusion [[estrella-a]] [[estrella-b]] [[estrella-c]]
/fusion --cluster [nombre-cluster-detectado-por-dark-matter]
```

**Siempre requiere aprobación explícita del usuario sobre la estrella resultante antes de ejecutar.**

## Instrucciones

### 1. Análisis previo

Lee todas las estrellas a fusionar. Presenta al usuario:
- El contenido de cada estrella (o su `summary` si son largas)
- Por qué se sugiere la fusión (similitud detectada, tags compartidos, etc.)
- Una propuesta de la estrella resultante

Pregunta: **"¿Procedemos con la fusión? ¿Deseas modificar algo de la estrella resultante?"**

**NO ejecutes ningún cambio hasta recibir aprobación.**

### 2. Construcción de la estrella fusionada

Una vez aprobado, construye la estrella resultante:

- **Tipo**: el mismo que las originales (o el más específico si difieren)
- **Título**: el más claro y descriptivo de los candidatos (el usuario puede modificarlo)
- **Contenido**: integración de lo mejor de cada estrella — sin duplicar, sin contradicciones
  - Si hay contradicciones: elige la versión más reciente (`updated` más reciente) y documenta la discrepancia en las notas
- **Frontmatter**:
  - `fase: activa`
  - `tags`: unión de todos los tags
  - `constellations`: unión de todas las constelaciones
  - `dependencies`: unión de todas las dependencias
  - `created`: la fecha más antigua de las originales
  - `updated`: fecha actual
  - `author`: `author` de la estrella más reciente (o la más completa)
  - `owner`: el `owner` con mayor frecuencia entre las originales
  - `summary`: regenerado para la estrella fusionada (si es tipo técnico)

### 3. Actualizar las estrellas originales

Para cada estrella original:
1. Cambiar `fase: remanente`
2. Agregar al inicio del contenido:
   ```
   > ⚠️ Esta estrella fue fusionada. Ver: [[Estrella Fusionada]]
   ```
3. Agregar campo al frontmatter:
   ```yaml
   fusionada_en: "[[Estrella Fusionada]]"
   fecha_fusion: YYYY-MM-DD
   ```
4. Mover el archivo a `archive/`

### 4. Actualizar referencias

Busca en todo el vault referencias a las estrellas originales:
- Wikilinks `[[nombre-original]]` en otros archivos
- Entradas en `dependencies` de otras estrellas
- Entradas en constelaciones

Actualiza cada referencia para apuntar a la nueva estrella fusionada.

Reporta al usuario cuántas referencias se actualizaron.

### 5. Actualizar constelaciones

Para cada constelación que tenía las estrellas originales:
- Elimina los links a las originales
- Agrega el link a la fusionada (en la misma sección)

### 6. Reporte final

```
✦ Fusión Estelar completada

Estrella resultante: [[nombre-fusionada]]
Estrellas absorbidas: [[a]] (remanente), [[b]] (remanente), [[c]] (remanente)
Referencias actualizadas: X archivos
Constelaciones actualizadas: [[cons-1]], [[cons-2]]

Acción pendiente: Revisar [[nombre-fusionada]] y confirmar que el contenido es correcto.
Git commit sugerido: [fusion] merge [[a]] + [[b]] + [[c]] → [[nombre-fusionada]]
```

---

**Reglas:**
- Sin aprobación del usuario → sin ejecución. Siempre mostrar la estrella resultante antes de fusionar.
- Las estrellas originales **nunca se eliminan** — quedan como `remanente` en `archive/`.
- Si el usuario rechaza la propuesta, pregunta qué cambiar y vuelve a proponer.
- Máximo 5 estrellas por fusión. Si hay más, sugerir fusiones en dos pasos.
