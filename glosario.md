---
tags:
  - glosario
updated: YYYY-MM-DD
owner: Nombre_Apellido
---

# Glosario de términos

Referencia para corregir nombres que la transcripción automática de reuniones escribe mal. `/nebula-process` y `/read-ai-sync` lo leen antes de escribir una estrella; `/dark-matter` lo usa para reportar errores que quedaron en el vault.

## Cómo se usa

- **Errores:** formas incorrectas que ya aparecieron en el vault. Se reemplazan por la forma correcta.
- **Alias:** formas válidas con las que la gente se refiere a alguien o algo (apodos, nombres cortos). No se reemplazan en el texto; solo sirven para saber a qué estrella enlazar.
- **Regla `auto`:** el error se corrige siempre.
- **Regla `contextual`:** el error también es una palabra o nombre real. Solo se corrige si el contexto lo confirma; si hay duda, se deja como está y se reporta.
- **Archivos:** cuántos archivos del vault contenían algún error de esa fila al agregarla. Sirve como evidencia de que el error existe.
- **Solo se aplican las secciones confirmadas.** Lo que está en "Por confirmar" y "Sin resolver" no se corrige.
- **Alcance:** se corrigen `stars/` y `constellations/`. Las transcripciones crudas de `archive/` no se tocan; son el registro original.
- **Auditoría:** cada reunión corregida lleva al final una línea `> Correcciones de transcripción (glosario): ...` con lo que cambió.

Para agregar un término: el procesamiento reporta palabras sospechosas como candidatas, el owner las confirma y se agregan a la tabla que corresponda.

## Sistemas y plataformas

| Correcto | Estrella | Errores (se corrigen) | Alias (se respetan) | Regla | Archivos | Contexto |
|---|---|---|---|---|---|---|
| Power BI | | Empower BI | | `auto` | 1 | Ejemplo: borra esta fila al llenar el glosario. |

## Personas

| Correcto | Estrella | Errores (se corrigen) | Alias (se respetan) | Regla | Archivos | Contexto |
|---|---|---|---|---|---|---|

## Empresas y clientes

| Correcto | Estrella | Errores (se corrigen) | Alias (se respetan) | Regla | Archivos | Contexto |
|---|---|---|---|---|---|---|

## Siglas y términos de negocio

| Correcto | Estrella | Errores (se corrigen) | Alias (se respetan) | Regla | Archivos | Contexto |
|---|---|---|---|---|---|---|

## Por confirmar

Propuestas con evidencia en el vault que todavía no se validan. No se aplican.

Sin pendientes por ahora.

## Sin resolver

Términos que parecen errores de transcripción pero cuya forma correcta se desconoce. Se dejan tal cual en las estrellas.

Sin pendientes por ahora.

## Personas distintas con nombres parecidos

Lista de nombres que se prestan a confusión, para no enlazar a la persona equivocada. Formato:

- **Nombre:** [[persona-a]] (área) y [[persona-b]] (área) son personas distintas.
