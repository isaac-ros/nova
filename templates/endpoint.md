---
type: endpoint
fase: formacion
cumulo: tu-cumulo
tags:
  - api
constellations:
  - "[[]]"
created: YYYY-MM-DD
updated: YYYY-MM-DD
author: Nombre_Apellido
owner: Nombre_Apellido
method: GET | POST | PUT | DELETE | PATCH
url: /api/v1/recurso
servicio: nombre_del_servicio
dependencies:
  - "[[]]"
summary: ""
---

# Nombre del Endpoint

## Resumen

| Campo | Valor |
|---|---|
| Método | `GET` |
| URL | `/api/v1/recurso` |
| Servicio | nombre_del_servicio |
| Auth | Bearer token / API key / Ninguna |
| Ambiente | Producción / Staging |

## Request

### Headers
```
Content-Type: application/json
Authorization: Bearer {{token}}
```

### Body / Parámetros
```json
{
  "param1": "valor",
  "param2": 123
}
```

## Response

### 200 OK
```json
{
  "data": [],
  "total": 0
}
```

### Errores comunes
| Código | Causa | Solución |
|---|---|---|
| 400 | Parámetro inválido | Revisar formato |
| 401 | Token expirado | Renovar token |
| 404 | Recurso no encontrado | Verificar ID |

## Ejemplo de uso

```python
import requests

response = requests.get(
    "https://api.servicio.com/v1/recurso",
    headers={"Authorization": "Bearer token"}
)
```

## Notas

- Rate limits: 
- Ambientes disponibles: 
- Contacto del equipo owner: [[]]
