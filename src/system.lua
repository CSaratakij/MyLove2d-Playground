-- System
-- PlayerControl System
local tiny = require("lib.tiny")
local colors = require("src.colors")
local System = {}

local playerControlSystem = tiny.processingSystem()
playerControlSystem.filter = tiny.requireAll("controlable", "velocity")

function playerControlSystem:process(e, dt)
    if e.controlable then
        --Input Handler
        local input = { x = 0, y = 0 }

        if love.keyboard.isDown("w") then
            input.y = 1
        elseif love.keyboard.isDown("s") then
            input.y = -1
        else
            input.y = 0
        end

        if love.keyboard.isDown("d") then
            input.x = 1
        elseif love.keyboard.isDown("a") then
            input.x = -1
        else
            input.x = 0
        end

        local absX = math.abs(input.x)
        local absY = math.abs(input.y)
        local isDiagonalAxis = absX + absY > 1

        if isDiagonalAxis then
            local magnitude = math.sqrt((input.x * input.x) + (input.y * input.y))
            if magnitude > 1 then
                input.x = input.x / magnitude
                input.y = input.y / magnitude
            end
        end

        e.velocity.x = input.x * e.speed
        e.velocity.y = input.y * e.speed
    end
end

-- PlayerFireAbility System
local playerFireAbilitySystem = tiny.processingSystem()
playerFireAbilitySystem.filter = tiny.requireAll("controlable", "position", "size", "fireAbility")

function playerFireAbilitySystem:process(e, dt)
    local component = e.fireAbility

    if component.fireAble == false then
        return
    end

    if love.keyboard.isDown("up") then
        component.fireDirection.y = 1
        component.isFire = true
    elseif love.keyboard.isDown("down") then
        component.fireDirection.y = -1
        component.isFire = true
    else
        component.fireDirection.y = 0
    end

    if love.keyboard.isDown("left") then
        component.fireDirection.x = -1
        component.isFire = true
    elseif love.keyboard.isDown("right") then
        component.fireDirection.x = 1
        component.isFire = true
    else
        component.fireDirection.x = 0
    end

    local absX = math.abs(component.fireDirection.x)
    local absY = math.abs(component.fireDirection.y)

    if absX + absY == 0 then
        component.isFire = false
    end

    local canFire = component.isFire and component.current_fire_rate >= component.fireRate

    if canFire then
        for i = 1, maxBulletPool, 1
        do
            local bullet = bulletPool[i]
            if bullet.active == false then
                bullet.active = true

                bullet.position.x = (e.size.width / 2) - (bullet.size.width / 2) + e.position.x
                bullet.position.y = e.position.y + (e.size.height / 2)

                bullet.velocity.x = component.fireDirection.x * bullet.speed
                bullet.velocity.y = component.fireDirection.y * bullet.speed

                -- world:add(bullet)

                component.isFire = false
                component.current_fire_rate = 0
                break;
            end
        end
    end

    if component.current_fire_rate < component.fireRate then
        component.current_fire_rate = component.current_fire_rate + dt
    end
end

-- WorldWarpAbility System
local worldWarpAbilitySystem =  tiny.processingSystem()
worldWarpAbilitySystem.filter = tiny.requireAll("speed", "worldWarpAble", "worldWarpAbility")

function worldWarpAbilitySystem:process(e, dt)
    local component = e.worldWarpAbility

    if component.canUseAbility and component.isToggleAbility then
        component.isToggleAbility = false
        component.canUseAbility = false
        e.worldWarpAble = true
        e.speed = e.maxSpeed
    end

    if e.worldWarpAble and component.abilityTimeOut > 0 then
        component.abilityTimeOut = component.abilityTimeOut - dt
        e.color = colors.blue
    else
        e.worldWarpAble = false
        component.canUseAbility = true
        component.abilityTimeOut = component.maxAbilityTimeOut
        e.speed = e.normalSpeed
        e.color = colors.white
    end
end

-- World Wrap System
local worldWarpableSystem = tiny.processingSystem()
worldWarpableSystem.filter = tiny.requireAll("position", "velocity", "worldWarpAble")

