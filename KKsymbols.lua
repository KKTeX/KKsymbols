luatexbase.provides_module{
  name     = 'KKsymbols',
  date     = '2026/06/26',
  version  = '2.2.2',
}

KKS = KKS or {}

function KKS.narrow_ones(s)
  if s:match("^%d%d+$") then
    local res = {}
    for i = 1, #s do
      local char = s:sub(i,i)
      if char == "1" then
        table.insert(res, 
          "{\\setbox0=\\hbox{1}\\hbox to 0.7\\wd0{\\hss\\box0\\hss}}"
        )
      else
        table.insert(res, char)
      end
    end
    tex.print(table.concat(res))
  else
    tex.print(s)
  end
end

-- Return true only when the fully expanded TeX argument is exactly one
-- lowercase ASCII letter.  TeX performs the expansion; Lua deliberately keeps
-- the classification small and predictable (not locale dependent).
function KKS.is_lowercase_ascii(s)
  return s:match("^[a-z]$") ~= nil
end

function KKS.lowercase_ascii_flag(s)
  return KKS.is_lowercase_ascii(s) and 1 or 0
end

-- Actual glyph-ink bounds for the shrink-only visual overflow guard.
--
-- Use LuaTeX's documented fontloader API instead of luaotfload's internal
-- shared.rawdata tables.  The latter can differ between cache states and TeX
-- Live releases.  Cache the scaled result by font id and glyph index so a font
-- file is normally opened only once for each distinct glyph used by a guard.
local visual_bbox_cache = {}

local glyph_id = node.id("glyph")
local hlist_id = node.id("hlist")
local vlist_id = node.id("vlist")
local rule_id = node.id("rule")
local glue_id = node.id("glue")
local kern_id = node.id("kern")
local disc_id = node.id("disc")
local penalty_id = node.id("penalty")
local dir_id = node.id("dir")
local whatsit_id = node.id("whatsit")
local colorstack_subtype = node.subtype("pdf_colorstack")
local userdefined_subtype = node.subtype("user_defined")
local pdfsave_subtype = node.subtype("pdf_save")
local pdfrestore_subtype = node.subtype("pdf_restore")
local running_rule = -1073741824

local function fontloader_field(object, key)
  local ok, value = pcall(function()
    return object[key]
  end)
  return ok and value or nil
end

local function normalized_font_name(name)
  if type(name) ~= "string" then
    return nil
  end
  return name:lower():gsub("[^%w]", "")
end

local function compatible_font_name(a, b)
  a, b = normalized_font_name(a), normalized_font_name(b)
  if not a or not b then
    return false
  end
  if a == b then
    return true
  end
  -- macOS Hiragino Pro/ProN collection aliases select the same family/weight
  -- under names that differ only by the JIS2004 "N" marker.  The glyph-level
  -- Unicode and advance checks below still have to succeed.
  return a:gsub("pron", "pro") == b:gsub("pron", "pro")
end

local function loaded_face_matches(loaded, expected_names)
  local actual_names = {
    fontloader_field(loaded, "fontname"),
    fontloader_field(loaded, "fullname"),
    fontloader_field(loaded, "familyname"),
  }
  for i = 1, #actual_names do
    for j = 1, #expected_names do
      if compatible_font_name(actual_names[i], expected_names[j]) then
        return true
      end
    end
  end
  return false
end

