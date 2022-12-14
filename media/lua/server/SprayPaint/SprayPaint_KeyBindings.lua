local sprayBindings = {}

local function addBind(name, key)
  local bind = {}
  bind.value = name
  bind.key = key
  table.insert(keyBinding, bind)
  table.insert(sprayBindings, bind)
end


table.insert(keyBinding, {value='[Spraypaint]'})
addBind('Looted', 0)
addBind('Hordes', 0)
addBind('NotSafe', 0)
addBind('Safe', 0)
addBind('Safehouse', 0)

addBind('Cross', 0)
addBind('Square', 0)
addBind('Circle', 0)
addBind('Triangle', 0)

addBind('West', 0)
addBind('North', 0)
addBind('South', 0)
addBind('East', 0)
addBind('Northwest', 0)
addBind('Northeast', 0)
addBind('Southwest', 0)
addBind('Southeast', 0)

addBind('ToggleSpraypaintWindow', 0)

local function getSprayByName(name)
  for _,place in ipairs(shapeConf.list) do
    for _,symbolType in ipairs(place.symbolTypes) do
      for _,shape in ipairs(symbolType.shapes) do
        if name == shape.text then return shape end
      end
    end
  end
  return nil
end

local function findFirstUsableCan(inventory)
  for i = 0,inventory:size() - 1 do
    local item = inventory:get(i)
    for _,sprayCan in ipairs(sprayCanConf.list) do
      if item:getType() == sprayCan.name and bcUtils.numUsesLeft(item) > 0 then return item, sprayCan end
    end
  end
  return nil
end

Events.OnKeyPressed.Add(function (key)
  for _,bind in ipairs(sprayBindings) do
    if getCore():getKey(bind.value) == key and getSpecificPlayer(0) ~= nil then
      local player = getSpecificPlayer(0);
      local inv = player:getInventory()
      local shape = getSprayByName(bind.value)
      local items = inv:getItems()
      local sprayCanItem,sprayCanColour,what = findFirstUsableCan(items)
      if shape ~= nil and sprayCanItem ~= nil then
        if player:getSecondaryHandItem() ~= sprayCanItem then ISTimedActionQueue.add(ISEquipWeaponAction:new(player, sprayCanItem, 50, false)) end
        local tag = Tag:new(player:getPlayerNum(), sprayCanItem, shape['name'], sprayCanColour.red, sprayCanColour.green, sprayCanColour.blue)
        getCell():setDrag(tag, player:getPlayerNum())
      end
    end
  end
end)