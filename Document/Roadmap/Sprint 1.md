Informe de Desarrollo --- Sprint 1
Fundaciones de Flutter, autenticación y perfiles
Proyecto: Aplicación móvil de gestión de pedidos y entregas MASS  
Versión del informe: 1.0  
Fecha: 13 de octubre de 2026  
Sprint: 1  
Duración propuesta: 2 semanas  
Objetivo: establecer la estructura inicial de la aplicación y
permitir el acceso controlado según la identidad y el rol del usuario.  
Stack: Flutter + Dart, Riverpod, `go_router`, Supabase Auth y
PostgreSQL/RLS.
---
1. Objetivo del Sprint
Implementar la base funcional de la aplicación Flutter, conectarla con
Supabase Auth y establecer un mecanismo seguro para asociar cada
identidad autenticada con su perfil de aplicación. La navegación debe
responder al estado de la sesión, mientras que los datos y operaciones
deben protegerse mediante políticas de acceso en el backend.
Resultado esperado: una aplicación que permita iniciar y cerrar
sesión, consultar el perfil propio y dirigir al usuario a una navegación
inicial según su rol, con pruebas que demuestren que los usuarios
anónimos y los usuarios sin permisos no acceden a recursos protegidos.
2. Prerrequisitos
Antes de comenzar, verificar que el Sprint 0 dejó disponible:
Repositorio GitHub accesible.
Aplicación Flutter mínima que compila en el entorno Android
acordado.
Proyecto Supabase de desarrollo.
Versiones de Flutter, Dart y dependencias documentadas.
Formato, análisis estático y prueba inicial configurados.
Flujo de GitHub Actions ejecutándose o con los bloqueos claramente
registrados.
Definición preliminar de roles y permisos.
Decisiones de autenticación y asignación de roles suficientemente
claras para implementar la base.
Si todavía no se ha definido de forma confiable quién asigna roles
privilegiados, esta decisión debe resolverse antes de habilitar cuentas
administrativas reales.
---
3. Alcance del Sprint
Incluye
Estructura inicial de la aplicación Flutter.
Tema visual y componentes básicos reutilizables.
Configuración de Riverpod y `go_router`.
Inicialización de `supabase_flutter`.
Inicio y cierre de sesión.
Manejo del estado de autenticación.
Asociación entre identidad de Supabase Auth y perfil de aplicación.
Redirección según sesión y rol.
Políticas RLS iniciales para los perfiles.
Pruebas de autenticación, navegación y autorización.
Documentación de configuración y administración básica de usuarios
internos.
No incluye
Gestión administrativa completa de usuarios.
Catálogo de productos.
Registro, preparación o entrega de pedidos.
Panel administrativo completo.
Recuperación avanzada de cuenta si el mecanismo aún no se ha
aprobado.
Permitir que un usuario se asigne a sí mismo un rol privilegiado.
Tratar la ocultación de pantallas en Flutter como única medida de
seguridad.
---
4. Tareas detalladas del desarrollador
S1-01. Configurar el punto de entrada y la estructura de la aplicación
Objetivo: organizar el código inicial para facilitar el
mantenimiento y la ampliación por funcionalidades.
Actividades 1. Configurar `main.dart` y el arranque de la
aplicación. 2. Inicializar las dependencias necesarias en el orden
correcto. 3. Crear `app.dart` para la composición principal de la app.
4. Crear una estructura mínima para `app/`, `core/` y `features/`. 5.
Separar configuración, presentación y acceso a datos. 6. Evitar crear
carpetas o módulos vacíos que todavía no se utilicen.
Entregables - Punto de entrada funcional. - Estructura inicial del
código en `lib/`. - Aplicación ejecutable sin errores de arranque.
Criterios de aceptación - La aplicación arranca en el dispositivo o
emulador objetivo. - La estructura permite incorporar autenticación y
perfiles sin concentrar toda la lógica en `main.dart`.
S1-02. Implementar el tema visual y componentes básicos
Objetivo: establecer una interfaz coherente para las pantallas de
autenticación y navegación inicial.
Actividades 1. Configurar Material 3 y el tema visual inicial. 2.
Definir colores, tipografía, estilos de botones y campos. 3. Crear
componentes reutilizables mínimos para campos, botones, indicadores de
carga y mensajes. 4. Mantener una interfaz adaptable a tamaños de
pantalla habituales. 5. Mostrar estados de carga, éxito y error de forma
clara. 6. Evitar dedicar este Sprint a diseñar todas las pantallas
futuras.
Entregables - Tema visual centralizado. - Componentes reutilizables
básicos. - Pantallas iniciales consistentes.
Criterios de aceptación - Las pantallas de acceso usan estilos
coherentes. - Los formularios muestran errores comprensibles y no
dependen únicamente del color para comunicar estados.
S1-03. Configurar Riverpod
Objetivo: gestionar las dependencias y el estado de la interfaz de
forma consistente.
Actividades 1. Configurar `flutter_riverpod` de acuerdo con la
versión aprobada. 2. Definir los proveedores necesarios para los
servicios de autenticación y perfil. 3. Separar el estado de la UI de
las llamadas directas a Supabase. 4. Definir estados de carga, datos
disponibles y error. 5. Evitar introducir una segunda biblioteca de
gestión de estado.
Entregables - Configuración inicial de Riverpod. - Proveedores de
autenticación y perfil, según el diseño implementado.
Criterios de aceptación - Las pantallas consumen el estado desde los
proveedores definidos. - La lógica de acceso a Supabase no queda
duplicada en varios widgets.
S1-04. Configurar la navegación con `go_router`
Objetivo: controlar la navegación inicial y las redirecciones según
la sesión.
Actividades 1. Configurar las rutas públicas y protegidas. 2. Crear
las pantallas mínimas para acceso, carga inicial y destino autenticado.
3. Implementar redirecciones cuando no existe sesión. 4. Implementar la
resolución del perfil y del rol antes de mostrar la navegación
correspondiente. 5. Manejar sesión vencida, cierre de sesión y errores
al consultar el perfil. 6. Evitar bucles de redirección y pantallas
bloqueadas indefinidamente. 7. Documentar que las rutas del cliente no
reemplazan la autorización del servidor.
Entregables - Configuración de rutas. - Redirecciones por sesión y
perfil. - Manejo de estados de carga y error durante la resolución de
acceso.
Criterios de aceptación - Un usuario anónimo no permanece en rutas
protegidas. - Una sesión válida conduce a la navegación permitida para
el perfil. - Los errores de carga o perfil ausente se manejan sin
mostrar datos privados.
S1-05. Configurar la conexión con Supabase
Objetivo: establecer una conexión segura y reproducible entre
Flutter y el proyecto Supabase de desarrollo.
Actividades 1. Inicializar `supabase_flutter` con la URL y la clave
pública apropiada para el cliente. 2. Cargar la configuración mediante
el mecanismo acordado para el entorno. 3. No incluir la clave
`service_role` ni secretos privilegiados en la aplicación. 4. Gestionar
errores de inicialización y falta de configuración. 5. Verificar
conectividad con una operación de prueba no sensible. 6. Documentar cómo
configurar el entorno local.
Entregables - Inicialización de Supabase. - Configuración local
documentada. - Manejo básico de errores de conexión.
Criterios de aceptación - La aplicación se conecta al proyecto
Supabase de desarrollo. - La configuración no contiene claves
privilegiadas. - Una configuración ausente o incorrecta produce un error
controlado.
S1-06. Implementar inicio y cierre de sesión
Objetivo: permitir que los usuarios accedan con el mecanismo de
autenticación aprobado y puedan cerrar su sesión.
Actividades 1. Confirmar el método de acceso que se usará en el MVP.
2. Implementar el formulario de inicio de sesión. 3. Validar campos
obligatorios y formato básico antes de enviar. 4. Conectar el formulario
con Supabase Auth. 5. Mostrar progreso mientras se procesa la solicitud.
6. Mostrar mensajes seguros ante credenciales incorrectas o fallos de
red. 7. Implementar cierre de sesión. 8. Escuchar los cambios del estado
de autenticación. 9. Evitar registrar contraseñas, tokens o información
sensible en logs.
Entregables - Pantalla funcional de inicio de sesión. - Cierre de
sesión. - Manejo del estado de sesión. - Mensajes de carga y error.
Criterios de aceptación - Un usuario válido puede iniciar sesión. -
Un usuario puede cerrar sesión y pierde el acceso a rutas protegidas. -
Las credenciales incorrectas no abren la aplicación autenticada. - Los
errores de red no se muestran como autenticaciones exitosas. - No se
registran secretos en logs.
S1-07. Definir y crear el perfil de aplicación
Objetivo: asociar la identidad autenticada con los datos mínimos y
el rol de negocio necesarios para la app.
Actividades 1. Revisar el modelo preliminar de perfiles definido en
el Sprint 0. 2. Definir la relación entre el identificador de Supabase
Auth y el perfil. 3. Crear una migración versionada para la tabla de
perfiles, si todavía no existe. 4. Definir campos mínimos, restricciones
y marcas de tiempo necesarias. 5. Definir cómo se crea o provisiona un
perfil. 6. Evitar que el cliente establezca por sí mismo un rol
privilegiado. 7. Manejar el caso de una identidad autenticada que aún no
tenga perfil. 8. No agregar datos personales que no sean necesarios.
Entregables - Modelo de perfil acordado. - Migración SQL
versionada. - Procedimiento documentado de creación o provisión de
perfiles.
Criterios de aceptación - El perfil está vinculado a una identidad
Auth de forma consistente. - La creación y actualización respetan las
restricciones. - La ausencia de perfil se trata como un estado pendiente
o no autorizado, no como permiso automático.
S1-08. Implementar la consulta del perfil autenticado
Objetivo: obtener los datos del usuario actual desde el backend y
utilizarlos para decidir la navegación.
Actividades 1. Crear el modelo de perfil necesario para la app. 2.
Crear una fuente de datos y un repositorio de perfiles. 3. Consultar
únicamente el perfil asociado a la identidad autenticada. 4. Convertir
errores del backend en estados manejables por la UI. 5. Evitar duplicar
consultas innecesarias durante reconstrucciones de widgets. 6. Mostrar
un estado de carga mientras se obtiene el perfil. 7. Manejar perfiles
inexistentes, desactivados o incompletos según las reglas aprobadas.
Entregables - Modelo de perfil. - Repositorio o capa de acceso a
perfiles. - Estado de perfil integrado con la navegación.
Criterios de aceptación - El usuario autenticado obtiene su perfil
autorizado. - Un usuario no puede obtener perfiles ajenos modificando
identificadores desde el cliente. - Los errores y perfiles inexistentes
se manejan de forma controlada.
S1-09. Definir el mecanismo confiable de asignación de roles
Objetivo: impedir que un usuario se otorgue permisos de
administrador, operador o repartidor.
Actividades 1. Definir quién está autorizado para asignar roles. 2.
Elegir un procedimiento confiable de provisión: por ejemplo,
administración controlada desde el backend o un proceso administrativo
restringido. 3. Evitar que el formulario de registro público permita
escoger un rol interno privilegiado. 4. Restringir las actualizaciones
del campo de rol desde el cliente. 5. Registrar los cambios de rol
relevantes cuando el diseño de auditoría esté disponible. 6. Documentar
el procedimiento para crear usuarios internos durante el desarrollo.
Entregables - Decisión técnica y funcional documentada. -
Procedimiento de provisión de usuarios y roles. - Restricciones
iniciales para impedir autoasignación de privilegios.
Criterios de aceptación - Un usuario normal no puede elevar sus
privilegios cambiando datos desde Flutter o enviando una solicitud
directa a la API. - Los roles internos se asignan mediante un mecanismo
controlado. - Si el procedimiento administrativo todavía no está listo,
el uso de roles privilegiados queda restringido al entorno de prueba.
S1-10. Configurar y probar políticas RLS para perfiles
Objetivo: proteger los perfiles en PostgreSQL independientemente de
las restricciones visuales de Flutter.
Actividades 1. Habilitar RLS en la tabla de perfiles expuesta por la
API. 2. Crear políticas explícitas de lectura y actualización según la
matriz de roles. 3. Permitir que un usuario consulte únicamente su
perfil, salvo excepciones administrativas aprobadas. 4. Restringir las
columnas o acciones que puedan modificar el rol. 5. Revisar permisos SQL
y políticas conjuntamente. 6. Crear migraciones versionadas para los
cambios. 7. Probar solicitudes permitidas y denegadas con identidades de
prueba distintas.
Entregables - Migraciones SQL de RLS y permisos. - Políticas
documentadas. - Evidencia de pruebas de autorización.
Criterios de aceptación - Un usuario no puede consultar o modificar
arbitrariamente el perfil de otro. - Las políticas no permiten
autoasignar roles privilegiados. - Las pruebas de acceso permitido y
denegado se ejecutan y sus resultados quedan registrados.
S1-11. Implementar la navegación inicial según el rol
Objetivo: presentar una pantalla inicial adecuada al perfil sin
confundir navegación con autorización real.
Actividades 1. Definir los destinos iniciales para los roles
aprobados. 2. Crear pantallas provisionales o contenedores iniciales
para cada destino que se necesite en este Sprint. 3. Resolver el rol
desde el perfil confiable del backend. 4. Gestionar roles desconocidos,
perfiles desactivados y perfiles sin autorización. 5. Evitar crear en
este Sprint los módulos completos de catálogo, pedidos, preparación o
delivery. 6. Mantener las rutas protegidas y la validación de datos en
el backend.
Entregables - Redirección inicial por rol. - Pantallas iniciales
mínimas o marcadores funcionales. - Tratamiento documentado de roles
desconocidos o no habilitados.
Criterios de aceptación - El usuario accede a la navegación inicial
correspondiente a su perfil. - Un rol desconocido o no habilitado no
recibe acceso privilegiado por defecto. - La autorización de operaciones
sigue dependiendo de Supabase/RLS y no solo de la ruta.
S1-12. Implementar validaciones y manejo de errores de autenticación
Objetivo: asegurar que los formularios y la experiencia de acceso
respondan de forma consistente ante entradas incorrectas y fallos del
servicio.
Actividades 1. Validar campos requeridos. 2. Evitar envíos repetidos
mientras una solicitud está en curso. 3. Mostrar estados de carga y
errores de red. 4. Manejar sesión vencida y cierre de sesión. 5. Evitar
mensajes que expongan detalles internos o información sensible. 6.
Asegurar que la UI se recupera cuando una solicitud falla.
Entregables - Validaciones del formulario. - Manejo uniforme de
errores y estados de carga. - Componentes o utilidades reutilizables que
sean necesarios.
Criterios de aceptación - Los formularios impiden solicitudes
evidentemente incompletas. - El usuario recibe mensajes comprensibles y
puede reintentar cuando corresponde. - Un fallo de red no deja la
interfaz bloqueada ni simula una operación exitosa.
S1-13. Crear pruebas unitarias y de widgets
Objetivo: verificar la lógica de autenticación y los estados
visibles de la interfaz.
Actividades 1. Probar validaciones de los campos de acceso. 2.
Probar el estado de carga, error y éxito del inicio de sesión mediante
dependencias controladas. 3. Probar el comportamiento de cierre de
sesión. 4. Probar la resolución del perfil y los casos de perfil
ausente. 5. Probar las redirecciones principales según sesión y rol. 6.
Evitar depender de cuentas reales o credenciales personales en pruebas
automatizadas.
Entregables - Pruebas unitarias de validaciones y lógica de
sesión. - Pruebas de widgets para acceso, carga y error. - Resultados
registrados en el repositorio o en CI.
Criterios de aceptación - Las pruebas definidas se ejecutan y
pasan. - Los casos de error y perfil ausente están cubiertos. - Las
pruebas no requieren credenciales personales ni datos reales.
S1-14. Probar autorización y aislamiento de perfiles
Objetivo: demostrar que las políticas del backend impiden accesos
indebidos.
Actividades 1. Preparar identidades de prueba con permisos
diferenciados. 2. Probar el acceso anónimo a recursos protegidos. 3.
Probar que un usuario consulta su propio perfil. 4. Probar que un
usuario no consulta ni modifica perfiles ajenos. 5. Probar intentos de
modificar el rol propio. 6. Probar el comportamiento de un usuario
autenticado sin perfil o con rol no habilitado. 7. Registrar resultados,
errores encontrados y correcciones.
Entregables - Casos de prueba de autorización. - Evidencia de
resultados. - Registro de defectos y correcciones.
Criterios de aceptación - Los accesos no autorizados son rechazados
por el backend, no solo ocultados por la interfaz. - Los intentos de
autoasignación de privilegios fallan. - Los casos probados quedan
documentados.
S1-15. Documentar administración básica de usuarios internos
Objetivo: establecer un procedimiento controlado para crear,
habilitar y desactivar usuarios internos durante el desarrollo.
Actividades 1. Documentar quién puede solicitar y autorizar una
cuenta interna. 2. Explicar cómo se crea la identidad Auth mediante el
procedimiento autorizado. 3. Explicar cómo se asocia el perfil y se
asigna el rol. 4. Documentar cómo desactivar o revocar el acceso. 5.
Evitar compartir contraseñas por repositorios, código o logs. 6.
Diferenciar el procedimiento de desarrollo del futuro procedimiento de
producción.
Entregable: `docs/14-administracion-usuarios-internos.md`
Criterio de aceptación: una persona autorizada puede seguir el
procedimiento documentado sin recurrir a una asignación de roles desde
la app cliente.
S1-16. Integrar, revisar y demostrar el incremento
Objetivo: cerrar el Sprint con una versión integrada y comprobable,
no con cambios aislados en ramas.
Actividades 1. Integrar los cambios mediante el flujo de revisión
acordado. 2. Ejecutar `dart format`, `flutter analyze` y `flutter test`.
3. Verificar las políticas y migraciones relacionadas con perfiles. 4.
Ejecutar la CI y revisar sus resultados. 5. Probar el flujo de inicio y
cierre de sesión en emulador o dispositivo. 6. Demostrar los casos de
acceso permitido y denegado. 7. Registrar limitaciones, defectos
pendientes y decisiones para el Sprint 2.
Entregables - Incremento integrado del Sprint 1. - Evidencia de
ejecución de pruebas y CI. - `docs/15-revision-sprint-1.md` o acta
equivalente de revisión.
Criterios de aceptación - La aplicación inicia, autentica, consulta
el perfil y cierra sesión según el alcance aprobado. - Las rutas
protegidas y las políticas RLS se verificaron. - No hay secretos
privilegiados en el cliente ni en el repositorio. - Los defectos
pendientes y la decisión de cierre están documentados.
---
5. Resumen de tareas y entregables
---
ID                      Tarea                   Entregable principal
---
S1-01                   Estructura y arranque   Estructura `lib/` y app ejecutable
de Flutter
S1-02                   Tema y componentes      Tema centralizado y componentes
básicos
S1-03                   Configurar Riverpod     Proveedores iniciales
S1-04                   Configurar `go_router`  Rutas y redirecciones
S1-05                   Conectar Supabase       Inicialización y configuración segura
S1-06                   Inicio/cierre de sesión Flujo de autenticación
S1-07                   Definir perfil          Modelo y migración de perfiles
S1-08                   Consultar perfil propio Modelo/repositorio y estado de perfil
S1-09                   Provisión de roles      Procedimiento confiable y restricciones
S1-10                   Configurar RLS          Migraciones y políticas probadas
S1-11                   Navegación por rol      Destinos iniciales y control de acceso
S1-12                   Validaciones y errores  Formularios y estados consistentes
S1-13                   Pruebas                 Pruebas automatizadas
unitarias/widgets
S1-14                   Pruebas de autorización Evidencia de acceso permitido/denegado
S1-15                   Documentar usuarios     `docs/14-administracion-usuarios-internos.md`
internos
S1-16                   Integrar y revisar      Incremento probado y acta de revisión
---
6. Estructura de código orientativa
``` text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme/
├── core/
│   ├── config/
│   ├── errors/
│   ├── logging/
│   └── widgets/
└── features/
    ├── auth/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    └── profiles/
        ├── data/
        ├── domain/
        └── presentation/

test/
├── features/
│   ├── auth/
│   └── profiles/
└── ...
supabase/
└── migrations/
```
La estructura es orientativa. Crear solamente las carpetas y capas que
se utilicen. No es obligatorio añadir una capa de dominio completa si no
aporta valor al flujo implementado; sí es necesario evitar que las
pantallas concentren consultas, reglas y control de permisos.
7. Lista de verificación para cerrar el Sprint 1
[ ] La app arranca en el dispositivo o emulador objetivo.
[ ] El tema y los componentes básicos están configurados.
[ ] Riverpod y `go_router` están integrados.
[ ] Supabase está inicializado con configuración segura.
[ ] El inicio y cierre de sesión funcionan.
[ ] El estado de sesión se maneja correctamente.
[ ] El perfil está vinculado a la identidad autenticada.
[ ] El usuario consulta solo su perfil autorizado.
[ ] Existe un mecanismo controlado de asignación de roles.
[ ] RLS y permisos SQL fueron revisados y probados.
[ ] Los usuarios no pueden asignarse roles privilegiados.
[ ] Las rutas protegidas responden a sesión y perfil.
[ ] Se manejan carga, error, perfil ausente y sesión vencida.
[ ] Las pruebas unitarias y de widgets definidas se ejecutaron.
[ ] Se probaron accesos permitidos y denegados en backend.
[ ] La CI se ejecutó con los cambios integrados.
[ ] No hay secretos privilegiados en el repositorio.
[ ] La documentación y la revisión del Sprint están actualizadas.
8. Resultado final esperado
Al terminar el Sprint 1, el desarrollador debe entregar:
Aplicación base: estructura Flutter, tema y componentes
iniciales.
Autenticación: inicio y cierre de sesión conectados con Supabase
Auth.
Perfiles: asociación entre identidad y perfil de aplicación.
Navegación protegida: redirecciones según sesión y rol, con
tratamiento de perfiles no habilitados.
Seguridad inicial: políticas RLS probadas y mecanismo controlado
de asignación de roles.
Pruebas: validaciones, widgets y casos de autorización
ejecutados.
Documentación: configuración, provisión de usuarios internos y
acta de revisión.
Integración continua: ejecución verificada de formato, análisis
y pruebas.
Criterio global de cierre: un usuario válido puede iniciar sesión,
consultar su propio perfil y cerrar sesión; un usuario no autenticado no
accede a rutas protegidas, y el backend impide consultar perfiles ajenos
o elevar privilegios. Los módulos comerciales ---catálogo y pedidos---
se desarrollarán en Sprints posteriores.