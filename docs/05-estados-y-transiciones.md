# Estados y transiciones propuestos

Fecha: 14 de octubre de 2026  
Estado: propuesta. No hay tabla de pedidos ni máquina de estados en el código. Debe validarse antes del Sprint 3.

## Pedido

| Estado | Significado | Quién puede entrar |
| --- | --- | --- |
| `draft` | En edición | Operador o administrador |
| `submitted` | Confirmado por quien lo registra | Sistema, al confirmar |
| `confirmed` | Aceptado para procesarse | Operador o administrador |
| `preparing` | En preparación | Operador |
| `ready_for_pickup` | Listo para atención presencial | Operador |
| `ready_for_dispatch` | Listo para asignar reparto | Operador |
| `assigned` | Tiene transportista y no salió | Usuario que asigna |
| `in_delivery` | Reparto iniciado | Transportista asignado |
| `delivered` | Entrega registrada | Transportista asignado |
| `completed` | Cerrado | Sistema, al completar la modalidad |
| `cancelled` | Cancelado con motivo | Según política pendiente |
| `delivery_failed` | Intento no completado | Transportista asignado |

## Transiciones previstas

- Presencial: `draft -> submitted -> confirmed -> preparing -> ready_for_pickup -> completed`.
- Domicilio: `draft -> submitted -> confirmed -> preparing -> ready_for_dispatch -> assigned -> in_delivery -> delivered -> completed`.
- `delivery_failed` exige un motivo. El siguiente paso, reintento, reasignación, devolución o cancelación, está pendiente.
- `completed` y `cancelled` no se reabren en el flujo normal.
- El presencial no pasa por `assigned` ni `in_delivery`.
- El domicilio no pasa a `ready_for_pickup`.

La entrega se modelará aparte del pedido cuando se implemente la asignación, para conservar reintentos y reasignaciones. Esa tabla todavía no existe.

## Reglas pendientes

- Si `delivered` y `completed` serán estados distintos en la operación real.
- Quién cancela y desde qué estados.
- Si se permiten faltantes o sustituciones.
- Cómo se resuelve un cambio concurrente.
- Si un transportista puede rechazar la asignación.
