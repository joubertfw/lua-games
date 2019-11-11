Player = Object:extend()

function Player:new(x, y, imgPath, buttons)
    self.x, self.y = x, y
    self.direction = 1
    self.velY = 0
    self.velX = 0
    self.velHoriz = 250
    self.velVert = 250
    self.velX = 0
    self.velY = 0
    self.animVel = 10
    self.quadQtd = 7

    self.input = Input(buttons)

    self.dtJump = 1
    self.isJumping = false
    self.screenPosition = 1
    self.inputDirection = 0

    self.image = love.graphics.newImage(imgPath)
    self.width = 150
    self.height = 300
    self.quad = love.graphics.newQuad(0, 0, self.width, self.height, self.image:getDimensions())
    self.currentImg = 0
    
    self.hitbox = HitBox(self.x, self.y, self.width*self.direction, self.height)
end

function Player:update(dt)
    if love.keyboard.isDown(self.btLeft) and not love.keyboard.isDown(self.btRight) and self.isJumping == false then
        self:animate(dt)
        self.inputDirection = -1
        --self:rotateLeft()
        self:moveLeft(dt)
    end
    if love.keyboard.isDown(self.btRight) and not love.keyboard.isDown(self.btLeft) and self.isJumping == false then
        self:animate(dt)
        self.inputDirection = 1
        --self:rotateRight()
        self:moveRight(dt)
    end
    if love.keyboard.isDown(self.btJump) then
        self.isJumping = true
    end
    if love.keyboard.isDown(self.btUp) and not love.keyboard.isDown(self.btDown) then
        --self:animate(dt)
        --self:moveUp(dt)
    end
    if love.keyboard.isDown(self.btDown) and not love.keyboard.isDown(self.btUp) then
        --self:animate(dt)
        --self:moveDown(dt)
    end
    if not love.keyboard.isDown(self.btLeft) and not love.keyboard.isDown(self.btRight) and not love.keyboard.isDown(self.btDown)and not love.keyboard.isDown(self.btUp) then
        self:stop()
    end
    self:jumpCheck(dt)
    self.hitbox:update(self.x, self.y, self.width*self.direction, self.height)
end

function Player:draw()
    self.hitbox:draw()
    love.graphics.draw(self.image,  self.quad, self.x, self.y, 0, self.direction, 1)
    love.graphics.print(self.direction, self.x, self.y)
end

function Player:stop()
    local x, y, w, h = self.quad:getViewport()
    self.quad:setViewport(w*7, y, w, h)
end

function Player:jump()
    local x, y, w, h = self.quad:getViewport()
    self.quad:setViewport(w*7, y, w, h)
end

function Player:animate(dt)
    local x, y, w, h = self.quad:getViewport()
    -- TODO: verificar se player 1 está se afastando de player 2
    if self.direction > 0 then
        self.currentImg = self.currentImg + dt*self.animVel
    else
        self.currentImg = self.currentImg - dt*self.animVel
    end

    if self.currentImg >= self.quadQtd and self.direction > 0 then
        self.currentImg = 0
    end
    if self.currentImg <= 0  and self.direction < 0 then
        self.currentImg = self.quadQtd
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
        self:jump()
        self.velY = self.velVert * self.dtJump * 2 
        self.dtJump = self.dtJump - dt
        self.y = self.y - self.velY*dt
        self.velX = self.velHoriz * self.inputDirection
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