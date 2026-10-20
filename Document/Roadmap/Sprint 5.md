Informe de desarrollo --- Sprint 5
Aplicación móvil para minimarket MASS
Sprint: 5  
Duración propuesta: 2 semanas  
Metodología: Scrum con prácticas seleccionadas de XP y tablero
Kanban  
Tecnologías base: Flutter, Dart, Riverpod, `go_router`, Supabase,
PostgreSQL, Git y GitHub  
Resultado esperado: asignación de pedidos listos a personal de
reparto autorizado y apertura de navegación mediante una aplicación
externa de mapas.
---
1. Objetivo del Sprint
Implementar la gestión básica de reparto: permitir que personal
autorizado asigne un pedido listo a un repartidor habilitado, y que el
repartidor consulte los pedidos que tiene asignados y abra la ruta hacia
el destino mediante una aplicación de mapas instalada en el dispositivo.
El Sprint no contempla seguimiento GPS en tiempo real. La ubicación del
destino se utilizará únicamente para abrir la navegación externa, según
los datos que el negocio esté autorizado a registrar y mostrar.
2. Alcance
Incluido
Validar el flujo de asignación y los roles involucrados.
Definir el modelo de repartidores o reutilizar el modelo de usuarios
con un rol específico.
Relacionar un pedido con un repartidor asignado.
Definir y validar la transición desde `ready` hacia el estado de
asignación aprobado.
Mostrar una lista de pedidos listos para asignar.
Permitir que el usuario autorizado asigne o reasigne un pedido según
las reglas aprobadas.
Mostrar al repartidor sus pedidos asignados.
Mostrar la información de destino mínima necesaria para realizar la
entrega.
Abrir una aplicación externa de mapas mediante un enlace de
navegación.
Manejar permisos, datos incompletos, errores y conflictos de
asignación.
Probar el flujo y documentar el módulo.
Fuera de alcance
Seguimiento GPS en tiempo real o registro continuo de ubicación.
Optimización automática de rutas o múltiples paradas.
Confirmación de entrega e incidencias, previstas para el Sprint 6.
Notificaciones push, SMS o WhatsApp automatizados.
Pagos digitales, facturación o integración con sistemas internos.
Sincronización con un sistema corporativo de despacho o con
inventario interno.
Acceso a datos personales o direcciones reales sin autorización
expresa.
Regla de alcance: utilizar datos ficticios o aprobados en el entorno
de pruebas. No asumir acceso a sistemas, credenciales, datos de clientes
ni servicios internos de MASS.
---
3. Dependencias de entrada
Antes de iniciar, comprobar que:
El Sprint 3 permite registrar y consultar pedidos.
El Sprint 4 permite avanzar los pedidos hasta el estado `ready` o su
equivalente aprobado.
La autenticación y los roles están implementados.
Existe un modelo de usuarios o repartidores con un criterio
verificable para determinar quién puede recibir asignaciones.
Las políticas RLS están activas y probadas.
Se han definido los campos de destino que pueden almacenarse y
consultarse.
Si no existe un modelo de repartidores aprobado, definirlo en esta fase
sin incorporar datos reales no autorizados.
---
4. Propuesta de flujo de asignación
La siguiente secuencia es una propuesta que debe validarse con el
responsable del proceso:
Un usuario con permiso consulta los pedidos en estado `ready`.
Selecciona un pedido y un repartidor habilitado.
El sistema valida el estado actual del pedido, el rol del usuario y
la habilitación del repartidor.
El servidor registra la asignación y el estado correspondiente.
El repartidor consulta únicamente los pedidos que tiene asignados.
El repartidor abre la navegación externa hacia el destino.
La entrega y su resultado se registrarán en el Sprint 6.
No permitir asignaciones a usuarios que no tengan el rol y la
habilitación requeridos. Las reglas para reasignar pedidos ya asignados
deben ser aprobadas antes de implementarse.
---
5. Plan de tareas del desarrollador
S5-01. Validar el proceso de reparto
Objetivo: confirmar reglas y responsabilidades antes de implementar
el módulo.
Actividades 1. Revisar el estado `ready` o su equivalente del Sprint
4. 2. Confirmar quién puede asignar pedidos. 3. Confirmar qué condición
hace que una persona sea un repartidor habilitado. 4. Definir si se
permite reasignar un pedido y bajo qué condiciones. 5. Confirmar qué
datos de destino son necesarios y están autorizados para la aplicación.
Entregables - Flujo de asignación documentado. - Reglas de roles,
estados y reasignación. - Historias de usuario y criterios de
aceptación.
Criterios de aceptación - Los permisos y las reglas de asignación
están definidos. - Las excepciones están documentadas. - No se
incorporan reglas de negocio no aprobadas.
S5-02. Definir el modelo de repartidores
Objetivo: identificar de forma segura al personal que puede recibir
pedidos.
Actividades 1. Revisar el modelo de usuarios y roles existente. 2.
Determinar si basta con un rol `delivery` o si se requiere una tabla de
perfil de repartidor. 3. Definir un indicador de habilitación o estado
activo, si el proceso lo requiere. 4. Definir qué datos del repartidor
son visibles para otros roles. 5. Crear una migración versionada si se
modifica el esquema.
Entregables - Modelo de repartidor o definición de rol. - Migración
y documentación, si corresponden.
Criterios de aceptación - Solo usuarios habilitados pueden recibir
asignaciones. - No se exponen datos personales innecesarios. - El modelo
es compatible con el sistema de autenticación existente.
S5-03. Modelar la asignación del pedido
Objetivo: persistir la relación entre pedido y repartidor.
Actividades 1. Evaluar si la asignación se representa en `orders` o
en una tabla independiente. 2. Definir los campos mínimos, como
identificador del repartidor asignado y fecha de asignación. 3. Definir
cómo se conserva la trazabilidad de una reasignación si está permitida.
4. Añadir claves foráneas y restricciones de integridad. 5. Preparar una
migración SQL versionada.
Entregables - Modelo de asignación. - Migración SQL. - Decisiones de
diseño documentadas.
Criterios de aceptación - La asignación referencia un pedido y un
repartidor válidos. - La base de datos evita referencias inexistentes. -
El modelo permite aplicar las reglas aprobadas de asignación y
reasignación.
S5-04. Definir el estado de reparto
Objetivo: representar el estado de asignación sin confundirlo con la
entrega final.
Actividades 1. Confirmar si se usará un estado como `assigned` o una
transición equivalente aprobada. 2. Definir las transiciones permitidas
desde `ready`. 3. Impedir que el cliente establezca libremente el
estado. 4. Mantener los estados de entrega para el Sprint 6. 5.
Actualizar las pruebas y la documentación de la máquina de estados.
Entregables - Transiciones de asignación documentadas. -
Restricciones o lógica de validación actualizadas.
Criterios de aceptación - Los estados coinciden con el flujo
aprobado. - No se marca una entrega como completada en este Sprint. -
Las transiciones inválidas se rechazan en el servidor.
S5-05. Implementar permisos y RLS
Objetivo: restringir la asignación y lectura de pedidos por rol.
Actividades 1. Permitir que solo los roles aprobados asignen o
reasignen pedidos. 2. Permitir que un repartidor consulte sus propios
pedidos asignados. 3. Restringir la modificación de campos protegidos.
4. Verificar que la lectura de detalles y datos de destino siga las
mismas reglas. 5. Probar accesos permitidos y denegados.
Entregables - Políticas RLS revisadas o nuevas. - Pruebas de
autorización.
Criterios de aceptación - Un repartidor no puede asignarse pedidos
arbitrarios. - Un repartidor no puede consultar los pedidos asignados a
otros repartidores, salvo autorización explícita. - La seguridad no
depende únicamente de ocultar acciones en la interfaz.
S5-06. Implementar el repositorio de asignaciones
Objetivo: centralizar operaciones de lectura y escritura de
asignaciones.
Actividades 1. Implementar consulta de pedidos listos para asignar.
2. Implementar consulta de repartidores habilitados. 3. Implementar la
operación de asignación autorizada. 4. Implementar consulta de pedidos
del repartidor autenticado. 5. Manejar errores de red, permisos y
conflictos de estado.
Entregables - Repositorio o servicio de asignación. - Contratos de
respuesta y errores.
Criterios de aceptación - La lógica de acceso a datos está separada
de los widgets. - Las consultas respetan las políticas de acceso. - Los
errores no exponen información sensible.
S5-07. Construir la lista de pedidos listos para asignar
Objetivo: ayudar al personal autorizado a identificar pedidos que
pueden pasar a reparto.
Actividades 1. Reutilizar la lista operativa del Sprint 4. 2.
Filtrar pedidos en el estado aprobado para asignación. 3. Mostrar
identificador, fecha y datos mínimos para reconocer el pedido. 4. Añadir
estados de carga, vacío y error. 5. Actualizar la lista después de
asignar un pedido.
Entregables - Pantalla de pedidos disponibles para asignación.
Criterios de aceptación - Solo aparecen pedidos que cumplen las
reglas de asignación. - Los pedidos asignados dejan de aparecer en la
lista disponible cuando corresponda. - La lista muestra información
persistida.
S5-08. Construir la selección de repartidor
Objetivo: permitir elegir un repartidor habilitado para un pedido.
Actividades 1. Mostrar únicamente repartidores habilitados y
autorizados. 2. Identificar cada opción con los datos mínimos
necesarios. 3. Mostrar un estado vacío si no hay repartidores
disponibles. 4. Validar que se haya seleccionado un repartidor antes de
confirmar. 5. Evitar enviar una asignación mientras otra está en curso.
Entregables - Selector de repartidor. - Validaciones de selección.
Criterios de aceptación - No se puede confirmar sin una selección
válida. - Los usuarios no habilitados no aparecen como opciones. - Los
errores se presentan con mensajes claros.
S5-09. Implementar confirmación de asignación
Objetivo: registrar una asignación de forma consistente.
Actividades 1. Mostrar un resumen breve del pedido y del repartidor
seleccionado. 2. Solicitar confirmación antes de guardar. 3. Ejecutar la
operación en el servidor. 4. Validar que el pedido continúe en el estado
permitido. 5. Actualizar la interfaz solo tras recibir confirmación.
Entregables - Flujo de asignación con confirmación. - Manejo de
conflictos y errores.
Criterios de aceptación - Una asignación válida queda persistida. -
Si el pedido cambió de estado, la operación se rechaza y se actualiza la
vista. - Los toques repetidos no generan asignaciones inconsistentes.
S5-10. Mostrar pedidos asignados al repartidor
Objetivo: permitir al repartidor revisar su carga de trabajo.
Actividades 1. Crear una pantalla con los pedidos asignados al
usuario autenticado. 2. Mostrar identificador, estado y datos de destino
autorizados. 3. Ordenar los pedidos con un criterio definido por el
negocio. 4. Permitir abrir el detalle. 5. Añadir estados de carga, lista
vacía y error.
Entregables - Pantalla de pedidos asignados. - Consulta limitada al
usuario autenticado.
Criterios de aceptación - El repartidor solo ve los pedidos
permitidos. - La lista refleja asignaciones guardadas. - Los pedidos no
asignados al usuario no se muestran.
S5-11. Implementar el detalle de reparto
Objetivo: presentar la información necesaria para dirigirse al
destino.
Actividades 1. Mostrar el identificador y estado del pedido. 2.
Mostrar solo los datos de destino aprobados. 3. Mostrar los productos o
detalles necesarios para la operación, según el permiso del rol. 4.
Manejar información de destino incompleta o inválida. 5. No incluir
todavía acciones de entrega completada o incidencia.
Entregables - Pantalla de detalle de reparto.
Criterios de aceptación - El detalle muestra datos coherentes con la
asignación. - No se revela información personal innecesaria. - Las
acciones del Sprint 6 no aparecen como funcionalidad disponible.
S5-12. Abrir navegación externa
Objetivo: facilitar la navegación al destino sin desarrollar un
sistema propio de mapas.
Actividades 1. Verificar qué dato de destino se encuentra disponible
y autorizado: coordenadas o dirección. 2. Generar un enlace de
navegación con los datos validados. 3. Abrir el enlace mediante el
mecanismo apropiado del dispositivo. 4. Manejar dispositivos sin una
aplicación compatible o enlaces inválidos. 5. Probar el comportamiento
en dispositivos Android compatibles con el mínimo del proyecto.
Entregables - Acción para abrir navegación externa. - Validación de
datos y manejo de errores.
Criterios de aceptación - El enlace se abre solo cuando el destino
es válido. - Si no puede abrirse, la aplicación informa al usuario y
muestra los datos disponibles autorizados. - No se implementa
seguimiento GPS continuo ni se solicita ubicación del repartidor si no
es necesaria.
S5-13. Manejar reasignaciones y conflictos
Objetivo: evitar que varios usuarios asignen simultáneamente un
pedido de forma inconsistente.
Actividades 1. Definir si se permite reasignar y en qué estados. 2.
Validar la asignación actual en el servidor antes de cambiarla. 3.
Registrar la reasignación si el proceso requiere trazabilidad. 4.
Informar cuando otro usuario ya asignó el pedido. 5. Refrescar las
listas de disponibilidad y asignación.
Entregables - Reglas de conflicto y reasignación. - Pruebas de
concurrencia.
Criterios de aceptación - La asignación respeta las reglas
aprobadas. - Un conflicto no produce un estado inconsistente. - La
reasignación no se habilita si no fue aprobada.
S5-14. Pruebas unitarias y de integración
Objetivo: verificar las reglas de asignación, permisos y navegación.
Actividades 1. Probar asignación válida e inválida. 2. Probar
repartidor no habilitado. 3. Probar acceso a pedidos asignados a otro
usuario. 4. Probar pedido en un estado no asignable. 5. Probar destino
incompleto y fallo al abrir navegación. 6. Probar actualización de lista
después de asignar.
Entregables - Pruebas automatizadas. - Evidencias de ejecución y
registro de defectos.
Criterios de aceptación - Las reglas críticas tienen pruebas
positivas y negativas. - Los errores de autorización se manejan
correctamente. - Las pruebas usan datos ficticios o aprobados.
S5-15. Documentar el módulo
Objetivo: dejar el módulo preparado para mantenimiento y revisión.
Actividades 1. Documentar el flujo de asignación. 2. Documentar
estados, roles, RLS y migraciones. 3. Explicar la configuración de
navegación externa. 4. Actualizar README y tablero. 5. Registrar
pendientes del Sprint 6.
Entregables - Documentación técnica y funcional actualizada.
Criterios de aceptación - Otro desarrollador puede comprender el
módulo y ejecutar las pruebas. - No se incluyen credenciales ni datos
sensibles en el repositorio.
S5-16. Integración, revisión y demostración
Objetivo: entregar un incremento funcional y verificable.
Actividades 1. Integrar cambios mediante Pull Request. 2. Ejecutar
`flutter analyze` y las pruebas disponibles. 3. Revisar las políticas de
acceso y las migraciones. 4. Corregir defectos críticos. 5. Demostrar
asignación, consulta del repartidor y apertura de navegación externa.
Entregables - Código integrado. - Evidencias de pruebas. - Informe
de revisión del Sprint.
Criterios de aceptación - El flujo aprobado funciona en el entorno
de pruebas. - No quedan defectos críticos abiertos en la asignación o
exposición de datos. - Los pendientes quedan registrados para el
siguiente Sprint.
---
6. Historias de usuario sugeridas
HU-05-01 --- Asignar pedido a un repartidor
Como usuario autorizado, quiero asignar un pedido listo a un
repartidor habilitado, para preparar la siguiente etapa de atención.
Criterios de aceptación - Solo se asignan pedidos en el estado
permitido. - Solo se eligen repartidores habilitados. - El servidor
confirma la asignación. - Los conflictos se rechazan y se informan.
HU-05-02 --- Consultar pedidos asignados
Como repartidor autenticado, quiero consultar los pedidos que
tengo asignados, para organizar mi trabajo.
Criterios de aceptación - Solo se muestran pedidos asignados al
usuario o permitidos por su rol. - La lista muestra el estado actual. -
Se puede abrir el detalle.
HU-05-03 --- Navegar al destino
Como repartidor, quiero abrir una aplicación de mapas con el
destino de un pedido, para orientarme durante el reparto.
Criterios de aceptación - El destino está disponible y validado. -
La aplicación externa se abre cuando el dispositivo lo permite. - Si el
enlace falla, se informa al usuario. - No se registra ubicación en
tiempo real.
---
7. Distribución sugerida de las dos semanas
---
Periodo                 Trabajo principal       Resultado revisable
---
Semana 1 --- días 1--2  Validar roles, estados  Reglas y modelo
y modelo de asignación  aprobados
Semana 1 --- días 3--4  Migraciones, RLS y      Asignación protegida
repositorio
Semana 1 --- día 5      Lista disponible y      Pedido listo para
selector de repartidor  asignar
Semana 2 --- días 1--2  Confirmación y lista    Pedidos asignados
del repartidor          visibles
Semana 2 --- días 3--4  Detalle, navegación     Flujo integrado
externa y pruebas
Semana 2 --- día 5      Correcciones,           Incremento revisado
documentación y  
demostración
La distribución puede ajustarse según la capacidad del equipo y los
bloqueos identificados, sin ampliar automáticamente el alcance.
8. Definition of Done (DoD)
Una tarea se considera terminada cuando:
[ ] Cumple sus criterios de aceptación.
[ ] Los roles y las reglas de asignación están documentados.
[ ] La autorización se aplica en el servidor o la base de datos.
[ ] Las consultas respetan RLS.
[ ] La aplicación confirma asignaciones solo tras respuesta exitosa.
[ ] Las reglas críticas tienen pruebas positivas y negativas.
[ ] Se ejecutan `flutter analyze` y las pruebas automatizadas
disponibles.
[ ] Las migraciones y políticas están versionadas y revisadas.
[ ] Los cambios pasan por revisión de código.
[ ] La documentación está actualizada.
[ ] La funcionalidad se demuestra en un entorno de pruebas.
9. Riesgos y controles
---
Riesgo                              Control
---
Asignación a un repartidor no       Validación del rol y habilitación
habilitado                          en el servidor
Repartidor consulta pedidos ajenos  RLS y pruebas con usuarios
distintos
Dos usuarios asignan el mismo       Validar estado y asignación actual
pedido                              de forma atómica
Dirección incompleta o inválida     Validar el destino y permitir
recuperación manual
Exposición de datos personales      Mostrar solo los datos necesarios
para el reparto
Dependencia de una aplicación de    Manejar enlaces no compatibles y
mapas                               fallos de apertura
Alcance crece a GPS en tiempo real  Mantener el seguimiento en tiempo
real fuera de este Sprint
10. Checklist de revisión del Sprint
[ ] Reglas de asignación y roles aprobadas.
[ ] Modelo de repartidores o rol de reparto definido.
[ ] Pedido listo se puede asignar a un repartidor habilitado.
[ ] Se rechazan asignaciones no autorizadas.
[ ] El repartidor ve sus pedidos asignados.
[ ] Se muestra solo información de destino autorizada.
[ ] La navegación externa funciona con un destino válido.
[ ] Los conflictos de asignación se manejan correctamente.
[ ] RLS y permisos se probaron con casos permitidos y denegados.
[ ] Pruebas y documentación están actualizadas.
[ ] El incremento fue integrado y demostrado.
11. Preparación del Sprint 6
El Sprint 6 abordará el resultado de la entrega y el registro de
incidencias. Antes de iniciarlo, definir:
Estados aprobados para pedido en reparto, entregado y no entregado.
Quién puede confirmar la entrega.
Qué evidencia de entrega se necesita y si está autorizada.
Qué motivos de incidencia estarán disponibles.
Qué sucede con un pedido no entregado y quién decide el siguiente
paso.
Qué información debe quedar registrada para auditoría.
No asumir que se requiere fotografía, firma, ubicación GPS, cobro en
efectivo ni captura de datos adicionales; cada elemento necesita una
decisión de negocio y una revisión de privacidad.
12. Resultado final esperado
Al cierre del Sprint 5, el sistema debe permitir que personal autorizado
asigne pedidos listos a repartidores habilitados, y que estos consulten
sus pedidos y abran una navegación externa al destino cuando la
información esté disponible.
La entrega completada y la gestión de incidencias quedan para el Sprint
6. Este incremento no implica que la aplicación esté lista para
producción ni que exista integración con sistemas internos de MASS.