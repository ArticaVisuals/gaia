// ─── Gaia Design System Generator — code.js ───────────────────────────────
// Runs inside Figma. Reads all local variables, paint styles, text styles,
// effect styles, and components, then lays them out on a new "Design System" page.

figma.showUI(__html__, { width: 360, height: 520, title: 'Design System Generator' });

// ─── Message router ───────────────────────────────────────────────────────
figma.ui.onmessage = async (msg) => {
  if (msg.type === 'getCounts') {
    sendCounts();
  }
  if (msg.type === 'generate') {
    try {
      await generateDesignSystem(msg.options);
      figma.ui.postMessage({ type: 'done' });
    } catch (e) {
      figma.ui.postMessage({ type: 'error', text: String(e) });
    }
  }
  if (msg.type === 'close') {
    figma.closePlugin();
  }
};

function sendCounts() {
  try {
    const collections = figma.variables.getLocalVariableCollections();
    const allVars     = figma.variables.getLocalVariables();
    const colorVars   = allVars.filter(v => v.resolvedType === 'COLOR').length;
    const compSets    = figma.root.findAll(n => n.type === 'COMPONENT_SET').length;
    const standalone  = figma.root.findAll(n => n.type === 'COMPONENT' && n.parent.type !== 'COMPONENT_SET').length;
    figma.ui.postMessage({
      type: 'counts',
      variables:    colorVars,
      colorStyles:  figma.getLocalPaintStyles().length,
      textStyles:   figma.getLocalTextStyles().length,
      effectStyles: figma.getLocalEffectStyles().length,
      components:   compSets + standalone,
      collections:  collections.length,
    });
  } catch(e) {
    figma.ui.postMessage({
      type: 'counts',
      variables: 0, colorStyles: figma.getLocalPaintStyles().length,
      textStyles: figma.getLocalTextStyles().length,
      effectStyles: figma.getLocalEffectStyles().length,
      components: 0, collections: 0,
    });
  }
}

// ─── Colour helpers ───────────────────────────────────────────────────────
function rgbToHex(r, g, b) {
  const h = v => Math.round(v * 255).toString(16).padStart(2, '0');
  return '#' + h(r) + h(g) + h(b);
}

function luminance({ r, g, b }) {
  const ch = v => (v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4));
  return 0.2126 * ch(r) + 0.7152 * ch(g) + 0.0722 * ch(b);
}

function textOnBg(color) {
  return luminance(color) > 0.35
    ? { r: 0.15, g: 0.13, b: 0.14 }
    : { r: 0.99, g: 0.99, b: 0.97 };
}

// ─── Font loading ─────────────────────────────────────────────────────────
// NOTE: Inter on Figma uses "Semi Bold" (with space), not "SemiBold"
async function loadCoreFonts() {
  const faces = [
    { family: 'Inter', style: 'Regular' },
    { family: 'Inter', style: 'Medium' },
    { family: 'Inter', style: 'Semi Bold' },
    { family: 'Inter', style: 'Bold' },
  ];
  for (const f of faces) {
    await figma.loadFontAsync(f).catch(() => {});
  }
}

async function loadStyleFonts(styles) {
  const seen = new Set();
  for (const s of styles) {
    const key = `${s.fontName.family}::${s.fontName.style}`;
    if (!seen.has(key)) {
      seen.add(key);
      await figma.loadFontAsync(s.fontName).catch(() => {});
    }
  }
}

// ─── Constants ────────────────────────────────────────────────────────────
const LABEL_CLR  = { r: 0.49, g: 0.47, b: 0.51 };
const INK        = { r: 0.15, g: 0.13, b: 0.14 };
const MUTED      = { r: 0.60, g: 0.58, b: 0.62 };
const BORDER_CLR = { r: 0.85, g: 0.83, b: 0.81 };
const CANVAS_W   = 1200; // width for wrapping grids
const COMPONENT_FAMILY_ORDER = ['Brand & identity', 'Controls', 'Status & utilities', 'Card families', 'Media', 'Navigation', 'Map', 'General'];

