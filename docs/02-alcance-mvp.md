# Alcance del MVP

Fecha: 14 de octubre de 2026  
Estado: propuesta para validar. Las exclusiones de esta lista no deben implementarse sin aprobación.

## Decisiones usadas para construir

| Pregunta | Decisión de trabajo | Estado |
| --- | --- | --- |
| ¿Quién registra el pedido? | El operador | Supuesto, alineado con el MVP recomendado del contexto |
| ¿El cliente compra desde su teléfono? | No en el MVP | Excluido hasta aprobación |
| ¿Cuántas tiendas? | Una | Pendiente de confirmar |
| ¿La atención presencial incluye caja? | No. Solo el pedido | Pendiente de confirmar |
| ¿Hay pago digital, inventario o comprobante? | No | Excluido |

## Clasificación

### P0, necesario para el flujo operativo

- Autenticación y cierre de sesión.
- Rol asignado por un administrador, nunca elegido por el usuario.
- Registro de pedido presencial o a domicilio por el operador.
- Datos mínimos del cliente y dirección cuando el pedido es a domicilio.
- Cálculo del total en el servidor, conservando el precio aplicado.
- Preparación y transiciones de estado válidas.
- Asignación manual de un transportista habilitado.
- Consulta de entregas propias, apertura de navegación externa y registro del resultado.
- Consulta operativa para el administrador.

### P1, importante pero posterior al acceso

- Gestión de empleados.
- Directorio de clientes.
- Reportes operativos básicos.
- Historial de estados.

### P2, fuera del MVP salvo aprobación

- Pedido creado por el cliente, catálogo público y carrito.
- Pagos digitales, caja y comprobantes electrónicos.
- Inventario en tiempo real.
- Integraciones con sistemas internos de MASS.
- GPS propio, optimización de rutas y seguimiento continuo.
- Promociones, puntos o fidelización.
- Varias empresas o sucursales.
- Notificaciones push.
- Evidencia fotográfica o firma.
- Modo offline con sincronización.
- iOS y panel web.

El mockup de carrito y el de registro de datos quedan como referencia visual de una fase posterior. No forman parte de esta entrega.
