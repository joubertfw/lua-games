Firework = Object:extend()

function Firework:new(x, y, direction, size)
    self.image = love.graphics.newImage("assets/image/shoot.png")    
    self.x = x
    self.y = y
    self.direction = direction
    self.velX = 7
    self.width = 57
    self.height = 9
    self.quad = love.graphics.newQuad(0, 0, self.width, self.height, self.image:getDimensions())
    self.currentImg = 0
    self.size = size
    self.movementDt = 1.0
    self.movementY = 1.0
    self.hitbox = HitBox(self.x - self.size*self.width*self.direction, self.y, self.size*self.width*self.direction, self.height)
end

function Firework:update(dt)
    self.movementDt = self.movementDt + dt

    if self.movementDt > 0.3 then
        self.movementDt = 0
        self.movementY = - self.movementY
    end

    self.y = self.y + self.movementY
    self.x = self.x + (self.direction*self.velX)
    self:animate(dt)
    self.hitbox:update(self.x - self.size*self.width*self.direction, self.y, self.size*self.width*self.direction, self.height)
end

function Firework:animate(dt)
    local x, y, w, h = self.quad:getViewport()
    self.currentImg = self.currentImg + dt*4
    if self.currentImg >= 6 then
        self.currentImg = 0
    end
    self.quad:setViewport(w*math.floor(self.currentImg), y, w, h)
end

function Firework:draw()
    love.graphics.draw(self.image, self.quad, self.x, self.y, 0, -self.direction*self.size, self.size)
    self.hitbox:draw()
end

function Firework:mustBeRemoved()
    if self.direction == 1 and self.x > love.graphics.getWidth() then
        return true
    elseif self.direction == -1 and self.x + self.width*self.size < 0 then
        return true
    end
    return false
end