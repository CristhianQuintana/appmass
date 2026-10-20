Informe de Desarrollo --- Sprint 2
Catálogo de productos y modelo de datos de pedidos
Proyecto: Aplicación móvil de gestión de pedidos y entregas MASS  
Versión del informe: 1.0  
Fecha: 13 de octubre de 2026  
Sprint: 2  
Duración propuesta: 2 semanas  
Objetivo: disponer de una fuente definida de productos y una base de
datos preparada para representar pedidos y sus líneas.  
Stack: Flutter + Dart, Supabase, PostgreSQL, Riverpod y
repositorios.
---
1. Objetivo del Sprint
Implementar el catálogo básico de productos y preparar el modelo de
datos inicial que permitirá registrar pedidos en el Sprint 3. El
catálogo debe consultar productos desde una fuente de datos definida,
mostrar la información necesaria y aplicar permisos de lectura y
edición. La base de datos debe contar con tablas, relaciones,
restricciones y migraciones versionadas, sin cerrar decisiones de
negocio que todavía no hayan sido aprobadas.
Resultado esperado: el usuario autorizado puede consultar y buscar
productos desde la aplicación, mientras que el modelo de datos inicial
de productos, pedidos y líneas de pedido queda versionado y probado en
el entorno de desarrollo.
2. Prerrequisitos
Antes de comenzar, verificar que se cuenta con:
Aplicación Flutter base funcional.
Repositorio GitHub y flujo de integración continua.
Proyecto Supabase de desarrollo.
Inicio de sesión, perfiles y permisos del Sprint 1, o un registro
explícito de los bloqueos pendientes.
Roles preliminares y matriz de permisos.
Definición de la fuente del catálogo y de los precios, o decisión
expresa de usar datos ficticios para el desarrollo.
Reglas iniciales de pedidos suficientemente claras para diseñar el
esquema sin inventar procesos.
Si no se ha definido quién mantiene el catálogo o cuál es la fuente de
precios, se debe utilizar un conjunto de datos ficticios claramente
identificado para el prototipo y registrar la decisión pendiente. No se
debe presentar el catálogo ficticio como un catálogo oficial de MASS.
---
3. Alcance del Sprint
Incluye
Diseño inicial de las tablas de productos, pedidos y líneas de
pedido.
Relaciones, claves, restricciones e índices necesarios.
Definición inicial de estados y campos obligatorios.
Reglas para importes y redondeo.
Migraciones SQL versionadas.
Políticas RLS para consultar el catálogo.
Definición de roles que pueden crear o modificar productos.
Modelos de datos y repositorio del catálogo en Flutter.
Lista de productos y búsqueda básica.
Estados de carga, vacío y error.
Datos ficticios de prueba cuando corresponda.
Pruebas de restricciones, permisos, errores y consultas.
No incluye
Flujo completo de creación de pedidos desde la interfaz; corresponde
al Sprint 3.
Preparación de pedidos y asignación de repartidores.
Inventario en tiempo real, salvo que se apruebe expresamente y
exista una fuente confiable.
Integración con sistemas internos de MASS.
Pagos digitales, caja o comprobantes electrónicos.
Afirmar disponibilidad o stock real sin una fuente de datos
autorizada.
---
4. Tareas detalladas del desarrollador
S2-01. Revisar los requisitos y validar el modelo inicial
Objetivo: confirmar que el esquema de datos responde a los flujos
definidos en los Sprints anteriores.
Actividades 1. Revisar los documentos de alcance, roles, flujos y
estados. 2. Identificar los datos mínimos que requiere un producto. 3.
Identificar los datos mínimos de un pedido y sus líneas, sin implementar
todavía el flujo completo. 4. Confirmar si se requiere categoría, código
interno, descripción, imagen o indicador de producto activo. 5.
Identificar las reglas que todavía dependen de decisiones de negocio. 6.
Documentar las decisiones del esquema antes de crear migraciones.
Entregable: `docs/sprint-2-modelo-datos.md`
Criterios de aceptación - El modelo propuesto está vinculado a
requisitos documentados. - Las decisiones no confirmadas están
identificadas. - No se incorporan tablas o campos que supongan
funcionalidades fuera del MVP aprobado.
S2-02. Diseñar la tabla de productos
Objetivo: definir una estructura consistente para almacenar y
consultar los productos del catálogo.
Actividades 1. Definir los campos necesarios, como identificador,
nombre, descripción opcional, precio, estado activo y fechas de
creación/actualización. 2. Determinar si se necesita categoría o código
de producto. 3. Definir restricciones para evitar nombres vacíos y
precios inválidos. 4. Definir la representación del importe monetario y
sus reglas de precisión. 5. Definir cómo se representa un producto
inactivo. 6. Evitar guardar stock como dato confiable si no existe una
fuente autorizada. 7. Documentar los campos y sus reglas.
Entregable: diseño de `products` documentado en
`docs/sprint-2-modelo-datos.md`.
Criterios de aceptación - Los campos tienen propósito definido y
restricciones apropiadas. - Los productos inactivos pueden excluirse de
nuevos pedidos. - Los importes no utilizan tipos de punto flotante
inadecuados para representar dinero.
S2-03. Diseñar las tablas de pedidos y líneas de pedido
Objetivo: preparar la estructura necesaria para persistir pedidos y
sus productos sin duplicar ni perder información.
Actividades 1. Definir la tabla conceptual `orders`. 2. Definir la
tabla conceptual `order_items`. 3. Establecer claves primarias y
foráneas. 4. Definir la relación entre pedido y líneas. 5. Definir
campos para modalidad presencial o domicilio. 6. Definir los campos
mínimos del cliente y la dirección, según el alcance aprobado. 7.
Definir cómo se conservará el nombre y el precio aplicado a cada línea
cuando se confirme el pedido. 8. Definir el usuario que creó el pedido y
las marcas de tiempo necesarias. 9. Definir el estado inicial y su
relación con el historial de estados. 10. Registrar reglas aún
pendientes, como cancelación, sustitución o productos faltantes.
Entregable: diseño documentado de `orders` y `order_items`.
Criterios de aceptación - Cada línea está vinculada a un pedido y a
un producto válido. - El esquema permite distinguir atención presencial
y domicilio. - Se ha definido cómo conservar el precio aplicado al
pedido, sin depender exclusivamente del precio actual del catálogo. -
Las reglas no confirmadas están documentadas.
S2-04. Definir restricciones, índices e integridad de datos
Objetivo: prevenir registros inconsistentes en la base de datos.
Actividades 1. Definir claves primarias y foráneas. 2. Definir
restricciones para cantidades válidas e importes no negativos. 3.
Definir campos obligatorios según modalidad. 4. Evaluar índices para
consultas por identificador, estado y fecha. 5. Definir restricciones
para evitar líneas sin pedido o referencias inexistentes. 6. Revisar
cómo se gestionarán los cambios de precio y la desactivación de
productos. 7. Evitar índices innecesarios sin una consulta que los
justifique.
Entregable: especificación de integridad y restricciones en
`docs/sprint-2-modelo-datos.md`.
Criterios de aceptación - Las restricciones esenciales se aplican en
PostgreSQL y no dependen solamente de la validación de Flutter. - Las
relaciones y reglas de integridad pueden probarse. - Los índices
propuestos tienen una justificación funcional.
S2-05. Definir reglas de importes y redondeo
Objetivo: asegurar que los precios y totales puedan calcularse de
forma consistente al implementar el registro de pedidos.
Actividades 1. Elegir un tipo numérico apropiado para precios en
PostgreSQL. 2. Definir la precisión y escala de los importes. 3.
Documentar el cálculo de subtotal por línea. 4. Documentar el cálculo
del total del pedido. 5. Definir cuándo se conserva el precio aplicado
al confirmar el pedido. 6. Acordar las reglas de redondeo necesarias. 7.
Evitar depender de cálculos de punto flotante binario para importes
monetarios.
Entregable: sección de reglas monetarias en
`docs/sprint-2-modelo-datos.md`.
Criterios de aceptación - Los tipos y las reglas monetarias están
documentados. - Los casos de prueba cubren cantidades, precios y
redondeo según las reglas aprobadas.
S2-06. Crear migraciones SQL versionadas
Objetivo: hacer reproducible el esquema de base de datos entre
entornos.
Actividades 1. Configurar o verificar Supabase CLI. 2. Crear
migraciones para las tablas y restricciones aprobadas. 3. Añadir
políticas y permisos iniciales que correspondan. 4. Mantener los
archivos SQL dentro del repositorio. 5. Aplicar las migraciones al
entorno de desarrollo. 6. Verificar que una instalación limpia puede
reproducir el esquema mediante el procedimiento acordado. 7. Evitar
modificar silenciosamente migraciones ya compartidas; crear nuevas
migraciones para cambios posteriores.
Entregables - Archivos SQL versionados en `supabase/migrations/`. -
Registro de aplicación de migraciones.
Criterios de aceptación - Las migraciones se aplican correctamente
en desarrollo. - El esquema resultante coincide con el diseño
aprobado. - Los cambios pueden revisarse mediante Git y reproducirse con
el procedimiento documentado.
S2-07. Definir permisos para el catálogo
Objetivo: limitar la consulta y modificación de productos a los
perfiles autorizados.
Actividades 1. Confirmar qué perfiles pueden consultar productos. 2.
Definir quién puede crear, modificar o desactivar productos. 3.
Configurar permisos SQL y políticas RLS de lectura del catálogo. 4.
Evitar permitir escrituras a todos los usuarios autenticados por
defecto. 5. Probar acceso permitido y denegado con perfiles de prueba.
6. Documentar las políticas y su relación con la matriz de permisos.
Entregable: migraciones RLS y `docs/sprint-2-permisos-catalogo.md`.
Criterios de aceptación - Los usuarios autorizados consultan el
catálogo. - Las operaciones de edición están limitadas a los perfiles
aprobados. - Los accesos no autorizados se rechazan en el backend.
S2-08. Preparar datos de prueba para el catálogo
Objetivo: permitir el desarrollo y las pruebas sin depender de datos
reales no autorizados.
Actividades 1. Crear un conjunto pequeño de productos ficticios. 2.
Incluir productos activos e inactivos. 3. Incluir precios y categorías
ficticias si corresponden. 4. Etiquetar o documentar claramente el
conjunto como datos de prueba. 5. No copiar datos personales ni
información comercial restringida. 6. Definir cómo cargar o restablecer
los datos en desarrollo.
Entregable: archivo de datos de prueba o script de carga, más
instrucciones de uso.
Criterios de aceptación - Los datos se pueden cargar de forma
reproducible en desarrollo. - Los datos ficticios están identificados y
no se presentan como catálogo oficial.
S2-09. Crear modelos de datos para productos
Objetivo: representar los productos en Flutter de forma consistente
con el esquema del backend.
Actividades 1. Crear el modelo Dart de producto. 2. Implementar
conversión segura desde y hacia el formato de datos utilizado. 3.
Manejar campos opcionales según el esquema. 4. Evitar incluir campos que
el backend no devuelve o que no están aprobados. 5. Crear pruebas de
conversión del modelo. 6. Documentar cualquier diferencia intencional
entre el modelo de UI y el de persistencia.
Entregable: modelo Dart de producto y pruebas correspondientes.
Criterios de aceptación - El modelo representa correctamente los
campos acordados. - La conversión de datos se prueba y maneja valores
opcionales de forma controlada.
S2-10. Implementar el repositorio del catálogo
Objetivo: separar las consultas de Supabase de la interfaz de
usuario.
Actividades 1. Crear una fuente de datos para consultar productos.
2. Crear un repositorio que exponga operaciones necesarias para el
catálogo. 3. Consultar solo productos visibles para el usuario según
permisos y reglas acordadas. 4. Evitar duplicar consultas directamente
en diferentes widgets. 5. Manejar errores de conexión, permisos y
respuestas inesperadas. 6. Preparar dependencias sustituibles para
facilitar las pruebas.
Entregable: repositorio de catálogo y su integración con Riverpod.
Criterios de aceptación - La UI obtiene productos a través del
repositorio. - Los errores del backend se transforman en estados
manejables. - Las consultas respetan los permisos del backend.
S2-11. Implementar la lista de productos
Objetivo: permitir que el usuario autorizado consulte los productos
disponibles en la fuente acordada.
Actividades 1. Crear la pantalla de catálogo. 2. Mostrar los campos
aprobados, como nombre, precio y categoría cuando exista. 3. Excluir
productos inactivos de la selección para nuevos pedidos. 4. Implementar
indicador de carga. 5. Implementar estado vacío cuando no haya
productos. 6. Implementar mensajes de error y opción de reintento. 7.
Evitar mostrar disponibilidad o stock no confirmado. 8. Verificar
legibilidad y comportamiento en los dispositivos objetivo.
Entregable: pantalla de catálogo funcional conectada a Supabase.
Criterios de aceptación - La lista presenta los productos devueltos
por la fuente configurada. - Los productos inactivos no se ofrecen para
nuevos pedidos. - Los estados de carga, vacío y error funcionan. - No se
muestran datos comerciales no confirmados como si fueran reales.
S2-12. Implementar búsqueda básica
Objetivo: facilitar la localización de productos dentro del
catálogo.
Actividades 1. Crear un campo de búsqueda. 2. Definir qué campos se
pueden buscar, por ejemplo nombre o código si existe. 3. Aplicar una
consulta compatible con el tamaño del catálogo. 4. Evitar traer
cantidades ilimitadas de datos si no es necesario. 5. Mostrar un estado
claro cuando no haya coincidencias. 6. Probar búsqueda con
coincidencias, sin coincidencias y errores de red.
Entregable: búsqueda básica integrada en la pantalla del catálogo.
Criterios de aceptación - La búsqueda devuelve resultados coherentes
con los campos acordados. - Un término sin coincidencias muestra un
estado vacío comprensible. - La búsqueda no elimina ni omite
restricciones de autorización.
S2-13. Restringir la edición del catálogo
Objetivo: garantizar que solo los perfiles autorizados puedan
modificar productos.
Actividades 1. Confirmar si la edición del catálogo forma parte del
MVP y qué rol la realiza. 2. Si está aprobada, implementar únicamente
las operaciones necesarias. 3. Proteger las operaciones en el backend
con permisos y RLS. 4. No confiar exclusivamente en ocultar botones en
Flutter. 5. Si la edición no está aprobada para el MVP, mantener el
catálogo de solo lectura y documentar la decisión.
Entregable: control de edición de catálogo implementado o decisión
documentada de solo lectura.
Criterios de aceptación - Los perfiles sin permiso no pueden crear
ni modificar productos mediante la API. - La interfaz refleja los
permisos, pero el backend es quien los impone.
S2-14. Crear pruebas de base de datos y permisos
Objetivo: comprobar que el esquema y las políticas rechazan datos
inválidos y accesos no autorizados.
Actividades 1. Probar claves foráneas y restricciones esenciales. 2.
Probar cantidades e importes inválidos. 3. Probar lectura de catálogo
por perfiles autorizados. 4. Probar denegación de lectura o edición
según la matriz de permisos. 5. Probar que los productos inactivos no se
ofrecen para nuevos pedidos. 6. Documentar el entorno y los resultados
de cada prueba. 7. Corregir defectos y repetir los casos afectados.
Entregables - Pruebas de esquema y restricciones. - Pruebas de
autorización/RLS. - Registro de resultados y defectos.
Criterios de aceptación - Los casos definidos se ejecutaron. - Las
restricciones y políticas se validan en el backend. - Los resultados y
defectos pendientes están documentados.
S2-15. Probar el repositorio y los estados de la interfaz
Objetivo: asegurar que el catálogo maneja correctamente datos,
errores y respuestas vacías.
Actividades 1. Crear pruebas unitarias del modelo y repositorio. 2.
Probar lista con resultados, lista vacía y error. 3. Probar búsqueda con
coincidencias y sin ellas. 4. Probar comportamiento ante fallos de
conexión. 5. Usar dependencias simuladas cuando sea apropiado para
pruebas deterministas. 6. Ejecutar las pruebas en el entorno local y en
CI.
Entregable: pruebas unitarias y de widgets del catálogo.
Criterios de aceptación - Los estados principales de la UI están
cubiertos. - Las pruebas se ejecutan sin depender de un catálogo real
externo. - Los errores se muestran de forma controlada.
S2-16. Documentar el origen de los productos y el modelo de datos
Objetivo: mantener trazabilidad de las decisiones que afectan al
catálogo y a los pedidos.
Actividades 1. Documentar el origen del catálogo. 2. Registrar si
los datos son ficticios o proceden de una fuente autorizada. 3.
Documentar el modelo de tablas, relaciones y restricciones. 4. Registrar
reglas de precios, estados y permisos. 5. Documentar cómo aplicar
migraciones en desarrollo. 6. Registrar las decisiones que deben
cerrarse antes del Sprint 3.
Entregable: documentación de modelo de datos, catálogo, permisos y
migraciones actualizada.
Criterios de aceptación - Otro desarrollador puede comprender el
modelo y reproducir las migraciones siguiendo la documentación. - Los
supuestos y pendientes están claramente identificados.
S2-17. Integrar y revisar el incremento
Objetivo: cerrar el Sprint con un catálogo funcional y una base de
datos reproducible.
Actividades 1. Integrar los cambios mediante el flujo de revisión
acordado. 2. Ejecutar `dart format`, `flutter analyze` y `flutter test`.
3. Aplicar las migraciones en el entorno de desarrollo. 4. Probar el
catálogo en emulador o dispositivo. 5. Ejecutar la CI y revisar sus
resultados. 6. Confirmar que no se han incorporado secretos ni datos
reales no autorizados. 7. Registrar defectos y decisiones que
condicionan el Sprint 3.
Entregables - Incremento integrado del Sprint 2. - Evidencia de
pruebas y CI. - Acta breve de revisión: `docs/revision-sprint-2.md`.
Criterios de aceptación - El catálogo se consulta y busca desde la
aplicación. - Las migraciones se aplican y el modelo de datos queda
versionado. - Las políticas de acceso se probaron. - Los defectos
pendientes y la decisión de cierre están documentados.
---
5. Resumen de tareas y entregables
---
ID                      Tarea                   Entregable principal
---
S2-01                   Revisar requisitos y    `docs/sprint-2-modelo-datos.md`
modelo
S2-02                   Diseñar productos       Diseño de tabla `products`
S2-03                   Diseñar pedidos y       Diseño de `orders` y
líneas                  `order_items`
S2-04                   Definir integridad e    Restricciones documentadas
índices
S2-05                   Definir importes y      Reglas monetarias
redondeo
S2-06                   Crear migraciones SQL   Archivos en
`supabase/migrations/`
S2-07                   Configurar permisos del RLS y permisos documentados
catálogo
S2-08                   Preparar datos de       Script o archivo de datos
prueba                  ficticios
S2-09                   Crear modelos Dart      Modelo `Product` y pruebas
S2-10                   Implementar repositorio Repositorio conectado a Supabase
S2-11                   Crear lista de          Pantalla de catálogo
productos
S2-12                   Implementar búsqueda    Búsqueda básica
S2-13                   Restringir edición      Control backend o decisión de
solo lectura
S2-14                   Probar base de datos y  Casos de prueba y resultados
RLS
S2-15                   Probar repositorio e    Pruebas unitarias/widgets
interfaz
S2-16                   Documentar datos y      Documentación técnica actualizada
modelo
S2-17                   Integrar y revisar      Incremento, CI y acta de revisión
---
6. Estructura de archivos orientativa
``` text
lib/
└── features/
    └── products/
        ├── data/
        │   ├── models/
        │   ├── datasources/
        │   └── repositories/
        ├── domain/
        └── presentation/
            ├── providers/
            ├── screens/
            └── widgets/

supabase/
└── migrations/
    ├── <timestamp>_create_products.sql
    ├── <timestamp>_create_orders_and_items.sql
    └── <timestamp>_catalog_policies.sql

test/
└── features/
    └── products/
        ├── models/
        ├── repositories/
        └── presentation/

docs/
├── sprint-2-modelo-datos.md
├── sprint-2-permisos-catalogo.md
└── revision-sprint-2.md
```
Los nombres de migración son ejemplos. Deben generarse con la
herramienta y el procedimiento elegidos; no se deben reutilizar marcas
de tiempo inventadas ni editar migraciones ya compartidas sin control.
---
7. Lista de verificación para cerrar el Sprint 2
[ ] El modelo de productos está documentado.
[ ] Las tablas conceptuales de pedidos y líneas están diseñadas.
[ ] Las claves, restricciones e índices están justificados.
[ ] Las reglas monetarias y de redondeo están documentadas.
[ ] Las migraciones SQL están versionadas y aplicadas en desarrollo.
[ ] La fuente de productos y precios está documentada.
[ ] Los datos ficticios están identificados, si se utilizan.
[ ] El catálogo se consulta desde Flutter.
[ ] La búsqueda básica funciona.
[ ] Se manejan carga, vacío, error y reintento.
[ ] Los productos inactivos no se ofrecen para nuevos pedidos.
[ ] Los permisos de lectura y edición están probados.
[ ] Las restricciones esenciales se aplican en PostgreSQL.
[ ] Las pruebas del modelo, repositorio y UI se ejecutaron.
[ ] `dart format`, `flutter analyze` y `flutter test` se ejecutaron.
[ ] La CI terminó con resultados revisados.
[ ] La documentación y el acta de revisión están actualizadas.
8. Condiciones para iniciar el Sprint 3
Se recomienda iniciar el Sprint 3 cuando:
La fuente del catálogo está definida o se ha aprobado explícitamente
el uso temporal de datos ficticios.
Los productos y sus precios tienen un modelo acordado.
Las tablas de pedidos y líneas tienen un diseño validado para el
flujo del MVP.
Se definió cómo conservar el precio aplicado al confirmar el pedido.
Las migraciones y restricciones se pueden reproducir en desarrollo.
Los permisos de catálogo están probados.
Se aclararon los datos obligatorios para pedidos presenciales y a
domicilio.
Las reglas que todavía no estén resueltas se registraron y no
bloquean el desarrollo previsto.
9. Reglas de trabajo para el desarrollador
No presentar datos ficticios como catálogo oficial.
No declarar stock disponible sin una fuente confiable.
No confiar solo en validaciones de Flutter para integridad o
permisos.
Versionar todos los cambios de esquema mediante migraciones.
Evitar cambios destructivos de base de datos sin revisión.
No incorporar pagos, inventario integrado o integraciones internas
sin aprobación.
Ejecutar y registrar las pruebas; no declarar resultados que no se
comprobaron.
Mantener el alcance del Sprint enfocado en catálogo y preparación
del modelo de pedidos.
10. Resultado final esperado
Al cierre del Sprint 2, el desarrollador debe entregar:
Catálogo funcional: lista y búsqueda básica conectadas a la
fuente acordada.
Modelo de datos inicial: estructura de productos, pedidos y
líneas, con relaciones y restricciones.
Migraciones reproducibles: esquema versionado en el repositorio
y aplicado en desarrollo.
Seguridad del catálogo: permisos y políticas RLS probadas.
Pruebas: validaciones de base de datos, repositorio, búsqueda y
estados de interfaz.
Documentación: origen de datos, modelo, reglas monetarias y
decisiones pendientes.
Incremento integrado: cambios revisados, CI ejecutada y acta de
Sprint.
Criterio global de cierre: un usuario autorizado puede consultar y
buscar productos, las restricciones de acceso se imponen en el backend y
el esquema inicial de pedidos puede reproducirse en el entorno de
desarrollo. El registro completo de pedidos se implementará en el Sprint
3.