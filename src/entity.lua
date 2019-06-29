local entity = {}
local colors = require("src.colors")

Player = {}
function Player:new(name)
    local t = setmetatable({}, { __index = Player })
    t.active = true
    t.name = "Player"
    t.shape = "triangle"
    t.color = colors.white
    t.health = 100
    t.speed = 250
    t.normalSpeed = 250
    t.maxSpeed = 400
    t.position = { x = 0, y = 0 }
    t.velocity = { x = 0, y = 0 }
    t.size = { width = 30, height = 15 }
    t.controlable = true
    t.worldWarpAble = false
    t.worldWarpAbility = {
        isToggleAbility = false,
        canUseAbility = true,
        abilityTimeOut = 1,
        maxAbilityTimeOut = 1
    }
    t.fireAbility = {
        fireAble = true,
        isFire = false,
        fireRate = 0.25,
        current_fire_rate = 0.25,
        fireDirection = { x = 0, y = 1 }
    }
    return t
end

Enemy = {}
function Enemy:new(name)
    local t = setmetatable({}, { __index = Enemy })
    t.active = true
    t.name = (name or "Enemy")
    t.shape = "circle"
    t.color = colors.white
    t.health = 100
    t.speed = 250
    t.position = { x = 0, y = 0 }
    t.velocity = { x = 0, y = 0 }
    t.size = { width = 30, height = 30 }
    t.worldWarpAble = false
    return t
end

Bullet = {}
function Bullet:new(name)
    local t = setmetatable({}, { __index = Bullet })
    t.name = (name or "Bullet")
    t.active = false
    t.shape = "rectangle"
    t.color = colors.red
    t.speed = 400
    t.position = { x = 0, y = 0 }
    t.velocity = { x = 0, y = 0 }
    t.size = { width = 10, height = 10 }
    t.cleanAfterOutOfReach = true
    return t
end

Box = {}
function Box:new(name)
    local t = setmetatable({}, { __index = Box })
    t.name = (name or "Box")
    t.active = true
    t.shape = "rectangle"
    t.color = colors.white
    t.speed = 300
    t.position = { x = 0, y = 0 }
    t.velocity = { x = 0, y = 0 }
    t.size = { width = 10, height = 10 }
    t.worldWarpAble = true
    return t
end

function Box:size(w, h)
    self.size.width = w
    self.size.height = h
end

return entity

