# Contexto y alcance

Fecha: 14 de octubre de 2026  
Fuente: `Document/Contexto del proyecto.md` y el encargo técnico del proyecto.  
Estado: definición de trabajo. No sustituye una aprobación del negocio.

## Hechos confirmados en el repositorio

- El producto descrito es una aplicación móvil para registrar y seguir pedidos de un minimarket, con atención presencial y entrega a domicilio.
- La tecnología móvil definida es Flutter y Dart. El backend previsto para esta etapa es Supabase con PostgreSQL y Row Level Security.
- La ubicación de referencia es Huancayo, Junín, Perú. La moneda prevista es PEN, el idioma español y la zona horaria `America/Lima`.
- El documento de contexto, versión 1.0 del 12 de octubre de 2026, está marcado como borrador funcional.
- Al iniciar esta auditoría el repositorio no era un repositorio Git y la aplicación era la plantilla del contador, con errores de sintaxis en `lib/main.dart`.
- No hay en el repositorio credenciales, catálogo oficial, APIs internas ni autorización escrita de Tiendas MASS.

## Supuestos de trabajo

- El MVP operativo lo usa el personal: administrador, operador y transportista.
- El operador registra el pedido. La compra autónoma del cliente queda fuera de esta etapa.
- Se modela una sola tienda hasta que se apruebe otra cosa.
- La atención presencial registra el pedido y su cierre. No incluye caja, cobro ni comprobante.
- Los precios, si se cargan, serán datos de prueba identificados como ficticios mientras no exista una fuente autorizada.

## Autorizaciones pendientes

- Usar la marca, el logotipo, los precios o los sistemas de Tiendas MASS.
- Tratar el producto como aplicación oficial.
- Confirmar el representante que puede aprobar reglas de negocio.
- Elegir la versión mínima de Android como decisión de negocio. La especificación de seguridad propone API 27 y el proyecto ya la usa como mínimo técnico.
- Definir si habrá pago, inventario, comprobantes, varias tiendas o pedidos creados por el cliente.

Hasta que esas autorizaciones existan, la interfaz usa la palabra MASS como nombre del proyecto y un isotipo tipográfico. No descarga el logotipo del mockup ni afirma que los servidores de una tienda estén operativos.
