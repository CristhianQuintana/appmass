Informe de desarrollo --- Sprint 3
Aplicación móvil para minimarket MASS
Sprint: 3  
Duración propuesta: 2 semanas  
Metodología: Scrum con prácticas seleccionadas de XP y tablero
Kanban  
Tecnologías base: Flutter, Dart, Riverpod, `go_router`, Supabase,
PostgreSQL, Git y GitHub  
Resultado esperado: registro y consulta de pedidos desde la
aplicación, con persistencia en Supabase y controles de validación.
---
1. Objetivo del Sprint
Implementar el flujo inicial de gestión de pedidos: permitir que un
usuario autorizado registre un pedido con uno o varios productos del
catálogo, revise los importes calculados por el sistema y consulte los
pedidos registrados.
Al finalizar el Sprint, el equipo debe poder demostrar el flujo completo
en un entorno de pruebas, desde la selección de productos hasta la
persistencia del pedido y sus detalles en PostgreSQL.
2. Alcance
Incluido
Revisar el modelo de datos y el catálogo implementados en el Sprint
2.
Definir y validar el flujo de registro de pedidos.
Mostrar los productos disponibles y permitir seleccionarlos.
Gestionar cantidades y eliminar productos de un pedido antes de
guardarlo.
Calcular subtotales y total en la aplicación para presentación, y
validar los importes críticos en el backend o en la base de datos.
Registrar el pedido y sus líneas de detalle de forma consistente.
Mostrar confirmación o errores comprensibles.
Consultar una lista de pedidos registrados y ver el detalle de cada
pedido.
Aplicar autorización y políticas RLS según los roles aprobados.
Implementar pruebas automatizadas y documentación.
Fuera de alcance
Flujo completo de preparación del pedido y cambios de estado
operativos.
Asignación de repartidores, navegación y seguimiento de entregas.
Pagos digitales, pasarela de pago o cobros automáticos.
Integración con sistemas internos de MASS, ERP, POS o inventario
corporativo.
Descuentos, cupones, promociones complejas o precios dinámicos,
salvo aprobación expresa.
Registro de pedidos directamente por clientes externos, si el MVP
acordado contempla registro por personal autorizado.
Regla de alcance: no conectar la aplicación a sistemas, datos,
marcas o servicios internos de MASS sin autorización expresa. Utilizar
un entorno propio de pruebas y datos ficticios cuando no exista acceso
aprobado.
3. Dependencias de entrada
Antes de iniciar las tareas, comprobar que:
El Sprint 1 permite iniciar sesión y controlar el acceso según el
rol.
El Sprint 2 entrega el catálogo, el modelo de productos y las
migraciones de base de datos.
Las tablas `products`, `orders` y `order_items` están definidas o
existe una decisión documentada equivalente.
Las políticas RLS necesarias están configuradas y probadas.
El entorno de desarrollo utiliza credenciales de prueba; no se
incluyen secretos en el repositorio.
Están definidos los campos mínimos del pedido, la moneda y la regla
de redondeo.
Si alguna dependencia no está lista, registrar el bloqueo en el tablero
y resolverlo antes de integrar el flujo completo.
---
4. Plan de tareas del desarrollador
S3-01. Revisar requisitos y flujo del pedido
Objetivo: convertir el alcance del Sprint en un flujo implementable
y verificable.
Actividades 1. Revisar historias de usuario, roles y criterios de
aceptación previos. 2. Definir los pasos: abrir catálogo, seleccionar
productos, editar cantidades, revisar resumen y confirmar registro. 3.
Definir los estados iniciales permitidos para un pedido, sin implementar
todavía el ciclo operativo de preparación. 4. Acordar qué información se
muestra en la lista y en el detalle. 5. Registrar las decisiones
pendientes y las exclusiones del Sprint.
Entregables - Flujo de registro y consulta de pedidos. - Historias
de usuario y criterios de aceptación actualizados.
Criterios de aceptación - El flujo puede explicarse y probarse de
principio a fin. - No hay contradicciones con el alcance del MVP. - Las
decisiones no resueltas quedan registradas, no se asumen como reglas de
negocio definitivas.
S3-02. Definir el contrato de datos del pedido
Objetivo: establecer la estructura que se guardará en la base de
datos.
Actividades 1. Revisar las tablas `orders` y `order_items` y sus
relaciones con usuarios y productos. 2. Verificar campos mínimos, claves
foráneas, restricciones y marcas de tiempo. 3. Definir cómo se
representa el precio aplicado al producto en el momento de crear el
pedido. 4. Definir qué datos son obligatorios y qué valores se asignan
en el servidor. 5. Confirmar cómo se identifica al usuario que registra
el pedido.
Entregables - Especificación del modelo de pedido y sus detalles. -
Migración SQL versionada si se requiere un ajuste.
Criterios de aceptación - Cada detalle pertenece a un pedido válido
y referencia un producto válido. - Las cantidades deben ser positivas. -
Los importes se almacenan con un tipo decimal apropiado, no con coma
flotante binaria. - El pedido conserva el precio aplicado al momento del
registro, si así lo establece la regla aprobada.
S3-03. Implementar validación del pedido
Objetivo: impedir que se guarden pedidos vacíos o con datos
inconsistentes.
Actividades 1. Validar que el pedido contenga al menos un producto.
2. Validar que cada cantidad sea un entero positivo dentro de los
límites definidos. 3. Validar que los productos existan y estén
disponibles para el flujo aprobado. 4. Evitar confiar únicamente en los
importes calculados en el dispositivo. 5. Mostrar mensajes de validación
claros y asociados al campo o producto correspondiente.
Entregables - Reglas de validación en la interfaz y en el lado
confiable del sistema. - Pruebas para datos válidos e inválidos.
Criterios de aceptación - No se puede registrar un pedido vacío. -
No se aceptan cantidades cero, negativas o mal formadas. - Un usuario no
puede alterar el total final enviando un importe arbitrario desde el
cliente. - Los errores se muestran sin cerrar inesperadamente la
aplicación.
S3-04. Crear el modelo Dart del pedido
Objetivo: representar los pedidos y sus líneas de detalle en el
código Flutter.
Actividades 1. Crear modelos tipados para pedido, detalle y resumen
del pedido. 2. Implementar conversión segura desde y hacia el formato de
Supabase. 3. Manejar valores nulos y fechas de manera explícita. 4.
Evitar mezclar lógica de presentación con acceso a datos.
Entregables - Modelos Dart de pedido y detalle. - Pruebas unitarias
de serialización y validación.
Criterios de aceptación - Los modelos pueden convertir datos de
prueba en ambas direcciones. - Los campos requeridos y los tipos están
documentados. - Las pruebas cubren datos válidos y casos de error
relevantes.
S3-05. Implementar el repositorio de pedidos
Objetivo: centralizar las operaciones de lectura y escritura de
pedidos.
Actividades 1. Crear un repositorio para registrar pedidos. 2. Crear
operaciones para listar pedidos y consultar el detalle. 3. Manejar
errores de red, autorización, validación y persistencia. 4. Mantener la
interfaz desacoplada de las consultas SQL/API. 5. Garantizar que el
encabezado y las líneas se registren como una sola operación lógica;
usar una transacción o función del lado servidor cuando corresponda.
Entregables - Repositorio de pedidos. - Contratos de respuesta y
tratamiento de errores.
Criterios de aceptación - La interfaz no realiza consultas de base
de datos dispersas en múltiples widgets. - El sistema no deja pedidos
parcialmente registrados cuando falla el guardado de sus detalles. - Los
errores se pueden identificar y mostrar sin exponer información
sensible.
S3-06. Construir la selección de productos
Objetivo: permitir al usuario agregar productos del catálogo a un
pedido en preparación.
Actividades 1. Reutilizar la pantalla y el repositorio del catálogo
del Sprint 2. 2. Incorporar una acción para añadir un producto. 3.
Permitir aumentar o disminuir la cantidad y quitar un producto. 4.
Evitar líneas duplicadas del mismo producto, acumulando su cantidad
cuando corresponda. 5. Mostrar un estado vacío y una indicación cuando
no haya productos disponibles.
Entregables - Pantalla o componente de selección de productos. -
Estado del pedido en preparación.
Criterios de aceptación - Se pueden agregar uno o varios
productos. - La cantidad se actualiza de forma consistente. - Al quitar
un producto, los subtotales y el total se actualizan. - La pantalla
contempla estados de carga, error y catálogo vacío.
S3-07. Construir el resumen y la confirmación
Objetivo: permitir revisar los productos e importes antes de
registrar el pedido.
Actividades 1. Mostrar producto, cantidad, precio aplicado y
subtotal. 2. Mostrar el total con formato de moneda coherente con la
configuración aprobada. 3. Implementar una pantalla o diálogo de
confirmación. 4. Deshabilitar el botón de guardado mientras la operación
está en curso. 5. Evitar envíos duplicados por toques repetidos.
Entregables - Resumen del pedido. - Confirmación antes del registro.
Criterios de aceptación - Los subtotales y el total corresponden a
las cantidades y precios mostrados. - El botón indica que la operación
está en curso y no permite duplicar el envío. - El usuario puede volver
a editar el pedido antes de confirmar. - La moneda y el redondeo siguen
la regla documentada.
S3-08. Registrar el pedido en Supabase
Objetivo: persistir el pedido y sus detalles de forma segura y
consistente.
Actividades 1. Conectar la confirmación con el repositorio. 2.
Enviar solo los datos que el cliente está autorizado a proporcionar. 3.
Asignar en el servidor los campos que no deben confiarse al dispositivo,
como el usuario autenticado y el estado inicial cuando corresponda. 4.
Aplicar validación del lado servidor y permisos RLS. 5. Confirmar el
resultado y limpiar el borrador únicamente cuando el registro haya
finalizado correctamente.
Entregables - Flujo funcional de registro conectado a Supabase. -
Validación y autorización del registro.
Criterios de aceptación - Un pedido válido se guarda con sus
detalles. - Si falla el guardado, el usuario recibe un mensaje y puede
reintentar sin generar duplicados. - El usuario no puede registrar
pedidos atribuidos a otro usuario mediante la modificación del
cliente. - No se guardan secretos privilegiados en el código Flutter.
S3-09. Mostrar confirmación del registro
Objetivo: informar de forma inequívoca que el pedido se registró
correctamente.
Actividades 1. Mostrar confirmación visual. 2. Mostrar un
identificador legible del pedido cuando esté disponible. 3. Permitir
volver al catálogo o abrir el detalle del pedido. 4. Diferenciar
confirmación real del servidor de una operación pendiente o fallida.
Entregables - Estado de éxito y navegación posterior al registro.
Criterios de aceptación - La confirmación solo aparece después de
que el servidor confirme el registro. - Si la operación falla, no se
presenta como exitosa. - La navegación posterior no borra ni duplica
pedidos ya guardados.
S3-10. Implementar la lista de pedidos
Objetivo: permitir consultar los pedidos que el usuario está
autorizado a ver.
Actividades 1. Crear una pantalla de lista. 2. Mostrar
identificador, fecha, total y estado inicial disponible. 3. Implementar
actualización manual o recarga al volver a la pantalla. 4. Ordenar por
fecha de creación, con un criterio consistente. 5. Incorporar estados de
carga, lista vacía y error.
Entregables - Pantalla de pedidos registrados. - Consulta paginada o
limitada si el volumen de datos lo requiere.
Criterios de aceptación - Se muestran únicamente los pedidos
permitidos por las políticas de acceso. - La lista refleja pedidos
guardados en el servidor. - La pantalla comunica claramente si no
existen registros o si ocurrió un error.
S3-11. Implementar el detalle del pedido
Objetivo: permitir inspeccionar los productos y los importes de un
pedido registrado.
Actividades 1. Mostrar identificador y fecha. 2. Mostrar las líneas
de detalle con cantidades, precios y subtotales. 3. Mostrar el total
registrado. 4. Manejar identificadores inexistentes o pedidos no
autorizados. 5. Mantener el detalle en modo de consulta; los cambios de
estado se desarrollarán en el Sprint 4.
Entregables - Pantalla de detalle de pedido.
Criterios de aceptación - Los importes mostrados coinciden con los
datos persistidos. - Un pedido inexistente o no autorizado no revela
información de otros usuarios. - No se habilitan acciones operativas
fuera del alcance del Sprint.
S3-12. Configurar estados de interfaz
Objetivo: asegurar una experiencia consistente durante las
operaciones asíncronas.
Actividades 1. Gestionar estados de carga, éxito, vacío y error. 2.
Evitar solicitudes repetidas innecesarias. 3. Mantener el estado de la
selección de productos durante las validaciones. 4. Revisar navegación
hacia atrás y recuperación ante errores. 5. Añadir mensajes de error
comprensibles sin mostrar trazas internas.
Entregables - Estados de interfaz para registro, lista y detalle.
Criterios de aceptación - Ninguna pantalla queda bloqueada
indefinidamente. - Los errores no eliminan el pedido en preparación. -
Los mensajes no exponen tokens, consultas sensibles ni detalles
internos.
S3-13. Verificar RLS y permisos
Objetivo: comprobar que la autorización funciona también en la base
de datos.
Actividades 1. Probar el registro con una sesión autenticada y con
sesión ausente. 2. Probar lectura de pedidos propios y de pedidos ajenos
según los roles aprobados. 3. Verificar que los detalles respeten las
mismas restricciones de acceso. 4. Probar intentos de modificar campos
protegidos. 5. Documentar las políticas aplicadas y los resultados.
Entregables - Pruebas de autorización y RLS. - Registro de hallazgos
y correcciones.
Criterios de aceptación - La seguridad no depende solo de ocultar
botones en Flutter. - Los accesos no autorizados son rechazados por el
backend/base de datos. - Las pruebas negativas quedan documentadas.
S3-14. Pruebas unitarias
Objetivo: verificar reglas de negocio sin depender de la interfaz.
Actividades 1. Probar cálculo de subtotal y total. 2. Probar
actualización y eliminación de líneas. 3. Probar cantidades inválidas y
pedido vacío. 4. Probar serialización de modelos. 5. Probar tratamiento
de errores del repositorio mediante dependencias simuladas cuando
corresponda.
Entregables - Suite de pruebas unitarias.
Criterios de aceptación - Las reglas críticas cuentan con pruebas
reproducibles. - Los casos límite definidos por el equipo están
cubiertos. - Las pruebas se ejecutan localmente y en CI si el flujo de
CI ya está habilitado.
S3-15. Pruebas de integración y de interfaz
Objetivo: comprobar el flujo entre la aplicación, el repositorio y
el entorno de prueba.
Actividades 1. Probar la selección y edición de productos. 2. Probar
el registro de un pedido válido. 3. Probar el rechazo de un pedido vacío
o inválido. 4. Probar la consulta de lista y detalle. 5. Verificar los
escenarios de carga, error y reintento.
Entregables - Pruebas de integración o widget tests según el entorno
disponible. - Evidencias de ejecución.
Criterios de aceptación - El flujo principal se puede ejecutar sin
intervención manual en cada paso de prueba. - Los errores previstos se
manejan correctamente. - Los datos de prueba no corresponden a clientes
reales.
S3-16. Documentar el módulo
Objetivo: dejar el módulo listo para revisión y mantenimiento.
Actividades 1. Documentar flujo, modelos, repositorio y decisiones
de negocio. 2. Registrar migraciones, políticas RLS y configuración de
entorno necesaria. 3. Documentar cómo ejecutar las pruebas. 4.
Actualizar README y tablero de tareas. 5. Registrar deuda técnica y
decisiones pendientes para el siguiente Sprint.
Entregables - Documentación técnica y funcional actualizada. -
Instrucciones de ejecución y pruebas.
Criterios de aceptación - Otro desarrollador puede comprender el
módulo y ejecutar sus pruebas siguiendo la documentación. - No se
incluyen credenciales ni datos sensibles en los archivos versionados.
S3-17. Integración, revisión y demostración
Objetivo: entregar un incremento funcional revisable al cierre del
Sprint.
Actividades 1. Integrar cambios mediante Pull Request. 2. Ejecutar
análisis estático, pruebas y revisión de permisos. 3. Corregir defectos
críticos encontrados. 4. Realizar una demostración del flujo completo.
5. Registrar resultados, bloqueos y tareas para el Sprint 4.
Entregables - Rama principal integrada. - Evidencias de pruebas y
demostración. - Informe de revisión del Sprint.
Criterios de aceptación - El flujo catálogo → selección → resumen →
registro → lista → detalle funciona en el entorno de prueba. - Las
pruebas acordadas pasan. - No quedan defectos críticos abiertos
relacionados con el registro o la exposición de pedidos. - El equipo
registra qué quedó pendiente y por qué.
---
5. Historias de usuario sugeridas
HU-03-01 --- Registrar pedido
Como usuario autorizado, quiero seleccionar productos y sus
cantidades, para registrar un pedido con importes consistentes.
Criterios de aceptación - El pedido contiene al menos un producto. -
Las cantidades son válidas. - El sistema calcula y valida los
importes. - El pedido y sus detalles se guardan de forma consistente. -
Se informa el resultado de la operación.
HU-03-02 --- Consultar pedidos
Como usuario autorizado, quiero ver los pedidos que puedo
consultar, para revisar los registros realizados.
Criterios de aceptación - La lista muestra identificador, fecha,
total y estado inicial disponible. - Se puede abrir el detalle de un
pedido. - Los permisos se aplican tanto a la lista como al detalle.
HU-03-03 --- Revisar el detalle
Como usuario autorizado, quiero consultar los productos,
cantidades y totales de un pedido, para verificar la información
registrada.
Criterios de aceptación - El detalle refleja los datos
persistidos. - No se permite consultar información no autorizada. - El
detalle no habilita todavía el flujo de preparación o entrega.
---
6. Distribución sugerida de las dos semanas
---
Periodo                 Trabajo principal       Resultado revisable
---
Semana 1 --- días 1--2  Requisitos, modelo y    Contrato de datos y
validaciones            reglas acordadas
Semana 1 --- días 3--4  Modelos Dart,           Selección de productos
repositorio y selección funcional
Semana 1 --- día 5      Resumen, importes y     Pedido preparado antes
revisión intermedia     de guardar
Semana 2 --- días 1--2  Registro persistente y  Pedido guardado en
confirmación            entorno de prueba
Semana 2 --- días 3--4  Lista, detalle, RLS y   Consulta segura de
pruebas                 pedidos
Semana 2 --- día 5      Correcciones,           Incremento integrado y
documentación y         probado
demostración
La distribución puede ajustarse según la capacidad del equipo y los
bloqueos identificados, sin ampliar automáticamente el alcance.
7. Definition of Done (DoD)
Una tarea se considera terminada cuando:
[ ] Cumple sus criterios de aceptación.
[ ] El código sigue la estructura acordada y las convenciones de
Dart/Flutter.
[ ] No se exponen secretos ni datos reales en el repositorio.
[ ] Las reglas críticas tienen pruebas.
[ ] Se ejecutan `flutter analyze` y las pruebas automatizadas
disponibles.
[ ] Las migraciones y políticas RLS están versionadas y revisadas
cuando corresponde.
[ ] Los cambios pasan por revisión de código.
[ ] La documentación se actualiza.
[ ] La funcionalidad se demuestra en un entorno de prueba.
8. Riesgos y controles
---
Riesgo                              Control
---
Totales manipulados desde el        Recalcular o validar importes en un
cliente                             componente confiable del servidor
Pedido guardado parcialmente        Usar operación transaccional o
función del servidor para
encabezado y detalles
Acceso a pedidos de otros usuarios  Aplicar y probar RLS en pedidos y
líneas de detalle
Envíos duplicados                   Deshabilitar el botón durante el
envío y definir una estrategia de
idempotencia si es necesaria
Catálogo sin datos aprobados        Usar datos ficticios en el entorno
de prueba
Cambios de alcance                  Registrar y aprobar cambios antes
de implementarlos
9. Checklist de revisión del Sprint
[ ] Se puede seleccionar uno o varios productos.
[ ] Se pueden modificar cantidades y quitar productos.
[ ] Se validan pedido vacío y cantidades inválidas.
[ ] El resumen presenta subtotales y total consistentes.
[ ] El pedido y sus detalles se guardan de forma consistente.
[ ] La aplicación confirma el registro solo tras respuesta exitosa.
[ ] Se muestra una lista de pedidos autorizados.
[ ] Se puede abrir el detalle de un pedido.
[ ] RLS se probó con casos permitidos y denegados.
[ ] Las pruebas unitarias y de integración acordadas pasan.
[ ] La documentación y las evidencias están actualizadas.
10. Condición de cierre y preparación del Sprint 4
El Sprint 3 se cierra cuando el equipo demuestra el flujo de registro y
consulta de pedidos, con persistencia, validaciones, permisos y pruebas.
Los pedidos deben tener un estado inicial definido, pero las
transiciones operativas se dejan para el siguiente Sprint.
Preparación del Sprint 4: definir el ciclo de estados del pedido y
sus transiciones permitidas ---por ejemplo, pendiente, en preparación y
listo---, las personas autorizadas para cambiarlos, las reglas de
transición y el historial mínimo necesario. Los nombres definitivos de
estados deben validarse con el responsable del proceso antes de
implementarlos.
11. Resultado final esperado
Al cierre del Sprint 3, la aplicación debe contar con un módulo
funcional para registrar pedidos a partir del catálogo y consultar sus
registros y detalles. El incremento debe estar integrado, documentado,
protegido por políticas de acceso y probado en un entorno controlado.
Este resultado no implica que el módulo esté listo para producción ni
que exista integración con los sistemas internos de MASS; eso requiere
autorización, validación técnica y pruebas específicas.