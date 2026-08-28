from pathlib import Path
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.section import WD_SECTION
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "entrega" / "Despensa-Memoria-Final.docx"
GREEN = "446B55"
SAGE = "DDE8DC"
TERRA = "B86345"
INK = "26332B"
MUTED = "66736B"


def shade(cell, color):
    tc_pr = cell._tc.get_or_add_tcPr()
    shd = OxmlElement("w:shd")
    shd.set(qn("w:fill"), color)
    tc_pr.append(shd)


def margins(cell, top=100, start=120, bottom=100, end=120):
    tc = cell._tc.get_or_add_tcPr()
    tc_mar = tc.first_child_found_in("w:tcMar")
    if tc_mar is None:
        tc_mar = OxmlElement("w:tcMar")
        tc.append(tc_mar)
    for side, value in (("top", top), ("start", start), ("bottom", bottom), ("end", end)):
        node = OxmlElement(f"w:{side}")
        node.set(qn("w:w"), str(value))
        node.set(qn("w:type"), "dxa")
        tc_mar.append(node)


def set_cell_text(cell, text, bold=False, color=INK, size=9):
    cell.text = ""
    p = cell.paragraphs[0]
    p.paragraph_format.space_after = Pt(0)
    r = p.add_run(str(text))
    r.bold = bold
    r.font.name = "Aptos"
    r.font.size = Pt(size)
    r.font.color.rgb = RGBColor.from_string(color)
    cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
    margins(cell)


def add_table(doc, headers, rows, widths=None):
    table = doc.add_table(rows=1, cols=len(headers))
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False
    for i, header in enumerate(headers):
        set_cell_text(table.rows[0].cells[i], header, bold=True, color="FFFFFF")
        shade(table.rows[0].cells[i], GREEN)
    for row_index, row in enumerate(rows):
        cells = table.add_row().cells
        for i, value in enumerate(row):
            set_cell_text(cells[i], value)
            if row_index % 2:
                shade(cells[i], "F4F7F3")
    if widths:
        for row in table.rows:
            for i, width in enumerate(widths):
                row.cells[i].width = Inches(width)
    doc.add_paragraph().paragraph_format.space_after = Pt(2)
    return table


def bullet(doc, text):
    p = doc.add_paragraph(style="List Bullet")
    p.add_run(text)
    return p


def figure(doc, path, caption, width=5.9):
    path = ROOT / path
    if not path.exists():
        return
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.add_run().add_picture(str(path), width=Inches(width))
    cap = doc.add_paragraph(caption)
    cap.style = doc.styles["Caption"]
    cap.alignment = WD_ALIGN_PARAGRAPH.CENTER


def page_break(doc):
    doc.add_page_break()


doc = Document()
sec = doc.sections[0]
sec.page_width = Inches(8.5)
sec.page_height = Inches(11)
sec.top_margin = sec.bottom_margin = Inches(0.8)
sec.left_margin = sec.right_margin = Inches(0.85)
sec.header_distance = Inches(0.35)
sec.footer_distance = Inches(0.35)

styles = doc.styles
normal = styles["Normal"]
normal.font.name = "Aptos"
normal.font.size = Pt(10.5)
normal.font.color.rgb = RGBColor.from_string(INK)
normal.paragraph_format.space_after = Pt(7)
normal.paragraph_format.line_spacing = 1.2
for name, size, before, after in (("Title", 30, 0, 10), ("Heading 1", 18, 16, 8), ("Heading 2", 14, 12, 6), ("Heading 3", 11.5, 9, 4)):
    style = styles[name]
    style.font.name = "Aptos Display" if name != "Heading 3" else "Aptos"
    style.font.size = Pt(size)
    style.font.color.rgb = RGBColor.from_string(GREEN)
    style.font.bold = True
    style.paragraph_format.space_before = Pt(before)
    style.paragraph_format.space_after = Pt(after)
    style.paragraph_format.keep_with_next = True
styles["Caption"].font.name = "Aptos"
styles["Caption"].font.size = Pt(9)
styles["Caption"].font.color.rgb = RGBColor.from_string(MUTED)

