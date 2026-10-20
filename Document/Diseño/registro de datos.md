<!DOCTYPE html>

<html class="light" lang="es"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Tiendas MASS - Datos del Pedido</title>
<!-- Material Symbols Outlined -->
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<!-- Fonts Inter & Montserrat -->
<link href="https://fonts.googleapis.com" rel="preconnect"/>
<link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;family=Montserrat:wght@700;800&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<!-- Tailwind CSS v3 -->
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<script id="tailwind-config">
    tailwind.config = {
      darkMode: "class",
      theme: {
        extend: {
          "colors": {
            "on-secondary": "#ffffff",
            "inverse-primary": "#f1c100",
            "on-surface-variant": "#4e4632",
            "on-tertiary": "#ffffff",
            "primary-fixed": "#ffe08b",
            "primary-fixed-dim": "#f1c100",
            "secondary": "#bb010c",
            "surface-container-highest": "#dce2f3",
            "on-tertiary-container": "#5a5a59",
            "on-secondary-fixed-variant": "#930007",
            "surface": "#f9f9ff",
            "error": "#ba1a1a",
            "inverse-on-surface": "#ebf1ff",
            "surface-container-high": "#e2e8f8",
            "surface-variant": "#dce2f3",
            "on-surface": "#151c27",
            "surface-container-low": "#f0f3ff",
            "error-container": "#ffdad6",
            "on-primary-fixed-variant": "#584400",
            "secondary-fixed-dim": "#ffb4aa",
            "on-secondary-fixed": "#410001",
            "surface-tint": "#745b00",
            "surface-bright": "#f9f9ff",
            "secondary-container": "#e02923",
            "background": "#f9f9ff",
            "secondary-fixed": "#ffdad5",
            "on-error-container": "#93000a",
            "primary-container": "#ffcc00",
            "tertiary-container": "#d4d1d1",
            "surface-container-lowest": "#ffffff",
            "tertiary": "#5f5e5e",
            "on-secondary-container": "#fffbff",
            "on-tertiary-fixed-variant": "#474746",
            "outline-variant": "#d2c5ab",
            "primary": "#745b00",
            "on-tertiary-fixed": "#1c1b1b",
            "surface-dim": "#d3daea",
            "tertiary-fixed-dim": "#c8c6c5",
            "outline": "#80765f",
            "surface-container": "#e7eefe",
            "on-primary-fixed": "#241a00",
            "tertiary-fixed": "#e5e2e1",
            "on-error": "#ffffff",
            "on-background": "#151c27",
            "inverse-surface": "#2a313d",
            "on-primary": "#ffffff",
            "on-primary-container": "#6f5700"
          },
          "borderRadius": {
            "DEFAULT": "0.25rem",
            "lg": "0.5rem",
            "xl": "0.75rem",
            "full": "9999px"
          },
          "spacing": {
            "gutter": "1rem",
            "space-xs": "0.25rem",
            "space-lg": "1.5rem",
            "space-md": "1rem",
            "margin": "1rem",
            "space-sm": "0.5rem",
            "space-xl": "2rem"
          },
          "fontFamily": {
            "body-lg": ["Inter"],
            "currency-display": ["Montserrat"],
            "label-sm": ["Inter"],
            "headline-lg": ["Montserrat"],
            "order-code": ["Inter"],
            "body-md": ["Inter"],
            "headline-sm": ["Montserrat"],
            "body-sm": ["Inter"],
            "label-lg": ["Inter"],
            "label-md": ["Inter"],
            "display-lg": ["Montserrat"],
            "headline-md": ["Montserrat"]
          },
          "fontSize": {
            "body-lg": ["16px", { "lineHeight": "24px", "fontWeight": "400" }],
            "currency-display": ["28px", { "lineHeight": "32px", "fontWeight": "800" }],
            "label-sm": ["11px", { "lineHeight": "14px", "fontWeight": "700" }],
            "headline-lg": ["24px", { "lineHeight": "32px", "fontWeight": "700" }],
            "order-code": ["15px", { "lineHeight": "20px", "fontWeight": "700" }],
            "body-md": ["14px", { "lineHeight": "20px", "fontWeight": "400" }],
            "headline-sm": ["16px", { "lineHeight": "24px", "fontWeight": "700" }],
            "body-sm": ["12px", { "lineHeight": "16px", "fontWeight": "400" }],
            "label-lg": ["14px", { "lineHeight": "20px", "fontWeight": "600" }],
            "label-md": ["12px", { "lineHeight": "16px", "fontWeight": "600" }],
            "display-lg": ["32px", { "lineHeight": "40px", "fontWeight": "800" }],
            "headline-md": ["20px", { "lineHeight": "28px", "fontWeight": "700" }]
          }
        }
      }
    }
  </script>
