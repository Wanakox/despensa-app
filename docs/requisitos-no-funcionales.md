# Especificación de requisitos no funcionales

## 1. Propósito

Este documento define las condiciones de calidad y las restricciones técnicas que
deberá cumplir el MVP de Despensa. Los requisitos no funcionales complementan las
funciones del sistema y establecen criterios medibles para el diseño, la
implementación y las pruebas.

## 2. Convenciones

Los requisitos utilizan el identificador `RNF-XX`. Cada uno incluye una descripción,
su prioridad MoSCoW y un criterio de verificación.

- **Must:** condición imprescindible para aceptar el MVP.
- **Should:** condición importante que debe alcanzarse salvo impedimento justificado.
- **Could:** mejora deseable si el calendario lo permite.

Los valores cuantitativos son objetivos iniciales para un proyecto académico. Se
revisarán mediante pruebas y se documentará cualquier desviación.

## 3. Usabilidad

### RNF-01. Claridad de los flujos principales

- **Descripción:** un usuario con experiencia básica en aplicaciones móviles deberá
  poder añadir un producto, enviarlo a la cesta y marcarlo como comprado sin recibir
  formación previa.
- **Prioridad:** Must.
- **Verificación:** una prueba con usuarios deberá completar cada flujo principal sin
  ayuda externa y sin errores bloqueantes.

### RNF-02. Número de acciones

- **Descripción:** las operaciones frecuentes deberán requerir el menor número
  razonable de acciones.
- **Prioridad:** Should.
- **Verificación:** ajustar la cantidad o marcar un elemento como comprado requerirá
  como máximo dos acciones desde su listado; añadir un producto requerirá como máximo
  una navegación y la cumplimentación del formulario.

### RNF-03. Retroalimentación de operaciones

- **Descripción:** la aplicación deberá informar del resultado de las operaciones que
  modifican datos.
- **Prioridad:** Must.
- **Verificación:** altas, modificaciones, eliminaciones y errores de red muestran un
  estado, confirmación o mensaje comprensible y no ambiguo.

### RNF-04. Consistencia visual

- **Descripción:** las pantallas deberán utilizar de manera consistente componentes,
  colores, iconos, espaciados y términos.
- **Prioridad:** Should.
- **Verificación:** la revisión de interfaces no detecta acciones equivalentes con
  nombres o representaciones contradictorias.

## 4. Accesibilidad

### RNF-05. Contraste

- **Descripción:** el texto y los controles esenciales deberán mantener contraste
  suficiente respecto a su fondo.
- **Prioridad:** Must.
- **Verificación:** los elementos principales alcanzan al menos la relación 4,5:1
  para texto normal y 3:1 para texto grande o componentes gráficos relevantes.

### RNF-06. Tamaño de objetivos táctiles

- **Descripción:** los controles interactivos deberán tener un área táctil adecuada.
- **Prioridad:** Must.
- **Verificación:** los objetivos táctiles esenciales alcanzan al menos 48 por 48
  píxeles lógicos o disponen de separación equivalente.

### RNF-07. Escalado de texto

- **Descripción:** la interfaz deberá admitir el aumento de texto configurado en
  Android sin ocultar acciones esenciales.
- **Prioridad:** Should.
- **Verificación:** con una escala de texto del 200 %, los flujos principales siguen
  siendo utilizables sin solapamientos ni texto crítico recortado.

### RNF-08. Información no dependiente solo del color

- **Descripción:** los estados de agotado, próximo a caducar, caducado y comprado no
  deberán comunicarse únicamente mediante color.
- **Prioridad:** Must.
- **Verificación:** cada estado dispone también de texto, icono o patrón visual
  identificable.

### RNF-09. Semántica para tecnologías de asistencia

- **Descripción:** los controles e información principal deberán proporcionar
  etiquetas semánticas comprensibles.
- **Prioridad:** Should.
- **Verificación:** TalkBack puede anunciar los controles principales, su función y
  el estado relevante del producto.

## 5. Rendimiento

### RNF-10. Tiempo de arranque

- **Descripción:** la aplicación deberá mostrar una interfaz utilizable en un tiempo
  razonable desde un arranque en frío.
- **Prioridad:** Should.
- **Verificación:** en el dispositivo de prueba, la pantalla inicial aparece en menos
  de tres segundos bajo condiciones normales.

### RNF-11. Respuesta de operaciones locales

- **Descripción:** las interacciones que no dependan de la red deberán proporcionar
  respuesta visual inmediata.
- **Prioridad:** Must.
- **Verificación:** pulsaciones, navegación y validaciones locales responden en menos
  de 300 milisegundos en el dispositivo de prueba.

