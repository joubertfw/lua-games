Player = Object:extend()
local util = Util()

local default = {
    dtJump = 0.4,
    velHoriz = 900,
    velVert = 900,
    velYOnJump = -1200,
    acelYOnFall = 2000,
    acelXOnHitted = 15000,
    acelYOnHitted = 8000,
    atritoSlide = 0.75,
    animVel = 5,
    quadQtd = 10,
    quadHitQtd = 9,
    dtAnimateHit = 0.3,
}

function Player:new(x, y, imgPath, buttons, config)
    -- Position and movement
    self.position = {x = x, y = y}
    self.vel = {x = 0, y = 0}
    self.acel = {x = 0, y = 0}
    self.dtJump = default.dtJump
    self.state = 'onFloor'
    self.direction = 1

    -- Input
    self.input = Input(buttons)
    
    -- Quads and animation
    if config.image then --Quads-based image (spritesheet)
        self.imageObj = Image(imgPath, config.image)
    else --Simple image
        self.imageObj = Image(imgPath)
    end
    
    -- Attack and damage
    self.buttonRepeat = true
    self.hitbox = CollisionBox(self.position.x, self.position.y, self.imageObj.width, self.imageObj.height)
    self.hurtbox = CollisionBox(self.position.x, self.position.y, self.imageObj.width, self.imageObj.height, 'hurtbox')
end

function Player:update(dt)

    self.acel.x = 0
    self:stop()

    -- State-based manipulation
    if self:isOnFloor() then
        self:animate(dt)
        self.acel.y = 0
        self.vel.y = 0
    elseif self:isFalling() then
        self:animate(dt)
        self.acel.y = default.acelYOnFall
    end

    self:listenInput(dt)
    
    -- After attributes-manipulation update
    self.vel.x = (self.vel.x * 0.95) + self.acel.x * dt
    self.vel.y = self.vel.y + self.acel.y * dt
    self.position.y = self.position.y + self.vel.y * dt
    self.position.x = self.position.x + self.vel.x * dt

    -- Collision boxes updates
    if self.direction == 1 then
        self.hitbox:update(self.position.x, self.position.y, self.imageObj.width, self.imageObj.height)
        self.hurtbox:update(self.position.x, self.position.y, self.imageObj.width, self.imageObj.height)
    else
        self.hitbox:update(self.position.x, self.position.y, self.imageObj.width, self.imageObj.height)
        self.hurtbox:update(self.position.x, self.position.y, self.imageObj.width, self.imageObj.height)
    end
end

function Player:draw()
    self.hitbox:draw()
    self.hurtbox:draw()
    self.imageObj:draw(self.position.x, self.position.y)
end

function Player:listenInput(dt)
    if love.keyboard.isDown(self.input.btLeft) and not love.keyboard.isDown(self.input.btRight) then
        self:animate(dt)
        self:moveLeft(dt)
        self.direction = -1
    end
    if love.keyboard.isDown(self.input.btRight) and not love.keyboard.isDown(self.input.btLeft) then
        self:animate(dt)
        self:moveRight(dt)
        self.direction = 1
    end
    if love.keyboard.isDown(self.input.btUp) and not love.keyboard.isDown(self.input.btDown) then
        self:animate(dt)
        self:moveUp(dt)
    end
    if love.keyboard.isDown(self.input.btDown) and not love.keyboard.isDown(self.input.btUp) then
        self:animate(dt)
        self:moveDown(dt)
    end
end

function Player:stop()
    local stopQuad
    if self.direction == 1 then 
        y = 0
        stopQuad = 5
    else
        y = self.imageObj.height
        stopQuad = 4
    end
    self.imageObj:update(stopQuad, y)
end

function Player:animate(dt)
    if self.direction == 1 then
        y = 0
    else
        y = self.imageObj.height
    end

    local currentImg = self.imageObj.currentImg + self.direction*dt*self.imageObj.animVel

    if currentImg > self.imageObj.quadQtd then
        currentImg = 0
    end
    if currentImg < 0 then
        currentImg = self.imageObj.quadQtd
    end
    self.imageObj:update(currentImg, y)
end

function Player:moveUp(dt)
    self.vel.y = -default.velVert
    self.y = self.y + self.vel.y*dt
end

function Player:moveDown(dt)
    self.vel.y = default.velVert
    self.y = self.y + self.vel.y*dt
end

function Player:moveLeft(dt)
    self.acel.x = -default.velHoriz
    if self.direction == 1 then
        self.position.x = self.hitbox.x - self.hitbox.width
    end
    if self:isFalling() and self.buttonRepeat then
        self.acel.x = self.acel.x*2
    end
end

function Player:moveRight(dt)
    self.acel.x = default.velHoriz
    if self.direction == -1 then
        self.position.x = self.hitbox.x - self.hitbox.width/3
    end
    if self:isFalling() and self.buttonRepeat then
        self.acel.x = self.acel.x*2
    end
end

function Player:isOnFloor()
    return self.state == 'onFloor'
end

function Player:isFalling()
    return self.state == 'falling'
end

function Player:setOnFloor()
    self.dtJump = default.dtJump
    self.state = 'onFloor'
end

function Player:setFalling()
    self.state = 'falling'
end