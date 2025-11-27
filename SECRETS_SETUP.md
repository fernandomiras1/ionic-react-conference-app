# 🔐 Configuración de Secrets para GitHub Actions - iOS Deployment

## 📋 Resumen

Este documento explica cómo configurar los secrets necesarios en GitHub para que el workflow `deploy-ios.yml` funcione correctamente.

## ⚠️ Estado Actual

El workflow ahora tiene **dos modos**:

1. **Modo Build Básico** (sin secrets): Compila la app para simulator sin firma de código
2. **Modo Deployment** (con secrets): Firma y sube a TestFlight

## 🚀 Opción 1: Build Básico (Sin Configuración)

Si **NO** configuras los secrets, el workflow:

- ✅ Construirá la app web
- ✅ Sincronizará Capacitor
- ✅ Instalará CocoaPods
- ✅ Compilará para iOS Simulator (sin firma)
- ❌ NO subirá a TestFlight

**Esto es útil para:** Validar que tu código compila correctamente.

## 🎯 Opción 2: Deployment Completo (Requiere Configuración)

Para poder subir a TestFlight, necesitas configurar los siguientes secrets:

### Paso 1: Crear Repositorio de Certificados

Fastlane Match usa un repositorio Git para almacenar certificados:

```bash
# 1. Crear un repositorio PRIVADO en GitHub
# Nombre sugerido: ios-certificates o certificates

# 2. Inicializar Match localmente
cd ios/App
bundle exec fastlane match init

# 3. Cuando pregunte por la URL, usar:
# https://github.com/TU_USUARIO/ios-certificates

# 4. Generar certificados
bundle exec fastlane match appstore

# 5. Cuando pida password, crear una NUEVA y guardarla
# Esta será tu MATCH_PASSWORD
```

### Paso 2: Configurar Secrets en GitHub

Ve a: **Tu Repo → Settings → Secrets and variables → Actions → New repository secret**

| Secret Name               | Descripción                  | Cómo Obtenerlo                                   |
| ------------------------- | ---------------------------- | ------------------------------------------------ |
| `MATCH_GIT_URL`           | URL del repo de certificados | `https://github.com/TU_USUARIO/ios-certificates` |
| `MATCH_PASSWORD`          | Password de Match            | El que creaste en Paso 1.4                       |
| `FASTLANE_APPLE_ID`       | Tu Apple ID                  | Tu email de Apple Developer                      |
| `FASTLANE_PASSWORD`       | Contraseña Apple ID          | **App-Specific Password** (ver abajo)            |
| `FASTLANE_TEAM_ID`        | Team ID                      | Apple Developer Portal → Membership              |
| `FASTLANE_ITC_TEAM_ID`    | App Store Connect Team       | Usualmente mismo que TEAM_ID                     |
| `FASTLANE_APP_IDENTIFIER` | Bundle ID                    | e.g., `com.fernandomiras.ionicconference`        |

### Paso 3: Crear App-Specific Password

Apple requiere un password específico para CI/CD:

1. Ve a https://appleid.apple.com/
2. Sign in
3. Security → App-Specific Passwords
4. Generate New Password
5. Nombre: "GitHub Actions Fastlane"
6. Copia el password generado
7. Úsalo como `FASTLANE_PASSWORD`

### Paso 4: Configurar App en App Store Connect

1. Ve a https://appstoreconnect.apple.com/
2. My Apps → + → New App
3. Llena la información básica
4. Guarda (no necesitas subir build aún)

## ✅ Verificación

Una vez configurados todos los secrets:

```bash
# Hacer un push o crear un tag
git tag v1.0.0
git push origin v1.0.0
```

El workflow:

1. ✅ Compilará la app
2. ✅ Descargará certificados de Match
3. ✅ Firmará la app
4. ✅ Subirá a TestFlight

## 🔒 Seguridad

### Importante:

- ✅ El repositorio de certificados DEBE ser PRIVADO
- ✅ Nunca commitear `MATCH_PASSWORD` en el código
- ✅ Usar App-Specific Password, no tu contraseña principal
- ✅ Rotar passwords regularmente

### Acceso al Repositorio de Certificados:

GitHub Actions necesita acceso al repo de certificados. Opciones:

**Opción A: Mismo Usuario**

- Si el repo de certs está en tu mismo usuario, funcionará automáticamente

**Opción B: Personal Access Token**
Si el repo está en otra org/usuario:

```bash
# Crear PAT en GitHub
# Settings → Developer settings → Personal access tokens → Tokens (classic)
# Scopes: repo (full control)

# Modificar MATCH_GIT_URL:
https://GITHUB_TOKEN@github.com/USER/certificates
```

## 📊 Troubleshooting

### Error: "repository '' does not exist"

- ❌ `MATCH_GIT_URL` no está configurado o está vacío
- ✅ Verifica en Settings → Secrets que existe y tiene valor

### Error: "Authentication failed"

- ❌ GitHub Actions no puede acceder al repo de certs
- ✅ Verifica que el repo sea accesible
- ✅ Considera usar Personal Access Token

### Error: "Could not find certificate"

- ❌ No has ejecutado `fastlane match appstore` localmente
- ✅ Ejecuta Match local primero para generar certs

## 🎓 Recursos

- [Fastlane Match Docs](https://docs.fastlane.tools/actions/match/)
- [App-Specific Passwords](https://support.apple.com/en-us/HT204397)
- [GitHub Secrets Docs](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

## 💡 Recomendación

Para empezar, es mejor:

1. Primero validar que los workflows básicos funcionen (sin secrets)
2. Luego configurar Match localmente
3. Finalmente agregar secrets para deployment automático

¿Necesitas ayuda con algún paso específico?
