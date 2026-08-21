# Visión y alcance de Despensa

## 1. Contexto

En muchos hogares, el control de los alimentos y productos de consumo diario se
realiza de memoria, mediante notas en papel o con aplicaciones de listas que no
representan el inventario real. Esta falta de información hace que se compren
productos repetidos, se olviden otros necesarios y se descubran alimentos caducados
cuando ya no se pueden consumir.

El problema aumenta cuando varias personas comparten la compra y el consumo del
hogar. Una lista que no está sincronizada o un inventario que depende de una sola
persona deja de reflejar rápidamente la situación real.

## 2. Problema que se quiere resolver

Las personas que conviven en un mismo hogar necesitan conocer, desde el móvil, qué
productos tienen disponibles, cuáles están próximos a agotarse o caducar y qué deben
comprar. Actualmente, esa información suele encontrarse fragmentada, desactualizada
o únicamente en la memoria de uno de los miembros del hogar.

Como consecuencia:

- Se compran productos que ya estaban disponibles.
- Se olvidan productos necesarios durante la compra.
- Se desperdician alimentos por superar su fecha de caducidad.
- Varias personas modifican listas diferentes y generan inconsistencias.
- Preparar la cesta de la compra requiere revisar físicamente diferentes zonas del
  hogar.

## 3. Visión del producto

Despensa será una aplicación móvil para Android que permitirá a los miembros de un
hogar mantener un inventario compartido y preparar conjuntamente la cesta de la
compra. La aplicación centralizará las cantidades, ubicaciones y fechas de caducidad
de los productos, facilitando que la información esté disponible y actualizada para
las personas autorizadas.

La aplicación buscará reducir olvidos, compras duplicadas y desperdicio doméstico
mediante una experiencia sencilla, accesible y orientada a tareas cotidianas.

## 4. Propuesta de valor

Despensa reunirá en una sola aplicación dos procesos que normalmente se gestionan
por separado: saber qué hay en casa y decidir qué comprar. El inventario alimentará
la cesta de la compra y la compra podrá actualizar posteriormente el inventario.

La propuesta se apoya en cuatro ideas:

1. **Información centralizada:** inventario y cesta dentro del mismo hogar digital.
2. **Colaboración:** cambios compartidos entre los miembros autorizados.
3. **Prevención:** identificación de productos agotados o próximos a caducar.
4. **Simplicidad:** operaciones rápidas y comprensibles para usuarios no técnicos.

## 5. Público objetivo

### 5.1. Público principal

- Personas que viven solas y desean organizar sus existencias y compras.
- Parejas y familias que comparten la compra y el consumo de productos.
- Compañeros de piso que necesitan mantener una cesta común.

### 5.2. Características de los usuarios

- Utilizan un teléfono Android.
- Tienen conocimientos básicos de aplicaciones móviles.
- Pueden gestionar productos con distintos niveles de detalle.
- Necesitan consultar o modificar información en momentos diferentes.

### 5.3. Usuarios no incluidos inicialmente

El MVP no estará dirigido a comercios, almacenes profesionales, restaurantes ni
organizaciones que necesiten facturación, proveedores, lotes o control contable.

## 6. Objetivos

### 6.1. Objetivo general

Desarrollar una aplicación móvil que permita gestionar de forma compartida el
inventario doméstico y la cesta de la compra, ayudando a reducir olvidos, compras
duplicadas y desperdicio de productos.

### 6.2. Objetivos específicos

- Permitir que un usuario se registre e inicie sesión de forma segura.
- Permitir la creación de un hogar y la incorporación de otros miembros.
- Registrar productos con su cantidad, unidad, categoría, ubicación y caducidad.
- Consultar y filtrar los productos disponibles en el hogar.
- Identificar productos agotados y productos próximos a caducar.
- Mantener una cesta de la compra compartida.
- Pasar productos del inventario a la cesta cuando sea necesario reponerlos.
- Incorporar al inventario los productos comprados.
- Sincronizar los cambios entre los miembros del mismo hogar.
- Proteger los datos para que solo sean accesibles por usuarios autorizados.