<style>
    .material-symbols-outlined {
      font-variation-settings: 'FILL' 0, 'wght' 500, 'GRAD' 0, 'opsz' 24;
      display: inline-block;
      vertical-align: middle;
      line-height: 1;
    }
    input:focus, select:focus, textarea:focus {
      outline: none;
      box-shadow: 0 0 0 2px #ffcc00;
    }
  </style>
</head>
<body class="bg-background text-on-surface antialiased flex justify-center min-h-screen selection:bg-primary-container selection:text-on-primary-container">
<!-- Mobile Viewport Shell (Constraint: Max 480px) -->
<div class="w-full max-w-md bg-surface flex flex-col min-h-screen shadow-lg relative pb-36">
<!-- Top Status / Branding Sub-Header (Integrated TopAppBar Anchor) -->
<header class="sticky top-0 z-40 bg-surface/95 backdrop-blur-sm border-b border-outline-variant/30 px-margin py-3 flex items-center justify-between shadow-sm">
<div class="flex items-center gap-3">
<button aria-label="Volver" class="w-9 h-9 rounded-full flex items-center justify-center text-on-surface hover:bg-surface-container-high active:scale-95 transition-transform duration-150" type="button">
<span class="material-symbols-outlined text-[24px]">arrow_back</span>
</button>
<div>
<h1 class="font-headline-sm text-headline-sm text-on-surface tracking-tight">Datos del Pedido</h1>
<p class="font-label-sm text-label-sm text-on-surface-variant">MVP Operador • Tiendas MASS</p>
</div>
</div>
<div class="flex items-center gap-2">
<span class="bg-secondary text-on-secondary px-2.5 py-1 rounded-full font-label-sm text-label-sm tracking-wide">Paso 3 de 4</span>
</div>
</header>
<!-- Linear Progress Bar -->
<div class="w-full bg-surface-container-high h-1.5 overflow-hidden">
<div class="bg-primary-container h-full w-3/4 rounded-r-full transition-all duration-300"></div>
</div>
<!-- Main Content Form Area -->
<main class="flex-1 px-margin py-space-md space-y-space-md">
<!-- Context Banner -->
<div class="flex items-center justify-between p-3 rounded-xl bg-surface-container-lowest border border-outline-variant/40 shadow-sm">
<div class="flex items-center gap-2.5">
<div class="w-8 h-8 rounded-lg bg-primary-container flex items-center justify-center text-on-surface font-bold">
<span class="material-symbols-outlined text-[20px]">local_shipping</span>
</div>
<div>
<span class="font-label-md text-label-md text-on-surface block">Modalidad activa:</span>
<span class="font-headline-sm text-headline-sm text-secondary">Entrega a Domicilio</span>
</div>
</div>
<span class="font-order-code text-order-code px-2 py-0.5 bg-surface-container rounded border border-outline-variant/30 text-on-surface-variant">#MASS-10492</span>
</div>
<!-- SECCIÓN 1: DATOS DEL CLIENTE -->
<section class="bg-surface-container-lowest p-4 rounded-xl border border-outline-variant/40 shadow-sm space-y-3">
<div class="flex items-center gap-2 pb-1 border-b border-outline-variant/20">
<span class="material-symbols-outlined text-secondary text-[20px]">person</span>
<h2 class="font-headline-sm text-headline-sm text-on-surface">1. Datos del Cliente</h2>
</div>
<!-- Campo: Nombre y Apellidos -->
<div class="space-y-1">
<label class="font-label-md text-label-md text-on-surface-variant flex items-center justify-between" for="cliente-nombre">
<span>Nombre y Apellidos completos</span>
<span class="text-error font-body-sm text-body-sm">*</span>
</label>
<div class="relative">
<input class="w-full h-12 px-3 rounded-lg border border-outline text-on-surface font-body-md text-body-md bg-surface-bright focus:border-on-surface transition-colors" id="cliente-nombre" name="cliente-nombre" required="" type="text" value="Elena Quispe Huamán"/>
<span class="material-symbols-outlined absolute right-3 top-3 text-primary text-[20px]" style="font-variation-settings: 'FILL' 1;">check_circle</span>
</div>
</div>
<!-- Campo: Teléfono -->
<div class="space-y-1">
<label class="font-label-md text-label-md text-on-surface-variant flex items-center justify-between" for="cliente-telefono">
<span>Teléfono de contacto</span>
<span class="text-error font-body-sm text-body-sm">*</span>
</label>
<div class="flex items-center gap-2">
<div class="flex items-center gap-1 bg-surface-container h-12 px-3 rounded-lg border border-outline font-label-lg text-label-lg text-on-surface">
<span class="font-bold">🇵🇪 +51</span>
</div>
<div class="relative flex-1">
<input class="w-full h-12 pl-10 pr-3 rounded-lg border border-outline text-on-surface font-body-md text-body-md bg-surface-bright focus:border-on-surface transition-colors" id="cliente-telefono" name="cliente-telefono" required="" type="tel" value="987 654 321"/>
<span class="material-symbols-outlined absolute left-3 top-3 text-on-surface-variant text-[20px]">phone_enabled</span>
</div>
</div>
</div>
<!-- Selector Rápido: Cliente Frecuente -->
<div class="pt-2 flex items-center justify-between bg-surface-container-low p-3 rounded-lg border border-outline-variant/30">
<div class="flex items-center gap-2">
<span class="material-symbols-outlined text-primary text-[22px]">loyalty</span>
<div>
<span class="font-label-md text-label-md text-on-surface block">¿Cliente frecuente?</span>
<span class="font-body-sm text-body-sm text-on-surface-variant">Aplica beneficios MASS Ahorro</span>
</div>
</div>
<!-- Toggle Activo -->
<label class="relative inline-flex items-center cursor-pointer">
<input checked="" class="sr-only peer" type="checkbox"/>
<div class="w-11 h-6 bg-tertiary-container peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-secondary"></div>
</label>
</div>
</section>
<!-- SECCIÓN 2: DIRECCIÓN DE ENTREGA -->
<section class="bg-surface-container-lowest p-4 rounded-xl border border-outline-variant/40 shadow-sm space-y-3">
<div class="flex items-center gap-2 pb-1 border-b border-outline-variant/20">
<span class="material-symbols-outlined text-secondary text-[20px]">pin_drop</span>
<h2 class="font-headline-sm text-headline-sm text-on-surface">2. Dirección de Entrega</h2>
</div>
<!-- Campo: Dirección Exacta -->
<div class="space-y-1">
<label class="font-label-md text-label-md text-on-surface-variant flex items-center justify-between" for="entrega-direccion">
<span>Dirección exacta (Calle, Jr, Av, Número)</span>
<span class="text-error font-body-sm text-body-sm">*</span>
</label>
<input class="w-full h-12 px-3 rounded-lg border border-outline text-on-surface font-body-md text-body-md bg-surface-bright focus:border-on-surface transition-colors" id="entrega-direccion" name="entrega-direccion" required="" type="text" value="Av. Angélica Gamarra 1420, Dpto 302"/>
</div>
<!-- Campo: Distrito -->
<div class="space-y-1">
<label class="font-label-md text-label-md text-on-surface-variant flex items-center justify-between" for="entrega-distrito">
<span>Distrito</span>
<span class="text-error font-body-sm text-body-sm">*</span>
</label>
<div class="relative">
<select class="w-full h-12 px-3 appearance-none rounded-lg border border-outline text-on-surface font-body-md text-body-md bg-surface-bright focus:border-on-surface transition-colors" id="entrega-distrito" name="entrega-distrito">
<option selected="" value="los-olivos">Los Olivos, Lima</option>
<option value="san-martin">San Martín de Porres, Lima</option>
<option value="comas">Comas, Lima</option>
<option value="independencia">Independencia, Lima</option>
</select>
<span class="material-symbols-outlined absolute right-3 top-3 text-on-surface-variant pointer-events-none text-[20px]">expand_more</span>
</div>
</div>
<!-- Campo: Referencia de Entrega -->
<div class="space-y-1">
<label class="font-label-md text-label-md text-on-surface-variant" for="entrega-referencia">
            Referencia de entrega
          </label>