header = sec.header.paragraphs[0]
header.text = "DESPENSA · INGENIERÍA DE SISTEMAS MÓVILES"
header.alignment = WD_ALIGN_PARAGRAPH.RIGHT
header.runs[0].font.size = Pt(8)
header.runs[0].font.color.rgb = RGBColor.from_string(MUTED)
footer = sec.footer.paragraphs[0]
footer.alignment = WD_ALIGN_PARAGRAPH.CENTER
field = OxmlElement("w:fldSimple")
field.set(qn("w:instr"), "PAGE")
footer._p.append(field)

# Cover: editorial_cover pattern.
doc.add_paragraph("PROYECTO FINAL", style="Subtitle").alignment = WD_ALIGN_PARAGRAPH.CENTER
doc.add_paragraph().paragraph_format.space_after = Pt(70)
logo = ROOT / "docs/branding/despensa-logo.png"
if logo.exists():
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.add_run().add_picture(str(logo), width=Inches(2.3))
title = doc.add_paragraph("Despensa", style="Title")
title.alignment = WD_ALIGN_PARAGRAPH.CENTER
subtitle = doc.add_paragraph("Inventario doméstico y cesta de la compra compartida")
subtitle.alignment = WD_ALIGN_PARAGRAPH.CENTER
subtitle.runs[0].font.size = Pt(16)
subtitle.runs[0].font.color.rgb = RGBColor.from_string(TERRA)
doc.add_paragraph().paragraph_format.space_after = Pt(72)
meta = doc.add_paragraph("Autor: Juan García\nCórdoba · Agosto de 2026\nIngeniería de Sistemas Móviles")
meta.alignment = WD_ALIGN_PARAGRAPH.CENTER
meta.paragraph_format.line_spacing = 1.5
page_break(doc)

doc.add_heading("Resumen ejecutivo", 1)
doc.add_paragraph("Despensa es una aplicación móvil desarrollada con Flutter para coordinar el inventario de alimentos y productos de un hogar. Une en un mismo flujo las existencias, las fechas de caducidad y una cesta compartida, reduciendo olvidos, compras duplicadas y desperdicio. El sistema utiliza Firebase Authentication y Cloud Firestore para la identidad, la persistencia y la sincronización en tiempo real, e incluye un modo local que permite ejecutar y demostrar el MVP sin una configuración remota.")
add_table(doc, ["Resultado", "Evidencia"], [
    ("MVP funcional", "Acceso, hogares, inventario, cesta, miembros, perfil y actividad"),
    ("Calidad automatizada", "25 pruebas Flutter y análisis estático sin incidencias"),
    ("Entrega Android", "APK release de 55,2 MB generado el 28/08/2026"),
    ("Trazabilidad", "4 milestones y 45 issues gestionadas en GitHub"),
], [2.0, 4.4])
doc.add_heading("Índice de contenidos", 1)
for line in [
    "1. Especificación y análisis del problema", "2. Descripción gráfica y ergonómica", "3. Descripción funcional y técnica", "4. Backend y modelo de datos", "5. Estrategia y casos de prueba", "6. Servicios integrados y planificación", "7. Desarrollo del proyecto con Scrum", "8. Resultados, conclusiones y mejoras", "Anexos y referencias",
]: bullet(doc, line)
page_break(doc)

doc.add_heading("1. Especificación y análisis del problema", 1)
doc.add_heading("1.1 Visión general", 2)
doc.add_paragraph("En los hogares compartidos, las compras y el consumo suelen coordinarse mediante memoria, mensajes dispersos o listas sin relación con las existencias reales. Esto provoca productos duplicados, faltas inesperadas y alimentos que caducan sin ser consumidos. Despensa propone un registro doméstico común, accesible por los miembros autorizados y actualizado en tiempo real.")
doc.add_heading("1.2 Objetivos", 2)
for text in [
    "Centralizar las existencias del hogar con cantidades, unidades, ubicación y caducidad.",
    "Mantener una cesta compartida que refleje qué falta y qué se ha comprado.",
    "Convertir una compra finalizada en existencias sin crear duplicados.",
    "Avisar de productos agotados, caducados o próximos a caducar con margen configurable.",
    "Permitir colaboración segura mediante hogares, invitaciones y roles.",
]: bullet(doc, text)
doc.add_heading("1.3 Público objetivo y alcance", 2)
doc.add_paragraph("El producto se dirige a familias, parejas y pisos compartidos. El MVP se centra en Android y en el ciclo inventario-cesta. Quedan fuera del alcance inicial el reconocimiento fotográfico, el escaneo de códigos de barras, las recetas, la comparación de precios y la publicación en tiendas.")
doc.add_heading("1.4 Comparativa", 2)
add_table(doc, ["Solución", "Fortaleza", "Oportunidad para Despensa"], [
    ("NoWaste", "Caducidades y reducción de desperdicio", "Flujo más pequeño y colaboración clara"),
    ("Pantry Check", "Inventario y escaneo", "Evitar dependencia de una base global"),
    ("Bring!", "Lista compartida rápida", "Relacionar compra y existencias"),
    ("Listonic", "Sincronización y entrada ágil", "Mantener permisos por hogar"),
], [1.2, 2.4, 2.8])

