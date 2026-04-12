---
type: table
fase: activa
cumulo: tu-cumulo
tags:
  - tabla
constellations:
  - "[[]]"
created: YYYY-MM-DD
updated: YYYY-MM-DD
author: Nombre_Apellido
owner: Nombre_Apellido
database: "[[]]"
schema: dbo | staging | mart
---

# nombre_tabla

> Una línea: qué contiene esta tabla y en qué contexto.

## Columnas

| Columna | Tipo | Nulable | Descripción |
|---|---|---|---|
| `id` | INT | No | Clave primaria |
| `fecha_registro` | DATE | No | |
| `descripcion` | VARCHAR(500) | Sí | |

## Claves

- **PK**: `id`
- **FK**: `fk_columna` → `[[otra_tabla]].id`
- **Índices**: `idx_fecha` sobre `fecha_registro`

## Volumen y frecuencia

- Registros aprox: 
- Crecimiento: registros/día o mes
- Fecha del dato más antiguo: 

## Queries que la usan

- [[nombre-query]] — para qué la usa

## Notas técnicas

- Particionado: 
- Issues conocidos de calidad:
