require '0Frameworks/Utils_Shared'
require 'OptionScreens/MainScreen'
require 'ISUI/ISButton'

if not utils then utils = {} end


---
--- Provides direct access to the ResetLua method.
--- Shortcut for runtime debugging.
---
utils.reloadLua = function()
  getCore():ResetLua(true, 'modsChanged')
end



---
--- Polyfill for table.pack
---
if table.pack == nil then
  table.pack = function(...)
    return { n = select('#', ...), ... }
  end
end



---
--- Maps the vanilla Polyfill unpack to table.unpack
---
if table.unpack == nil then
  table.unpack = function(t, i)
    i = i or 1;
    if t[i] then return t[i], unpack(t, i + 1) end
  end
end