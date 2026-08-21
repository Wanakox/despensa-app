# Especificación de requisitos funcionales

## 1. Propósito

Este documento define las funciones que deberá proporcionar el producto mínimo
viable de Despensa. Los requisitos se derivan de la visión y el alcance aprobados y
del análisis de aplicaciones similares.

La especificación servirá como entrada para los casos de uso, el modelo de datos, el
diseño de interfaces y los casos de prueba.

## 2. Convenciones

Cada requisito utiliza el identificador `RF-XX` y contiene:

- **Descripción:** comportamiento observable que debe ofrecer el sistema.
- **Prioridad:** importancia dentro del proyecto.
- **Criterio de aceptación:** condición verificable para considerar satisfecho el
  requisito.

Las prioridades utilizadas son:

- **Must:** imprescindible para que el MVP cumpla su propósito.
- **Should:** importante, pero el sistema puede demostrarse temporalmente sin ella.
- **Could:** mejora deseable si el calendario lo permite.

## 3. Actores preliminares

| Actor | Descripción |
|---|---|
| Visitante | Persona que todavía no ha iniciado sesión. |
| Usuario | Persona registrada y autenticada en Despensa. |
| Propietario del hogar | Usuario que crea un hogar y puede gestionar sus miembros. |
| Miembro del hogar | Usuario autorizado para consultar y modificar el inventario y la cesta de un hogar. |

Un propietario también actúa como miembro dentro del hogar. La definición definitiva
de actores se realizará en la issue correspondiente a los casos de uso.

## 4. Autenticación y sesión

### RF-01. Registro de usuario

- **Descripción:** el sistema deberá permitir que un visitante cree una cuenta
  mediante correo electrónico y contraseña.
- **Prioridad:** Must.
- **Criterio de aceptación:** con datos válidos se crea la cuenta y con un correo no
  válido, una contraseña insuficiente o una cuenta existente se muestra un error
  comprensible sin duplicar el usuario.

### RF-02. Inicio de sesión

- **Descripción:** el sistema deberá permitir que un usuario acceda mediante su
  correo electrónico y contraseña.
- **Prioridad:** Must.
- **Criterio de aceptación:** las credenciales válidas permiten acceder al área
  autenticada y las no válidas generan un mensaje sin revelar qué dato es incorrecto.

### RF-03. Persistencia de sesión

- **Descripción:** el sistema deberá conservar la sesión iniciada entre aperturas de
  la aplicación hasta que el usuario cierre sesión o la credencial deje de ser válida.
- **Prioridad:** Must.
- **Criterio de aceptación:** al cerrar y volver a abrir la aplicación, un usuario con
  sesión válida accede sin introducir nuevamente sus credenciales.

### RF-04. Cierre de sesión

- **Descripción:** el sistema deberá permitir cerrar la sesión activa.
- **Prioridad:** Must.
- **Criterio de aceptación:** al cerrar sesión se impide consultar información del
  hogar y se vuelve a la pantalla de acceso.

### RF-05. Restablecimiento de contraseña

- **Descripción:** el sistema deberá permitir solicitar el restablecimiento de una
  contraseña mediante el correo de la cuenta.
- **Prioridad:** Should.
- **Criterio de aceptación:** una solicitud válida inicia el mecanismo de
  recuperación sin confirmar públicamente si el correo pertenece a una cuenta.

## 5. Gestión del hogar

### RF-06. Creación de un hogar

- **Descripción:** el sistema deberá permitir que un usuario cree un hogar con un
  nombre identificativo.
- **Prioridad:** Must.
- **Criterio de aceptación:** se crea un hogar válido, el usuario se convierte en su
  propietario y puede acceder a su inventario y cesta.

### RF-07. Consulta del hogar activo

- **Descripción:** el sistema deberá mostrar el nombre y los datos básicos del hogar
  que el usuario está gestionando.
- **Prioridad:** Must.
- **Criterio de aceptación:** las pantallas principales indican de forma inequívoca
  a qué hogar pertenecen los datos mostrados.

