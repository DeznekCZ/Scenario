
require("character.character")


if not global.scenario then
  global.scenario = {}
end
if not global.scenario.tasks then
  global.scenario.tasks = {}
end
if not global.scenario.characters then
  global.scenario.characters = {}
end
if not global.scenario.detached then
  global.scenario.detached = {}
end
if not global.scenario.forces then
  global.scenario.forces = { _index = 0 }
end

require("control.gm")
require("control.bm")

local scenario = global.scenario

local function get_or_create_player_force(player)
  if not scenario[player.name..":"..player.tag] then
    scenario[player.name..":"..player.tag] = { 
      builder = "builder:"..scenario.forces._index,
      player = "player:"..scenario.forces._index
    }
    scenario.forces._index = scenario.forces._index + 1
  end
  
  return game.forces[scenario[player.name..":"..player.tag].player] or game.create_force(scenario[player.name..":"..player.tag].player)
end

local function get_or_create_builder_force(player)
  if not scenario[player.name..":"..player.tag] then
    scenario[player.name..":"..player.tag] = { 
      builder = "builder:"..scenario.forces._index,
      player = "player:"..scenario.forces._index
    }
    scenario.forces._index = scenario.forces._index + 1
  end
  
  return game.forces[scenario[player.name..":"..player.tag].builder] or game.create_force(scenario[player.name..":"..player.tag].builder)
end

local function string_starts(str_value, str_start)
  local i_start, _ = string.find(str_value,str_start)
  return i_start == 1
end

local function on_init()
  if game and not game.forces["gm"] then
    local gm_force = game.create_force("gm")
    
    for tree_name, tree_data in pairs(game.entity_prototypes) do
      if string.match(tree_data.type, "tree") then 
        gm_force.recipes[tree_name.."-recipe"].enabled = true
      end
    end
  end
end

script.on_init(on_init)
script.on_load(on_init)

local function gm_parse(event)
  local player_index = event.player_index
  local command = event.name
  local parameters = event.parameter
  
  local player = game.players[player_index]
  
  local force_name = player.force.name
  local player_name = player.name
  if parameters then
    player_index = tonumber(string.find(parameters,"%d+"))
    player = game.players[player_index]
    force_name = player.force.name
    player_name = player.name
  end
  
  local force_gm = string.match(force_name,"gm")
  
  if not force_gm then
    player.force = "gm"
  end
end

commands.add_command("gm", {"", "Enable game master playing for player or to self:\n/gm [player_id]"}, gm_parse)

local function builder_parse(event)
  local player_index = event.player_index
  local command = event.name
  local parameters = event.parameter
  
  local player = game.players[player_index]
  
  local force_name = game.players[player_index].force.name
  local player_name = game.players[player_index].name
  if parameters then
    player_index = tonumber(string.find(parameters,"%d+"))
    player = game.players[player_index]
    force_name = player.force.name
    player_name = player.name
  end
  
  local force_builder = string_starts(force_name,"builder:")
  
  if not force_builder then
    player.force = get_or_create_builder_force(player)
  end
end

commands.add_command("builder", {"", "Enable builder playing for player or to self:\n/player [player_id]"}, builder_parse)

local function player_parse(event)
  local player_index = event.player_index
  local command = event.name
  local parameters = event.parameter
  
  local player = game.players[player_index]
  
  local force_name = player.force.name
  local player_name = player.name
  if parameters then
    player_index = tonumber(string.find(parameters,"%d+"))
    player = game.players[player_index]
    force_name = player.force.name
    player_name = player.name
  end
  
  local force_player = string_starts(force_name,"player:")
  
  if not force_player then
    player.force = get_or_create_player_force(player)
  end
end

commands.add_command("player", {"", "Enable character playing for player or to self:\n/player [player_id]"}, player_parse)

script.on_event(defines.events.on_player_changed_force, function(event)
  local player = game.players[event.player_index]
  
  local force_name = player.force.name
  
  local force_gm = string_starts(force_name,"gm")
  local force_player = string_starts(force_name,"player:")
  local force_builder = string_starts(force_name,"builder:")
  
  local last_gm = string_starts(event.force.name,"gm")
  local last_player = string_starts(event.force.name,"player:")
  local last_builder = string_starts(event.force.name,"builder:")
  
  if force_gm or force_builder then
    if not last_gm and not last_builder then
      scenario.detached["player:"..player.name..":"..player.tag] = player.character
      player.disassociate_character(scenario.detached["player:"..player.name..":"..player.tag])
      scenario.detached["player:"..player.name..":"..player.tag].force = get_or_create_player_force(player)
      player.set_controller{type = defines.controllers.god}
    end
    
    if force_gm then -- Init tiles trees ans so one
      if last_builder then
        BM.SaveBar(player)
      end
      GM.RestoreBar(player)
    elseif force_builder then -- Init buildings
      if last_gm then
        GM.SaveBar(player)
      end
      BM.RestoreBar(player)
    end
  elseif (not force_gm) and (not force_builder) and force_player then
    if last_builder then
      BM.SaveBar(player)
    end
    if last_gm then
      GM.SaveBar(player)
    end
    
    local lc =  scenario.detached["player:"..player.name..":"..player.tag]
    player.set_controller{type = defines.controllers.character, character = lc}
    --player.associate_character(lc)
  end
  
  game.print(event.tick.." player "..player.name.." is "..player.force.name)
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.players[event.player_index]
  local force_name = player.force.name
  
  --player.set_controller{type = defines.controllers.ghost}
  
  if not scenario.characters[player.name] then
    scenario.characters[player.name] = {}
    -- Show character creation menu
    -- | On done
    -- | Show character selection menu
    -- - On else
    player.tag = "Proste postava"
    scenario.characters[player.name][player.tag] = Character.new(player.tag)
    
    -- Detaching default character
    scenario.detached["player:"..player.name..":"..player.tag] = player.character
    --player.set_controller{type = defines.controllers.ghost}
    --player.disassociate_character(scenario.detached["player:"..player.name..":"..player.tag])
    
    player.force = get_or_create_player_force(player)
    get_or_create_builder_force(player)
  else
    -- Show character selection menu
    local characters = scenario.characters[player.name]
    for character_name, character in pairs(characters) do
    	-- Add to gui selection
    end
    player.tag = "Proste postava"
  end
  
  game.print("player "..player.name.." is "..force_name)
end)