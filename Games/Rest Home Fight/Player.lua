Player = Object:extend()

function Player:new(x, y, imgPath, left, right, up, down)
    self.x, self.y = x, y
    self.direction = 1
    self.velY = 0
    self.velX = 0
    self.velHoriz = 250
    self.velVert = 250
    self.velX = 0
    self.velY = 0
    self.animVel = 10
    self.quadQtd = 12

    self.left = left or 'left'
    self.right = right or 'right'
    self.up = up or 'up'
    self.down = down or 'down'
    self.jump = 'v'
    self.dtJump = 1
    self.isJumping = false

    self.image = love.graphics.newImage(imgPath)
    self.width = 150
    self.height = 300
    self.quad = love.graphics.newQuad(0, 0, self.width, self.height, self.image:getDimensions())
    self.currentImg = 0
    
    self.hitbox = HitBox(self.x, self.y, self.width*self.direction, self.height)
end

function Player:update(dt)
    if love.keyboard.isDown(self.left) and not love.keyboard.isDown(self.right) and self.isJumping == false then
        self:animate(dt)
        self:rotateLeft()
        self:moveLeft(dt)
    end
    if love.keyboard.isDown(self.right) and not love.keyboard.isDown(self.left) and self.isJumping == false then
        self:animate(dt)
        self:rotateRight()
        self:moveRight(dt)
    end
    if love.keyboard.isDown(self.jump) then
        self.isJumping = true
    end
    if love.keyboard.isDown(self.up) and not love.keyboard.isDown(self.down) then
        --self:animate(dt)
        --self:moveUp(dt)
    end
    if love.keyboard.isDown(self.down) and not love.keyboard.isDown(self.up) then
        --self:animate(dt)
        --self:moveDown(dt)
    end
    if not love.keyboard.isDown(self.left) and not love.keyboard.isDown(self.right) and not love.keyboard.isDown(self.down)and not love.keyboard.isDown(self.up) then
        self:stop()
    end
    self:jumpCheck(dt)
    self.hitbox:update(self.x, self.y, self.width*self.direction, self.height)
end

function Player:draw()
    self.hitbox:draw()
    love.graphics.draw(self.image,  self.quad, self.x, self.y, 0, self.direction, 1)
end

function Player:stop()
    local x, y, w, h = self.quad:getViewport()
    self.quad:setViewport(w*7, y, w, h)
end

function Player:animate(dt)
    local x, y, w, h = self.quad:getViewport()
    self.currentImg = self.currentImg + dt*self.animVel
    if self.currentImg >= self.quadQtd then
        self.currentImg = 0
    end
    self.quad:setViewport(w*math.floor(self.currentImg), y, w, h)
end

function Player:moveUp(dt)
    self.velY = -self.velVert
    self.y = self.y + self.velY*dt
end

function Player:moveDown(dt)
    self.velY = self.velVert
    self.y = self.y + self.velY*dt
end

function Player:moveLeft(dt)
    self.velX = -self.velHoriz
    self.x = self.x + self.velX*dt
end

function Player:moveRight(dt)
    self.velX = self.velHoriz
    self.x = self.x + self.velX*dt
end

function Player:jumpCheck(dt)
    if self.isJumping == true then
        self.velY = self.velVert * self.dtJump * 2 
        self.dtJump = self.dtJump - dt
        self.y = self.y - self.velY*dt
        self.velX = self.velHoriz * self.direction
        self.x = self.x + self.velX*dt
    end
    if self.dtJump <= -1 and self.isJumping == true then
        self.isJumping = false
        self.dtJump = 1
        self.velY = 0
    end
end

function Player:rotateLeft()
    if self.direction == 1 and self.isJumping == false then
        self.direction = -1
        self.x = self.x + self.width
    end
end

function Player:rotateRight()
    if self.direction == -1 and self.isJumping == false then
        self.direction = 1
        self.x = self.x - self.width
    end
end