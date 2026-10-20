# Definition of Ready y Definition of Done

Fecha: 14 de octubre de 2026.

## Definition of Ready

Una historia puede empezarse cuando:

- tiene un objetivo y un identificador;
- el rol que la usa está nombrado;
- el criterio de aceptación se puede observar;
- las dependencias de negocio o de entorno están resueltas o están acotadas;
- se sabe qué datos personales toca y quién puede verlos;
- no exige una integración, un pago o una marca que sigan sin autorización.

Si falta una regla de negocio, la historia espera. No se inventa la regla dentro del código.

## Definition of Done

Una historia está terminada cuando:

- cumple el criterio de aceptación;
- el formato, el análisis y las pruebas afectadas se ejecutaron;
- los errores de usuario no revelan SQL, tokens ni si una cuenta existe;
- si cambia permisos, datos o una operación sensible, la regla también está en el servidor y hay una prueba negativa;
- la documentación afectada se actualizó;
- los defectos que queden están escritos, con lo que falta para cerrarlos.

Escribir el código o crear el archivo no cierra la historia.

## Revisión en un equipo de una persona

Antes de integrar, se revisa el diff completo, se vuelven a ejecutar las verificaciones y se distingue lo probado de lo pendiente. El cierre de un sprint deja un acta corta: hecho, bloqueado y decisión que falta.
