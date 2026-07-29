# /sync

Sincroniza el vault con el remoto: pull seguro si hay commits nuevos, y publica el backlog local (estrellas ya `activa` pero sin versionar, o cambios sin commitear).

Complementa el hook `SessionStart` (`.claude/hooks/vault-sync.sh`), que solo cubre el pull automático al iniciar sesión. `/sync` es el camino explícito de push.

## Uso

```
/sync            # pull si hay remoto nuevo, luego ofrece commitear y empujar el backlog local
/sync --push     # va directo a revisar y publicar cambios locales sin commitear
```

## Instrucciones

### 1. Pull seguro

`git fetch` y aplica la misma lógica del hook:
- Si el remoto tiene commits nuevos y el árbol está limpio: `git pull --ff-only`.
- Si el remoto tiene commits nuevos y el árbol está sucio: avisa y detente antes de pull (no fuerces merge).
- Si `--push` fue pasado, salta directo al paso 2.

### 2. Inventario del backlog local

Lista el trabajo local sin publicar, agrupado:
- **Nuevas sin trackear** (`??`): dentro de `stars/`, `constellations/`, `inbox/`, `archive/`.
- **Modificadas sin commitear** (`M`).
- **Borrados** (`D`).

Ignora ruido de tooling: `.claude/worktrees/`, archivos temporales, `.obsidian/`.

### 3. Advertencias fuera del pipeline

Señala archivos sueltos fuera del pipeline esperado (raíz del repo, material crudo en `archive/`) para que el usuario decida si entran al vault vía `inbox/` o se descartan. No los mezcles automáticamente en el commit propuesto.

### 4. Proponer commit

Propón un `git add` selectivo — solo contenido de vault relevante, nunca `git add -A` a ciegas — y un mensaje de commit según la convención de CLAUDE.md §13. Muestra la lista exacta de archivos y pide confirmación explícita.

### 5. Publicar

Al confirmar: `git commit` y luego `git push`. Reporta el resultado.

```
✓ Sync completado
   Pull: N commits nuevos   (o: nada nuevo)
   Commit: <hash corto> "..."
   Push: ✓ origin/main   (o: ✗ remoto adelantado, reintenta /sync)
   Fuera del pipeline (sin tocar): [archivo1, archivo2]   (o: ninguno)
```

---

**Regla:** `/sync` nunca hace `git add -A` a ciegas. Siempre muestra la lista de archivos y confirma antes de commitear o empujar.