### RF-08. Invitación de miembros

- **Descripción:** el propietario deberá poder generar o enviar una invitación para
  incorporar a otro usuario al hogar.
- **Prioridad:** Should.
- **Criterio de aceptación:** un usuario autenticado puede aceptar una invitación
  válida una sola vez y pasa a figurar como miembro del hogar correspondiente.

### RF-09. Consulta de miembros

- **Descripción:** los miembros deberán poder consultar qué usuarios forman parte
  del hogar.
- **Prioridad:** Should.
- **Criterio de aceptación:** la aplicación muestra la lista actualizada de miembros
  y diferencia al propietario.

### RF-10. Expulsión de un miembro

- **Descripción:** el propietario deberá poder retirar del hogar a un miembro que no
  sea el propio propietario.
- **Prioridad:** Could.
- **Criterio de aceptación:** el usuario retirado deja de poder consultar o modificar
  los datos del hogar y el resto de miembros conserva el acceso.

## 6. Gestión del inventario

### RF-11. Consulta del inventario

- **Descripción:** los miembros deberán poder consultar los productos registrados en
  el hogar activo.
- **Prioridad:** Must.
- **Criterio de aceptación:** el listado muestra, como mínimo, nombre, cantidad,
  unidad y estado de cada producto.

### RF-12. Alta de un producto

- **Descripción:** los miembros deberán poder añadir un producto indicando nombre,
  cantidad, unidad, categoría y ubicación, con fecha de caducidad opcional.
- **Prioridad:** Must.
- **Criterio de aceptación:** los datos válidos crean el producto en el hogar activo;
  los datos obligatorios ausentes o inválidos impiden guardarlo y se señalan en el
  formulario.

### RF-13. Modificación de un producto

- **Descripción:** los miembros deberán poder modificar los datos de un producto del
  hogar.
- **Prioridad:** Must.
- **Criterio de aceptación:** al guardar cambios válidos, el inventario refleja la
  nueva información sin crear un producto adicional.

### RF-14. Eliminación de un producto

- **Descripción:** los miembros deberán poder eliminar un producto del inventario.
- **Prioridad:** Must.
- **Criterio de aceptación:** la aplicación solicita confirmación y, tras aceptarla,
  el producto deja de aparecer en el inventario del hogar.

### RF-15. Ajuste de cantidad

- **Descripción:** los miembros deberán poder aumentar o reducir rápidamente la
  cantidad disponible de un producto.
- **Prioridad:** Must.
- **Criterio de aceptación:** la cantidad se actualiza sin admitir valores negativos
  y el producto se identifica como agotado cuando alcanza cero.

### RF-16. Consulta del detalle de un producto

- **Descripción:** los miembros deberán poder consultar todos los datos almacenados
  de un producto.
- **Prioridad:** Must.
- **Criterio de aceptación:** desde el listado se puede abrir una vista que muestra
  los datos actuales y ofrece las acciones permitidas.

### RF-17. Búsqueda por nombre

- **Descripción:** los miembros deberán poder buscar productos por su nombre.
- **Prioridad:** Must.
- **Criterio de aceptación:** al introducir texto, el listado muestra únicamente los
  productos cuyo nombre coincide total o parcialmente sin distinguir mayúsculas.

### RF-18. Filtrado del inventario

- **Descripción:** los miembros deberán poder filtrar los productos por categoría,
  ubicación y estado.
- **Prioridad:** Should.
- **Criterio de aceptación:** cada filtro aplicado limita correctamente el listado y
  puede retirarse para recuperar todos los productos.

### RF-19. Gestión de categorías

- **Descripción:** el sistema deberá ofrecer categorías para clasificar productos y
  permitir al menos seleccionar una categoría durante su alta o edición.
- **Prioridad:** Must.
- **Criterio de aceptación:** cada producto queda asociado a una categoría válida y
  esta puede utilizarse en el filtro del inventario.

