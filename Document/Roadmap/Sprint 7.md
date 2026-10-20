Informe de desarrollo --- Sprint 7
Aplicación móvil para minimarket MASS
Sprint: 7  
Duración propuesta: 2 semanas  
Metodología: Scrum con prácticas seleccionadas de XP y tablero
Kanban  
Tecnologías base: Flutter, Dart, Riverpod, `go_router`, Supabase,
PostgreSQL, Git y GitHub  
Resultado esperado: MVP endurecido mediante pruebas de regresión,
revisión de seguridad, validación de estabilidad y preparación para un
piloto controlado.
---
1. Objetivo del Sprint
Realizar una revisión integral de la aplicación desarrollada en los
Sprints 1 a 6 para detectar y corregir defectos funcionales,
vulnerabilidades de configuración o autorización, problemas de
usabilidad y fallos de estabilidad antes de realizar un piloto
controlado.
Este Sprint se centra en validar y estabilizar el alcance existente. No
debe utilizarse para añadir módulos grandes ni ampliar el alcance sin
una decisión explícita.
2. Alcance
Incluido
Revisar los defectos pendientes de los Sprints anteriores.
Ejecutar pruebas de regresión sobre autenticación, catálogo,
pedidos, preparación, asignación y resultado de entrega.
Revisar configuración de entornos, gestión de secretos y permisos de
Supabase.
Verificar las políticas RLS con usuarios y roles distintos.
Revisar validaciones de formularios, estados de carga, errores,
reintentos y conexión inestable.
Ejecutar análisis estático y pruebas automatizadas disponibles.
Revisar compatibilidad en dispositivos y versiones de Android
contemplados por el proyecto.
Revisar accesibilidad básica y consistencia de interfaz.
Corregir defectos priorizados por severidad.
Preparar un checklist y una decisión de preparación para el piloto.
Fuera de alcance
Incorporar módulos funcionales nuevos de gran tamaño.
Seguimiento GPS en tiempo real, pagos digitales o notificaciones
automatizadas.
Integraciones con sistemas internos de MASS no autorizadas.
Despliegue productivo generalizado.
Declarar certificación formal de seguridad o cumplimiento normativo
sin una evaluación independiente y evidencia suficiente.
Regla de alcance: ejecutar las pruebas en entornos controlados con
datos ficticios o autorizados. No utilizar credenciales reales de
producción ni datos personales innecesarios.
---
3. Dependencias de entrada
Antes de iniciar, verificar que:
Los flujos de los Sprints 1 a 6 están integrados en una rama
revisable.
Existen instrucciones para ejecutar la aplicación y las pruebas.
Hay un entorno de pruebas de Supabase separado de producción.
Se conocen los roles y las políticas RLS vigentes.
Los defectos conocidos están registrados en el tablero.
Existe una lista de dispositivos y versiones de Android objetivo
para la validación.
Si una función aún no está implementada, no se debe marcar como
aprobada: registrar el pendiente y evaluar si bloquea el piloto.
---
4. Criterios de severidad de defectos
Utilizar una clasificación acordada por el equipo:
---
Severidad               Criterio                Tratamiento
---
Crítica                 Acceso no autorizado a  Bloquea el piloto hasta
datos, exposición de    resolver o mitigar y
secretos, pérdida o     verificar
corrupción grave de  
pedidos, o bloqueo  
total del flujo  
principal
Alta                    Una función esencial    Debe corregirse antes
falla o genera          del piloto, salvo
resultados incorrectos  excepción formal
sin alternativa         documentada
aceptable
Media                   Fallo con alternativa   Priorizar según riesgo
temporal o impacto      y frecuencia
limitado
Baja                    Detalle visual o mejora Puede registrarse para
menor sin impacto       una iteración posterior
relevante en seguridad  
o flujo principal
La clasificación debe basarse en evidencia reproducible, impacto y
probabilidad, no únicamente en la dificultad de corregir el defecto.
---
5. Plan de tareas del desarrollador
S7-01. Consolidar defectos y deuda técnica
Objetivo: disponer de una lista única y priorizada de problemas
pendientes.
Actividades 1. Revisar incidencias de los Sprints 1 a 6. 2.
Reproducir los defectos reportados. 3. Registrar pasos, resultado
esperado, resultado obtenido y evidencia. 4. Clasificar por severidad,
impacto y prioridad. 5. Separar defectos, deuda técnica y mejoras
futuras.
Entregables - Backlog de estabilización priorizado. - Registro de
defectos reproducibles.
Criterios de aceptación - Cada defecto prioritario tiene descripción
y pasos de reproducción. - Los defectos críticos y altos se identifican
claramente. - Las mejoras fuera del alcance se mantienen separadas.
S7-02. Ejecutar regresión funcional
Objetivo: verificar que las funciones implementadas siguen
operativas después de los cambios acumulados.
Actividades 1. Probar inicio y cierre de sesión. 2. Probar catálogo
y búsqueda. 3. Probar selección de productos, registro y consulta de
pedidos. 4. Probar preparación y cambio de estado. 5. Probar asignación
a repartidor. 6. Probar navegación externa y registro de resultado de
entrega. 7. Verificar que cada función respeta el rol autenticado.
Entregables - Matriz de regresión. - Resultados por escenario y
evidencias.
Criterios de aceptación - Los escenarios críticos tienen resultado
documentado. - Los fallos se registran como defectos. - No se marca un
escenario como aprobado si no fue ejecutado.
S7-03. Revisar autenticación y sesiones
Objetivo: comprobar que el acceso a la aplicación y la gestión de
sesiones se comportan de forma predecible.
Actividades 1. Probar inicio de sesión válido e inválido. 2. Revisar
cierre de sesión y navegación posterior. 3. Probar expiración o pérdida
de sesión según el comportamiento del proveedor. 4. Verificar que las
pantallas protegidas requieren autenticación. 5. Comprobar que los
errores de autenticación no revelan información sensible.
Entregables - Resultados de pruebas de autenticación. - Defectos y
correcciones aplicadas.
Criterios de aceptación - Las rutas protegidas no quedan accesibles
tras cerrar sesión. - La aplicación maneja fallos de sesión de forma
controlada. - Los mensajes no exponen tokens ni detalles internos.
S7-04. Auditar secretos y configuración
Objetivo: evitar que credenciales privilegiadas o configuraciones
sensibles se distribuyan dentro de la aplicación.
Actividades 1. Buscar claves y secretos accidentales en el
repositorio y el historial reciente. 2. Confirmar que el cliente Flutter
no contiene la clave `service_role` de Supabase. 3. Revisar archivos
`.env`, `local.properties`, configuraciones de CI y `.gitignore`. 4.
Confirmar que las claves públicas utilizadas en el cliente están
protegidas por políticas de acceso adecuadas. 5. Si se expuso un
secreto, retirarlo del código y rotarlo; borrar el texto del repositorio
por sí solo no invalida una clave filtrada.
Entregables - Checklist de configuración segura. - Registro de
hallazgos y acciones correctivas.
Criterios de aceptación - No se incluyen secretos privilegiados en
el cliente. - Las credenciales de prueba se gestionan fuera del control
de versiones. - Los secretos expuestos se revocan o rotan según
corresponda.
S7-05. Auditar políticas RLS y permisos
Objetivo: validar que las restricciones de acceso funcionan en la
base de datos.
Actividades 1. Enumerar las tablas accesibles desde la aplicación.
2. Revisar que RLS esté habilitado donde corresponde. 3. Probar accesos
con distintos roles y usuarios. 4. Intentar consultar pedidos de otro
usuario o repartidor sin permiso. 5. Intentar modificar campos
protegidos y ejecutar transiciones inválidas. 6. Documentar cada
política y resultado.
Entregables - Matriz de autorización. - Evidencias de pruebas
permitidas y denegadas.
Criterios de aceptación - Los permisos no dependen solo de la
interfaz. - Los accesos no autorizados son rechazados. - Las políticas y
excepciones quedan documentadas.
S7-06. Revisar validación y consistencia de datos
Objetivo: evitar registros incompletos o inconsistentes en el flujo
operativo.
Actividades 1. Probar cantidades inválidas y pedidos vacíos. 2.
Verificar cálculo y persistencia de importes. 3. Probar estados y
transiciones no permitidos. 4. Verificar referencias entre pedidos,
detalles, repartidores e incidencias. 5. Comprobar que los campos de
auditoría se generan en un componente confiable.
Entregables - Matriz de validaciones. - Correcciones de integridad y
pruebas.
Criterios de aceptación - Las reglas críticas se validan también en
el servidor o base de datos. - Los casos inválidos se rechazan sin dejar
registros parciales. - Los importes y estados son coherentes entre
interfaz y persistencia.
S7-07. Revisar errores de red y recuperación
Objetivo: mejorar el comportamiento cuando la conexión es lenta o se
interrumpe.
Actividades 1. Simular fallos de red durante consultas. 2. Simular
un fallo durante el registro o cambio de estado. 3. Verificar
indicadores de carga y mensajes de error. 4. Comprobar que los
reintentos no duplican pedidos o resultados. 5. Confirmar que la
interfaz vuelve a consultar el estado del servidor después de un
conflicto.
Entregables - Pruebas de recuperación ante errores. - Correcciones
para escenarios prioritarios.
Criterios de aceptación - La aplicación no informa éxito antes de
confirmar la operación. - Los errores no eliminan silenciosamente datos
que el usuario aún necesita. - Los reintentos son seguros o muestran
claramente que se debe verificar el resultado antes de repetir.
S7-08. Revisar interfaz y accesibilidad básica
Objetivo: identificar obstáculos de uso en los flujos principales.
Actividades 1. Revisar tamaños de texto, contraste y estados de
foco. 2. Verificar que botones y campos tengan etiquetas comprensibles.
3. Revisar formularios, validaciones y mensajes de error. 4. Probar
navegación atrás y pantallas vacías. 5. Verificar que los controles
importantes no dependan únicamente del color para comunicar un estado.
Entregables - Checklist de usabilidad y accesibilidad. - Lista de
mejoras priorizadas.
Criterios de aceptación - Los defectos que impiden completar flujos
críticos se corrigen. - Los mensajes principales son legibles y
comprensibles. - Las mejoras menores se registran si no pueden incluirse
en el Sprint.
S7-09. Verificar compatibilidad en Android
Objetivo: comprobar la ejecución en los dispositivos y versiones de
Android objetivo.
Actividades 1. Confirmar `minSdk`, `targetSdk` y `compileSdk`
configurados en el proyecto. 2. Probar en al menos un dispositivo o
emulador representativo del mínimo admitido y otro entorno reciente
cuando esté disponible. 3. Verificar inicio de sesión, navegación,
formularios y apertura de mapas externos. 4. Revisar permisos y
comportamiento al reanudar la aplicación. 5. Registrar modelo, versión
de Android, versión de la app y resultado.
Entregables - Matriz de compatibilidad. - Evidencias de ejecución y
defectos.
Criterios de aceptación - Los flujos principales se prueban en los
entornos acordados. - Las incompatibilidades se documentan y
priorizan. - No se afirma compatibilidad con dispositivos que no fueron
probados o evaluados técnicamente.
S7-10. Ejecutar análisis estático y pruebas automatizadas
Objetivo: detectar defectos de código antes del piloto.
Actividades 1. Ejecutar `flutter analyze`. 2. Ejecutar las pruebas
unitarias y de widgets disponibles. 3. Ejecutar pruebas de integración
configuradas. 4. Revisar advertencias y fallos repetibles. 5. Corregir
los defectos relevantes y repetir las pruebas.
Entregables - Reporte de análisis y pruebas. - Lista de defectos
corregidos y pendientes.
Criterios de aceptación - El análisis y las pruebas se ejecutan en
un entorno documentado. - Los fallos críticos están resueltos o bloquean
explícitamente el piloto. - No se ocultan errores mediante exclusiones
injustificadas.
S7-11. Revisar rendimiento y estabilidad básica
Objetivo: comprobar que las pantallas y operaciones esenciales
tienen un comportamiento aceptable para el piloto.
Actividades 1. Medir de forma básica el tiempo de carga de las
pantallas principales. 2. Revisar operaciones repetidas y consultas
innecesarias. 3. Probar listas vacías y conjuntos de datos de prueba
representativos. 4. Observar bloqueos, cierres inesperados y errores
visibles. 5. Registrar medidas iniciales y umbrales acordados por el
equipo.
Entregables - Registro de pruebas de estabilidad y rendimiento. -
Problemas priorizados.
Criterios de aceptación - Los escenarios acordados se ejecutan sin
bloqueos críticos. - Las medidas incluyen contexto de dispositivo y
entorno. - No se inventan umbrales ni se declara rendimiento suficiente
sin evidencia.
S7-12. Revisar dependencias y cadena de construcción
Objetivo: reducir riesgos por dependencias desactualizadas o
compilaciones no reproducibles.
Actividades 1. Revisar `pubspec.yaml` y el archivo de bloqueo de
dependencias. 2. Confirmar que las versiones instaladas resuelven
correctamente. 3. Ejecutar una compilación limpia en el entorno de
desarrollo o CI disponible. 4. Revisar advertencias relevantes y
dependencias abandonadas o incompatibles. 5. Verificar que las
migraciones de base de datos están versionadas.
Entregables - Registro de dependencias y construcción. -
Correcciones necesarias.
Criterios de aceptación - La aplicación puede compilarse siguiendo
instrucciones documentadas. - Las dependencias utilizadas están fijadas
de forma reproducible. - Los cambios de versión no se realizan sin
verificar compatibilidad.
S7-13. Preparar el piloto controlado
Objetivo: definir cómo se probará el MVP con un grupo limitado y
autorizado.
Actividades 1. Definir participantes, responsables y duración del
piloto. 2. Definir los flujos que se evaluarán y los datos permitidos.
3. Preparar instrucciones breves de uso y un canal para reportar
problemas. 4. Definir cómo registrar incidentes y detener la prueba si
aparece un riesgo. 5. Confirmar que el entorno, las cuentas y los datos
de prueba están preparados.
Entregables - Plan de piloto. - Casos de prueba de aceptación. -
Registro de responsables y criterios de detención.
Criterios de aceptación - El piloto tiene alcance, participantes y
criterios definidos. - Existe una forma de reportar y priorizar
defectos. - No se usa información real sin autorización y controles
apropiados.
S7-14. Elaborar la matriz de salida
Objetivo: tomar una decisión basada en evidencia sobre si el MVP
puede pasar al piloto.
Actividades 1. Consolidar resultados funcionales, de seguridad,
compatibilidad y estabilidad. 2. Identificar defectos abiertos y su
severidad. 3. Clasificar cada requisito como aprobado, fallido,
bloqueado o no probado. 4. Registrar riesgos residuales y mitigaciones.
5. Recomendar continuar, continuar con restricciones o bloquear el
piloto.
Entregables - Matriz de salida del Sprint. - Registro de riesgos
residuales y recomendación.
Criterios de aceptación - La recomendación se basa en resultados
verificables. - Los defectos críticos no se ocultan en un promedio
general. - Las excepciones tienen responsable y aprobación explícita.
S7-15. Integración, revisión y demostración
Objetivo: cerrar el Sprint con un incremento estabilizado y
revisable.
Actividades 1. Integrar cambios mediante Pull Request. 2. Ejecutar
análisis y pruebas finales. 3. Revisar cambios de configuración,
migraciones y políticas RLS. 4. Demostrar los flujos principales y los
casos negativos relevantes. 5. Registrar defectos pendientes y acuerdos
de salida.
Entregables - Código integrado. - Evidencias finales. - Informe de
revisión del Sprint.
Criterios de aceptación - Los resultados de pruebas están
documentados. - No existen defectos críticos sin resolver que permitan
acceso no autorizado, corrupción de pedidos o bloqueo total del flujo
principal. - La decisión sobre el piloto queda registrada y justificada.
---
6. Matriz de regresión sugerida
---
Código                  Escenario               Resultado esperado
---
RG-01                   Inicio de sesión válido Acceso según rol
RG-02                   Inicio de sesión        Acceso rechazado sin
inválido                filtrar información
RG-03                   Consultar catálogo      Productos de prueba
visibles
RG-04                   Registrar pedido válido Pedido y detalles
persistidos
RG-05                   Registrar pedido vacío  Operación rechazada
RG-06                   Iniciar preparación     Estado permitido y
persistido
RG-07                   Marcar pedido como      Transición permitida
listo
RG-08                   Asignar pedido a        Asignación persistida
repartidor habilitado
RG-09                   Repartidor consulta     Acceso denegado salvo
pedido ajeno            permiso explícito
RG-10                   Abrir navegación con    Se abre el mapa externo
destino válido          cuando está disponible
RG-11                   Registrar entrega       Resultado persistido
completada
RG-12                   Registrar entrega       Operación rechazada
fallida sin motivo  
requerido
RG-13                   Repetir una operación   No se generan
por error de red        resultados
inconsistentes
RG-14                   Usuario sin permiso     Operación rechazada
intenta cambiar estado
RG-15                   Cerrar sesión y volver  No se accede a
atrás                   pantallas protegidas
Los resultados deben marcarse como Aprobado, Fallido,
Bloqueado o No probado, con fecha, entorno y evidencia.
7. Distribución sugerida de las dos semanas
---
Periodo                 Trabajo principal       Resultado revisable
---
Semana 1 --- días 1--2  Consolidar defectos y   Backlog priorizado y
ejecutar regresión      matriz inicial
Semana 1 --- días 3--4  Revisar secretos, RLS y Hallazgos de seguridad
validaciones
Semana 1 --- día 5      Recuperación de errores Correcciones
y usabilidad            prioritarias
Semana 2 --- días 1--2  Compatibilidad,         Evidencias técnicas
análisis y dependencias
Semana 2 --- días 3--4  Estabilidad y           Matriz de salida
preparación del piloto  preliminar
Semana 2 --- día 5      Revisión final y        Decisión documentada
demostración
La distribución puede ajustarse según defectos encontrados. Si aparece
un riesgo crítico, priorizar su corrección sobre las mejoras cosméticas.
8. Definition of Done (DoD)
Una tarea se considera terminada cuando:
[ ] Cumple sus criterios de aceptación.
[ ] Los escenarios ejecutados tienen evidencia.
[ ] Los defectos están clasificados por severidad.
[ ] Las políticas RLS se han probado con distintos roles.
[ ] No hay secretos privilegiados en el cliente ni en el
repositorio.
[ ] Se ejecutan `flutter analyze` y las pruebas automatizadas
disponibles.
[ ] La compilación y las instrucciones de ejecución están
documentadas.
[ ] Las migraciones y los cambios de configuración están
versionados.
[ ] Los cambios pasan por revisión de código.
[ ] Los riesgos residuales y los pendientes están documentados.
[ ] La recomendación de salida está respaldada por evidencia.
9. Riesgos y controles
---
Riesgo                              Control
---
Pruebas insuficientes por falta de  Priorizar flujos críticos y
tiempo                              documentar lo no probado
Exposición de claves o datos        Revisión de secretos, rotación y
datos de prueba
RLS incorrecta                      Pruebas negativas con usuarios y
roles distintos
Cambios de estabilización rompen    Ejecutar regresión después de cada
otros módulos                       corrección relevante
Incompatibilidad entre dispositivos Probar entornos representativos y
documentar limitaciones
Defectos críticos se aceptan por    Criterios de bloqueo explícitos y
presión de fecha                    aprobación registrada
Se declara listo para producción    Limitar la decisión a piloto
sin evidencia                       controlado y documentar riesgos
10. Checklist de revisión del Sprint
[ ] Backlog de defectos priorizado.
[ ] Regresión funcional ejecutada y documentada.
[ ] Autenticación y cierre de sesión verificados.
[ ] Secretos y configuración revisados.
[ ] RLS y permisos probados con casos positivos y negativos.
[ ] Validaciones de pedidos y estados verificadas.
[ ] Errores de red y reintentos evaluados.
[ ] Usabilidad y accesibilidad básica revisadas.
[ ] Compatibilidad Android probada en los entornos acordados.
[ ] `flutter analyze` y pruebas automatizadas ejecutadas.
[ ] Construcción y dependencias revisadas.
[ ] Plan de piloto y matriz de salida documentados.
[ ] Decisión sobre el piloto justificada con evidencia.
11. Preparación del Sprint 8
El Sprint 8 estará orientado al piloto, correcciones finales y
preparación de una versión candidata, de acuerdo con el plan inicial.
Antes de comenzar, confirmar:
Que los criterios de salida del Sprint 7 se cumplen.
Que los responsables han autorizado el piloto.
Que el entorno y los datos están preparados.
Que existe un procedimiento de soporte y registro de incidencias.
Que hay un procedimiento para detener el piloto y recuperar una
versión estable.
Que las limitaciones conocidas se comunican a los participantes.
Si persiste un defecto crítico, no avanzar automáticamente al piloto;
registrar el bloqueo y resolverlo.
12. Resultado final esperado
Al cierre del Sprint 7, el equipo debe contar con una versión revisada y
estabilizada del MVP, una matriz de regresión, evidencia de análisis y
pruebas, resultados de revisión de seguridad y una recomendación
documentada sobre la preparación para el piloto.
Completar este Sprint no equivale a una certificación de seguridad ni
garantiza la preparación para producción. La decisión debe depender de
la evidencia obtenida, las autorizaciones necesarias y los riesgos
residuales aceptados.