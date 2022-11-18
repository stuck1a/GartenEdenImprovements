require 'Items/ProceduralDistributions'

--- @class UtilsSrv
if not UtilsSrv then UtilsSrv = {} end


---
--- Adds a set of definitions of procedural item distribution
--- @param ItemDist table  Item distribution defnition table
---
UtilsSrv.addItemDistributions = function(ItemDist)
  for i=1, #ItemDist do
    for j=1, #(ItemDist[i].Distributions) do
      for k=1, #(ItemDist[i].Items) do
        local tLootTable = ProceduralDistributions.list[ItemDist[i].Distributions[j][1]]
        table.insert(tLootTable.items, ItemDist[i].Items[k])
        table.insert(tLootTable.items, ItemDist[i].Distributions[j][2])
      end
    end
  end
end


---
--- Fetches all items matching any of the given itemTags and returns
--- a script-like item list like "Base.Hammer=1/Base.StoneHammer=1"
--- @param itemTags table list of item tags
--- @return string concatenated string of concrete items
---
function UtilsSrv.ConcatItemTypes(itemTags)
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
