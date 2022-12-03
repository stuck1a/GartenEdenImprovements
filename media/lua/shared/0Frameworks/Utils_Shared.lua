require 'luautils'
if not utils then utils = {} end


---
--- Searches for a given value within a table (not recursive!)
--- @param tbl table Target table
--- @param value any Value to search for
--- @return boolean True if the value was found, false otherwise
---
utils.tableContains = function(tbl, value)
  for _,v in ipairs(tbl) do if v == value then return true end end
  return false
end



---
--- Recursively copies the value of a table
--- @param data table Target table
--- @param _ int Recursion counter (don't set this value!)
--- @return table Deep copy (no metatables)
---
utils.tableCopyData = function(data, _)
  _ = _ or 0
  if _ > 100 then return nil end
  local result = {}
  for k, v in pairs(data) do
    if type(v) == 'table' then v = utils.tableCopyData(v, 1 + _) end
    result[k] = v
  end
  return result
end



---
--- Fetches all items matching any of the given itemTags and returns
--- a script-like item list like "Base.Hammer=1/Base.StoneHammer=1"
--- @param itemTags table list of item tags
--- @return string concatenated string of all items which use this tag
---
utils.concatItemTypes = function(itemTags)
  local result = ''
  for i=1, #itemTags do
    local aItems = getScriptManager():getItemsTag(itemTags[i])
    for j=0, aItems:size() - 1 do
      result = result .. aItems:get(j):getFullName()
      if j < aItems:size() - 1 then result = result .. '/' end
    end
  end
  return result
end



---
--- Generic tostring() for objects
--- @param o any Target object
--- @param lvl int Maximum depth
--- @param ind int Number of spaces for indentation
--- @return string string representation of the object
---
utils.dump = function(o, lvl, ind)
  lvl = lvl or 5
  ind = ind or 0
  local pref = ''
  for _=1, ind do pref = pref .. ' ' end
  if lvl < 0 then return pref .. 'SO (' .. tostring(o) .. ')' end
  if type(o) == 'table' then
    local s = '{\n'
    for k,v in pairs(o) do
      if k == 'prev' or k == 'next' then
        s = string.format('%s%s[%s] = %s,\n', s, pref, k, tostring(v))
      else
        if type(k) ~= 'number' then k = string.format('"%s"', tostring(k)) end
        s = string.format('%s%s[%s] = %s,\n', s, pref, k, utils.dump(v, lvl-1, ind+1))
      end
    end
    pref = ''
    for _=2, ind do pref = pref .. ' ' end
    return s .. pref .. '}\n'
  else
    if type(o) == 'string' then return string.format('"%s"', o) end
    return tostring(o)
  end
end


---
--- Print text or an objects string representation to the logfile
---
utils.pline = function(text)
  print(tostring(text))
end


---
--- Check if an object is a stove
---
utils.isStove = function(o)
  if not o then return false end
  return instanceof(o, 'IsoStove')
end


---
--- Check if an object is a window
---
utils.isWindow = function(o)
  if not o then return false end
  return instanceof(o, 'IsoWindow')
end


---
---  Check if an object is a door
---
utils.isDoor = function(o)
  if not o then return false end
  return (instanceof(o, 'IsoDoor') or (instanceof(o, 'IsoThumpable') and o:isDoor()))
end


---
--- Check if an object is a tree
---
utils.isTree = function(o)
  if not o then return false end
  return instanceof(o, 'IsoTree')
end


---
--- Check if an object is a container
---
utils.isContainer = function(o)
  if not o then return false end;
  return o:getContainer();
end


---
--- Checks if an object is a pen or pencil
---
utils.isPenOrPencil = function(o)
  if not o then return false end
  return o:getFullType() == 'Base.Pen' or o:getFullType() == 'Base.Pencil'
end


---
--- Checks if a given table is empty
---
utils.tableIsEmpty = function(o)
  for _,_ in pairs(o) do return false end
  return true
end


---
--- Checks if two tables have identical content
---
utils.tableIsEqual = function(tbl1, tbl2)
  for k,v in pairs(tbl1) do
    if type(v) == 'table' and type(tbl2[k]) == 'table' then
      if not utils.tableIsEqual(v, tbl2[k]) then return false end
    else
      if v ~= tbl2[k] then return false end
    end
  end
  for k,v in pairs(tbl2) do
    if type(v) == 'table' and type(tbl1[k]) == 'table' then
      if not utils.tableIsEqual(v, tbl1[k]) then return false end
    else
      if v ~= tbl1[k] then return false end
    end
  end
  return true
end


---
--- Clone a table including any metatables
---
utils.cloneTable = function(orig)
  local orig_type, copy = type(orig)
  if orig_type == 'table' then
    copy = {}
    for orig_key,orig_value in pairs(orig) do copy[orig_key] = utils.cloneTable(orig_value) end
    setmetatable(copy, utils.cloneTable(getmetatable(orig)))
  else
    copy = orig
  end
  return copy
end



---
--- Check if an object is a street
---
utils.isStreet = function(o)
  if not o then return false end
  if not o:getTextureName() then return false end
  return luautils.stringStarts(o:getTextureName(), 'blends_street')
end


---
--- Check if an tile object has a street object on it
---
utils.hasStreet = function(o)
  if not o then return false end
  local objects = o:getObjects()
  for k=0,objects:size()-1 do
    local it = objects:get(k)
    if utils.isStreet(it) then return true end
  end
  return false
end


---
--- Check if an object is a dirtroad
---
utils.isDirtRoad = function(o)
  if not o then return false end
  if not o:getTextureName() then return false end
  if luautils.stringStarts(o:getTextureName(), 'blends_natural') then
    local m = utils.split(o:getTextureName(), '_');
    return m[3] == '01' and tonumber(m[4]) <= 7;
  end
  return false
end


---
--- Check if an tile object has a dirtroad object on it
---
utils.hasDirtRoad = function(o)
  if not o then return false end
  local objects = o:getObjects()
  for k=0, objects:size()-1 do
    local it = objects:get(k)
    if utils.isDirtRoad(it) then return true end
  end
  return false
end


---
--- Calculates and returns the real distance between two tiles (Pythagorean)
---
utils.realDist = function(x1, y1, x2, y2)
  return math.sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2))
