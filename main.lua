require "vector2d"
require "particle"
require "keyRepeatEvent"

particles = {}
newParticle = nil

G = 500
mass = 10

centerModes = {"Center of Mass", "Largest Object"}
cMode = 1

increaseMassKey = keyRepeatEvent:new(function(args) return (args[0] + 1) end)
decreaseMassKey = keyRepeatEvent:new(function(args) return math.max(args[0] - 1, 1) end)

screen = {}

clicked = {
    [1] = {
        state = false
    },
    [2] = {
        state = false
    },
    [3] = {
        state = false
    }
}

function dist(x, y, h, k)
    return math.pow(math.pow(x - h, 2) + math.pow(y - k, 2), 0.5)
end

function delete(tbl, obj)
    for i, value in ipairs(tbl) do
        if value == obj then
            table.remove(tbl, i)
        end
    end
end

function biggest(particles)
    local biggestP = particles[1]
    for i, p in ipairs(particles) do
        if p.mass > biggestP.mass then
            biggestP = p
        end
    end

    return biggestP
end

function COG(particles)
    local sumPos = Vector2d:new(0, 0)
    local totalMass = 0
    for i, p in ipairs(particles) do
        totalMass = totalMass + p.mass
        sumPos = vSum(sumPos, vProduct(p.position, p.mass))
    end

    sumPos = vProduct(sumPos, 1 / totalMass)
    return sumPos
end

function love.load()
    screen.width = love.graphics.getWidth()
    screen.height = love.graphics.getHeight()
end

function love.update(dt)
    center = centerModes[cMode]

    newMass = increaseMassKey:run(love.keyboard.isDown("up"), dt, {[0] = mass})
    if newMass ~= nil then
        mass = newMass
    end

    newMass = decreaseMassKey:run(love.keyboard.isDown("down"), dt, {[0] = mass,})
    if newMass ~= nil then
        mass = newMass
    end

    xDis = 0
    yDis = 0
    mDis = Vector2d:new(0, 0)
    if #particles > 0  then
        if center == "Largest Object" then
            biggestP = biggest(particles)
            xDis = screen.width / 2 - biggestP:X()
            yDis = screen.height / 2 - biggestP:Y()
            mDis = vProduct(biggestP.momentum, -1)
        elseif center == "Center of Mass" then
            centerPoint = COG(particles)
            xDis = screen.width / 2 - centerPoint.x
            yDis = screen.height / 2 - centerPoint.y
            if prevCenter ~= nil then
                mDis = vProduct(vSum(centerPoint, vProduct(prevCenter, -1)), -1)
            end

            prevCenter = centerPoint
        end
    end

    if clicked[1].state == "pressed" then
        clicked[1].state = "held"
        newParticle = Particle:new(clicked[1].position, mass, Vector2d:new(0, 0))
    end

    if clicked[1].state == "held" then
        newMomentum = vProduct(vSum(newParticle.position, vProduct(Vector2d:new(love.mouse.getX(),  love.mouse.getY()), -1)), -1 * dt)
        newParticle.momentum = newMomentum
    end

    if newParticle ~= nil then
        newParticle.mass = mass
    end

    if clicked[1].state == "released" then
        clicked[1].state = "unpressed"
        if newParticle ~= nil then
            newParticle.position = vSum(newParticle.position, vProduct(Vector2d:new(xDis, yDis), -1))
            newParticle.momentum = vSum(newParticle.momentum, vProduct(mDis, -1))
            table.insert(particles, newParticle)
            newParticle = nil
        end
    end

    -- calculate momentums
    for i, p in ipairs(particles) do
        for ii, p2 in ipairs(particles) do
            if p ~= p2 then
                force = G * dt * p.mass * p2.mass / math.pow(dist(p:X(), p:Y(), p2:X(), p2:Y()), 2) / p.mass
                direction = vSum(p2.position, vProduct(p.position, -1)):angle()
                newMomentum = vFromPolar(force, direction)
                p.momentum = vSum(p.momentum, newMomentum)
            end
        end
    end

    -- combine particles that collide
    for i, p in ipairs(particles) do
        for ii, p2 in ipairs(particles) do
            if p ~= p2 and dist(p:X(), p:Y(), p2:X(), p2:Y()) < math.max(p.mass, p2.mass) then
                if p.mass > p2.mass then
                    larger = p
                    smaller = p2
                else
                    larger = p2
                    smaller = p
                end

                avgMass = p.mass + p2.mass / 2
                direction = vSum(smaller.position, vProduct(larger.position, -1)):angle()
                newPos = vSum(larger.position, vFromPolar(smaller.mass, direction))
                table.insert(particles, Particle:new(newPos, p.mass + p2.mass, vSum(vProduct(p.momentum, p.mass / avgMass), vProduct(p2.momentum, p2.mass / avgMass))))
                delete(particles, p)
                delete(particles, p2)
            end
        end
    end

    -- update particles' positions
    for i, p in ipairs(particles) do
        p:update()
    end
end

function drawCircle(x, y, radius)
    love.graphics.circle("fill", x, y, radius)
    love.graphics.circle("line", x, y, radius)
end

function love.draw(dt)
    -- draw background
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, screen.width, screen.height)

    love.graphics.setColor(0, 0, 0)
    love.graphics.print("New particle mass: " .. tostring(mass), 5, 5)
    love.graphics.print("Centered on: " .. center, 5, 25)

    for i, particle in ipairs(particles) do
        drawCircle(particle:X() + xDis, particle:Y() + yDis, particle.mass)
    end

    love.graphics.setColor(0.4, 0.4, 0.4)
    if newParticle ~= nil then
        drawCircle(newParticle:X(), newParticle:Y(), newParticle.mass)
        love.graphics.line(newParticle:X(), newParticle:Y(), love.mouse.getX(), love.mouse.getY())
    end
end

function love.mousepressed(x, y, button)
    clicked[button] = {
        state = "pressed",
        position = Vector2d:new(x, y),
    }
end

function love.mousereleased(x, y, button)
    clicked[button] = {
        state = "released",
        position = Vector2d:new(x, y),
    }
end

function love.keypressed(key)
    if key == "escape" or key == "q" then
        love.event.push("quit")
    elseif key == "r" then
        particles = {}
    elseif key == "c" then
        cMode = cMode % #centerModes + 1
    end
end

