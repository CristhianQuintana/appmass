# Riesgos y decisiones pendientes

Fecha: 14 de octubre de 2026.

| ID | Riesgo | Probabilidad | Impacto | Tratamiento |
| --- | --- | --- | --- | --- |
| R1 | Usar marca o datos de MASS sin autorización | Media | Alto | Tratar el proyecto como independiente |
| R2 | No hay catálogo ni precios confiables | Alta | Alto | No implementar precios reales en este sprint |
| R3 | Permisos solo en la interfaz | Media | Alto | RLS de perfiles ya definida; falta aplicarla y probarla |
| R4 | No hay proyecto Supabase | Alta | Alto | La app no simula una sesión correcta si falta la configuración |
| R5 | Android sin licencias ni dispositivo | Alta | Medio | No se declara probada en Android |
| R6 | La CI no se ha ejecutado en GitHub | Alta | Medio | El flujo existe; falta el remoto y una corrida real |
| R7 | Registro público activado por defecto en Supabase | Media | Alto | La guía exige desactivarlo; el perfil nace sin privilegios |
| R8 | Sesión en almacenamiento sin cifrar | Media | Alto | Se usa el almacén seguro del sistema en lugar de SharedPreferences |
| R9 | Alcance de cliente, pagos e inventario se cuele en el MVP | Media | Alto | Quedan en P2, fuera de esta entrega |

## Decisiones que bloquean el uso real del Sprint 1

- Crear el proyecto Supabase de desarrollo.
- Confirmar quién provisiona los usuarios internos.
- Aceptar licencias Android y elegir el dispositivo de prueba.

## Decisiones que pueden esperar al módulo que las necesita

- Fuente del catálogo y regla de impuestos.
- Política de cancelación, faltantes y entrega fallida.
- Si el operador asigna transportistas.
- Evidencia de entrega.
- MFA para administradores. El proveedor puede hacerlo; todavía no está configurado ni probado.
- Varias tiendas y el canal del cliente.

## Responsable

Hoy no hay un responsable de negocio identificado en el repositorio. Las decisiones de producto las tiene que cerrar quien encargó el proyecto. Las decisiones técnicas locales de esta entrega están en `docs/09-decisiones-tecnicas.md`.
