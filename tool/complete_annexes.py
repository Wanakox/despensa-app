from copy import deepcopy
from pathlib import Path
from tempfile import NamedTemporaryFile
from zipfile import ZIP_DEFLATED, ZIP_STORED, ZipFile

from lxml import etree

ROOT = Path(__file__).resolve().parents[1]
ODT = ROOT / 'docs/entrega/Despensa-Memoria-Final.odt'
NS = {
    'office': 'urn:oasis:names:tc:opendocument:xmlns:office:1.0',
    'text': 'urn:oasis:names:tc:opendocument:xmlns:text:1.0',
    'table': 'urn:oasis:names:tc:opendocument:xmlns:table:1.0',
    'draw': 'urn:oasis:names:tc:opendocument:xmlns:drawing:1.0',
    'xlink': 'http://www.w3.org/1999/xlink',
}
Q = lambda p, n: f'{{{NS[p]}}}{n}'

with ZipFile(ODT) as archive:
    files = {name: archive.read(name) for name in archive.namelist()}
root = etree.fromstring(files['content.xml'])
body = root.find('.//office:text', NS)

def clean(node):
    return ' '.join(''.join(node.itertext()).split())

def heading_container(prefix):
    for child in body:
        headings = ([child] if child.tag == Q('text', 'h') else []) + child.xpath('.//text:h', namespaces=NS)
        if any(clean(h).startswith(prefix) for h in headings):
            return child
    raise RuntimeError(f'No se encontró {prefix}')

def paragraph(value, style='P13'):
    p = etree.Element(Q('text', 'p'), {Q('text', 'style-name'): style})
    span = etree.SubElement(p, Q('text', 'span'), {Q('text', 'style-name'): 'T1'})
    span.text = value
    return p

def subhead(value):
    return paragraph(value, 'P20')

def table_by_name(name):
    found = root.xpath(f"//table:table[@table:name='{name}']", namespaces=NS)
    if not found:
        raise RuntimeError(f'No se encontró la tabla {name}')
    return found[0]

def annex_table(name, new_name):
    table = deepcopy(table_by_name(name))
    table.set(Q('table', 'name'), new_name)
    return table

# Conserva el material actual antes de reemplazar el contenido del Anexo I.
rf = annex_table('RequisitosFuncionales', 'AnexoRequisitosFuncionales')
rnf = annex_table('RequisitosNoFuncionales', 'AnexoRequisitosNoFuncionales')
actors = annex_table('ActoresCasosUsoActualizados', 'AnexoActoresCompletos')
catalog = annex_table('CatalogoCasosUsoActualizado', 'AnexoCatalogoCompleto')
case_tables = [annex_table(f'CasoUso{i:02d}', f'AnexoCasoUso{i:02d}') for i in range(1, 17)]

case_titles = []
for i in range(1, 17):
    table = table_by_name(f'CasoUso{i:02d}')
    current = table.getprevious()
    while current is not None and not clean(current):
        current = current.getprevious()
    case_titles.append(clean(current))

diagram = next(
    deepcopy(p) for p in root.xpath('//text:p', namespaces=NS)
    if p.xpath('.//draw:frame', namespaces=NS) and 'Casos de uso' in clean(p)
)

annex_nodes = [
    paragraph('Este anexo reúne la especificación funcional completa utilizada en el proyecto: requisitos, actores, catálogo, diagrama y fichas detalladas de los dieciséis casos de uso.'),
    subhead('1. Requisitos funcionales'),
    paragraph('La prioridad utiliza MoSCoW: M (Must), S (Should) y C (Could).'),
    rf,
    subhead('2. Requisitos no funcionales'),
    rnf,
    subhead('3. Actores'),
    actors,
    subhead('4. Catálogo de casos de uso'),
    catalog,
    subhead('5. Diagrama general de casos de uso'),
    diagram,
    paragraph('Anexo I — Figura A1. Diagrama general de casos de uso', 'P6'),
    subhead('6. Especificación detallada de casos de uso'),
]
for title, table in zip(case_titles, case_tables):
    annex_nodes.append(subhead(title))
    annex_nodes.append(table)

annex_start = heading_container('ANEXO I. Especificaciones funcionales')
annex_end = heading_container('ANEXO II. Especificaciones formales del sistema')
start_i, end_i = body.index(annex_start), body.index(annex_end)
for node in list(body)[start_i + 1:end_i]:
    body.remove(node)
for offset, node in enumerate(annex_nodes):
    body.insert(start_i + 1 + offset, node)

# Duplica en los anexos el bloque completo del prototipo, incluido el enlace.
prototype_start = heading_container('1.2.3. Prototipo interactivo')
functional_start = heading_container('1.3. Descripción funcional')
proto_nodes = [deepcopy(node) for node in list(body)[body.index(prototype_start) + 1:body.index(functional_start)]]

body.append(subhead('4. Prototipo interactivo y evidencias de interfaz'))
body.append(paragraph('Las siguientes capturas recogen el flujo visual completo diseñado antes de la implementación: bienvenida, acceso, registro, creación del hogar, resumen, inventario, cesta y gestión de miembros.'))
for node in proto_nodes:
    body.append(node)

# Añade el nuevo apartado a la relación estática de contenidos del Anexo II.
for p in root.xpath('//text:p', namespaces=NS):
    if clean(p) == '3. Evidencias de interfaz y proceso':
        entry = deepcopy(p)
        text_nodes = entry.xpath('.//text()', namespaces=NS)
        if text_nodes:
            text_nodes[0].getparent().text = '4. Prototipo interactivo y evidencias de interfaz'
            for extra in text_nodes[1:]:
                extra.getparent().text = ''
        p.getparent().insert(p.getparent().index(p) + 1, entry)
        break

files['content.xml'] = etree.tostring(root, xml_declaration=True, encoding='UTF-8')
with NamedTemporaryFile(dir=ODT.parent, suffix='.odt', delete=False) as temp:
    temporary = Path(temp.name)
with ZipFile(temporary, 'w') as output:
    output.writestr('mimetype', files.pop('mimetype'), compress_type=ZIP_STORED)
    for name, data in files.items():
        output.writestr(name, data, compress_type=ZIP_DEFLATED)
temporary.replace(ODT)
print(ODT)