// ─── Low-level node builders ──────────────────────────────────────────────
function txt(content, size, style, color) {
  style = style || 'Regular';
  color = color || INK;
  const t = figma.createText();
  t.fontName = { family: 'Inter', style: style };
  t.fontSize = size;
  t.fills = [{ type: 'SOLID', color: color }];
  t.characters = String(content);
  return t;
}

// Auto-layout frame that sizes to its content
function autoFrame(name, direction, gap) {
  direction = direction || 'VERTICAL';
  gap = (gap === undefined) ? 16 : gap;
  const f = figma.createFrame();
  f.name = name;
  f.layoutMode = direction;
  f.itemSpacing = gap;
  f.counterAxisSizingMode = 'AUTO';
  f.primaryAxisSizingMode = 'AUTO';
  f.fills = [];
  return f;
}

// Wrapping horizontal grid — needs a fixed width to know where to wrap
function wrapGrid(name, colGap, rowGap, fixedWidth) {
  colGap    = colGap    || 12;
  rowGap    = rowGap    || 20;
  fixedWidth = fixedWidth || CANVAS_W;
  const f = figma.createFrame();
  f.name = name;
  f.layoutMode = 'HORIZONTAL';
  f.layoutWrap = 'WRAP';                  // ← correct Figma API property
  f.itemSpacing = colGap;                 // column gap
  f.counterAxisSpacing = rowGap;          // row gap (only valid when layoutWrap = 'WRAP')
  f.primaryAxisSizingMode = 'FIXED';
  f.counterAxisSizingMode = 'AUTO';
  f.fills = [];
  f.resize(fixedWidth, 10);              // give it width so wrap knows where to break
  return f;
}

// ─── Section chrome ───────────────────────────────────────────────────────
function sectionLabel(text) {
  const t = txt(text.toUpperCase(), 11, 'Bold', LABEL_CLR);
  t.name = 'Label';
  t.letterSpacing = { value: 1.5, unit: 'PIXELS' };
  return t;
}

function hairline() {
  const l = figma.createLine();
  l.resize(CANVAS_W, 0);
  l.strokes = [{ type: 'SOLID', color: BORDER_CLR, opacity: 0.6 }];
  l.strokeWeight = 1;
  l.name = 'Hairline';
  return l;
}

function sectionWrapper(title) {
  const wrap = autoFrame(title, 'VERTICAL', 32);
  wrap.paddingBottom = 16;
  const head = autoFrame('Head', 'VERTICAL', 12);
  head.appendChild(sectionLabel(title));
  head.appendChild(hairline());
  wrap.appendChild(head);
  return wrap;
}

// ─── SWATCH helper ────────────────────────────────────────────────────────
function colorSwatch(colorRgb, alpha, firstName, subtitleLine) {
  const card = autoFrame(firstName, 'VERTICAL', 5);

  // Always strip 'a' from color — Figma fills only accept {r,g,b} in .color;
  // opacity goes in the Paint object's own .opacity field.
  const pureRgb  = { r: colorRgb.r, g: colorRgb.g, b: colorRgb.b };
  const opacity  = (alpha !== undefined && alpha !== null) ? alpha
                 : (colorRgb.a !== undefined ? colorRgb.a : 1);

  // Swatch box (plain frame — no auto-layout so absolute badge works)
  const box = figma.createFrame();
  box.name = 'Swatch';
  box.resize(76, 76);
  box.cornerRadius = 12;
  box.fills = [{ type: 'SOLID', color: pureRgb, opacity: opacity }];
  box.strokes = [{ type: 'SOLID', color: { r: 0, g: 0, b: 0 }, opacity: 0.08 }];
  box.strokeWeight = 1;
  box.strokeAlign = 'INSIDE';

  // Hex badge pinned inside the swatch
  const hexStr  = rgbToHex(pureRgb.r, pureRgb.g, pureRgb.b);
  const badge   = txt(hexStr, 9, 'Medium', textOnBg(pureRgb));
  badge.name    = 'HexBadge';
  badge.x = 5;
  badge.y = box.height - 18;
  box.appendChild(badge);

  const name1 = txt(firstName, 11, 'Medium', INK);
  card.appendChild(box);
  card.appendChild(name1);
  if (subtitleLine) {
    card.appendChild(txt(subtitleLine, 9, 'Regular', MUTED));
  }
  return card;
}

