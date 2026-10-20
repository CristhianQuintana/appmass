<!DOCTYPE html>

<html class="h-full bg-background" lang="es"><head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>MASS Operaciones - Inicio de Sesión</title>
<!-- Google Fonts: Montserrat & Inter -->
<link href="https://fonts.googleapis.com" rel="preconnect"/>
<link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;family=Montserrat:wght@700;800;900&amp;display=swap" rel="stylesheet"/>
<!-- Material Symbols Outlined -->
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<!-- Tailwind CSS v3 -->
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<script id="tailwind-config">
    tailwind.config = {
      darkMode: "class",
      theme: {
        extend: {
          "colors": {
            "on-surface": "#151c27",
            "surface-container-high": "#e2e8f8",
            "on-primary": "#ffffff",
            "on-primary-container": "#6f5700",
            "on-tertiary": "#ffffff",
            "primary": "#745b00",
            "surface-dim": "#d3daea",
            "on-secondary-container": "#fffbff",
            "on-tertiary-fixed-variant": "#474746",
            "secondary-fixed": "#ffdad5",
            "inverse-primary": "#f1c100",
            "background": "#f9f9ff",
            "on-secondary-fixed-variant": "#930007",
            "primary-container": "#ffcc00",
            "surface-container-lowest": "#ffffff",
            "error-container": "#ffdad6",
            "tertiary": "#5f5e5e",
            "on-tertiary-fixed": "#1c1b1b",
            "on-secondary": "#ffffff",
            "primary-fixed-dim": "#f1c100",
            "tertiary-container": "#d4d1d1",
            "inverse-surface": "#2a313d",
            "secondary-container": "#e02923",
            "secondary": "#bb010c",
            "on-background": "#151c27",
            "tertiary-fixed": "#e5e2e1",
            "surface-bright": "#f9f9ff",
            "on-error": "#ffffff",
            "on-secondary-fixed": "#410001",
            "secondary-fixed-dim": "#ffb4aa",
            "surface": "#f9f9ff",
            "outline-variant": "#d2c5ab",
            "on-surface-variant": "#4e4632",
            "error": "#ba1a1a",
            "primary-fixed": "#ffe08b",
            "on-error-container": "#93000a",
            "surface-container": "#e7eefe",
            "surface-container-low": "#f0f3ff",
            "surface-container-highest": "#dce2f3",
            "on-tertiary-container": "#5a5a59",
            "on-primary-fixed-variant": "#584400",
            "tertiary-fixed-dim": "#c8c6c5",
            "surface-tint": "#745b00",
            "surface-variant": "#dce2f3",
            "inverse-on-surface": "#ebf1ff",
            "outline": "#80765f",
            "on-primary-fixed": "#241a00"
          },
          "borderRadius": {
            "DEFAULT": "0.25rem",
            "lg": "0.5rem",
            "xl": "0.75rem",
            "full": "9999px"
          },
          "spacing": {
            "space-xs": "0.25rem",
            "gutter": "1rem",
            "space-md": "1rem",
            "space-xl": "2rem",
            "margin": "1rem",
            "space-sm": "0.5rem",
            "space-lg": "1.5rem"
          },
          "fontFamily": {
            "headline-lg": ["Montserrat"],
            "body-lg": ["Inter"],
            "label-md": ["Inter"],
            "headline-md": ["Montserrat"],
            "body-md": ["Inter"],
            "display-lg": ["Montserrat"],
            "headline-sm": ["Montserrat"],
            "order-code": ["Inter"],
            "currency-display": ["Montserrat"],
            "label-sm": ["Inter"],
            "label-lg": ["Inter"],
            "body-sm": ["Inter"]
          },
          "fontSize": {
            "headline-lg": ["24px", { "lineHeight": "32px", "fontWeight": "700" }],
            "body-lg": ["16px", { "lineHeight": "24px", "fontWeight": "400" }],
            "label-md": ["12px", { "lineHeight": "16px", "fontWeight": "600" }],
            "headline-md": ["20px", { "lineHeight": "28px", "fontWeight": "700" }],
            "body-md": ["14px", { "lineHeight": "20px", "fontWeight": "400" }],
            "display-lg": ["32px", { "lineHeight": "40px", "fontWeight": "800" }],
            "headline-sm": ["16px", { "lineHeight": "24px", "fontWeight": "700" }],
            "order-code": ["15px", { "lineHeight": "20px", "fontWeight": "700" }],
            "currency-display": ["28px", { "lineHeight": "32px", "fontWeight": "800" }],
            "label-sm": ["11px", { "lineHeight": "14px", "fontWeight": "700" }],
            "label-lg": ["14px", { "lineHeight": "20px", "fontWeight": "600" }],
            "body-sm": ["12px", { "lineHeight": "16px", "fontWeight": "400" }]
          }
        }
      }
    }
  </script>