end


---
--- Splits a string by a given separator with regex and returns the resulting array
--- While the luautils variant uses spaces as default separator, this one uses colons
--- and works more efficient
---
utils.split = function(string, sep)
  sep = sep or ':'
  local pattern = string.format('([^%s]+)', sep)
  local fields = {}
  string:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end


---
--- Reads a named server INI file for a given mod name and returns its content as data structure
--- with key-value-pairs grouped by found categories, if any
---
utils.readModINI = function(mod, filename)
  local retVal = {}
  local rvptr = retVal
  local f = getModFileReader(mod, filename, false)
  if not f then return retVal end
  local line = '1'
  local currentCat = 'unknown'
  while line do
    line = f:readLine()
    if line then
      if luautils.stringStarts(line, '[') then
        currentCat = string.match(line, '[a-zA-Z0-9/ \.]+')
        rvptr = retVal
        for _,cat in ipairs(utils.split(currentCat, '/')) do
          if not rvptr[cat] then rvptr[cat] = {} end
          rvptr = rvptr[cat]
        end
      else
        local kv = utils.split(line, '=')
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
utils.readINI = function(filename)
  local retVal = {}
  local rvptr = retVal
  local f = getFileReader(filename, false)
  if not f then return retVal end
  local line = '1'
  local currentCat = 'unknown'
  while line do
    line = f:readLine()
    if line then
      if luautils.stringStarts(line, '[') then
        currentCat = string.match(line, '[a-zA-Z0-9/ \.]+')
        rvptr = retVal
        for _,cat in ipairs(utils.split(currentCat, '/')) do
          if not rvptr[cat] then rvptr[cat] = {} end
          rvptr = rvptr[cat]
        end
      else
        local kv = utils.split(line, '=')
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
utils.writeINItable = function(fd, table, parentCategory)
  local category;
  for catID,catVal in pairs(table) do
    if parentCategory then
      category = parentCategory .. '/' .. catID
    else
      category = catID;
    end
    fd:write('[' .. category .. ']\n')
    for k,v in pairs(catVal) do
      if type(v) == 'table' then
        local a = {}
        a[k] = v
        utils.writeINItable(fd, a, category)
      else
        fd:write(tostring(k) .. '=' .. tostring(v) .. '\n')
      end
    end
  end
end


---
--- Replaces the actual content of an INI file with any new content.
--- If the target file does not exist, it will be created, if possible.
---
utils.writeINI = function(filename, content)
  local fd = getFileWriter(filename, true, false)
  if not fd then return false end
  utils.writeINItable(fd, content)
  fd:close()
end


---
--- Returns the total number of uses of an drainable item
---
utils.numUses = function(item)
  if not item then return 0 end
  return math.floor(1 / item:getUseDelta())
end



---
--- Returns the remaining number of uses of an drainable item
---
utils.numUsesLeft = function(item)
  if not item then return 0 end
  return math.floor(item:getUsedDelta() / item:getUseDelta())
end


---
--- Checks, if an user already has a safehouse (as owener or shared)
--- @param username string username of the target user
--- @return boolean
---
utils.hasSafehouseAccess = function(username)
  local aSafehouses = SafeHouse.getSafehouseList()
  for i=0, aSafehouses:size()-1 do
    local aPlayers = aSafehouses:get(i):getPlayers()
    for j=0, aPlayers:size()-1 do
      if aPlayers:get(j) == username then return true end
    end
  end
  return false
end