<input class="w-full h-12 px-3 rounded-lg border border-outline text-on-surface font-body-md text-body-md bg-surface-bright focus:border-on-surface transition-colors" id="entrega-referencia" name="entrega-referencia" type="text" value="Frente al parque Virgen del Rosario, reja blanca"/>
</div>
<!-- Campo: Instrucciones para Transportista -->
<div class="space-y-1">
<label class="font-label-md text-label-md text-on-surface-variant flex items-center gap-1" for="entrega-instrucciones">
<span class="material-symbols-outlined text-[16px] text-tertiary">info</span>
<span>Instrucciones para el transportista</span>
</label>
<textarea class="w-full p-3 rounded-lg border border-outline text-on-surface font-body-md text-body-md bg-surface-bright focus:border-on-surface transition-colors" id="entrega-instrucciones" name="entrega-instrucciones" rows="2">Timbrar al 302, portón izquierdo</textarea>
</div>
</section>
<!-- SECCIÓN 3: DETALLES DEL PAGO Y OBSERVACIONES -->
<section class="bg-surface-container-lowest p-4 rounded-xl border border-outline-variant/40 shadow-sm space-y-3">
<div class="flex items-center gap-2 pb-1 border-b border-outline-variant/20">
<span class="material-symbols-outlined text-secondary text-[20px]">payments</span>
<h2 class="font-headline-sm text-headline-sm text-on-surface">3. Detalles del Pago y Observaciones</h2>
</div>
<!-- Método de Pago Pactado -->
<div class="space-y-2">
<label class="font-label-md text-label-md text-on-surface-variant block">
            Método de pago pactado
          </label>
