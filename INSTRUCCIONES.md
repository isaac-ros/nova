# Instrucciones de uso — Nova

Nova es el vault de conocimiento del equipo, editado a través de Claude Code. Todo el contenido son archivos de texto (`.md`), organizados en carpetas, con links entre sí. Este documento explica cómo usarlo sin necesidad de saber de git ni de markdown.

## Antes de empezar

- Necesitas Claude Code instalado y abierto en la carpeta del vault.
- No hace falta memorizar comandos: basta con escribir en lenguaje normal lo que quieres hacer, y Claude decide qué comando o acción usar.
- Cada vez que abres una sesión nueva, Claude revisa si hay cambios del equipo en el remoto y te avisa si tu copia está desactualizada.
- Los comandos abajo se escriben empezando con `/` directamente en el chat.

## El ciclo de una idea dentro de Nova

Una nota nueva pasa por tres momentos:

1. **Llega cruda.** Pegas un texto, subes un archivo, o le cuentas a Claude algo que pasó en una reunión.
2. **Claude la procesa.** La convierte en una nota estructurada (una "estrella"), le pone título, tipo, resumen y la conecta con notas relacionadas. Queda marcada como pendiente de revisión.
3. **Tú la apruebas.** Lees la nota, confirmas que está bien, y Claude la publica: la marca como vigente y la sube a GitHub para que el resto del equipo la vea.

El paso 3 es el único que requiere tu decisión. Los pasos 1 y 2 los hace Claude.

## Comandos principales

### `/nebula-process` — procesar contenido nuevo

Úsalo cuando tengas material sin organizar: notas de una junta, un correo largo, un archivo Excel, un PDF. Claude lo lee, decide de qué tipo de nota se trata, y construye el archivo correspondiente. Al terminar te muestra un resumen de todo lo que creó y dónde quedó.

### `/aprobar` — publicar una nota

Es el comando del día a día. Pasa una nota de "pendiente de revisión" a "vigente" y la sube a GitHub.

```
/aprobar                  # te muestra todas las pendientes y eliges
/aprobar nombre-de-la-nota
/aprobar todas
```

Antes de publicar, Claude te muestra exactamente qué se va a subir y pide tu confirmación. Nunca sube nada sin que lo apruebes explícitamente.

### `/sync` — poner al día tu copia y la del equipo

Trae los cambios que otros hicieron en GitHub y, si tú tienes notas ya aprobadas pero sin subir, te ofrece publicarlas. Úsalo si el aviso al abrir la sesión te dice que hay cambios pendientes en ambos lados.

### `/dark-matter` — revisión de salud del vault

Un chequeo general: notas sin conexión con nada más, notas que llevan mucho tiempo esperando aprobación, posibles duplicados, temas relacionados que no están conectados. Es de solo lectura, no cambia nada por su cuenta, solo te avisa y te sugiere qué hacer.

### `/fusion` — unir notas duplicadas

Cuando dos o más notas hablan de lo mismo, este comando arma una sola versión combinada y te la muestra antes de aplicar nada. Las notas originales no se borran, quedan archivadas con un aviso de que fueron fusionadas.

### `/big-bang` — carga masiva

Para migrar de golpe una carpeta grande de archivos externos al vault. Claude hace un inventario primero, y procesa en lotes pequeños para que puedas revisar sobre la marcha. No corre solo, cada lote espera tu confirmación.

### `/supernova` — actualizar una nota que ya cambió

Si una nota vigente recibe información nueva que la deja desactualizada (un dato cambió, un sistema pasó de "en desarrollo" a "en producción"), este comando la vuelve a poner en revisión con el contenido corregido, y luego pasa otra vez por `/aprobar`.

## Preguntas frecuentes

**¿Tengo que aprender git?**
No. Todo el manejo de versiones (guardar cambios, subirlos, traer los del equipo) pasa por `/aprobar` y `/sync`.

**¿Puedo simplemente contarle algo a Claude sin usar un comando?**
Sí. Describe lo que pasó o pega el contenido, y Claude identifica si conviene procesarlo como nota nueva.

**¿Qué pasa si apruebo algo por error?**
Nada se pierde. Todo queda en el historial de cambios y se puede corregir o revertir.

**¿Quién ve lo que subo?**
Todo lo que se publica con `/aprobar` o `/sync` queda visible para el resto del equipo en el repositorio compartido.