function worldWarpableSystem:process(e, dt)
    if e.worldWarpAble == false then
        return
    end

    local offset = { x = e.size.width / 2, y = e.size.height / 2 }

    if e.position.x > boundRight - offset.x then
        e.position.x = (boundLeft - offset.x)
    elseif e.position.x < boundLeft - offset.x then
        e.position.x = (boundRight - offset.x)
    end

    if e.position.y > boundDown - offset.y then
        e.position.y = (boundUp - offset.y)
    elseif e.position.y < boundUp - offset.y then
        e.position.y = (boundDown - offset.y)
    end
end

-- Bound System
local boundSystem = tiny.processingSystem()
boundSystem.filter = tiny.requireAll("position", "velocity", tiny.requireAny("worldWarpAble"))

function boundSystem:process(e, dt)
    local nextLocation = {
        x = e.position.x + e.velocity.x * dt,
        y = e.position.y - e.velocity.y * dt
    }

    if e.worldWarpAble == nil or e.worldWarpAble == false then
        if nextLocation.x > boundRight - e.size.width then
            e.velocity.x = 0
            e.position.x = boundRight - e.size.width
        elseif nextLocation.x < boundLeft then
            e.velocity.x = 0
            e.position.x = boundLeft
        end

        if nextLocation.y < boundUp then
            e.velocity.y = 0
            e.position.y = boundUp
        elseif nextLocation.y > boundDown - e.size.height then
            e.velocity.y = 0
            e.position.y = boundDown - e.size.height
        end
    end
end


-- Movement System
local movementSystem = tiny.processingSystem()
movementSystem.filter = tiny.requireAll("position", "velocity")

function movementSystem:process(e, dt)
    if e.active == false then
        return
    end
    e.position.x = e.position.x + (e.velocity.x * dt)
    e.position.y = e.position.y - (e.velocity.y * dt)
    -- print(("Position : of %s is (%d, %d)"):format(e.name, e.position.x, e.position.y))
end

-- Draw System
local drawEntitySystem = tiny.processingSystem()
drawEntitySystem.filter = tiny.requireAll("position", "size", "shape", "color")
drawEntitySystem.isDrawSystem = true

function drawEntitySystem:process(e, dt)
    if e.active == false then
        return
    end
    love.graphics.setColor(e.color)
    if e.shape == "triangle" then
        local x1 = (e.position.x)
        local y1 = (e.position.y + e.size.height)
        local x2 = (e.position.x + e.size.width / 2)
        local y2 = (e.position.y - e.size.height)
        local x3 = (e.position.x + e.size.width)
        local y3 = (e.position.y + e.size.height)
        local vertices = { x1, y1, x2, y2, x3, y3 }
        love.graphics.polygon('fill', vertices)
    elseif e.shape == "rectangle" then
        love.graphics.rectangle("fill", e.position.x, e.position.y, e.size.width, e.size.height)
    elseif e.shape == "circle" then
        love.graphics.circle("fill", e.position.x, e.position.y, e.size.width)
    end
end

--CleanUp System
local bulletCleanUpSystem = tiny.processingSystem()
bulletCleanUpSystem.filter = tiny.requireAll("cleanAfterOutOfReach", "position", "velocity")

function bulletCleanUpSystem:process(e, dt)
    -- Test out of bound
    if e.position.y > love.graphics.getHeight() or e.position.y < 0 or
       e.position.x < 0 or e.position.x > love.graphics.getWidth() then
        e.active = false
        e.position.x = -100

        e.velocity.x = 0
        e.velocity.y = 0

        -- print(("Hide entity name : %s"):format(e.name))
        -- world:remove(e)
    end
end

System.playerControlSystem = playerControlSystem
System.playerFireAbilitySystem = playerFireAbilitySystem
System.worldWarpAbilitySystem = worldWarpAbilitySystem
System.worldWarpableSystem = worldWarpableSystem
System.boundSystem = boundSystem
System.movementSystem = movementSystem
System.drawEntitySystem = drawEntitySystem
System.bulletCleanUpSystem = bulletCleanUpSystem

return System