// ─── GENERATE ─────────────────────────────────────────────────────────────
async function generateDesignSystem(opts) {
  post('status', 'Loading fonts…');
  await loadCoreFonts();

  // Get / create the target page
  var page = null;
  for (var i = 0; i < figma.root.children.length; i++) {
    if (figma.root.children[i].name === '🎨 Design System') {
      page = figma.root.children[i];
      break;
    }
  }
  if (page) {
    var kids = page.children.slice();
    for (var k = 0; k < kids.length; k++) kids[k].remove();
  } else {
    page = figma.createPage();
    page.name = '🎨 Design System';
    figma.root.insertChild(1, page);
  }
  figma.currentPage = page;
  page.backgrounds = [{ type: 'SOLID', color: { r: 0.988, g: 0.980, b: 0.957 } }];

  // Root vertical frame
  const root = autoFrame('Canvas', 'VERTICAL', 80);
  root.paddingTop = root.paddingBottom = 80;
  root.paddingLeft = root.paddingRight = 80;
  root.fills = [];
  page.appendChild(root);

  root.appendChild(await buildHeader());

  if (opts.variables) {
    post('status', 'Laying out variables…');
    const s = await buildVariables();
    if (s) root.appendChild(s);
  }

  if (opts.colorStyles) {
    post('status', 'Laying out color styles…');
    const s = await buildColorStyles();
    if (s) root.appendChild(s);
  }

  if (opts.textStyles) {
    post('status', 'Laying out typography…');
    const s = await buildTextStyles();
    if (s) root.appendChild(s);
  }

  if (opts.effectStyles) {
    post('status', 'Laying out effects…');
    const s = await buildEffectStyles();
    if (s) root.appendChild(s);
  }

  if (opts.components) {
    post('status', 'Laying out components…');
    const s = await buildComponents();
    if (s) root.appendChild(s);
  }

  figma.viewport.scrollAndZoomIntoView([root]);
}

function post(type, text) {
  figma.ui.postMessage({ type: type, text: text });
}

// ─── HEADER ───────────────────────────────────────────────────────────────
async function buildHeader() {
  const wrap  = autoFrame('Header', 'VERTICAL', 10);
  const title = txt('Design System', 56, 'Bold', INK);
  title.name  = 'Title';
  const date  = new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });
  const sub   = txt(figma.root.name + '  ·  Generated ' + date, 16, 'Regular', MUTED);
  sub.name    = 'Subtitle';
  wrap.appendChild(title);
  wrap.appendChild(sub);
  return wrap;
}

