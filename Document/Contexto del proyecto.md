Documento de definición de producto y alcance
Aplicación móvil de gestión de pedidos, atención en tienda y entregas a domicilio --- MASS, Huancayo
Versión: 1.0  
Fecha: 12 de octubre de 2026  
Estado: Borrador funcional para validación antes del diseño técnico  
Plataforma inicial propuesta: Android  
Tecnología móvil definida: Flutter + Dart  
Ubicación de referencia: Huancayo, Junín, Perú  
Moneda y configuración regional: soles peruanos (PEN), español y
zona horaria `America/Lima`
> **Importante sobre la naturaleza del producto:** este documento
> describe una propuesta de aplicación relacionada con la operación de
> un minimarket MASS. No presupone que sea una aplicación oficial de
> Tiendas MASS, que exista autorización para usar su marca, que haya
> acceso a sus sistemas internos ni que se disponga de APIs, catálogo,
> precios o inventario corporativos. Antes de presentarla como producto
> oficial o integrar activos/sistemas de la empresa, deberán confirmarse
> los permisos correspondientes. Mientras eso no ocurra, se tratará como
> un proyecto independiente, prototipo o solución autorizada pendiente
> de validación.
---
1. Resumen ejecutivo
Se propone desarrollar una aplicación para gestionar el ciclo de
atención de pedidos de un minimarket: registro de una solicitud,
preparación de productos, asignación de un repartidor cuando
corresponda, entrega al cliente y cierre de la operación. La misma
solución debe permitir registrar ventas o pedidos atendidos
presencialmente en el establecimiento, sin obligar a que toda operación
pase por reparto.
El producto tendrá cuatro perfiles principales:
Administrador: supervisa la operación y gestiona usuarios,
tiendas, productos, pedidos, entregas, incidencias y reportes, según
los permisos asignados.
Operador de pedidos y preparación: registra pedidos, confirma
los datos, coordina la preparación, actualiza el estado y solicita o
realiza la asignación de reparto cuando esté autorizado. El nombre
definitivo del rol se validará con el proceso real.
Transportista o repartidor: consulta las entregas que tiene
asignadas, revisa la información necesaria para realizarlas, accede
a la ubicación del destino, organiza su recorrido y registra los
eventos de entrega.
Cliente: solicita productos o registra una compra/pedido,
proporciona sus datos y dirección cuando corresponda, consulta el
estado y recibe confirmación de la entrega o de la atención
presencial.
La aplicación debe distinguir dos modalidades operativas:
Atención presencial: el personal registra y atiende una compra
en el establecimiento. No requiere asignar un transportista.
Entrega a domicilio: se registra el pedido, se prepara, se
asigna un transportista y se documenta la entrega.
El objetivo de esta primera etapa no es programar pantallas, sino
acordar reglas de negocio, alcance, actores, estados, permisos, datos,
excepciones y criterios de aceptación. Este documento constituye una
especificación inicial; los puntos marcados como pendientes de
validación no deben tratarse como hechos confirmados del negocio.
---
2. Contexto, problema y oportunidad
2.1 Contexto
El proyecto está orientado a una operación de minimarket en Huancayo,
Perú, donde puede existir atención presencial y, si el negocio lo
aprueba, recepción y entrega de pedidos a domicilio. La solución busca
centralizar la información operativa en una plataforma con roles y
permisos.
No se asume que los procesos actuales sean manuales ni que MASS ofrezca
oficialmente reparto a domicilio. La investigación inicial debe
confirmar cómo se realiza hoy la atención, quién registra los pedidos,
cómo se controla la disponibilidad de productos y quién es responsable
de la entrega.
2.2 Problema que se busca resolver
Hipótesis de problema por validar: cuando el registro de pedidos, la
preparación, la asignación de repartidores y la confirmación de entrega
se realizan mediante herramientas separadas o comunicación informal,
puede ser difícil conocer el estado actualizado de cada pedido,
identificar al responsable de una tarea, evitar duplicidades y medir el
desempeño operativo.
2.3 Oportunidad
Centralizar el flujo permitiría:
mantener un registro único por pedido;
identificar quién registró, preparó, asignó y entregó cada pedido;
separar la atención presencial de la entrega a domicilio;
visualizar estados y tareas pendientes;
reducir errores de transcripción y pedidos duplicados;
consultar las entregas asignadas a cada transportista;
ayudar al transportista a llegar a la dirección del cliente;
registrar incidencias y motivos de cancelación;
obtener reportes de operación y tiempos, cuando haya datos
suficientes.
Estos beneficios son objetivos esperados, no resultados demostrados. Se
medirán durante las pruebas piloto.
---
3. Objetivos
3.1 Objetivo general
Definir y desarrollar una aplicación móvil con Flutter que permita
gestionar de manera trazable el registro, preparación, asignación,
seguimiento y cierre de pedidos de un minimarket, incluyendo tanto la
atención presencial como las entregas a domicilio, con acceso
diferenciado para administradores, operadores, transportistas y
clientes.
3.2 Objetivos específicos
Definir un flujo operativo común para registrar y procesar pedidos.
Permitir que el personal autorizado registre pedidos presenciales o
para entrega.
Administrar el catálogo de productos y sus precios mediante una
fuente de datos autorizada y definida.
Controlar el avance del pedido mediante estados explícitos y
transiciones válidas.
Permitir la asignación de una entrega a un transportista habilitado.
Proporcionar al transportista una lista de entregas asignadas y la
información necesaria para completarlas.
Facilitar la apertura de una ruta hacia la dirección de destino
mediante un servicio de mapas compatible.
Registrar la confirmación de entrega, el resultado de intentos
fallidos y las incidencias.
Ofrecer al administrador una visión consolidada de la operación, con
permisos acordes a su función.
Proteger los datos personales, las sesiones y las operaciones
sensibles.
Probar los flujos principales y las excepciones antes de utilizar la
aplicación en una operación real.
3.3 Indicadores iniciales de éxito
Los valores objetivo deberán acordarse con el responsable del negocio.
Como mínimo, el piloto debe medir:
porcentaje de pedidos con información obligatoria completa;
porcentaje de pedidos con historial de estados completo;
porcentaje de entregas registradas con resultado final;
número de pedidos duplicados;
porcentaje de pedidos cancelados y sus motivos;
tiempo entre registro y preparación;
tiempo entre asignación y primer intento de entrega;
porcentaje de entregas completadas en el primer intento;
número de incidencias por cada cantidad definida de pedidos;
tasa de errores críticos detectados en pruebas.
No se fijan metas numéricas sin una línea base del negocio.
---
4. Alcance funcional
4.1 Incluido en la propuesta de producto
Aplicación móvil Android desarrollada con Flutter.
Autenticación y control de acceso según rol.
Gestión de perfiles y usuarios autorizados.
Consulta y gestión del catálogo, según permisos.
Registro de pedidos por el cliente o por personal autorizado.
Selección de modalidad: atención presencial o entrega a domicilio.
Registro de datos del cliente y, si corresponde, dirección de
entrega.
Detalle de productos, cantidades, precios aplicables y total.
Flujo de preparación del pedido.
Asignación y reasignación controlada de transportistas.
Vista de entregas asignadas al transportista.
Acceso a navegación externa o mapa para llegar al destino.
Registro de eventos de entrega e incidencias.
Consulta del estado del pedido por usuarios autorizados.
Panel operativo para administración.
Historial de acciones relevantes.
Validaciones, manejo de errores y pruebas.
Configuración regional para Perú.
4.2 Fuera del alcance inicial, salvo aprobación expresa
Integración con sistemas internos de MASS o de terceros sin
autorización y documentación.
Uso de logotipos, imágenes, diseños o marca oficial sin
autorización.
Promociones oficiales, precios corporativos o inventario real no
suministrado por una fuente autorizada.
Facturación electrónica, emisión de comprobantes fiscales o
integración con SUNAT.
Procesamiento directo de tarjetas o almacenamiento de datos
completos de tarjetas.
Programa de puntos, cupones, membresías o fidelización.
Chat en tiempo real entre cliente, operador y transportista.
Seguimiento GPS continuo en segundo plano.
Optimización avanzada de rutas para múltiples repartidores y
ventanas horarias.
Asignación automática basada en inteligencia artificial.
Gestión de nómina, turnos, remuneraciones o evaluación laboral.
Integración con ERP, POS, almacenes, proveedores o plataformas de
reparto.
Versión iOS.
Portal web administrativo completo, a menos que se decida como
componente separado.
Modo offline con sincronización compleja.
Operación en múltiples ciudades o franquicias sin confirmar primero
el modelo de tiendas.
4.3 Distinción esencial: pedido, venta y comprobante
La aplicación debe diferenciar estos conceptos:
Pedido: solicitud de productos y una modalidad de atención.
Venta: operación comercial que se considera realizada según las
reglas del negocio.
Pago: registro o confirmación del dinero recibido por un medio
permitido.
Comprobante: documento tributario emitido por un sistema
autorizado, si corresponde.
Crear un pedido en la aplicación no significa automáticamente que exista
una venta fiscalmente válida, que el pago haya sido recibido ni que se
haya emitido un comprobante. Estas reglas deberán definirse antes de
implementar cobros reales.
---
5. Actores, roles y permisos
El rol se asignará a la cuenta por un administrador autorizado. El
usuario no debe poder obtener privilegios seleccionando libremente un
rol en el registro. Los permisos deberán validarse también en el
backend, no solo ocultando opciones en la interfaz.
5.1 Administrador
Propósito: supervisar la operación y mantener la configuración
autorizada del sistema.
Funciones propuestas:
consultar el resumen general de pedidos;
consultar pedidos por estado, fecha, modalidad, tienda y
responsable, según el alcance;
crear, editar, activar, desactivar y consultar cuentas de personal;
asignar roles y permisos autorizados;
habilitar o deshabilitar transportistas;
consultar y administrar el catálogo, si esa responsabilidad se le
asigna;
revisar pedidos e historial de cambios;
asignar o reasignar transportistas;
revisar incidencias, cancelaciones y entregas fallidas;
consultar indicadores operativos;
configurar parámetros generales permitidos;
consultar el registro de auditoría;
bloquear una cuenta comprometida o inactiva;
gestionar tiendas si se aprueba la operación multisucursal.
Restricciones:
no puede consultar secretos ni contraseñas en texto plano;
los cambios críticos deben quedar registrados;
las acciones sobre pedidos cerrados deben estar limitadas y
auditadas;
no debe poder alterar silenciosamente el historial de una operación;
el alcance de acceso a datos personales debe ser el mínimo
necesario.
Pendiente de decisión: si el administrador podrá editar precios,
confirmar pagos, cancelar pedidos, reabrir pedidos cerrados y gestionar
varias tiendas.
5.2 Operador de pedidos y preparación
Nombre de rol recomendado provisional: Operador de pedidos. Otras
alternativas: Asesor de atención, Preparador de pedidos o
Operador de tienda. "Cajero" puede ser inexacto si su función
principal no es cobrar en caja.
Propósito: registrar y preparar pedidos, mantener actualizado su
estado y coordinar la atención presencial o el despacho.
Funciones propuestas:
iniciar sesión;
registrar un pedido para un cliente;
buscar o registrar los datos mínimos del cliente;
añadir productos y cantidades;
consultar el precio vigente disponible en el sistema;
validar disponibilidad si existe una fuente de stock confiable;
seleccionar atención presencial o entrega a domicilio;
registrar dirección e indicaciones para el reparto, cuando
corresponda;
revisar el resumen antes de confirmar;
enviar el pedido al flujo de preparación;
marcar el inicio y fin de la preparación;
registrar sustituciones, faltantes o productos no disponibles, si la
política lo permite;
solicitar o efectuar la asignación del transportista según sus
permisos;
registrar la entrega presencial al cliente cuando ese flujo esté
autorizado;
consultar pedidos de su tienda o ámbito asignado;
reportar incidencias;
consultar el historial necesario para atender al cliente.
Restricciones:
no administra roles ni permisos globales;
no accede a información de otras tiendas salvo autorización;
no puede modificar un pedido entregado sin un procedimiento
especial;
no puede marcar un pago como confirmado si no existe evidencia o
validación del mecanismo definido;
no puede declarar que hay stock si la aplicación no dispone de datos
fiables;
toda cancelación, modificación posterior a la confirmación o
sustitución debe respetar las reglas de negocio y dejar registro.
Decisión pendiente: confirmar si este rol también cobra, maneja
caja, registra ventas presenciales o solo registra/prepara pedidos. No
se asumirá manejo de efectivo en el MVP hasta definirlo.
5.3 Transportista o repartidor
Nombre recomendado provisional: Repartidor si la función principal
es entregar pedidos a domicilio; Transportista si también transporta
mercancías entre locales. Para el alcance descrito, "Repartidor" parece
más preciso.
Propósito: ejecutar las entregas que le han sido asignadas y
registrar su resultado.
Funciones propuestas:
iniciar sesión;
consultar sus entregas asignadas;
consultar datos mínimos del pedido necesarios para entregar;
ver dirección, referencia e indicaciones de entrega;
llamar al cliente mediante una acción explícita, si la política de
privacidad lo permite;
abrir la dirección en una aplicación de mapas instalada;
ordenar manualmente sus paradas;
consultar el estado de cada entrega;
aceptar o rechazar una asignación solo si el negocio define ese
proceso;
marcar que inició el reparto;
registrar intento de entrega;
registrar entrega exitosa con fecha y hora;
registrar entrega fallida con motivo;
registrar incidencias;
adjuntar evidencia de entrega solo si se define qué evidencia se
necesita y existe consentimiento/base legítima;
finalizar la jornada o indicar disponibilidad, si se incorpora
gestión de turnos.
Restricciones:
solo ve pedidos asignados a su cuenta;
no cambia precios, cantidades o datos comerciales del pedido;
no reasigna pedidos a otros repartidores;
no consulta el historial general de clientes;
no marca una entrega como completada sin cumplir los criterios
establecidos;
no debe rastrearse continuamente en segundo plano en la primera
versión;
no debe mostrarse más información personal que la necesaria para
realizar la entrega.
Pendiente de decisión: si el repartidor recibe pagos, debe devolver
efectivo, realiza entregas parciales, puede rechazar pedidos y si se
requiere foto, firma, PIN u otra prueba de entrega.
5.4 Cliente
Propósito: realizar o solicitar un pedido, indicar cómo desea
recibirlo y consultar su estado.
Funciones propuestas:
registrarse e iniciar sesión, si se exige cuenta;
continuar como invitado, solo si se aprueba esa opción;
consultar catálogo, categorías y detalles de productos;
buscar productos;
consultar precios publicados por la fuente autorizada;
seleccionar cantidades;
crear un pedido;
elegir atención presencial o entrega a domicilio cuando ambas
opciones estén disponibles;
proporcionar y confirmar datos de contacto;
registrar dirección y referencias para entrega;
revisar el resumen y el total;
confirmar la solicitud;
consultar el estado y el historial básico de su pedido;
recibir notificaciones de cambios importantes si se habilitan;
consultar el historial de sus pedidos;
cancelar dentro de las condiciones permitidas;
reportar un problema;
solicitar la actualización o eliminación de datos de acuerdo con la
política aplicable.
Restricciones:
solo consulta sus propios pedidos;
no modifica un pedido que ya está en preparación o reparto salvo
mediante un flujo permitido;
no puede manipular precios, totales ni estados internos;
no puede consultar datos de otros clientes;
el catálogo, la compra y la entrega deben presentarse como funciones
disponibles solo cuando la operación real las soporte.
Decisión pendiente: confirmar si el cliente realmente hará pedidos
desde su propio teléfono en el MVP o si el pedido será registrado
exclusivamente por el personal. Esta decisión cambia de manera
importante el alcance y la interfaz.
5.5 Matriz preliminar de permisos
---
Acción              Administrador         Operador       Repartidor     Cliente
---
Ver panel global    Sí                    No; solo       No             No
ámbito  
autorizado
Gestionar cuentas y Sí, con permisos      No             No             No
roles
Consultar catálogo  Sí                    Sí             Solo resumen   Sí, si se
del pedido     habilita
Gestionar           Según permisos        No, salvo      No             No
productos/precios                         autorización  
explícita
Crear pedido        Sí, si lo necesita    Sí             No             Sí, si se
habilita
Preparar pedido     Supervisión/ajustes   Sí             No             No
autorizados
Asignar repartidor  Sí                    Si se autoriza No             No
Ver entregas de     Sí, según ámbito      Según          No             No
otros repartidores                        necesidad  
operativa
Ver entregas        Sí                    Según          Sí             No
asignadas                                 necesidad  
operativa
Marcar entrega      Supervisión           No, salvo      Sí, para sus   No
excepcional y         atención       asignaciones  
auditada              presencial
Consultar su propio Sí, por operación     Según ámbito   Solo lo        Sí
pedido                                                   asignado
Cancelar pedido     Según política        Según permisos Reporta        Según política
y estado       incidencia     y estado
Consultar auditoría Sí, según permisos    Solo acciones  Solo acciones  No
propias cuando propias cuando
proceda        proceda
La matriz es una propuesta inicial. El equipo deberá convertirla en
permisos explícitos y pruebas de autorización.
---
6. Flujos de negocio
6.1 Flujo A: pedido registrado por el cliente
Este flujo solo aplica si se confirma que el cliente puede crear pedidos
desde su dispositivo.
El cliente consulta el catálogo.
Selecciona productos y cantidades.
La aplicación valida los datos disponibles y muestra el resumen.
El cliente elige atención presencial o entrega a domicilio.
Si es a domicilio, registra dirección, referencia y contacto.
La aplicación presenta total, condiciones y modalidad.
El cliente confirma la solicitud.
El sistema crea el pedido con identificador único y estado inicial.
El operador recibe el pedido en su cola de trabajo.
El operador revisa disponibilidad y acepta, rechaza o solicita
cambios según política.
Si se acepta, se inicia la preparación.
Para atención presencial, se completa el flujo de entrega en tienda.
Para reparto, se asigna un repartidor cuando el pedido está listo y
se cumplen las reglas de despacho.
El repartidor ejecuta la entrega y registra el resultado.
El sistema cierra el pedido según las reglas definidas.
El cliente puede consultar el resultado e historial.
Excepciones que deben definirse: producto agotado, precio
actualizado, cliente no localizable, dirección inválida, pedido
duplicado, cancelación, pago pendiente, aplicación sin conexión y tienda
sin capacidad de atender pedidos.
6.2 Flujo B: pedido registrado por el operador
El operador inicia sesión.
Selecciona "Nuevo pedido".
Busca un cliente existente o registra los datos mínimos necesarios.
Añade productos y cantidades.
El sistema muestra precios y total de acuerdo con la fuente vigente.
El operador selecciona "Atención presencial" o "Entrega a
domicilio".
Si es a domicilio, registra dirección y referencias.
Revisa y confirma el pedido.
El pedido aparece en la cola de preparación.
El operador inicia la preparación.
Registra productos preparados y excepciones permitidas.
Si es presencial, entrega el pedido y registra el resultado.
Si es a domicilio, marca el pedido listo para despacho y asigna un
repartidor autorizado.
El repartidor realiza la entrega.
El sistema conserva la trazabilidad hasta el cierre.
Regla crítica: el sistema debe impedir que un pedido para reparto se
asigne antes de estar listo, salvo que el negocio defina una excepción
expresa.
6.3 Flujo C: atención presencial
El operador registra la solicitud o venta según el proceso aprobado.
Añade los productos y confirma el resumen.
Se prepara o entrega el pedido en el establecimiento.
Se registra el resultado de la atención presencial.
El pedido queda cerrado con el usuario, fecha y hora
correspondientes.
Pendiente de validación: si la app solo registra pedidos
presenciales, o si además gestionará caja, cobro, devoluciones,
comprobantes o integración con un POS. Estas funciones no se presumen
incluidas.
6.4 Flujo D: reparto a domicilio
El pedido pasa a "Listo para despacho".
Un usuario autorizado asigna un repartidor habilitado.
El repartidor ve la nueva asignación.
Revisa dirección y detalles indispensables.
Inicia el reparto.
Abre la navegación hacia el destino.
Al llegar, registra el intento.
Si entrega el pedido, registra el resultado y la evidencia acordada.
Si no puede entregarlo, selecciona un motivo y registra la
incidencia.
El pedido queda entregado, con intento fallido o pendiente de una
decisión operativa.
Si requiere otro intento, devolución o reasignación, el
administrador u operador autorizado ejecuta el flujo definido.
6.5 Flujo E: reasignación
Un pedido tiene un repartidor asignado.
Un usuario autorizado solicita la reasignación y selecciona el
motivo.
El sistema comprueba que el estado permite la acción.
Se registra la asignación anterior, la nueva asignación, el actor,
la fecha y el motivo.
La asignación anterior deja de aparecer como activa para el
repartidor anterior.
El nuevo repartidor ve la entrega asignada.
No se debe sobrescribir el historial de asignaciones.
---
7. Estados y transiciones
7.1 Estados propuestos del pedido
---
Estado                              Significado
---
`draft` / Borrador                  El pedido está en edición y aún no
se ha confirmado.
`submitted` / Solicitado            La solicitud fue confirmada y
espera revisión operativa.
`confirmed` / Confirmado            El personal autorizado confirmó que
puede procesarse.
`preparing` / En preparación        Se está preparando el pedido.
`ready_for_pickup` / Listo para     Está listo para entrega presencial
atención                            o retiro, según modalidad.
`ready_for_dispatch` / Listo para   Está listo para ser asignado o
despacho                            salir a reparto.
`assigned` / Asignado               Tiene un repartidor asignado y aún
no inició el reparto.
`in_delivery` / En reparto          El repartidor inició el recorrido.
`delivered` / Entregado             Se confirmó la entrega según la
regla definida.
`completed` / Cerrado               La operación terminó y no admite
cambios ordinarios.
`cancelled` / Cancelado             Se canceló conforme a una regla y
con motivo registrado.
`delivery_failed` / Entrega fallida Un intento de entrega no se
completó; puede requerir una
decisión posterior.
No todos los estados se utilizarán en todos los tipos de pedido. El
flujo presencial no debe pasar por asignación ni reparto. Se debe
definir si `delivered` y `completed` son estados separados o si uno
basta para el negocio. La tabla es una propuesta que debe validarse
antes de implementarse.
7.2 Transiciones principales
`draft` → `submitted`
`submitted` → `confirmed` o `cancelled`
`confirmed` → `preparing` o `cancelled`
`preparing` → `ready_for_pickup`, `ready_for_dispatch` o
`cancelled`, según las reglas
`ready_for_pickup` → `completed`
`ready_for_dispatch` → `assigned`
`assigned` → `in_delivery` o regreso controlado a
`ready_for_dispatch`
`in_delivery` → `delivered` o `delivery_failed`
`delivered` → `completed`
`delivery_failed` → nueva asignación, nuevo intento, devolución o
cancelación, según política
`completed` y `cancelled` son terminales para la operación normal;
cualquier reapertura debe ser excepcional y auditada.
El backend, cuando exista, será la autoridad para validar las
transiciones. No se confiará exclusivamente en las condiciones de la
interfaz móvil.
7.3 Estados de una entrega
Se recomienda separar el estado del pedido del estado de la
asignación/entrega. Un pedido representa la solicitud comercial; una
entrega representa el intento logístico. Esta separación facilita los
reintentos y las reasignaciones sin borrar el historial del pedido.
Estados iniciales posibles de la entrega:
pendiente de asignación;
asignada;
aceptada, si se utiliza aceptación;
en camino;
intento fallido;
entregada;
cancelada;
devuelta a tienda, si se define ese proceso.
La lista final dependerá de si se permiten múltiples intentos, entregas
parciales y devoluciones.
---
8. Requisitos funcionales
Los identificadores permiten convertir esta especificación en tareas,
casos de prueba y criterios de aceptación.
8.1 Autenticación y cuentas
RF-AUT-01: el sistema debe permitir iniciar sesión mediante el
mecanismo definido.
RF-AUT-02: el sistema debe determinar el rol a partir de la
cuenta autorizada, no de una selección libre del usuario.
RF-AUT-03: el sistema debe restringir las pantallas y
operaciones según el rol.
RF-AUT-04: las operaciones protegidas deben validarse en el
backend cuando exista backend.
RF-AUT-05: el administrador autorizado debe poder activar o
desactivar cuentas.
RF-AUT-06: el sistema debe cerrar o renovar sesiones según una
política definida.
RF-AUT-07: los errores de autenticación no deben revelar si una
cuenta ajena existe cuando eso represente un riesgo.
RF-AUT-08: la recuperación de acceso debe seguir un proceso
seguro.
RF-AUT-09: el sistema debe registrar eventos relevantes de
acceso sin guardar contraseñas ni tokens.
RF-AUT-10: el usuario debe poder cerrar sesión.
8.2 Usuarios y permisos
RF-USR-01: el administrador podrá consultar las cuentas dentro
de su ámbito autorizado.
RF-USR-02: el administrador podrá crear o invitar usuarios
internos según el método elegido.
RF-USR-03: el administrador podrá asignar roles permitidos.
RF-USR-04: el sistema impedirá que un usuario eleve sus
privilegios por cuenta propia.
RF-USR-05: los cambios de rol, estado o ámbito deberán quedar
auditados.
RF-USR-06: el sistema limitará el acceso a los datos de clientes
según necesidad operativa.
RF-USR-07: las cuentas desactivadas no podrán iniciar nuevas
sesiones.
8.3 Catálogo y productos
RF-CAT-01: los usuarios autorizados podrán consultar productos
disponibles en el catálogo.
RF-CAT-02: el catálogo mostrará nombre, descripción breve,
unidad, precio y disponibilidad únicamente si esos datos existen y
son confiables.
RF-CAT-03: el usuario podrá buscar productos por nombre o código
si el dato existe.
RF-CAT-04: el sistema permitirá filtrar por categorías si se
aprueban.
RF-CAT-05: solo los roles autorizados podrán crear o modificar
productos y precios.
RF-CAT-06: los cambios de precio deberán registrar fecha de
vigencia y usuario responsable, si el sistema administra precios.
RF-CAT-07: si no existe una fuente real de inventario, el
sistema no deberá presentar disponibilidad como stock confirmado.
RF-CAT-08: los productos desactivados no podrán añadirse a
nuevos pedidos.
8.4 Pedidos
RF-PED-01: el sistema permitirá crear un pedido desde los roles
habilitados.
RF-PED-02: cada pedido tendrá un identificador único.
RF-PED-03: cada pedido registrará fecha, hora, creador,
modalidad, cliente y estado.
RF-PED-04: el pedido tendrá una lista de productos, cantidades,
precios aplicados y subtotal.
RF-PED-05: el sistema calculará el total con reglas
centralizadas y verificables.
RF-PED-06: el sistema impedirá cantidades inválidas o productos
desactivados.
RF-PED-07: antes de confirmar, se mostrará un resumen del
pedido.
RF-PED-08: el sistema impedirá confirmar un pedido si faltan
datos obligatorios para su modalidad.
RF-PED-09: el pedido podrá consultarse por identificador, estado
y filtros permitidos.
RF-PED-10: las modificaciones posteriores a la confirmación
estarán limitadas por estado y permiso.
RF-PED-11: una cancelación requerirá motivo cuando la política
lo determine.
RF-PED-12: las operaciones que puedan duplicarse por reintentos
deberán diseñarse para evitar pedidos duplicados.
RF-PED-13: el sistema mantendrá un historial de cambios de
estado.
RF-PED-14: el sistema distinguirá atención presencial de entrega
a domicilio.
RF-PED-15: un pedido cerrado no podrá editarse mediante el flujo
ordinario.
8.5 Preparación
RF-PRE-01: el operador autorizado verá una cola de pedidos
pendientes de preparar.
RF-PRE-02: el operador podrá iniciar la preparación de un pedido
elegible.
RF-PRE-03: el sistema registrará quién inició y finalizó la
preparación.
RF-PRE-04: el operador podrá marcar faltantes o incidencias
según la política aprobada.
RF-PRE-05: el pedido solo pasará a listo cuando se cumplan las
condiciones definidas.
RF-PRE-06: el sistema impedirá que dos operadores ejecuten
cambios incompatibles sin una regla de concurrencia.
RF-PRE-07: las sustituciones requerirán una política explícita
y, si corresponde, aceptación del cliente.
8.6 Asignación de reparto
RF-ASI-01: solo usuarios autorizados podrán asignar
repartidores.
RF-ASI-02: solo se asignarán pedidos de entrega a domicilio que
cumplan las condiciones de despacho.
RF-ASI-03: solo repartidores activos y habilitados podrán
recibir asignaciones.
RF-ASI-04: el sistema registrará el responsable, fecha, hora y
repartidor de cada asignación.
RF-ASI-05: una reasignación conservará el historial anterior.
RF-ASI-06: el sistema impedirá asignaciones incompatibles con el
estado del pedido.
RF-ASI-07: el sistema deberá evitar que dos repartidores tengan
la misma entrega activa por una actualización concurrente.
RF-ASI-08: si se decide manejar capacidad máxima por repartidor,
esta deberá configurarse y probarse.
8.7 Aplicación del repartidor
RF-REP-01: el repartidor verá únicamente las entregas de su
ámbito autorizadas y asignadas a él.
RF-REP-02: podrá consultar el resumen necesario de cada pedido.
RF-REP-03: podrá abrir la dirección de entrega en una aplicación
de mapas compatible.
RF-REP-04: podrá marcar el inicio del reparto.
RF-REP-05: podrá registrar un intento de entrega.
RF-REP-06: podrá marcar entrega exitosa solo si se cumplen las
condiciones definidas.
RF-REP-07: podrá registrar una entrega fallida con un motivo de
una lista controlada y una observación opcional.
RF-REP-08: podrá reportar incidencias.
RF-REP-09: no podrá modificar productos, precios ni el total
comercial.
RF-REP-10: el sistema registrará la hora del evento y el usuario
responsable.
RF-REP-11: si se permite evidencia fotográfica, el sistema
controlará permisos, acceso y retención de imágenes.
RF-REP-12: el sistema deberá manejar la pérdida de conexión
durante el registro de eventos según la estrategia offline aprobada.
8.8 Cliente
RF-CLI-01: el cliente podrá consultar el catálogo si el canal de
autoservicio está habilitado.
RF-CLI-02: podrá crear un pedido si se confirma esa capacidad
para el MVP.
RF-CLI-03: podrá registrar los datos mínimos de contacto y
entrega necesarios.
RF-CLI-04: podrá revisar modalidad, productos, cantidades y
total antes de confirmar.
RF-CLI-05: podrá consultar el estado de sus pedidos.
RF-CLI-06: podrá consultar únicamente sus propios pedidos.
RF-CLI-07: podrá cancelar solo cuando la política y el estado lo
permitan.
RF-CLI-08: recibirá una explicación clara si una acción no está
permitida.
RF-CLI-09: si se habilitan notificaciones, estas no deberán
exponer datos sensibles en la pantalla bloqueada.
8.9 Administración y reportes
RF-ADM-01: el administrador verá un resumen de pedidos por
estado.
RF-ADM-02: podrá filtrar por fechas, modalidad, estado, tienda y
responsable cuando esos campos existan.
RF-ADM-03: podrá consultar pedidos y su historial.
RF-ADM-04: podrá consultar asignaciones y resultados de entrega.
RF-ADM-05: podrá consultar incidencias y motivos de cancelación.
RF-ADM-06: podrá consultar indicadores calculados a partir de
eventos registrados.
RF-ADM-07: los reportes no deberán presentar como real un dato
ausente o estimado.
RF-ADM-08: las exportaciones de datos, si se incluyen, estarán
limitadas por permisos y registradas.
RF-ADM-09: las acciones administrativas sensibles quedarán en
auditoría.
8.10 Notificaciones
Las notificaciones push no son obligatorias para el primer incremento
salvo que se confirme que son necesarias.
Si se incorporan:
RF-NOT-01: se enviarán ante eventos definidos, como pedido
confirmado, listo, asignado o entregado.
RF-NOT-02: no se enviarán notificaciones duplicadas por
reintentos.
RF-NOT-03: el contenido respetará la privacidad del usuario.
RF-NOT-04: el sistema mantendrá una forma alternativa de
consultar el estado si el usuario no recibe notificaciones.
8.11 Auditoría e incidencias
RF-AUD-01: los cambios críticos registrarán actor, fecha/hora,
entidad afectada, acción y resultado.
RF-AUD-02: la auditoría no guardará contraseñas, tokens ni datos
de tarjeta.
RF-AUD-03: el usuario operativo podrá registrar incidencias
relacionadas con un pedido o entrega.
RF-AUD-04: las incidencias tendrán categoría, descripción,
estado y responsable cuando corresponda.
RF-AUD-05: el cierre o resolución de una incidencia conservará
su historial.
---
9. Requisitos no funcionales
9.1 Seguridad
Todas las comunicaciones remotas deben utilizar HTTPS.
Los permisos deben verificarse en el backend cuando exista.
Las credenciales y tokens no deben almacenarse en texto plano.
No se deben incluir secretos de producción en el repositorio ni en
el binario móvil.
Los errores no deben filtrar información interna, credenciales ni
trazas sensibles.
Deben aplicarse validación de entradas, límites de acceso y
protección contra operaciones duplicadas.
Deben revisarse las dependencias y sus vulnerabilidades conocidas.
El acceso a datos personales debe seguir el principio de mínimo
privilegio.
La administración de roles y los cambios críticos deben auditarse.
9.2 Privacidad y protección de datos
El diseño debe identificar qué datos personales se recogen, por qué son
necesarios, quién accede a ellos, cuánto tiempo se conservan y cómo se
atienden solicitudes de actualización o eliminación. Antes de operar con
usuarios reales, debe revisarse la normativa peruana aplicable sobre
protección de datos personales y definir el aviso/política de privacidad
correspondiente.
No solicitar DNI, fecha de nacimiento ni otros datos sensibles si no
existe una necesidad justificada. Para la entrega, puede bastar con
nombre, teléfono y dirección, sujeto a la política comercial y legal
aprobada.
9.3 Rendimiento
La interfaz debe mantener una respuesta fluida en los dispositivos
Android objetivo.
Las listas grandes deberán utilizar carga incremental o paginación
cuando corresponda.
No deben ejecutarse operaciones pesadas en el hilo principal.
Las imágenes deben optimizarse para el dispositivo y la conexión.
Las solicitudes deben mostrar estados de carga, éxito y error.
Los objetivos numéricos de rendimiento se establecerán después de
definir dispositivos y volumen esperado.
9.4 Disponibilidad y conectividad
La aplicación debe explicar claramente cuando no hay conexión.
No debe mostrar una operación como confirmada si el servidor no la
confirmó.
Los reintentos deben evitar duplicar pedidos, asignaciones o
eventos.
El alcance offline deberá definirse por flujo: lectura en caché,
registro temporal o ninguna operación sin conexión.
No se debe prometer operación completamente offline antes de diseñar
y probar sincronización y resolución de conflictos.
9.5 Compatibilidad
Plataforma inicial: Android.
Versión mínima de Android: pendiente de decisión.
Dispositivos objetivo: pendiente de decisión.
iOS: fuera del alcance inicial, salvo aprobación.
Versiones de Flutter y Dart: se fijarán después de auditar el
entorno y verificar compatibilidad de dependencias.
9.6 Mantenibilidad y calidad
El código se organizará por funcionalidades y responsabilidades.
La lógica comercial no se concentrará en widgets.
Los componentes visuales reutilizables deberán tener estilos
centralizados.
Los errores deberán manejarse de forma consistente.
Las reglas de negocio deberán contar con pruebas.
Las decisiones técnicas relevantes se documentarán.
No se declarará una prueba como aprobada sin haberla ejecutado.
9.7 Accesibilidad y usabilidad
textos legibles y acciones principales visibles;
formularios con validaciones comprensibles;
controles táctiles adecuados;
contraste suficiente;
mensajes de error accionables;
navegación consistente;
confirmación antes de acciones destructivas;
estados vacíos y de carga diseñados;
adaptación a pantallas de distintos tamaños.
9.8 Localización
idioma principal: español;
moneda: PEN cuando se muestren importes;
zona horaria de negocio: `America/Lima`;
formatos regionales coherentes;
almacenamiento de fechas en un formato consistente y presentación
local al usuario.
---
10. Datos principales del dominio
Este apartado define conceptos de negocio, no un esquema físico
definitivo de base de datos.
10.1 Usuario
Campos conceptuales:
identificador;
nombre;
correo o identificador de acceso;
teléfono si es necesario;
rol;
estado de cuenta;
ámbito o tienda asignada;
fechas de creación y actualización.
No almacenar contraseñas en el perfil de negocio. La autenticación debe
delegarse a un mecanismo seguro.
10.2 Cliente
identificador;
nombre o nombre de contacto;
teléfono;
correo opcional, si es necesario;
direcciones guardadas, si se permite;
fecha de alta;
preferencias estrictamente necesarias.
Debe definirse si el cliente puede existir sin cuenta y cómo se vincula
con sus pedidos.
10.3 Producto
identificador;
código o SKU, si existe;
nombre;
descripción opcional;
categoría opcional;
unidad de venta;
precio vigente;
estado activo/inactivo;
referencia a la fuente de precio;
datos de disponibilidad solo si se cuenta con una fuente confiable.
10.4 Pedido
identificador único;
código legible;
cliente;
tienda de origen, si aplica;
modalidad;
estado;
fecha de creación y actualización;
usuario que lo registró;
lista de productos;
cantidades;
precio aplicado por línea;
subtotal, descuentos e impuestos solo cuando se hayan definido;
total;
dirección y referencias si es a domicilio;
observaciones operativas;
motivo de cancelación cuando corresponda;
historial de estados.
El pedido debe conservar el precio aplicado al confirmarse, conforme a
la política de precios, para que un cambio posterior en el catálogo no
altere silenciosamente pedidos históricos.
10.5 Detalle de pedido
identificador;
pedido;
producto;
descripción/nombre del producto al momento de la operación;
cantidad;
precio unitario aplicado;
subtotal de línea;
sustitución o faltante si se habilita.
10.6 Preparación
pedido;
responsable;
hora de inicio;
hora de finalización;
productos preparados;
incidencias;
observaciones.
10.7 Entrega y asignación
identificador de entrega;
pedido asociado;
repartidor asignado;
estado de la entrega;
fecha de asignación;
fecha de inicio;
intentos;
resultado;
motivo de fallo;
evidencia, si se aprueba;
fecha y hora de cierre.
La asignación debe tener historial para preservar reasignaciones y
varios intentos.
10.8 Dirección
identificador;
cliente o pedido;
dirección textual;
referencia;
distrito o zona si se necesita;
coordenadas solo si se obtienen de manera legítima y con precisión
adecuada;
indicaciones de acceso.
La dirección textual no debe convertirse automáticamente en coordenadas
sin validar el resultado. El usuario debe poder corregir el punto de
destino si la herramienta lo permite.
10.9 Pago --- solo si se incluye
identificador;
pedido;
importe;
moneda;
medio de pago;
estado;
referencia del proveedor;
fecha/hora;
resultado de validación.
No almacenar números completos de tarjeta ni códigos de seguridad. El
estado de pago debe proceder de una fuente confiable.
10.10 Auditoría
actor;
acción;
entidad afectada;
identificador de la entidad;
fecha/hora;
resultado;
motivo cuando sea necesario;
metadatos no sensibles.
La auditoría debe permitir reconstruir los cambios críticos sin
registrar secretos.
---
11. Reglas de negocio preliminares
Las siguientes reglas se proponen para validación:
Cada pedido tiene un identificador único.
Cada pedido tiene una modalidad de atención.
Los pedidos presenciales no requieren repartidor.
Los pedidos a domicilio requieren una dirección suficientemente
completa.
Solo usuarios autorizados pueden confirmar, cancelar o modificar
pedidos según su estado.
Un pedido debe estar listo antes de iniciar el reparto.
Un repartidor solo puede operar sobre entregas asignadas a su
cuenta.
Una reasignación conserva el historial de la asignación anterior.
Toda entrega fallida debe tener un motivo.
La aplicación no declara una entrega completada sin el evento de
confirmación definido.
Los precios y totales se validan en la fuente de autoridad del
sistema; el cliente móvil no es la autoridad final.
Si no hay integración real con inventario, la aplicación no promete
disponibilidad exacta.
Los pedidos cancelados y cerrados no se eliminan físicamente del
historial operativo ordinario.
Los cambios relevantes de estado registran actor y fecha/hora.
Los permisos se verifican en el servidor cuando exista backend.
Los errores de red no deben provocar pedidos o asignaciones
duplicadas.
Las modificaciones posteriores a la confirmación deben seguir una
política explícita.
Las operaciones monetarias deben utilizar una representación decimal
o entera apropiada, evitando errores de punto flotante.
El sistema debe distinguir pedido, pago, venta y comprobante.
La información visible a cada rol debe limitarse a lo necesario para
su tarea.
Estas reglas no sustituyen la validación del proceso real del negocio.
---
12. Geolocalización y rutas
12.1 Alcance inicial recomendado
Para el primer MVP, se recomienda que el repartidor pueda pulsar una
acción como "Abrir ruta", que envíe la dirección de destino a una
aplicación de mapas instalada. Esto evita construir prematuramente un
motor propio de navegación.
12.2 Funciones incluidas en esa propuesta
mostrar la dirección y referencia de entrega;
abrir una aplicación de mapas mediante un enlace compatible;
permitir al repartidor utilizar la navegación del proveedor elegido;
registrar el resultado de entrega desde la aplicación del proyecto.
12.3 Funciones que no se presumen incluidas
algoritmo propio de ruta óptima;
optimización simultánea de múltiples paradas;
seguimiento GPS continuo;
cálculo de tiempos garantizados;
asignación automática por distancia;
mapa integrado con actualización en tiempo real.
12.4 Decisiones pendientes
proveedor de mapas;
si se abrirá una aplicación externa o se mostrará un mapa dentro de
la app;
si se requieren coordenadas exactas;
si se permite reordenar entregas;
si el negocio necesita calcular distancias o tiempos para cobrar el
envío;
política de permisos de ubicación y retención de datos.
La navegación externa no garantiza que la dirección haya sido
geocodificada correctamente. El repartidor debe poder verificar el
destino antes de iniciar el recorrido.
---
13. UX/UI y navegación propuesta
La interfaz debe adaptarse al rol autenticado. No se recomienda mostrar
todos los módulos a todos los usuarios.
13.1 Estructura de navegación por rol
Administrador - Resumen - Pedidos - Entregas - Productos, si tiene
permiso - Usuarios y roles - Incidencias - Reportes - Configuración
autorizada
Operador de pedidos - Cola de pedidos - Nuevo pedido - Preparación -
Pedidos de la tienda - Incidencias - Perfil
Repartidor - Entregas asignadas - Detalle de entrega - Abrir ruta -
Historial de entregas - Incidencias - Perfil/disponibilidad, si se
implementa
Cliente - Inicio/catálogo - Búsqueda - Carrito o resumen de pedido -
Mis pedidos - Detalle/seguimiento - Perfil y direcciones, si se
habilitan
Estas son estructuras conceptuales; la navegación final se diseñará
después de validar el MVP.
13.2 Estados visuales obligatorios
Cada flujo relevante debe contemplar:
carga;
contenido disponible;
lista vacía;
error de conexión;
error de validación;
falta de permisos;
sesión vencida;
operación en proceso;
operación confirmada;
operación fallida;
confirmación antes de cancelar o reasignar.
13.3 Identidad visual
Se creará un sistema visual coherente y original. El uso de identidad
visual oficial de MASS dependerá de la autorización correspondiente. No
se presentará un diseño independiente como interfaz oficial de la
empresa.
---
14. Arquitectura técnica: criterios de selección
La arquitectura definitiva se aprobará después de confirmar quién crea
los pedidos, quién administra el catálogo, si habrá pagos, qué datos
deben sincronizarse y si el sistema será una app única o incluirá un
panel web.
14.1 Aplicación móvil
Flutter y Dart.
Material 3 como base, con un sistema visual propio.
Arquitectura organizada por funcionalidades.
Separación entre presentación, lógica de negocio y acceso a datos.
Una sola solución de gestión de estado, elegida según la complejidad
real.
Navegación declarativa si el número de flujos y permisos lo
justifica.
Validación centralizada de formularios y errores.
14.2 Backend
Un backend central es recomendable si varios usuarios deben compartir y
actualizar pedidos, roles, asignaciones e historial en tiempo real o
casi real. La app móvil no debe conectarse directamente a una base de
datos administrativa sin controles adecuados.
Alternativas a evaluar:
Supabase: puede acelerar autenticación, base de datos relacional
y políticas de acceso.
Firebase: puede ser adecuado si se prioriza un ecosistema
gestionado y sincronización, pero debe revisarse el modelado de
consultas, reglas y costos.
Backend propio con Laravel o NestJS: permite definir reglas y
API con mayor control, a cambio de mayor responsabilidad de
despliegue y mantenimiento.
No se selecciona definitivamente una alternativa en este documento. La
decisión requiere comparar costos, experiencia del equipo, reglas
transaccionales, seguridad, reportes, volumen esperado y necesidades de
integración.
14.3 Base de datos
Si se necesitan relaciones entre pedidos, productos, usuarios,
asignaciones e historial, una base de datos relacional puede simplificar
integridad y transacciones. PostgreSQL es una candidata a evaluar, no
una decisión ya tomada.
14.4 Panel administrativo
La administración completa puede ser poco eficiente en una pantalla
móvil. Se debe decidir si el administrador utilizará:
la misma app móvil con una interfaz adaptada;
una app móvil separada;
un panel web administrativo.
Para el MVP, evitar duplicar interfaces sin necesidad. Sin embargo, la
gestión masiva de usuarios, reportes y catálogo podría justificar un
panel web en una fase posterior.
14.5 Mapas y notificaciones
Se elegirán proveedores solo después de revisar disponibilidad, costos,
restricciones de uso, privacidad y compatibilidad. No incluir
credenciales privadas de proveedor en el código móvil.
---
15. Estrategia de pruebas y aceptación
15.1 Pruebas funcionales prioritarias
Inicio de sesión correcto e incorrecto.
Acceso denegado a funciones de otro rol.
Creación de pedido válido.
Rechazo de pedido con datos obligatorios incompletos.
Cálculo correcto de subtotales y total.
Registro de pedido presencial sin asignación de repartidor.
Registro de pedido a domicilio con dirección.
Inicio y finalización de preparación.
Bloqueo de asignación si el pedido no está listo.
Asignación a repartidor activo.
Reasignación con historial conservado.
Repartidor sin acceso a entregas de otro repartidor.
Apertura de ruta con dirección válida.
Registro de entrega exitosa.
Registro de intento fallido con motivo.
Cancelación permitida y denegada según estado.
Pérdida de conexión durante una operación.
Prevención de operaciones duplicadas por reintento.
Sesión vencida durante una operación.
Auditoría de cambios administrativos.
15.2 Pruebas técnicas
pruebas unitarias de reglas de negocio;
pruebas de widgets para estados de interfaz;
pruebas de integración de repositorios y API;
pruebas de navegación por rol;
pruebas de autorización en backend;
pruebas de concurrencia para asignación y modificación de pedidos;
pruebas de accesibilidad y tamaños de pantalla;
pruebas de rendimiento en dispositivos objetivo;
pruebas de seguridad y dependencias.
15.3 Criterios de aceptación del MVP
El MVP podrá considerarse aceptable cuando:
los cuatro perfiles aprobados puedan realizar sus tareas
autorizadas;
el flujo presencial no exija reparto;
el flujo a domicilio registre preparación, asignación, intento y
resultado;
los estados no puedan cambiarse de forma inválida;
un repartidor no pueda acceder a entregas ajenas;
el administrador pueda supervisar la operación definida;
el historial conserve las acciones críticas;
los importes se calculen de forma consistente;
los errores y falta de conexión se comuniquen correctamente;
los escenarios críticos tengan pruebas ejecutadas y resultados
documentados;
no existan defectos críticos abiertos sin una decisión explícita de
aceptación del riesgo.
---
16. Riesgos y mitigaciones
---
Riesgo                  Impacto                   Mitigación
---
No tener autorización   Legal y comercial         Tratar el proyecto como
para usar marca o                                 independiente hasta
sistemas de MASS                                  confirmar autorización.
No disponer de catálogo Pedidos incorrectos       Definir quién
o precios confiables                              administra los datos y
cuál es la fuente
autorizada.
No tener datos de       Faltantes y cancelaciones No prometer stock
inventario en tiempo                              confirmado; validar
real                                              disponibilidad en el
proceso operativo.
Mezclar pedido, pago,   Errores                   Modelar cada concepto
venta y comprobante     comerciales/tributarios   por separado y validar
requisitos antes de
integrar pagos.
Permisos solo en la     Acceso no autorizado      Validar roles y
interfaz                                          recursos en el backend.
Dirección incompleta o  Entregas fallidas         Validación de
geolocalización errónea                           dirección, referencias
y verificación del
destino.
Pérdida de conectividad Eventos no registrados o  Definir política
duplicados                offline, reintentos e
idempotencia.
Reasignaciones sin      Falta de trazabilidad     Registrar cada
historial                                         asignación como evento
o registro histórico.
Alcance excesivo en la  Retraso y defectos        Priorizar un MVP y
primera versión                                   mover funciones
avanzadas a fases
posteriores.
Gestión administrativa  Operación lenta           Evaluar panel web para
solo desde móvil                                  tareas masivas.
Recolección excesiva de Riesgo de privacidad      Minimización, control
datos personales                                  de acceso, retención
definida y política de
privacidad.
Optimización de rutas   Costos y retrasos         Comenzar con navegación
demasiado compleja                                externa y evaluar
optimización más
adelante.
---
17. Propuesta de MVP
El MVP debe probar el flujo central con el menor número de componentes
que permita una operación controlada.
17.1 MVP recomendado: operación asistida por personal
Para reducir incertidumbre, se recomienda empezar con un piloto donde el
operador registra el pedido y el cliente recibe la atención
presencial o la entrega a domicilio. El autoservicio completo del
cliente puede habilitarse después de validar el proceso, el catálogo,
los precios y la operación logística.
Incluido en el MVP recomendado:
autenticación;
roles y permisos;
gestión básica de usuarios internos;
catálogo básico administrado por un usuario autorizado;
registro de pedido por operador;
datos mínimos de cliente;
modalidad presencial o domicilio;
cálculo del resumen;
cola y estados de preparación;
asignación manual de repartidor;
vista de entregas asignadas;
apertura de navegación externa;
registro de entrega exitosa o fallida;
consulta de pedidos;
auditoría básica de cambios;
pruebas del flujo completo.
Sujeto a confirmación para el MVP:
creación de pedidos por el propio cliente;
pago digital;
cobro contra entrega;
caja y ventas presenciales;
comprobantes electrónicos;
inventario real;
notificaciones push;
evidencia fotográfica o firma;
soporte para múltiples tiendas;
panel web;
modo offline.
17.2 Fases posteriores posibles
Fase 2 --- Autoservicio del cliente - registro del cliente; -
catálogo público; - carrito; - pedidos desde el teléfono; - historial y
notificaciones.
Fase 3 --- Operación avanzada - gestión de varias tiendas; -
inventario integrado; - reportes avanzados; - panel web
administrativo; - indicadores por tienda y repartidor.
Fase 4 --- Logística avanzada - múltiples paradas; - optimización de
rutas; - ventanas horarias; - cálculo de costos de entrega; - ubicación
compartida solo si existe necesidad y base legal.
Fase 5 --- Integraciones - proveedor de pagos; - POS/ERP
autorizado; - comprobantes electrónicos, si corresponde; - sistemas
externos aprobados.
Las fases no implican compromiso de implementación; dependen de la
validación del negocio y del presupuesto.
---
18. Entregables de ingeniería
Antes de comenzar la implementación, el equipo debe mantener estos
artefactos:
Documento de alcance aprobado.
Mapa de actores y permisos.
Diagrama de flujo de pedidos presenciales.
Diagrama de flujo de entrega a domicilio.
Diagrama de estados y transiciones.
Historias de usuario y criterios de aceptación.
Matriz de requisitos funcionales y no funcionales.
Modelo conceptual de datos.
Decisión documentada de backend y base de datos.
Prototipo UX/UI validado.
Especificación de API, si corresponde.
Matriz de pruebas.
Plan de seguridad y privacidad.
Plan de despliegue y mantenimiento.
Registro de decisiones y riesgos.
---
19. Historias de usuario iniciales
Administrador
Como administrador, quiero ver los pedidos por estado para conocer
la carga operativa.
Como administrador, quiero habilitar o desactivar usuarios para
controlar el acceso.
Como administrador, quiero asignar un repartidor a un pedido listo
para despacho para organizar la entrega.
Como administrador, quiero revisar el historial de cambios para
investigar incidencias.
Como administrador, quiero filtrar pedidos por fecha y estado para
supervisar la operación.
Operador de pedidos
Como operador, quiero registrar un pedido con productos y cantidades
para iniciar su atención.
Como operador, quiero indicar si el pedido es presencial o a
domicilio para activar el flujo correcto.
Como operador, quiero marcar el inicio y fin de la preparación para
que el estado sea visible.
Como operador, quiero registrar un faltante para evitar entregar
información incorrecta.
Como operador autorizado, quiero asignar un repartidor cuando el
pedido esté listo para despacho.
Repartidor
Como repartidor, quiero ver mis entregas asignadas para organizar mi
trabajo.
Como repartidor, quiero abrir la dirección en un mapa para llegar al
destino.
Como repartidor, quiero registrar una entrega exitosa para cerrar el
intento.
Como repartidor, quiero registrar un intento fallido y su motivo
para que el equipo decida el siguiente paso.
Como repartidor, quiero reportar una incidencia para dejar
constancia de un problema.
Cliente
Estas historias solo se incluyen si se aprueba el canal de autoservicio.
Como cliente, quiero consultar los productos y precios disponibles
para decidir qué solicitar.
Como cliente, quiero confirmar un pedido con su resumen para conocer
lo que he solicitado.
Como cliente, quiero indicar mi dirección para recibir el pedido.
Como cliente, quiero consultar el estado de mi pedido para saber en
qué etapa se encuentra.
Como cliente, quiero cancelar un pedido cuando las reglas lo
permitan.
---
20. Decisiones pendientes que bloquean la arquitectura definitiva
Las siguientes decisiones deben resolverse con el responsable del
proyecto antes de cerrar la especificación.
20.1 Naturaleza y autorización
¿Es un prototipo académico, una solución independiente o un proyecto
autorizado por MASS?
¿Existe autorización para usar marca, logotipos, catálogo, precios o
sistemas internos?
¿La operación real de pedidos y reparto ya existe o la app propone
crearla?
20.2 Usuarios y canales
¿El cliente creará pedidos desde su propio teléfono o el operador
los registrará?
¿Los cuatro roles usarán la misma aplicación móvil con navegación
por rol?
¿El administrador necesita un panel web para gestión completa?
¿Habrá una sola tienda o varias?
20.3 Operación
¿Qué significa exactamente "registrar presencialmente": registrar un
pedido, registrar una venta cobrada o gestionar caja?
¿El operador cobrará? ¿Qué medios de pago se aceptan?
¿Se necesita pago anticipado, contra entrega o ambos?
¿Se emitirá comprobante? ¿Existe un sistema autorizado para ello?
¿Cómo se obtiene y actualiza el catálogo y el precio?
¿Existe inventario confiable que pueda consultarse?
¿Se permiten sustituciones, entregas parciales, devoluciones y
reintentos?
¿Quién puede cancelar un pedido y hasta qué estado?
20.4 Reparto y mapas
¿Los repartidores son empleados, contratistas o personal externo?
¿El repartidor puede aceptar o rechazar una asignación?
¿Se requiere evidencia de entrega? ¿Foto, firma, PIN o solo
confirmación?
¿Basta con abrir Google Maps u otra app externa, o se requiere mapa
integrado?
¿Un repartidor puede llevar varios pedidos en una misma ruta?
¿Se necesita ubicación GPS en tiempo real o solo navegación al
destino?
20.5 Tecnología, presupuesto y operación
¿Cuál es la versión mínima de Android?
¿Qué dispositivos se utilizarán y qué conectividad se espera?
¿La app debe seguir registrando operaciones sin conexión?
¿Existe un backend o base de datos previa que deba reutilizarse?
¿Cuál es el presupuesto y la fecha objetivo del MVP?
¿Dónde se alojará el backend y quién lo mantendrá?
¿Cómo se gestionarán soporte, copias de seguridad y recuperación
ante fallos?
---
21. Plan de trabajo propuesto
---
Etapa                   Actividades             Resultado para aprobar
---
0. Descubrimiento      Resolver decisiones     Alcance firmado o
pendientes y validar    aprobado
procesos
1. Diseño funcional    Historias, estados,     Especificación
permisos y criterios de funcional
aceptación
2. UX/UI               Flujos, wireframes y    Prototipo validado
prototipo
3. Diseño técnico      Arquitectura, datos,    Decisiones técnicas
API, seguridad y        documentadas
despliegue
4. Fundaciones         Proyecto Flutter,       Base funcional probada
autenticación y  
permisos
5. Pedidos y           Registro, detalle,      Flujo operativo probado
preparación             estados y cola de  
trabajo
6. Reparto             Asignación, navegación  Flujo de entrega
y resultado de entrega  probado
7. Administración      Usuarios, filtros,      Supervisión operativa
auditoría e indicadores probada
básicos
8. QA y piloto         Pruebas, correcciones y Informe de aceptación
validación con usuarios
9. Despliegue          Compilación,            Versión candidata para
configuración y         uso controlado
documentación
Las fechas y duraciones se definirán cuando se conozcan el equipo, el
presupuesto y el alcance aprobado.
---
22. Criterio de cierre de la fase de definición
La fase de definición no se considera terminada hasta que:
se confirme la naturaleza del proyecto y su autorización;
se determine si los clientes crean pedidos o si lo hace
exclusivamente el personal;
se acuerden los nombres y responsabilidades de los roles;
se apruebe la diferencia entre atención presencial y entrega a
domicilio;
se definan estados y transiciones;
se aprueben las reglas de cancelación, faltantes, reasignación y
entrega fallida;
se defina la fuente autorizada de catálogo y precios;
se determine si hay pagos, caja, comprobantes e inventario;
se apruebe el alcance del mapa y la ubicación;
se defina la estrategia de conectividad;
se priorice el MVP y se separen las funciones futuras;
se aprueben los criterios de aceptación y los riesgos.
---
23. Recomendación final de alcance
La recomendación inicial es construir primero un sistema de operación
de pedidos y entregas asistido por personal, con cuatro roles
conceptuales, pero habilitando en el MVP únicamente las funciones que se
confirmen necesarias. El flujo principal sería:
Operador registra pedido → prepara pedido → asigna repartidor si es a
domicilio → repartidor abre la ruta → registra resultado → administrador
supervisa el historial.
Para la atención presencial, el pedido debe poder cerrarse en tienda sin
asignar un repartidor.
El autoservicio del cliente, los pagos, el inventario en tiempo real,
los comprobantes, las notificaciones y la optimización avanzada de rutas
deben permanecer como decisiones explícitas hasta que se confirme la
necesidad y la disponibilidad de los sistemas requeridos.
La arquitectura final y el código deben comenzar únicamente después de
validar los puntos bloqueantes del apartado 20. Este documento es una
base detallada de definición, no una afirmación de que todas las
funciones ya estén aprobadas por el negocio.