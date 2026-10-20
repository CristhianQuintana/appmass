<!DOCTYPE html>

<html class="light" lang="es"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>Tiendas MASS - Catálogo de Productos</title>
<!-- Google Fonts: Inter & Montserrat -->
<link href="https://fonts.googleapis.com" rel="preconnect"/>
<link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;family=Montserrat:wght@700;800&amp;display=swap" rel="stylesheet"/>
<!-- Material Symbols Outlined -->
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<!-- Tailwind CSS CDN -->
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
    .no-scrollbar::-webkit-scrollbar { display: none; }
    .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
  </style>
</head>
<body class="bg-surface text-on-surface font-body-md text-body-md antialiased min-h-screen flex justify-center selection:bg-primary-container selection:text-on-surface">
<!-- Mobile Container (Simulates Android Hardware Layout) -->
<div class="w-full max-w-md min-h-screen bg-surface flex flex-col relative pb-32">
<!-- Top Bar / App Header -->
<header class="sticky top-0 z-40 bg-surface-container-lowest shadow-sm px-margin pt-3 pb-3">
<!-- Android Status Anchor / Top Controls -->
<div class="flex items-center justify-between gap-3 mb-3">
<button aria-label="Volver" class="w-10 h-10 flex items-center justify-center rounded-xl bg-surface-container hover:bg-surface-container-high active:scale-95 transition-transform text-on-surface" type="button">
<span class="material-symbols-outlined text-[24px]">arrow_back</span>
</button>
<div class="flex-1">
<span class="text-label-sm font-label-sm text-secondary uppercase tracking-wider block">MASS Operaciones</span>
<h1 class="text-headline-md font-headline-md text-on-surface tracking-tight leading-none">Agregar Productos</h1>
</div>
<div class="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-surface-container-low border border-outline-variant/40">
<span class="material-symbols-outlined text-[16px] text-primary" style="font-variation-settings: 'FILL' 1;">storefront</span>
<span class="text-label-sm font-label-sm text-on-surface">MASS-048</span>
</div>
</div>
<!-- Search Input Component -->
<div class="relative flex items-center">
<span class="material-symbols-outlined absolute left-3.5 text-[22px] text-outline pointer-events-none">search</span>
<input class="w-full h-12 pl-11 pr-11 bg-surface-container-low rounded-xl border border-outline-variant/50 text-body-md font-body-md text-on-surface placeholder:text-outline focus:outline-none focus:ring-2 focus:ring-primary-container focus:border-on-surface transition-all text-ellipsis" placeholder="Buscar abarrotes, bebidas, limpieza..." type="search"/>
<button aria-label="Escanear Código de Barras" class="absolute right-2.5 w-8 h-8 flex items-center justify-center rounded-lg bg-surface-container-lowest shadow-sm border border-outline-variant/30 text-on-surface active:scale-90 transition-transform" type="button">
<span class="material-symbols-outlined text-[20px]">barcode_scanner</span>
</button>
</div>
<!-- Carousel Category Chips -->
<div class="flex items-center gap-2 overflow-x-auto no-scrollbar pt-3 -mx-margin px-margin">
<button class="whitespace-nowrap px-4 py-2 rounded-full bg-on-surface text-surface-container-lowest font-label-md text-label-md shadow-sm active:scale-95 transition-all" type="button">
          Todos
        </button>
<button class="whitespace-nowrap px-4 py-2 rounded-full bg-surface-container hover:bg-surface-container-high text-on-surface font-label-md text-label-md border border-outline-variant/30 active:scale-95 transition-all" type="button">
          Abarrotes
        </button>
<button class="whitespace-nowrap px-4 py-2 rounded-full bg-surface-container hover:bg-surface-container-high text-on-surface font-label-md text-label-md border border-outline-variant/30 active:scale-95 transition-all" type="button">
          Lácteos &amp; Huevos
        </button>
<button class="whitespace-nowrap px-4 py-2 rounded-full bg-surface-container hover:bg-surface-container-high text-on-surface font-label-md text-label-md border border-outline-variant/30 active:scale-95 transition-all" type="button">
          Bebidas
        </button>
<button class="whitespace-nowrap px-4 py-2 rounded-full bg-surface-container hover:bg-surface-container-high text-on-surface font-label-md text-label-md border border-outline-variant/30 active:scale-95 transition-all" type="button">
          Snacks
        </button>