// ─── VARIABLES ────────────────────────────────────────────────────────────
async function buildVariables() {
  var collections, allVars;
  try {
    collections = figma.variables.getLocalVariableCollections();
    allVars     = figma.variables.getLocalVariables();
  } catch(e) {
    return null;
  }
  if (!collections.length) return null;

  const section = sectionWrapper('Variables');

  for (var ci = 0; ci < collections.length; ci++) {
    const col    = collections[ci];
    const modeId = col.modes[0].modeId;
    const vars   = allVars.filter(function(v) { return v.variableCollectionId === col.id; });
    const colorV = vars.filter(function(v) { return v.resolvedType === 'COLOR'; });
    const floatV = vars.filter(function(v) { return v.resolvedType === 'FLOAT'; });
    const otherV = vars.filter(function(v) { return v.resolvedType !== 'COLOR' && v.resolvedType !== 'FLOAT'; });

    const colWrap = autoFrame(col.name, 'VERTICAL', 20);

    // Title row
    const colHead = autoFrame('ColHead', 'HORIZONTAL', 12);
    colHead.counterAxisAlignItems = 'CENTER';
    colHead.appendChild(txt(col.name, 18, 'Semi Bold', INK));
    colHead.appendChild(txt(col.modes.length + ' mode' + (col.modes.length > 1 ? 's' : ''), 11, 'Regular', MUTED));
    colWrap.appendChild(colHead);

    // Color vars → wrapping swatch grid
    if (colorV.length) {
      const grid = wrapGrid('Color Vars', 12, 20);

      for (var vi = 0; vi < colorV.length; vi++) {
        const v   = colorV[vi];
        const raw = v.valuesByMode[modeId];
        var color = null;

        if (raw && typeof raw === 'object' && 'r' in raw) {
          color = raw;
        } else if (raw && raw.type === 'VARIABLE_ALIAS') {
          try {
            const aliasVar = figma.variables.getVariableById(raw.id);
            if (aliasVar) {
              const aliasRaw = aliasVar.valuesByMode[Object.keys(aliasVar.valuesByMode)[0]];
              if (aliasRaw && typeof aliasRaw === 'object' && 'r' in aliasRaw) color = aliasRaw;
            }
          } catch(e2) {}
        }
        if (!color) continue;

        const shortName = v.name.split('/').pop();
        const swatch    = colorSwatch(color, color.a, shortName, null);
        grid.appendChild(swatch);
      }
      colWrap.appendChild(grid);
    }

    // Float vars → list
    if (floatV.length) {
      const numWrap = autoFrame('Numbers', 'VERTICAL', 0);
      numWrap.appendChild(txt('Numbers & Spacing', 12, 'Semi Bold', INK));
      for (var fi = 0; fi < floatV.length; fi++) {
        const v   = floatV[fi];
        const val = v.valuesByMode[modeId];
        const row = autoFrame(v.name, 'HORIZONTAL', 16);
        row.counterAxisAlignItems = 'CENTER';
        row.paddingTop = row.paddingBottom = 6;
        row.appendChild(txt(v.name.split('/').pop(), 12, 'Regular', INK));
        // Bar
        const bar = figma.createFrame();
        bar.name = 'Bar';
        bar.cornerRadius = 100;
        bar.fills = [{ type: 'SOLID', color: { r: 0.41, g: 0.48, b: 0.36 }, opacity: 0.2 }];
        const barW = typeof val === 'number' ? Math.min(Math.max(val, 4), 200) : 32;
        bar.resize(barW, 8);
        row.appendChild(bar);
        row.appendChild(txt(typeof val === 'number' ? val.toFixed(0) + 'px' : String(val), 12, 'Regular', MUTED));
        numWrap.appendChild(row);
      }
      colWrap.appendChild(numWrap);
    }

    // Other vars (strings, booleans)
    if (otherV.length) {
      const otherWrap = autoFrame('Other', 'VERTICAL', 6);
      otherWrap.appendChild(txt('Other', 12, 'Semi Bold', INK));
      for (var oi = 0; oi < otherV.length; oi++) {
        const v   = otherV[oi];
        const val = String(v.valuesByMode[modeId]);
        const row = autoFrame(v.name, 'HORIZONTAL', 12);
        row.appendChild(txt(v.name.split('/').pop(), 11, 'Regular', INK));
        row.appendChild(txt(val, 11, 'Regular', MUTED));
        otherWrap.appendChild(row);
      }
      colWrap.appendChild(otherWrap);
    }

    section.appendChild(colWrap);
  }

  return section;
}

// ─── COLOR STYLES ─────────────────────────────────────────────────────────
async function buildColorStyles() {
  const styles = figma.getLocalPaintStyles();
  if (!styles.length) return null;

  const section = sectionWrapper('Color Styles');
  const groups  = {};

  for (var i = 0; i < styles.length; i++) {
    const s   = styles[i];
    const cat = s.name.indexOf('/') > -1 ? s.name.split('/')[0] : 'General';
    if (!groups[cat]) groups[cat] = [];
    groups[cat].push(s);
  }

  for (var cat in groups) {
    const list  = groups[cat];
    const group = autoFrame(cat, 'VERTICAL', 16);
    group.appendChild(txt(cat, 14, 'Semi Bold', INK));

    const grid = wrapGrid('grid', 12, 20);
    for (var j = 0; j < list.length; j++) {
      const s     = list[j];
      const solid = null;
      var paint   = null;
      for (var p = 0; p < s.paints.length; p++) {
        if (s.paints[p].type === 'SOLID') { paint = s.paints[p]; break; }
      }
      if (!paint) continue;
      // paint.color is always {r,g,b} from Figma styles (no .a), opacity is separate
      grid.appendChild(colorSwatch({ r: paint.color.r, g: paint.color.g, b: paint.color.b }, paint.opacity, s.name.split('/').pop(), null));
    }

    group.appendChild(grid);
    section.appendChild(group);
  }

  return section;
}

