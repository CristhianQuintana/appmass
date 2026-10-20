# Informe funcional y técnico: Módulo de Cliente y Compras — App MASS

Versión: 1.0  
Fecha: 20 de octubre de 2026  
Stack: Flutter + Dart, Riverpod, go_router, Supabase y PostgreSQL.  
Estado: auditoría contra el repositorio. El módulo de cliente no está implementado. Las decisiones comerciales de la sección 8 siguen abiertas y bloquean el checkout.

Este informe no autoriza a construir el autoservicio. El alcance vigente del repositorio es la operación asistida por personal.

## 1. Resumen ejecutivo

La especificación propone que un cliente explore productos, arme un carrito, elija cómo recibir la compra, confirme un pedido y consulte su estado, reutilizando el modelo operativo del personal.

Eso todavía no existe en el código. Lo que sí existe es el flujo interno:

operador registra el pedido → prepara → asigna transportista si es a domicilio → el transportista abre un mapa externo y registra el resultado → el administrador supervisa.

El cliente de la compra, en el modelo actual, es un contacto escrito por el personal (`customer_name`, teléfono y dirección). No es un usuario autenticado ni el dueño del pedido.

`docs/02-alcance-mvp.md` y el contexto del proyecto dejan el autoservicio, el catálogo público y el carrito como P2, fuera del MVP hasta una aprobación explícita. El contexto recomienda validar primero catálogo, precios y logística.

No hay fuente oficial de productos, precios, imágenes, cobertura, tarifa de envío ni método de pago. El catálogo cargado es ficticio (`PRB-*`, `is_sample = true`) y la interfaz lo indica. No debe presentarse como catálogo de Tiendas MASS.

No se implementó ninguna de las 12 pantallas CUS-01 a CUS-12. Hacerlo ahora exigiría inventar reglas que el propio documento prohíbe suponer.

## 2. Respuestas de la auditoría

| Pregunta | Hallazgo en el repositorio | Evidencia |
| --- | --- | --- |
| ¿Existe entidad de producto? | Sí, `public.products`. No hay tabla `categories` ni `image_url`. La categoría es texto. El precio es `price_cents` entero, no un decimal. | `supabase/migrations/20261014200000_operations.sql` |
| ¿Existe un pedido compartido con el operador? | Sí. `orders`, `order_items`, `order_events`, `delivery_assignments` y `delivery_incidents`. El autor es `created_by`, un perfil de personal, no un `customer_user_id`. | Misma migración y `lib/features/orders/` |
| ¿Cómo se autentican los usuarios? | Supabase Auth con PKCE. La sesión va al almacén seguro del sistema. El rol sale de `profiles` después del acceso. La pantalla de ingreso no elige rol. Sin proyecto Supabase, la app ofrece una demostración local. | `lib/app/bootstrap.dart`, `lib/features/authentication/`, `lib/features/simulation/` |
| ¿Qué políticas RLS hay? | Escritas en migraciones, no ejecutadas contra una base real. El personal activo administrador u operador lee productos. El transportista no lee el catálogo. Pedidos: administrador y operador ven el ámbito operativo; el transportista solo su asignación vigente. No hay políticas de inserción para el cliente. Las escrituras críticas pasan por funciones `SECURITY DEFINER`. | Migraciones `20261014120000_profiles.sql` y `20261014200000_operations.sql` |
| ¿Cuál es la fuente oficial de productos y precios? | No existe. Hay ocho productos de prueba en `20261014201000_sample_products.sql`. | `docs/06-catalogo-y-precios.md` |
| ¿Qué modalidades están aprobadas? | En el modelo operativo, `in_store` y `delivery`. No hay distritos, cobertura ni tarifa. | Restricción `orders_modality_check` |
| ¿Qué métodos de pago están permitidos? | Ninguno modelado. No hay `payment_method` ni `payment_status`. | Esquema de `orders` |
| ¿Qué estados existen realmente? | `submitted`, `preparing`, `ready_for_pickup`, `ready_for_dispatch`, `assigned`, `in_delivery`, `delivered`, `completed`, `cancelled`, `delivery_failed`. Dependen de la modalidad. El cliente no puede transicionarlos. | `order_status.dart` y `transition_order` |

