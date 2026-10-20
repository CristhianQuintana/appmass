Especificación de seguridad integral --- App móvil MASS
Documento: SEC-MASS-MOBILE-001  
Versión: 1.0  
Fecha: 13/10/2026  
Estado: Especificación técnica para implementación y verificación  
Plataforma: Aplicación móvil Flutter/Dart, con compatibilidad mínima
prevista desde Android 8.1 (API 27), sujeta a validación de dependencias
y políticas vigentes  
Backend: Supabase Auth, PostgreSQL, Row Level Security (RLS),
Storage, Realtime y Edge Functions únicamente cuando el caso de uso lo
requiera  
Gestión de estado y navegación: Riverpod y `go_router`  
Objetivo: establecer controles de seguridad verificables para cada
módulo, pantalla, operación, dato y canal de comunicación de la
aplicación.
---
1. Propósito y criterio de seguridad
Este documento establece requisitos obligatorios para reducir la
probabilidad e impacto de accesos no autorizados, robo de sesiones,
abuso de privilegios, manipulación de pedidos, exposición de datos
personales, inyección, configuración insegura y vulnerabilidades de la
aplicación móvil.
Ninguna medida aislada garantiza que una aplicación sea
invulnerable. La seguridad se obtiene mediante defensa en profundidad,
validación del lado servidor, controles de acceso por registro, pruebas
negativas, revisión de código, gestión de secretos y respuesta a
incidentes. Ocultar botones o validar únicamente en Flutter no
constituye un control de autorización suficiente.
1.1 Principios obligatorios
Denegación por defecto: todo acceso no concedido explícitamente
se rechaza.
Mínimo privilegio: cada rol obtiene solo los permisos
indispensables.
Servidor como autoridad: el backend/base de datos decide
permisos, precios, estados y resultados finales.
Autorización por registro: no basta con validar que el usuario
inició sesión; debe comprobarse que puede acceder a ese pedido,
incidencia, archivo o perfil concreto.
Validación en capas: validar en interfaz para usabilidad y en
servidor/base de datos para seguridad.
Separación de entornos: desarrollo, pruebas y producción deben
tener proyectos/credenciales separados.
Secretos fuera del cliente: la app nunca contiene claves
privilegiadas, contraseñas de servicio ni secretos administrativos.
Trazabilidad sin exposición: registrar eventos de seguridad
útiles, evitando contraseñas, tokens y datos personales
innecesarios.
Errores seguros: no revelar consultas SQL, estructura interna,
tokens, claves ni trazas al usuario.
Privacidad por diseño: recopilar y mostrar únicamente los datos
necesarios para la operación autorizada.
Cambios verificables: políticas, funciones y esquema de base de
datos deben estar versionados y revisados.
Pruebas adversariales: comprobar expresamente que los accesos no
autorizados fallan.
1.2 Referencias de trabajo
Usar como marcos de referencia, verificando las versiones vigentes antes
de declarar conformidad:
OWASP MASVS y OWASP MASTG para seguridad de aplicaciones móviles.
OWASP ASVS como referencia complementaria para controles del
backend.
OWASP Top 10 y OWASP API Security Top 10 para riesgos web/API.
NIST SSDF para prácticas de desarrollo seguro.
Guías oficiales de Supabase sobre Auth, RLS, Storage, Edge Functions
y gestión de claves.
Políticas de privacidad y protección de datos que resulten
aplicables en Perú.
Este documento es una especificación de implementación; no declara
certificación formal con esos marcos.
---
2. Arquitectura de seguridad
2.1 Límites de confianza
---
Componente              Nivel de confianza      Responsabilidad de
seguridad
---
App Flutter instalada   No confiable            Presentar interfaz,
validar para usabilidad
y enviar solicitudes;
nunca decidir permisos
finales
Dispositivo Android     No confiable por        Puede estar rooteado,
defecto                 depurado, respaldado o
tener otras apps
capaces de observar
datos
Supabase Auth           Servicio de identidad   Verificar identidad y
gestionar sesión
PostgreSQL + RLS        Capa de datos protegida Aplicar acceso por
tabla y fila; imponer
integridad
Funciones del servidor  Capa de negocio         Validar identidad, rol,
/ Edge Functions        confiable solo si está  estado actual, reglas
correctamente           de negocio y
configurada             operaciones atómicas
GitHub/CI               Cadena de suministro    Revisar código,
ejecutar pruebas y
proteger secretos
Mapas externos          Servicio de tercero     Recibir solo el destino
mínimo necesario; no
enviar tokens ni datos
adicionales
2.2 Regla de acceso a datos
Flutter puede usar la clave pública/`anon` o publishable de Supabase
diseñada para cliente, siempre junto con RLS correctamente
configurado.
Nunca incluir `service_role`, claves secretas de API ni credenciales
de base de datos privilegiadas en el binario, `assets`,
`dart-define`, `.env` empaquetados, `local.properties`, logs o
repositorio.
Las operaciones sensibles ---cambiar roles, asignar/reasignar
pedidos, cambiar estados, cerrar entregas, administrar empleados y
acciones con varios pasos--- deben ejecutarse mediante funciones
confiables del servidor o transacciones SQL con permisos
cuidadosamente limitados.
Las políticas RLS deben mantenerse incluso si también se valida en
una Edge Function.
No exponer tablas ni vistas a roles públicos sin necesidad. Revisar
privilegios `GRANT`, vistas, funciones `SECURITY DEFINER`, esquemas
expuestos y permisos `EXECUTE`.
Si una función usa `SECURITY DEFINER`, fijar explícitamente un
`search_path` seguro, calificar objetos con esquema, revocar
`EXECUTE` a `PUBLIC` cuando no corresponda y revisar que no pueda
elevar privilegios indebidamente.
2.3 Roles de negocio propuestos
Roles recordados para el MVP:
Administrador: administra empleados, pedidos y clientes conforme
a permisos explícitos.
Operador de pedidos/preparación: registra y prepara pedidos y
realiza asignaciones autorizadas.
Transportista/repartidor: consulta pedidos asignados a sí mismo,
navega al destino autorizado y registra el resultado de entrega.
Cliente: solo debe recibir permisos si el alcance aprobado
contempla acceso de clientes. El MVP planificado no incluye pedidos
directos del cliente; no habilitar un portal o registro público de
clientes por defecto.
El nombre del rol en Flutter no es prueba de autorización. El rol y la
relación del usuario con cada registro deben verificarse en el
servidor/base de datos.
---
3. Matriz general de permisos
La matriz es un punto de partida que debe validarse con el responsable
del proceso. `Sí` significa que el rol puede ejecutar la operación
cuando se cumplen además las reglas de estado y relación con el
registro.
---
Recurso/acción         Administrador       Operador     Repartidor        Cliente
---
Iniciar/cerrar                    Sí             Sí             Sí     Solo si se
sesión                                                                   habilita
Consultar catálogo                Sí             Sí     Solo si es No por defecto
operativo                                                necesario
Crear pedido                      Sí             Sí             No  Fuera del MVP
Consultar todos los  Según necesidad    Solo ámbito             No             No
pedidos               administrativa     autorizado
Consultar pedidos      Según permiso  Según permiso             Sí             No
asignados propios
Cambiar estado de      Según permiso             Sí             No             No
preparación
Asignar/reasignar      Según permiso      Sí, si se             No             No
repartidor                                  aprueba
Abrir destino de     Según necesidad          Según   Solo pedidos             No
reparto                                   necesidad      asignados
Registrar resultado       Solo si el    Según regla    Solo pedido             No
de entrega                proceso lo       aprobada     asignado y
autoriza                 estado válido
Gestionar                    Sí, con             No             No             No
usuarios/roles             controles  
reforzados
Consultar auditoría     Solo permiso No por defecto No por defecto             No
específico
Cambiar                         Solo             No             No             No
configuración          administrador  
sensible                     técnico  
autorizado
Regla: evitar un rol genérico `admin` con acceso irrestricto si no
es necesario. Separar administración operativa de administración técnica
cuando la organización lo permita.
---
4. Seguridad del inicio de sesión y recuperación de cuenta
4.1 Pantalla de inicio de sesión
Requisitos obligatorios
Autenticación exclusivamente mediante TLS/HTTPS; no permitir HTTP
para APIs o callbacks propios.
Usar Supabase Auth u otro proveedor aprobado; no crear un sistema
artesanal de almacenamiento de contraseñas en Flutter.
No almacenar ni registrar contraseñas en preferencias, archivos,
base de datos local, analytics, crash reports o logs.
Usar campos con semántica correcta: email/usuario según política,
contraseña oculta y opción de mostrarla controlada por el usuario.
Deshabilitar el botón mientras se envía la solicitud; prevenir
envíos simultáneos.
Validar formato y campos vacíos en la interfaz, pero dejar la
validación definitiva al proveedor.
Mostrar mensajes genéricos que no permitan enumerar cuentas, por
ejemplo: "No se pudo iniciar sesión con los datos proporcionados".
No revelar si una cuenta existe, está deshabilitada o tiene un rol
específico.
Limitar intentos abusivos mediante controles del proveedor, reglas
de backend y, si se implementa, rate limiting en una capa confiable.
No depender solo de un contador local.
No bloquear permanentemente una cuenta solo por fallos repetidos que
un atacante podría provocar; usar throttling temporal, detección y
recuperación controlada.
No implementar CAPTCHA propio como única defensa. Si se requiere
desafío antibot, integrarlo de forma soportada y verificarlo del
lado servidor.
Aplicar MFA a administradores y a otras cuentas de alto privilegio
cuando el proveedor, la operación y la política de la organización
lo permitan. La activación debe probarse en todo el flujo de sesión
y recuperación.
El registro público debe estar deshabilitado por defecto para una
app interna/operativa. Las cuentas de personal deben crearse
mediante un flujo administrativo autorizado.
No conceder un rol por un parámetro enviado desde Flutter, por un
formulario público ni por metadata editable por el usuario.
Tras iniciar sesión, recuperar el perfil y los permisos desde una
fuente confiable; si no se puede determinar el rol, denegar las
operaciones protegidas.
No permitir que un error de carga del perfil convierta al usuario en
administrador ni deje accesos protegidos habilitados.
Evitar conservar el contenido de la contraseña al navegar o al
volver de segundo plano.
No incluir correo, contraseña, token o respuesta de autenticación en
mensajes de depuración.
Criterios de aceptación
Credenciales incorrectas no dan acceso y no revelan si la cuenta
existe.
La navegación a pantallas protegidas sin sesión redirige al acceso.
Un usuario autenticado sin perfil/rol válido no obtiene permisos por
defecto.
No hay secretos privilegiados dentro del paquete de la aplicación.
Las pruebas comprueban envío repetido, error de red, cuenta no
autorizada y sesión inválida.
4.2 Política de contraseñas
La política debe definirse en Supabase Auth y ser consistente con la
política organizacional:
Preferir contraseñas largas y únicas; permitir gestores de
contraseñas y pegado seguro.
Establecer una longitud mínima apropiada conforme a la política
vigente del proveedor y el riesgo de la aplicación; evitar reglas
arbitrarias de composición que empeoren usabilidad sin beneficio.
Rechazar contraseñas comunes o comprometidas si el proveedor/plan lo
soporta.
No forzar cambios periódicos sin indicio de compromiso o exigencia
normativa; sí exigir cambio al detectar exposición o credencial
temporal.
No mostrar ni enviar contraseñas por correo o mensajería.
Nunca almacenar contraseña en texto plano ni diseñar hashes en el
cliente.
No compartir una cuenta entre operadores o repartidores.
4.3 Recuperación de contraseña
Respuesta genérica para evitar enumeración de usuarios.
Enlace de recuperación de un solo uso, con caducidad y destino
permitido en una lista explícita.
Validar dominio, esquema y ruta de retorno; evitar open redirects.
Al cambiar la contraseña, invalidar o renovar sesiones según la
capacidad configurada del proveedor y documentar el comportamiento.
No registrar tokens de recuperación en logs, analytics o capturas de
error.
No aceptar un cambio de contraseña por un endpoint que confíe solo
en el ID de usuario enviado por el cliente.
Mostrar confirmación genérica de solicitud, no confirmar existencia
de cuenta.
Probar enlaces expirados, usados, manipulados y abiertos desde otra
sesión.
4.4 Cierre de sesión, expiración y cambio de rol
Cerrar la sesión en el proveedor y limpiar estado sensible en
memoria.
Borrar caches locales de datos sensibles al cerrar sesión o cambiar
de usuario.
Proteger el router para que volver con el botón Android no exponga
una pantalla autenticada.
Responder a expiración/revocación de sesión de forma segura; no
continuar operaciones protegidas usando datos cacheados como si
estuvieran autorizados.
Volver a consultar permisos después de cambios de rol o eventos
relevantes.
Al deshabilitar una cuenta, impedir nuevas operaciones y revocar
sesiones/tokens según las capacidades del proveedor.
Probar que un usuario cuyo rol cambió no conserva permisos
privilegiados en una sesión antigua.
---
5. Gestión de sesión y almacenamiento en el dispositivo
Usar el mecanismo de persistencia de sesión soportado por el SDK
oficial de Supabase para Flutter y validar su comportamiento en la
versión elegida.
No implementar criptografía propia ni crear formatos de token
propios.
Evaluar almacenamiento seguro respaldado por Android Keystore para
cualquier secreto local que realmente necesite persistencia. No
guardar secretos en `SharedPreferences` sin protección.
No guardar datos sensibles de pedidos, direcciones, incidencias o
perfiles en almacenamiento persistente local salvo necesidad
documentada.
Si se requiere caché, definir campos permitidos, tiempo de vida,
cifrado cuando corresponda y política de eliminación.
No asumir que ofuscar el APK protege los secretos. La ofuscación no
sustituye controles del servidor.
Desactivar backups de datos sensibles cuando corresponda y verificar
`AndroidManifest.xml`, reglas de backup y comportamiento en
versiones objetivo.
No escribir tokens en logs, excepciones, mensajes de error, capturas
ni nombres de archivos.
Limpiar datos en memoria y caché al cerrar sesión, cambiar de cuenta
o recibir una revocación.
No copiar direcciones, teléfonos ni datos del pedido al portapapeles
automáticamente.
No almacenar respuestas completas de APIs si solo se requieren
algunos campos.
Evaluar si la app necesita funcionar offline; el MVP no debe
permitir mutaciones críticas offline sin una estrategia de
sincronización, autorización y conflictos explícitamente diseñada.
Prueba: extraer una copia de los archivos de la app en un
dispositivo/emulador de pruebas y verificar que no haya credenciales
privilegiadas ni datos sensibles persistidos sin justificación.
---
6. Autorización, perfiles y administración de usuarios
6.1 Perfil
El ID de perfil debe relacionarse con el identificador de identidad
autenticada, no con un ID arbitrario proporcionado por Flutter.
El usuario solo puede leer y editar los campos de su perfil
expresamente autorizados.
El usuario no puede editar su propio rol, estado de habilitación,
permisos, identificador de Auth ni campos de auditoría.
Cambios de rol solo mediante un flujo administrativo del servidor,
con autorización reforzada y registro de auditoría.
Si no existe perfil, el sistema debe denegar operaciones de negocio
hasta que se resuelva el estado.
Limitar datos personales a los necesarios para operar.
6.2 Administración de empleados
Solo administradores autorizados pueden crear/deshabilitar cuentas
de personal.
La operación privilegiada debe ejecutarse en backend seguro, nunca
con `service_role` desde Flutter.
Validar el rol que puede asignarse y evitar escalamiento de
privilegios.
No permitir que un administrador operativo se conceda permisos
técnicos si esa separación se requiere.
Confirmar acciones destructivas o de impacto alto.
Registrar actor, objetivo, acción, fecha y resultado; evitar
registrar contraseñas o tokens.
Deshabilitar usuarios sin borrar la evidencia histórica necesaria
para la integridad de pedidos.
Probar intento de crear un administrador desde un usuario operador o
repartidor.
---
7. Seguridad de navegación y protección de rutas
Para `go_router`:
Definir rutas públicas y protegidas explícitamente.
Usar redirecciones basadas en el estado de autenticación y carga del
perfil.
No usar la ruta oculta o la falta de un botón como mecanismo de
autorización.
Al abrir una deep link, validar sesión, rol, formato e identificador
de recurso.
No permitir que una URL externa fuerce navegación a una pantalla
privilegiada sin verificación.
Evitar incluir tokens, contraseñas, datos personales o información
sensible en query parameters.
Validar todos los argumentos de navegación; un ID manipulado debe
terminar en acceso denegado, no en datos de otro usuario.
Evitar loops de redirección cuando la sesión expira o el perfil
falla.
Probar acceso directo a cada ruta protegida sin autenticación y con
cada rol.
En acciones protegidas, verificar permiso en el servidor incluso si
el router ya filtró la ruta.
Pruebas mínimas: acceso anónimo a cada pantalla, usuario de rol
incorrecto, ID de pedido ajeno, sesión expirada, deep link manipulado y
navegación atrás después de cerrar sesión.
---
8. Seguridad por interfaz y módulo
Las reglas de esta sección se aplican además de los controles generales
de autenticación, autorización, almacenamiento y backend.
8.1 Inicio / splash / carga inicial
No mostrar datos de un usuario anterior mientras se resuelve la
sesión actual.
Mantener una pantalla de carga neutra hasta determinar autenticación
y permisos.
Si falla la consulta del perfil, no permitir acceso temporal a
pantallas privilegiadas.
No registrar tokens ni datos de sesión.
No iniciar consultas de pedidos antes de validar la sesión.
Al cambiar de cuenta, descartar estados Riverpod y cachés que
contengan información del usuario anterior.
8.2 Inicio de sesión
Aplicar todos los requisitos de la sección 4. Además:
No autocompletar contraseñas en campos o formularios no seguros.
Marcar correctamente el campo como contraseña y evitar que se
muestre en texto claro por defecto.
Deshabilitar captura de pantalla solo si el riesgo y el flujo lo
justifican; no usarla como sustituto de controles de backend.
Limitar intentos de solicitud en la interfaz para evitar errores
accidentales, sin confiar en ese límite para frenar ataques.
Mantener mensajes accesibles y no enumerables.
8.3 Recuperación y cambio de contraseña
No mostrar la contraseña actual o nueva en logs.
Validar el token de recuperación en el proveedor.
No permitir que el parámetro de retorno redirija a un dominio
arbitrario.
Exigir confirmación y manejar caducidad de enlace.
Invalidar datos sensibles de la sesión cuando corresponda.
Probar token expirado, token reutilizado y usuario no autenticado.
8.4 Dashboard / inicio por rol
Consultar únicamente los indicadores necesarios para el rol.
Los totales deben calcularse en consultas o funciones autorizadas
del servidor; no confiar en filtros locales para privacidad.
No incluir información personal en notificaciones locales, analytics
o logs.
Aplicar límites de filas y paginación a listados.
No presentar información de pedidos ajenos por un fallo temporal de
filtros.
Mostrar errores genéricos y permitir recargar de forma segura.
8.5 Catálogo y búsqueda
El catálogo se debe leer desde una fuente autorizada y mediante RLS.
Tratar nombre, descripción, código y búsqueda como entradas no
confiables.
Usar consultas parametrizadas mediante el SDK; no concatenar texto
de usuario para construir SQL.
Limitar longitud de búsqueda y resultados; evitar consultas costosas
sin límite.
No permitir que el cliente modifique precio, disponibilidad o campos
administrativos si el rol es de solo lectura.
Los precios usados al crear el pedido deben validarse/recalcularse
en el servidor.
No confiar en el precio enviado por el cliente.
Mostrar solo productos y atributos que el rol puede consultar.
Manejar productos eliminados o deshabilitados sin romper el registro
del pedido.
Probar búsquedas vacías, caracteres especiales, texto muy largo y
respuestas con datos incompletos.
8.6 Selección de productos y resumen del pedido
Validar cantidad positiva, límites razonables y tipo numérico.
Impedir pedido vacío.
Calcular subtotales para presentación, pero volver a
calcular/validar los importes definitivos en el servidor.
Usar tipos decimales apropiados en PostgreSQL para dinero; no usar
`double`/coma flotante como fuente autoritativa de importes.
No aceptar descuentos, impuestos o precio total enviados por el
cliente como datos confiables.
Prevenir toques repetidos y solicitudes duplicadas.
Evitar que cambiar la cantidad de un producto afecte otra línea por
error.
Mantener un borrador local solo durante el tiempo necesario y
limpiarlo al cerrar sesión.
No mostrar datos de un pedido anterior al iniciar un pedido nuevo.
Si el precio cambió entre selección y confirmación, aplicar la regla
del negocio aprobada y mostrar el resultado antes de guardar.
8.7 Registro de pedido
El servidor debe validar sesión, rol, productos, cantidades,
disponibilidad autorizada, precios y reglas de estado.
El servidor debe asignar el usuario creador desde la identidad
verificada, no desde un campo de Flutter.
Guardar cabecera y líneas como una única operación atómica; evitar
pedidos sin detalles o detalles huérfanos.
Asignar ID, estado inicial y fechas desde un componente confiable.
Usar idempotencia o un mecanismo equivalente para reintentos cuando
la red se interrumpa y la app no sepa si la operación se completó.
No aceptar del cliente campos protegidos como `created_by`,
`status`, `total`, `assigned_to`, `delivered_at` o datos de
auditoría sin validación del servidor.
Mostrar éxito solo tras confirmación real del backend.
Si el registro falla, preservar el borrador de manera segura y
explicar si es seguro reintentar.
Probar cantidades negativas, producto inexistente, usuario sin rol,
precio alterado, pedido vacío, envío duplicado y fallo parcial.
8.8 Lista de pedidos
Filtrar por rol y ámbito en el servidor; no descargar todos los
pedidos y ocultar los ajenos en Flutter.
Aplicar RLS a cada consulta.
Usar paginación/límites y orden estable.
Seleccionar solo columnas necesarias.
No mostrar dirección, teléfono o detalles de entrega a roles que no
los necesitan.
Al abrir un pedido, revalidar acceso en la consulta del detalle.
Tratar un ID manipulado como un intento normal de acceso no
autorizado: denegar sin revelar si el pedido existe.
Refrescar datos tras cambios de estado y gestionar datos obsoletos.
Evitar caché compartida entre cuentas o roles.
Probar lectura de pedidos ajenos, ID inexistente, página vacía y
cambio de rol.
8.9 Detalle del pedido
Consultar el pedido y sus líneas con autorización en el servidor.
Verificar que el usuario puede acceder a ese registro específico.
No confiar en el ID enviado por la ruta.
Mostrar solo campos necesarios.
No habilitar botones solo por estado local: el servidor debe
comprobar el estado actual.
Manejar pedidos eliminados, archivados o cambiados por otro usuario.
Evitar exponer detalles sensibles en capturas de error o logs.
Probar ID alterado, pedido no autorizado, sesión expirada y datos
incompletos.
8.10 Preparación y cambios de estado
Definir una máquina de estados permitida y validarla con el negocio.
El servidor debe validar estado actual, nuevo estado, rol y
precondiciones de cada transición.
Rechazar saltos de estado y actualizaciones arbitrarias.
Ejecutar cada transición de forma atómica.
No confiar en el estado que muestra la interfaz; consultar el estado
vigente al guardar.
Registrar actor y fecha desde el servidor.
Evitar que un operador cambie directamente campos no relacionados.
Controlar concurrencia: si otro usuario cambió el pedido, rechazar
el cambio obsoleto y refrescar.
Evitar duplicar registros de auditoría por reintentos.
Probar todas las transiciones válidas e inválidas, además de usuario
sin permiso y dos cambios simultáneos.
8.11 Asignación y reasignación de repartidor
Solo roles autorizados pueden asignar.
Solo usuarios con rol y estado de repartidor habilitado pueden
recibir pedidos.
Validar que el pedido se encuentre en estado asignable.
Verificar asignación actual dentro de la misma operación de
escritura.
No permitir que un repartidor se asigne a sí mismo pedidos mediante
modificación directa de parámetros.
Registrar quién asignó, a quién, cuándo y, si se permite, motivo de
reasignación.
La política de reasignación debe estar explícitamente aprobada.
Aplicar RLS para impedir que repartidores consulten pedidos
asignados a otras personas.
Probar asignación a usuario inactivo, pedido no listo, conflicto
concurrente y acceso a asignación ajena.
8.12 Vista del repartidor / pedidos asignados
La consulta debe derivar la identidad del repartidor desde la sesión
verificada.
No aceptar un `driver_id` libre del cliente como autoridad para
listar pedidos.
Filtrar en el servidor y aplicar RLS.
Mostrar solo pedidos asignados a ese repartidor, salvo una excepción
aprobada.
No guardar permanentemente direcciones o teléfonos sin necesidad.
Si la asignación cambia, dejar de mostrar el pedido cuando el
servidor lo indique.
Probar que cambiar el ID de usuario en una solicitud no revela
pedidos de otro repartidor.
8.13 Dirección y navegación externa
Mostrar datos de destino solo al personal autorizado y durante el
tiempo necesario.
Validar y codificar direcciones/coordenadas antes de construir el
enlace.
Permitir únicamente esquemas y destinos de URL esperados; no abrir
URLs arbitrarias recibidas de la base de datos sin validación.
No incluir tokens, credenciales ni otros datos personales en la URL.
Minimizar datos enviados al proveedor de mapas externo.
No pedir permiso de ubicación del dispositivo si solo se abre
navegación externa al destino y no se necesita la ubicación propia.
No implementar rastreo GPS en tiempo real dentro del MVP.
Tratar el enlace de mapas como contenido externo y usar mecanismos
de apertura seguros.
Si el destino está incompleto, no generar un enlace engañoso;
mostrar un error y permitir que personal autorizado corrija el dato.
Probar direcciones con caracteres especiales, destino vacío y
ausencia de aplicación compatible.
8.14 Registrar entrega completada
Solo el repartidor asignado o un rol explícitamente autorizado puede
registrar el resultado.
Verificar estado actual y asignación en el servidor.
No aceptar un `delivered_by`, `delivered_at` o estado final
arbitrario desde el cliente.
Generar fecha y actor desde el servidor.
Hacer la operación atómica e idempotente.
Evitar que un pedido ya cerrado se cierre de nuevo sin una regla
aprobada.
No afirmar entrega exitosa si la solicitud falla o queda en estado
incierto.
Mostrar confirmación solo después de recibir el resultado
autoritativo.
Probar pedido no asignado, estado inválido, solicitud duplicada y
cambio concurrente.
8.15 Registrar entrega fallida e incidencias
Usar un catálogo controlado de motivos aprobado por el negocio.
Validar en servidor que el motivo existe y está permitido.
Aplicar límites de longitud al comentario opcional.
Evitar solicitar información personal excesiva o contenido sensible
no necesario.
Escapar y presentar texto de forma segura; no interpretar
comentarios como HTML o código.
No permitir que un comentario libre determine por sí solo un cambio
de rol, estado o decisión privilegiada.
Registrar actor y fecha en el servidor.
Definir explícitamente qué pasa después de una entrega fallida; no
reasignar ni reprogramar automáticamente sin regla aprobada.
Limitar quién puede consultar las incidencias.
Probar motivo omitido, motivo inválido, comentario demasiado largo,
acceso no autorizado y reintento duplicado.
8.16 Administración de clientes y empleados
Restringir la pantalla a los roles administrativos aprobados.
No usar un rol guardado únicamente en el dispositivo.
Las altas, bajas, cambios de rol y deshabilitaciones se ejecutan en
el servidor.
Confirmar las acciones sensibles y mostrar claramente el usuario
objetivo.
Exigir reautenticación o MFA para operaciones de alto impacto si el
proveedor y la política lo permiten.
Prevenir que el administrador cambie su propio rol a uno más
privilegiado a través de una petición manipulada.
Registrar auditoría de cambios administrativos.
No borrar en cascada pedidos e incidencias históricas por eliminar
un perfil; usar deshabilitación o referencias controladas.
No revelar contraseñas temporales en logs ni mostrarlas nuevamente
tras crearlas.
Probar escalamiento de privilegios, deshabilitación de cuenta y
modificación de usuario no autorizado.
8.17 Pantalla de auditoría (si se incluye)
Acceso exclusivo a roles autorizados.
Consultas paginadas y con límite temporal.
No incluir contraseñas, tokens, claves, cabeceras de autorización ni
cuerpos completos de solicitudes.
Registrar eventos útiles: fallos de autenticación agregados,
denegaciones relevantes, cambios de rol, asignaciones y transiciones
de estado.
Evitar registrar más datos personales de los necesarios.
Proteger los registros frente a modificación por usuarios
ordinarios.
Definir retención y acceso de acuerdo con la política
organizacional.
No mostrar trazas internas completas en la interfaz móvil.
8.18 Ajustes y configuración
No exponer configuración técnica sensible en una pantalla accesible
al usuario común.
Las funciones administrativas requieren autorización del servidor.
No permitir cambiar endpoint, claves, políticas o entorno de
producción desde controles ordinarios de la app.
Separar configuración por entorno y validar valores al iniciar.
Fallar de forma segura si la configuración es inválida.
No almacenar secretos administrativos en la base de datos de
configuración accesible al cliente.
8.19 Errores, diálogos y notificaciones
Mensajes para el usuario breves y sin datos internos.
Detalles técnicos solo en registros controlados y sanitizados.
No incluir tokens, contraseñas, direcciones completas ni información
de pedido en notificaciones de pantalla bloqueada si no es
necesario.
Confirmar acciones irreversibles o de alto impacto.
No usar un diálogo como único control de autorización.
Evitar que excepciones sin capturar muestren contenido sensible.
Probar errores de red, timeout, sesión expirada y permisos
denegados.
---
9. Seguridad de Supabase y PostgreSQL
9.1 RLS obligatoria
Para cada tabla expuesta al cliente:
Habilitar RLS.
Definir políticas explícitas para `SELECT`, `INSERT`, `UPDATE` y
`DELETE`; no asumir que una política de lectura protege las
escrituras.
Usar `auth.uid()` para vincular el registro con el usuario
autenticado cuando aplique.
Para pedidos y asignaciones, comprobar rol, relación del usuario con
el pedido y estado actual.
No confiar en campos enviados por el cliente para probar su propio
rol.
Revisar políticas `USING` y `WITH CHECK` para que una actualización
no permita cambiar un registro hacia un propietario o estado no
autorizado.
Probar las políticas con usuarios reales de prueba de cada rol.
Verificar vistas, funciones y tablas relacionadas que puedan filtrar
datos indirectamente.
Revocar privilegios innecesarios y revisar `GRANT` a roles de
Postgres.
Versionar cada cambio de política mediante migraciones.
9.2 Modelo de datos y restricciones
Usar claves foráneas, `NOT NULL`, `CHECK` y restricciones únicas
donde corresponda.
Restringir estados a valores válidos.
Usar tipos numéricos apropiados para importes.
Definir reglas de borrado para proteger la integridad histórica.
No confiar solo en validaciones Dart.
Usar transacciones para registrar pedidos y detalles o para ejecutar
cambios de estado con varias escrituras.
Definir índices necesarios para consultas autorizadas sin permitir
listados ilimitados.
Evitar errores que permitan enumerar IDs secuenciales si eso expone
información; de todas formas, IDs no predecibles no sustituyen RLS.
9.3 Funciones SQL / RPC / Edge Functions
Verificar identidad y autorización en cada operación.
Validar todos los parámetros y limitar tamaños.
Ejecutar operaciones sensibles de forma atómica.
No confiar en rol, usuario, total, estado ni marca temporal enviados
por el cliente.
Restringir `EXECUTE` a los roles necesarios.
Para `SECURITY DEFINER`, revisar `search_path`, permisos,
referencias calificadas y exposición.
No registrar secretos o datos completos de solicitudes.
Aplicar límites y controles de abuso adecuados.
Probar invocación sin sesión, con rol incorrecto, parámetros
malformados y recurso ajeno.
9.4 Storage
Si se usa Supabase Storage:
Mantener buckets privados por defecto para documentos o archivos no
públicos.
Definir políticas de lectura/escritura por rol y relación con el
pedido.
No confiar en el nombre del archivo para decidir permisos.
Validar tamaño, extensión y tipo de contenido en servidor cuando se
acepten archivos.
Generar nombres internos no controlados directamente por el usuario
y evitar sobrescrituras indebidas.
Usar URLs firmadas con expiración para accesos temporales, si
corresponde.
No incluir información sensible en metadatos o nombres.
Eliminar archivos de prueba y definir retención.
Si el MVP no requiere archivos, no habilitar carga por anticipado.
9.5 Realtime
Si se habilita Supabase Realtime:
Suscribirse solo a tablas/canales necesarios.
Verificar las políticas de acceso y filtrado aplicables.
No transmitir eventos con datos personales a canales públicos.
No confiar en el evento recibido como autoridad final; refrescar el
registro desde una consulta autorizada cuando sea necesario.
Desuscribirse al cerrar sesión o abandonar el contexto.
Probar que un repartidor no recibe cambios de pedidos de otros
repartidores.
---
10. Seguridad del dispositivo y Android
Solicitar únicamente permisos Android necesarios para las funciones
actuales.
No solicitar contactos, SMS, micrófono, cámara o ubicación si no
existe una función aprobada que lo requiera.
Revisar `AndroidManifest.xml` y eliminar permisos heredados no
utilizados.
Usar HTTPS y no habilitar tráfico HTTP en claro para APIs.
No desactivar validación de certificados TLS en producción ni
aceptar todos los certificados.
No instalar certificados de confianza personalizados sin necesidad y
revisión.
Evaluar configuración de backups y extracción de datos sensibles.
Revisar deep links e intent filters para que no acepten destinos
arbitrarios.
Usar versiones estables y compatibles de Flutter, Dart y plugins;
registrar versiones exactas en el repositorio.
Evaluar protección contra ingeniería inversa como defensa
complementaria, sin tratarla como barrera principal.
No confiar en detección de root/emulador para autorizar acceso:
puede usarse como señal de riesgo, no como control central.
No implementar certificate pinning sin una estrategia de rotación y
recuperación; una implementación rígida mal gestionada puede dejar
la app sin conexión.
No prometer bloqueo absoluto de capturas de pantalla; el control de
exposición principal debe estar en los datos que se entregan al
dispositivo.
Probar en el Android mínimo admitido y en versiones representativas
actuales.
---
11. Protección de APIs y defensa contra abuso
Toda operación de negocio debe exigir sesión válida salvo que se
documente expresamente como pública.
Validar formato, tamaño, tipo y rango de cada parámetro.
Limitar filas devueltas y evitar endpoints que permitan extracción
masiva.
Aplicar rate limiting donde exista una capa de servidor adecuada;
considerar límites para login, recuperación, creación de pedidos y
operaciones administrativas.
Evitar consultas arbitrarias o filtros que permitan leer recursos
ajenos.
No crear endpoints que acepten nombres de tabla, SQL o nombres de
función enviados libremente por el cliente.
Verificar permisos por objeto para prevenir IDOR/BOLA.
No confiar en controles de interfaz, identificadores opacos ni
valores del dispositivo.
Manejar errores de forma uniforme, sin revelar existencia de
registros protegidos.
Probar repetición de solicitudes, parámetros alterados, enumeración,
acceso horizontal entre usuarios y escalamiento vertical entre
roles.
---
12. Protección de datos y privacidad
Inventariar qué datos personales se almacenan y por qué.
Mostrar dirección y contacto solo a roles que lo necesitan para
cumplir la operación.
Definir retención y borrado/anonimización cuando corresponda,
preservando registros que deban mantenerse por obligación legítima.
Evitar copiar datos de pedidos a analytics, herramientas de crash
reporting o servicios externos sin evaluación y autorización.
No usar datos reales en pruebas salvo aprobación y controles
específicos.
Restringir accesos a bases de datos y exportaciones.
No usar información real de clientes en capturas de pantalla o
documentos de desarrollo.
Documentar qué datos recibe un proveedor de mapas al abrir una
navegación.
Aplicar los requisitos de protección de datos personales vigentes en
Perú y las políticas de la organización; solicitar revisión legal si
el uso real lo requiere.
---
13. Registro, monitoreo y respuesta a incidentes
13.1 Eventos que deben poder investigarse
Fallos repetidos de autenticación de forma agregada.
Intentos de acceso denegado relevantes.
Cambios de roles y deshabilitación de cuentas.
Creación de pedidos y cambios operativos críticos.
Asignaciones y reasignaciones.
Resultados de entrega e incidencias.
Cambios de políticas, funciones o configuración realizados por
personal autorizado.
13.2 Qué nunca registrar
Contraseñas.
Tokens de acceso/refresh o enlaces completos de recuperación.
Claves secretas o `service_role`.
Cabeceras `Authorization`.
Datos personales completos sin necesidad operativa.
Cuerpos completos de solicitudes si pueden contener credenciales o
información sensible.
13.3 Respuesta mínima a incidentes
Registrar hora, sistema, entorno, evento y responsable que lo
detectó.
Evaluar alcance: cuenta, pedido, datos o entorno afectado.
Revocar sesiones/credenciales comprometidas y rotar secretos cuando
corresponda.
Restringir temporalmente la operación vulnerable si existe riesgo
activo.
Preservar evidencias necesarias con acceso limitado.
Corregir causa raíz y desplegar mediante proceso revisado.
Repetir las pruebas que reprodujeron el problema.
Documentar impacto, medidas adoptadas y acciones preventivas.
Evaluar obligaciones de notificación conforme a la política y
normativa aplicable.
---
14. Seguridad del ciclo de desarrollo y CI/CD
Proteger la rama principal con revisión de Pull Request.
No permitir que una sola persona apruebe y despliegue cambios
críticos sin el control definido por el equipo.
Ejecutar `flutter analyze` y pruebas en CI.
Añadir análisis de dependencias y búsqueda de secretos al flujo de
CI cuando sea viable.
Revisar cambios de `pubspec.lock`, plugins nativos, permisos y
scripts de build.
Mantener dependencias actualizadas con cambios controlados y pruebas
de regresión.
No incluir `.env`, claves, certificados privados ni dumps de base de
datos en Git.
Guardar secretos de CI en el gestor de secretos del proveedor, no en
variables versionadas.
Usar migraciones de base de datos versionadas y revisadas.
Separar proyectos/credenciales de desarrollo, prueba y producción.
Restringir quién puede desplegar funciones, cambiar políticas RLS o
acceder a secretos.
Revisar artefactos finales y configuración de build antes de
distribuirlos.
Mantener un inventario de dependencias y un proceso de actualización
ante vulnerabilidades.
No aceptar una excepción de seguridad sin riesgo, responsable, plazo
y aprobación documentados.
---
15. Pruebas de seguridad obligatorias
Las pruebas deben ejecutarse únicamente en entornos propios o
expresamente autorizados. No hacer pruebas intrusivas sobre sistemas
reales de MASS ni sobre datos de clientes sin autorización escrita.
15.1 Pruebas por rol
Sin sesión: no puede consultar pedidos ni ejecutar operaciones
privadas.
Cliente (si se habilita): no obtiene acceso a funciones internas.
Operador: puede ejecutar operaciones operativas permitidas, pero no
administrar roles.
Repartidor: solo consulta y actualiza pedidos asignados y estados
permitidos.
Administrador: puede ejecutar acciones administrativas aprobadas,
pero las operaciones quedan auditadas.
Usuario deshabilitado: no puede continuar realizando operaciones
protegidas.
15.2 Pruebas de manipulación
Cambiar IDs de pedido, perfil, repartidor o incidencia.
Alterar `role`, `user_id`, `created_by`, `assigned_to`, `status`,
`total`, `delivered_at` o campos de auditoría en la petición.
Enviar cantidades negativas, cero, valores extremos, cadenas largas
y tipos incorrectos.
Repetir una solicitud de creación o cambio de estado.
Ejecutar transiciones fuera de secuencia.
Intentar leer pedidos de otro repartidor.
Invocar funciones sin sesión o con rol insuficiente.
Probar una sesión expirada y una cuenta deshabilitada.
Usar un enlace de recuperación expirado o manipulado.
Probar destino de mapas vacío o con caracteres especiales.
15.3 Pruebas de seguridad móvil
Inspeccionar el paquete de prueba en busca de secretos
privilegiados.
Revisar logs durante login, errores y registro de pedidos.
Verificar que cerrar sesión elimina estado sensible visible.
Verificar que backups no incluyan secretos o datos sensibles no
protegidos.
Revisar permisos solicitados y tráfico de red.
Confirmar que TLS está validado correctamente.
Probar deep links y navegación directa a pantallas protegidas.
15.4 Registro de resultado
Cada prueba debe guardar:
ID y objetivo.
Entorno y versión de la app.
Rol/cuenta de prueba, sin incluir contraseña ni token.
Pasos de reproducción.
Resultado esperado y resultado observado.
Estado: `APROBADO`, `FALLIDO`, `BLOQUEADO` o `NO PROBADO`.
Evidencia sanitizada.
Severidad, responsable y referencia al defecto si falla.
---
16. Requisitos mínimos de salida a piloto
No autorizar el piloto si se cumple cualquiera de estas condiciones:
Existe una clave `service_role` o secreto privilegiado en el cliente
o en el repositorio.
RLS está desactivada o las tablas expuestas carecen de políticas
justificadas.
Un usuario puede consultar o modificar pedidos ajenos.
Un usuario puede elevar su rol desde Flutter.
Se pueden manipular importes o estados críticos sin validación del
servidor.
El registro de pedido puede dejar datos parcialmente escritos.
Los fallos de red pueden producir duplicaciones graves sin control
ni recuperación.
Existen defectos críticos abiertos en autenticación, autorización o
integridad.
No hay forma de revocar acceso a una cuenta comprometida.
Las pruebas esenciales no se ejecutaron o sus resultados no están
documentados.
No existe autorización para el uso de datos, marca, infraestructura
o cuentas del negocio.
Los defectos altos deben corregirse antes del piloto salvo excepción
formal con mitigación y aprobación explícita. Los defectos medios/bajos
deben tener responsable, evaluación de riesgo y fecha prevista.
---
17. Checklist maestro por módulo
Autenticación
[ ] Mensajes no enumerables.
[ ] Contraseñas y tokens fuera de logs.
[ ] Recuperación con token de un solo uso y retorno validado.
[ ] Sesión y cierre de sesión probados.
[ ] MFA evaluado para roles privilegiados.
[ ] Registro público deshabilitado por defecto si es app interna.
Navegación y perfil
[ ] Rutas protegidas.
[ ] Rol recuperado desde fuente confiable.
[ ] Sin acceso temporal ante error de perfil.
[ ] Perfil no puede cambiar su rol.
[ ] Deep links validados.
Catálogo y pedidos
[ ] RLS para todas las operaciones expuestas.
[ ] Precios y totales validados en servidor.
[ ] Pedido y detalles se guardan atómicamente.
[ ] Creación idempotente o reintentos controlados.
[ ] IDs ajenos denegados.
[ ] Paginación y límites.
Preparación y asignación
[ ] Máquina de estados validada.
[ ] Transiciones ejecutadas en servidor.
[ ] Solo repartidores habilitados reciben pedidos.
[ ] Conflictos concurrentes rechazados.
[ ] Auditoría de acciones críticas.
Reparto y resultado
[ ] Repartidor solo ve sus asignaciones.
[ ] Destino solo visible a roles autorizados.
[ ] Enlace externo validado.
[ ] Resultado de entrega confirmado por servidor.
[ ] Motivos de incidencia controlados.
[ ] Sin duplicación por reintentos.
Supabase/Backend
[ ] RLS activa y probada.
[ ] `service_role` nunca está en Flutter.
[ ] Privilegios SQL y funciones revisados.
[ ] Storage privado si se utiliza.
[ ] Realtime restringido si se utiliza.
[ ] Secretos rotables y entornos separados.
Calidad y operación
[ ] Análisis estático y pruebas ejecutados.
[ ] Dependencias revisadas.
[ ] Regresión por roles.
[ ] Logs sanitizados.
[ ] Procedimiento de incidentes definido.
[ ] Riesgos residuales documentados.
---
18. Matriz de implementación y evidencia
Completar esta matriz durante el desarrollo. No marcar un control como
implementado únicamente porque existe un widget o una regla en la
interfaz.
---
ID                Control              Capa responsable  Evidencia mínima
---
SEC-001           No hay claves        Build/CI          Escaneo de secretos
privilegiadas en el                    y revisión del
cliente                                paquete
SEC-002           Rutas protegidas por Flutter/router    Pruebas de
sesión                                 navegación anónima
SEC-003           Rol validado en      Backend/DB        Pruebas negativas
servidor                               por rol
SEC-004           RLS para pedidos     PostgreSQL        Pruebas de
lectura/escritura
con usuarios
distintos
SEC-005           Total                Backend/DB        Prueba con total
calculado/validado                     manipulado
en servidor
SEC-006           Pedido y líneas      Backend/DB        Prueba de fallo
atómicos                               parcial
SEC-007           Transiciones de      Backend/DB        Matriz de
estado restringidas                    transiciones
válidas e inválidas
SEC-008           Asignación validada  Backend/DB        Pruebas de
repartidor inactivo
y conflicto
SEC-009           Resultado de entrega Backend/DB        Pruebas de
autorizado                             asignación y estado
SEC-010           Sesión cerrada       Flutter/Auth      Prueba de cierre y
limpia estado                          navegación atrás
sensible
SEC-011           Secretos excluidos   App/CI            Revisión de logs de
de logs                                escenarios críticos
SEC-012           Navegación externa   Flutter           Pruebas de destino
validada                               válido e inválido
SEC-013           Dependencias         CI                Informe de
revisadas                              dependencias
SEC-014           Errores sin detalles App/backend       Pruebas de errores
internos                               controlados
SEC-015           Procedimiento de     Operación         Documento aprobado
incidentes                             y responsable
asignado
Estados permitidos para la matriz: `PENDIENTE`, `EN IMPLEMENTACIÓN`,
`IMPLEMENTADO`, `VERIFICADO`, `BLOQUEADO`. Solo `VERIFICADO` significa
que hay evidencia de prueba.
---
19. Orden recomendado de implementación
Fundación: entornos separados, gestión de secretos,
autenticación y rutas protegidas.
Autorización: modelo de roles, RLS y pruebas negativas antes de
conectar pantallas operativas.
Integridad: modelo de datos, restricciones, operaciones atómicas
y validaciones del servidor.
Módulos funcionales: catálogo, pedidos, preparación, asignación
y resultado con permisos específicos.
Protección móvil: sesión, almacenamiento, permisos Android, deep
links y logs.
Verificación: pruebas por rol, pruebas adversariales
controladas, análisis de dependencias y regresión.
Piloto: solo después de cumplir los criterios de salida y
documentar riesgos residuales.
20. Decisiones que deben quedar registradas antes de producción
Roles definitivos y permisos de cada acción.
Si existe un módulo de cliente en el alcance real.
Política de contraseñas y MFA para administración.
Estados oficiales del pedido y transiciones.
Catálogo de incidencias y política de reasignación.
Datos personales necesarios, acceso, retención y eliminación.
Proveedor externo de mapas y datos que recibe.
Entornos, responsables de despliegue y rotación de secretos.
Política de auditoría, respuesta a incidentes y notificación.
Dispositivos/versiones Android oficialmente soportados.
Criterios de aceptación y aprobación del piloto.
---
21. Definición de terminado de seguridad
Un módulo solo puede considerarse verificado desde el punto de vista
de seguridad cuando:
Sus activos, amenazas y permisos están identificados.
Las validaciones críticas existen en el servidor/base de datos.
La autorización por rol y por registro fue probada con casos
negativos.
Los errores no filtran información sensible.
No expone secretos privilegiados.
Cuenta con pruebas reproducibles y evidencia.
La revisión de código y configuración está completada.
Los riesgos pendientes tienen responsable y tratamiento documentado.
Conclusión: esta especificación debe convertirse en tareas de
desarrollo y pruebas verificables. No basta con incorporar controles
visuales en Flutter: los controles decisivos de identidad, autorización,
integridad de pedidos y cambios de estado deben aplicarse en
Supabase/PostgreSQL o en una capa de servidor confiable. La seguridad
debe verificarse en cada Sprint y antes de cualquier piloto o
despliegue.