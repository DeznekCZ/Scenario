GM = {}

local scenario = global.scenario

if not global.scenario.gm then
  global.scenario.gm = {}
end

function GM.RestoreBar(player)
  if not global.scenario.gm[player.name] then
    -- Init inventory
    -- Not specific to load
  else
    -- Load inventory
    
  end
  player.cheat_mode = true
end

function GM.SaveBar(player)
  player.cheat_mode = false
  if not global.scenario.gm[player.name] then
    
  else
    -- Load inventory
    
  
  end
end