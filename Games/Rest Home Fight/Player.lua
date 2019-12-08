Player = Object:extend()
local util = Util()

local default = {
    dtJump = 0.4,
    velHoriz = 900,
    velVert = 900,
    acelYOnJump = -3500,
    acelYOnFall = 2500,
    acelXOnHitted = 15000,
    acelYOnHitted = 8000,
    acelYOnSlide = 2000,
    animVel = 5,
    quadQtd = 10
}

function Player:new(x, y, imgPath, buttons)
    -- Position and movement
    self.x, self.y = x, y
    self.direction = 1
    self.velX = 0
    self.velY = 0
    self.acelX = 1
    self.acelY = 10
    self.dtJump = default.dtJump
    self.state = 'falling'
    self.stateHitted = 'none'
    self.stateHit = false
    self.hitRepeat = false
    self.spaceRepeat = true
    self.dtHit = 0
    self.dtTimeFly = 1
    self.dtProtected = 0

    -- Input
    self.input = Input(buttons)
    
    -- Quads and animation
    self.direction = 1
    self.animVel = default.animVel
    self.image = love.graphics.newImage(imgPath)
    self.quadQtd = default.quadQtd
    self.stopQuad = 4
    self.width = 160
    self.height = 240
    self.quad = love.graphics.newQuad(0, 0, self.width, self.height, self.image:getDimensions())
    self.currentImg = 0
    
    self.life = 100

    -- Hitboxes
    self.hurtboxY = 0
    self.hurtboxWidth = 0
    self.hurtboxHeight = 40
    self.hitbox = HitBox(self.x, self.y, self.width, self.height, 0)
    self.hurtbox = HitBox(self.x, self.y, 0, 0, 1)
end

function Player:update(dt)

    if not self:isOnFloor() --se nao ta no chao
        and not self:isSliding() -- nem escorregando
        and not self:isJumping() --nem pulando
        or self.dtJump < 0 --ou o pulo acabou
        or (self:isJumping() and not love.keyboard.isDown(self.input.btJump)) --ou tava pulando mas parou de apertar
        or (self.spaceRepeat and self.dtJump < default.dtJump and self:isJumping()) then
        self.spaceRepeat = true
        self:fall()
    else
        if self:isOnFloor() and self.dtJump >= default.dtJump and not love.keyboard.isDown(self.input.btJump) then
            self.spaceRepeat = false
        end
        if self:isOnFloor() and self.dtJump < 0 and love.keyboard.isDown(self.input.btJump) then
            self.velY = 0
        end
        if love.keyboard.isDown(self.input.btJump) and self.dtJump > 0 and not self.spaceRepeat then
            --jumping
            self.acelY = default.acelYOnJump
            self.dtJump = self.dtJump - dt
        else
            self.acelY = 0
            self.velY = 0
        end
        if self:isSliding() then
            self:slide()
            -- reseta pulo
            self.dtJump = default.dtJump
            self.spaceRepeat = false
        end
    end

    if love.keyboard.isDown(self.input.btPunch) then
        if (self.dtHit == 0 and not self.stateHit) then
            self.hurtboxWidth = self.width
            self.stateHit = true
        end
        self.hurtboxY = 40
    end
    if love.keyboard.isDown(self.input.btKick) then
        if (self.dtHit == 0 and not self.stateHit) then
            self.hurtboxWidth = self.width
            self.stateHit = true
        end
        self.hurtboxY = 150
    end

    if love.keyboard.isDown(self.input.btLeft) and not love.keyboard.isDown(self.input.btRight) then
        if not self:isSlidingLeft() then
            self:animate(dt)
            self:moveLeft(dt)
        end
        self.direction = -1
    end
    if love.keyboard.isDown(self.input.btRight) and not love.keyboard.isDown(self.input.btLeft) then
        if not self:isSlidingRight() then
            self:animate(dt)
            self:moveRight(dt)
        end
        self.direction = 1
    end
    if love.keyboard.isDown(self.input.btJump) and not self:isFalling() then
        self:setJumping()
        self:animateJump(dt)
    end
    if not self:isOnFloor() then
        self:animateJump()
    end
    
    if love.keyboard.isDown(self.input.btUp) and not love.keyboard.isDown(self.input.btDown) then
        --self:animate(dt)
        --self:moveUp(dt)
    end
    if love.keyboard.isDown(self.input.btDown) and not love.keyboard.isDown(self.input.btUp) then
        --self:animate(dt)
        --self:moveDown(dt)
    end

    if not love.keyboard.isDown(self.input.btPunch) and not love.keyboard.isDown(self.input.btKick) then
        self.hitRepeat = false
        self.stateHit = false
        self.dtHit = 0
        self.hurtboxWidth = 0
    end

    if (self.dtHit >= 0.4) then
        self.hurtboxWidth = 0
        self.dtHit = 0
        self.hitRepeat = true
    end
    
    if (self.stateHit == true and not self.hitRepeat) then
        self:animateHit(dt)
        self.dtTimeFly = 1
        self.dtHit = self.dtHit + dt
    end

    if (self.stateHitted == "left") then
        self.acelX = -default.acelXOnHitted
        self.acelY = -default.acelYOnHitted
    end
    if (self.stateHitted == "right") then
        self.acelX = default.acelXOnHitted
        self.acelY = -default.acelYOnHitted
    end
    
    self.velX = (self.velX * 0.95) + self.acelX * dt
    self.velY = (self.velY * 0.95) + self.acelY * dt
    self.y = self.y + self.velY * dt
    self.x = self.x + self.velX * dt

    -- hitboxes updates
    if self.direction == 1 then
        self.hitbox:update(self.x + 20, self.y, self.width - 90, self.height)
    else
        self.hitbox:update(self.x + 70, self.y, self.width - 90, self.height)
    end
    self.hurtbox:update(self.x + (self.direction*((self.width/2))) + 10, self.hurtboxY + self.y, self.hurtboxWidth, self.hurtboxHeight)

    if not love.keyboard.isDown(self.input.btLeft) 
        and not love.keyboard.isDown(self.input.btRight)
        and not love.keyboard.isDown(self.input.btDown)
        and not love.keyboard.isDown(self.input.btUp)
        and not love.keyboard.isDown(self.input.btKick)
        and not love.keyboard.isDown(self.input.btPunch) then
            if self:isOnFloor() then
                self:stop()
            end
        self.acelX = 0
    end