### RF-20. Gestión de ubicaciones

- **Descripción:** el sistema deberá permitir clasificar los productos mediante
  ubicaciones domésticas, como despensa, frigorífico o congelador.
- **Prioridad:** Must.
- **Criterio de aceptación:** cada producto queda asociado a una ubicación válida y
  esta puede utilizarse en el filtro del inventario.

### RF-21. Identificación de productos agotados

- **Descripción:** el sistema deberá identificar visualmente los productos cuya
  cantidad sea cero.
- **Prioridad:** Must.
- **Criterio de aceptación:** un producto con cantidad cero presenta un estado
  claramente reconocible y puede enviarse a la cesta.

### RF-22. Identificación de productos próximos a caducar

- **Descripción:** el sistema deberá identificar productos caducados o próximos a su
  fecha de caducidad.
- **Prioridad:** Must.
- **Criterio de aceptación:** los productos con fecha se clasifican de forma
  consistente como vigentes, próximos a caducar o caducados según el margen definido.

### RF-23. Consulta de caducidades

- **Descripción:** los miembros deberán poder consultar una vista o filtro de
  productos próximos a caducar y caducados.
- **Prioridad:** Should.
- **Criterio de aceptación:** la vista ordena o agrupa los productos por urgencia y
  no incluye productos sin fecha como si estuvieran caducados.

## 7. Gestión de la cesta de la compra

### RF-24. Consulta de la cesta

- **Descripción:** los miembros deberán poder consultar la cesta compartida del hogar
  activo.
- **Prioridad:** Must.
- **Criterio de aceptación:** todos los miembros autorizados consultan los mismos
  elementos y su estado actualizado.

### RF-25. Alta de un elemento en la cesta

- **Descripción:** los miembros deberán poder añadir manualmente un elemento con
  nombre, cantidad y unidad.
- **Prioridad:** Must.
- **Criterio de aceptación:** los datos válidos añaden el elemento y los datos
  obligatorios ausentes muestran errores en el formulario.

### RF-26. Modificación de un elemento de la cesta

- **Descripción:** los miembros deberán poder modificar el nombre, cantidad, unidad
  y notas de un elemento pendiente.
- **Prioridad:** Must.
- **Criterio de aceptación:** los cambios se guardan en el mismo elemento y aparecen
  para los demás miembros.

### RF-27. Eliminación de un elemento de la cesta

- **Descripción:** los miembros deberán poder retirar un elemento de la cesta.
- **Prioridad:** Must.
- **Criterio de aceptación:** tras la acción, el elemento deja de aparecer en la
  cesta compartida sin modificar el inventario.

### RF-28. Marcado de un elemento como comprado

- **Descripción:** los miembros deberán poder marcar y desmarcar un elemento como
  comprado.
- **Prioridad:** Must.
- **Criterio de aceptación:** el estado se diferencia visualmente y se sincroniza con
  los demás miembros sin eliminar inmediatamente el elemento.

### RF-29. Envío de un producto a la cesta

- **Descripción:** los miembros deberán poder añadir a la cesta un producto existente
  en el inventario para reponerlo.
- **Prioridad:** Must.
- **Criterio de aceptación:** la acción crea o actualiza un elemento vinculado al
  producto y no altera por sí misma la cantidad disponible.

### RF-30. Prevención de duplicados en la cesta

- **Descripción:** el sistema deberá detectar que un producto o nombre equivalente ya
  está pendiente en la cesta antes de añadirlo de nuevo.
- **Prioridad:** Must.
- **Criterio de aceptación:** ante un duplicado, el sistema permite actualizar la
  cantidad existente o cancelar, sin crear silenciosamente dos elementos pendientes.

### RF-31. Incorporación de compras al inventario

- **Descripción:** los miembros deberán poder incorporar al inventario los elementos
  marcados como comprados.
