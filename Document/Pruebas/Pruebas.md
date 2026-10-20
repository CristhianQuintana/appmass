Plan integral de pruebas por Sprint --- Aplicación móvil MASS
Código del documento: QA-MASS-PLAN-001  
Versión: 1.0  
Fecha: 13/10/2026  
Estado: Plan de pruebas propuesto para ejecución y evidencias  
Aplicación: App móvil para operaciones de minimarket MASS  
Tecnologías previstas: Flutter/Dart, Riverpod, `go_router`, Supabase
Auth, PostgreSQL/RLS, GitHub y Android  
Duración de referencia: 8 Sprints, de dos semanas cada uno  
Enfoque: pruebas funcionales, integración, seguridad, regresión,
compatibilidad, usabilidad y aceptación.
> **Importante:** este documento define pruebas que deben ejecutarse; no
> afirma que ya se hayan ejecutado ni que hayan sido aprobadas. Cada
> resultado debe registrarse con evidencia real del entorno de pruebas.
> Las pruebas deben realizarse solo en sistemas propios o expresamente
> autorizados y con datos ficticios o aprobados.
---
1. Objetivo
Definir un plan de pruebas completo, trazable y organizado por Sprint
para verificar que la aplicación funciona según los requisitos, protege
los datos, respeta los permisos, mantiene la integridad de pedidos y
ofrece un comportamiento estable en los dispositivos Android acordados.
El plan incluye pruebas de aceptación, unitarias, de widgets,
integración, base de datos/RLS, seguridad, regresión y preparación de
piloto. Para cada Sprint se indican alcance, casos, resultado esperado,
prioridad y evidencia.
2. Alcance funcional por Sprint
---
Sprint                  Alcance principal       Pruebas dominantes
---
0                       Descubrimiento,         Revisión de requisitos,
arquitectura,           configuración,
decisiones y entorno    secretos, migraciones y
criterios de aceptación
1                       Base Flutter,           Login, sesión, rutas
autenticación,          protegidas, permisos y
perfiles, roles y       estructura inicial
navegación
2                       Catálogo, modelo de     Datos, búsqueda,
productos y permisos    integridad, RLS y
estados de interfaz
3                       Registro y consulta de  Validación, cálculo,
pedidos                 persistencia atómica,
lista, detalle y
autorización
4                       Preparación y cambios   Máquina de estados,
de estado               permisos, concurrencia,
trazabilidad
5                       Asignación a repartidor Elegibilidad,
y navegación externa    asignación, aislamiento
por repartidor, enlaces
de mapas
6                       Resultado de entrega e  Entrega
incidencias             exitosa/fallida,
motivos, auditoría,
idempotencia
7                       Estabilización y        Seguridad,
regresión integral      dependencias,
compatibilidad,
errores, rendimiento
básico y decisión de
piloto
8                       Piloto controlado y     Aceptación de usuarios,
versión candidata       regresión final,
incidencias,
recuperación y
criterios de salida
El Sprint 8 se incluye como continuación lógica del plan inicial. Sus
actividades concretas deben confirmarse antes de iniciar, especialmente
el alcance del piloto y quién autoriza su ejecución.
---
3. Método de trabajo de QA
3.1 Tipos de prueba
Prueba unitaria: verifica una función o regla aislada.
Prueba de widget/UI: verifica comportamiento de componentes y
pantallas Flutter.
Prueba de integración: verifica la interacción entre
componentes, repositorio y servicios.
Prueba de base de datos/RLS: verifica restricciones, integridad
y autorización en PostgreSQL/Supabase.
Prueba de aceptación: verifica un flujo completo contra
criterios de negocio.
Prueba de seguridad: verifica que accesos no autorizados,
manipulación y escalamiento de privilegios sean rechazados.
Regresión: confirma que los cambios no rompen flujos ya
aprobados.
Compatibilidad: verifica comportamiento en los
dispositivos/versiones Android definidos.
Rendimiento básico: mide tiempos y estabilidad en un entorno
documentado, sin declarar umbrales que no hayan sido acordados.
Prueba exploratoria: busca fallos no cubiertos por casos
predefinidos.
3.2 Prioridades
P0 --- Bloqueante: exposición de datos, escalamiento de
privilegios, corrupción de pedidos, secreto privilegiado en cliente
o caída total del flujo crítico.
P1 --- Alta: función principal falla o genera resultados
incorrectos sin alternativa aceptable.
P2 --- Media: impacto acotado con alternativa temporal.
P3 --- Baja: defecto visual o mejora menor.
Un defecto P0 bloquea la salida a piloto. Un P1 debe resolverse antes
del piloto salvo excepción formal, mitigación y aprobación documentadas.
3.3 Estados de ejecución
Cada caso debe quedar como uno de los siguientes:
`APROBADO`: ejecutado y cumple el resultado esperado.
`FALLIDO`: ejecutado y no cumple el resultado esperado.
`BLOQUEADO`: no se pudo ejecutar por dependencia o entorno.
`NO PROBADO`: aún no se ejecutó.
No marcar casos como aprobados por inspección superficial, por tener
código escrito o porque la pantalla exista.
3.4 Datos y entorno de pruebas
Usar proyecto Supabase y credenciales de prueba separados de
producción.
Crear cuentas ficticias por rol: administrador, operador y
repartidor; cliente solo si se aprueba en el alcance.
Utilizar productos, pedidos, direcciones y resultados de entrega
ficticios.
Nunca copiar contraseñas, tokens, datos personales o claves
privilegiadas en los reportes.
Restablecer datos entre pruebas destructivas.
Registrar versión de app, commit, dispositivo, versión Android,
configuración del entorno y fecha.
Evitar ejecutar pruebas intrusivas sobre sistemas de MASS sin
autorización escrita.
---
4. Sprint 0 --- Descubrimiento, arquitectura y entorno
Objetivo de QA
Verificar que los requisitos, roles, datos, entorno de desarrollo y
criterios de aceptación son suficientes para comenzar sin introducir
riesgos de seguridad o decisiones de negocio no aprobadas.
Casos de prueba
S0-T01 --- Trazabilidad de requisitos
Tipo/Prioridad: revisión funcional / P1.
Preparación: disponer de historias de usuario y alcance del MVP.
Pasos: relacionar cada requisito con una pantalla, operación,
regla de negocio y criterio de aceptación.
Esperado: no existen funciones críticas sin criterio
verificable; las dudas quedan registradas.
Evidencia: matriz requisito--historia--prueba.
S0-T02 --- Confirmación de alcance
Tipo/Prioridad: aceptación / P1.
Pasos: revisar con el responsable los flujos incluidos y
excluidos, incluidos pagos, inventario, GPS y sistemas internos.
Esperado: los límites del MVP y las exclusiones quedan
aprobados.
Evidencia: acta o registro de decisiones.
S0-T03 --- Definición de roles y permisos
Tipo/Prioridad: seguridad / P0.
Pasos: enumerar acciones de administrador, operador y
repartidor; identificar acciones privilegiadas.
Esperado: cada operación tiene un rol autorizado y el resto se
deniega por defecto.
Evidencia: matriz de permisos aprobada.
S0-T04 --- Separación de entornos
Tipo/Prioridad: configuración / P0.
Pasos: comprobar que desarrollo/pruebas no usan credenciales ni
datos productivos.
Esperado: existen entornos identificables y separados; no hay
credenciales productivas en archivos de desarrollo.
Evidencia: configuración sanitizada y lista de entornos.
S0-T05 --- Gestión de secretos
Tipo/Prioridad: seguridad / P0.
Pasos: revisar repositorio, configuración y archivos ignorados;
buscar claves privilegiadas y contraseñas.
Esperado: no se versionan secretos; `service_role` no se entrega
al cliente.
Evidencia: resultado de revisión de secretos sin mostrar el
valor de ninguna clave.
S0-T06 --- Versiones y compatibilidad
Tipo/Prioridad: compatibilidad / P2.
Pasos: verificar versiones reales de Flutter, Dart, Android SDK
y plugins; probar resolución de dependencias.
Esperado: versiones registradas y compatibles con el mínimo
Android aprobado.
Evidencia: salida de versiones y resolución de dependencias.
S0-T07 --- Estrategia de migraciones
Tipo/Prioridad: base de datos / P1.
Pasos: verificar que cambios de esquema se aplican mediante
migraciones versionadas en un entorno limpio.
Esperado: una instalación nueva puede construir el esquema de
prueba siguiendo instrucciones documentadas.
Evidencia: log de migración sin secretos.
S0-T08 --- Plan de pruebas y defectos
Tipo/Prioridad: proceso / P2.
Pasos: crear estructura de casos, prioridades, responsables y
formato de reporte.
Esperado: cada caso tendrá ID, precondiciones, pasos, resultado
esperado y evidencia.
Evidencia: tablero y plantilla de ejecución.
Criterio de salida del Sprint 0
Requisitos críticos y roles definidos.
Entorno de prueba disponible.
No hay secretos privilegiados en el repositorio.
Migraciones y ejecución del proyecto documentadas.
Los bloqueos se registran; no se presume que el entorno está listo
sin evidencia.
---
5. Sprint 1 --- Fundamentos, autenticación, perfil y navegación
Objetivo de QA
Verificar que la aplicación inicia, gestiona sesiones de manera segura,
carga el perfil y permite acceder únicamente a las rutas autorizadas.
Casos de prueba
S1-T01 --- Inicio de sesión correcto
Tipo/Prioridad: funcional / P1.
Pasos: ingresar credenciales válidas de una cuenta de prueba
habilitada.
Esperado: la sesión se inicia y se carga el perfil/rol correcto.
Evidencia: captura sanitizada y log de prueba.
S1-T02 --- Credenciales incorrectas
Tipo/Prioridad: seguridad / P1.
Pasos: intentar autenticarse con contraseña incorrecta.
Esperado: acceso denegado, mensaje genérico y ninguna
información que permita confirmar la existencia de la cuenta.
Evidencia: resultado de UI.
S1-T03 --- Campos vacíos o mal formados
Tipo/Prioridad: widget/unitaria / P2.
Pasos: enviar campos vacíos, email mal formado y valores
excesivamente largos.
Esperado: validación clara; no se envían solicitudes
innecesarias para errores locales.
Evidencia: pruebas de formulario.
S1-T04 --- Envío repetido del login
Tipo/Prioridad: UI / P2.
Pasos: tocar repetidamente el botón durante la solicitud.
Esperado: no se generan solicitudes duplicadas por el mismo
evento; el indicador de carga funciona.
Evidencia: prueba de widget o registro controlado.
S1-T05 --- Acceso directo a ruta protegida sin sesión
Tipo/Prioridad: seguridad / P0.
Pasos: abrir una ruta interna directamente sin iniciar sesión.
Esperado: redirección al login; no se muestra información
privada.
Evidencia: prueba de navegación.
S1-T06 --- Perfil o rol no disponible
Tipo/Prioridad: autorización / P0.
Pasos: autenticar un usuario de prueba sin perfil válido o
simular fallo de carga del perfil.
Esperado: denegación por defecto; no se habilitan pantallas
privilegiadas.
Evidencia: resultado de integración.
S1-T07 --- Cierre de sesión
Tipo/Prioridad: seguridad / P0.
Pasos: iniciar sesión, navegar a una pantalla privada, cerrar
sesión y usar atrás.
Esperado: la sesión se cierra y las pantallas protegidas no
quedan accesibles.
Evidencia: vídeo/capturas sanitizadas o test automatizado.
S1-T08 --- Error de red durante login
Tipo/Prioridad: resiliencia / P2.
Pasos: simular pérdida de conexión durante autenticación.
Esperado: mensaje controlado, sin falsa autenticación ni bloqueo
permanente de UI.
Evidencia: prueba reproducible.
S1-T09 --- Recuperación de contraseña
Tipo/Prioridad: seguridad / P1.
Pasos: solicitar recuperación para una cuenta de prueba y probar
enlace válido, expirado y reutilizado.
Esperado: respuesta no enumerable; enlace expirado/reutilizado
no permite cambiar contraseña.
Evidencia: resultado del proveedor y UI, sin registrar token.
S1-T10 --- Usuario deshabilitado o sesión revocada
Tipo/Prioridad: seguridad / P1.
Pasos: revocar/deshabilitar la cuenta de prueba y tratar de
ejecutar una operación protegida.
Esperado: el backend rechaza la operación según la política de
sesión configurada.
Evidencia: resultado de solicitud de prueba.
S1-T11 --- Cambio de usuario
Tipo/Prioridad: privacidad / P1.
Pasos: cerrar sesión de un usuario e iniciar con otro.
Esperado: no se muestran datos, cachés o estados de la cuenta
anterior.
Evidencia: prueba de navegación/estado.
S1-T12 --- Prueba por rol
Tipo/Prioridad: seguridad / P0.
Pasos: ingresar con cada rol definido y recorrer las rutas.
Esperado: solo aparecen rutas autorizadas; la protección del
servidor se valida en S1/S2 y no depende solo de la UI.
Evidencia: matriz rol--ruta.
Criterio de salida del Sprint 1
Login, sesión, cierre y rutas protegidas funcionan; perfil no válido
deniega por defecto; no se exponen secretos en logs; los casos P0/P1
están aprobados o documentados como bloqueantes.
---
6. Sprint 2 --- Catálogo, modelo de productos, búsqueda y RLS
Objetivo de QA
Verificar que el catálogo se muestra correctamente, la búsqueda es
robusta y las operaciones de base de datos respetan las restricciones de
integridad y autorización.
Casos de prueba
S2-T01 --- Catálogo con datos válidos
Tipo/Prioridad: funcional / P1.
Pasos: consultar catálogo con una cuenta autorizada.
Esperado: se muestran productos de prueba con campos correctos.
Evidencia: captura y respuesta sanitizada.
S2-T02 --- Catálogo vacío
Tipo/Prioridad: UI / P2.
Pasos: consultar entorno sin productos.
Esperado: mensaje de lista vacía, sin excepción ni datos
antiguos.
Evidencia: prueba de widget.
S2-T03 --- Error o timeout de catálogo
Tipo/Prioridad: resiliencia / P2.
Pasos: simular error de consulta.
Esperado: mensaje controlado y opción de reintento.
Evidencia: test de repositorio/widget.
S2-T04 --- Búsqueda normal
Tipo/Prioridad: funcional / P2.
Pasos: buscar un nombre/código existente.
Esperado: resultados correctos, sin traer registros fuera del
permiso.
Evidencia: resultado de prueba.
S2-T05 --- Búsqueda con caracteres especiales
Tipo/Prioridad: seguridad / P1.
Pasos: buscar comillas, símbolos, caracteres Unicode y texto
largo.
Esperado: no se rompe la consulta ni se ejecuta SQL arbitrario;
se aplican límites.
Evidencia: pruebas de búsqueda.
S2-T06 --- Consulta sin permiso
Tipo/Prioridad: RLS / P0.
Pasos: consultar catálogo o campos no autorizados con un rol
restringido.
Esperado: acceso denegado o solo campos autorizados.
Evidencia: resultado desde cuenta de prueba con rol restringido.
S2-T07 --- Inserción de producto con datos inválidos
Tipo/Prioridad: integridad / P1.
Pasos: intentar insertar cantidades, precios o campos inválidos
mediante una operación de prueba autorizada.
Esperado: restricciones del servidor/base de datos rechazan el
dato.
Evidencia: resultado de prueba SQL/RPC.
S2-T08 --- Manipulación de precio desde cliente
Tipo/Prioridad: seguridad / P0.
Pasos: intentar modificar precio de catálogo desde una cuenta
sin permiso.
Esperado: operación denegada por backend/RLS.
Evidencia: resultado de autorización.
S2-T09 --- Integridad de claves y campos obligatorios
Tipo/Prioridad: base de datos / P1.
Pasos: probar referencia a producto inexistente y campos
obligatorios omitidos.
Esperado: restricciones rechazan datos inválidos.
Evidencia: resultado de migración/prueba.
S2-T10 --- Paginación y límites
Tipo/Prioridad: rendimiento / P2.
Pasos: consultar con volumen de datos de prueba representativo.
Esperado: límite de resultados, orden estable y uso razonable de
consultas.
Evidencia: consulta y medición contextualizada.
S2-T11 --- Serialización del modelo Dart
Tipo/Prioridad: unitaria / P2.
Pasos: probar conversión JSON válida, campos opcionales y datos
mal formados.
Esperado: conversiones correctas y errores controlados.
Evidencia: reporte de unit tests.
S2-T12 --- RLS por rol y tabla
Tipo/Prioridad: seguridad / P0.
Pasos: probar lectura y escritura con cada rol, incluyendo
ausencia de sesión.
Esperado: las políticas aplican a cada operación relevante y
deniegan por defecto.
Evidencia: matriz de políticas y pruebas negativas.
Criterio de salida del Sprint 2
Catálogo y búsqueda funcionan; integridad de datos y RLS están probadas;
ningún rol sin permiso puede cambiar campos de producto protegidos.
---
7. Sprint 3 --- Registro, lista y detalle de pedidos
Objetivo de QA
Verificar el ciclo de registro de un pedido con uno o varios productos,
la consistencia de importes y la consulta segura de la lista y detalle.
Casos de prueba
S3-T01 --- Crear pedido válido con un producto
Tipo/Prioridad: aceptación / P1.
Pasos: seleccionar un producto, cantidad válida, revisar resumen
y confirmar.
Esperado: cabecera y línea quedan guardadas; se devuelve
identificador de pedido.
Evidencia: ID ficticio y consulta de verificación.
S3-T02 --- Crear pedido con varios productos
Tipo/Prioridad: aceptación / P1.
Pasos: seleccionar varios productos y confirmar.
Esperado: cada línea se relaciona con el pedido correcto y los
importes coinciden.
Evidencia: comparación resumen/base de datos.
S3-T03 --- Pedido vacío
Tipo/Prioridad: validación / P1.
Pasos: intentar confirmar sin productos.
Esperado: operación rechazada en UI y servidor.
Evidencia: prueba de UI y backend.
S3-T04 --- Cantidad cero, negativa, decimal o extrema
Tipo/Prioridad: validación / P1.
Pasos: enviar valores inválidos desde pruebas controladas.
Esperado: valores fuera de la regla aprobada son rechazados por
el servidor.
Evidencia: pruebas de validación.
S3-T05 --- Manipulación del total
Tipo/Prioridad: seguridad / P0.
Pasos: alterar total o subtotal en la solicitud.
Esperado: el backend recalcula/valida los importes y rechaza
valores inconsistentes.
Evidencia: prueba negativa.
S3-T06 --- Precio cambió antes de confirmar
Tipo/Prioridad: negocio / P1.
Pasos: cambiar precio de prueba entre selección y confirmación.
Esperado: se aplica la regla aprobada y el usuario ve el importe
final antes de aceptar si corresponde.
Evidencia: registro del caso.
S3-T07 --- Atomicidad de cabecera y detalles
Tipo/Prioridad: integridad / P0.
Pasos: simular fallo durante el guardado de detalles.
Esperado: no queda pedido parcial; la operación es transaccional
o equivalente.
Evidencia: consulta posterior de integridad.
S3-T08 --- Envío doble y reintento
Tipo/Prioridad: integridad / P0.
Pasos: tocar confirmar repetidamente o simular timeout tras
envío.
Esperado: no se crean pedidos duplicados por una única acción
lógica; la app permite verificar el resultado.
Evidencia: IDs y resultado de pruebas.
S3-T09 --- Usuario no autenticado registra pedido
Tipo/Prioridad: seguridad / P0.
Pasos: invocar la operación sin sesión válida.
Esperado: operación denegada.
Evidencia: resultado del servidor.
S3-T10 --- Suplantación de creador
Tipo/Prioridad: seguridad / P0.
Pasos: enviar un `created_by` distinto al usuario autenticado.
Esperado: el servidor ignora el campo no confiable o rechaza la
solicitud.
Evidencia: prueba negativa.
S3-T11 --- Lista de pedidos
Tipo/Prioridad: funcional / P1.
Pasos: consultar lista con datos de prueba.
Esperado: identificador, fecha, total y estado corresponden al
servidor.
Evidencia: comparación con base de datos.
S3-T12 --- Acceso a pedido ajeno
Tipo/Prioridad: seguridad / P0.
Pasos: modificar el ID de un pedido para consultar el de otro
usuario/ámbito.
Esperado: denegación sin revelar detalles del registro
protegido.
Evidencia: prueba de autorización.
S3-T13 --- Pedido inexistente
Tipo/Prioridad: funcional / P2.
Pasos: abrir un ID inexistente.
Esperado: mensaje controlado, sin cierre inesperado.
Evidencia: prueba de UI.
S3-T14 --- Importes y redondeo
Tipo/Prioridad: unitaria / P1.
Pasos: probar importes decimales y cantidades variadas según
regla aprobada.
Esperado: resultados coherentes con la política de moneda y
redondeo.
Evidencia: tabla de valores esperados.
S3-T15 --- Recuperación ante error de red
Tipo/Prioridad: resiliencia / P1.
Pasos: cortar conexión durante registro.
Esperado: no se muestra éxito falso; se informa si debe
reintentarse o verificar el resultado.
Evidencia: grabación/log sanitizado.
Criterio de salida del Sprint 3
Se registra y consulta un pedido completo; el total se valida en el
servidor; no hay escrituras parciales; los pedidos ajenos son
inaccesibles.
---
8. Sprint 4 --- Preparación y transiciones de estado
Objetivo de QA
Verificar que solo los roles autorizados pueden cambiar un pedido por
transiciones válidas, con persistencia, trazabilidad y control de
concurrencia.
Casos de prueba
S4-T01 --- Transición pendiente a preparación
Tipo/Prioridad: aceptación / P1.
Pasos: seleccionar pedido pendiente y comenzar preparación.
Esperado: estado actualizado solo si la transición está aprobada
y el rol tiene permiso.
Evidencia: estado antes/después.
S4-T02 --- Transición preparación a listo
Tipo/Prioridad: aceptación / P1.
Pasos: marcar como listo un pedido en preparación.
Esperado: el servidor confirma el cambio y la UI se actualiza.
Evidencia: registro de estado.
S4-T03 --- Salto de estado
Tipo/Prioridad: seguridad / P0.
Pasos: intentar cambiar directamente de pendiente a listo.
Esperado: el servidor rechaza la transición si no está
permitida.
Evidencia: respuesta negativa.
S4-T04 --- Cambio por rol no autorizado
Tipo/Prioridad: seguridad / P0.
Pasos: intentar cambiar estado como repartidor o rol sin
permiso.
Esperado: operación denegada en backend/RLS.
Evidencia: prueba por rol.
S4-T05 --- Modificación de campos protegidos
Tipo/Prioridad: seguridad / P0.
Pasos: intentar alterar total, creador o asignación en una
operación de cambio de estado.
Esperado: campos protegidos no se modifican.
Evidencia: comparación antes/después.
S4-T06 --- Estado obsoleto
Tipo/Prioridad: concurrencia / P1.
Pasos: dos usuarios abren el mismo pedido; uno cambia estado y
el otro envía el cambio anterior.
Esperado: la operación obsoleta se rechaza y la UI refresca el
estado.
Evidencia: secuencia de operaciones.
S4-T07 --- Doble toque
Tipo/Prioridad: integridad / P1.
Pasos: activar repetidamente la acción.
Esperado: una transición válida, sin cambios duplicados ni
auditoría engañosa.
Evidencia: prueba automatizada.
S4-T08 --- Trazabilidad
Tipo/Prioridad: auditoría / P1.
Pasos: cambiar estado y consultar los campos/historial de
auditoría.
Esperado: actor y fecha provienen del servidor; el cliente no
puede falsificarlos.
Evidencia: registro sanitizado.
S4-T09 --- Pedido inexistente o no visible
Tipo/Prioridad: seguridad / P1.
Pasos: intentar cambiar estado de un ID no autorizado.
Esperado: denegación sin fuga de información.
Evidencia: respuesta de prueba.
S4-T10 --- Lista operativa y detalle
Tipo/Prioridad: regresión / P2.
Pasos: cambiar estado y volver a la lista/detalle.
Esperado: la vista refleja el estado persistido.
Evidencia: comparación con base de datos.
S4-T11 --- Error de red durante transición
Tipo/Prioridad: resiliencia / P1.
Pasos: simular timeout al actualizar.
Esperado: no se informa éxito sin confirmación; se recupera el
estado real del servidor.
Evidencia: prueba reproducible.
S4-T12 --- Catálogo de estados inválido
Tipo/Prioridad: integridad / P1.
Pasos: intentar persistir un estado no reconocido.
Esperado: restricción/operación del servidor lo rechaza.
Evidencia: prueba de base de datos.
Criterio de salida del Sprint 4
Transiciones permitidas funcionan, las no permitidas se rechazan, los
conflictos no producen estados inconsistentes y la auditoría no puede
falsificarse desde Flutter.
---
9. Sprint 5 --- Asignación de repartidor y navegación
Objetivo de QA
Verificar que solo usuarios autorizados asignan pedidos a repartidores
habilitados, que cada repartidor ve únicamente sus pedidos y que la
navegación externa usa destinos válidos.
Casos de prueba
S5-T01 --- Asignación válida
Tipo/Prioridad: aceptación / P1.
Pasos: un operador autorizado asigna un pedido listo a un
repartidor activo.
Esperado: asignación persistida y pedido fuera de la cola de no
asignados según regla aprobada.
Evidencia: registro de asignación.
S5-T02 --- Repartidor deshabilitado
Tipo/Prioridad: seguridad / P1.
Pasos: intentar asignar pedido a un usuario deshabilitado/no
habilitado.
Esperado: operación rechazada en servidor.
Evidencia: prueba negativa.
S5-T03 --- Pedido en estado no asignable
Tipo/Prioridad: integridad / P1.
Pasos: intentar asignar un pedido pendiente o ya cerrado.
Esperado: el servidor rechaza la asignación fuera de estado
permitido.
Evidencia: estado antes/después.
S5-T04 --- Operador sin permiso asigna
Tipo/Prioridad: seguridad / P0.
Pasos: intentar asignar con un rol no autorizado.
Esperado: denegación en backend/RLS.
Evidencia: prueba por rol.
S5-T05 --- Repartidor intenta autoasignarse
Tipo/Prioridad: seguridad / P0.
Pasos: modificar parámetros para asignarse un pedido arbitrario.
Esperado: operación denegada.
Evidencia: prueba negativa.
S5-T06 --- Conflicto de asignación
Tipo/Prioridad: concurrencia / P1.
Pasos: dos operadores intentan asignar el mismo pedido a
diferentes repartidores.
Esperado: la operación atómica permite una asignación válida y
rechaza el conflicto.
Evidencia: registro de operaciones.
S5-T07 --- Reasignación no permitida
Tipo/Prioridad: seguridad / P1.
Pasos: intentar reasignar un pedido cuando la regla no lo
permite.
Esperado: operación rechazada.
Evidencia: prueba de transición.
S5-T08 --- Lista propia del repartidor
Tipo/Prioridad: autorización / P0.
Pasos: iniciar sesión como repartidor y consultar asignaciones.
Esperado: solo se muestran pedidos asignados al usuario
autenticado.
Evidencia: comparación de cuentas de prueba.
S5-T09 --- Manipulación de driver ID
Tipo/Prioridad: seguridad / P0.
Pasos: cambiar el identificador de repartidor en una petición de
consulta.
Esperado: el servidor ignora el identificador no confiable o
deniega el acceso.
Evidencia: respuesta de prueba.
S5-T10 --- Destino válido
Tipo/Prioridad: funcional / P2.
Pasos: abrir navegación con una dirección/coordenadas ficticias
válidas.
Esperado: se abre la aplicación externa compatible o se muestra
una alternativa segura.
Evidencia: dispositivo y resultado.
S5-T11 --- Destino vacío o mal formado
Tipo/Prioridad: validación / P2.
Pasos: probar dirección vacía, caracteres especiales y
coordenadas inválidas.
Esperado: no se abre un enlace inválido ni una URL arbitraria.
Evidencia: prueba de UI.
S5-T12 --- Minimización de datos en navegación
Tipo/Prioridad: privacidad / P1.
Pasos: inspeccionar el enlace generado.
Esperado: contiene solo los datos de destino necesarios; no
incluye tokens ni información extra.
Evidencia: enlace de prueba sanitizado.
S5-T13 --- Acceso a detalle de pedido ajeno
Tipo/Prioridad: seguridad / P0.
Pasos: modificar ID desde la vista de repartidor.
Esperado: acceso denegado por servidor.
Evidencia: prueba de autorización.
Criterio de salida del Sprint 5
La asignación se valida en servidor, el repartidor solo ve sus pedidos y
la navegación externa no filtra datos innecesarios ni acepta destinos
arbitrarios.
---
10. Sprint 6 --- Resultado de entrega e incidencias
Objetivo de QA
Verificar que el resultado de entrega se registra de forma autorizada,
consistente e idempotente, y que las incidencias utilizan motivos
válidos.
Casos de prueba
S6-T01 --- Entrega completada válida
Tipo/Prioridad: aceptación / P1.
Pasos: el repartidor asignado registra la entrega de un pedido
en estado permitido.
Esperado: estado final persistido y trazabilidad generada por
servidor.
Evidencia: registro de prueba.
S6-T02 --- Repartidor no asignado intenta cerrar
Tipo/Prioridad: seguridad / P0.
Pasos: otra cuenta de repartidor intenta registrar el resultado.
Esperado: operación denegada.
Evidencia: prueba por rol.
S6-T03 --- Estado no permitido
Tipo/Prioridad: integridad / P1.
Pasos: intentar cerrar un pedido pendiente/no asignado.
Esperado: el servidor rechaza la transición.
Evidencia: respuesta y estado final.
S6-T04 --- Motivo válido de entrega fallida
Tipo/Prioridad: aceptación / P1.
Pasos: seleccionar motivo del catálogo aprobado y registrar
fallo.
Esperado: resultado e incidencia asociados al pedido.
Evidencia: registro sanitizado.
S6-T05 --- Motivo obligatorio omitido
Tipo/Prioridad: validación / P1.
Pasos: enviar resultado fallido sin motivo cuando sea
obligatorio.
Esperado: operación rechazada.
Evidencia: respuesta de prueba.
S6-T06 --- Motivo no permitido
Tipo/Prioridad: seguridad / P1.
Pasos: enviar código de motivo que no pertenece al catálogo.
Esperado: servidor rechaza el valor.
Evidencia: prueba negativa.
S6-T07 --- Comentario excesivo o mal formado
Tipo/Prioridad: validación / P2.
Pasos: enviar comentario demasiado largo o caracteres
especiales.
Esperado: longitud validada; texto tratado como contenido, no
como código.
Evidencia: prueba de formulario/backend.
S6-T08 --- Manipulación de fecha o actor
Tipo/Prioridad: seguridad / P0.
Pasos: enviar `delivered_by` o `delivered_at` falsificado.
Esperado: servidor usa identidad y tiempo confiables, o rechaza
campos no permitidos.
Evidencia: comparación de registro.
S6-T09 --- Resultado duplicado
Tipo/Prioridad: integridad / P0.
Pasos: repetir el envío después de un timeout.
Esperado: no se crean resultados contradictorios ni duplicados.
Evidencia: consulta del registro final.
S6-T10 --- Entrega ya cerrada
Tipo/Prioridad: integridad / P1.
Pasos: intentar cambiar resultado final sin permiso/regla de
corrección.
Esperado: operación rechazada o encaminada al flujo formal
aprobado.
Evidencia: resultado del servidor.
S6-T11 --- Consulta de incidencia por rol
Tipo/Prioridad: seguridad / P1.
Pasos: consultar incidencia con un rol no autorizado.
Esperado: denegación o respuesta limitada a campos permitidos.
Evidencia: prueba por rol.
S6-T12 --- Error de red al cerrar
Tipo/Prioridad: resiliencia / P1.
Pasos: cortar conexión tras enviar el resultado.
Esperado: la app no afirma éxito falso; permite comprobar estado
antes de repetir.
Evidencia: secuencia reproducible.
S6-T13 --- Lista y detalle tras resultado
Tipo/Prioridad: regresión / P2.
Pasos: registrar resultado y consultar lista/detalle.
Esperado: el estado persistido aparece correctamente.
Evidencia: comparación con base de datos.
Criterio de salida del Sprint 6
Entrega completada y fallida funcionan según reglas aprobadas; motivos
se validan en servidor; los resultados no se duplican y los accesos
están restringidos.
---
11. Sprint 7 --- Estabilización, seguridad y regresión integral
Objetivo de QA
Ejecutar regresión completa, revisar la seguridad de la aplicación y el
backend, comprobar compatibilidad y determinar con evidencia si el MVP
puede avanzar a un piloto.
Casos de prueba
S7-T01 --- Regresión de autenticación
Prioridad: P0/P1.
Pasos: repetir login, cierre, expiración, recuperación y acceso
directo a rutas.
Esperado: no hay regresiones en sesión ni rutas protegidas.
Evidencia: matriz de regresión.
S7-T02 --- Búsqueda de secretos
Prioridad: P0.
Pasos: escanear repositorio, configuración y paquete de prueba.
Esperado: no existen secretos privilegiados expuestos.
Evidencia: reporte sanitizado de escaneo.
S7-T03 --- Revisión RLS por tabla y operación
Prioridad: P0.
Pasos: revisar `SELECT`, `INSERT`, `UPDATE`, `DELETE` y
funciones para cada tabla expuesta.
Esperado: todos los permisos están justificados y probados.
Evidencia: matriz tabla--operación--rol.
S7-T04 --- Acceso horizontal entre usuarios
Prioridad: P0.
Pasos: usar IDs de pedidos, perfiles, incidencias y asignaciones
de otras cuentas.
Esperado: no hay acceso no autorizado.
Evidencia: pruebas negativas por recurso.
S7-T05 --- Escalamiento vertical de privilegios
Prioridad: P0.
Pasos: intentar cambiar rol, habilitación o campos
administrativos desde una cuenta no privilegiada.
Esperado: servidor rechaza los cambios.
Evidencia: respuestas y estado de base de datos.
S7-T06 --- Manipulación de importes y estados
Prioridad: P0.
Pasos: modificar total, estado, creador, asignación y marcas de
tiempo.
Esperado: datos críticos son recalculados o validados en
servidor.
Evidencia: pruebas negativas.
S7-T07 --- Regresión de pedidos
Prioridad: P1.
Pasos: registrar pedidos simples y múltiples, consultar lista y
detalle, comprobar importes.
Esperado: todos los resultados siguen siendo correctos.
Evidencia: resultados de aceptación.
S7-T08 --- Regresión de preparación y asignación
Prioridad: P1.
Pasos: ejecutar transiciones válidas, asignar y comprobar listas
por rol.
Esperado: estados consistentes y separación entre repartidores.
Evidencia: matriz de flujo.
S7-T09 --- Regresión de entrega e incidencias
Prioridad: P1.
Pasos: registrar éxito y fallo, probar motivo inválido y
reintento.
Esperado: resultados consistentes, sin duplicados.
Evidencia: pruebas funcionales.
S7-T10 --- Errores de red y reintentos
Prioridad: P1.
Pasos: simular pérdida de conexión en lectura, creación y cambio
de estado.
Esperado: sin falso éxito ni corrupción de datos.
Evidencia: secuencias de prueba.
S7-T11 --- Cierre de sesión y datos residuales
Prioridad: P1.
Pasos: cerrar sesión y examinar UI, estado de Riverpod y
almacenamiento de prueba.
Esperado: no quedan datos sensibles accesibles al usuario
siguiente.
Evidencia: checklist de dispositivo.
S7-T12 --- Permisos Android
Prioridad: P2.
Pasos: revisar manifiesto y permisos solicitados.
Esperado: solo se solicitan permisos justificados por las
funciones.
Evidencia: manifiesto revisado.
S7-T13 --- Validación TLS y configuración de red
Prioridad: P0.
Pasos: revisar configuración de producción y probar conexiones
HTTPS; verificar que no se aceptan certificados inválidos.
Esperado: TLS validado y sin bypass inseguro.
Evidencia: configuración y resultado de prueba autorizada.
S7-T14 --- Dependencias y compilación limpia
Prioridad: P1.
Pasos: resolver dependencias y compilar desde un entorno limpio
siguiendo el README.
Esperado: construcción reproducible o defectos documentados.
Evidencia: log de CI/build sin secretos.
S7-T15 --- Análisis estático y tests
Prioridad: P1.
Pasos: ejecutar `flutter analyze`, pruebas unitarias, widget e
integración disponibles.
Esperado: sin fallos críticos sin explicación; los fallos están
registrados.
Evidencia: reportes de ejecución.
S7-T16 --- Compatibilidad Android
Prioridad: P1.
Pasos: probar dispositivo/emulador del mínimo admitido y un
entorno actual representativo.
Esperado: flujos principales funcionales o limitaciones
documentadas.
Evidencia: matriz dispositivo--versión--resultado.
S7-T17 --- Rendimiento básico
Prioridad: P2.
Pasos: medir carga de catálogo/listas y operaciones principales
con conjunto de prueba conocido.
Esperado: mediciones reproducibles y sin bloqueos críticos; los
umbrales deben estar acordados previamente.
Evidencia: resultados con dispositivo, red y volumen indicados.
S7-T18 --- Revisión de logs y errores
Prioridad: P1.
Pasos: provocar errores de autenticación, permisos y
persistencia; revisar logs.
Esperado: no aparecen tokens, contraseñas, claves ni datos
personales innecesarios.
Evidencia: muestras sanitizadas.
S7-T19 --- Preparación de piloto
Prioridad: P1.
Pasos: revisar criterios de salida, participantes, datos, canal
de incidencias y procedimiento de detención.
Esperado: el piloto tiene alcance y responsables definidos.
Evidencia: checklist de salida aprobado.
S7-T20 --- Decisión de salida
Prioridad: P0/P1.
Pasos: consolidar defectos y resultados por severidad.
Esperado: decisión justificada: `APTO`, `APTO CON RESTRICCIONES`
o `NO APTO`; no se promedian defectos críticos.
Evidencia: informe de salida.
Criterio de salida del Sprint 7
No hay defectos críticos abiertos de autorización, exposición de
secretos, corrupción de pedidos o bloqueo total del flujo. Las pruebas
no ejecutadas se declaran como tales. La decisión de piloto se documenta
y requiere aprobación del responsable.
---
12. Sprint 8 --- Piloto controlado y versión candidata
Objetivo de QA
Validar el MVP con participantes autorizados en un entorno de piloto
limitado, observar el uso real del flujo aprobado y decidir si el
producto cumple los criterios de aceptación acordados para una versión
candidata.
Precondiciones
Sprint 7 ha emitido recomendación favorable.
El responsable ha autorizado por escrito el piloto.
El entorno y las cuentas están preparados.
Se usan datos ficticios o datos reales expresamente autorizados y
protegidos.
Existe procedimiento de soporte, registro de incidencias y detención
del piloto.
Se ha identificado una versión estable a la que volver si hay que
detener la prueba.
Casos de prueba
S8-T01 --- Instalación y primer inicio
Tipo/Prioridad: aceptación / P1.
Pasos: instalar el paquete candidato en dispositivo aprobado e
iniciar la app.
Esperado: instalación y arranque correctos; configuración apunta
al entorno autorizado.
Evidencia: versión, dispositivo y resultado.
S8-T02 --- Acceso por rol
Tipo/Prioridad: aceptación/seguridad / P0.
Pasos: participantes ingresan con cuentas de prueba asignadas a
su rol.
Esperado: cada uno ve solo las funciones y datos permitidos.
Evidencia: matriz de rol y aceptación.
S8-T03 --- Flujo completo de pedido
Tipo/Prioridad: aceptación / P1.
Pasos: seleccionar productos, registrar pedido y consultar
detalle.
Esperado: registro consistente y datos visibles para el rol
autorizado.
Evidencia: ID ficticio y checklist.
S8-T04 --- Preparación
Tipo/Prioridad: aceptación / P1.
Pasos: avanzar pedido por estados permitidos.
Esperado: cada transición se registra y la lista se actualiza.
Evidencia: historial de estados.
S8-T05 --- Asignación y consulta del repartidor
Tipo/Prioridad: aceptación/seguridad / P1.
Pasos: asignar pedido y consultar la cuenta del repartidor.
Esperado: el pedido aparece solo en la cuenta autorizada.
Evidencia: comprobación por dos cuentas.
S8-T06 --- Navegación externa
Tipo/Prioridad: aceptación / P2.
Pasos: abrir un destino de prueba válido.
Esperado: abre una aplicación compatible o presenta alternativa
controlada.
Evidencia: resultado en dispositivo.
S8-T07 --- Resultado de entrega
Tipo/Prioridad: aceptación / P1.
Pasos: registrar entrega completada y, por separado, entrega
fallida con motivo.
Esperado: resultados persistidos y consultables según permisos.
Evidencia: registros de prueba.
S8-T08 --- Uso con conexión intermitente
Tipo/Prioridad: resiliencia / P1.
Pasos: simular conexión inestable durante una consulta y una
operación crítica en entorno de prueba.
Esperado: no se crean duplicados ni se presenta falso éxito.
Evidencia: incidencia y resultado.
S8-T09 --- Observación de usabilidad
Tipo/Prioridad: exploratoria / P2.
Pasos: observar a los participantes ejecutar las tareas
definidas sin revelarles cada paso.
Esperado: registrar confusiones, errores de operación y mejoras
priorizadas.
Evidencia: notas de prueba sin datos personales innecesarios.
S8-T10 --- Registro y priorización de incidencias
Tipo/Prioridad: proceso / P1.
Pasos: registrar cada problema con entorno, pasos, severidad y
evidencia.
Esperado: incidencias trazables y asignadas a un responsable.
Evidencia: tablero de defectos.
S8-T11 --- Criterio de detención
Tipo/Prioridad: seguridad/operación / P0.
Pasos: comprobar que el equipo conoce las condiciones para
detener el piloto.
Esperado: ante exposición de datos, acceso no autorizado o
corrupción de pedidos se detiene el flujo afectado y se activa
respuesta.
Evidencia: plan y responsable identificados.
S8-T12 --- Regresión después de correcciones
Tipo/Prioridad: regresión / P1.
Pasos: repetir los casos afectados por cada corrección incluida
en la versión candidata.
Esperado: defecto corregido sin regresiones en los flujos
relacionados.
Evidencia: ejecución antes/después.
S8-T13 --- Validación de versión candidata
Tipo/Prioridad: release / P1.
Pasos: verificar versión, configuración, migraciones, permisos,
build y notas de cambios.
Esperado: artefacto identificable y reproducible; no se incluyen
secretos.
Evidencia: checklist de release.
S8-T14 --- Aceptación final
Tipo/Prioridad: aceptación / P1.
Pasos: comparar resultados del piloto con criterios acordados.
Esperado: decisión formal: continuar, corregir y repetir, o
detener.
Evidencia: acta de aceptación y riesgos residuales.
Criterio de salida del Sprint 8
El piloto concluye con resultados y defectos documentados. La versión
candidata solo puede avanzar si cumple los criterios acordados, no tiene
defectos bloqueantes y cuenta con la aprobación requerida. El éxito del
piloto no sustituye auditorías, obligaciones legales o revisiones de
producción que sean necesarias.
---
13. Pruebas transversales en todos los Sprints
Estos controles no se ejecutan una sola vez: deben repetirse cuando
cambie el código, el esquema, las políticas o las dependencias
relacionadas.
13.1 Seguridad y autorización
Pruebas con sesión ausente, sesión válida y sesión revocada.
Pruebas de rol insuficiente y acceso a registros ajenos.
Pruebas de modificación de campos protegidos.
Revisión de RLS para `SELECT`, `INSERT`, `UPDATE` y `DELETE`.
Comprobación de que `service_role` no aparece en app, logs o
repositorio.
Verificación de errores sin información interna sensible.
13.2 Integridad y concurrencia
Doble envío de operaciones de escritura.
Timeout después de que el servidor haya procesado la operación.
Dos usuarios actualizando el mismo pedido.
Estado obsoleto.
Fallo a mitad de una operación compuesta.
Verificación de cabecera/detalles y relaciones.
13.3 Calidad móvil
Pantalla vacía, carga prolongada y error de red.
Cambio de orientación o reanudación si se soporta.
Cierre de sesión y cambio de cuenta.
Botón atrás y deep links.
Permisos mínimos.
Compatibilidad con el mínimo Android aprobado.
13.4 Cadena de suministro
Dependencias y versiones.
Escaneo de secretos.
Análisis estático.
Revisión de Pull Requests.
Migraciones versionadas.
Build limpio y artefacto identificado.
---
14. Automatización recomendada
14.1 En cada Pull Request
Formato/análisis de Dart y `flutter analyze`.
Pruebas unitarias.
Pruebas de widgets relevantes.
Escaneo de secretos.
Análisis de dependencias disponible.
Validación de que no se incluyan archivos de secretos ni dumps.
Revisión de cambios SQL/RLS cuando el PR toque el backend.
14.2 Antes de integrar a la rama principal
Pruebas de integración aplicables.
Revisión humana del cambio.
Migraciones probadas en entorno aislado.
Verificación de permisos por rol para operaciones afectadas.
Evidencia de resolución de defectos.
14.3 Antes de piloto o distribución
Regresión de flujos críticos.
Pruebas negativas de seguridad.
Build limpio y configuración correcta.
Revisión de secretos y permisos Android.
Matriz de defectos y riesgos residuales.
Aprobación de salida documentada.
No automatizar en CI pruebas destructivas contra producción. Las pruebas
de base de datos deben usar proyectos o datos aislados.
---
15. Métricas de calidad y reporte
Registrar las siguientes métricas sin convertirlas en sustituto de la
revisión de riesgos:
Casos planificados, ejecutados, aprobados, fallidos y bloqueados.
Porcentaje de ejecución: `ejecutados / planificados × 100`.
Porcentaje de aprobación entre casos ejecutados:
`aprobados / ejecutados × 100`.
Defectos abiertos por severidad.
Defectos reabiertos.
Cobertura de pruebas automatizadas, si la herramienta la mide
correctamente.
Flujos críticos con pruebas positivas y negativas.
Hallazgos de seguridad abiertos y cerrados.
Dispositivos/versiones probados.
Incidencias del piloto por flujo y severidad.
Regla de interpretación: una tasa alta de aprobación no compensa un
defecto crítico. Los casos bloqueados o no probados deben permanecer
visibles en el informe.
---
16. Plantilla de registro de ejecución
Copiar esta plantilla por cada caso:
``` text
ID del caso:
Sprint:
Fecha y hora:
Versión de la app / commit:
Entorno:
Dispositivo / versión Android:
Rol de la cuenta de prueba:
Precondiciones:
Pasos ejecutados:
Resultado esperado:
Resultado observado:
Estado: APROBADO / FALLIDO / BLOQUEADO / NO PROBADO
Prioridad/severidad:
Evidencia sanitizada:
ID de defecto:
Responsable:
Observaciones:
```
No adjuntar contraseñas, tokens, claves, datos reales de clientes ni
capturas que expongan información personal no necesaria.
17. Plantilla de reporte de defecto
``` text
ID del defecto:
Título:
Sprint detectado:
Severidad: P0 / P1 / P2 / P3
Módulo:
Entorno y versión:
Precondiciones:
Pasos para reproducir:
Resultado esperado:
Resultado real:
Frecuencia:
Impacto:
Evidencia sanitizada:
Causa raíz (cuando se conozca):
Corrección propuesta:
Prueba de verificación:
Estado: ABIERTO / EN CURSO / CORREGIDO / VERIFICADO / REABIERTO
Responsable:
```
18. Criterios globales de salida
Bloquean cualquier piloto
Exposición de clave privilegiada.
Acceso no autorizado a datos de pedidos, perfiles o incidencias.
Escalamiento de privilegios.
Manipulación no controlada de importes o estados.
Corrupción o duplicación grave de pedidos.
Fallos de autenticación que permitan acceso indebido.
Ausencia de evidencia de pruebas críticas.
Falta de autorización para usar el entorno o datos del negocio.
Requieren resolución o excepción formal antes del piloto
Fallo en registro, preparación, asignación o resultado de entrega.
Error de red que produce un resultado incierto sin mecanismo de
recuperación.
Compatibilidad rota en un dispositivo objetivo.
Incidencia alta de usabilidad que impide completar un flujo
esencial.
Pueden planificarse según riesgo
Mejoras visuales menores.
Optimizaciones no críticas con mediciones registradas.
Funcionalidades expresamente fuera del MVP.
---
19. Responsabilidades sugeridas
---
Rol del equipo                      Responsabilidad
---
Desarrollador Flutter               Unit tests, widget tests, estados
de UI, manejo de errores y
corrección de defectos móviles
Desarrollador backend/base de datos Integridad, transacciones,
funciones, RLS, autorización y
pruebas de datos
QA/Tester                           Diseño y ejecución de casos,
evidencias, regresión, defectos y
verificación de correcciones
Responsable de producto/proceso     Aprobar estados, permisos,
criterios de negocio y alcance del
piloto
Responsable técnico/seguridad       Revisar secretos, arquitectura,
políticas, riesgos y criterios de
salida
Responsable del piloto              Autorizar participantes, entorno,
soporte y procedimiento de
detención
En un equipo pequeño una persona puede asumir varios roles, pero las
decisiones de aceptación y las excepciones de seguridad deben quedar
explícitas y documentadas.
20. Conclusión
Este plan establece una base verificable de pruebas para los Sprints 0 a
8 de la aplicación móvil MASS. Cada Sprint incorpora pruebas alineadas
con su alcance y mantiene controles transversales de autenticación,
autorización, integridad, privacidad, resiliencia y cadena de
suministro.
La ejecución debe generar evidencia real: un caso escrito no equivale a
una prueba aprobada. Los controles de seguridad decisivos deben
comprobarse en el backend/base de datos, especialmente RLS, acceso por
registro, integridad transaccional y validación de estados. El piloto y
cualquier despliegue posterior dependen de los resultados observados, de
los riesgos residuales y de las autorizaciones pertinentes.