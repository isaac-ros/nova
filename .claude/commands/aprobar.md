# /aprobar

Pasa una estrella de `fase: formacion` a `fase: activa` y la versiona en el historial local (commit con confirmación).

Es el verbo diario de cierre del ciclo. El usuario no necesita tocar git a mano.

**El vault es local.** Este comando nunca hace `push`, `pull` ni `fetch`. Nada sale de la máquina (CLAUDE.md §14).

## Uso

```
/aprobar                  # interactivo: lista todas las estrellas en formacion y el usuario elige
/aprobar [nombre|path]    # aprueba una estrella específica
/aprobar todas            # aprueba todas las que estén en formacion
```

## Instrucciones

### 1. Descubrir estrellas en formación

Busca en `stars/` (todas las subcarpetas) los archivos con `fase: formacion`.

No busques en `inbox/`: bajo el modelo actual (CLAUDE.md §2) las estrellas en formación ya viven en su carpeta destino.

Si se pasó un nombre o path, filtra a esa estrella. Si no hay ninguna, informa "No hay estrellas en formación pendientes" y detente.

### 2. Presentar para revisión

Muestra una tabla con: nombre, tipo, carpeta, resumen corto (`summary` o la definición del blockquote inicial), días en formación, `updated`.

Marca como stale las que superen `STALE_DRAFT_DAYS` de `health_thresholds` en `nova.config.yaml`.

Si la invocación fue sin argumento, pregunta cuáles aprobar: todas, una lista específica, o cancelar.

### 3. Gate de calidad (antes de activar cada estrella)

Una estrella `activa` es fuente de verdad, así que valida lo mínimo antes de promoverla:

- **Frontmatter obligatorio completo**: `type`, `fase`, `tags`, `cumulo`, `created`, `updated`, `author`, `owner`.
- **`author` / `owner`**: si están en `por_asignar`, adviértelo. No bloquea la aprobación.
- **Constelación**: al menos una entrada en `constellations`, o el tag `sin-constelacion` (CLAUDE.md §5.2).
- **Wikilinks del cuerpo**: que resuelvan a un archivo existente. Reporta los rotos.

Si algo falla, repórtalo y pregunta: aprobar de todas formas, o corregir primero. Nunca auto-corrijas contenido sustantivo sin permiso.

### 4. Aplicar la transición

Para cada estrella aprobada:
- `fase: formacion` → `fase: activa`
- `updated`: fecha actual
- No muevas archivos. Ya están en su carpeta destino.

### 5. Versionar en local (commit con confirmación)

- `git add` SOLO de los archivos aprobados, más los archivos de constelación que hayan cambiado en este mismo flujo, más la carpeta original que indique `fuente_archivo` si la estrella lo tiene (reuniones traídas por `/read-ai-sync`). Nunca `git add -A`: eso barrería `.obsidian/`, `.claude/worktrees/`, borrados y otro ruido no relacionado.
- Mensaje de commit según la convención de CLAUDE.md §13: `[star] aprobar: <nombres o "N estrellas">`.
- Muestra al usuario exactamente qué archivos se van a commitear. Pide confirmación explícita.
- Al confirmar: `git commit`. Ahí termina. No hay push — el commit se queda en el historial local.

### 6. Cerrar el ciclo hacia arriba (gravedad bidireccional)

Aplica el principio §1.8 y la regla §5.6 de CLAUDE.md.

Para las estrellas recién activadas, evalúa si alguna deja stale a otra estrella `activa` (agrega hechos, contradice un estado, documenta una integración nueva). Reporta candidatos a `/supernova`.

**Regla por defecto:** reportar, no editar.

### 7. Reporte final

```
✦ Aprobadas: N estrellas → activa
   - [[estrella-1]] (tipo)
   - [[estrella-2]] (tipo)
   Commit local: <hash corto> "[star] aprobar: ..."
   Candidatos a supernova (hacia arriba): [[destino]] — razón   (o: ninguno)
   Advertencias: [author/owner en por_asignar: X · wikilinks rotos: Y]
```

---

**Reglas:**
- El usuario aprueba. Claude nunca auto-aprueba.
- `/aprobar` solo toca estrellas en `formacion`. El backlog de estrellas ya `activa` pero sin commitear se resuelve pidiéndole a Claude que lo versione — mismo criterio: lista exacta de archivos y confirmación antes de commitear.
- Nunca `push`, `pull`, `fetch` ni ningún comando que contacte un remoto. El vault no se publica en ningún servicio externo.