## 7. Alcance del producto mínimo viable

El MVP incluirá las funciones necesarias para demostrar el ciclo completo de uso,
desde el registro de un producto hasta su reposición mediante la cesta.

### 7.1. Acceso y hogar

- Registro con correo electrónico y contraseña.
- Inicio y cierre de sesión.
- Creación de un hogar.
- Consulta de los miembros del hogar.
- Incorporación de otro usuario mediante un mecanismo de invitación sencillo.

### 7.2. Inventario

- Creación, consulta, modificación y eliminación de productos.
- Registro de nombre, cantidad, unidad, categoría y ubicación.
- Fecha de caducidad opcional.
- Búsqueda por nombre.
- Filtrado por categoría, ubicación y estado.
- Identificación visual de productos agotados o próximos a caducar.

### 7.3. Cesta de la compra

- Creación automática de una cesta compartida para el hogar.
- Adición, modificación y eliminación de elementos.
- Marcado de elementos como comprados.
- Envío de un producto agotado desde el inventario a la cesta.
- Incorporación de los productos comprados al inventario.
- Prevención o aviso de elementos duplicados.

### 7.4. Sincronización y seguridad

- Persistencia de la información en Cloud Firestore.
- Sincronización de inventario y cesta entre miembros.
- Reglas para impedir el acceso a hogares ajenos.
- Validación de los datos introducidos por el usuario.

## 8. Funcionalidades fuera del MVP

Las siguientes posibilidades se considerarán mejoras futuras y no condicionarán la
entrega de la primera versión:

- Escaneo de códigos de barras.
- Reconocimiento de productos mediante fotografías.
- Lectura automática de tickets de compra.
- Comparación de precios entre supermercados.
- Integración con comercios o servicios de compra en línea.
- Recomendación de recetas.
- Estadísticas avanzadas de gasto o consumo.
- Control económico, facturas y presupuestos.
- Gestión profesional de almacenes o proveedores.
- Aplicaciones específicas para iOS, web o escritorio.

## 9. Restricciones

- La primera versión se desarrollará para Android con Flutter.
- Firebase proporcionará autenticación, persistencia y sincronización.
- El desarrollo se realizará dentro del calendario académico disponible.
- La aplicación deberá poder demostrarse con un conjunto reducido de usuarios y
  datos de prueba.
- Algunas funciones dependerán de una conexión a Internet.
- No se almacenarán datos bancarios ni información especialmente sensible.

## 10. Criterios de éxito del MVP

La primera versión se considerará satisfactoria cuando permita:

1. Registrar un usuario y crear un hogar.
2. Añadir, modificar y eliminar productos del inventario.
3. Consultar cantidades y caducidades.
4. Añadir productos a una cesta compartida.
5. Marcar una compra y actualizar el inventario.
6. Observar los cambios desde otro miembro autorizado.
7. Impedir que un usuario ajeno consulte los datos del hogar.
8. Completar los flujos principales sin errores bloqueantes.

## 11. Supuestos iniciales

- Cada usuario dispondrá de una cuenta individual.
- Un usuario podrá pertenecer al menos a un hogar durante el MVP.
- Los miembros colaborarán y serán responsables de mantener las cantidades
  actualizadas.
- La fecha de caducidad será opcional porque no todos los productos disponen de ella.
- Las cantidades podrán expresarse mediante unidades comprensibles para el usuario.
- Las decisiones definitivas se revisarán durante la extracción de requisitos y el
  modelado de casos de uso.

## 12. Riesgos iniciales

- Un registro manual demasiado lento podría reducir el uso del inventario.
- La información perderá utilidad si los miembros no actualizan las cantidades.
- La sincronización y los permisos pueden aumentar la complejidad técnica.
- Un alcance excesivo pondría en riesgo la estabilidad y las pruebas de la entrega.
- Las notificaciones de caducidad pueden verse afectadas por las restricciones de
  ejecución en segundo plano de Android.

Estos riesgos se mitigarán priorizando flujos cortos, limitando el MVP y validando
progresivamente las funciones de mayor importancia.
