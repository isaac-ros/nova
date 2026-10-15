<p align="center">
  <img width="180" alt="Nova logo" src="https://github.com/user-attachments/assets/c060b2f9-7e9c-4d96-85a6-ca9940400e37" />
</p>

# Nova — Knowledge Galaxy System

> A local-first knowledge management system built on Obsidian, Git, and Claude Code.

**Nova runs in local mode.** The vault lives only on your machine: no remote, no cloud sync, no external services. Git is used only to keep history on disk, and Claude Code is blocked from `push`, `pull`, `fetch`, `remote`, `clone` and `gh` through `.claude/settings.json`. See `CLAUDE.md` §14.

> **Joining a vault that's already set up?** This README covers installation and system design. For day-to-day usage, see [INSTRUCCIONES.md](INSTRUCCIONES.md) (Spanish).

## TL;DR

Your team's knowledge is scattered: 10 GitHub projects, scripts in shared folders, decisions living in one person's head, outdated documentation in wikis nobody reads. Every developer works with their own context — no visibility into others' decisions, no way to know what already exists, repeating work or contradicting what someone already solved.

**Nova is a single source of truth for your team's knowledge, designed to be consumed by LLMs.**

Architecture decisions get written down, documented queries prevent redoing what already exists, and whenever you ask Claude something, Claude responds with the actual knowledge accumulated in the vault — not generic assumptions.

The vault is markdown files on disk, versioned with a local Git repository. Claude Code acts as the librarian: it classifies, enriches, connects, and maintains structured knowledge. The MCP server (the telescope) lets Claude search the vault semantically without loading everything into context.

**The basic flow:**

1. Drop raw content into `inbox/` — a `.sql`, a `.py`, an architecture decision, meeting notes
2. Run `/nebula-process` and Claude turns it into a structured note with metadata, a summary, and links to related notes
3. Audit pending stars with `/formacion`, then approve with `/aprobar` (moves `phase: formation` → `phase: active` and makes a local commit)
4. The note lives in `stars/`, appears in the right constellations, and any team member — or Claude in any future conversation — can find it

**Got existing knowledge to migrate?** Run `/big-bang`: drop your content into `inbox/` in batches, Claude processes it in bulk under your supervision, and within a few hours your vault is populated.

Nova works **without the MCP server** from day one — Claude Code + slash commands are enough to populate and navigate the vault. The MCP (semantic search) is an enhancement added in Phase 4.

## Quick Start

1. **Clone this repository** as your vault
2. Copy `.env.example` → `.env` and configure your API keys
3. Open the folder in Obsidian
4. Edit `nova.config.yaml` with your organization's name and clusters
5. Create your seed constellations in `constellations/`
6. Start dropping knowledge into `inbox/` and run `/nebula-process`

## The Space Metaphor

| Metaphor | What it is |
| --- | --- |
| **Star** | An atomic note — a single idea, query, decision, or concept |
| **Constellation** | A map of content (MOC) that groups stars by topic or perspective |
| **System** | A functional area or team (BI, Infrastructure, RPA...) |
| **Galaxy** | The entire vault — the complete universe of knowledge |
| **Nebula** | The inbox — raw content not yet processed |
| **Gravity** | Links between stars. More connections = more gravitational mass |
| **Dark Matter** | Implicit connections not yet explicitly created |
| **Wormhole** | A high-importance cross-area link, always visible in searches |
| **Star Dust** | The frontmatter — metadata that enables search and classification |

## Navigation

**Don't start with the folders. Start with your constellation.**

Each constellation is a knowledge map from a specific perspective. Open `constellations/` and find the one that matches your area or project. From there you'll find links to all the relevant stars.

## Contributing Knowledge

### Fast route — nebula

1. Copy your query, script, idea, or document into `inbox/`
2. Run `/nebula-process` in Claude Code
3. Claude classifies, structures, and enriches the content
4. The star lands in `formation`, already in its destination folder under `stars/`
5. You review and approve with `/aprobar` — the star moves to `active` without changing folders

### Direct route — create a star

1. Copy the template from `templates/[type].md`
2. Fill in the complete frontmatter
3. Write the content
4. Save it in the correct subfolder under `stars/`

## Star Lifecycle

```
nebula → formation → active → dying → dead
                        ↑                │
                        └────────────────┘  (reactivatable)
                                remnant (if merged)
```

