import fs from "node:fs/promises";
import { Presentation, PresentationFile } from "@oai/artifact-tool";

const ROOT = "/home/wan/Escritorio/ISM/despensa-app";
const OUT = `${ROOT}/docs/entrega/Despensa-Presentacion-Final.pptx`;
const TMP = "/tmp/despensa-slides";
const C = { green: "#446B55", dark: "#26332B", sage: "#DDE8DC", ivory: "#FAF7F0", terra: "#B86345", muted: "#66736B", white: "#FFFFFF" };
const assetBytes = new Map();
for (const relative of [
  "docs/branding/despensa-logo.png",
  "docs/capturas/sprint1-estado_inicial.png",
  "docs/capturas/sprint3-final.png",
]) {
  assetBytes.set(`${ROOT}/${relative}`, await fs.readFile(`${ROOT}/${relative}`));
}

function box(slide, x, y, w, h, fill, radius = "rounded-xl") {
  return slide.shapes.add({ geometry: "roundRect", position: { left: x, top: y, width: w, height: h }, fill, line: { fill: "none", width: 0 }, borderRadius: radius });
}
function text(slide, value, x, y, w, h, size = 24, color = C.dark, bold = false, align = "left") {
  const shape = slide.shapes.add({ geometry: "textbox", position: { left: x, top: y, width: w, height: h }, fill: "none", line: { fill: "none", width: 0 } });
  shape.text = value;
  shape.text.style = { fontSize: size, fontFamily: "Aptos", color, bold, alignment: align, verticalAlignment: "middle" };
  return shape;
}
function title(slide, value, kicker) {
  if (kicker) text(slide, kicker.toUpperCase(), 72, 42, 600, 28, 14, C.terra, true);
  text(slide, value, 72, 78, 1136, 70, 36, C.green, true);
}
function footer(slide, n) {
  text(slide, "DESPENSA · PROYECTO FINAL", 72, 682, 500, 20, 11, C.muted, true);
  text(slide, String(n).padStart(2, "0"), 1140, 682, 68, 20, 11, C.muted, true, "right");
}
function addImage(slide, path, alt, x, y, w, h, fit = "contain") {
  return slide.images.add({ blob: assetBytes.get(path), contentType: "image/png", alt, fit, position: { left: x, top: y, width: w, height: h }, geometry: "roundRect", borderRadius: "rounded-xl" });
}
function bullet(slide, value, y, accent = C.green) {
  slide.shapes.add({ geometry: "ellipse", position: { left: 82, top: y + 9, width: 10, height: 10 }, fill: accent, line: { fill: "none", width: 0 } });
  text(slide, value, 108, y, 1030, 52, 22, C.dark, false);
}

const deck = Presentation.create({ slideSize: { width: 1280, height: 720 } });

// 1 — cover
{
  const s = deck.slides.add(); s.background.fill = C.ivory;
  box(s, 0, 0, 34, 720, C.green, "rounded-none");
  addImage(s, `${ROOT}/docs/branding/despensa-logo.png`, "Logotipo de Despensa", 780, 150, 390, 250);
  text(s, "DESPENSA", 74, 126, 620, 50, 16, C.terra, true);
  text(s, "Comprar mejor.\nDesperdiciar menos.", 74, 190, 650, 190, 54, C.green, true);
  text(s, "Inventario doméstico y cesta compartida", 78, 405, 620, 52, 24, C.dark);
  text(s, "Juan García · Ingeniería de Sistemas Móviles · 2026", 78, 610, 760, 34, 16, C.muted);
}

// 2 — problem
{
  const s = deck.slides.add(); s.background.fill = C.ivory; title(s, "Un problema doméstico cotidiano", "01 · Contexto");
  text(s, "Compras duplicadas", 82, 205, 310, 50, 28, C.terra, true);
  text(s, "Productos olvidados", 470, 205, 330, 50, 28, C.terra, true);
  text(s, "Listas desconectadas", 866, 205, 330, 50, 28, C.terra, true);
  text(s, "No sabemos qué hay realmente en casa.", 82, 285, 300, 100, 22, C.dark);
  text(s, "Las caducidades no se ven a tiempo.", 470, 285, 300, 100, 22, C.dark);
  text(s, "La compra no actualiza las existencias.", 866, 285, 300, 100, 22, C.dark);
  box(s, 82, 455, 1086, 116, C.sage);
  text(s, "Despensa conecta existencias, caducidad y compra en un único flujo compartido.", 130, 480, 990, 64, 30, C.green, true, "center"); footer(s, 2);
}

// 3 — solution
{
  const s = deck.slides.add(); s.background.fill = C.ivory; title(s, "El ciclo completo en cuatro pasos", "02 · Solución");
  const labels = [["1", "Registrar", "Productos, cantidades y fechas"], ["2", "Detectar", "Agotados y próximos a caducar"], ["3", "Comprar", "Cesta compartida en tiempo real"], ["4", "Reponer", "Actualizar inventario sin duplicados"]];
  labels.forEach((d, i) => { const x = 74 + i * 296; box(s, x, 205, 260, 300, i === 3 ? C.green : C.white); text(s, d[0], x + 24, 225, 52, 52, 36, i === 3 ? C.white : C.terra, true); text(s, d[1], x + 24, 306, 210, 44, 28, i === 3 ? C.white : C.green, true); text(s, d[2], x + 24, 368, 210, 86, 19, i === 3 ? C.white : C.dark); }); footer(s, 3);
}

