Enemie = Object:extend()

function Enemie:new(x, y, imgPath, shootPosition)
    self.x = x
    self.y = y
    self.size = self.y*0.004
    self.direction = -1
    self.acelY = 0
    self.acelX = 0
    self.acelHoriz = 200
    self.acelVert = 150
    self.shootPosition = shootPosition
    self.gun = Gun()
    self.image = love.graphics.newImage(imgPath.. "/player.png")
    self.currentImg = 0
    self.width = 150
    self.height = 150
    self.dtShooting = 1.5
    self.quad = love.graphics.newQuad(0, 0, self.width, self.height, self.image:getDimensions())
    self.state = 'entering'

    self.hitbox = HitBox(self.x + self.size*self.direction*self.width/3, self.y + self.size*20, self.width/2*self.direction*self.size, (self.height - 35)*self.size)
end

function Enemie:update(dt)
    self.gun:update(dt)
    if self.state == 'entering' then
        self.size = self.y*0.004
        self:animate(dt)
        self.x = self.x + self.direction*self.acelHoriz*dt
        if self.direction == 1 and self.x >= self.shootPosition then
            self.state = 'shooting'
        elseif self.direction == -1 and self.x <= self.shootPosition then
            self.state = 'shooting'
        end
    elseif self.state == 'shooting' then
        if self.dtShooting == 1.5 then
            self:stop()
            self.gun:shoot(self.x, self.y, self.direction, self.size, self.width, self.height)
        end
        if self.dtShooting > 0 then
            self.dtShooting = self.dtShooting - dt
        else
            self.state = 'gettingAway'
            if self.direction == 1 then
                self:rotateLeft()
            else
                self:rotateRight()
            end
        end
     
    elseif self.state == 'gettingAway' then 
        self.size = self.y*0.004
        self:animate(dt)
        self.x = self.x + self.direction*self.acelHoriz*dt
    end
    self.hitbox:update(self.x + self.size*self.direction*self.width/3, self.y + self.size*60, self.width/2*self.direction*self.size, (self.height - 120)*self.size)
end

function Enemie:draw()
    self.hitbox:draw()
    love.graphics.draw(self.image,  self.quad, self.x, self.y, 0, self.direction*self.size, self.size)
    self.gun:draw(self.quad, self.x, self.y, self.direction*self.size, self.size)
end

function Enemie:stop()
    local x, y, w, h = self.quad:getViewport()
    self.quad:setViewport(w*7, y, w, h)
end

function Enemie:animate(dt)
    local x, y, w, h = self.quad:getViewport()
    self.currentImg = self.currentImg + dt*8
    if self.currentImg >= 7 then
        self.currentImg = 0
    end
    self.quad:setViewport(w*math.floor(self.currentImg), y, w, h)
end

function Enemie:rotateLeft()
    self.direction = -1
    self.x = self.x + self.width*self.size
end

function Enemie:rotateRight()
    self.direction = 1
    self.x = self.x - self.width*self.size
end

function Enemie:mustBeRemoved()
    if self.state ~= 'gettingAway' then
        return false
    end
    if self.direction == 1 and self.x > love.graphics.getWidth() then
        return true
    elseif self.direction == -1 and self.x + self.width*self.size < 0 then
        return true
    end
    return false
end