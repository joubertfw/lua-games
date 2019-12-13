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
    dtAnimateHit = 0.3
}

function Player:new(x, y, imgPath, buttons, config)
    -- Position and movement
    self.position = {[x] = x, [y] = y}
    self.vel = {x = 0, y = 0}
    self.acel = {x = 0, y = 0}
    self.dtJump = default.dtJump
    self.state = 'onFloor'
    self.direction = 1
    
    -- Input
    self.input = Input(buttons)
    
    -- Quads and animation
    self.imageObj = Image(imgPath, {quadWidth = 140, quadHeight = 210, animVel = 0, quadQtd = 0, stopQuad = 0})
    
    -- Attack and damage
    self.buttonRepeat = true
    self.hitbox = CollisionBox(self.x, self.y, self.width, self.height)
    self.hurtbox = CollisionBox(self.x, self.y, self.width, self.height, 'hurtbox')
end

function Player:update(dt)

    self:stop()

    -- State-based manipulation
    if self:isOnFloor() then
        self:animateJump(dt)
    elseif self:isJumping() then

    end

    self:listenInput(dt)
    
    -- After attributes-manipulation update
    self.velX = (self.velX * 0.95) + self.acelX * dt
    self.velY = self.velY + self.acelY * dt
    self.y = self.y + self.velY * dt
    self.x = self.x + self.velX * dt

    -- Collision boxes updates
    if self.direction == 1 then
        self.hitbox:update(self.x, self.y, self.width, self.height)
        self.hurtbox:update(self.x, self.y, self.width, self.height)
    else
        self.hitbox:update(self.x, self.y, self.width, self.height)
        self.hurtbox:update(self.x, self.y, self.width, self.height)
    end
end

function Player:draw()
    self.hitbox:draw()
    self.hurtbox:draw()
    self.imageObj:draw(self.x, self.y)
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

function Player:stop(jumping)
    local x, y, w, h = self.quad:getViewport()
    if self.direction == 1 then 
        y = 0
        stopQuad = 5
    else
        y = h
        stopQuad = 4
    end
    self.quad:setViewport(w*stopQuad, y, w, h)
end

function Player:animate(dt)
    local x, y, w, h = self.quad:getViewport()
    if self.direction == 1 then
        y = 0
    else
        y = h
    end

    self.currentImg = self.currentImg + self.direction*dt*self.animVel

    if self.currentImg > self.quadQtd then
        self.currentImg = 0
    end
    if self.currentImg < 0 then
        self.currentImg = self.quadQtd
    end
    self.quad:setViewport(w*math.floor(self.currentImg), y, w, h)
end

function Player:animateJump()
    local x, y, w, h = self.quad:getViewport()
    if self.direction == 1 then 
        y = 2*h
    else
        y = 3*h
    end
    self.quad:setViewport(w*9, y, w, h)
end

function Player:animateHit(dt)
    local x, y, w, h = self.quad:getViewport()
    if self.direction == 1 then
        y = 2*h
    else
        y = 3*h
    end
    self.currentImg = self.currentImg + self.direction*dt*(10/default.dtAnimateHit)

    if self.currentImg > default.quadHitQtd then
        self.currentImg = 0
    end
    if self.currentImg < 0 then
        self.currentImg = default.quadHitQtd
    end

    self.quad:setViewport(w*math.floor(self.currentImg), y, w, h)
end

function Player:moveLeft(dt)
    self.acelX = -default.velHoriz
    if self.direction == 1 then
        self.x = self.hitbox.x - self.hitbox.width
    end
    if self:isFalling() and self.buttonRepeat then
        self.acelX = self.acelX*2
    end
end

function Player:moveRight(dt)
    self.acelX = default.velHoriz
    if self.direction == -1 then
        self.x = self.hitbox.x - self.hitbox.width/3
    end
    if self:isFalling() and self.buttonRepeat then
        self.acelX = self.acelX*2
    end
end

function Player:isHitted(hurtBox, type, dt)
    self:setHittedNone()
    self.hittedMult = 1
    if type == "kick" then
        self.hittedMult = 4
    end 

    if (self.hitbox:checkColision(hurtBox)) then
        if (self.hitbox.x < hurtBox.x) then
            self:setHittedLeft()
        else
            self:setHittedRight()
        end
    end
end

function Player:isOnFloor()
    return self.state == 'onFloor'
end

function Player:isFalling()
    return self.state == 'falling'
end

function Player:isSliding()
    return self.state == 'slidingLeft' or self.state == 'slidingRight'
end

function Player:isSlidingLeft()
    return self.state == 'slidingLeft'
end

function Player:isSlidingRight()
    return self.state == 'slidingRight'
end

function Player:setSlidingLeft()
    self.state = 'slidingLeft'
end

function Player:setSlidingRight()
    self.state = 'slidingRight'
end

function Player:setOnFloor()
    self.dtJump = default.dtJump
    self.state = 'onFloor'
end

function Player:setFalling()
    self.state = 'falling'
end

function Player:setHittedLeft()
    self.stateHitted = 'left'
end

function Player:setHittedRight()
    self.stateHitted = 'right'
end

function Player:setHittedNone()
    self.stateHitted = 'none'
end