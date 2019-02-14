GM = {}

local scenario = global.scenario

if not global.scenario.gm then
  global.scenario.gm = {}
end

function GM.RestoreBar(player)
  if not global.scenario.gm[player.name] then
    -- Init inventory
    for tree_name, tree_data in pairs(game.entity_prototypes) do
      if string.match(tree_data.type, "tree") and game.forces.gm.recipes[tree_name.."-recipe"] then 
        game.forces.gm.recipes[tree_name.."-recipe"].enabled = true
      end
    end
    -- Not specific to loada
  else
    -- Load inventory
    
  end
  player.cheat_mode = true
end

function GM.SaveBar(player)
  player.cheat_mode = false
  -- Save inventory
end