### RNF-12. Consulta de listados

- **Descripción:** el inventario y la cesta deberán cargarse con un tiempo aceptable
  para el volumen previsto en un hogar.
- **Prioridad:** Must.
- **Verificación:** con hasta 500 productos y una conexión estable, el contenido
  almacenado aparece o actualiza en menos de dos segundos después de obtener respuesta
  del servicio.

### RNF-13. Propagación de cambios

- **Descripción:** los cambios confirmados deberán aparecer rápidamente en los demás
  dispositivos conectados.
- **Prioridad:** Must.
- **Verificación:** en condiciones normales, el 95 % de los cambios de prueba se
  refleja en otro dispositivo en menos de cinco segundos.

## 6. Disponibilidad y recuperación

### RNF-14. Conservación ante pérdida de conectividad

- **Descripción:** una pérdida temporal de conexión no deberá cerrar la sesión ni
  provocar la desaparición inmediata de los datos ya consultados.
- **Prioridad:** Should.
- **Verificación:** al desconectar la red, la aplicación mantiene el último contenido
  disponible e informa de que puede estar desactualizado.

### RNF-15. Operaciones no confirmadas

- **Descripción:** una operación que no se haya persistido correctamente no deberá
  mostrarse de forma definitiva como completada.
- **Prioridad:** Must.
- **Verificación:** al simular un error de escritura, la aplicación informa del fallo
  y permite reintentar o recuperar un estado coherente.

### RNF-16. Integridad ante concurrencia

- **Descripción:** las actualizaciones simultáneas no deberán generar cantidades
  negativas, elementos corruptos ni acceso cruzado entre hogares.
- **Prioridad:** Must.
- **Verificación:** las pruebas concurrentes mantienen las restricciones de datos y
  producen un resultado definido, aunque una actualización posterior sustituya a otra.

## 7. Seguridad y privacidad

### RNF-17. Autenticación gestionada

- **Descripción:** las credenciales deberán gestionarse mediante Firebase
  Authentication y no almacenarse directamente en la base de datos de la aplicación.
- **Prioridad:** Must.
- **Verificación:** Firestore no contiene contraseñas ni equivalentes reversibles y
  el acceso utiliza credenciales emitidas por el proveedor de autenticación.

### RNF-18. Autorización en el servidor

- **Descripción:** el aislamiento entre hogares deberá aplicarse mediante reglas de
  seguridad del servicio, no únicamente ocultando datos en la interfaz.
- **Prioridad:** Must.
- **Verificación:** las pruebas contra Firestore rechazan lecturas y escrituras de un
  usuario autenticado que no pertenezca al hogar solicitado.

### RNF-19. Principio de mínimo privilegio

- **Descripción:** cada rol deberá disponer solo de las operaciones necesarias.
- **Prioridad:** Must.
- **Verificación:** un miembro no puede ejecutar acciones reservadas al propietario,
  como expulsar a otros miembros.

### RNF-20. Datos mínimos

- **Descripción:** el MVP almacenará únicamente los datos personales necesarios para
  identificar la cuenta y gestionar la pertenencia a hogares.
- **Prioridad:** Must.
- **Verificación:** el modelo de datos no solicita dirección postal, teléfono, datos
  bancarios ni otra información ajena al propósito declarado.

### RNF-21. Comunicaciones cifradas

- **Descripción:** las comunicaciones con los servicios remotos deberán utilizar
  conexiones cifradas proporcionadas por los SDK oficiales.
- **Prioridad:** Must.
- **Verificación:** la aplicación no define endpoints HTTP sin cifrar ni desactiva la
  validación de certificados.

### RNF-22. Protección de secretos

- **Descripción:** no se publicarán contraseñas, claves privadas, tokens de servicio
  ni archivos con privilegios administrativos en el repositorio.
- **Prioridad:** Must.
- **Verificación:** la revisión del historial y de los archivos versionados no detecta
  secretos; las credenciales administrativas se mantienen fuera del cliente.

## 8. Compatibilidad

### RNF-23. Plataforma inicial

- **Descripción:** el MVP deberá ejecutarse en Android.
- **Prioridad:** Must.
- **Verificación:** se genera un APK instalable y los flujos principales se completan
  en al menos un dispositivo Android físico o emulado.

### RNF-24. Versiones de Android

- **Descripción:** la aplicación deberá ser compatible con una versión mínima de
  Android que cubra dispositivos recientes sin incrementar innecesariamente el coste
  de mantenimiento.
