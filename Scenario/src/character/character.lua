Character = {
  name = "no_name"
}

Character.__index = Character

setmetatable(Character, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function Character.new(name)
  local self = setmetatable({}, Character)
  self.name = name;
  self.skills = {}
  self.stats = {}
  return self
end

function Character.restore(data)
  local newCharacter = Character.new()
  newCharacter.name = data.name
  newCharacter.skills = data.skills
  newCharacter.stats = data.stats
  return newCharacter
end

function Character:SetSkill(skill_name, skill_level)
  
end

function Character:GetSkill(skill_name, skill_level)
  
end