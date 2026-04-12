<p align="center">
  <img width="180" alt="Nova logo" src="https://github.com/user-attachments/assets/c060b2f9-7e9c-4d96-85a6-ca9940400e37" />
</p>

# Nova — Knowledge Galaxy System

> Sistema de gestión de conocimiento colaborativo construido sobre Obsidian, Git y Claude Code.

## TL;DR

Tu equipo tiene conocimiento disperso: 10 proyectos de github, scripts en carpetas compartidas, decisiones en la cabeza de una sola persona, documentación desactualizada en wikis que nadie lee. Cada desarrollador trabaja con su propio contexto — sin visibilidad de las decisiones del resto, sin saber qué ya existe, repitiendo trabajo o contradiciendo lo que alguien ya resolvió.

**Nova es una fuente única de verdad para el conocimiento del equipo, diseñada para ser consumida por LLMs.**

Tres desarrolladores trabajando en el mismo repo comparten el mismo vault: las decisiones de arquitectura de uno son contexto para los otros dos, los queries documentados evitan que alguien rehaga lo que ya existe, y cuando cualquiera le pregunta algo a Claude, Claude responde con el conocimiento real del equipo — no con suposiciones genéricas.

El vault vive en Git como archivos markdown. Claude Code actúa como el bibliotecario: clasifica, enriquece, conecta y mantiene el conocimiento estructurado. El MCP server (el telescopio) permite que Claude busque en el vault semánticamente sin cargar todo al contexto.

**El flujo básico:**
1. Depositas contenido crudo en `inbox/` — un `.sql`, un `.py`, una decisión de arquitectura, una minuta
2. Ejecutas `/nebula-process` y Claude lo convierte en una nota estructurada con metadata, summary y links a notas relacionadas
3. Revisas y apruebas cambiando `fase: formacion` → `fase: activa`
4. La nota vive en `stars/`, aparece en las constelaciones correctas, y cualquier miembro del equipo — o Claude en cualquier conversación futura — puede encontrarla

**¿Tienes conocimiento existente que migrar?** Ejecuta `/big-bang`: deposita tu contenido en `inbox/` en lotes, Claude lo procesa en masa con tu supervisión, y en unas horas tienes el vault poblado.

Nova funciona **sin el MCP server** desde el día uno — Claude Code + los slash commands son suficientes para poblar y navegar el vault. El MCP (búsqueda semántica) es una mejora que se agrega en Fase 4.

## Inicio rápido

1. **Clona este repositorio** como tu vault
2. Copia `.env.example` → `.env` y configura tus API keys
3. Abre la carpeta en Obsidian
4. Edita `nova.config.yaml` con el nombre de tu organización y tus cúmulos
5. Crea tus constelaciones semilla en `constellations/`
6. Empieza a depositar conocimiento en `inbox/` y ejecuta `/nebula-process`

## La metáfora espacial

| Metáfora | Qué es |
|---|---|
| **Estrella** | Una nota atómica — una sola idea, query, decisión o concepto |
| **Constelación** | Un mapa de contenido (MOC) que agrupa estrellas por tema o perspectiva |
| **Sistema** | Un área funcional o equipo (BI, Infraestructura, RPA...) |
| **Galaxia** | Todo el vault — el universo completo del conocimiento |
| **Nebulosa** | El inbox — contenido crudo aún sin procesar |
| **Gravedad** | Los links entre estrellas. Más conexiones = más masa gravitacional |
| **Materia Oscura** | Conexiones implícitas que aún no se han creado explícitamente |
| **Agujero de Gusano** | Link cross-área de alta importancia, siempre visible en búsquedas |
| **Polvo Estelar** | El frontmatter — metadata que permite buscar y clasificar |

## Navegación

**No empieces por las carpetas. Empieza por tu constelación.**

Cada constelación es un mapa del conocimiento desde una perspectiva específica. Abre `constellations/` y busca la que corresponde a tu área o proyecto. Desde ahí encontrarás links a todas las estrellas relevantes.

## Contribuir conocimiento

### Ruta rápida — nebulosa
1. Copia tu query, script, idea o documento en `inbox/`
2. Ejecuta `/nebula-process` en Claude Code
3. Claude clasifica, estructura y enriquece el contenido
4. Tú revisas y apruebas — la estrella pasa a `activa` y se mueve a `stars/`

