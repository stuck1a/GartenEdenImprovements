
local function OnClientCommand(module, command, player, args)
	if not isServer() or module ~= "Traps" then return end
	if command == "SetTrap" then
		local sq = getWorld():getCell():getGridSquare(args.x, args.y, args.z)
		local Objs = sq:getWorldObjects()
		for i=0, Objs:size()-1 do
			if Objs:get(i):getKeyId() == args.trapid then 
				Objs:get(i):getModData().isSet = true
				Objs:get(i):getItem():getModData().isSet = true
			end
		end
		sq:getModData().isTrapSet = true
		player:Say(getText("UI_Traps_TrapPlaced"));
	end
end
	
Events.OnClientCommand.Add(OnClientCommand);
