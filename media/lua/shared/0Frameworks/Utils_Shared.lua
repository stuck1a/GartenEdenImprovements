require "luautils"

if not bcUtils then bcUtils = {} end


---
--- Small function to dump an object.
---
bcUtils.dump = function(o, lvl, ind)
  lvl = lvl or 5
  ind = ind or 0
  local pref = ""
  for _=1,ind do pref = pref .. " " end
  if lvl < 0 then return pref .. "SO ("..tostring(o)..")" end
  if type(o) == 'table' then
    local s = '{\n'
    for k,v in pairs(o) do
      if k == "prev" or k == "next" then
        s = s .. pref .. '['..k..'] = '..tostring(v)..",\n"
      else
        if type(k) ~= 'number' then k = '"'..tostring(k)..'"' end
        s = s .. pref .. '['..k..'] = ' .. bcUtils.dump(v, lvl - 1, ind + 1) .. ',\n'
      end
    end
    pref = ""
    for _=2,ind do pref = pref .. " " end
    return s .. pref .. '}\n'
  else
    if type(o) == "string" then return '"'..tostring(o)..'"' end
    return tostring(o)
  end
end


---
--- Print text or an objects string representation to the logfile
---
bcUtils.pline = function(text)
  print(tostring(text))
end


---
--- Check if an object is a stove
---
bcUtils.isStove = function(o)
  if not o then return false end
  return instanceof(o, "IsoStove")
end


---
--- Check if an object is a window
---
bcUtils.isWindow = function(o)
  if not o then return false end
  return instanceof(o, "IsoWindow")
end


---
---  Check if an object is a door
---
bcUtils.isDoor = function(o)
  if not o then return false end
  return (instanceof(o, "IsoDoor") or (instanceof(o, "IsoThumpable") and o:isDoor()))
end


---
--- Check if an object is a tree
---
bcUtils.isTree = function(o)
  if not o then return false end
  return instanceof(o, "IsoTree")
end


---
--- Check if an object is a container
---
bcUtils.isContainer = function(o)
  if not o then return false end;
  return o:getContainer();
end


---
--- Check if an object is a pen or pencil
---
bcUtils.isPenOrPencil = function(o)
  if not o then return false end
  return o:getFullType() == "Base.Pen" or o:getFullType() == "Base.Pencil"
end


---
--- Check if a given table is empty
---
bcUtils.tableIsEmpty = function(o)
  for _,_ in pairs(o) do
    return false
  end
  return true
end


---
--- Check if two tables have identical content
---
bcUtils.tableIsEqual = function(tbl1, tbl2)
  for k,v in pairs(tbl1) do
    if type(v) == "table" and type(tbl2[k]) == "table" then
      if not bcUtils.tableIsEqual(v, tbl2[k]) then return false end
    else
      if v ~= tbl2[k] then return false end
    end
  end
  for k,v in pairs(tbl2) do
    if type(v) == "table" and type(tbl1[k]) == "table" then
      if not bcUtils.tableIsEqual(v, tbl1[k]) then return false end
    else
      if v ~= tbl1[k] then return false end
    end
  end
  return true
end


---
--- Clone a table including any metatables
---
bcUtils.cloneTable = function(orig)
  local orig_type, copy = type(orig)
  if orig_type == 'table' then
    copy = {}
    for orig_key,orig_value in pairs(orig) do copy[orig_key] = bcUtils.cloneTable(orig_value) end
    setmetatable(copy, bcUtils.cloneTable(getmetatable(orig)))
  else
    copy = orig
  end
  return copy
end



---
--- Check if an object is a street
---
bcUtils.isStreet = function(o)
  if not o then return false end
  if not o:getTextureName() then return false end
  return luautils.stringStarts(o:getTextureName(), "blends_street")
end


---
--- Check if an tile object has a street object on it
---
bcUtils.hasStreet = function(o)
  if not o then return false end
  local objects = o:getObjects()
  for k=0,objects:size()-1 do
    local it = objects:get(k)
    if bcUtils.isStreet(it) then return true end
  end
  return false
end


---
--- Check if an object is a dirtroad
---
bcUtils.isDirtRoad = function(o)
  if not o then return false end
  if not o:getTextureName() then return false end
  if luautils.stringStarts(o:getTextureName(), "blends_natural") then
    local m = bcUtils.split(o:getTextureName(), "_");
    return m[3] == "01" and tonumber(m[4]) <= 7;
  end
  return false
end


