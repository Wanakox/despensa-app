# Análisis de aplicaciones similares

## 1. Objetivo

El objetivo de este análisis es estudiar soluciones existentes relacionadas con el
inventario doméstico y la cesta de la compra. La comparación permite identificar
funciones consolidadas, limitaciones y oportunidades que ayuden a definir Despensa
sin ampliar innecesariamente el producto mínimo viable.

El estudio se basa en la información publicada por los proveedores y consultada en
agosto de 2026. No constituye una prueba exhaustiva de todas las versiones, planes de
pago o plataformas disponibles.

## 2. Criterios de comparación

Se han seleccionado los siguientes criterios por su relación con el problema que
pretende resolver Despensa:

- Gestión de un inventario doméstico.
- Registro de cantidades y fechas de caducidad.
- Organización por ubicaciones o categorías.
- Creación de listas de compra.
- Colaboración y sincronización entre usuarios.
- Paso de información entre inventario y cesta.
- Ayudas para introducir productos con rapidez.
- Funciones adicionales que puedan distraer del objetivo principal.

## 3. Aplicaciones estudiadas

### 3.1. NoWaste

NoWaste se centra en la gestión de alimentos disponibles en el frigorífico, el
congelador y la despensa. Su información oficial destaca el seguimiento de cantidades
y fechas de caducidad, la reducción del desperdicio, la lista de compra y ayudas como
el escaneo de códigos de barras y el reconocimiento mediante fotografías.

**Puntos fuertes:**

- El inventario se organiza según ubicaciones domésticas reconocibles.
- Relaciona directamente existencias, caducidad y desperdicio alimentario.
- Reduce el esfuerzo de registro mediante escaneo y reconocimiento visual.
- Combina inventario y lista de compra en un mismo producto.

**Aspectos a considerar:**

- El reconocimiento automático aumenta la complejidad técnica.
- La planificación de comidas y las funciones basadas en inteligencia artificial
  amplían el producto más allá del núcleo de inventario y compra.
- Un registro muy detallado puede resultar costoso para usuarios que solo necesitan
  controlar unos pocos productos.

**Aprendizaje para Despensa:** utilizar ubicaciones sencillas y hacer opcionales los
datos que no sean imprescindibles. El escaneo puede reservarse como mejora futura.

### 3.2. Pantry Check

Pantry Check presenta un sistema de inventario doméstico con lectura de códigos de
barras, cantidades, fechas de caducidad, ubicaciones personalizadas, sincronización
familiar y listas inteligentes basadas en el uso y las existencias. También incorpora
precios y estimaciones del coste de la compra.

**Puntos fuertes:**

- Integra el ciclo completo entre inventario y compra.
- Permite compartir la información del hogar en tiempo real.
- Ofrece recordatorios de caducidad.
- Las listas pueden aprovechar la información del inventario.

**Aspectos a considerar:**

- La versión gratuita limita el número de productos según la información pública de
  su ficha.
- Los precios, estadísticas de uso y gran base de productos aumentan la densidad de
  la interfaz.
- La ficha oficial consultada corresponde a su distribución en el ecosistema Apple,
  mientras que Despensa se orientará primero a Android.

**Aprendizaje para Despensa:** el vínculo entre inventario y cesta es una ventaja
central, pero debe implementarse con un flujo corto y sin depender inicialmente de
una base mundial de productos.

### 3.3. Bring!

Bring! se especializa en listas de compra compartidas. Permite crear listas, añadir
detalles e imágenes, sincronizar los cambios en tiempo real y ordenar los elementos
según los pasillos del supermercado. Su producto también ofrece folletos, ofertas,
tarjetas de fidelización y recetas.

**Puntos fuertes:**

- Colaboración sencilla para familias, parejas y compañeros de piso.
- Cambios compartidos en tiempo real.
- Introducción y marcado rápido de productos.
- Presentación visual y adaptable de la lista.

**Aspectos a considerar:**

- Su núcleo está en la planificación de la compra, no en el inventario doméstico.
- Ofertas, folletos, fidelización y recetas añaden objetivos comerciales y de
  contenido que no son necesarios para Despensa.
- Una interfaz muy visual puede dificultar la presentación de cantidades,
  ubicaciones y caducidades de forma compacta.

**Aprendizaje para Despensa:** la cesta debe ser rápida y colaborativa. La gestión de
ofertas o recetas no debe formar parte del MVP.

### 3.4. Listonic

Listonic es una aplicación de listas de compra que permite crear y compartir listas,
sincronizarlas en tiempo real, ordenar productos, añadir cantidades, unidades, notas,
fotografías y precios, y recibir sugerencias basadas en el historial. También declara
funcionamiento sin conexión y acceso desde diferentes plataformas.

**Puntos fuertes:**

