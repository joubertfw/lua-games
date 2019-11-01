Player = Object:extend()

function Player:new(x, y, imgPath, left, right, up, down, shoot)
    self.x = x
    self.y = y
    self.direction = 1
    self.acelY = 0
    self.acelX = 0
    self.acelHoriz = 200
    self.acelVert = 150
    self.size = self.y*0.004
    self.life = 3
    self.gun = Gun()
    self.left = left or 'left'
    self.right = right or 'right'
    self.up = up or 'up'
    self.down = down or 'down'
    self.shoot = shoot or 'return'
    self.image = love.graphics.newImage(imgPath.. "/player.png")
    self.width = 150
    self.height = 150
    self.quad = love.graphics.newQuad(0, 0, self.width, self.height, self.image:getDimensions())
    self.currentImg = 0
    
    self.hitbox = HitBox(self.x + self.size*self.direction*self.width/3, self.y + self.size*20, self.width/2*self.direction*self.size, (self.height - 35)*self.size)
end

function Player:update(dt)
    self.gun:update(dt)
    if love.keyboard.isDown(self.left) and not love.keyboard.isDown(self.right) then
        self:animate(dt)
        self:rotateLeft()
        self:moveLeft(dt)
    end
    if love.keyboard.isDown(self.right) and not love.keyboard.isDown(self.left) then
        self:animate(dt)
        self:rotateRight()
        self:moveRight(dt)
    end

    if love.keyboard.isDown(self.up) and not love.keyboard.isDown(self.down) then
        self:animate(dt)
        self:moveUp(dt)
    end
    if love.keyboard.isDown(self.down) and not love.keyboard.isDown(self.up) then
        self:animate(dt)
        self:moveDown(dt)
    end
    if love.keyboard.isDown(self.shoot) then
        self.gun:shoot(self.x, self.y, self.direction, self.size, self.width, self.height)
    end
    if not love.keyboard.isDown(self.left) and not love.keyboard.isDown(self.right) and not love.keyboard.isDown(self.down)and not love.keyboard.isDown(self.up) then
        self:stop()
    end
    self.size = self.y*0.004
    self.hitbox:update(self.x + self.size*self.direction*self.width/3, self.y + self.size*60, self.width/2*self.direction*self.size, (self.height - 120)*self.size)
end

function Player:draw()
    self.hitbox:draw()
    self.gun:draw(self.quad, self.x, self.y, self.direction*self.size, self.size)
    love.graphics.draw(self.image,  self.quad, self.x, self.y, 0, self.direction*self.size, self.size)
    for i = 1, self.life do
        love.graphics.draw(love.graphics.newImage("assets/image/heart.png"), self.x + (i*25 + 30) *self.size*self.direction, self.y - self.height/8*self.size, 0, self.direction*self.size/7, self.size/7)
    end
end

function Player:stop()
    local x, y, w, h = self.quad:getViewport()
    self.quad:setViewport(w*7, y, w, h)
end

function Player:animate(dt)
    local x, y, w, h = self.quad:getViewport()
    self.currentImg = self.currentImg + dt*8
    if self.currentImg >= 7 then
        self.currentImg = 0
    end
    self.quad:setViewport(w*math.floor(self.currentImg), y, w, h)
end

function Player:moveUp(dt)
    self.acelY = -self.acelVert
    self.y = self.y + self.acelY*dt

    local extremidade = false
    if self.y < love.graphics.getHeight()/6 then
        self.y = love.graphics.getHeight()/6
        extremidade = true
    end
    if not extremidade then
        if self.direction == 1 then
            self.x = self.x + self.size
        else
            self.x = self.x - self.size
        end
    end
end

function Player:moveDown(dt)
    self.acelY = self.acelVert
    self.y = self.y + self.acelY*dt
    
    local extremidade = false
    if self.y + self.height*self.size > love.graphics.getHeight() then
        self.y = love.graphics.getHeight() - self.height*self.size
        extremidade = true
    end
    if not extremidade then
        if self.direction == 1 then
            self.x = self.x - self.size
        else
            self.x = self.x + self.size
        end
    end
end

function Player:moveLeft(dt)
    self.acelX = -self.acelHoriz
    self.x = self.x + self.acelX*dt
end

function Player:moveRight(dt)
    self.acelX = self.acelHoriz
    self.x = self.x + self.acelX*dt
end

function Player:rotateLeft()
    if self.direction == 1 then
        self.direction = -1
        self.x = self.x + self.width*self.size
    end
end

function Player:rotateRight()
    if self.direction == -1 then
        self.direction = 1
        self.x = self.x - self.width*self.size
    end
end