---
--- Check if an tile object has a dirtroad object on it
---
bcUtils.hasDirtRoad = function(o)
  if not o then return false end
  local objects = o:getObjects()
  for k=0, objects:size()-1 do
    local it = objects:get(k)
    if bcUtils.isDirtRoad(it) then return true end
  end
  return false
end


---
--- Calculates and returns the real distance between two tiles (Pythagorean)
---
bcUtils.realDist = function(x1, y1, x2, y2)
  return math.sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2))
end


---
---  Splits a string by a given separator with regex and returns the resulting array
---
bcUtils.split = function(string, sep)
  sep = sep or ":"
  local pattern = string.format("([^%s]+)", sep)
  local fields = {}
  string:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end


---
--- Reads a named server INI file for a given mod name and returns its content as data structure
--- with key-value-pairs grouped by found categories, if any
---
bcUtils.readModINI = function(mod, filename)
  local retVal = {}
  local rvptr = retVal
  local f = getModFileReader(mod, filename, false)
  if not f then return retVal end
  local line = "1"
  local currentCat = "unknown"
  while line do
    line = f:readLine()
    if line then
      if luautils.stringStarts(line, "[") then
        currentCat = string.match(line, "[a-zA-Z0-9/ \.]+")
        rvptr = retVal
        for _,cat in ipairs(bcUtils.split(currentCat, "/")) do
          if not rvptr[cat] then rvptr[cat] = {} end
          rvptr = rvptr[cat]
        end
      else
        local kv = bcUtils.split(line, "=")
        rvptr[kv[1]] = kv[2]
      end
    end
  end
  return retVal
end


---
--- Reads an arbitrary server INI file of the given name and returns its content as data structure
--- with key-value-pairs grouped by found categories, if any
---
bcUtils.readINI = function(filename)
  local retVal = {}
  local rvptr = retVal
  local f = getFileReader(filename, false)
  if not f then return retVal end
  local line = "1"
  local currentCat = "unknown"
  while line do
    line = f:readLine()
    if line then
      if luautils.stringStarts(line, "[") then
        currentCat = string.match(line, "[a-zA-Z0-9/ \.]+")
        rvptr = retVal
        for _,cat in ipairs(bcUtils.split(currentCat, "/")) do
          if not rvptr[cat] then rvptr[cat] = {} end
          rvptr = rvptr[cat]
        end
      else
        local kv = bcUtils.split(line, "=")
        rvptr[kv[1]] = kv[2]
      end
    end
  end
  return retVal
end


---
--- Writes the content of an given table with key-value-pairs and to the given parent category.
--- Can contain several parent categories, if the key-value-pairs are grouped by them.
--- In this case the param parentCategory must be omitted or nil.
--- Needs an already existing file writer object pointing to the target file.
---
bcUtils.writeINItable = function(fd, table, parentCategory)
  local category;
  for catID,catVal in pairs(table) do
    if parentCategory then
      category = parentCategory.."/"..catID
    else
      category = catID;
    end
    fd:write("["..category.."]\n")
    for k,v in pairs(catVal) do
      if type(v) == "table" then
        local a = {}
        a[k] = v
        bcUtils.writeINItable(fd, a, category)
      else
        fd:write(tostring(k).."="..tostring(v).."\n")
      end
    end
  end
end


---
--- Replaces the actual content of an INI file with any new content.
--- If the target file does not exist, it will be created, if possible.
---
bcUtils.writeINI = function(filename, content)---{{{
  local fd = getFileWriter(filename, true, false)
  if not fd then return false end
  bcUtils.writeINItable(fd, content)
  fd:close()
end


---
--- Returns the total number of uses of an drainable item
---
bcUtils.numUses = function(item)
  if not item then return 0 end
  return math.floor(1 / item:getUseDelta())
end



---
--- Returns the remaining number of uses of an drainable item
---
bcUtils.numUsesLeft = function(item)
  if not item then return 0 end
  return math.floor(item:getUsedDelta() / item:getUseDelta())
end


---
--- Checks, if an user already has a safehouse (as owener or shared)
--- @param username string username of the target user
--- @return boolean
---
bcUtils.hasSafehouseAccess = function(username)
  local aSafehouses = SafeHouse.getSafehouseList()
  for i=0, aSafehouses:size()-1 do
    local aPlayers = aSafehouses:get(i):getPlayers()
    for j=0, aPlayers:size()-1 do
      if aPlayers:get(j) == username then return true end
    end
  end
  return false
end
