Player = Object:extend()

function Player:new(x, y, imgPath, left, right, up, down)
    self.x, self.y = x, y
    self.direction = 1
    self.acelY = 0
    self.acelX = 0
    self.acelHoriz = aceleracao
    self.acelVert = aceleracao

    self.left = left or 'left'
    self.right = right or 'right'
    self.up = up or 'up'
    self.down = down or 'down'

    self.image = love.graphics.newImage(imgPath)
    self.width = quadWidth
    self.height = quadHeight
    self.quad = love.graphics.newQuad(0, 0, self.width, self.height, self.image:getDimensions())
    self.currentImg = 0
    
    self.hitbox = HitBox(self.x, self.y, self.width*self.direction, self.height)
end

function Player:update(dt)
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
    if not love.keyboard.isDown(self.left) and not love.keyboard.isDown(self.right) and not love.keyboard.isDown(self.down)and not love.keyboard.isDown(self.up) then
        self:stop()
    end
    self.hitbox:update(self.x, self.y, self.width*self.direction, self.height)
end

function Player:draw()
    self.hitbox:draw()
    love.graphics.draw(self.image,  self.quad, self.x, self.y, 0, self.direction)
end

function Player:stop()
    local x, y, w, h = self.quad:getViewport()
    self.quad:setViewport(w*7, y, w, h)
end

function Player:animate(dt)
    local x, y, w, h = self.quad:getViewport()
    self.currentImg = self.currentImg + dt*velocidadeAnimacao
    if self.currentImg >= qntQuads then
        self.currentImg = 0
    end
    self.quad:setViewport(w*math.floor(self.currentImg), y, w, h)
end

function Player:moveUp(dt)
    self.acelY = -self.acelVert
    self.y = self.y + self.acelY*dt
end

function Player:moveDown(dt)
    self.acelY = self.acelVert
    self.y = self.y + self.acelY*dt
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
        self.x = self.x + self.width
    end
end

function Player:rotateRight()
    if self.direction == -1 then
        self.direction = 1
        self.x = self.x - self.width
    end
end