<!-- Opción 1: Efectivo (Seleccionada) -->
<label class="flex items-start gap-3 p-3 rounded-lg border-2 border-primary-container bg-surface-container-low cursor-pointer transition-all">
<input checked="" class="mt-1 text-primary focus:ring-primary-container h-4 w-4" name="metodo-pago" type="radio" value="efectivo"/>
<div class="flex-1">
<div class="flex items-center justify-between">
<span class="font-headline-sm text-headline-sm text-on-surface">Efectivo contra entrega</span>
<span class="px-2 py-0.5 rounded-full bg-primary-container text-on-primary-container font-label-sm text-label-sm">Cambio exacto</span>
</div>
<p class="font-body-sm text-body-sm text-on-surface mt-0.5">Cliente paga con <strong class="font-bold text-secondary">S/ 50.00</strong> (Vuelto: S/ 5.80)</p>
</div>
</label>
<!-- Opción 2: Billetera Digital -->
<label class="flex items-center gap-3 p-3 rounded-lg border border-outline-variant/50 bg-surface-container-lowest hover:bg-surface-container-low cursor-pointer transition-all">
<input class="text-primary focus:ring-primary-container h-4 w-4" name="metodo-pago" type="radio" value="digital"/>
<div class="flex-1 flex items-center justify-between">
<div>
<span class="font-headline-sm text-headline-sm text-on-surface block">Yape / Plin</span>
<span class="font-body-sm text-body-sm text-on-surface-variant">Confirmar captura de pantalla al recibir</span>
</div>
<span class="material-symbols-outlined text-tertiary text-[20px]">qr_code_scanner</span>
</div>
</label>
</div>
<!-- Observaciones Adicionales -->
<div class="space-y-1 pt-1">
<label class="font-label-md text-label-md text-on-surface-variant" for="pago-observaciones">
            Observaciones adicionales
          </label>
<input class="w-full h-11 px-3 rounded-lg border border-outline text-on-surface font-body-md text-body-md bg-surface-bright focus:border-on-surface transition-colors placeholder:text-outline" id="pago-observaciones" name="pago-observaciones" placeholder="Ej: Dejar con el vigilante en caso de no responder..." type="text"/>
</div>
</section>
<!-- Warning Operational Note -->
<div class="flex items-center gap-2 p-3 bg-amber-50 border-l-4 border-primary-container rounded-r-lg text-on-surface">
<span class="material-symbols-outlined text-primary text-[20px]">verified_user</span>
<p class="font-body-sm text-body-sm">
          Al registrar, se reservará el inventario en tienda y se despachará al transporte asignado.
        </p>
</div>
</main>
<!-- Caja Fija Inferior: Resumen y Botón de Acción Principal -->
<div class="fixed bottom-0 left-0 w-full z-50 flex justify-center bg-surface-container-lowest border-t border-outline-variant/40 shadow-[0px_-4px_16px_rgba(0,0,0,0.08)]">
<div class="w-full max-w-md p-margin space-y-2.5">
<!-- Resumen Compacto -->
<div class="flex items-center justify-between px-1">
<div class="flex items-baseline gap-1.5">
<span class="font-label-md text-label-md text-on-surface-variant">Total a cobrar:</span>
<span class="font-currency-display text-currency-display text-secondary tracking-tight">S/ 44.20</span>
</div>
<span class="font-label-sm text-label-sm bg-surface-container px-2.5 py-1 rounded-full text-on-surface-variant font-bold border border-outline-variant/30">
            8 items
          </span>
</div>
<!-- Botón Principal MASS -->
<button class="w-full h-14 bg-primary-container text-on-surface font-headline-sm text-headline-sm font-extrabold rounded-xl shadow-md hover:brightness-95 active:scale-[0.98] transition-all flex items-center justify-center gap-2 tracking-wide border border-outline-variant/20" type="button">
<span class="material-symbols-outlined text-[24px]" style="font-variation-settings: 'FILL' 1;">check_circle</span>
<span>Registrar Pedido Definitivo</span>
</button>
</div>
</div>
</div>
</body></html>