end

function Player:draw()
    self.hitbox:draw()
    self.hurtbox:draw()
    love.graphics.draw(self.image,  self.quad, self.x, self.y, 0)
    
    love.graphics.print("dtHit:" .. self.input.btKick, 50, 200)
end

function Player:stop(jumping)
    local x, y, w, h = self.quad:getViewport()
    if self.direction == 1 then 
        y = 0
        self.stopQuad = 5
    else
        y = h
        self.stopQuad = 4
    end
    self.quad:setViewport(w*self.stopQuad, y, w, h)
end

function Player:fall(resetVelY)
    if resetVelY then
        self.velY = 0
    end
    self.acelY = default.acelYOnFall
end

function Player:slide()
    self.acelY = default.acelYOnSlide
    self.acelX = 0
    self.velX = 0
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
    self.animVel = default.animVel
    self.currentImg = self.currentImg + self.direction*dt*self.animVel
    self.quadQtd = 9

    if self.currentImg > self.quadQtd then
        self.currentImg = 0
    end
    if self.currentImg < 0 then
        self.currentImg = self.quadQtd
    end

    self.quad:setViewport(w*math.floor(self.currentImg), y, w, h)
    self.animVel = default.animVel
    self.quadQtd = default.quadQtd
end

-- function Player:moveUp(dt)
--     self.velY = -self.velVert
--     self.y = self.y + self.velY*dt
-- end

-- function Player:moveDown(dt)
--     self.velY = self.velVert
--     self.y = self.y + self.velY*dt
-- end

function Player:moveLeft(dt)
    self.acelX = -default.velHoriz
    if self.direction == 1 then
        self.x = self.hitbox.x - self.hitbox.width
    end
    if self:isJumping() then
        self.acelX = self.acelX*2
    end
end

function Player:moveRight(dt)
    self.acelX = default.velHoriz
    if self.direction == -1 then
        self.x = self.hitbox.x - self.hitbox.width/3
    end
    if self:isJumping() then
        self.acelX = self.acelX*2
    end
end

function Player:isHitted(hurtBox, dt)
    self:setHittedNone()
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

function Player:isJumping()
    return self.state == 'jumping'
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

function Player:setJumping()
    self.state = 'jumping'
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