## 3. Alcance: lo que hay y lo que la especificación pide

### Ya construido, para personal

- Ingreso, recuperación de contraseña y cierre de sesión.
- Perfiles `administrator`, `operator`, `courier` y `unassigned`. Una cuenta inactiva o sin rol no entra.
- Catálogo de prueba, búsqueda y alta o edición solo para administrador.
- Borrador de pedido del operador: modalidad, contacto, dirección, cantidades de 1 a 99.
- `create_order`: el servidor lee el precio, calcula `total_cents` y usa `auth.uid()`. El teléfono envía solo `product_id` y `quantity`.
- Idempotencia por `(created_by, idempotency_key)`.
- Preparación, cancelación con motivo, asignación, mapa externo solo con la dirección, entrega o incidencia con motivo de catálogo.
- Resumen, contactos derivados de pedidos y gestión de personal. Un administrador no cambia su propio acceso.
- Iconos de ayuda en las pantallas operativas.
- Demostración local, marcada como ficticia y sin red.

### Pedido por la especificación y ausente

- Rol e inicio de cliente.
- Inicio comercial, categorías, detalle de producto, carrito y contador.
- Checkout propio, direcciones guardadas y perfil de comprador.
- Historial «Mis pedidos» limitado al comprador autenticado.
- Línea de progreso para el cliente.
- Imágenes, envío, descuentos, impuestos y pago.
- Tabla de categorías, carrito persistido y `customer_addresses`.

### Fuera de alcance, coincidente con el repositorio

Pagos digitales, reembolsos, cupones, fidelización, chat, GPS propio, recomendaciones, pedidos recurrentes, facturación electrónica, inventario en tiempo real, multi-sucursal, ERP y POS. No están modelados y no deben mostrarse como disponibles.

## 4. Roles

No existe el rol `customer`. El check de `profiles.role` solo admite `administrator`, `operator`, `courier` y `unassigned`.

| Rol | Qué puede hoy | Qué no puede |
| --- | --- | --- |
| Operador | Crear y preparar pedidos; asignar transportista; leer catálogo activo | Cambiar su rol; ver personal |
| Administrador | Lo del operador, más resumen, catálogo inactivo, productos y personal ajeno | Cambiar su propio acceso |
| Transportista | Ver la asignación vigente, abrir el mapa y registrar el resultado | Crear pedidos, leer el catálogo o asignarse solo |
| Cliente comprador | Nada. No hay cuenta ni ruta | — |

`created_by` identifica al empleado que registró el pedido. Un futuro `customer_user_id` no puede sustituir ese campo: el operador debe seguir siendo el autor operativo cuando el pedido entre en preparación. Si se aprueba el autoservicio, el comprador sería un propietario adicional, no un reemplazo de `created_by`.

## 5. Diseño

La app usa Material 3, amarillo `#FFCC00` en la acción principal, tinta `#151C27` y fondo `#F9F9FF`. La marca es tipográfica. No hay logotipo oficial en el repositorio y no debe inventarse.

No hay recursos del proyecto Stitch enlazados como activos. Las tarjetas, botones e iconos de ayuda ya existen para el personal y pueden reutilizarse. No hay imágenes de producto: un placeholder solo tendría sentido después de definir la fuente.

La demostración y el catálogo `PRB-*` ya se identifican como ficticios. Esa regla se mantiene.

## 6. Mapa de las 12 pantallas

