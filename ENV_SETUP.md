# Configuración del Archivo .env

## ⚠️ IMPORTANTE

El archivo `.env` contiene información sensible y **NO** debe ser incluido en el repositorio Git. Por seguridad, este archivo está bloqueado por el `.gitignore`.

## Configuración Inicial

1. **Crea el archivo `.env` en la raíz del proyecto:**

```bash
# En la raíz del proyecto (mismo nivel que pubspec.yaml)
# Crea el archivo .env
touch .env
```

2. **Agrega el siguiente contenido al archivo `.env`:**

```env
# Backend API URL
# IMPORTANTE: Cambia esta URL por la dirección de tu backend EventMaster
# Ejemplos:
#   - Local: http://localhost:3000
#   - IP local (para probar en dispositivo físico): http://192.168.1.100:3000
#   - Producción: https://api.eventmaster.com
API_URL=http://localhost:3000

# Google Maps API Key (opcional)
# Obtén tu clave en: https://console.cloud.google.com/
# Necesitas habilitar: Maps SDK for Android, Maps SDK for iOS
GOOGLE_MAPS_API_KEY=
```

## Variables de Entorno

### `API_URL` (Requerida)

- **Descripción:** URL base del backend EventMaster Express
- **Formato:** `http://host:puerto` o `https://dominio.com`
- **Importante:** NO incluir `/` al final
- **Ejemplos válidos:**
  - `http://localhost:3000`
  - `http://192.168.1.10:3000`
  - `https://eventmaster-api.herokuapp.com`

### `GOOGLE_MAPS_API_KEY` (Opcional)

- **Descripción:** Clave API de Google Maps para mostrar ubicaciones de eventos
- **Obtener clave:** https://console.cloud.google.com/
- **APIs necesarias:**
  - Maps SDK for Android
  - Maps SDK for iOS
- **Formato:** String alfanumérico largo

## Verificación

Para verificar que el archivo `.env` está configurado correctamente:

1. El archivo debe existir en: `Proyecto-Progra-Movil-main/.env`
2. El archivo debe contener al menos la variable `API_URL`
3. La URL debe ser accesible desde tu dispositivo/emulador

## Troubleshooting

### Error: "ENV no cargado"

- Verifica que el archivo `.env` existe en la raíz del proyecto
- Verifica que el archivo está listado en `pubspec.yaml` bajo `assets:`

### Error de conexión al backend

- Verifica que la `API_URL` es correcta
- Si usas un emulador Android, usa `http://10.0.2.2:3000` para conectar a localhost del host
- Si usas un dispositivo físico, usa la IP local de tu computadora (ej: `http://192.168.1.100:3000`)
- Verifica que el backend está corriendo

### El backend está en localhost pero no conecta

**Android Emulator:**
- Usa `http://10.0.2.2:3000` en lugar de `http://localhost:3000`

**iOS Simulator:**
- Usa `http://localhost:3000` (funciona directamente)

**Dispositivo físico:**
- Tu dispositivo y tu computadora deben estar en la misma red Wi-Fi
- Usa la IP local de tu computadora (Windows: `ipconfig`, Mac/Linux: `ifconfig`)
- Asegúrate de que el firewall permita conexiones entrantes al puerto del backend

## Seguridad

🔒 **NUNCA** compartas tu archivo `.env` ni lo subas a Git
🔒 El archivo `.env` está protegido por `.gitignore`
🔒 Si necesitas compartir configuración, usa `.env.example` sin valores reales
