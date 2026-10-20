Informe de desarrollo --- Sprint 4
Aplicación móvil para minimarket MASS
Sprint: 4  
Duración propuesta: 2 semanas  
Metodología: Scrum con prácticas seleccionadas de XP y tablero
Kanban  
Tecnologías base: Flutter, Dart, Riverpod, `go_router`, Supabase,
PostgreSQL, Git y GitHub  
Resultado esperado: flujo de preparación de pedidos con estados
controlados, actualización segura y consulta del estado actual.
---
1. Objetivo del Sprint
Implementar el flujo operativo inicial para que el personal autorizado
pueda revisar los pedidos registrados, iniciar su preparación y marcar
cuándo están listos, respetando las transiciones de estado definidas por
el responsable del proceso.
Al finalizar el Sprint, el equipo debe demostrar que un pedido puede
avanzar por los estados operativos permitidos y que los cambios quedan
persistidos y visibles para los usuarios autorizados.
2. Alcance
Incluido
Confirmar con el responsable del proceso los estados y las
transiciones permitidas.
Definir permisos para consultar y actualizar pedidos.
Implementar en la base de datos la validación de transiciones cuando
corresponda.
Mostrar una lista de pedidos pendientes y sus estados.
Mostrar el detalle del pedido durante la preparación.
Permitir iniciar la preparación y marcar el pedido como listo, solo
a los roles autorizados.
Registrar fecha, usuario y cambio de estado cuando sea necesario
para la trazabilidad acordada.
Refrescar el estado mostrado después de una actualización.
Manejar errores, solicitudes repetidas y conflictos de
actualización.
Añadir pruebas automatizadas y documentación.
Fuera de alcance
Asignación de repartidores y gestión de rutas, que corresponden al
Sprint 5.
Confirmación de entrega, incidencias y cierre de reparto, previstos
para el Sprint 6.
Pagos digitales, facturación electrónica o integración con sistemas
internos.
Automatización de inventario o descuento de stock, salvo que exista
una regla de negocio aprobada y una fuente de inventario autorizada.
Notificaciones push, mensajería externa o seguimiento GPS en tiempo
real.
Cambios de estado realizados por clientes externos si el MVP está
destinado al personal operativo.
Regla de alcance: los nombres de los estados y las transiciones de
este documento son una propuesta que debe validarse con el responsable
del proceso antes de aplicarse en producción. No se deben conectar
sistemas o datos internos de MASS sin autorización expresa.
---
3. Dependencias de entrada
Antes de iniciar, verificar que:
El Sprint 3 permite registrar pedidos y consultar su lista y
detalle.
Los pedidos tienen un estado inicial persistido y coherente.
Los roles de usuario están definidos y la autenticación funciona.
Las políticas RLS están habilitadas y probadas.
Existe un entorno de pruebas separado de cualquier entorno
productivo.
El responsable del proceso confirma qué rol puede preparar pedidos y
qué condiciones permiten avanzar de estado.
Si las dependencias no están listas, registrar el bloqueo y resolverlo
antes de habilitar el flujo operativo.
---
4. Propuesta de ciclo de estados
La siguiente secuencia es una propuesta inicial para validar, no una
regla definitiva:
---
Estado                  Significado             Acción permitida
---
`pending`               Pedido registrado, aún  Iniciar preparación
no iniciado
`preparing`             El personal está        Marcar como listo
preparando el pedido
`ready`                 Pedido preparado y      Consultar; la
pendiente de la         asignación de entrega
siguiente etapa         se aborda en el Sprint
5
Transiciones propuestas:
`pending` → `preparing`
`preparing` → `ready`
No se debe permitir saltar directamente de `pending` a `ready`, ni
regresar de `ready` a `preparing`, salvo que el responsable apruebe
expresamente esas transiciones. Los estados de entrega se definirán en
los Sprints 5 y 6.
Los valores almacenados en la base de datos deben ser estables y estar
documentados. Las etiquetas que se muestran al usuario pueden estar
traducidas al español.
---
5. Plan de tareas del desarrollador
S4-01. Validar el flujo operativo
Objetivo: confirmar las reglas de negocio antes de codificar las
transiciones.
Actividades 1. Revisar el flujo de registro de pedidos del Sprint 3.
2. Consultar al responsable del proceso sobre estados, nombres y
significado de cada uno. 3. Definir qué rol puede iniciar y completar la
preparación. 4. Definir qué sucede si un pedido contiene datos
incorrectos o no puede prepararse. 5. Registrar decisiones y excepciones
aprobadas.
Entregables - Diagrama o descripción del flujo. - Tabla de estados y
transiciones aprobadas. - Historias de usuario actualizadas.
Criterios de aceptación - Cada estado tiene un significado y una
acción permitida. - Los roles autorizados están definidos. - Las
excepciones no se implementan por suposición.
S4-02. Diseñar el modelo de estados
Objetivo: representar los estados de forma consistente entre base de
datos y aplicación.
Actividades 1. Revisar la columna de estado de `orders`. 2. Definir
valores válidos y restricciones de integridad. 3. Evitar textos
arbitrarios o inconsistentes en la columna de estado. 4. Definir cómo se
representan la fecha de actualización y el usuario que actualizó el
pedido, si aplica. 5. Preparar una migración versionada cuando sea
necesario.
Entregables - Modelo de estados documentado. - Migración SQL y
restricciones, si se requieren.
Criterios de aceptación - La base de datos rechaza estados fuera del
conjunto permitido. - Los valores de estado coinciden con los que maneja
la aplicación. - La migración puede ejecutarse en el entorno de pruebas
y tiene una estrategia de reversión apropiada.
S4-03. Definir las transiciones válidas
Objetivo: evitar cambios de estado no permitidos.
Actividades 1. Crear una función o servicio del lado servidor para
validar el estado actual y el nuevo estado. 2. Aceptar únicamente
transiciones aprobadas. 3. Verificar que el pedido existe y que el
usuario está autorizado. 4. Rechazar actualizaciones que intenten saltar
etapas. 5. Definir respuestas claras para conflictos y transiciones
inválidas.
Entregables - Lógica de transición del lado servidor. - Pruebas de
transiciones válidas e inválidas.
Criterios de aceptación - Las transiciones no dependen únicamente de
controles visuales en Flutter. - Un usuario no autorizado no puede
cambiar el estado. - Una transición inválida se rechaza sin alterar el
registro.
S4-04. Configurar permisos y RLS
Objetivo: limitar la lectura y actualización de pedidos según el
rol.
Actividades 1. Revisar políticas de lectura de pedidos y detalles.
2. Definir qué roles pueden actualizar estados. 3. Restringir la
actualización a los campos autorizados. 4. Evitar que el usuario
modifique directamente el total, el creador o campos protegidos. 5.
Probar accesos permitidos y denegados.
Entregables - Políticas RLS revisadas. - Evidencias de pruebas de
autorización.
Criterios de aceptación - La seguridad se aplica en la base de datos
o servicio confiable, no solo en la interfaz. - Los usuarios sin permiso
no pueden actualizar estados. - Los intentos de alterar campos
protegidos son rechazados.
S4-05. Implementar el repositorio de estados
Objetivo: centralizar la consulta y actualización del estado de los
pedidos.
Actividades 1. Crear una operación para consultar pedidos por
estado. 2. Crear una operación para solicitar una transición. 3. Manejar
errores de red, autorización y conflicto. 4. Evitar consultas directas
dispersas en los widgets. 5. Asegurar que la aplicación solo presenta
una transición como completada tras la confirmación del servidor.
Entregables - Repositorio o servicio de operaciones de estado. -
Manejo de errores documentado.
Criterios de aceptación - La lógica de acceso a datos está separada
de la interfaz. - La interfaz no informa éxito antes de confirmar la
operación. - Los errores permiten reintentar de forma segura.
S4-06. Construir la lista de pedidos operativos
Objetivo: facilitar al personal autorizado la identificación de
pedidos pendientes de preparación.
Actividades 1. Reutilizar la lista de pedidos del Sprint 3. 2.
Mostrar identificador, fecha, estado y datos necesarios para reconocer
cada pedido. 3. Priorizar o agrupar por estado según el flujo aprobado.
4. Incorporar actualización manual o recarga al volver a la pantalla. 5.
Añadir estados de carga, lista vacía y error.
Entregables - Lista operativa de pedidos. - Filtros por estado si el
volumen y el flujo lo requieren.
Criterios de aceptación - La lista muestra datos persistidos y
actualizados. - El usuario solo ve los pedidos que su rol está
autorizado a consultar. - Los estados son comprensibles y consistentes.
S4-07. Mejorar el detalle para preparación
Objetivo: permitir revisar el contenido de un pedido antes de
actualizar su estado.
Actividades 1. Mostrar productos, cantidades, precios y total
registrado. 2. Mostrar el estado actual del pedido. 3. Mostrar fecha de
registro y otros datos estrictamente necesarios. 4. Deshabilitar
acciones no permitidas para el estado o rol actual. 5. Manejar pedidos
inexistentes, eliminados o no autorizados.
Entregables - Detalle operativo del pedido.
Criterios de aceptación - Los datos coinciden con los registros
persistidos. - La pantalla no ofrece acciones incompatibles con el
estado actual. - No se expone información ajena al rol del usuario.
S4-08. Implementar la acción "Iniciar preparación"
Objetivo: permitir pasar un pedido pendiente al estado de
preparación.
Actividades 1. Mostrar la acción solo cuando el usuario y el estado
la permitan. 2. Solicitar la transición al servidor. 3. Mostrar
indicador de progreso y prevenir toques repetidos. 4. Actualizar la
lista y el detalle después de una respuesta exitosa. 5. Informar si otro
usuario cambió el pedido antes de completar la acción.
Entregables - Acción de inicio de preparación.
Criterios de aceptación - Solo un pedido en estado inicial aprobado
puede iniciar preparación. - La actualización se confirma en el
servidor. - Los errores o conflictos no se muestran como éxito.
S4-09. Implementar la acción "Marcar como listo"
Objetivo: registrar que un pedido completó la preparación.
Actividades 1. Mostrar la acción solo para pedidos en preparación y
roles autorizados. 2. Solicitar confirmación si el proceso operativo lo
requiere. 3. Ejecutar la transición del lado servidor. 4. Refrescar la
lista y el detalle. 5. Preparar el pedido para la siguiente etapa, sin
implementar todavía la asignación de reparto.
Entregables - Acción para marcar un pedido como listo.
Criterios de aceptación - Solo se permite desde el estado
aprobado. - La operación queda persistida. - El pedido aparece con el
estado correcto después de actualizar la vista.
S4-10. Registrar trazabilidad de cambios
Objetivo: permitir identificar cómo y cuándo cambió el estado de un
pedido, según el nivel de auditoría aprobado.
Actividades 1. Definir si basta con `updated_at` y `updated_by` o si
se requiere una tabla de historial. 2. Si se requiere historial,
registrar estado anterior, estado nuevo, usuario y fecha. 3. Evitar que
el cliente pueda falsificar el usuario o la marca temporal. 4. Definir
quién puede consultar el historial. 5. Documentar el criterio elegido.
Entregables - Campos de auditoría o tabla de historial. - Migración
y pruebas, si corresponden.
Criterios de aceptación - La trazabilidad refleja los cambios reales
confirmados por el servidor. - Los campos de auditoría no pueden ser
manipulados por un cliente no confiable. - La solución es proporcional a
los requisitos aprobados.
S4-11. Manejar concurrencia y solicitudes duplicadas
Objetivo: prevenir inconsistencias cuando dos usuarios intentan
actualizar el mismo pedido.
Actividades 1. Comprobar el estado actual al ejecutar la transición.
2. Rechazar una segunda transición incompatible. 3. Deshabilitar la
acción mientras una solicitud está en curso. 4. Mostrar un mensaje si el
pedido cambió desde que se abrió. 5. Actualizar la vista con el estado
real del servidor.
Entregables - Control de conflictos y solicitudes repetidas.
Criterios de aceptación - Dos acciones concurrentes no producen una
transición inválida. - Una repetición no genera registros de auditoría
engañosos ni cambios adicionales. - El usuario puede actualizar la
pantalla y continuar con el estado real.
S4-12. Implementar estados de interfaz y errores
Objetivo: mantener una experiencia predecible durante las
operaciones.
Actividades 1. Implementar carga, éxito, error y estado vacío. 2.
Mostrar mensajes concretos para permisos insuficientes y transiciones no
válidas. 3. Conservar la información visible ante errores temporales. 4.
Evitar mostrar trazas técnicas o detalles sensibles. 5. Revisar
navegación hacia atrás y recarga.
Entregables - Manejo de estados y mensajes de error.
Criterios de aceptación - Ninguna operación queda bloqueada
indefinidamente. - Los errores no cambian visualmente el estado sin
confirmación del servidor. - La interfaz permite recuperarse de un fallo
temporal.
S4-13. Pruebas unitarias de transiciones
Objetivo: validar las reglas del ciclo de estados.
Actividades 1. Probar cada transición permitida. 2. Probar saltos de
estado no permitidos. 3. Probar estados desconocidos y pedidos
inexistentes. 4. Probar permisos insuficientes. 5. Probar solicitudes
repetidas y conflictos.
Entregables - Suite de pruebas unitarias para las reglas de estado.
Criterios de aceptación - Cada transición aprobada tiene al menos
una prueba positiva. - Las transiciones inválidas tienen pruebas
negativas. - Las reglas críticas se pueden ejecutar de forma
reproducible.
S4-14. Pruebas de integración, RLS y flujo de interfaz
Objetivo: verificar el ciclo completo en el entorno de pruebas.
Actividades 1. Registrar un pedido de prueba. 2. Avanzarlo por las
transiciones permitidas. 3. Confirmar que cada cambio se refleja en
lista y detalle. 4. Probar accesos desde roles permitidos y denegados.
5. Probar dos intentos concurrentes o una transición obsoleta cuando el
entorno lo permita.
Entregables - Pruebas de integración o de interfaz. - Evidencias de
resultados y defectos corregidos.
Criterios de aceptación - El flujo aprobado funciona de principio a
fin. - Los intentos no autorizados se rechazan. - La interfaz y la base
de datos mantienen el mismo estado.
S4-15. Documentar el módulo de preparación
Objetivo: facilitar el mantenimiento y la revisión del incremento.
Actividades 1. Documentar estados y transiciones aprobadas. 2.
Describir políticas RLS y operaciones del servidor. 3. Documentar
migraciones y cómo ejecutar las pruebas. 4. Actualizar README y tablero.
5. Registrar deuda técnica y pendientes para el Sprint 5.
Entregables - Documentación técnica y funcional actualizada.
Criterios de aceptación - Otro desarrollador puede comprender las
reglas y ejecutar las pruebas. - No se versionan secretos ni datos
reales.
S4-16. Integración, revisión y demostración
Objetivo: entregar un incremento funcional al cierre del Sprint.
Actividades 1. Integrar cambios mediante Pull Request. 2. Ejecutar
`flutter analyze` y las pruebas disponibles. 3. Revisar migraciones,
permisos y validaciones del lado servidor. 4. Corregir defectos
críticos. 5. Demostrar el ciclo de preparación y registrar los
pendientes.
Entregables - Código integrado. - Evidencias de pruebas. - Informe
de revisión del Sprint.
Criterios de aceptación - El ciclo de estados aprobado funciona en
el entorno de prueba. - No quedan defectos críticos abiertos en el flujo
de preparación. - Las limitaciones y pendientes están documentados.
---
6. Historias de usuario sugeridas
HU-04-01 --- Iniciar preparación
Como miembro del personal autorizado, quiero iniciar la
preparación de un pedido pendiente, para indicar que su atención
está en curso.
Criterios de aceptación - Solo se habilita para los roles
autorizados. - El pedido se encuentra en el estado correcto. - El
servidor confirma la transición. - La lista y el detalle reflejan el
nuevo estado.
HU-04-02 --- Marcar pedido como listo
Como miembro del personal autorizado, quiero marcar un pedido
como listo, para indicar que terminó la preparación.
Criterios de aceptación - Solo se permite desde el estado
aprobado. - La transición queda persistida. - No se implementa aún la
asignación del repartidor.
HU-04-03 --- Consultar estado operativo
Como usuario autorizado, quiero consultar el estado de los
pedidos, para conocer cuáles están pendientes, en preparación o
listos.
Criterios de aceptación - La lista refleja el estado persistido. -
Se puede abrir el detalle. - Las restricciones de acceso se aplican en
el servidor.
---
7. Distribución sugerida de las dos semanas
---
Periodo                 Trabajo principal       Resultado revisable
---
Semana 1 --- días 1--2  Validar estados, roles  Flujo aprobado y
y transiciones          documentado
Semana 1 --- días 3--4  Migraciones, reglas del Transiciones seguras
servidor y RLS
Semana 1 --- día 5      Repositorio y lista     Pedidos consultables
operativa               por estado
Semana 2 --- días 1--2  Detalle y acciones de   Inicio y fin de
preparación             preparación
Semana 2 --- días 3--4  Trazabilidad,           Flujo integrado y
concurrencia y pruebas  verificado
Semana 2 --- día 5      Correcciones,           Incremento revisado
documentación y  
demostración
La distribución puede ajustarse según la capacidad del equipo y los
bloqueos identificados, sin ampliar automáticamente el alcance.
8. Definition of Done (DoD)
Una tarea se considera terminada cuando:
[ ] Cumple sus criterios de aceptación.
[ ] Las transiciones coinciden con las reglas aprobadas.
[ ] Los permisos se aplican en el servidor o la base de datos.
[ ] Los cambios de estado se confirman antes de mostrarse como
exitosos.
[ ] Existen pruebas positivas y negativas para las reglas críticas.
[ ] Se ejecutan `flutter analyze` y las pruebas automatizadas
disponibles.
[ ] Las migraciones y políticas están versionadas y revisadas.
[ ] El código pasa por revisión.
[ ] La documentación está actualizada.
[ ] La funcionalidad se demuestra en un entorno de pruebas.
9. Riesgos y controles
---
Riesgo                              Control
---
Estados definidos sin validación    Confirmar la máquina de estados con
del negocio                         el responsable antes de implementar
Usuario cambia un estado sin        Validación del lado servidor y RLS
autorización
Salto de etapas                     Permitir únicamente transiciones
explícitas
Dos usuarios actualizan             Validar el estado actual en la
simultáneamente                     operación de transición
Interfaz muestra un estado que no   Actualizar la interfaz solo tras
se guardó                           confirmación del servidor
Historial de cambios falsificable   Generar usuario y fecha desde un
componente confiable
Alcance crece hacia reparto o pagos Mantener esos flujos en sus Sprints
definidos
10. Checklist de revisión del Sprint
[ ] Estados y transiciones confirmados con el responsable.
[ ] Lista de pedidos operativa.
[ ] Detalle del pedido muestra el estado actual.
[ ] Acción de iniciar preparación funciona.
[ ] Acción de marcar como listo funciona.
[ ] Transiciones inválidas son rechazadas.
[ ] Roles y RLS se probaron con casos permitidos y denegados.
[ ] Solicitudes duplicadas y conflictos se manejan correctamente.
[ ] La interfaz refleja los datos confirmados por el servidor.
[ ] Pruebas y documentación están actualizadas.
[ ] El incremento fue revisado y demostrado.
11. Preparación del Sprint 5
El Sprint 5 abordará la asignación de pedidos listos al personal de
reparto y la navegación hacia el destino, según el alcance aprobado.
Antes de iniciarlo, definir:
Cómo se registran y autorizan los repartidores.
Si la asignación será manual por personal autorizado.
Qué información de destino está aprobada para almacenar y mostrar.
Si la aplicación abrirá una aplicación externa de mapas mediante un
enlace, sin implementar GPS en tiempo real.
Qué estado representa un pedido asignado o en reparto.
Qué restricciones de privacidad se aplican a los datos de dirección
y contacto.
No implementar seguimiento GPS en tiempo real, notificaciones push ni
integración con sistemas de despacho sin una decisión explícita de
alcance.
12. Resultado final esperado
Al cierre del Sprint 4, la aplicación debe permitir que personal
autorizado consulte los pedidos registrados, inicie su preparación y los
marque como listos mediante transiciones controladas. Los cambios deben
persistir, respetar permisos y poder verificarse en pruebas.
Este resultado no implica que el módulo esté listo para producción ni
que exista integración con sistemas internos de MASS; eso requiere
autorización, validación técnica y pruebas específicas.