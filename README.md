# Despensa

Aplicación móvil para gestionar el inventario del hogar, controlar cantidades y
fechas de caducidad, y crear cestas de la compra compartidas.

## Estado

Proyecto académico en desarrollo. El producto mínimo viable se construye de
forma incremental mediante sprints de cuatro días.

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
