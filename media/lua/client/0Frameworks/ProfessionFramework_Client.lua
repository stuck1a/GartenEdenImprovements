--
-- Client file for the profession framework mod.
-- Handles special profession trait swaps, adding starter kits, and
-- mounts OnNewGame handler for each registered profession and trait,
-- and OnGameStart handler for traits
--

Events.OnGameStart.Add(function()
  local player = getSpecificPlayer(0)
  for trait, details in pairs(ProfessionFramework.Traits) do
    if player:HasTrait(trait) and details.OnGameStart then details.OnGameStart(trait) end
  end
end)

Events.OnNewGame.Add(function(player, square)
  for trait, details in pairs(ProfessionFramework.Traits) do repeat
    if not player:HasTrait(trait) then break end
    ProfessionFramework.addStartingKit(player, square, details)
    if details.swap then
      player:getTraits():remove(trait)
      player:getTraits():add(details.swap)
    end
    if details.add then
      for _, trait in ipairs(details.add) do
        if not player:HasTrait(trait) then player:getTraits():add(trait) end
      end
    end
    if details.OnNewGame then details.OnNewGame(player, square, trait) end
  until true end
  local profession = player:getDescriptor():getProfession()
  local details = ProfessionFramework.getProfession(profession)
  if not details then return end
  ProfessionFramework.addStartingKit(player, square, details)
  if details.OnNewGame then details.OnNewGame(player, square, profession) end
end)
