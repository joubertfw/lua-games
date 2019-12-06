Player = Object:extend()
local util = Util()

local hit = ""

function Player:new(x, y, imgPath, buttons)
    -- Position and movement
    self.x, self.y = x, y
    self.direction = 1
    self.velHoriz = 900
    self.velVert = 900
    self.velX = 0
    self.velY = 0
    self.acelX = 1
    self.acelY = 10
    self:resetDtJump()
    self.dtJump = -1
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
    self:resetAnimVel()
    self.image = love.graphics.newImage(imgPath)
    self:resetQuadQTD()
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
    self.hitbox = HitBox(self.x, self.y, self.width*self.direction, self.height, 0)
    self.hurtbox = HitBox(self.x, self.y, 0, 0, 1)
end

function Player:update(dt)

    if not self:isOnFloor() and not self:isJumping() or self.dtJump < 0 or (self:isJumping() and not love.keyboard.isDown(self.input.btJump)) or (self.spaceRepeat and self.dtJump < 0.5 and self:isJumping()) then
        self.spaceRepeat = true
        --falling
        self.acelY = 2000
    else
        if self:isOnFloor() and self.dtJump >= 0.5 and not love.keyboard.isDown(self.input.btJump) then
            self.spaceRepeat = false
        end
        if self:isOnFloor() and self.dtJump < 0 and love.keyboard.isDown(self.input.btJump) then
            self.velY = 0
        end
        if love.keyboard.isDown(self.input.btJump) and self.dtJump > 0 and not self.spaceRepeat then
            --jumping
            self.acelY = -3500
            self.dtJump = self.dtJump - dt
        else
            self.acelY = 0
            self.velY = 0
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
        self.direction = -1
        self:animate(dt)
        self:moveLeft(dt)
    end
    if love.keyboard.isDown(self.input.btRight) and not love.keyboard.isDown(self.input.btLeft) then
        self.direction = 1
        self:animate(dt)
        self:moveRight(dt)
    end
    if love.keyboard.isDown(self.input.btJump) and not self:isFalling() then
        self:setJumping()
        self:jump(dt)
        self:animate(dt)
    end
    if not self:isOnFloor() then
        self:stop(true)
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
        self.acelX = -15000
        self.acelY = -8000
    end
    if (self.stateHitted == "right") then
        self.acelX = 15000
        self.acelY = -8000
    end
    
    self.velX = (self.velX * 0.95) + self.acelX * dt
    self.velY = (self.velY * 0.95) + self.acelY * dt
    self.y = self.y + self.velY * dt
    self.x = self.x + self.velX * dt

    -- hitboxes updates
    self.hitbox:update(self.x, self.y, self.width, self.height)
    self.hurtbox:update(self.x + (self.direction*((self.width/2))) + 10, self.hurtboxY + self.y, self.hurtboxWidth, self.hurtboxHeight)

    if not love.keyboard.isDown(self.input.btLeft) 
        and not love.keyboard.isDown(self.input.btRight) 
        and not love.keyboard.isDown(self.input.btDown)
        and not love.keyboard.isDown(self.input.btUp) 
        and not love.keyboard.isDown(self.input.btKick)
        and not love.keyboard.isDown(self.input.btPunch) then
        self:stop()
        self.acelX = 0
    end
end

function Player:draw()
    self.hitbox:draw()
    self.hurtbox:draw()
    love.graphics.draw(self.image,  self.quad, self.x, self.y, 0)
    -- love.graphics.print(self.direction, self.x, self.y)
    -- love.graphics.print(self.state, self.x, self.y + self.height + 5)
    --love.graphics.print("stateHit:" .. self.stateHit , 50, 150)
    -- love.graphics.print("dtHit:" .. self.dtHit, 50, 200)
    -- love.graphics.print("HIT:" .. hit, 50, 50)

    
    love.graphics.print("dtHit:" .. self.input.btKick, 50, 200)
end

function Player:stop(jumping)
    -- TODO: Criar frame fixo de jump
    local x, y, w, h = self.quad:getViewport()
    if self.direction == 1 then 
        self.stopQuad = 5
    else
        self.stopQuad = 4
    end
    self.quad:setViewport(w*self.stopQuad, y, w, h)
end

function Player:fall(dt)

end

function Player:jump(dt)
    
end

function Player:resetQuadQTD()
    self.quadQtd = 10
end

function Player:resetDtJump()
    self.dtJump = 0.5
end

function Player:resetAnimVel()
    self.animVel = 10
end

function Player:animate(dt)
    local x, y, w, h = self.quad:getViewport()
    if self.direction == 1 then
        y = 0
    else
        y = h
    end

    -- if self.stateHit then
    --     self.animVel = 20
    --     y = y + h*2
    --     self.quadQtd = 9
    -- else
    --     self:resetQuadQTD()
    --     self:resetAnimVel()
    -- end

    self.currentImg = self.currentImg + self.direction*dt*self.animVel

    if self.currentImg > self.quadQtd then
        self.currentImg = 0
    end
    if self.currentImg < 0 then
        self.currentImg = self.quadQtd
    end
    self.quad:setViewport(w*math.floor(self.currentImg), y, w, h)
end

function Player:animateHit(dt)
    local x, y, w, h = self.quad:getViewport()
    if self.direction == 1 then
        y = 2*h
    else
        y = 3*h
    end
    self.animVel = 10
    self.currentImg = self.currentImg + self.direction*dt*self.animVel
    self.quadQtd = 9

    if self.currentImg > self.quadQtd then
        self.currentImg = 0
    end
    if self.currentImg < 0 then
        self.currentImg = self.quadQtd
    end

    self.quad:setViewport(w*math.floor(self.currentImg), y, w, h)
    
    self:resetQuadQTD()
    self:resetAnimVel()
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
    self.acelX = -self.velHoriz
    if self:isJumping() then
        self.acelX = self.acelX*2
    end
end

function Player:moveRight(dt)
    self.acelX = self.velHoriz
    if self:isJumping() then
        self.acelX = self.acelX*1.5
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

function Player:setOnFloor()
    self:resetDtJump()
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