| Phase | Location | What it means |
| --- | --- | --- |
| `nebula` | `inbox/` | Raw content, unprocessed |
| `formation` | `stars/` | Processed by Claude, already in its destination folder, awaiting approval via `/aprobar` |
| `active` | `stars/` | Current, verified knowledge |
| `dying` | `stars/` | Deprecated — treat with caution |
| `dead` | `archive/` | Archived, ranks very low in searches |
| `remnant` | `archive/` | Merged into another star, redirects to the new one |

## Claude Code Commands

| Command | What it does |
| --- | --- |
| `/nebula-process` | Processes the inbox: classifies, enriches, normalizes terms with the glossary, and reports supernova candidates |
| `/formacion` | Read-only audit of stars in `formation`: importance, grounding signals, and quality gate before approval |
| `/aprobar` | Approves a star (`formation` → `active`) and records it with a local commit after confirmation |
| `/read-ai-sync` | Pulls new Read.ai meetings: archives the original in `archive/` and creates the `meeting` star (idempotent by `fuente_id`) |
| `/supernova` | Re-enriches an active star that has been modified |
| `/dark-matter` | Health check: detects orphans, duplicates, missing links |
| `/fusion` | Merges duplicate or partial stars into one |
| `/big-bang` | Supervised bulk migration from external sources |

## Commit Convention

Commits are local only. Claude never runs `push`, `pull`, `fetch`, or any command that contacts a remote.

```
[star] description of the star created or modified
[constellation] which constellation was updated
[fix] correction of broken links or incorrect frontmatter
[fusion] result of a star merge
[big-bang] bulk ingestion from an external source
```

## Folder Structure

```
nova-vault/
├── CLAUDE.md              # System rules for Claude Code
├── nova.config.yaml       # Vault configuration (edit on install)
├── glosario.md            # Transcription fixes and aliases (used by /nebula-process and /dark-matter)
├── .env.example           # Environment variables (copy to .env with your keys)
├── inbox/                 # Nebula — drop raw content here
├── stars/
│   ├── concepts/          # Business definitions and concepts
│   ├── decisions/         # ADRs — decisions with context and rationale
│   ├── queries/           # SQL, DAX queries
│   ├── code/              # Scripts, notebooks, functions
│   ├── endpoints/         # APIs consumed or exposed
│   ├── meetings/          # Meeting minutes and notes
│   ├── projects/          # Active initiatives and projects
│   ├── people/            # Team directory
│   ├── systems/           # System documentation
│   ├── data/              # Datasets, databases, tables, pipelines
│   ├── specs/             # Specifications and BRDs
│   ├── runbooks/          # Operational procedures
│   ├── documents/         # Reference sources: procedures, forms, diagrams, job descriptions
│   └── records/           # Changelogs and Claude conversations
├── constellations/        # Content maps — navigate from here
├── templates/             # Templates by star type
├── archive/               # Dead or remnant stars
└── mcp-server/            # Telescope — MCP server (Phase 4)
```

## Obsidian Configuration

* **Excluded files**: add `mcp-server` under Settings → Files & Links → Excluded files
* **Recommended plugins**: Dataview, Templater, Graph Analysis
* **Don't install sync plugins** (obsidian-git with a remote, Obsidian Sync, cloud clients). They would take the vault off your machine.

## Tech Stack

| Component | Tool |
| --- | --- |
| User interface | Obsidian |
| Version control | Local Git, no remote |
| Session status | `SessionStart` hook (`.claude/hooks/vault-status.sh`), read-only |
| Processing agent | Claude Code |
| System rules | CLAUDE.md |
| Reusable flows | Slash commands in `.claude/commands/` |
| Semantic search (Phase 4) | MCP server — SQLite + FTS5 + embeddings |

## Implementation Phases

* **Phase 1 — Foundation** ✅ Vault ready with structure, templates, and commands
* **Phase 2 — Claude Commands** ✅ Populate and maintain the vault without MCP
* **Phase 3 — Big Bang** ✅ Migrate existing knowledge
* **Phase 4 — The Telescope** (in progress) MCP server with hybrid search
* **Phase 5 — Expansion** Full team, multiple clusters

---

*Nova is your team's knowledge. Every star you add makes the galaxy brighter for everyone.*