// ─── TEXT STYLES ──────────────────────────────────────────────────────────
async function buildTextStyles() {
  const styles = figma.getLocalTextStyles();
  if (!styles.length) return null;

  post('status', 'Loading text style fonts…');
  await loadStyleFonts(styles);

  const section = sectionWrapper('Typography');
  const groups  = {};

  for (var i = 0; i < styles.length; i++) {
    const s   = styles[i];
    const cat = s.name.indexOf('/') > -1 ? s.name.split('/')[0] : 'General';
    if (!groups[cat]) groups[cat] = [];
    groups[cat].push(s);
  }

  for (var cat in groups) {
    const list  = groups[cat];
    const group = autoFrame(cat, 'VERTICAL', 0);

    // Section group title (standalone text, no padding)
    group.appendChild(txt(cat, 14, 'Semi Bold', INK));

    for (var j = 0; j < list.length; j++) {
      const s   = list[j];
      const row = figma.createFrame();
      row.name  = s.name;
      row.layoutMode = 'HORIZONTAL';
      row.itemSpacing = 32;
      row.paddingTop = row.paddingBottom = 16;
      row.paddingLeft = row.paddingRight = 0;
      row.counterAxisSizingMode = 'AUTO';
      row.primaryAxisSizingMode = 'AUTO';
      row.fills       = j % 2 === 0 ? [{ type: 'SOLID', color: { r: 0, g: 0, b: 0 }, opacity: 0.02 }] : [];
      row.cornerRadius = 6;

      // Sample text
      var sample;
      try {
        sample = figma.createText();
        sample.fontName  = s.fontName;
        sample.fontSize  = Math.min(s.fontSize, 36);
        sample.fills     = [{ type: 'SOLID', color: INK }];
        sample.characters = 'The quick brown fox';
        sample.name      = 'Sample';
        sample.textAutoResize = 'WIDTH_AND_HEIGHT';
      } catch (fe) {
        sample = txt('(font unavailable)', 12, 'Regular', MUTED);
      }

      // Meta
      const meta = autoFrame('Meta', 'VERTICAL', 3);
      meta.counterAxisSizingMode = 'FIXED';
      meta.primaryAxisSizingMode = 'AUTO';
      meta.resize(200, 10);
      meta.appendChild(txt(s.name.split('/').pop(), 12, 'Semi Bold', INK));
      meta.appendChild(txt(s.fontName.family + ' · ' + s.fontName.style + ' · ' + s.fontSize + 'px', 10, 'Regular', MUTED));

      var lhStr = 'auto';
      if (s.lineHeight && s.lineHeight.unit === 'PIXELS')  lhStr = s.lineHeight.value + 'px';
      if (s.lineHeight && s.lineHeight.unit === 'PERCENT') lhStr = s.lineHeight.value + '%';
      meta.appendChild(txt('lh: ' + lhStr, 10, 'Regular', MUTED));

      row.appendChild(sample);
      row.appendChild(meta);
      group.appendChild(row);
    }

    section.appendChild(group);
  }

  return section;
}

// ─── EFFECT STYLES ────────────────────────────────────────────────────────
async function buildEffectStyles() {
  const styles = figma.getLocalEffectStyles();
  if (!styles.length) return null;

  const section = sectionWrapper('Effects & Shadows');
  const grid    = wrapGrid('Grid', 32, 32);

  for (var i = 0; i < styles.length; i++) {
    const s    = styles[i];
    const card = autoFrame(s.name, 'VERTICAL', 12);

    const preview = figma.createFrame();
    preview.name         = 'Preview';
    preview.resize(100, 100);
    preview.cornerRadius = 20;
    preview.fills        = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }];
    try { preview.effects = s.effects; } catch(e) {}

    card.appendChild(preview);
    card.appendChild(txt(s.name.split('/').pop(), 11, 'Regular', INK));
    if (s.description) card.appendChild(txt(s.description, 10, 'Regular', MUTED));
    grid.appendChild(card);
  }

  section.appendChild(grid);
  return section;
}