// 4 — product
{
  const s = deck.slides.add(); s.background.fill = C.ivory; title(s, "Un MVP colaborativo y demostrable", "03 · Producto");
  addImage(s, `${ROOT}/docs/capturas/sprint3-final.png`, "Tablero GitHub al cierre del Sprint 3", 630, 168, 570, 430, "contain");
  bullet(s, "Autenticación y hogares con roles", 190);
  bullet(s, "Inventario con búsqueda, filtros y caducidad", 270);
  bullet(s, "Cesta compartida y compra atómica", 350);
  bullet(s, "Invitaciones, miembros y actividad", 430);
  bullet(s, "Modo Firebase y modo local", 510, C.terra); footer(s, 4);
}

// 5 — architecture
{
  const s = deck.slides.add(); s.background.fill = C.ivory; title(s, "Arquitectura simple, separada por responsabilidades", "04 · Técnica");
  const xs = [90, 410, 730, 1010];
  [["PRESENTATION", "Pantallas Material 3"], ["DOMAIN", "Entidades del negocio"], ["DATA / CORE", "Servicios y persistencia"], ["FIREBASE", "Auth + Firestore"]].forEach((d, i) => { box(s, xs[i], 240, i === 3 ? 190 : 250, 190, i === 3 ? C.green : C.white); text(s, d[0], xs[i] + 20, 270, i === 3 ? 150 : 210, 32, 19, i === 3 ? C.white : C.terra, true, "center"); text(s, d[1], xs[i] + 20, 325, i === 3 ? 150 : 210, 58, 20, i === 3 ? C.white : C.dark, false, "center"); if(i < 3) text(s, "→", xs[i] + (i === 2 ? 260 : 270), 300, 46, 46, 30, C.green, true, "center"); });
  text(s, "Flutter · Firebase Authentication · Cloud Firestore · SharedPreferences", 120, 500, 1040, 54, 24, C.green, true, "center"); footer(s, 5);
}

// 6 — scrum
{
  const s = deck.slides.add(); s.background.fill = C.ivory; title(s, "Cuatro sprints, un incremento verificable", "05 · Proceso");
  addImage(s, `${ROOT}/docs/capturas/sprint1-estado_inicial.png`, "Tablero al inicio del Sprint 1", 72, 180, 530, 330, "cover");
  addImage(s, `${ROOT}/docs/capturas/sprint3-final.png`, "Tablero al cierre del Sprint 3", 678, 180, 530, 330, "cover");
  text(s, "ANÁLISIS → BASE TÉCNICA → COLABORACIÓN → CALIDAD", 110, 555, 1060, 42, 27, C.green, true, "center");
  text(s, "45 issues · requisitos, código, pruebas y evidencias trazables", 110, 610, 1060, 30, 17, C.muted, false, "center"); footer(s, 6);
}

// 7 — quality
{
  const s = deck.slides.add(); s.background.fill = C.ivory; title(s, "La versión final supera la cadena de calidad", "06 · Validación");
  [["25/25", "pruebas Flutter"], ["0", "incidencias de análisis"], ["55,2 MB", "APK release"], ["4", "milestones"]].forEach((d, i) => { const x = 75 + i * 294; box(s, x, 205, 250, 200, i === 0 ? C.green : C.white); text(s, d[0], x + 15, 235, 220, 76, 44, i === 0 ? C.white : C.terra, true, "center"); text(s, d[1], x + 20, 325, 210, 42, 19, i === 0 ? C.white : C.dark, false, "center"); });
  box(s, 180, 470, 920, 100, C.sage); text(s, "Permisos por hogar · operaciones confirmadas · estados vacíos · sincronización", 215, 492, 850, 55, 23, C.green, true, "center"); footer(s, 7);
}

// 8 — demo
{
  const s = deck.slides.add(); s.background.fill = C.ivory; title(s, "Demostración: del producto agotado a la despensa", "07 · Recorrido");
  const items = ["1. Entrar y seleccionar hogar", "2. Localizar un producto agotado", "3. Añadirlo a la cesta", "4. Marcarlo como comprado", "5. Guardar la compra en inventario"];
  items.forEach((v, i) => { const y = 180 + i * 82; box(s, 95, y, 1040, 60, i === 4 ? C.green : C.white); text(s, v, 130, y + 8, 970, 44, 23, i === 4 ? C.white : C.dark, i === 4); }); footer(s, 8);
}

// 9 — close
{
  const s = deck.slides.add(); s.background.fill = C.green;
  text(s, "DESPENSA", 72, 70, 300, 30, 15, C.sage, true);
  text(s, "Una base sólida para\ncomprar con criterio.", 72, 150, 760, 170, 52, C.white, true);
  text(s, "Siguiente paso", 76, 400, 280, 32, 18, C.sage, true);
  text(s, "Notificaciones push · código de barras · modo offline avanzado · iOS", 76, 448, 1000, 86, 24, C.white);
  text(s, "Gracias", 76, 625, 300, 38, 24, C.sage, true);
}

await fs.mkdir(TMP, { recursive: true });
await fs.mkdir(`${ROOT}/docs/entrega`, { recursive: true });
for (const [i, slide] of deck.slides.items.entries()) {
  const png = await deck.export({ slide, format: "png", scale: 1 });
  await fs.writeFile(`${TMP}/slide-${String(i + 1).padStart(2, "0")}.png`, new Uint8Array(await png.arrayBuffer()));
  const layout = await slide.export({ format: "layout" });
  await fs.writeFile(`${TMP}/slide-${String(i + 1).padStart(2, "0")}.layout.json`, await layout.text());
}
const montage = await deck.export({ format: "webp", montage: true, scale: 1 });
await fs.writeFile(`${TMP}/montage.webp`, new Uint8Array(await montage.arrayBuffer()));
const pptx = await PresentationFile.exportPptx(deck);
await pptx.save(OUT);
console.log(OUT);
