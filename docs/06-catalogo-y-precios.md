# Catálogo y precios

Fecha: 14 de octubre de 2026  
Estado: la fuente autorizada no existe. No se sembró un catálogo.

## Qué se sabe

- No hay en el repositorio un catálogo, una lista de precios ni una API de inventario.
- El contexto prohíbe presentar stock como confirmado si no hay una fuente fiable.
- El precio aplicado a un pedido confirmado deberá conservarse. Un cambio posterior del catálogo no puede reescribir el pedido.

## Decisión de trabajo

- Mientras no haya una fuente autorizada, el Sprint 2 usará productos ficticios marcados como datos de prueba.
- Esos datos no se presentarán como precios de Tiendas MASS.
- El campo de disponibilidad no se mostrará como stock real.
- El total definitivo se calculará en el servidor con un tipo decimal. El móvil solo podrá mostrar el resultado confirmado.

## Campos mínimos previstos

- Identificador.
- Nombre.
- Unidad de venta.
- Precio vigente.
- Estado activo o inactivo.
- Código y categoría solo si el dato existe.

## Pendiente

- Quién mantiene el catálogo.
- Si el precio incluye impuestos y cómo se redondea en soles.
- Si un producto inactivo puede permanecer en pedidos históricos. La regla prevista es que sí, como texto y precio ya aplicados, y que no pueda agregarse a un pedido nuevo.