doc.add_heading("2. Descripción gráfica y ergonómica", 1)
doc.add_paragraph("La interfaz sigue Material 3 con una identidad calmada y doméstica. El fondo marfil reduce dureza visual; el verde salvia representa orden y sostenibilidad; el terracota se reserva para avisos y acciones que requieren atención. Los controles principales mantienen áreas táctiles amplias, etiquetas textuales y confirmación en operaciones destructivas.")
figure(doc, "docs/branding/despensa-logo.png", "Figura 1. Identidad gráfica de Despensa", 2.5)
figure(doc, "docs/capturas/sprint3-final.png", "Figura 2. Estado funcional al cierre del Sprint 3", 5.4)
doc.add_heading("2.1 Navegación", 2)
doc.add_paragraph("Tras autenticarse, el usuario selecciona un hogar. La navegación inferior proporciona cuatro destinos persistentes: Inicio, Despensa, Cesta y Miembros. El perfil se abre desde la lista de hogares. Esta jerarquía separa la elección de contexto de las operaciones del hogar y reduce errores entre espacios compartidos.")

doc.add_heading("3. Descripción funcional y técnica", 1)
add_table(doc, ["Área", "Funciones principales"], [
    ("Autenticación", "Registro, inicio y cierre de sesión; recuperación de sesión"),
    ("Hogares", "Crear, seleccionar, renombrar, abandonar o eliminar"),
    ("Inventario", "Alta, edición, borrado, búsqueda, filtros y cantidades rápidas"),
    ("Caducidad", "Estados visuales, resumen de atención y margen configurable"),
    ("Cesta", "Alta, edición, comprado, vaciado e incorporación al inventario"),
    ("Colaboración", "Invitar, aceptar/rechazar, retirar y transferir propiedad"),
    ("Actividad", "Historial reciente con marcas de tiempo de servidor"),
], [1.4, 5.0])
doc.add_heading("3.1 Arquitectura", 2)
doc.add_paragraph("El código se organiza por funcionalidades. La capa presentation contiene pantallas y componentes; domain define entidades; data y core/services encapsulan Firebase y la persistencia local. Esta separación hace posible probar la lógica sin depender siempre de servicios remotos y limita el acoplamiento entre interfaz y backend.")
figure(doc, "docs/diagrams/Despensa-ER.png", "Figura 3. Modelo entidad-relación", 5.8)
figure(doc, "docs/diagrams/Despensa-CU.png", "Figura 4. Diagrama general de casos de uso", 5.8)

doc.add_heading("4. Backend y modelo de datos", 1)
doc.add_paragraph("Firebase Authentication gestiona la identidad por correo y contraseña. Cloud Firestore almacena hogares, miembros, inventario, cesta, actividad e invitaciones. Los inventarios y cestas se modelan como subcolecciones del hogar, lo que facilita el aislamiento y las escuchas en tiempo real. SharedPreferences proporciona un modo local para demostración y pruebas.")
add_table(doc, ["Colección", "Contenido", "Control"], [
    ("users/{uid}", "Perfil y referencias a hogares", "Solo el propio usuario"),
    ("households/{id}", "Nombre, propietario, contador y preferencias", "Miembros; acciones sensibles al propietario"),
    ("members", "Rol, nombre, correo y fecha de unión", "Lectura de miembros; gestión restringida"),
    ("inventory / cart", "Productos y elementos compartidos", "Lectura/escritura de miembros"),
    ("invitations", "Correo, hogar y estado", "Propietario y destinatario"),
    ("activity", "Descripción, autor y fecha", "Creación de miembros; inmutable"),
], [1.5, 2.8, 2.1])
doc.add_heading("4.1 Seguridad", 2)
doc.add_paragraph("Las reglas comprueban autenticación, pertenencia al hogar y rol de propietario. La aceptación de invitaciones valida el correo del token y el estado de la invitación. La actividad no puede editarse ni borrarse. En producción, las reglas deben desplegarse y validarse con Firebase Emulator Suite antes de cada release.")