- **Prioridad:** Must.
- **Criterio de aceptación:** los elementos vinculados actualizan la cantidad del
  producto correspondiente; los no vinculados permiten crear un producto, y solo los
  elementos procesados se retiran o archivan en la cesta.

### RF-32. Separación entre pendientes y comprados

- **Descripción:** la cesta deberá distinguir los elementos pendientes de los ya
  comprados.
- **Prioridad:** Should.
- **Criterio de aceptación:** el usuario puede identificar ambos grupos y continuar
  añadiendo o marcando elementos sin perder información.

## 8. Sincronización y avisos

### RF-33. Sincronización entre miembros

- **Descripción:** el sistema deberá propagar los cambios de inventario, cesta y
  miembros a los usuarios autorizados del mismo hogar.
- **Prioridad:** Must.
- **Criterio de aceptación:** un cambio confirmado desde un dispositivo aparece en
  otro dispositivo conectado sin necesitar reiniciar la aplicación.

### RF-34. Control de acceso por hogar

- **Descripción:** el sistema deberá permitir consultar o modificar un hogar solo a
  los usuarios que pertenezcan a él.
- **Prioridad:** Must.
- **Criterio de aceptación:** una solicitud autenticada de un usuario ajeno es
  rechazada incluso si conoce el identificador del hogar o de un producto.

### RF-35. Avisos de caducidad

- **Descripción:** el sistema debería avisar al usuario cuando existan productos
  próximos a caducar según el margen configurado por la aplicación.
- **Prioridad:** Should.
- **Criterio de aceptación:** un producto con fecha dentro del margen genera un aviso
  identificable y un producto sin fecha no lo genera.

### RF-36. Estados de carga, vacío y error

- **Descripción:** el sistema deberá informar del estado de las operaciones y de la
  ausencia de datos.
- **Prioridad:** Must.
- **Criterio de aceptación:** los listados diferencian carga, resultado vacío y error,
  y los fallos de guardado no se presentan como operaciones completadas.

## 9. Requisitos funcionales fuera del MVP

Los siguientes requisitos no se implementarán en la primera versión, aunque podrán
incorporarse al backlog futuro:

| Identificador | Funcionalidad | Motivo de exclusión |
|---|---|---|
| RF-F01 | Escaneo de códigos de barras | Requiere cámara, catálogo externo y tratamiento de productos no reconocidos. |
| RF-F02 | Reconocimiento de tickets | Exige OCR y reglas para interpretar comercios y formatos diferentes. |
| RF-F03 | Reconocimiento fotográfico | Incrementa el riesgo técnico y no es necesario para demostrar el ciclo principal. |
| RF-F04 | Comparación de precios | Depende de proveedores externos y datos comerciales actualizados. |
| RF-F05 | Recomendación de recetas | Amplía el propósito del MVP y requiere información adicional de ingredientes. |
| RF-F06 | Estadísticas de gasto | Necesita precios e historial de compras fiable. |
| RF-F07 | Aplicación para iOS o web | La plataforma académica inicial será Android. |

## 10. Matriz de cobertura preliminar

| Área del MVP | Requisitos |
|---|---|
| Acceso seguro | RF-01 a RF-05 |
| Hogar compartido | RF-06 a RF-10 |
| Inventario | RF-11 a RF-23 |
| Cesta de la compra | RF-24 a RF-32 |
| Sincronización y avisos | RF-33 a RF-36 |

La trazabilidad con casos de uso y casos de prueba se añadirá cuando estos elementos
sean definidos y reciban sus identificadores definitivos.

## 11. Decisiones pendientes

- Determinar el margen exacto para considerar próxima una caducidad.
- Definir el mecanismo concreto de invitación al hogar.
- Acordar las unidades y categorías iniciales.
- Decidir si el MVP permitirá pertenecer a varios hogares simultáneamente.
- Precisar cómo se resolverá una modificación simultánea del mismo producto.

Estas decisiones no impiden continuar el modelado, pero deberán resolverse antes de
implementar los módulos afectados.