| ID | Pantalla | Prioridad propuesta | Estado en el código | Reutilizable |
| --- | --- | --- | --- | --- |
| CUS-01 | Inicio del cliente | P0 | No existe | Tema, aviso de catálogo de prueba |
| CUS-02 | Catálogo por categoría | P0 | No existe. La categoría es un texto, sin entidad | Búsqueda `list_catalog` |
| CUS-03 | Búsqueda | P0 | No existe para el cliente. El operador ya busca con espera de 300 ms | `sanitizeCatalogQuery` y `list_catalog` |
| CUS-04 | Detalle del producto | P0 | No existe | Campos `name`, `description`, `unit_label`, `price_cents` |
| CUS-05 | Carrito | P0 | No existe. El borrador del operador no es un carrito de cliente | `OrderDraft` solo como referencia de validación |
| CUS-06 | Modalidad y dirección | P0 | No existe para el cliente. El operador ya pide nombre, teléfono y dirección | Reglas de teléfono y dirección del borrador |
| CUS-07 | Confirmación | P0 | No existe | `create_order` y la clave de idempotencia, si se extienden con permiso de cliente |
| CUS-08 | Resultado | P0 | No existe | El código público `public_code` ya lo genera el servidor |
| CUS-09 | Mis pedidos | P0 | No existe. El listado actual no filtra por comprador | RLS de `orders`, que hoy no contempla al comprador |
| CUS-10 | Seguimiento | P0 | No existe. El detalle operativo no es una vista de cliente | `order_events` y los estados reales |
| CUS-11 | Perfil | P1 | No existe. El perfil actual es de personal | Lectura del propio perfil |
| CUS-12 | Direcciones | P1 | No existe. La dirección queda copiada en el pedido | Puede posponerse |

Rutas actuales: `/ingreso`, `/inicio/administrador`, `/inicio/operador`, `/inicio/transportista` y sus hijas. No hay prefijo `/customer`. Ocultar un botón no sustituye la autorización: hoy `resolveRedirect` solo admite el prefijo del rol de personal.

## 7. Flujo de compra frente al flujo real

El flujo propuesto termina en el mismo pedido que atiende el personal. Eso es compatible si el alta sigue siendo `create_order` o una función nueva que inserte en `orders` y `order_items`, no una tabla paralela.

Hoy el alta solo la ejecutan administrador y operador. El precio no viaja en el payload. La misma clave de idempotencia, para el mismo autor, devuelve el pedido ya creado. Esas tres reglas deben conservarse si el comprador confirma.

El estado inicial real es `submitted`, no un nombre comercial distinto. La línea de progreso del cliente tendría que traducir los estados existentes, no inventar «Registrado», «Preparado» o «En ruta» como valores nuevos de base de datos.

No hay GPS en vivo. El mapa del transportista abre solo la dirección en un enlace externo.

## 8. Decisiones comerciales que bloquean el checkout

Ninguna de estas preguntas está cerrada en el repositorio. No se implementan por suposición.

| Decisión | Situación actual | Efecto si se implementa sin respuesta |
| --- | --- | --- |
| ¿Cuenta obligatoria o invitado? | Solo hay cuentas de personal. El registro público debe permanecer desactivado. | No hay dueño del pedido |
| Fuente oficial de catálogo, precios e imágenes | No existe. Hay datos `PRB-*` | Se publicaría un catálogo falso |
| ¿Hay stock real? | No hay inventario | No se puede prometer disponibilidad |
| ¿Entrega, recogida o ambas? | El personal ya usa presencial y domicilio. Falta confirmar si el cliente puede elegirlas | El checkout no tiene opciones aprobadas |
| Cobertura y distritos | No hay zonas | No se puede validar una dirección |
| Tarifa de envío | No hay campo ni regla. El total es la suma de líneas | Un coste inventado alteraría el cobro |
| Pago | No modelado. El contexto separa pedido, pago y comprobante | No debe aparecer un método |
| ¿Hasta dónde cancela el cliente? | El personal cancela solo en `submitted` o `preparing`, con motivo | Una cancelación de cliente sería una transición nueva |
| ¿El alta queda aceptada o la revisa el operador? | Todo pedido nace en `submitted` y el operador lo prepara | Encaja con revisión humana, pero no está aprobado para autoservicio |
| Sustituciones y cambio de precio | El servidor rechaza un producto inactivo. No hay reconfirmación de precio para un carrito | El cliente podría confirmar un precio ya cambiado |
| ¿Una tienda o varias? | El modelo es de una operación. Multi-sucursal está fuera | — |
| Notificaciones | No hay push, correo de pedido ni SMS | — |
| Retención de datos personales | No hay política de retención | Direcciones y teléfonos no deben ampliarse sin criterio |