doc.add_heading("5. Estrategia y casos de prueba", 1)
doc.add_paragraph("La estrategia combina pruebas unitarias de persistencia y transformación, pruebas de widgets para recorridos funcionales y verificaciones de compilación. La batería automatizada contiene 25 pruebas y se ejecutó junto con flutter analyze antes de generar el APK.")
tests = [
    ("CP-01", "Registro/inicio", "Credenciales válidas", "Acceso a Mis hogares", "Superado"),
    ("CP-02", "Crear hogar", "Nombre Casa de verano", "Hogar con un miembro", "Superado"),
    ("CP-03", "Buscar producto", "Consulta leche", "Solo coincidencias", "Superado"),
    ("CP-04", "Ajustar cantidad", "Reducir 6 a 5", "Cantidad persistente", "Superado"),
    ("CP-05", "Filtrar agotados", "Unidades 0 y 2", "Solo agotado", "Superado"),
    ("CP-06", "Añadir inventario", "Formulario válido", "Producto visible", "Superado"),
    ("CP-07", "Enviar a cesta", "Producto existente", "Elemento no duplicado", "Superado"),
    ("CP-08", "Editar cesta", "Cambiar unidades", "Dato actualizado", "Superado"),
    ("CP-09", "Marcar comprado", "Checkbox activo", "Estado conservado", "Superado"),
    ("CP-10", "Guardar compra", "Comprados seleccionados", "Inventario incrementado", "Superado"),
    ("CP-11", "Vaciar cesta", "Confirmación", "Estado vacío", "Superado"),
    ("CP-12", "Invitar miembro", "Correo válido", "Invitación creada", "Superado"),
    ("CP-13", "Aviso caducidad", "Margen 7 días", "Preferencia persistida", "Superado"),
    ("CP-14", "Análisis estático", "flutter analyze", "0 incidencias", "Superado"),
    ("CP-15", "Release Android", "flutter build apk --release", "APK generado", "Superado"),
]
add_table(doc, ["ID", "Caso", "Datos", "Resultado esperado", "Estado"], tests, [0.55, 1.2, 1.5, 2.45, 0.7])
doc.add_heading("5.1 Resultado de calidad", 2)
for text in [
    "flutter analyze: sin incidencias.", "flutter test: 25 de 25 pruebas superadas.", "flutter build apk --release: compilación correcta; APK de 55,2 MB.", "SHA-256: bc62374731cfb7c337fcfcdc5d04f9dd855fb698cdd4d2a2d57177f8d74f2954.",
]: bullet(doc, text)

doc.add_heading("6. Servicios integrados y planificación", 1)
add_table(doc, ["Servicio", "Motivo de selección", "Uso"], [
    ("Flutter", "Una base de código y Material 3", "Aplicación Android"),
    ("Firebase Auth", "Identidad gestionada y SDK oficial", "Registro y sesión"),
    ("Cloud Firestore", "Sincronización y reglas", "Datos colaborativos"),
    ("SharedPreferences", "Persistencia ligera", "Modo local"),
    ("GitHub", "Trazabilidad técnica", "Código, milestones e issues"),
], [1.3, 2.9, 2.2])
doc.add_paragraph("El trabajo se dividió en cuatro sprints: análisis y diseño; base técnica e inventario; cesta, caducidad y colaboración; y calidad y cierre. La planificación mediante milestones permitió relacionar requisitos, cambios y evidencias.")