// ─── COMPONENTS ───────────────────────────────────────────────────────────
async function buildComponents() {
  const sets       = figma.root.findAll(function(n) { return n.type === 'COMPONENT_SET'; });
  const standalone = figma.root.findAll(function(n) { return n.type === 'COMPONENT' && n.parent.type !== 'COMPONENT_SET'; });
  const all        = sets.concat(standalone);
  if (!all.length) return null;

  const section = sectionWrapper('Components');
  const groups  = {};

  for (var i = 0; i < all.length; i++) {
    const c   = all[i];
    const cat = c.name.indexOf('/') > -1 ? c.name.split('/')[0] : 'General';
    if (!groups[cat]) groups[cat] = [];
    groups[cat].push(c);
  }

  const cats = Object.keys(groups).sort(function(a, b) {
    const ai = COMPONENT_FAMILY_ORDER.indexOf(a);
    const bi = COMPONENT_FAMILY_ORDER.indexOf(b);
    if (ai !== bi) {
      return (ai === -1 ? 999 : ai) - (bi === -1 ? 999 : bi);
    }
    return a.localeCompare(b);
  });

  for (var ci = 0; ci < cats.length; ci++) {
    const cat  = cats[ci];
    const list = groups[cat].slice().sort(function(a, b) {
      return a.name.localeCompare(b.name);
    });
    const group = autoFrame(cat, 'VERTICAL', 20);
    group.appendChild(txt(cat, 14, 'Semi Bold', INK));

    const grid = wrapGrid('Grid', 20, 20);

    for (var j = 0; j < Math.min(list.length, 30); j++) {
      const comp = list[j];
      const card = figma.createFrame();
      card.name  = comp.name;
      card.layoutMode = 'VERTICAL';
      card.itemSpacing = 8;
      card.paddingTop = card.paddingBottom = card.paddingLeft = card.paddingRight = 14;
      card.counterAxisSizingMode = 'AUTO';
      card.primaryAxisSizingMode = 'AUTO';
      card.counterAxisAlignItems = 'CENTER';
      card.fills       = [{ type: 'SOLID', color: { r: 1, g: 1, b: 1 } }];
      card.cornerRadius = 12;
      card.strokes     = [{ type: 'SOLID', color: BORDER_CLR }];
      card.strokeWeight = 1;
      card.strokeAlign  = 'OUTSIDE';

      // Instance preview
      try {
        var src = comp;
        if (comp.type === 'COMPONENT_SET') {
          src = comp.defaultVariant || comp.children[0];
        }
        if (src) {
          const inst = src.createInstance();
          const MAX  = 140;
          if (inst.width > MAX || inst.height > MAX) {
            inst.rescale(MAX / Math.max(inst.width, inst.height));
          }
          const holder = figma.createFrame();
          holder.name  = 'Preview';
          holder.fills = [{ type: 'SOLID', color: { r: 0.96, g: 0.95, b: 0.94 } }];
          holder.cornerRadius = 8;
          holder.resize(Math.max(inst.width + 20, 110), inst.height + 20);
          holder.layoutMode = 'VERTICAL';
          holder.primaryAxisAlignItems  = 'CENTER';
          holder.counterAxisAlignItems  = 'CENTER';
          holder.primaryAxisSizingMode  = 'FIXED';
          holder.counterAxisSizingMode  = 'FIXED';
          holder.appendChild(inst);
          card.appendChild(holder);
        }
      } catch(e) {}

      const shortName = comp.name.split('/').pop();
      const label     = txt(shortName, 11, 'Regular', INK);
      label.textAlignHorizontal = 'CENTER';
      label.textAutoResize      = 'WIDTH_AND_HEIGHT';
      card.appendChild(label);

      if (comp.type === 'COMPONENT_SET') {
        const chip = txt(comp.children.length + ' variants', 9, 'Regular', MUTED);
        chip.textAlignHorizontal = 'CENTER';
        chip.textAutoResize      = 'WIDTH_AND_HEIGHT';
        card.appendChild(chip);
      }

      grid.appendChild(card);
    }

    group.appendChild(grid);
    section.appendChild(group);
  }

  return section;
}
