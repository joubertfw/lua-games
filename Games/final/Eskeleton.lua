Eskeleton = class('Eskeleton')

--These values are global for every instance
--When overritten, all instances are affected
local default = {
    quadWidth = 128,
    quadHeight = 96,
    animVel = 3,
    idleCols = 4,
    moveCols = 6,
    atackCols = 8,
    hitCols = 3,
    jumpCols = 6,
    rows = 5,
    acelOnWalking = 400,
    acelYOnHitted = 2000,
    dtDieAnimation = 5,
    dtWalking = 3
}

function Eskeleton:initialize(x, y, imgPath, direction)
    -- Position and movement
    self.position = {x = x, y = y}
    self.vel = {x = 0, y = 0}
    self.acel = {x = 0, y = 0}
    self.state = 'idle'
    self.direction = -1
    self.dtWalking = default.dtWalking
    self.dtStop = 0
    self.stopedTime = stopedTime
    
    --Quads and animation
    self.image = Image(imgPath, default)
    
    -- Attack and damage
    self.hitbox = CollisionBox(self.position.x, self.position.y, self.image.width*self.direction, self.image.height)
    self.hurtbox = CollisionBox(self.position.x, self.position.y, self.image.width*self.direction, self.image.height, 'hurtbox')
    self.isHitted = false
    self.dtDieAnimation = -default.dtDieAnimation/2
end

function Eskeleton:update(dt)
    if self.isHitted then
        
    elseif self:isIdle() then
        self:animateIdle(dt)
    elseif self:isWalking() then

    elseif self:isAttacking() then

    end

    -- After attributes-manipulation update
    --self:calculatePosition(dt)

    self.hitbox:update(self.position.x + 25*self.direction, self.position.y + self.image.height/10, self.direction*(self.image.width/2), self.image.height*0.85)
end

function Eskeleton:draw()
    self.hitbox:draw()
    self.image:draw(self.position.x, self.position.y, self.direction)
end

function Eskeleton:wasHitted(hurtBox)
    if (self.hitbox:checkCollision(hurtBox)) then
        self.isHitted = true
        return true
    end
    return false
end

function Eskeleton:die()
    self.acel.y = default.acelYOnHitted*self.dtDieAnimation
    local x, y, w, h = self.image.quad:getViewport()
    self.image.quad:setViewport(w*2, h, w, h)
end

function Eskeleton:calculatePosition(dt)
    self.vel.y = (self.vel.y * 0.95) + self.acel.y * dt
    self.position.y = self.position.y + self.vel.y * dt
    self.vel.x = (self.vel.x * 0.95) + self.acel.x * dt
    self.position.x = self.position.x + self.vel.x * dt
end

function Eskeleton:stop()
    local x, y, w, h = self.image.quad:getViewport()
    self.image.quad:setViewport(0, y, w, h)
end

function Eskeleton:animate(dt)
    local currentCol = self.image.currentCol + dt*self.image.animVel
    row = 0
    if currentCol > self.image.quadConfig.cols then
        currentCol = 0
    end

    self.image:update(currentCol, row)
end

function Eskeleton:animateIdle(dt)
    local currentCol = self.image.currentCol + dt*self.image.animVel
    row = 0
    if currentCol > self.image.quadConfig.idleCols then
        currentCol = 0
    end

    self.image:update(currentCol, row)
end

function Eskeleton:rotate()
    self.direction = -self.direction
    self.position.x = self.position.x - self.direction*self.image.width
end

function Eskeleton:isWalking()
    return self.state == 'walking'
end

function Eskeleton:setWalking()
    self.state = 'walking'
end

function Eskeleton:isAttacking()
    return self.state == 'attacking'
end

function Eskeleton:setAttacking()
    self.state = 'attacking'
end

function Eskeleton:isIdle()
    return self.state == 'idle'
end

function Eskeleton:setIdle()
    self.state = 'idle'
end

function Eskeleton:isAlreadyDead()
    return self.isHitted and self.dtDieAnimation > default.dtDieAnimation
end