doc.add_heading("7. Desarrollo del proyecto con Scrum", 1)
add_table(doc, ["Sprint", "Objetivo", "Resultado"], [
    ("1", "Análisis y diseño", "Visión, requisitos, casos de uso, modelo de datos y wireframes"),
    ("2", "Base técnica e inventario", "Flutter, Firebase, navegación, hogares e inventario"),
    ("3", "Cesta y colaboración", "Compra compartida, caducidades, tiempo real e invitaciones"),
    ("4", "Calidad y cierre", "Pruebas, APK, memoria y presentación"),
], [0.7, 2.2, 3.5])
figure(doc, "docs/capturas/sprint1-estado_inicial.png", "Figura 5. Inicio del Sprint 1", 5.7)
figure(doc, "docs/capturas/sprint1-estado_final.png", "Figura 6. Cierre del Sprint 1", 5.7)
figure(doc, "docs/capturas/sprint2-final.png", "Figura 7. Cierre del Sprint 2", 5.7)
figure(doc, "docs/capturas/sprint3-inicio.png", "Figura 8. Inicio del Sprint 3", 5.7)
figure(doc, "docs/capturas/sprint3-final.png", "Figura 9. Cierre del Sprint 3", 5.7)
doc.add_heading("7.1 Ceremonias y seguimiento", 2)
doc.add_paragraph("Cada sprint comenzó con selección de alcance y creación de issues. Durante el desarrollo se mantuvo un tablero de trabajo y se revisaron los cambios con análisis y pruebas. El cierre incluyó la comprobación del incremento, la actualización de evidencias y el estado de las issues. Al tratarse de un proyecto individual, el autor asumió las responsabilidades de Product Owner, Scrum Master y desarrollo.")

doc.add_heading("8. Resultados, conclusiones y mejoras", 1)
doc.add_heading("8.1 Puntos fuertes", 2)
for text in ["Ciclo completo entre inventario y cesta.", "Colaboración en tiempo real con control por hogar.", "Interfaz coherente y estados de error comprensibles.", "Modo local que facilita demostración y pruebas.", "Trazabilidad entre documentación, issues, código y pruebas."]: bullet(doc, text)
doc.add_heading("8.2 Limitaciones", 2)
for text in ["La primera entrega se limita a Android.", "No se incluyen notificaciones push en segundo plano.", "Las pruebas de reglas requieren completar una campaña con Emulator Suite.", "El APK usa la configuración de firma disponible en el entorno académico."]: bullet(doc, text)
doc.add_heading("8.3 Mejoras futuras", 2)
for text in ["Notificaciones locales y push de caducidad.", "Escaneo de códigos de barras y catálogo asistido.", "Funcionamiento offline avanzado con resolución de conflictos.", "Estadísticas de consumo y desperdicio.", "Versión iOS, publicación en tiendas y telemetría respetuosa con la privacidad."]: bullet(doc, text)
doc.add_heading("8.4 Conclusión", 2)
doc.add_paragraph("Despensa alcanza el objetivo académico y funcional propuesto: demuestra una aplicación móvil colaborativa, con backend real, diseño consistente y un ciclo de compra verificable. El proyecto queda en una versión estable para demostración y con una arquitectura adecuada para incorporar las mejoras futuras de forma incremental.")

doc.add_heading("Anexo I. Casos de uso", 1)
doc.add_paragraph("La especificación completa se conserva en docs/casos-de-uso-despensa.odt. Incluye actores, catálogo y flujos principales y alternativos de dieciséis casos de uso, desde el registro hasta la gestión de la cesta.")
doc.add_heading("Anexo II. Estructura técnica", 1)
for text in ["lib/app: aplicación y tema.", "lib/core: servicios y componentes reutilizables.", "lib/features/auth: registro e inicio de sesión.", "lib/features/households y members: colaboración y permisos.", "lib/features/inventory y cart: núcleo funcional.", "lib/features/home, activity y profile: resumen, trazabilidad y cuenta."]: bullet(doc, text)
doc.add_heading("Referencias", 1)
refs = [
    "Flutter. Documentación oficial. https://docs.flutter.dev/",
    "Firebase. Documentación de Authentication y Cloud Firestore. https://firebase.google.com/docs",
    "Material Design 3. https://m3.material.io/",
    "Schwaber, K. y Sutherland, J. The Scrum Guide, 2020. https://scrumguides.org/",
    "Universidad de Córdoba. Material docente de Ingeniería de Sistemas Móviles, 2026.",
    "NoWaste, Pantry Check, Bring! y Listonic. Información pública de producto consultada en agosto de 2026.",
]
for ref in refs: bullet(doc, ref)

for paragraph in doc.paragraphs:
    paragraph.paragraph_format.widow_control = True
    for run in paragraph.runs:
        run.font.name = run.font.name or "Aptos"

OUT.parent.mkdir(parents=True, exist_ok=True)
doc.save(OUT)
print(OUT)