<style>
    .material-symbols-outlined {
      font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
      display: inline-block;
      vertical-align: middle;
      line-height: 1;
    }
  </style>
</head>
<body class="bg-background text-on-surface min-h-full flex flex-col justify-between antialiased selection:bg-primary-container selection:text-on-surface">
<!-- Mobile Android Status Bar Simulation -->
<header class="w-full bg-surface-container-lowest px-margin pt-2.5 pb-2 flex justify-between items-center text-on-surface-variant select-none shadow-sm">
<div class="flex items-center space-x-1">
<span class="font-label-md text-label-md tracking-tight font-semibold text-on-surface">08:42</span>
<span class="font-label-sm text-label-sm text-on-surface-variant">AM</span>
</div>
<div class="flex items-center space-x-2">
<span class="material-symbols-outlined text-[16px]">signal_cellular_4_bar</span>
<span class="material-symbols-outlined text-[16px]">wifi</span>
<span class="material-symbols-outlined text-[18px]">battery_charging_full</span>
</div>
</header>
<!-- Main Canvas Container (Centered single-column layout optimized for mobile field operations) -->
<main class="w-full max-w-md mx-auto px-margin py-6 flex-1 flex flex-col justify-center">
<!-- Top Identity: MASS Logo & MVP Badge -->
<section class="flex flex-col items-center mb-6">
<div class="relative flex items-center justify-center p-2 rounded-xl bg-surface-container-lowest border border-outline-variant/40 shadow-sm mb-3">
<img alt="Logotipo Tiendas MASS" class="h-12 w-auto object-contain" src="https://lh3.googleusercontent.com/aida/AEtjO1VI_R7UmRGQoXHZ0kybsUX-igXRHZB4dKoNdwkFitAJd4h2308jEmws_wY6MHPM_o1ONZAPsKFeebBQTKLCM25XznEApwLY4kVlKlRXahwnjpO9ZIutfqf3g15qcIMmEo2K_wOppj5fRzobgW_RdzqdW7CsYR14PzrHLXtV0rf5ZWgFtVwKl5z1BwhRh2zbnVN2pCEGHs8CmmoQgDlshtax7KVjH8Srct868W4BqG3GdVRFaB6aTziBncw"/>
</div>
<div class="inline-flex items-center space-x-1.5 px-3 py-1 rounded-full bg-secondary-container text-on-secondary-container shadow-xs">
<span class="w-2 h-2 rounded-full bg-surface-container-lowest animate-pulse"></span>
<span class="font-label-sm text-label-sm tracking-wider uppercase">MVP OPERATIVO</span>
</div>
</section>
<!-- Header Titles -->
<header class="text-center mb-6">
<h1 class="font-headline-lg text-headline-lg text-on-surface tracking-tight mb-1">
        Inicia sesión
      </h1>
<p class="font-body-md text-body-md text-on-surface-variant max-w-xs mx-auto">
        Accede a tu cuenta para continuar con las operaciones de tienda
      </p>
