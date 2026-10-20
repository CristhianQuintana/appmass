Informe de Desarrollo --- Sprint 0
Aplicación móvil de gestión de pedidos y entregas MASS
Versión: 1.0  
Fecha: 13 de octubre de 2026  
Duración propuesta: 2 semanas  
Objetivo del Sprint: descubrimiento, decisiones y habilitación
técnica  
Stack propuesto: Flutter + Dart + Supabase/PostgreSQL  
Metodología: Scrum con prácticas técnicas seleccionadas de XP
---
1. Objetivo general
Preparar las bases funcionales y técnicas antes de desarrollar las
funciones comerciales. Al finalizar, el desarrollador debe entregar una
definición inicial del MVP, flujos operativos documentados, decisiones
pendientes identificadas, repositorio configurado, una aplicación
Flutter mínima que compile, un proyecto Supabase de desarrollo y
controles iniciales de calidad automatizados.
Resultado esperado: un entorno reproducible y una planificación
suficientemente clara para iniciar el Sprint 1 sin programar sobre
reglas de negocio no aprobadas.
2. Alcance
Incluido
Definición inicial del propósito y límites del proyecto.
Roles, permisos preliminares, flujos y estados propuestos.
Backlog inicial con prioridades y criterios de aceptación.
Repositorio GitHub y estructura base.
Configuración inicial de Flutter/Dart y Android.
Proyecto Supabase para desarrollo.
Formato, análisis estático, prueba inicial y CI.
Documentación para ejecutar el proyecto localmente.
Fuera de alcance
Funcionalidades comerciales completas.
Login completo, catálogo operativo o registro de pedidos.
Preparación de pedidos y asignación de repartidores.
Pagos, inventario en tiempo real y comprobantes electrónicos.
Integración con sistemas internos de MASS.
Uso de datos personales reales en desarrollo.
> **Restricción:** no se debe asumir autorización para utilizar la
> marca, los datos, las APIs o los sistemas internos de Tiendas MASS. Si
> el proyecto es académico o independiente, se utilizarán datos
> ficticios salvo autorización expresa.
---
3. Tareas detalladas del desarrollador
S0-01. Confirmar el contexto y propósito del proyecto
Objetivo: documentar si el proyecto es académico, independiente o
autorizado por el negocio.
Actividades 1. Registrar el propósito de la aplicación y sus
usuarios previstos. 2. Identificar si existe un representante autorizado
para validar procesos. 3. Documentar restricciones de uso de marca,
datos, sistemas e integraciones. 4. Registrar las autorizaciones
existentes o señalar las pendientes.
Entregable: `docs/01-contexto-y-alcance.md`
Criterio de aceptación: el documento distingue hechos confirmados,
supuestos y autorizaciones pendientes.
S0-02. Definir el alcance del MVP
Objetivo: evitar que se desarrollen funciones no aprobadas o se
amplíe el alcance sin evaluación.
Actividades 1. Confirmar si el operador registrará los pedidos en el
MVP. 2. Decidir si el cliente podrá crear pedidos desde su propia app;
si no se aprueba, dejarlo fuera. 3. Confirmar si se trabajará con una
tienda o varias. 4. Aclarar si la atención presencial incluye caja y
cobro o solo gestión del pedido. 5. Clasificar pagos, inventario,
comprobantes e integraciones como incluidos, excluidos o pendientes. 6.
Priorizar funcionalidades como P0 (obligatorias), P1 (importantes) y P2
(fuera del MVP salvo aprobación).
Entregable: `docs/02-alcance-mvp.md`
Criterio de aceptación: cada función relevante tiene una
clasificación y las exclusiones están expresamente documentadas.
S0-03. Definir roles y permisos preliminares
Objetivo: determinar qué acciones puede realizar cada perfil.
Actividades 1. Documentar los perfiles conceptuales: administrador,
operador de pedidos/preparación, repartidor y cliente si corresponde. 2.
Crear una matriz de permisos para consultar, crear, modificar, asignar y
cerrar recursos. 3. Definir quién puede crear o desactivar cuentas
internas. 4. Definir quién puede asignar y reasignar repartidores. 5.
Identificar datos personales que cada rol necesita consultar. 6. Marcar
las decisiones que requieren aprobación del responsable del producto.
Entregable: `docs/03-matriz-roles-permisos.md`
Criterio de aceptación: cada rol tiene acciones permitidas y
restricciones conocidas; los puntos no confirmados están marcados como
pendientes.
S0-04. Documentar los flujos operativos
Objetivo: definir el recorrido del pedido antes de diseñar la base
de datos o desarrollar pantallas.
Actividades 1. Representar el flujo de atención presencial. 2.
Representar el flujo de pedido a domicilio. 3. Identificar quién
registra el pedido y qué datos mínimos necesita. 4. Definir cuándo
comienza y termina la preparación. 5. Definir cuándo un pedido
presencial queda listo para atención. 6. Definir cuándo un pedido a
domicilio queda listo para despacho. 7. Registrar el tratamiento
pendiente para cancelaciones, productos faltantes y entregas fallidas.
8. Crear diagramas sencillos que permitan revisar los flujos.
Entregables: `docs/04-flujos-operativos.md` y diagramas en
`docs/diagramas/` o incluidos en el documento.
Criterio de aceptación: ambos flujos pueden seguirse de principio a
fin; las excepciones no resueltas aparecen identificadas.
S0-05. Proponer estados y transiciones
Objetivo: prevenir estados contradictorios de pedidos y entregas.
Actividades 1. Proponer los estados iniciales del pedido. 2.
Documentar transiciones válidas por modalidad. 3. Separar el estado del
pedido y el de la entrega cuando sea necesario. 4. Indicar qué rol puede
ejecutar cada transición. 5. Registrar reglas pendientes sobre
cancelación, reintentos, reasignaciones y fallos. 6. No implementar
todavía la lógica completa: el objetivo de esta tarea es definirla y
validarla.
Entregable: `docs/05-estados-y-transiciones.md`
Criterio de aceptación: cada estado y transición propuesta tiene una
descripción, un actor responsable y las reglas pendientes identificadas.
S0-06. Definir la fuente del catálogo y los precios
Objetivo: evitar el uso de información de productos o precios no
confiable.
Actividades 1. Identificar quién mantendrá el catálogo. 2. Confirmar
si existe una fuente autorizada de productos y precios. 3. Definir los
campos mínimos de cada producto. 4. Proponer cómo conservar el precio
aplicado al confirmar un pedido. 5. Confirmar si se dispone de
información fiable de inventario. 6. Si no existe una fuente autorizada,
planificar datos ficticios claramente identificados.
Entregable: `docs/06-catalogo-y-precios.md`
Criterio de aceptación: la fuente está definida o el uso de datos
ficticios está documentado; no se presenta el stock como confirmado sin
una fuente fiable.
S0-07. Crear el backlog inicial
Objetivo: convertir el alcance en trabajo planificable y verificable
para los siguientes Sprints.
Actividades 1. Crear épicas para configuración, identidad, catálogo,
pedidos, preparación, entregas, administración y calidad. 2. Descomponer
las épicas en historias pequeñas. 3. Asignar prioridades iniciales. 4.
Escribir criterios de aceptación verificables. 5. Registrar
dependencias, riesgos y bloqueos. 6. Identificar historias que no estén
listas por falta de decisiones.
Entregable: `docs/07-product-backlog-inicial.md` o backlog
equivalente en la herramienta acordada.
Criterio de aceptación: las historias iniciales tienen
identificador, descripción, prioridad, criterios de aceptación y
dependencias conocidas.
S0-08. Crear el repositorio GitHub
Objetivo: mantener código y documentación bajo control de versiones
desde el inicio.
Actividades 1. Crear un repositorio privado. 2. Añadir una
estructura mínima del proyecto. 3. Crear un `README.md` con el propósito
y el estado del proyecto. 4. Configurar `.gitignore` para Flutter/Dart,
Android y archivos locales. 5. Crear un ejemplo de configuración sin
secretos reales, si aplica. 6. Definir una convención sencilla de ramas
y Pull Requests. 7. Realizar el primer commit.
Entregables: repositorio GitHub, `README.md`, `.gitignore`, archivo
de ejemplo de configuración si corresponde y primer commit.
Criterio de aceptación: el repositorio se puede clonar y no contiene
tokens, contraseñas ni claves privadas.
S0-09. Preparar Flutter, Dart y Android
Objetivo: garantizar que el proyecto compile en un entorno Android
reproducible.
Actividades 1. Instalar o verificar una versión estable compatible
de Flutter. 2. Registrar `flutter --version` y `dart --version`. 3.
Ejecutar `flutter doctor` y resolver o documentar problemas relevantes.
4. Verificar Android SDK, herramientas de compilación y emulador o
dispositivo. 5. Crear el proyecto Flutter en el repositorio. 6. Ejecutar
la app inicial en el entorno objetivo. 7. Documentar los requisitos y
comandos necesarios. 8. Versionar `pubspec.lock`.
Entregables: proyecto Flutter inicial y
`docs/08-entorno-desarrollo.md` o documentación equivalente en el
README.
Criterio de aceptación: la app mínima compila y se ejecuta en el
entorno Android acordado; los problemas restantes están documentados.
S0-10. Evaluar y configurar dependencias
Objetivo: seleccionar dependencias compatibles y evitar complejidad
innecesaria.
Actividades 1. Verificar compatibilidad entre Flutter, Dart y los
paquetes. 2. Evaluar `flutter_riverpod` para estado e inyección de
dependencias. 3. Evaluar `go_router` para navegación. 4. Evaluar
`supabase_flutter` para la futura conexión al backend. 5. Incorporar
solo las dependencias necesarias para la base. 6. Registrar las
decisiones y versiones elegidas. 7. Ejecutar `flutter pub get`, formato,
análisis y pruebas iniciales.
Entregables: `pubspec.yaml`, `pubspec.lock` y
`docs/09-decisiones-tecnicas.md`.
Criterio de aceptación: las dependencias son compatibles y las
decisiones están documentadas; las versiones se fijan después de
verificarlas, no por suposición.
S0-11. Crear Supabase de desarrollo
Objetivo: preparar el backend de desarrollo sin exponer secretos ni
utilizar datos reales.
Actividades 1. Crear un proyecto Supabase destinado a desarrollo. 2.
Documentar la URL y la configuración pública necesaria para la app. 3.
No incluir la clave `service_role` ni secretos privilegiados en Flutter.
4. Configurar Supabase CLI si se utilizará para migraciones. 5. Mantener
separados los entornos de desarrollo y producción. 6. Revisar región,
límites, costos y opciones de respaldo. 7. Documentar la configuración
local de forma segura.
Entregable: proyecto Supabase de desarrollo y
`docs/10-configuracion-supabase.md`.
Criterio de aceptación: el proyecto de desarrollo existe y su
configuración está documentada sin publicar secretos. No se crea un
esquema de negocio definitivo si las reglas siguen pendientes.
S0-12. Configurar calidad inicial
Objetivo: detectar errores básicos antes de que el código crezca.
Actividades 1. Configurar `flutter_lints` o la configuración
acordada. 2. Verificar el formato con `dart format`. 3. Ejecutar
`flutter analyze`. 4. Crear al menos una prueba inicial con
`flutter_test`. 5. Documentar los comandos de verificación. 6. Corregir
problemas iniciales o registrar los pendientes.
Entregables: configuración de análisis estático y prueba inicial
ejecutable.
Criterio de aceptación: formato, análisis y prueba se ejecutan
localmente; no se declaran aprobados controles que no se hayan
ejecutado.
S0-13. Configurar integración continua (CI)
Objetivo: automatizar verificaciones básicas en GitHub.
Actividades 1. Crear un flujo de GitHub Actions. 2. Configurar el
entorno Flutter en el flujo. 3. Ejecutar formato, análisis estático y
pruebas. 4. Configurar los eventos de ejecución acordados, como Pull
Requests y cambios en la rama principal. 5. Revisar una ejecución real y
corregir fallos. 6. Documentar qué verifica la CI y qué queda fuera por
ahora.
Entregable: flujo en `.github/workflows/` y evidencia de ejecución.
Criterio de aceptación: GitHub ejecuta las verificaciones
configuradas y muestra sus resultados; no basta con que exista el
archivo de configuración.
S0-14. Definir DoR y DoD
Objetivo: establecer cuándo una historia está lista para empezar y
cuándo se considera terminada.
Actividades 1. Documentar la Definition of Ready (DoR): objetivo,
criterios verificables, rol, dependencias y seguridad. 2. Documentar la
Definition of Done (DoD): criterios satisfechos, revisión, formato,
análisis, pruebas, permisos revisados cuando correspondan y
documentación actualizada. 3. Definir cómo se revisará el trabajo en un
equipo pequeño o unipersonal. 4. Acordar que escribir código no equivale
a terminar una tarea.
Entregable: `docs/11-dor-dod.md`
Criterio de aceptación: existen listas de comprobación claras y se
usarán en las revisiones de trabajo.
S0-15. Registrar riesgos y decisiones pendientes
Objetivo: visibilizar asuntos que pueden retrasar o cambiar el
desarrollo.
Actividades 1. Registrar riesgos de alcance, autorización, catálogo,
seguridad, conectividad y costos. 2. Añadir probabilidad, impacto,
responsable y mitigación cuando se conozcan. 3. Crear una lista de
decisiones pendientes. 4. Identificar cuáles bloquean el Sprint 1 y
cuáles afectan Sprints posteriores. 5. No implementar funcionalidades
dependientes de reglas aún no aprobadas.
Entregable: `docs/12-riesgos-y-decisiones-pendientes.md`
Criterio de aceptación: los riesgos relevantes tienen tratamiento
inicial y las decisiones pendientes tienen responsable o mecanismo
previsto para resolverlas.
S0-16. Documentar la ejecución local
Objetivo: permitir que el proyecto se ejecute sin depender de
instrucciones verbales.
Actividades 1. Documentar prerrequisitos. 2. Explicar cómo clonar el
repositorio. 3. Explicar cómo instalar dependencias. 4. Indicar cómo
configurar variables locales sin compartir secretos. 5. Documentar cómo
ejecutar la app. 6. Documentar cómo ejecutar formato, análisis y
pruebas. 7. Añadir problemas conocidos, si corresponde.
Entregable: `README.md` completo o `docs/13-ejecucion-local.md`.
Criterio de aceptación: una persona con el entorno requerido puede
seguir la guía, ejecutar la app mínima y lanzar las verificaciones.
---
4. Resumen de tareas y entregables
---
ID                      Tarea                   Entregable principal
---
S0-01                   Confirmar contexto y    `docs/01-contexto-y-alcance.md`
propósito
S0-02                   Definir alcance del MVP `docs/02-alcance-mvp.md`
S0-03                   Definir roles y         `docs/03-matriz-roles-permisos.md`
permisos
S0-04                   Documentar flujos       `docs/04-flujos-operativos.md` y diagramas
S0-05                   Proponer estados        `docs/05-estados-y-transiciones.md`
S0-06                   Definir catálogo y      `docs/06-catalogo-y-precios.md`
precios
S0-07                   Crear backlog inicial   `docs/07-product-backlog-inicial.md`
S0-08                   Crear repositorio       Repositorio GitHub y archivos base
S0-09                   Preparar entorno        App mínima y guía de entorno
Flutter/Android
S0-10                   Evaluar dependencias    `pubspec.yaml`, `pubspec.lock` y decisiones
S0-11                   Crear Supabase de       Proyecto y guía de configuración
desarrollo
S0-12                   Configurar calidad      Formato, análisis y prueba ejecutable
inicial
S0-13                   Configurar CI           GitHub Actions ejecutado
S0-14                   Definir DoR y DoD       `docs/11-dor-dod.md`
S0-15                   Registrar riesgos       `docs/12-riesgos-y-decisiones-pendientes.md`
S0-16                   Documentar ejecución    README o guía equivalente
local
5. Estructura documental sugerida
``` text
proyecto-mass/
├── .github/
│   └── workflows/
│       └── flutter-ci.yml
├── docs/
│   ├── 01-contexto-y-alcance.md
│   ├── 02-alcance-mvp.md
│   ├── 03-matriz-roles-permisos.md
│   ├── 04-flujos-operativos.md
│   ├── 05-estados-y-transiciones.md
│   ├── 06-catalogo-y-precios.md
│   ├── 07-product-backlog-inicial.md
│   ├── 08-entorno-desarrollo.md
│   ├── 09-decisiones-tecnicas.md
│   ├── 10-configuracion-supabase.md
│   ├── 11-dor-dod.md
│   ├── 12-riesgos-y-decisiones-pendientes.md
│   └── 13-ejecucion-local.md
├── lib/
├── test/
├── .gitignore
├── analysis_options.yaml
├── pubspec.yaml
├── pubspec.lock
└── README.md
```
La estructura es orientativa. No se deben crear archivos vacíos solo
para completar el árbol; se puede agrupar documentación si se conserva
el contenido y se actualizan las referencias.
6. Lista de verificación para cerrar el Sprint 0
[ ] Propósito, restricciones y alcance documentados.
[ ] Exclusiones del MVP identificadas.
[ ] Roles y permisos preliminares documentados.
[ ] Flujos presencial y domicilio representados.
[ ] Estados y transiciones propuestas documentados.
[ ] Fuente del catálogo definida o marcada como pendiente.
[ ] Backlog inicial con criterios de aceptación.
[ ] Repositorio creado y libre de secretos.
[ ] App Flutter mínima compilada y ejecutada en el entorno acordado.
[ ] Versiones de herramientas y dependencias registradas.
[ ] Proyecto Supabase de desarrollo creado.
[ ] Formato, análisis y pruebas iniciales ejecutables.
[ ] GitHub Actions ejecutado.
[ ] DoR y DoD documentadas.
[ ] Riesgos y decisiones pendientes registrados.
[ ] Guía de ejecución local revisada.
[ ] Decisión documentada sobre iniciar o bloquear el Sprint 1.
7. Condiciones para iniciar el Sprint 1
Se recomienda iniciar el Sprint 1 cuando: 1. La aplicación mínima
compila en el entorno objetivo. 2. El repositorio y la CI funcionan. 3.
Existe un responsable que resuelva dudas de negocio, o las decisiones
pendientes están acotadas. 4. La matriz preliminar de roles permite
comenzar el diseño de autenticación y perfiles. 5. Se ha definido cómo
se asignarán roles de forma confiable. 6. Las variables y secretos se
gestionan de forma segura.
Las decisiones sobre catálogo o reglas de pedidos pueden continuar
pendientes si no bloquean la autenticación; deben quedar registradas y
resolverse antes de implementar las funcionalidades que dependen de
ellas.
8. Reglas de trabajo
Mantener tareas pequeñas y actualizar el tablero.
Realizar commits frecuentes y describir los cambios.
No subir tokens, contraseñas ni claves privilegiadas al repositorio.
No usar datos personales reales en pruebas.
No crear el modelo de datos definitivo antes de validar las reglas
necesarias.
No declarar pruebas aprobadas si no se ejecutaron.
Registrar bloqueos en vez de asumir reglas de negocio.
Demostrar al cierre la app mínima, la CI y los documentos
producidos.
9. Resultado final esperado
Al finalizar el Sprint 0, el desarrollador debe entregar:
Definición del producto: contexto, alcance, roles, flujos,
estados y backlog inicial.
Código base: repositorio GitHub y aplicación Flutter mínima que
compila.
Entorno de desarrollo: herramientas y dependencias documentadas
y proyecto Supabase de desarrollo.
Calidad inicial: formato, análisis estático, prueba inicial y CI
ejecutada.
Documentación de trabajo: DoR, DoD, instrucciones locales,
riesgos y decisiones pendientes.
Acta breve de revisión: tareas terminadas, bloqueos, decisiones
faltantes y recomendación de iniciar o no el Sprint 1.
Criterio global de cierre: el Sprint 0 no se aprueba por la cantidad
de archivos creados, sino porque el entorno puede reproducirse, la
aplicación mínima compila, las verificaciones automáticas funcionan y el
alcance necesario para iniciar el Sprint 1 está suficientemente
definido.