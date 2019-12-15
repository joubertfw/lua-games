Player = class('Player')
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
    dtAnimateHit = 0.3
}

function Player:initialize(x, y, imgPath, buttons, config)
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
    if config then --Quads-based image (spritesheet)
        self.image = Image(imgPath, config)
    else --Simple image
        self.image = Image(imgPath)
    end
    
    -- Attack and damage
    self.buttonRepeat = true
    self.hitbox = CollisionBox(0, 0, 0, 0)
    self.hurtbox = CollisionBox(0, 0, 0, 0, 'hurtbox')
end

function Player:update(dt)

    self.acel.x = 0
    self:animateIdle(dt)

    -- State-based manipulation
    if self:isOnFloor() then
        self.acel.y = 0
        self.vel.y = 0
    elseif self:isFalling() then
        self.acel.y = default.acelYOnFall
    end

    self:listenInput(dt)
    
    -- After attributes-manipulation update
    self.vel.x = (self.vel.x * 0.95) + self.acel.x * dt
    self.vel.y = self.vel.y + self.acel.y * dt
    self.position.y = self.position.y + self.vel.y * dt
    self.position.x = self.position.x + self.vel.x * dt

    -- Collision boxes updates
    self.hitbox:update(self.position.x + 10*self.direction, self.position.y + self.image.height/2.7, self.direction*(self.image.width/3 - 20), self.image.height/3.5)
    self.hurtbox:update(self.position.x + 10*self.direction, self.position.y + self.image.height/2.7, self.direction*(self.image.width/3 - 20), self.image.height/3.5)
end

function Player:draw()
    self.hitbox:draw()
    self.hurtbox:draw()
    self.image:draw(self.position.x, self.position.y, self.direction)
end

function Player:listenInput(dt)
    if love.keyboard.isDown(self.input.btLeft) and not love.keyboard.isDown(self.input.btRight) then
        self:moveLeft(dt)
        self:animate(dt)
        self.direction = -1
    end
    if love.keyboard.isDown(self.input.btRight) and not love.keyboard.isDown(self.input.btLeft) then
        self:moveRight(dt)
        self:animate(dt)
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

function Player:animateIdle(dt)
    local currentCol = self.image.currentCol + dt*self.image.animVel
    row = 0
    if currentCol > self.image.quadConfig.idleCols then
        currentCol = 0
    end
    if currentCol < 0 then
        currentCol = self.image.quadConfig.idleCols - 1
    end

    self.image:update(currentCol, row)
end

function Player:animate(dt)
    local currentCol = self.image.currentCol + dt*self.image.animVel
    row = self.image.height
    if currentCol > self.image.quadConfig.moveCols then
        currentCol = 0
    end
    if currentCol < 0 then
        currentCol = self.image.quadConfig.moveCols - 1
    end

    self.image:update(currentCol, row)
end

function Player:moveUp(dt)
    self.vel.y = -default.velVert
    self.position.y = self.position.y + self.vel.y*dt
end

function Player:moveDown(dt)
    self.vel.y = default.velVert
    self.position.y = self.position.y + self.vel.y*dt
end

function Player:moveLeft(dt)
    self.acel.x = -default.velHoriz
    if self.direction == 1 then
        self.position.x = self.position.x + self.hitbox.width*1.25
    end
    if self:isFalling() and self.buttonRepeat then
        self.acel.x = self.acel.x*2
    end
end

function Player:moveRight(dt)
    self.acel.x = default.velHoriz
    if self.direction == -1 then
        self.position.x = self.position.x - self.hitbox.width*1.25
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