- **Prioridad:** Must.
- **Verificación:** se fija y documenta el nivel mínimo definitivo antes de la primera
  compilación de entrega, y se prueba al menos en el nivel mínimo y en uno reciente.

### RNF-25. Tamaños de pantalla

- **Descripción:** las pantallas deberán adaptarse a tamaños habituales de teléfonos
  Android en orientación vertical.
- **Prioridad:** Must.
- **Verificación:** no existen desbordamientos en anchos lógicos de 320, 360 y 412
  píxeles durante los flujos principales.

### RNF-26. Orientación

- **Descripción:** el MVP podrá priorizar la orientación vertical y no dependerá de la
  orientación horizontal para completar ninguna operación.
- **Prioridad:** Should.
- **Verificación:** todas las funciones principales son accesibles en vertical.

## 9. Mantenibilidad y calidad del código

### RNF-27. Separación de responsabilidades

- **Descripción:** la interfaz, la lógica de negocio y el acceso a Firebase deberán
  mantenerse desacoplados mediante una estructura modular.
- **Prioridad:** Must.
- **Verificación:** los widgets de presentación no realizan directamente todas las
  consultas ni contienen reglas complejas de inventario.

### RNF-28. Análisis estático

- **Descripción:** el código deberá cumplir las reglas de análisis configuradas en el
  proyecto.
- **Prioridad:** Must.
- **Verificación:** `flutter analyze` finaliza sin errores ni advertencias pendientes.

### RNF-29. Pruebas automatizadas

- **Descripción:** la lógica de negocio crítica deberá disponer de pruebas
  automatizadas.
- **Prioridad:** Must.
- **Verificación:** existen pruebas para cantidades, caducidades, duplicados,
  transición cesta-inventario y permisos simulables, y `flutter test` finaliza
  correctamente.

### RNF-30. Convenciones y documentación

- **Descripción:** los nombres, módulos y decisiones no evidentes deberán seguir
  convenciones consistentes y quedar documentados.
- **Prioridad:** Should.
- **Verificación:** el repositorio permite identificar cómo ejecutar el proyecto, su
  estructura y las decisiones arquitectónicas principales.

### RNF-31. Trazabilidad

- **Descripción:** requisitos, casos de uso, implementación y pruebas deberán poder
  relacionarse mediante identificadores, issues, commits o documentación.
- **Prioridad:** Must.
- **Verificación:** cada función principal puede vincularse al menos con un requisito,
  una issue y un caso de prueba.

## 10. Escalabilidad y límites

### RNF-32. Volumen doméstico objetivo

- **Descripción:** el sistema deberá soportar el uso habitual de un hogar sin cambios
  de arquitectura.
- **Prioridad:** Must.
- **Verificación:** las pruebas con 10 miembros, 500 productos y 200 elementos de
  cesta conservan los objetivos funcionales y de rendimiento establecidos.

### RNF-33. Consultas limitadas

- **Descripción:** las consultas deberán evitar descargar colecciones ajenas al hogar
  o conjuntos de datos ilimitados.
- **Prioridad:** Must.
- **Verificación:** cada consulta se restringe al hogar autorizado y utiliza filtros,
  ordenación o paginación cuando el volumen pueda crecer.

### RNF-34. Coste controlado del servicio

- **Descripción:** el diseño del MVP deberá ser viable dentro de los límites de uso
  académico del proveedor seleccionado.
- **Prioridad:** Should.
- **Verificación:** se evitan escuchas duplicadas, escrituras innecesarias y consultas
  completas repetitivas, y se documentan los servicios activados.

## 11. Resumen de cobertura

| Categoría | Requisitos |
|---|---|
| Usabilidad | RNF-01 a RNF-04 |
| Accesibilidad | RNF-05 a RNF-09 |
| Rendimiento | RNF-10 a RNF-13 |
| Disponibilidad y recuperación | RNF-14 a RNF-16 |
| Seguridad y privacidad | RNF-17 a RNF-22 |
| Compatibilidad | RNF-23 a RNF-26 |
| Mantenibilidad y calidad | RNF-27 a RNF-31 |
| Escalabilidad y límites | RNF-32 a RNF-34 |

## 12. Decisiones pendientes

- Fijar el nivel mínimo de Android tras revisar el entorno de compilación.
- Elegir los dispositivos o emuladores empleados como referencia para medir tiempos.
- Definir el margen de caducidad utilizado en las pruebas.
- Precisar qué comportamiento sin conexión se implementará explícitamente y cuál se
  delegará en la persistencia local de Firestore.
- Establecer los indicadores KPI de producto, diferenciándolos de estas métricas de
  calidad técnica.
