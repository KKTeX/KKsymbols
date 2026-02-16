luatexbase.provides_module{
  name     = 'KKsymbols',
  date     = '2026/02/17',
  version  = '2.1.2',
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

_G.KKsymbols = KKS