Pago contra entrega o en tienda, si se aprueba, tiene que modelarse aparte. Hoy no existe.

## 9. Modelo de datos: propuesta frente a lo migrado

No hace falta crear otro `orders`. Los campos propuestos que ya cubre el esquema son identificador, código legible, modalidad, estado, notas, nombre y teléfono de contacto, dirección, referencia, total e instantánea de línea (`product_name`, `unit_price_cents`, `quantity`, `line_total_cents`).

Diferencias que no deben «corregirse» en silencio:

- El dinero está en céntimos enteros. `docs/06` menciona un decimal; la migración y `Money` usan enteros. Esa es la decisión implementada.
- No hay `category_id`, `image_url`, `subtotal`, `delivery_fee`, `discount_total`, `payment_method` ni `payment_status`.
- No hay `customer_user_id`. `created_by` es el empleado.
- El historial es `order_events`, no `order_status_history`. Lo escriben las funciones del servidor.
- La dirección es una copia en el pedido. No hay direcciones guardadas.
- El carrito del operador es memoria de la sesión (`OrderDraft`), no tablas `carts` y `cart_items`.

Si más adelante se aprueba el módulo, la migración debe añadir el vínculo del comprador y las políticas nuevas sobre las tablas actuales. No se duplica el pedido.

Las migraciones no se han aplicado a ningún proyecto Supabase. El archivo de ejemplo `env/dev.json.example` no contiene claves.

## 10. Arquitectura y navegación

La app ya separa dominio, datos y presentación en `lib/features/`. Un módulo de cliente, si se aprueba, encajaría en `lib/features/customer/` sin mezclarlo con el shell de personal.

Rutas conceptuales `/customer/...` no están registradas. `resolveRedirect` devuelve al inicio del rol de personal cualquier ruta fuera de su prefijo. Un cliente con rol desconocido cae en `/sin-autorizacion`.

La demostración local (`demoModeProvider`) sustituye los repositorios solo en memoria. No es un canal de compra ni una sesión de Supabase.

## 11. Seguridad

Lo que ya protege el diseño, pendiente de prueba en una base real:

- RLS forzado en productos, pedidos, líneas, eventos, asignaciones, incidencias y perfiles.
- El cliente autenticado no tiene políticas de `INSERT`, `UPDATE` ni `DELETE` sobre pedidos.
- `create_order` ignora precios y totales enviados, exige rol activo de administrador u operador y rechaza producto inactivo o cantidad fuera de 1 a 99.
- Un transportista no lee pedidos sin asignación vigente.
- `admin_set_staff_access` no permite cambiar el propio acceso. La app no incluye `service_role`.
- Errores de Postgres no se muestran crudos.
- El enlace de mapa no lleva teléfono, notas ni tokens.

Lo que faltaría antes de un cliente comprador, y no está hecho:

- Política para que solo lea sus pedidos, sin usar un `customer_id` enviado por el teléfono.
- Impedir que lea direcciones o teléfonos de otros pedidos.
- Una función de alta que compruebe el permiso de cliente y siga calculando el total en el servidor.
- Pruebas RLS con dos compradores distintos. Hoy no hay proyecto Supabase ni esa prueba.
- Revisar el registro público: debe seguir desactivado. Una cuenta nueva nace `unassigned` e inactiva.

`docs/03-matriz-roles-permisos.md` es anterior a las funciones de pedidos. La fuente vigente de permisos es la migración de operaciones, no esa matriz.

## 12. Integración operativa

Un pedido creado por `create_order` ya queda visible para el operador y, tras la asignación, para un solo transportista. El cliente comprador no tiene consulta.

No hay Realtime. Las pantallas recargan al invalidar el proveedor. Para el personal es suficiente. Un seguimiento de cliente, si se aprueba, puede empezar por consulta bajo demanda. Realtime solo tendría sentido con las mismas políticas de lectura.

## 13. Pruebas

Ejecutadas en local, con dobles y con la demostración en memoria: acceso, navegación por rol, dinero en céntimos, borrador sin precios, transiciones inválidas, enlace de mapa, pedido vacío, ayuda y que el transportista simulado no ve pedidos ajenos. `flutter analyze` quedó sin issues en la última corrida de esas pruebas.

