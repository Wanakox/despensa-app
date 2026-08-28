# Despensa

Aplicación móvil para gestionar el inventario del hogar, controlar cantidades y
fechas de caducidad, y crear cestas de la compra compartidas.

## Estado

Producto mínimo viable completado en cuatro sprints. La versión 1.0 incluye la
aplicación Android, memoria final, presentación y evidencias de prueba.

## Calidad y entrega

- `flutter analyze`: sin incidencias.
- `flutter test`: 25 pruebas superadas.
- APK release verificado mediante SHA-256.
- Memoria y presentación disponibles en `docs/entrega/`.

Para reproducir la comprobación final:

```bash
flutter analyze
flutter test
flutter build apk --release
sha256sum build/app/outputs/flutter-apk/app-release.apk
```

## Tecnologías

- Flutter y Dart.
- Android como plataforma inicial.
- Firebase Authentication para el acceso de usuarios.
- Cloud Firestore para persistencia y sincronización.

## Puesta en marcha

Requisitos:

- Flutter estable.
- Android Studio o Android SDK.
- JDK 17 o posterior compatible.

```bash
flutter pub get
flutter run
```

### Configuración de Firebase

La aplicación usa el identificador Android `com.wanakox.despensa`. Para conectar
un proyecto Firebase es necesario iniciar sesión con una cuenta autorizada y ejecutar:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --platforms=android
```

Este proceso debe generar `lib/firebase_options.dart` y registrar la aplicación
Android. Después se habilitan en Firebase Console el acceso por correo y contraseña
y Cloud Firestore. Los archivos generados deben revisarse antes de publicarlos.

Las reglas e índices se despliegan con:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

### Emuladores de Firebase

El repositorio incluye puertos para Authentication, Firestore y la interfaz de
Firebase Emulator Suite. Para probar las reglas sin modificar datos reales:

```bash
firebase emulators:start --only auth,firestore
```

La aplicación mantiene un modo local cuando Firebase no está configurado. En una
sesión autenticada, inventario, cesta, miembros y métricas del inicio se sincronizan
en tiempo real con el hogar seleccionado.

### Modelo colaborativo

- Los propietarios pueden invitar por correo, renombrar o eliminar el hogar,
  gestionar miembros y transferir la propiedad.
- Los usuarios invitados ven la invitación en «Mis hogares» y pueden aceptarla o
  rechazarla.
- Los miembros pueden abandonar un hogar y editar inventario y cesta compartidos.
- El paso de productos comprados a la despensa se guarda como una operación atómica.
- El perfil se abre desde «Mis hogares» y permite cambiar nombre y contraseña o
  eliminar la cuenta; el correo no se modifica.
- El inicio muestra la actividad compartida ordenada por la hora del servidor.
- El inventario ofrece filtros A–Z, agotados y caducados, además de edición rápida
  de unidades. La cesta se puede vaciar completa con confirmación.

## Arquitectura

El código de `lib/` se organiza por responsabilidad:

- `app/`: aplicación, tema y configuración visual.
- `core/`: componentes reutilizables y servicios compartidos.
- `features/`: funcionalidades independientes como autenticación, inicio,
  inventario, cesta, miembros y perfil.

La interfaz utiliza Material 3 y la identidad visual del prototipo: fondo marfil,
verde salvia como color principal y terracota como acento.

## Organización

El trabajo se gestiona mediante milestones e issues en GitHub. Los documentos de
análisis, requisitos, casos de uso y diseño se incorporarán progresivamente al
repositorio para mantener la trazabilidad con la memoria final.