### Ruta directa — crear estrella
1. Copia el template desde `templates/[tipo].md`
2. Llena el frontmatter completo
3. Escribe el contenido
4. Guarda en la subcarpeta correcta de `stars/`

## Lifecycle de una estrella

```
nebula → formacion → activa → muriendo → muerta
                        ↑                   │
                        └───────────────────┘  (reactivable)
                                  remanente (si fue fusionada)
```

| Fase | Ubicación | Qué significa |
|---|---|---|
| `nebula` | `inbox/` | Contenido crudo, sin procesar |
| `formacion` | `inbox/` | Procesado por Claude, esperando aprobación |
| `activa` | `stars/` | Conocimiento vigente y verificado |
| `muriendo` | `stars/` | Deprecado — tratar con cautela |
| `muerta` | `archive/` | Archivado, rankea muy bajo en búsquedas |
| `remanente` | `archive/` | Fusionada en otra estrella, redirige a la nueva |

## Comandos de Claude Code

| Comando | Qué hace |
|---|---|
| `/nebula-process` | Procesa el inbox: clasifica, enriquece y estructura estrellas |
| `/supernova` | Re-enriquece una estrella activa que fue modificada |
| `/dark-matter` | Health check: detecta huérfanas, duplicados, links faltantes |
| `/fusion` | Fusiona estrellas duplicadas o parciales en una sola |
| `/big-bang` | Migración masiva supervisada desde fuentes externas |

## Convención de commits

```
[star] descripción de la estrella creada o modificada
[constellation] qué constelación se actualizó
[fix] corrección de links rotos o frontmatter incorrecto
[fusion] resultado de fusión de estrellas
[big-bang] ingesta masiva desde fuente externa
```

## Estructura de carpetas

```
nova-vault/
├── CLAUDE.md              # Reglas del sistema para Claude Code
├── nova.config.yaml       # Configuración del vault (editar al instalar)
├── .env.example           # Variables de entorno (copiar a .env con tus keys)
├── inbox/                 # Nebulosa — deposita aquí contenido crudo
├── stars/
│   ├── conceptos/         # Definiciones y conceptos de negocio
│   ├── decisiones/        # ADRs — decisiones con contexto y razones
│   ├── consultas/         # Queries SQL, DAX
│   ├── codigo/            # Scripts, notebooks, funciones
│   ├── endpoints/         # APIs consumidas o expuestas
│   ├── reuniones/         # Minutas y notas de reunión
│   ├── proyectos/         # Iniciativas y proyectos activos
│   ├── personas/          # Directorio del equipo
│   ├── sistemas/          # Documentación de sistemas
│   ├── datos/             # Datasets, bases de datos, tablas, pipelines
│   ├── specs/             # Especificaciones y BRDs
│   ├── runbooks/          # Procedimientos operativos
│   └── registros/         # Changelogs y conversaciones con Claude
├── constellations/        # Mapas de contenido — navega desde aquí
├── templates/             # Templates por tipo de estrella
├── archive/               # Estrellas muertas o remanentes
└── mcp-server/            # Telescopio — MCP server (Fase 4)
```

## Configuración de Obsidian

- **Excluded files**: agregar `mcp-server` en Settings → Files & Links → Excluded files
- **Plugins recomendados**: Dataview, Templater, obsidian-git, Graph Analysis

## Stack técnico

| Componente | Herramienta |
|---|---|
| Interfaz de usuario | Obsidian |
| Versionado | Git + GitHub |
| Agente de procesamiento | Claude Code |
| Reglas del sistema | CLAUDE.md |
| Flujos reutilizables | Slash commands en `.claude/commands/` |
| Búsqueda semántica (Fase 4) | MCP server — SQLite + FTS5 + embeddings |

## Fases de implementación

- **Fase 1 — Fundación** ✅ Vault listo con estructura, templates y comandos
- **Fase 2 — Claude Commands** ✅ Poblar y mantener el vault sin MCP
- **Fase 3 — Big Bang** ✅ Migrar conocimiento existente
- **Fase 4 — El Telescopio** MCP server con búsqueda híbrida
- **Fase 5 — Expansión** Equipo completo, múltiples cúmulos

---

*Nova es el conocimiento del equipo. Cada estrella que agregas hace la galaxia más brillante para todos.*