No ejecutadas, y por tanto no aprobadas:

- RLS con usuarios reales.
- Creación de pedido contra PostgreSQL.
- Cualquier caso CUS-01 a CUS-12.
- Autorización de un comprador, porque el rol no existe.
- La app en un emulador Android. La imagen disponible quedó fuera de línea. La evidencia visual se tomó en Chrome, en modo demostración.

No se afirma que el módulo de cliente esté probado.

## 14. Plan condicionado

El Sprint A de la especificación es esta auditoría. Los sprints B a F no empiezan hasta que se apruebe el canal de autoservicio y se cierren las decisiones que cambian el total o la autorización.

| Sprint | Qué haría | Bloqueo |
| --- | --- | --- |
| A. Auditoría | Hecho en este informe | — |
| B. Catálogo del cliente | Inicio, búsqueda y detalle, solo con datos marcados como prueba | Falta aprobación para publicar aunque sea el catálogo ficticio a un rol nuevo |
| C. Carrito | Intención local, separada del pedido | No cobra envío ni descuento |
| D. Checkout | Modalidad, dirección, `create_order` extendido e idempotencia | Cobertura, tarifa, pago, cancelación y aceptación |
| E. Historial | Lectura de pedidos propios y estados reales | RLS de comprador, sin base de prueba |
| F. Perfil y direcciones | Solo si se aprueba persistir direcciones | Retención de datos personales |

El primer incremento implementable, después de la aprobación, sería el Sprint B con el catálogo de prueba ya etiquetado. El checkout permanece cerrado.

## 15. Criterios de aceptación

El módulo de cliente no cumple los 17 criterios de la especificación. En particular no hay fuente oficial, ni carrito, ni checkout, ni historial del comprador, ni RLS de cliente probada. La identidad visual del personal sí existe. Las migraciones del flujo interno están escritas y no aplicadas.

## 16. Riesgos específicos de este módulo

| Riesgo | Situación |
| --- | --- |
| Publicar el catálogo `PRB-*` como si fuera MASS | Mitigado en la UI actual. Volvería a abrirse si un inicio de cliente no muestra el aviso |
| Precio enviado por el teléfono | Mitigado en `create_order` y en la demostración. Hay que conservar esa regla |
| Pedido paralelo | Mitigado mientras no se cree otra tabla. Cualquier alta nueva debe escribir en `orders` |
| RLS incompleta para compradores | Abierto. Las políticas actuales no conocen a ese rol |
| Doble envío | Mitigado para el empleado mediante `idempotency_key`. Habría que definir la clave del comprador |
| Pago o envío inventados | Abierto si el checkout se construye antes de la decisión |

## 17. Documentación relacionada

- Contexto y recomendación de MVP asistido: `Document/Contexto del proyecto.md`, secciones 17 y 23.
- Exclusión explícita del autoservicio: `docs/02-alcance-mvp.md`.
- Catálogo ficticio: `docs/06-catalogo-y-precios.md`.
- Modelo implementado: `docs/17-modelo-operativo.md`.
- Migraciones: `supabase/migrations/`.

`docs/03` y la frase de `docs/06` sobre un tipo decimal no describen el código actual. Este informe prevalece para el módulo de cliente hasta que esas páginas se actualicen.

## 18. Decisión

No se modifica el esquema ni se añaden pantallas de compra en esta entrega.

Para autorizar el Sprint B hace falta una respuesta escrita a estas preguntas:

1. ¿El autoservicio entra en el alcance, o sigue fuera del MVP?
2. ¿El cliente verá el catálogo de prueba, claramente marcado, o se espera una fuente oficial que aún no existe?
3. ¿Presencial, domicilio o ambas pueden elegirlas el comprador?
4. ¿El envío es cero, una tarifa definida o queda fuera?
5. ¿Qué método de pago, si alguno, se puede mostrar?
6. ¿El pedido del cliente nace en `submitted` y lo prepara el operador?

Hasta esas respuestas, el canal de compra permanece especificado y no construido.
