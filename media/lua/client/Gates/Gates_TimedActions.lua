-- From mod "Gates"

NolanGate = {};
NolanGate.CreateGate = function(item, player, time, square)
  ISTimedActionQueue.add(BuildGateAction:new(player:getPlayerNum(), item, time, square));
end

require "TimedActions/ISBaseTimedAction"
BuildGateAction = ISBaseTimedAction:derive("BuildGateAction");

function BuildGateAction:isValid()
  return true;
end

function BuildGateAction:update()
  --self.character:faceThisObject(self.wall)
end

function BuildGateAction:start()
  self.sound = self.character:getEmitter():playSound("PZ_Hammer", true)
end

function BuildGateAction:stop()
  if self.sound then
    self.character:getEmitter():stopSound(self.sound)
    self.sound = nil
  end
  ISBaseTimedAction.stop(self);
end

function BuildGateAction:perform()
  if self.sound then
    self.character:getEmitter():stopSound(self.sound)
    self.sound = nil
  end
  CreateGate(self.square);
  ISBaseTimedAction.perform(self);
end

function BuildGateAction:new(character, wall, time, square)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.character = getSpecificPlayer(character);
  o.activate = activate;
  o.wall = wall;
  o.square = square;
  o.stopOnWalk = true;
  o.stopOnRun = true;
  o.maxTime = time;
  o.caloriesModifier = 5;
  return o;
end
