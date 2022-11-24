require 'Items/ProceduralDistributions'

--- @class utils
if not utils then utils = {} end


---
--- Adds a set of definitions of procedural item distribution
--- @param ItemDist table  Item distribution defnition table
---
utils.addItemDistributions = function(ItemDist)
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