</header>
<!-- Role Quick Selector / Demo Toggle Tab Bar -->
<section aria-label="Selector de Perfil" class="mb-6">
<div class="flex items-center justify-between mb-2">
<span class="font-label-sm text-label-sm text-on-surface-variant tracking-wide">PERFIL DE ACCESO:</span>
<span class="font-label-sm text-label-sm text-secondary font-bold" id="roleSelectedIndicator">Operador de Tienda</span>
</div>
<div class="grid grid-cols-3 gap-1.5 p-1 bg-surface-container-highest rounded-xl border border-outline-variant/30">
<button class="role-btn py-2 px-1 rounded-lg font-label-md text-label-md flex flex-col items-center justify-center bg-primary-container text-on-surface font-bold shadow-sm transition-transform active:scale-95" id="btn-operador" onclick="selectRole('operador')" type="button">
<span class="material-symbols-outlined text-[20px] mb-0.5">inventory_2</span>
<span>Operador</span>
</button>
<button class="role-btn py-2 px-1 rounded-lg font-label-md text-label-md flex flex-col items-center justify-center text-on-surface-variant hover:text-on-surface font-medium transition-transform active:scale-95" id="btn-transportista" onclick="selectRole('transportista')" type="button">
<span class="material-symbols-outlined text-[20px] mb-0.5">local_shipping</span>
<span>Transportista</span>
</button>
<button class="role-btn py-2 px-1 rounded-lg font-label-md text-label-md flex flex-col items-center justify-center text-on-surface-variant hover:text-on-surface font-medium transition-transform active:scale-95" id="btn-administrador" onclick="selectRole('administrador')" type="button">
<span class="material-symbols-outlined text-[20px] mb-0.5">admin_panel_settings</span>
<span>Supervisor</span>
</button>
</div>
</section>
<!-- Authentication Form Card -->
<div class="bg-surface-container-lowest border border-outline-variant/50 rounded-xl p-space-lg shadow-sm">
<form class="space-y-4" id="loginForm" onsubmit="event.preventDefault(); simulateLogin();">
<!-- Corporate Email Field -->
<div>
<label class="block font-label-lg text-label-lg text-on-surface mb-1.5 font-semibold" for="corporate-email">
            Correo electrónico corporativo
          </label>
<div class="relative rounded-lg shadow-none">
<div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-on-surface-variant">
<span class="material-symbols-outlined text-[20px]">mail</span>
</div>
<input class="w-full pl-10 pr-4 py-3 bg-surface border-1.5 border-outline-variant/60 rounded-lg font-body-md text-body-md text-on-surface focus:outline-none focus:ring-2 focus:ring-primary-container focus:border-on-surface placeholder:text-tertiary transition-colors" id="corporate-email" name="email" placeholder="ejemplo@mass.pe" required="" type="email" value="operador.lurin04@mass.pe"/>
</div>
</div>
<!-- Password Field with Show/Hide Toggle -->
<div>
<div class="flex items-center justify-between mb-1.5">
<label class="font-label-lg text-label-lg text-on-surface font-semibold" for="corporate-password">
              Contraseña
            </label>
<span class="font-label-sm text-label-sm text-on-surface-variant">Mín. 8 caracteres</span>
</div>
<div class="relative rounded-lg">
<div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-on-surface-variant">
<span class="material-symbols-outlined text-[20px]">lock</span>
</div>
<input class="w-full pl-10 pr-12 py-3 bg-surface border-1.5 border-outline-variant/60 rounded-lg font-body-md text-body-md text-on-surface focus:outline-none focus:ring-2 focus:ring-primary-container focus:border-on-surface placeholder:text-tertiary transition-colors" id="corporate-password" name="password" required="" type="password" value="MassRetail2024!"/>
<button aria-label="Mostrar u ocultar contraseña" class="absolute inset-y-0 right-0 pr-3.5 flex items-center text-on-surface-variant hover:text-on-surface active:scale-95 transition-transform" id="togglePasswordBtn" onclick="togglePasswordVisibility()" type="button">
<span class="material-symbols-outlined text-[22px]" id="passwordIcon">visibility</span>
</button>
</div>
</div>
<!-- Help Link -->
<div class="flex justify-end pt-0.5">
<a class="font-label-md text-label-md text-secondary hover:text-on-secondary-fixed-variant font-semibold tracking-tight active:underline" href="#">
            ¿Olvidaste tu contraseña?
          </a>
