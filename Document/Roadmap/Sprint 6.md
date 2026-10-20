Informe de desarrollo --- Sprint 6
Aplicación móvil para minimarket MASS
Sprint: 6  
Duración propuesta: 2 semanas  
Metodología: Scrum con prácticas seleccionadas de XP y tablero
Kanban  
Tecnologías base: Flutter, Dart, Riverpod, `go_router`, Supabase,
PostgreSQL, Git y GitHub  
Resultado esperado: registro del resultado de la entrega y gestión
básica de incidencias con estados, permisos y trazabilidad.
---
1. Objetivo del Sprint
Implementar el cierre operativo de un pedido asignado a un repartidor:
permitir registrar si la entrega se completó o no, guardar el resultado
y, cuando corresponda, registrar una incidencia con un motivo definido
por el negocio.
Al finalizar el Sprint, el sistema debe reflejar el resultado confirmado
por el servidor, impedir cambios no autorizados y conservar la
información mínima necesaria para consultar qué ocurrió con el pedido.
2. Alcance
Incluido
Validar con el responsable del proceso los estados finales y las
reglas de entrega.
Definir quién puede registrar el resultado de una entrega.
Implementar el flujo de entrega completada y entrega no completada,
según reglas aprobadas.
Registrar incidencias con un catálogo controlado de motivos.
Asociar el resultado al pedido y al usuario autorizado que lo
registra.
Guardar fecha y hora del registro desde un componente confiable.
Mostrar el estado y el resultado de entrega en la lista y el detalle
del pedido.
Manejar errores, reintentos y solicitudes duplicadas.
Proteger operaciones con validación del lado servidor y RLS.
Añadir pruebas automatizadas, documentación y evidencias.
Fuera de alcance
Seguimiento GPS en tiempo real.
Captura obligatoria de fotografías, firmas o documentos, salvo
aprobación explícita.
Pagos digitales, cobro automatizado o facturación electrónica.
Reintentos de reparto automatizados, optimización de rutas o
asignación inteligente.
Notificaciones push, SMS o WhatsApp automatizados.
Integraciones con sistemas internos de MASS.
Analítica avanzada, paneles corporativos o informes operativos
extensos.
Regla de alcance: no se debe recopilar evidencia, ubicación o
información personal adicional sin una decisión de negocio y revisión de
privacidad. Utilizar datos ficticios o autorizados en el entorno de
pruebas.
---
3. Dependencias de entrada
Antes de iniciar, verificar que:
El Sprint 3 permite registrar y consultar pedidos.
El Sprint 4 permite preparar pedidos y marcarlos como listos.
El Sprint 5 permite asignar pedidos a repartidores y mostrar sus
pedidos asignados.
Los roles de personal operativo y repartidor están definidos.
Las políticas RLS están activas y probadas.
Los estados de reparto y las reglas de entrega pueden ser validados
por el responsable del proceso.
Si las dependencias no están listas, registrar el bloqueo y resolverlo
antes de habilitar el cierre de entregas.
---
4. Propuesta de estados para validar
Los estados siguientes son una propuesta de trabajo y deben ser
aprobados por el responsable del proceso:
---
Estado                  Significado             Acción siguiente
---
`assigned`              El pedido fue asignado  Iniciar reparto, si el
a un repartidor         proceso lo requiere
`in_delivery`           El pedido está en       Registrar el resultado
proceso de entrega
`delivered`             La entrega fue          Consulta; cierre
completada              operativo
`delivery_failed`       La entrega no pudo      Registrar o revisar
completarse             incidencia
La transición desde `assigned` hacia `in_delivery` solo se implementará
si el proceso aprobado la requiere y no fue cubierta en el Sprint 5. No
habilitar transiciones arbitrarias ni permitir que el cliente establezca
libremente estados finales.
La política para un pedido `delivery_failed` ---por ejemplo,
reasignarlo, reprogramarlo o devolverlo a una cola operativa--- debe
definirse con el responsable. No se debe elegir una acción automática
por suposición.
---
5. Plan de tareas del desarrollador
S6-01. Validar el cierre de entrega
Objetivo: acordar qué significa completar o no completar una
entrega.
Actividades 1. Revisar el flujo de pedidos asignados del Sprint 5.
2. Definir quién puede registrar el resultado. 3. Confirmar los estados
finales y las transiciones permitidas. 4. Definir qué sucede después de
una entrega fallida. 5. Determinar si se requiere evidencia de entrega y
qué datos están autorizados.
Entregables - Flujo de cierre de entrega aprobado. - Tabla de
estados y transiciones. - Historias de usuario y criterios de aceptación
actualizados.
Criterios de aceptación - Las reglas para éxito y fallo están
documentadas. - Las responsabilidades por rol están claras. - No se
incorporan evidencias o acciones posteriores no aprobadas.
S6-02. Definir el catálogo de incidencias
Objetivo: estandarizar los motivos por los que una entrega no se
completó.
Actividades 1. Solicitar al responsable los motivos válidos. 2.
Definir códigos estables y etiquetas legibles. 3. Determinar si el
comentario libre es necesario y opcional. 4. Establecer límites de
longitud y reglas para evitar datos sensibles innecesarios. 5.
Documentar cómo se añadirán o modificarán los motivos.
Entregables - Catálogo de motivos de incidencia. - Reglas de
validación.
Criterios de aceptación - Los motivos son aprobados por el
responsable. - No se usan textos arbitrarios como única clasificación. -
Los comentarios, si existen, tienen límites y finalidad definidos.
S6-03. Diseñar el modelo de resultado de entrega
Objetivo: persistir el resultado sin perder la información operativa
del pedido.
Actividades 1. Evaluar si el resultado se guarda en `orders` o en
una tabla separada. 2. Definir campos mínimos: resultado, motivo de
incidencia cuando aplique, usuario que registra y fecha del servidor. 3.
Definir claves foráneas y restricciones. 4. Establecer si se conserva un
historial de resultados o solo el resultado final. 5. Crear una
migración SQL versionada cuando sea necesario.
Entregables - Modelo de resultado e incidencia. - Migración y
documentación técnica.
Criterios de aceptación - El resultado queda asociado a un pedido
válido. - Los datos obligatorios se validan en la base de datos o
servicio confiable. - La estructura evita estados y motivos
inconsistentes.
S6-04. Implementar transiciones seguras del lado servidor
Objetivo: permitir solo las transiciones de entrega aprobadas.
Actividades 1. Crear o ampliar una operación confiable para
registrar el resultado. 2. Verificar estado actual, asignación y rol del
usuario. 3. Rechazar pedidos no asignados al repartidor cuando esa sea
la regla aprobada. 4. Validar que una entrega no completada tenga un
motivo cuando sea obligatorio. 5. Evitar que el cliente cambie
directamente campos protegidos.
Entregables - Operación de cierre de entrega. - Validaciones y
respuestas de error.
Criterios de aceptación - La operación rechaza estados o roles no
permitidos. - Los campos de auditoría se generan en el servidor. - Una
operación inválida no deja datos parcialmente actualizados.
S6-05. Revisar permisos y políticas RLS
Objetivo: restringir la lectura y el registro del resultado de
entrega.
Actividades 1. Definir quién puede consultar el resultado. 2.
Permitir que solo los roles autorizados registren el cierre. 3. Aplicar
las restricciones a pedidos, incidencias y detalles. 4. Impedir que el
cliente altere el usuario o la fecha del registro. 5. Probar accesos
permitidos y denegados.
Entregables - Políticas RLS revisadas. - Evidencias de pruebas de
autorización.
Criterios de aceptación - Las reglas se aplican en la base de datos
o servicio confiable. - Un usuario no autorizado no puede cerrar ni
consultar pedidos fuera de su permiso. - Las pruebas negativas están
documentadas.
S6-06. Implementar el repositorio de entrega
Objetivo: centralizar las operaciones de lectura y escritura del
resultado.
Actividades 1. Crear una operación para registrar una entrega
completada. 2. Crear una operación para registrar una entrega no
completada con su motivo. 3. Manejar errores de red, permisos, estado
inválido y conflictos. 4. Mantener la interfaz desacoplada del acceso a
datos. 5. Evitar duplicaciones ante reintentos.
Entregables - Repositorio o servicio de entrega. - Manejo de errores
y resultados documentado.
Criterios de aceptación - La interfaz no modifica directamente los
registros críticos. - El resultado solo se presenta como confirmado tras
respuesta exitosa. - Los reintentos no crean resultados duplicados.
S6-07. Mostrar la acción de registrar resultado
Objetivo: permitir al repartidor iniciar el cierre desde su pedido
asignado.
Actividades 1. Añadir las acciones permitidas al detalle del pedido.
2. Mostrar las acciones solo cuando el estado y rol lo permitan. 3.
Solicitar confirmación antes de guardar, cuando corresponda. 4.
Deshabilitar los controles durante la operación. 5. Manejar pedidos que
hayan cambiado de estado en otro dispositivo.
Entregables - Interfaz para registrar el resultado de la entrega.
Criterios de aceptación - Las acciones disponibles coinciden con el
estado y el rol. - La interfaz evita toques repetidos. - Los errores no
se presentan como una entrega completada.
S6-08. Implementar la entrega completada
Objetivo: registrar que el pedido fue entregado correctamente.
Actividades 1. Mostrar la acción de completar la entrega cuando esté
permitida. 2. Solicitar confirmación si lo requiere el flujo aprobado.
3. Enviar la operación al servidor. 4. Guardar el estado final y la
trazabilidad necesaria. 5. Actualizar la lista y el detalle tras la
confirmación.
Entregables - Flujo funcional de entrega completada.
Criterios de aceptación - Solo un pedido en estado válido puede
cerrarse como entregado. - El servidor confirma la actualización. - La
lista y el detalle muestran el resultado persistido.
S6-09. Implementar la entrega no completada
Objetivo: registrar un intento fallido de entrega de forma
consistente.
Actividades 1. Mostrar la acción solo en los estados permitidos. 2.
Presentar el catálogo aprobado de motivos. 3. Validar el motivo y el
comentario opcional. 4. Registrar el resultado y la trazabilidad. 5.
Mostrar el siguiente paso operativo definido por el responsable, sin
automatizarlo si no está aprobado.
Entregables - Flujo de entrega no completada. - Formulario de
incidencia.
Criterios de aceptación - El motivo requerido no puede omitirse. -
Solo se aceptan motivos válidos. - La aplicación no reasigna ni
reprograma automáticamente el pedido sin regla aprobada.
S6-10. Mostrar resultado e incidencia en el detalle
Objetivo: permitir consultar cómo terminó el intento de entrega.
Actividades 1. Mostrar el estado final. 2. Mostrar motivo de
incidencia y comentario cuando el rol tenga permiso. 3. Mostrar la fecha
y el responsable del registro si corresponde. 4. Diferenciar pedidos
entregados de pedidos con entrega fallida. 5. Manejar registros sin
resultado o sin incidencia.
Entregables - Detalle actualizado con resultado de entrega.
Criterios de aceptación - La información coincide con los datos
persistidos. - Solo los roles autorizados ven el resultado y los datos
asociados. - Los pedidos previos sin resultado no causan errores de
visualización.
S6-11. Gestionar reintentos y concurrencia
Objetivo: evitar resultados contradictorios ante fallos de red o
acciones simultáneas.
Actividades 1. Verificar el estado actual antes de guardar el
resultado. 2. Rechazar el cierre si el pedido ya fue cerrado o cambió de
estado. 3. Evitar registrar más de un resultado final cuando el modelo
lo prohíba. 4. Mostrar un mensaje y actualizar los datos al detectar un
conflicto. 5. Definir un mecanismo de idempotencia si el diseño de la
operación lo requiere.
Entregables - Manejo de conflictos y reintentos. - Pruebas
correspondientes.
Criterios de aceptación - Una repetición no crea resultados
contradictorios. - El estado real del servidor prevalece sobre el estado
local. - El usuario puede recuperar la vista y continuar según el
proceso aprobado.
S6-12. Pruebas unitarias
Objetivo: verificar las reglas de resultado e incidencias.
Actividades 1. Probar el registro de una entrega completada. 2.
Probar una entrega no completada con motivo válido. 3. Probar la
ausencia de motivo cuando sea obligatorio. 4. Probar motivos no
permitidos y transiciones inválidas. 5. Probar permisos y reintentos.
Entregables - Suite de pruebas unitarias.
Criterios de aceptación - Cada resultado permitido tiene una prueba
positiva. - Las condiciones inválidas tienen pruebas negativas. - Las
pruebas son reproducibles.
S6-13. Pruebas de integración y de interfaz
Objetivo: comprobar el flujo completo desde el pedido asignado hasta
el resultado persistido.
Actividades 1. Probar la entrega completada. 2. Probar la entrega no
completada con cada motivo de prueba relevante. 3. Verificar
actualización de lista y detalle. 4. Probar acceso desde roles
permitidos y denegados. 5. Simular errores de red y solicitudes
repetidas.
Entregables - Pruebas de integración o de interfaz. - Evidencias y
registro de defectos.
Criterios de aceptación - Los resultados se persisten
correctamente. - Los errores se manejan sin mostrar información falsa. -
Las pruebas usan datos ficticios o autorizados.
S6-14. Documentar el cierre de entrega
Objetivo: facilitar la revisión y el mantenimiento del módulo.
Actividades 1. Documentar estados finales y motivos de incidencia.
2. Documentar el modelo de datos y las operaciones del servidor. 3.
Actualizar las políticas RLS y las instrucciones de prueba. 4.
Actualizar README y tablero. 5. Registrar decisiones pendientes para el
Sprint 7.
Entregables - Documentación técnica y funcional actualizada.
Criterios de aceptación - Otro desarrollador puede entender el flujo
y ejecutar las pruebas. - No se incluyen secretos ni datos reales en el
repositorio.
S6-15. Integración, revisión y demostración
Objetivo: entregar un incremento funcional verificable.
Actividades 1. Integrar cambios mediante Pull Request. 2. Ejecutar
`flutter analyze` y las pruebas disponibles. 3. Revisar validaciones,
permisos, migraciones y trazabilidad. 4. Corregir defectos críticos. 5.
Demostrar ambos resultados de entrega y registrar pendientes.
Entregables - Código integrado. - Evidencias de pruebas. - Informe
de revisión del Sprint.
Criterios de aceptación - El flujo aprobado de entrega completada y
no completada funciona en pruebas. - No quedan defectos críticos
abiertos relacionados con el cierre o la exposición de datos. - Los
pendientes están registrados para el siguiente Sprint.
---
6. Historias de usuario sugeridas
HU-06-01 --- Confirmar entrega
Como repartidor autorizado, quiero registrar que entregué un
pedido, para cerrar su atención de manera verificable.
Criterios de aceptación - Solo puedo cerrar pedidos asignados y en
un estado permitido. - El servidor confirma el resultado. - El estado se
actualiza en lista y detalle. - El resultado no se duplica por
reintentos.
HU-06-02 --- Registrar incidencia
Como repartidor autorizado, quiero registrar el motivo por el
que no pude completar una entrega, para dejar constancia y permitir
que el personal responsable decida el siguiente paso.
Criterios de aceptación - Selecciono un motivo válido. - Se validan
los campos obligatorios. - El resultado queda asociado al pedido. - La
aplicación no ejecuta acciones posteriores no aprobadas.
HU-06-03 --- Consultar el resultado de entrega
Como usuario autorizado, quiero consultar el resultado
registrado, para conocer si el pedido fue entregado o si presenta
una incidencia.
Criterios de aceptación - Se muestra el resultado persistido. - Los
datos están restringidos por rol. - Los pedidos antiguos sin resultado
se muestran correctamente.
---
7. Distribución sugerida de las dos semanas
---
Periodo                 Trabajo principal       Resultado revisable
---
Semana 1 --- días 1--2  Validar estados finales Reglas de cierre
y motivos               aprobadas
Semana 1 --- días 3--4  Modelo de datos,        Registro seguro del
operación de servidor y resultado
RLS
Semana 1 --- día 5      Repositorio e interfaz  Acciones de resultado
inicial                 disponibles
Semana 2 --- días 1--2  Entrega completada y no Dos flujos funcionales
completada
Semana 2 --- días 3--4  Detalle, conflictos y   Flujo integrado y
pruebas                 verificado
Semana 2 --- día 5      Correcciones,           Incremento revisado
documentación y  
demostración
La distribución puede ajustarse según la capacidad del equipo y los
bloqueos identificados, sin ampliar automáticamente el alcance.
8. Definition of Done (DoD)
Una tarea se considera terminada cuando:
[ ] Cumple sus criterios de aceptación.
[ ] Los estados finales y motivos están aprobados.
[ ] Las validaciones críticas se ejecutan en el servidor o la base
de datos.
[ ] Los permisos se prueban con casos permitidos y denegados.
[ ] Los campos de auditoría se generan en un componente confiable.
[ ] Los reintentos no generan resultados contradictorios.
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
Cierre por un usuario no autorizado Validación de rol, asignación y RLS
Motivos de incidencia               Catálogo controlado aprobado por el
inconsistentes                      negocio
Estado local difiere del servidor   Confirmar resultado y refrescar la
vista
Reintentos crean resultados         Validación de estado e idempotencia
duplicados                          cuando corresponda
Recopilación excesiva de datos      Minimización y aprobación de cada
dato o evidencia
Entrega fallida sin procedimiento   Acordar el siguiente paso con el
definido                            responsable antes de automatizarlo
Cambios de alcance a GPS, pagos o   Mantener esas funciones fuera del
notificaciones                      Sprint salvo aprobación expresa
10. Checklist de revisión del Sprint
[ ] Estados finales y reglas de entrega aprobados.
[ ] Catálogo de motivos de incidencia definido.
[ ] Se puede registrar una entrega completada.
[ ] Se puede registrar una entrega no completada con motivo válido.
[ ] Se rechazan estados, motivos y usuarios no autorizados.
[ ] La lista y el detalle muestran el resultado persistido.
[ ] Se manejan reintentos y conflictos.
[ ] RLS y permisos están probados.
[ ] Pruebas automatizadas y documentación están actualizadas.
[ ] El incremento fue integrado y demostrado.
11. Preparación del Sprint 7
El Sprint 7 debe centrarse en endurecimiento funcional y técnico,
revisión integral de seguridad, pruebas de regresión, accesibilidad y
estabilidad del MVP. Antes de iniciarlo, revisar:
Defectos pendientes de los Sprints 1 a 6.
Cobertura de pruebas y escenarios críticos sin automatizar.
Revisión de políticas RLS, secretos y configuración de entornos.
Tiempos de respuesta y comportamiento con conexión inestable.
Accesibilidad, validación de formularios y manejo de errores.
Criterios de aceptación del piloto y condiciones para detenerlo.
No se debe declarar el sistema listo para producción únicamente por
completar los Sprints; la salida depende de las pruebas, autorizaciones
y revisión de riesgos.
12. Resultado final esperado
Al cierre del Sprint 6, el sistema debe permitir registrar si una
entrega se completó o no, documentar la incidencia cuando corresponda y
mostrar el resultado a los roles autorizados. Las operaciones deben
estar validadas, protegidas y probadas en un entorno controlado.
Este incremento no implica que la aplicación esté lista para producción
ni que exista integración con sistemas internos de MASS. Cualquier
despliegue real requiere autorización, validación técnica, revisión de
privacidad y pruebas de aceptación.