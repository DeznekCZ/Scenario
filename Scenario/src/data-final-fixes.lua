
local function string_starts(str_value, str_start)
  local i_start, _ = string.find(str_value,str_start)
  return i_start ~= nil and i_start == 1
end

for tech_name, tech_data in pairs(data.raw.technology) do
  tech_data.enabled = false
end

for tree_name, tree_data in pairs(data.raw.tree) do

  local tree_icon = tree_name
  if string.match(tree_name, "^dead[-]tree[-].*") ~= nil then
    tree_icon = "dead-tree" 
  end
  if string.match(tree_icon,".*red$") then
    tree_icon = string.gsub(tree_icon,"[-]red","")
  end
  if string.match(tree_icon,".*brown$") then
    tree_icon = string.gsub(tree_icon,"[-]brown","")
  end

  data:extend{
    {
      type = "item",
      name = tree_name.."-item",
      localised_name = { "entity-name."..tree_name },
      place_result = tree_name,
      stack_size = 100,
      flags = {
        "goes-to-quickbar"
      },
      icon = "__base__/graphics/icons/"..tree_icon..".png",
      icon_size = 32,
      energy_required = 0.5,
    },
    {
      type = "recipe",
      name = tree_name.."-recipe",
      ingredients = {{"raw-wood", 1}},
      result = tree_name.."-item",
      result_count = 100,
      icon = "__base__/graphics/icons/"..tree_icon..".png",
      icon_size = 32,
      enabled = false,
    }
  }
end