</div>
<!-- Submit Button in MASS Yellow Style -->
<div class="pt-2">
<button class="w-full h-12 bg-primary-container hover:bg-primary-fixed-dim text-on-surface font-headline-sm text-headline-sm font-bold rounded-lg shadow-sm active:scale-[0.98] transition-transform duration-150 flex items-center justify-center space-x-2" id="loginSubmitBtn" type="submit">
<span>Iniciar sesión</span>
<span class="material-symbols-outlined text-[20px]">arrow_forward</span>
</button>
</div>
</form>
</div>
<!-- Security Information Notice Card -->
<section class="mt-5 p-3.5 bg-surface-container-low border border-outline-variant/40 rounded-xl flex items-start space-x-3">
<div class="p-1 rounded-lg bg-surface-container-high text-secondary flex-shrink-0 mt-0.5">
<span class="material-symbols-outlined text-[20px]">verified_user</span>
</div>
<div>
<h4 class="font-label-md text-label-md font-bold text-on-surface">Red Corporativa Protegida</h4>
<p class="font-body-sm text-body-sm text-on-surface-variant leading-relaxed mt-0.5">
          Este sistema es para uso exclusivo de colaboradores autorizados de Tiendas MASS. Todo acceso queda registrado en la bitácora de auditoría.
        </p>
</div>
</section>
</main>
<!-- Clean Android Mobile Footer / Version Info -->
<footer class="w-full py-3.5 text-center bg-surface-container-lowest border-t border-outline-variant/30">
<div class="flex items-center justify-center space-x-2 text-on-surface-variant">
<span class="w-2 h-2 rounded-full bg-emerald-600"></span>
<span class="font-label-sm text-label-sm tracking-wide">Servidores Lima Centro: Operativos</span>
</div>
<div class="font-label-sm text-label-sm text-tertiary mt-0.5">
      MASS Operaciones Mobile • Versión 2.4.1 (Build 1084)
    </div>
</footer>
<script>
    function togglePasswordVisibility() {
      const passwordInput = document.getElementById('corporate-password');
      const passwordIcon = document.getElementById('passwordIcon');
      if (passwordInput.type === 'password') {
        passwordInput.type = 'text';
        passwordIcon.textContent = 'visibility_off';
      } else {
        passwordInput.type = 'password';
        passwordIcon.textContent = 'visibility';
      }
    }

    function selectRole(role) {
      const roles = ['operador', 'transportista', 'administrador'];
      const emailInput = document.getElementById('corporate-email');
      const indicator = document.getElementById('roleSelectedIndicator');

      roles.forEach(r => {
        const btn = document.getElementById('btn-' + r);
        if (r === role) {
          btn.className = "role-btn py-2 px-1 rounded-lg font-label-md text-label-md flex flex-col items-center justify-center bg-primary-container text-on-surface font-bold shadow-sm transition-transform active:scale-95";
        } else {
          btn.className = "role-btn py-2 px-1 rounded-lg font-label-md text-label-md flex flex-col items-center justify-center text-on-surface-variant hover:text-on-surface font-medium transition-transform active:scale-95";
        }
      });

      if (role === 'operador') {
        emailInput.value = 'operador.lurin04@mass.pe';
        indicator.textContent = 'Operador de Tienda';
      } else if (role === 'transportista') {
        emailInput.value = 'flota.sur12@mass.pe';
        indicator.textContent = 'Despacho & Rutas';
      } else if (role === 'administrador') {
        emailInput.value = 'supervisor.distrito@mass.pe';
        indicator.textContent = 'Supervisor General';
      }
    }

    function simulateLogin() {
      const btn = document.getElementById('loginSubmitBtn');
      btn.innerHTML = `<span class="material-symbols-outlined animate-spin text-[20px]">sync</span><span>Accediendo...</span>`;
      btn.disabled = true;
      setTimeout(() => {
        btn.innerHTML = `<span class="material-symbols-outlined text-[20px]">check_circle</span><span>¡Acceso Concedido!</span>`;
        btn.classList.remove('bg-primary-container');
        btn.classList.add('bg-emerald-500', 'text-white');
      }, 1000);
    }
  </script>
</body></html>