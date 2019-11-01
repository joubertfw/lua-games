Gun = Object:extend()

function Gun:new()
    self.image = love.graphics.newImage("assets/image/gun2.png")
    self.fireworks = {}
    self.currentImg = 0
    self.shootDt = 0
end

function Gun:update(dt)
    self.shootDt = self.shootDt - dt
    for i, firework in pairs(self.fireworks) do
        firework:update(dt)
        if firework:mustBeRemoved() then
            table.remove(self.fireworks, i)
        end
    end
end

function Gun:draw(quad, x, y, direction, size)
    for i, firework in pairs(self.fireworks) do
        firework:draw()
    end
    love.graphics.draw(self.image, quad, x, y, 0, direction, size)
end

function Gun:shoot(x, y, direction, size, width, height)
    if self.shootDt <= 0 then
        local firework = Firework(x + ((width)*direction*size), y + (height/2)*size, direction, size)
        table.insert(self.fireworks, firework)
        self.shootDt = 2
    end
end

