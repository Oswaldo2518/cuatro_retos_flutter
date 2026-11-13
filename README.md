# Cuatro Retos · Flutter + APIs

Aplicación educativa en español que integra los cuatro ejercicios del PDF **Los Cuatro Retor.pdf** en un mismo proyecto. Diseño Material 3 oscuro y navegación adaptable a teléfono y escritorio.

## Módulos

1. **Películas (TMDB):** listado de tendencias, géneros seleccionados y elección aleatoria. Requiere clave API gratuita de TMDB v3.
2. **Memes de gatos (Cataas):** imágenes aleatorias, texto personalizado y filtros (normal, blanco y negro, desenfoque e invertido).
3. **Clima (Open-Meteo):** búsqueda de ciudad, temperatura, sensación térmica, humedad y viento. No solicita GPS ni clave API. El PDF sugería OpenWeatherMap o WeatherAPI; aquí se usa Open-Meteo como alternativa sin clave para facilitar las pruebas.
4. **Criptomonedas (CoinGecko):** Bitcoin, Ethereum y Solana; precios USD, cambio de 24 h y cálculo de unidades a partir de un monto escrito. Una clave demo mejora la confiabilidad del acceso; el acceso público sin clave puede estar limitado.

## Requisitos

- Flutter SDK instalado y disponible desde una terminal (comando `flutter`).
- Visual Studio Code con extensiones Flutter y Dart (o Android Studio).
- Un emulador Android / teléfono con depuración USB / navegador compatible.
- Conexión a Internet.

> Este ZIP trae el código Flutter, la configuración y las pruebas. Los archivos nativos que genera `flutter create` (`android/`, `web/`, etc.) se generan **una sola vez** durante la preparación para evitar incluir cientos de archivos del SDK en el ZIP.

## Preparación rápida en Windows 11

1. Descomprime el ZIP.
2. Abre la carpeta `cuatro_retos_flutter` en VS Code.
3. Abre la terminal de PowerShell y ejecuta:

```powershell
.\preparar_windows.ps1
flutter devices
flutter run
```

El script crea las plataformas Android, Windows y web; agrega permiso de Internet a Android; y ejecuta `flutter pub get`. Si el sistema restringe la ejecución de scripts, usa la preparación manual de abajo (sin modificar las políticas de seguridad).

## Preparación manual (Windows, macOS o Linux)

Desde la carpeta raíz:

```bash
flutter create . --project-name cuatro_retos_flutter --platforms android,web
flutter pub get
flutter devices
flutter run
```

**Android:** abre `android/app/src/main/AndroidManifest.xml` después de `flutter create .` y agrega la siguiente línea como hija directa de `<manifest ...>` antes de `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

Para agregar también plataforma de escritorio en Windows, usa `--platforms android,web,windows` al crear el proyecto; para ejecutar en Windows se requiere la cadena de compilación de Visual Studio para escritorio.

## Claves de API

**TMDB:** crea una cuenta en https://www.themoviedb.org/ y obtiene una API Key v3 desde la configuración API de la cuenta. Pégala en el campo **Configuración de TMDB** de la pantalla de películas y toca **Cargar películas**. El campo no la guarda de forma permanente.

**CoinGecko:** puedes probar sin clave; ante bloqueos o límite de acceso, crea una API key Demo en https://www.coingecko.com/en/api y pégala en el campo de la sección cripto.

Opcionalmente puedes iniciar la app con claves de desarrollo mediante:

```bash
flutter run --dart-define=TMDB_API_KEY=TU_API_KEY --dart-define=COINGECKO_API_KEY=TU_CLAVE_DEMO
```

**Nota de seguridad:** en una app distribuida públicamente, las claves embebidas en Flutter pueden ser extraídas por terceros; para producción, usa un backend seguro o limitaciones de clave proporcionadas por el servicio. Este proyecto es una práctica académica.

## Probar en web

```bash
flutter run -d chrome
```

Algunas APIs de imágenes, especialmente Cataas, pueden tener restricciones de CORS en el navegador. Para validar todas las funciones se recomienda ejecutar la app en **Android**.

## Pruebas

```bash
flutter test
```

Incluye pruebas básicas de parseo de películas, cálculo de conversión y construcción segura de la URL del meme.

## Organización

```
lib/
  main.dart                      # Tema, navegación, estructura de la aplicación
  models/app_models.dart         # Modelos de datos
  services/api_service.dart      # Peticiones HTTP y parseo JSON
  widgets/ui.dart                # Componentes visuales compartidos
  screens/movies_screen.dart     # Pantalla 1: películas
  screens/cats_screen.dart       # Pantalla 2: memes
  screens/weather_screen.dart    # Pantalla 3: clima
  screens/crypto_screen.dart     # Pantalla 4: criptomonedas

test/models_test.dart            # Pruebas unitarias
pubspec.yaml                     # Dependencias
preparar_windows.ps1             # Configuración para Windows
```

## Referencias de API

- TMDB: https://developer.themoviedb.org/docs/authentication-application
- Cataas: https://cataas.com/doc.html
- Open-Meteo (clima): https://open-meteo.com/en/docs
- Open-Meteo (geocodificación): https://open-meteo.com/en/docs/geocoding-api
- CoinGecko: https://docs.coingecko.com/reference/simple-price

Proyecto con fines educativos. El convertidor de criptomonedas no permite comprar activos y no representa asesoría financiera.
