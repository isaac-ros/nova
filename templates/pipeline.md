---
type: pipeline
fase: formacion
cumulo: tu-cumulo
tags:
  - pipeline
  - etl
constellations:
  - "[[]]"
created: YYYY-MM-DD
updated: YYYY-MM-DD
author: Nombre_Apellido
owner: Nombre_Apellido
sistema_fuente: "[[]]"
sistema_destino: "[[]]"
frecuencia: diaria | semanal | mensual | event-driven | manual
---

# Nombre del Pipeline

## Propósito

¿Qué datos mueve este pipeline? ¿De dónde a dónde y para qué?

## Arquitectura

```
[Fuente] → [Staging] → [Transformación] → [Destino]
  Sistema X     tabla_staging     lógica de negocio    mart_tabla
```

## Pasos del pipeline

1. **Extracción**: de [[Sistema Fuente]] — frecuencia, ventana de datos
2. **Transformación**: qué lógica se aplica
3. **Carga**: hacia [[tabla destino]] — modo (append / overwrite / upsert)

## Dependencias

- Upstream (depende de): [[]]
- Downstream (alimenta a): [[]]

## Monitoreo

- Dónde ver el estado: 
- Alertas configuradas: 
- Tiempo de ejecución esperado: 

## Manejo de errores

- Qué pasa si falla: 
- Cómo reiniciar: 
- Dónde revisar logs: 

## Historial de incidentes

| Fecha | Incidente | Resolución |
|---|---|---|
| YYYY-MM-DD | | |
