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

function Player:new(x, y, imgPath, imgIndicator, buttons)
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
    self.dtProtected = 0
    self.indicator = false

    -- Input
    self.input = Input(buttons)
    
    -- Quads and animation
    self.direction = 1
    self.animVel = default.animVel
    self.image = love.graphics.newImage(imgPath)
    self.imageIndicator = love.graphics.newImage(imgIndicator)
    self.quadQtd = default.quadQtd
    self.width = 140
    self.height = 210
    self.quad = love.graphics.newQuad(0, 0, self.width, self.height, self.image:getDimensions())
    self.currentImg = 0
    self.dtAnimateHit = 0

    self.life = 100

    -- Hitboxes
    self.hurtboxY = 0
    self.hurtboxWidth = 0
    self.hurtboxHeight = 40
    self.hitbox = HitBox(self.x, self.y, self.width, self.height, 0)
    self.hurtbox = HitBox(self.x, self.y, 0, 0, 1)
    self.hitType = "punch"
    self.hittedMult = 1
end

function Player:update(dt)

    self.acelX = 0
    self:stop()
    self.acelY = default.acelYOnFall
    self.indicator = self.x < 0 or self.x > love.graphics.getWidth()

    if love.keyboard.isDown(self.input.btJump) and not self.spaceRepeat then
        self.velY = self:isSliding() and default.velYOnJump * 1.5 or default.velYOnJump
        self.spaceRepeat = true
    elseif self:isOnFloor() and self.velY >= 0 then
        self.velY = 0
        self.acelY = 0
        if not love.keyboard.isDown(self.input.btJump) then
            self.spaceRepeat = false
        end
    elseif self:isSliding() then
        self:slide()
        if not love.keyboard.isDown(self.input.btJump) then
            self.spaceRepeat = false
        end
    end

    if love.keyboard.isDown(self.input.btPunch) then
        if (self.dtHit == 0 and not self.stateHit) then
            self.hurtboxWidth = self.width/2
            self.stateHit = true
        end
        self.hurtboxY = 40
        self.hitType = "punch"
    end
    if love.keyboard.isDown(self.input.btKick) then
        if (self.dtHit == 0 and not self.stateHit) then
            self.hurtboxWidth = self.width/2
            self.stateHit = true
        end
        self.hurtboxY = 150
        self.hitType = "kick"
    end

    if self:isFalling() then
        self:animateJump(dt)
    end

    if love.keyboard.isDown(self.input.btLeft) and not love.keyboard.isDown(self.input.btRight) then
        if not self:isSlidingLeft() then
            if not self:isFalling() then
                self:animate(dt)
            end
            self:moveLeft(dt)
        end
        self.direction = -1
    end
    if love.keyboard.isDown(self.input.btRight) and not love.keyboard.isDown(self.input.btLeft) then
        if not self:isSlidingRight() then
            if not self:isFalling() then
                self:animate(dt)
            end
            self:moveRight(dt)
        end
        self.direction = 1
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

    if self.dtAnimateHit > 0 then
        self.dtAnimateHit = self.dtAnimateHit - dt
        self:animateHit(dt)
    end
    if (self.stateHit == true and not self.hitRepeat) then
        self.dtHit = self.dtHit + dt
        if self.dtAnimateHit <= 0 then
            self.dtAnimateHit = default.dtAnimateHit
            self.currentImg = 0
        end
    end

    if (self.stateHitted == "left") then
        self.acelX = -default.acelXOnHitted*self.hittedMult
        self.acelY = -default.acelYOnHitted
    end

    if (self.stateHitted == "right") then
        self.acelX = default.acelXOnHitted*self.hittedMult
        self.acelY = -default.acelYOnHitted
    end

    
    self.velX = (self.velX * 0.95) + self.acelX * dt
    self.velY = ( self.acelY * dt) + (self:isSliding() and self.velY  * default.atritoSlide or self.velY)
    self.y = self.y + self.velY * dt
    self.x = self.x + self.velX * dt

    -- hitboxes updates
    if self.direction == 1 then
        self.hitbox:update(self.x + 20, self.y, self.width - 90, self.height)
        self.hurtbox:update(self.x + (self.direction*((self.width/2))), self.hurtboxY + self.y, self.hurtboxWidth, self.hurtboxHeight)
    else
        self.hitbox:update(self.x + 70, self.y, self.width - 90, self.height)
        self.hurtbox:update(self.x, self.hurtboxY + self.y, self.hurtboxWidth, self.hurtboxHeight)
    end
end

function Player:draw()
    self.hitbox:draw()
    self.hurtbox:draw()
    love.graphics.draw(self.image,  self.quad, self.x, self.y, 0)

    if self.indicator then
        local scale = self.x < 0 and 0.4 + (self.x*0.0005) or 0.4 - ((self.x - love.graphics.getWidth())*0.0005)
        love.graphics.print("SCALE:" .. scale, 800, 500)
        love.graphics.draw(self.imageIndicator, self.x < 0 and 0 or love.graphics.getWidth() - (self.imageIndicator:getWidth()*scale), self.y, 0, scale,  scale)
    end
    
    love.graphics.print("dtHit:" .. self.input.btKick, 50, 200)
end

function Player:stop(jumping)
    local x, y, w, h = self.quad:getViewport()
    local stopQuad
    if self.direction == 1 then 
        y = 0
        stopQuad = 5
    else
        y = h
        stopQuad = 4
    end
    self.quad:setViewport(w*stopQuad, y, w, h)
end

function Player:fall(resetVelY)
    if resetVelY then
        self.velY = 0
    end
    self.acelY = default.acelYOnFall
end

function Player:slide()
    --self.acelY = default.acelYOnSlide
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
    self.currentImg = self.currentImg + self.direction*dt*(10/default.dtAnimateHit)

    if self.currentImg > default.quadHitQtd then
        self.currentImg = 0
    end
    if self.currentImg < 0 then
        self.currentImg = default.quadHitQtd
    end

    self.quad:setViewport(w*math.floor(self.currentImg), y, w, h)
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
    if self:isFalling() and self.spaceRepeat then
        self.acelX = self.acelX*2
    end
end

function Player:moveRight(dt)
    self.acelX = default.velHoriz
    if self.direction == -1 then
        self.x = self.hitbox.x - self.hitbox.width/3
    end
    if self:isFalling() and self.spaceRepeat then
        self.acelX = self.acelX*2
    end
end

function Player:isHitted(hurtBox, type, dt)
    self:setHittedNone()
    self.hittedMult = 1
    if type == "kick" then
        self.hittedMult = 2
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