local function open_font_file(tfm)
  if not tfm or not tfm.filename then
    return nil
  end
  local filename = tfm.filename:lower()
  local is_collection = filename:match("%.ttc$")
    or filename:match("%.otc$") or filename:match("%.dfont$")
  if not is_collection then
    local ok, loaded = pcall(fontloader.open, tfm.filename)
    if ok and loaded then
      return loaded
    end
    return nil
  end
  local names = {}
  local seen = {}
  local function add_name(name)
    if name and name ~= "" and not seen[name] then
      seen[name] = true
      names[#names + 1] = name
    end
  end
  -- Prefer the collection's official face name corresponding to luaotfload's
  -- numeric subfont index, then try the names stored in the live font table.
  local info_ok, info = pcall(fontloader.info, tfm.filename)
  if info_ok and type(info) == "table" and type(tfm.subfont) == "number" then
    local face = info[tfm.subfont + 1] or info[tfm.subfont]
    if type(face) == "table" then
      add_name(face.fontname)
      add_name(face.fullname)
    end
  end
  add_name(tfm.fontname)
  add_name(tfm.psname)
  add_name(tfm.fullname)
  for _, name in ipairs(names) do
    local ok, loaded = pcall(fontloader.open, tfm.filename, name)
    if ok and loaded then
      if loaded_face_matches(loaded, names) then
        return loaded
      end
      pcall(fontloader.close, loaded)
    end
  end
  -- A collection needs an explicit face name.  Falling back to its first face
  -- can silently measure a different font from the one LuaTeX is rendering.
  return nil
end

local function glyph_ink_bbox(font_id, char)
  local tfm = font.getfont(font_id)
  if not tfm or tfm.type == "virtual" or not tfm.characters then
    return nil
  end
  -- Font expansion and slant are affine and can be reflected in the box.
  -- Synthetic emboldening changes the outline itself, so fail open there.
  if tfm.embolden and tfm.embolden ~= 0 then
    return nil
  end
  local character = tfm.characters[char]
  local index = character and character.index
  if index == nil then
    return nil
  end
  local font_cache = visual_bbox_cache[font_id]
  if not font_cache then
    font_cache = {}
    visual_bbox_cache[font_id] = font_cache
  end
  local cached = font_cache[index]
  if cached ~= nil then
    return cached or nil
  end

  local loaded = open_font_file(tfm)
  if not loaded then
    font_cache[index] = false
    return nil
  end
  local debug_reason
  local ok, result = pcall(function()
    local glyph_source = loaded
    if index < loaded.glyphmin or index > loaded.glyphmax then
      glyph_source = nil
      if loaded.subfonts then
        for i = 1, #loaded.subfonts do
          local subfont = loaded.subfonts[i]
          if index >= subfont.glyphmin and index <= subfont.glyphmax then
            local glyph_ok, candidate = pcall(function()
              return subfont.glyphs[index]
            end)
            if glyph_ok and candidate then
              glyph_source = subfont
              break
            end
          end
        end
      end
      if not glyph_source then
        debug_reason = string.format("index=%s range=[%s,%s] subfonts=%s",
          tostring(index), tostring(loaded.glyphmin), tostring(loaded.glyphmax),
          tostring(loaded.subfonts ~= nil))
        return nil
      end
    end
    local glyph = glyph_source.glyphs and glyph_source.glyphs[index]
    local bbox = glyph and glyph.boundingbox
    local units = glyph_source.units_per_em
    if not units or units == 0 then
      units = loaded.units_per_em
    end
    if not units or units == 0 then
      units = tfm.units_per_em
    end
    if not bbox or not units or units == 0 then
      debug_reason = string.format("glyph=%s bbox=%s units=%s range=[%s,%s] subfonts=%s",
        tostring(glyph ~= nil), tostring(bbox ~= nil), tostring(units),
        tostring(glyph_source.glyphmin), tostring(glyph_source.glyphmax),
        tostring(loaded.subfonts ~= nil))
      return nil
    end
    local scale = tfm.size / units
    local extend = (tfm.extend or 1000) / 1000
    local slant = (tfm.slant or 0) / 1000
    -- A CID-keyed CFF can expose subfont glyphs by CID while LuaTeX's live
    -- character table stores a glyph index.  Accept the lookup only when the
    -- record identifies the same Unicode character and scaled advance.  Any
    -- ambiguity must preserve the legacy rendering (fail open), never shrink
    -- from a plausible but unrelated glyph box.
    local glyph_unicode = fontloader_field(glyph, "unicode")
    if type(glyph_unicode) == "number" and glyph_unicode >= 0
        and glyph_unicode ~= char then
      debug_reason = string.format("glyph unicode mismatch U+%04X != U+%04X",
        glyph_unicode, char)
      return nil
    end
    local glyph_width = fontloader_field(glyph, "width")
    if type(glyph_width) == "number" and type(character.width) == "number" then
      local loaded_width = glyph_width * scale * extend
      local tolerance = math.max(2, math.abs(character.width) * 0.02)
      if math.abs(loaded_width - character.width) > tolerance then
        debug_reason = string.format("glyph width mismatch %.2f != %.2f",
          loaded_width, character.width)
        return nil
      end
    end
    local xmin, ymin = math.huge, math.huge
    local xmax, ymax = -math.huge, -math.huge
    for _, x in ipairs({ bbox[1], bbox[3] }) do
      for _, y in ipairs({ bbox[2], bbox[4] }) do
        local tx = (extend * x + slant * y) * scale
        local ty = y * scale
        xmin, xmax = math.min(xmin, tx), math.max(xmax, tx)
        ymin, ymax = math.min(ymin, ty), math.max(ymax, ty)
      end
    end
    return { xmin, ymin, xmax, ymax }
  end)
  pcall(fontloader.close, loaded)
  if not ok or not result then
    if KKS.visual_debug then
      texio.write_nl("term and log", "KKS-VISUAL fontloader failure "
        .. tostring(debug_reason or result))
    end
    font_cache[index] = false
    return nil
  end
  font_cache[index] = result
  return result
end

local function include_bbox(bounds, xmin, ymin, xmax, ymax)
  bounds.xmin = math.min(bounds.xmin, xmin)
  bounds.ymin = math.min(bounds.ymin, ymin)
  bounds.xmax = math.max(bounds.xmax, xmax)
  bounds.ymax = math.max(bounds.ymax, ymax)
  bounds.found = true
end

local function effective_glue_width(n, parent)
  local width = n.width or 0
  if not parent then
    return width
  end
  local sign = parent.glue_sign or 0
  local order = parent.glue_order or 0
  local set = parent.glue_set or 0
  if sign == 1 and (n.stretch_order or 0) == order then
    width = width + set * (n.stretch or 0)
  elseif sign == 2 and (n.shrink_order or 0) == order then
    width = width - set * (n.shrink or 0)
  end
  return width
end

local measure_hlist

local function measure_vlist(box, x0, y0, bounds)
  -- Star-path alphanumerics are horizontal material.  Empty nested vlists
  -- (notably phantoms) are harmless, but arbitrary vertical material needs a
  -- full page-builder model and therefore fails open deterministically.
  if not box.head then
    return true
  end
  for n in node.traverse(box.head) do
    if n.id == glue_id or n.id == kern_id or n.id == penalty_id
        or n.id == dir_id then
      -- dimension-only / non-ink nodes
    elseif n.id == hlist_id and not n.head then
      -- empty phantom box
    elseif n.id == rule_id and (n.width or 0) == 0 then
      -- zero-width phantom rule
    else
      return false
    end
  end
  return true
end

measure_hlist = function(box, x0, y0, bounds)
  local x = x0
  if not box.head then
    return true
  end
  for n in node.traverse(box.head) do
    if n.id == glyph_id then
      local bbox = glyph_ink_bbox(n.font, n.char)
      if not bbox then
        if KKS.visual_debug then
          local tfm = font.getfont(n.font)
          texio.write_nl("term and log", string.format(
            "KKS-VISUAL missing glyph bbox font=%s char=U+%04X file=%s name=%s type=%s index=%s",
            tostring(n.font), n.char, tostring(tfm and tfm.filename),
            tostring(tfm and tfm.fontname), tostring(tfm and tfm.type),
            tostring(tfm and tfm.characters and tfm.characters[n.char]
              and tfm.characters[n.char].index)))
        end
        return false
      end
      local xoffset = n.xoffset or 0
      local yoffset = n.yoffset or 0
      include_bbox(bounds,
        x + xoffset + bbox[1], y0 + yoffset + bbox[2],
        x + xoffset + bbox[3], y0 + yoffset + bbox[4])
      x = x + (n.width or 0)
    elseif n.id == kern_id then
      x = x + (n.kern or 0)
    elseif n.id == glue_id then
      if n.leader then
        return false
      end
      x = x + effective_glue_width(n, box)
    elseif n.id == hlist_id then
      if not measure_hlist(n, x, y0 - (n.shift or 0), bounds) then
        return false
      end
      x = x + (n.width or 0)
    elseif n.id == vlist_id then
      if not measure_vlist(n, x, y0 - (n.shift or 0), bounds) then
        return false
      end
      x = x + (n.width or 0)
    elseif n.id == rule_id then
      local width = n.width or 0
      if width == running_rule or (n.height or 0) == running_rule
          or (n.depth or 0) == running_rule then
        return false
      end
      if width > 0 and ((n.height or 0) > 0 or (n.depth or 0) > 0) then
        include_bbox(bounds, x, y0 - (n.depth or 0),
          x + width, y0 + (n.height or 0))
      end
      x = x + width
    elseif n.id == disc_id then
      if n.replace then
        local replacement = node.hpack(node.copy_list(n.replace))
        local ok = measure_hlist(replacement, x, y0, bounds)
        local width = replacement.width or 0
        node.flush_node(replacement)
        if not ok then
          return false
        end
        x = x + width
      end
    elseif n.id == penalty_id or n.id == dir_id then
      -- no ink and no horizontal advance
    elseif n.id == whatsit_id then
      -- Colour and luatexja bookkeeping do not draw ink.  Literal PDF,
      -- images, forms, links, writes, etc. are deliberately unsupported.
      if n.subtype ~= colorstack_subtype and n.subtype ~= userdefined_subtype
          and n.subtype ~= pdfsave_subtype and n.subtype ~= pdfrestore_subtype then
        if KKS.visual_debug then
          texio.write_nl("term and log", string.format(
            "KKS-VISUAL unsupported whatsit subtype=%s", tostring(n.subtype)))
        end
        return false
      end
    else
      if KKS.visual_debug then
        texio.write_nl("term and log", string.format(
          "KKS-VISUAL unsupported node type=%s subtype=%s",
          tostring(node.type(n.id)), tostring(n.subtype)))
      end
      return false
    end
  end
  return true
end

local function box_ink_bounds(box_number)
  local box = tex.getbox(box_number)
  if not box or box.id ~= hlist_id then
    return nil
  end
  local bounds = {
    xmin = math.huge, ymin = math.huge,
    xmax = -math.huge, ymax = -math.huge,
    found = false,
  }
  if not measure_hlist(box, 0, 0, bounds) or not bounds.found then
    return nil
  end
  bounds.width = box.width or 0
  bounds.height = box.height or 0
  bounds.depth = box.depth or 0
  return bounds
end

-- Return an empty string for the byte-identical pass/fail-open path.  Otherwise
-- return only an additional, uniform shrink factor for the already existing
-- star-path scaler.  Ink is never used as a sizing or centering basis.
function KKS.visual_scale(raw_box_number, legacy_box_number, shape, p1, p2)
  local ok, factor = pcall(function()
    local raw = box_ink_bounds(raw_box_number)
    local legacy_box = tex.getbox(legacy_box_number)
    local raw_box = tex.getbox(raw_box_number)
    if not raw or not legacy_box or not raw_box then
      return nil
    end
    local legacy_scale
    if (raw_box.width or 0) ~= 0 then
      legacy_scale = (legacy_box.width or 0) / raw_box.width
    else
      local raw_total = (raw_box.height or 0) + (raw_box.depth or 0)
      if raw_total == 0 then
        return nil
      end
      legacy_scale = ((legacy_box.height or 0) + (legacy_box.depth or 0)) / raw_total
    end
    if not legacy_scale or legacy_scale <= 0
        or legacy_scale ~= legacy_scale or legacy_scale == math.huge then
      return nil
    end

    local cx = (raw.width or 0) / 2
    local cy = ((raw.height or 0) - (raw.depth or 0)) / 2
    local xs = {
      (raw.xmin - cx) * legacy_scale,
      (raw.xmax - cx) * legacy_scale,
    }
    local ys = {
      (raw.ymin - cy) * legacy_scale,
      (raw.ymax - cy) * legacy_scale,
    }
    local required = 1
    if shape == "circle" then
      local radius = tonumber(p1)
      if not radius or radius <= 0 then
        return nil
      end
      -- A fontloader bounding box is the smallest axis-aligned ink box, not
      -- the glyph outline.  Testing its empty corners against a circle creates
      -- false positives (notably the documented i/iv/viii samples).  Its four
      -- extrema, however, prove overflow whenever they cross the visible
      -- circle's horizontal or vertical extent.
      local max_x = math.max(math.abs(xs[1]), math.abs(xs[2]))
      local max_y = math.max(math.abs(ys[1]), math.abs(ys[2]))
      required = math.min(1, radius / max_x, radius / max_y)
    elseif shape == "rectangle" then
      local half_width, half_height = tonumber(p1), tonumber(p2)
      if not half_width or not half_height or half_width <= 0 or half_height <= 0 then
        return nil
      end
      local max_x = math.max(math.abs(xs[1]), math.abs(xs[2]))
      local max_y = math.max(math.abs(ys[1]), math.abs(ys[2]))
      required = math.min(1, half_width / max_x, half_height / max_y)
    else
      return nil
    end
    if required >= 0.999999 then
      if KKS.visual_debug then
        texio.write_nl("term and log", string.format(
          "KKS-VISUAL shape=%s scale=pass legacy=%.8f x=[%.2f,%.2f] y=[%.2f,%.2f] p=[%.2f,%.2f]",
          shape, legacy_scale, xs[1], xs[2], ys[1], ys[2], tonumber(p1) or 0,
          tonumber(p2) or 0))
      end
      return nil
    end
    if required < 0.0000001 or required ~= required or required == math.huge then
      return nil
    end
    if KKS.visual_debug then
      texio.write_nl("term and log", string.format(
        "KKS-VISUAL shape=%s scale=%.8f legacy=%.8f x=[%.2f,%.2f] y=[%.2f,%.2f] p=[%.2f,%.2f]",
        shape, required, legacy_scale, xs[1], xs[2], ys[1], ys[2],
        tonumber(p1) or 0, tonumber(p2) or 0))
    end
    return required
  end)
  if not ok or not factor then
    return ""
  end
  return string.format("%.8f", factor)
end

-- Return an additional uniform shrink factor that keeps the already-scaled
-- content between the actual inner ink edges of a pair of bracket glyphs.
-- The caller passes the unscaled bracket boxes because graphicx implements
-- horizontal scaling with PDF transformation whatsits; applying the known
-- x-scale here keeps the measurement on documented fontloader data.
function KKS.visual_bracket_scale(raw_box_number, legacy_box_number,
    left_box_number, right_box_number, inner_width, overlap, bracket_xscale,
    angle)
  local ok, factor = pcall(function()
    if KKS.visual_debug then
      texio.write_nl("term and log", string.format(
        "KKS-BRACKET boxes legacy=%s left=%s right=%s",
        tostring(legacy_box_number), tostring(left_box_number),
        tostring(right_box_number)))
    end
    local content = box_ink_bounds(raw_box_number)
    local raw_box = tex.getbox(raw_box_number)
    local legacy_box = tex.getbox(legacy_box_number)
    local left = box_ink_bounds(left_box_number)
    local right = box_ink_bounds(right_box_number)
    inner_width = tonumber(inner_width)
    overlap = tonumber(overlap)
    bracket_xscale = tonumber(bracket_xscale)
    angle = tonumber(angle)
    if not content or not raw_box or not legacy_box or not left or not right
        or not inner_width or not overlap
        or not bracket_xscale or not angle or inner_width <= 0
        or bracket_xscale <= 0 then
      if KKS.visual_debug then
        texio.write_nl("term and log", string.format(
          "KKS-BRACKET fail inputs content=%s left=%s right=%s width=%s overlap=%s xscale=%s angle=%s",
          tostring(content ~= nil), tostring(left ~= nil), tostring(right ~= nil),
          tostring(inner_width), tostring(overlap), tostring(bracket_xscale),
          tostring(angle)))
      end
      return nil
    end

    local middle_start = bracket_xscale * left.width - overlap
    local middle_center = middle_start + inner_width / 2
    local left_limit = bracket_xscale * left.xmax - middle_center
    local right_start = middle_start + inner_width - overlap
    local right_limit = right_start + bracket_xscale * right.xmin - middle_center
    -- A glyph bbox gives only the global x-extreme.  For curved, angled, and
    -- corner brackets that extreme may occur at a tip far above or below the
    -- content and is not evidence of an ink collision.  The middle box edges
    -- are the strongest limits we can prove from bbox data without inventing
    -- an outline intersection.  This deliberately favours the exact legacy
    -- rendering unless content ink actually leaves the designated opening.
    left_limit = math.min(left_limit, -inner_width / 2)
    right_limit = math.max(right_limit, inner_width / 2)
    if left_limit >= 0 or right_limit <= 0 then
      if KKS.visual_debug then
        texio.write_nl("term and log", string.format(
          "KKS-BRACKET fail gap limits=[%.2f,%.2f]", left_limit, right_limit))
      end
      return nil
    end

    local legacy_scale
    if raw_box.width ~= 0 then
      legacy_scale = legacy_box.width / raw_box.width
    else
      local raw_total = raw_box.height + raw_box.depth
      if raw_total == 0 then
        return nil
      end
      legacy_scale = (legacy_box.height + legacy_box.depth) / raw_total
    end
    if legacy_scale <= 0 or legacy_scale ~= legacy_scale
        or legacy_scale == math.huge then
      return nil
    end

    local cx = content.width / 2
    local cy = (content.height - content.depth) / 2
    local radians = angle * math.pi / 180
    local cosine, sine = math.cos(radians), math.sin(radians)
    local xmin, xmax = math.huge, -math.huge
    for _, x in ipairs({ (content.xmin - cx) * legacy_scale,
        (content.xmax - cx) * legacy_scale }) do
      for _, y in ipairs({ (content.ymin - cy) * legacy_scale,
          (content.ymax - cy) * legacy_scale }) do
        local rotated_x = x * cosine - y * sine
        xmin, xmax = math.min(xmin, rotated_x), math.max(xmax, rotated_x)
      end
    end

    local required = 1
    if xmin < left_limit then
      required = math.min(required, (-left_limit) / (-xmin))
    end
    if xmax > right_limit then
      required = math.min(required, right_limit / xmax)
    end
    if required >= 0.999999 then
      if KKS.visual_debug then
        texio.write_nl("term and log", string.format(
          "KKS-BRACKET scale=pass x=[%.2f,%.2f] limits=[%.2f,%.2f] angle=%.2f",
          xmin, xmax, left_limit, right_limit, angle))
      end
      return nil
    end
    if required < 0.0000001 or required ~= required or required == math.huge then
      return nil
    end
    if KKS.visual_debug then
      texio.write_nl("term and log", string.format(
        "KKS-BRACKET scale=%.8f x=[%.2f,%.2f] limits=[%.2f,%.2f] angle=%.2f",
        required, xmin, xmax, left_limit, right_limit, angle))
    end
    return required
  end)
  if not ok or not factor then
    return ""
  end
  return string.format("%.8f", factor)
end

_G.KKsymbols = KKS