- Creación y edición rápida de listas.
- Colaboración en tiempo real con notificaciones de cambios.
- Organización automática y categorías personalizables.
- Posibilidad de utilizar las listas sin crear inicialmente una cuenta.
- Buen tratamiento de situaciones con conectividad limitada.

**Aspectos a considerar:**

- No representa como función principal las existencias reales del hogar.
- Presupuesto, precios, historial, voz e inteligencia artificial pueden alejarse del
  objetivo académico del MVP.
- Permitir colaboración sin cuenta simplifica el acceso, pero complica el control de
  permisos y la trazabilidad de los cambios.

**Aprendizaje para Despensa:** conviene minimizar los pasos para añadir y completar
elementos. En el MVP se mantendrán cuentas individuales para aplicar permisos claros
a cada hogar.

## 4. Tabla comparativa

| Criterio | NoWaste | Pantry Check | Bring! | Listonic | Despensa (MVP) |
|---|---|---|---|---|---|
| Inventario doméstico | Sí | Sí | No como función central | No como función central | Sí |
| Cantidades | Sí | Sí | Sí, en la lista | Sí, en la lista | Sí |
| Caducidades | Sí | Sí | No como función central | No como función central | Sí |
| Ubicaciones del hogar | Frigorífico, congelador y despensa | Personalizables | No | No como inventario | Sí |
| Cesta de la compra | Sí | Sí | Sí | Sí | Sí |
| Compartición en tiempo real | Disponible según el producto | Sí | Sí | Sí | Sí |
| Relación inventario-cesta | Sí | Sí | Limitada | Limitada | Sí |
| Código de barras | Sí | Sí | No es su función principal | No es su función principal | Mejora futura |
| Reconocimiento fotográfico | Sí | Registro con imágenes | Imágenes en elementos | Imágenes en elementos | Fuera del MVP |
| Precios o presupuesto | No es el núcleo | Sí | Mediante ofertas | Sí | Fuera del MVP |
| Recetas o comidas | Sí | No es el núcleo | Sí | Sugerencias y asistente | Fuera del MVP |
| Plataforma inicial de Despensa | - | - | - | - | Android |

## 5. Oportunidad de diferenciación

Las soluciones analizadas suelen especializarse en uno de dos extremos:

1. Inventarios detallados con escaneo, caducidades y funciones de planificación.
2. Listas de compra muy rápidas con colaboración, ofertas o recomendaciones.

Despensa puede situarse entre ambos mediante un MVP pequeño que mantenga una
relación explícita entre existencias y compra. Su diferenciación académica no
consistirá en tener más funciones, sino en demostrar con claridad el siguiente ciclo:

1. Un miembro registra o consulta un producto del hogar.
2. El producto se agota o necesita reposición.
3. Se incorpora a la cesta compartida evitando duplicados.
4. Otro miembro observa el cambio y realiza la compra.
5. Los productos comprados actualizan el inventario.

Este ciclo combina las fortalezas observadas en las aplicaciones de inventario y en
las listas colaborativas, manteniendo fuera del MVP las funciones que incrementarían
el riesgo técnico.

## 6. Decisiones derivadas del análisis

- Mantener inventario y cesta como módulos diferenciados pero conectados.
- Permitir cantidades, unidades, categorías y ubicaciones.
- Hacer opcional la fecha de caducidad.
- Compartir la información dentro de un hogar con usuarios autenticados.
- Evitar duplicados al mover productos a la cesta o devolverlos al inventario.
- Diseñar operaciones frecuentes con pocos pasos.
- Reservar códigos de barras, fotografías, tickets, recetas, precios e inteligencia
  artificial para mejoras futuras.
- Considerar el funcionamiento con conexión inestable durante el diseño técnico,
  aprovechando las posibilidades de persistencia local del proveedor seleccionado.

## 7. Conclusión

El mercado confirma que el problema es relevante y que las funciones de inventario,
caducidad y listas compartidas aportan valor por separado. También muestra que la
acumulación de funciones puede aumentar la complejidad y el esfuerzo de registro.

Despensa priorizará un ciclo coherente entre el producto disponible y el producto que
debe comprarse. La sencillez, la colaboración y la delimitación del MVP serán los
principales criterios para la posterior extracción de requisitos.

## 8. Fuentes consultadas

- [NoWaste - Food inventory management](https://www.nowasteapp.com/)
- [Pantry Check - ficha en App Store](https://apps.apple.com/us/app/pantry-check-grocery-list/id966702368)
- [Bring! - funcionalidades](https://www.getbring.com/en/features)
- [Bring! - listas colaborativas](https://www.getbring.com/en/features/collaborative)
- [Listonic - funcionalidades](https://listonic.com/features)
- [Listonic - listas compartidas](https://listonic.com/features/share-lists)