<button class="whitespace-nowrap px-4 py-2 rounded-full bg-surface-container hover:bg-surface-container-high text-on-surface font-label-md text-label-md border border-outline-variant/30 active:scale-95 transition-all" type="button">
          Limpieza
        </button>
</div>
</header>
<!-- Operational Banner / Micro-Telemetry -->
<div class="px-margin pt-3 pb-1">
<div class="bg-surface-container-low rounded-xl p-3 border border-outline-variant/40 flex items-center justify-between">
<div class="flex items-center gap-2">
<span class="w-2.5 h-2.5 rounded-full bg-primary-container animate-pulse"></span>
<span class="text-label-md font-label-md text-on-surface">Picking Activo: Pedido #MASS-9281</span>
</div>
<span class="text-label-sm font-label-sm bg-surface-container-lowest px-2 py-0.5 rounded border border-outline-variant/30 text-on-surface-variant font-mono">STOCK EN LÍNEA</span>
</div>
</div>
<!-- Product Grid / Listing -->
<main class="px-margin pt-2 flex flex-col gap-3">
<!-- Item 1: Arroz Costeño -->
<article class="bg-surface-container-lowest rounded-xl border border-outline-variant/40 p-3.5 shadow-sm flex flex-col gap-3 transition-shadow hover:shadow-md">
<div class="flex gap-3">
<div class="w-20 h-20 rounded-lg bg-surface-container-low overflow-hidden flex-shrink-0 border border-outline-variant/30">
<img class="w-full h-full object-cover" data-alt="A clean studio product photograph of a standard 1kg packet of white Costeno rice against an off-white minimalist background. The lighting is bright commercial light-mode style with realistic reflections and subtle shadows, focusing on the retail package textures and deep red branding." src="https://lh3.googleusercontent.com/aida-public/AB6AXuCCXh6fMHAP6GEFIzyo5niKpMadZdtjdfPt2piWqZSvUahS4T1E7r83bd8qK35K-5q6u5YJ9eWJBdH1-7rk2IKuiAaaIVYK9bj5OqYQuwj1ADrRkrDafX4EuMcHtL9emxWzJIgWUg7atFasWWZrO0PuOBpGQEdg1v63iVuy4aOVjfZ1nv5d59WrBJJUcmOO7fHXYaTiy-F3QcPCGCdHuY4pg4iYPBKHtukI_2pOgEjJ3A2pfW4HTYWK6A"/>
</div>
<div class="flex-1 flex flex-col justify-between min-w-0">
<div>
<div class="flex items-start justify-between gap-1">
<span class="text-label-sm font-label-sm text-secondary font-mono tracking-tight">SKU: 7750182001</span>
<span class="text-label-sm font-label-sm text-on-surface-variant font-medium">Pasillo 02</span>
</div>
<h2 class="text-headline-sm font-headline-sm text-on-surface truncate">Arroz Costeño Extra 1 kg</h2>
<p class="text-body-sm font-body-sm text-on-surface-variant">Unidad: S/ 4.80</p>
</div>
<div class="flex items-baseline justify-between pt-1">
<span class="text-headline-md font-headline-md text-on-surface">S/ 4.80</span>
<span class="text-label-sm font-label-sm text-primary font-bold bg-primary-container/20 px-2 py-0.5 rounded">Subtotal: S/ 9.60</span>
</div>
</div>
</div>
<!-- Stepper Component -->
<div class="flex items-center justify-between pt-2 border-t border-outline-variant/30">
<span class="text-body-sm font-body-sm text-on-surface-variant">Cantidad a entregar:</span>
<div class="flex items-center bg-surface-container-low rounded-xl border border-outline-variant/50 p-0.5">
<button aria-label="Disminuir Arroz Costeño" class="w-10 h-10 flex items-center justify-center rounded-lg bg-surface-container-lowest text-on-surface shadow-xs active:bg-surface-container-high transition-transform active:scale-90 font-bold" type="button">
<span class="material-symbols-outlined text-[20px]">remove</span>
</button>
<span class="w-10 text-center font-headline-sm text-headline-sm text-on-surface select-none">2</span>
<button aria-label="Aumentar Arroz Costeño" class="w-10 h-10 flex items-center justify-center rounded-lg bg-primary-container text-on-surface shadow-xs active:scale-90 transition-transform font-bold" type="button">
<span class="material-symbols-outlined text-[20px]">add</span>
</button>
</div>
</div>
</article>
<!-- Item 2: Leche Evaporada Gloria Azul -->
<article class="bg-surface-container-lowest rounded-xl border border-outline-variant/40 p-3.5 shadow-sm flex flex-col gap-3 transition-shadow hover:shadow-md">
<div class="flex gap-3">
<div class="w-20 h-20 rounded-lg bg-surface-container-low overflow-hidden flex-shrink-0 border border-outline-variant/30">
<img class="w-full h-full object-cover" data-alt="A commercial e-commerce product photograph of a classic blue Gloria evaporated milk 400g metal can, lit with pristine studio lighting against a clean white backdrop. Soft reflections highlight the metallic rim and deep blue label graphics in crisp focus with authentic retail aesthetic." src="https://lh3.googleusercontent.com/aida-public/AB6AXuAyHLZgKDM3RfBNTulALDz_9zxKcJpT4DFktAzb99In5J7fQ7S7YVbv6KJWg7mYbeuVUDTluxix53m_Xfs9eohcQM0ZJK36syvnQmxTbSg9J9NFrLW_pnG79Hr0-iDt8fThLYGcXaGaZMMX-JMHAY3DUQkVuAFcmFxZ8Fs_tlbHAzaRTFeLcVhajIRtIgtcbA9lHq5xXFBMDj4Lp_8CXUezGn1iloBtgi8XoejnuRGkngwnShgmuU57ww"/>
</div>
<div class="flex-1 flex flex-col justify-between min-w-0">
<div>
<div class="flex items-start justify-between gap-1">
<span class="text-label-sm font-label-sm text-secondary font-mono tracking-tight">SKU: 7750243004</span>
<span class="text-label-sm font-label-sm text-on-surface-variant font-medium">Pasillo 01</span>
</div>
<h2 class="text-headline-sm font-headline-sm text-on-surface truncate">Leche Evaporada Gloria Azul 400g</h2>
<p class="text-body-sm font-body-sm text-on-surface-variant">Unidad: S/ 4.20</p>
</div>
<div class="flex items-baseline justify-between pt-1">
<span class="text-headline-md font-headline-md text-on-surface">S/ 4.20</span>
<span class="text-label-sm font-label-sm text-primary font-bold bg-primary-container/20 px-2 py-0.5 rounded">Subtotal: S/ 12.60</span>
</div>
</div>
</div>
<!-- Stepper Component -->
<div class="flex items-center justify-between pt-2 border-t border-outline-variant/30">
<span class="text-body-sm font-body-sm text-on-surface-variant">Cantidad a entregar:</span>
<div class="flex items-center bg-surface-container-low rounded-xl border border-outline-variant/50 p-0.5">
<button aria-label="Disminuir Leche Gloria" class="w-10 h-10 flex items-center justify-center rounded-lg bg-surface-container-lowest text-on-surface shadow-xs active:bg-surface-container-high transition-transform active:scale-90 font-bold" type="button">
<span class="material-symbols-outlined text-[20px]">remove</span>
</button>
<span class="w-10 text-center font-headline-sm text-headline-sm text-on-surface select-none">3</span>
<button aria-label="Aumentar Leche Gloria" class="w-10 h-10 flex items-center justify-center rounded-lg bg-primary-container text-on-surface shadow-xs active:scale-90 transition-transform font-bold" type="button">
<span class="material-symbols-outlined text-[20px]">add</span>
</button>
</div>
</div>
</article>
<!-- Item 3: Aceite Vegetal Primor -->
<article class="bg-surface-container-lowest rounded-xl border border-outline-variant/40 p-3.5 shadow-sm flex flex-col gap-3 transition-shadow hover:shadow-md">
<div class="flex gap-3">
<div class="w-20 h-20 rounded-lg bg-surface-container-low overflow-hidden flex-shrink-0 border border-outline-variant/30">
<img class="w-full h-full object-cover" data-alt="A clean studio photo of a Primor 900ml clear plastic cooking oil bottle filled with vibrant golden liquid. Clean bright daylight highlights the clear transparency and the green and red brand sticker, set on a pristine white surface with ultra realistic high-key studio treatment." src="https://lh3.googleusercontent.com/aida-public/AB6AXuA3bqJCqtDbAJ9cuL9NAdLNz-xKLhHmQRPllUklG-scRJSg7KBGc9ptGXvCy8FON4O18WmRqNYHlB4m3iBPdsOqsSmnPVMLTSey5j_tbwJ4v49DfkgIkD5OvZIA31yai4gIvewH9wX6FbkI6zJCrPqLGPAiWl3LS813xEXP0t8fByTohY3W61bOozLEqQRMKn02KoTK915NsHLDMZRn4Lklwf2ZhC6GvTBfNqxGaUkMrT_Tb5LupXoX7w"/>
</div>
<div class="flex-1 flex flex-col justify-between min-w-0">
<div>
<div class="flex items-start justify-between gap-1">
<span class="text-label-sm font-label-sm text-secondary font-mono tracking-tight">SKU: 7750892019</span>
<span class="text-label-sm font-label-sm text-on-surface-variant font-medium">Pasillo 03</span>
</div>
<h2 class="text-headline-sm font-headline-sm text-on-surface truncate">Aceite Vegetal Primor 900ml</h2>
<p class="text-body-sm font-body-sm text-on-surface-variant">Unidad: S/ 9.50</p>
</div>
<div class="flex items-baseline justify-between pt-1">
<span class="text-headline-md font-headline-md text-on-surface">S/ 9.50</span>
<span class="text-label-sm font-label-sm text-primary font-bold bg-primary-container/20 px-2 py-0.5 rounded">Subtotal: S/ 9.50</span>
</div>
</div>
</div>
<!-- Stepper Component -->
<div class="flex items-center justify-between pt-2 border-t border-outline-variant/30">
<span class="text-body-sm font-body-sm text-on-surface-variant">Cantidad a entregar:</span>
<div class="flex items-center bg-surface-container-low rounded-xl border border-outline-variant/50 p-0.5">
<button aria-label="Disminuir Aceite Primor" class="w-10 h-10 flex items-center justify-center rounded-lg bg-surface-container-lowest text-on-surface shadow-xs active:bg-surface-container-high transition-transform active:scale-90 font-bold" type="button">
<span class="material-symbols-outlined text-[20px]">remove</span>
</button>
<span class="w-10 text-center font-headline-sm text-headline-sm text-on-surface select-none">1</span>
<button aria-label="Aumentar Aceite Primor" class="w-10 h-10 flex items-center justify-center rounded-lg bg-primary-container text-on-surface shadow-xs active:scale-90 transition-transform font-bold" type="button">
<span class="material-symbols-outlined text-[20px]">add</span>
</button>
</div>
</div>
</article>
<!-- Item 4: Gaseosa Inca Kola -->
<article class="bg-surface-container-lowest rounded-xl border border-outline-variant/40 p-3.5 shadow-sm flex flex-col gap-3 transition-shadow hover:shadow-md">
<div class="flex gap-3">
<div class="w-20 h-20 rounded-lg bg-surface-container-low overflow-hidden flex-shrink-0 border border-outline-variant/30">
<img class="w-full h-full object-cover" data-alt="A commercial product shot of a 1.5L non-returnable bottle of Inca Kola soda, showing vivid luminous yellow-golden beverage inside with crisp condensation drops on the plastic bottle. Pure white light-box background, perfectly exposed commercial studio look." src="https://lh3.googleusercontent.com/aida-public/AB6AXuBm9_b7V6ZryhA5ODrcrEKQkqI6x9uV1Xa5kLNx42xHFyDpUXmPMGCqd4_Q_62ijYd9q00HPbEfUzFCt2vkrlLF9uOI2pT7Xxm2eeOXNLwG0HoyzAeu6RU0915zeRECPWvxce5fx_K9E-kOdsUCkGZUPuj3-STFGxFinH1efLgc9Zmg9eliskZrjP-un-loMK0XGaHXYC0KfA77tQleYBt9y7HGsNkB0yJk7D1JV2mbLk4UCJmptB_0fg"/>
</div>
<div class="flex-1 flex flex-col justify-between min-w-0">
<div>
<div class="flex items-start justify-between gap-1">
<span class="text-label-sm font-label-sm text-secondary font-mono tracking-tight">SKU: 7750391090</span>
<span class="text-label-sm font-label-sm text-on-surface-variant font-medium">Bebidas 01</span>
</div>
<h2 class="text-headline-sm font-headline-sm text-on-surface truncate">Gaseosa Inca Kola 1.5L No Retornable</h2>
<p class="text-body-sm font-body-sm text-on-surface-variant">Unidad: S/ 6.50</p>
</div>
<div class="flex items-baseline justify-between pt-1">
<span class="text-headline-md font-headline-md text-on-surface">S/ 6.50</span>
<span class="text-label-sm font-label-sm text-primary font-bold bg-primary-container/20 px-2 py-0.5 rounded">Subtotal: S/ 13.00</span>
</div>
</div>
</div>
<!-- Stepper Component -->
<div class="flex items-center justify-between pt-2 border-t border-outline-variant/30">
<span class="text-body-sm font-body-sm text-on-surface-variant">Cantidad a entregar:</span>
<div class="flex items-center bg-surface-container-low rounded-xl border border-outline-variant/50 p-0.5">
<button aria-label="Disminuir Inca Kola" class="w-10 h-10 flex items-center justify-center rounded-lg bg-surface-container-lowest text-on-surface shadow-xs active:bg-surface-container-high transition-transform active:scale-90 font-bold" type="button">
<span class="material-symbols-outlined text-[20px]">remove</span>
</button>
<span class="w-10 text-center font-headline-sm text-headline-sm text-on-surface select-none">2</span>
<button aria-label="Aumentar Inca Kola" class="w-10 h-10 flex items-center justify-center rounded-lg bg-primary-container text-on-surface shadow-xs active:scale-90 transition-transform font-bold" type="button">
<span class="material-symbols-outlined text-[20px]">add</span>
</button>
</div>
</div>
</article>
<!-- Item 5: Detergente Bolívar -->
<article class="bg-surface-container-lowest rounded-xl border border-outline-variant/40 p-3.5 shadow-sm flex flex-col gap-3 transition-shadow hover:shadow-md">
<div class="flex gap-3">
<div class="w-20 h-20 rounded-lg bg-surface-container-low overflow-hidden flex-shrink-0 border border-outline-variant/30">
<img class="w-full h-full object-cover" data-alt="A high-key commercial retail pack shot of a Bolivar Floral 800g laundry powder bag, standing upright against an ultra clean white surface. Soft balanced studio lighting showcases the vibrant pink floral packaging design with rich saturation and crisp edges." src="https://lh3.googleusercontent.com/aida-public/AB6AXuDtrCfNzwNi9ihns1peIE2RwlkOr0HHQWpXFfm2Sj83HEY8ZsZnfXgte1K3R6h8Ao17DhiiSDPBK8PgdU_lqbFU_Tdd4F_pkLkb25uBjRQTQ6DBnRXQRDa7UvQiyS3IzjBiV3Gp1M0vS7aujprLNQHreTGpTZIE8vXsMiNS4BxrPl-ZMEBCyAoxcJwQ8ddnptzlOMZN9yd-7ppZRrcJYogdR2uBQwoOI9u96mW03tbtmMAAv0FYtlLsSg"/>
</div>
<div class="flex-1 flex flex-col justify-between min-w-0">
<div>
<div class="flex items-start justify-between gap-1">
<span class="text-label-sm font-label-sm text-secondary font-mono tracking-tight">SKU: 7750129841</span>
<span class="text-label-sm font-label-sm text-on-surface-variant font-medium">Limpieza 02</span>
</div>
<h2 class="text-headline-sm font-headline-sm text-on-surface truncate">Detergente Bolívar Floral 800g</h2>
<p class="text-body-sm font-body-sm text-on-surface-variant">Bolsa 800g polvo activo</p>
</div>
<div class="flex items-baseline justify-between pt-1">
<span class="text-headline-md font-headline-md text-on-surface">S/ 7.80</span>
<span class="text-label-sm font-label-sm text-outline">Sin agregar</span>
</div>
</div>
</div>
<!-- Action Button Add -->
<div class="flex items-center justify-end pt-2 border-t border-outline-variant/30">
<button class="w-full sm:w-auto h-11 px-5 rounded-xl bg-surface-container border border-outline-variant/60 hover:bg-primary-container active:scale-95 transition-all flex items-center justify-center gap-2 font-label-lg text-label-lg text-on-surface" type="button">
<span class="material-symbols-outlined text-[20px] text-primary" style="font-variation-settings: 'FILL' 1;">add_circle</span>
<span>+ Agregar</span>
</button>
</div>
</article>
<!-- Item 6: Fideos Don Vittorio Spaghetti -->
<article class="bg-surface-container-lowest rounded-xl border border-outline-variant/40 p-3.5 shadow-sm flex flex-col gap-3 transition-shadow hover:shadow-md">
<div class="flex gap-3">
<div class="w-20 h-20 rounded-lg bg-surface-container-low overflow-hidden flex-shrink-0 border border-outline-variant/30">
<img class="w-full h-full object-cover" data-alt="A clean product shot of Don Vittorio Spaghetti pasta 450g blue plastic transparent packaging showing golden pasta strands inside. Lit with soft white studio lighting on a neutral white background, creating an authentic discount supermarket retail presentation." src="https://lh3.googleusercontent.com/aida-public/AB6AXuACXI1LC2yTLPNwCC9s1aZxuvxCa4tfbY9c9JIrYhqCUdjKbE7mDWnG46a-AqDaGjjy6z1bQLHebYCTni95z6vWR70-LBldzX3nv4uZV1z7HipgXG7F9DqneAZHfRqWPgvynWAzLRnIUWom1ObxJh45RTxaY54oyqsSil8Vex7oha9L--cyZILrKTjSCoKTwTT8aJtRvXdr5YXB0W3SDNZxkWZwu-HqNYdMs3AL_agLTl00jPgy_CHXBw"/>
</div>
<div class="flex-1 flex flex-col justify-between min-w-0">
<div>
<div class="flex items-start justify-between gap-1">
<span class="text-label-sm font-label-sm text-secondary font-mono tracking-tight">SKU: 7750100411</span>
<span class="text-label-sm font-label-sm text-on-surface-variant font-medium">Pasillo 02</span>
</div>
<h2 class="text-headline-sm font-headline-sm text-on-surface truncate">Fideos Don Vittorio Spaghetti 450g</h2>
<p class="text-body-sm font-body-sm text-on-surface-variant">Paquete 450g clásico</p>
</div>
<div class="flex items-baseline justify-between pt-1">
<span class="text-headline-md font-headline-md text-on-surface">S/ 2.70</span>
<span class="text-label-sm font-label-sm text-outline">Sin agregar</span>
</div>
</div>
</div>
<!-- Action Button Add -->
<div class="flex items-center justify-end pt-2 border-t border-outline-variant/30">
<button class="w-full sm:w-auto h-11 px-5 rounded-xl bg-surface-container border border-outline-variant/60 hover:bg-primary-container active:scale-95 transition-all flex items-center justify-center gap-2 font-label-lg text-label-lg text-on-surface" type="button">
<span class="material-symbols-outlined text-[20px] text-primary" style="font-variation-settings: 'FILL' 1;">add_circle</span>
<span>+ Agregar</span>
</button>
</div>
</article>
</main>
<!-- Bottom Sheet Fixed Bar (Elegante negro con acento amarillo MASS) -->
<aside class="fixed bottom-0 left-0 right-0 max-w-md mx-auto z-50 bg-[#111111] text-white px-4 pt-3.5 pb-5 rounded-t-2xl shadow-[0px_-6px_20px_rgba(0,0,0,0.35)] border-t border-[#262626]">
<div class="w-12 h-1 bg-[#333333] rounded-full mx-auto mb-2.5"></div>
<div class="flex items-center justify-between gap-3">
<!-- Cart & Total Info -->
<div class="flex flex-col">
<div class="flex items-center gap-1.5">
<span class="w-2 h-2 rounded-full bg-primary-container"></span>
<span class="text-label-sm font-label-sm text-primary-container tracking-wide font-bold">8 artículos en carrito</span>
</div>
<div class="flex items-baseline gap-1 mt-0.5">
<span class="text-body-sm font-body-sm text-gray-400">Total:</span>
<span class="text-currency-display font-currency-display text-white tracking-tight">S/ 44.70</span>
</div>
</div>
<!-- Primary Action Button -->
<button class="h-12 px-5 bg-primary-container hover:bg-inverse-primary active:scale-95 text-[#111111] font-label-lg font-bold rounded-xl flex items-center justify-center gap-2 shadow-md transition-all" type="button">
<span>Ver Resumen (8)</span>
<span class="material-symbols-outlined text-[20px] font-bold">arrow_forward</span>
</button>
</div>
</aside>
</div>
</body></html>