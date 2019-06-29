require("src.entity")

local tiny = require("lib.tiny")
local systems = require("src.system")
local colors = require("src.colors")

-- Global
-- Bullet pools
maxBulletPool = 10
bulletPool = {}

for i = 1, maxBulletPool
do
    local bullet = Bullet:new("Bullet#"..i)
    bullet.position.x = -100
    bullet.active = false
    table.insert(bulletPool, bullet)
end

boundRight = 0
boundLeft = 0
boundUp = 0
boundDown = 0

-- Entity
local player = Player:new("Player1")
local enemy = Enemy:new("Enemy")
local box = Box:new("Box")
local box2 = Box:new("Box2")

-- World
world = tiny.world()

world:add(enemy, box, box2)
for i = 1, maxBulletPool
do
    world:add(bulletPool[i])
end

world:add(player)
world:add(
    systems.playerControlSystem,
    systems.playerFireAbilitySystem,
    systems.worldWarpAbilitySystem,
    systems.worldWarpableSystem,
    systems.boundSystem,
    systems.movementSystem,
    systems.drawEntitySystem,
    systems.bulletCleanUpSystem
)

-- Game Loop
local updateFilter = tiny.rejectAny("isDrawSystem")
local drawFilter = tiny.requireAll("isDrawSystem")

function love.load()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    local center = { x = width / 2, y = height / 2 }

    boundRight = width
    boundLeft = 0
    boundUp = 0
    boundDown = height

    player.position.x = center.x
    player.position.y = height - (player.size.height + 30)

    enemy.position.x = center.x
    enemy.position.y = enemy.size.height + 10
    enemy.worldWarpAble = true
    enemy.velocity.x = -enemy.speed

    box.position.x = 0 + box.size.width
    box.position.y = center.y
    box.color = colors.green
    box.size.width = 60
    box.size.height = 60
    box.velocity.x = box.speed
    box.velocity.y = box.speed

    box2.position.y = 0
    box2.color = colors.yellow
    box2.size.width = 50
    box2.size.height = 50
    box2.velocity.y = box2.speed
end

function love.keypressed(key, scancode, isRepeat)
    if key == "escape" then
        love.event.quit()
    end

    -- Toggle world wrap ability
    local ability = player.worldWarpAbility

    if key == "e" and ability.canUseAbility then
        ability.isToggleAbility = true
    end
end

function love.keyreleased(key, scancode, isRepeat)

end

function love.update(dt)
    world:update(dt, updateFilter)
end

function love.draw()
    local dt = love.timer.getDelta()
    world:update(dt, drawFilter)
    drawUI()
end

function drawUI()
    love.graphics.setColor({ 0, 0, 0, 0.5 })
    love.graphics.rectangle("fill", 0, love.graphics.getHeight() - 30, 70, 40)
    love.graphics.rectangle("fill", love.graphics.getWidth() - 60, 20, 80, 20)
    love.graphics.setColor(colors.white)
    love.graphics.print("HP : "..player.health, 10, love.graphics.getHeight() - 20)
    love.graphics.print("FPS : "..love.timer.getFPS(), love.graphics.getWidth() - 60, 20)
end

function love.resize(width, height)
    boundRight = width
    boundLeft = 0
    boundUp = 0
    boundDown = height
end

