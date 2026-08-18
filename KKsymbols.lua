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

-- Return true only when the fully expanded TeX argument consists entirely of
-- lowercase ASCII letters.  TeX performs the expansion; Lua deliberately keeps
-- the classification small and predictable (not locale dependent).
function KKS.is_lowercase_ascii(s)
  return s:match("^[a-z]+$") ~= nil
end

function KKS.lowercase_ascii_flag(s)
  return KKS.is_lowercase_ascii(s) and 1 or 0
end

_G.KKsymbols = KKS
