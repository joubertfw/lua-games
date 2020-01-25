Skeleton = class('Skeleton')

--These values are global for every instance
--When overritten, all instances are affected
local default = {
    quadWidth = 256,
    quadHeight = 192,
    animVel = 3,
    idleCols = 4,
    walkCols = 6,
    attackCols = 8,
    hitCols = 3,
    jumpCols = 6,
    rows = 5,
    acelOnWalking = 400,
    acelYOnHitted = 2000,
    dtDieAnimation = 5,
    dtAttack = 5
}

function Skeleton:initialize(x, y, direction, imgPath, dtWalking, idleTime)
    -- Position and movement
    self.position = {x = x, y = y}
    self.vel = {x = 0, y = 0}
    self.acel = {x = 0, y = 0}
    self.state = 'walking'
    self.direction = -direction
    self.defaultDtWalking = dtWalking
    self.dtWalking = dtWalking
    self.dtIdle = 0
    self.idleTime = idleTime
    
    --Quads and animation
    self.image = Image(imgPath, default)
    
    -- Attack and damage
    self.hitbox = CollisionBox(0, 0, 0, 0)
    self.hurtbox = CollisionBox(0, 0, 0, 0, 'hurtbox')
    self.isHitted = false
    self.dtDieAnimation = -default.dtDieAnimation/2
end

function Skeleton:update(dt)
    -- State-based manipulation
    --[[
        if self.isHitted then
            
        elseif self:isIdle() then
            self:animateIdle(dt)
        elseif self:isWalking() then
            self:animateWalk(dt)
        elseif self:isAttacking() then
            self:animateAttack(dt)
        end
    ]]
    if self.isHitted then
        self.dtDieAnimation = self.dtDieAnimation + dt*8
        self:die()
    elseif self:isWalking() then
        if self.dtIdle > 0 then
            --stoped
            self.dtIdle = self.dtIdle - dt
            self.vel.x = 0
            self.acel.x = 0
            self:animateIdle(dt)
        elseif self.dtWalking > 0 then
            if self.dtWalking == self.defaultDtWalking then
                --this means it has been reset and must rotate    
                self:rotate()
            end
            --walking
            self.acel.x = self.direction*default.acelOnWalking
            self.dtWalking = self.dtWalking - dt
            self:animateWalk(dt)
        else
            self.dtIdle = self.idleTime
            self.dtWalking = self.defaultDtWalking
        end
    end

    -- After attributes-manipulation update
    self:calculatePosition(dt)

    self.hitbox:update(self.position.x + 65*self.direction, self.position.y + self.image.height/2.6, self.direction*self.image.width/6, self.image.height*0.6)
end

function Skeleton:draw()
    self.hitbox:draw()
    self.image:draw(self.position.x, self.position.y, self.direction)
end

function Skeleton:wasHitted(hurtBox)
    if (self.hitbox:checkCollision(hurtBox)) then
        self.isHitted = true
        return true
    end
    return false
end

function Skeleton:die()
    self.acel.y = default.acelYOnHitted*self.dtDieAnimation
    local x, y, w, h = self.image.quad:getViewport()
    self.image.quad:setViewport(w*2, h, w, h)
end

function Skeleton:isAlreadyDead()
    return self.isHitted and self.dtDieAnimation > default.dtDieAnimation
end

function Skeleton:calculatePosition(dt)
    self.vel.y = (self.vel.y * 0.95) + self.acel.y * dt
    self.position.y = self.position.y + self.vel.y * dt
    self.vel.x = (self.vel.x * 0.95) + self.acel.x * dt
    self.position.x = self.position.x + self.vel.x * dt
end

function Skeleton:animateWalk(dt)
    local currentCol = self.image.currentCol + dt*self.image.animVel
    row = 0
    if currentCol > self.image.quadConfig.walkCols then
        currentCol = 0
    end

    self.image:update(currentCol, row)
end

function Skeleton:animateIdle(dt)
    local currentCol = self.image.currentCol + dt*self.image.animVel
    row = 0
    if currentCol > self.image.quadConfig.idleCols then
        currentCol = 0
    end

    self.image:update(currentCol, row)
end

function Skeleton:animateAttack(dt)
    local currentCol = self.image.currentCol + (dt*self.image.animVel)*default.dtAttack
    if currentCol > self.image.quadConfig.attackCols then
        currentCol = 0
    end
    row = 2*self.image.height
    self.image:update(currentCol, row)
end

function Skeleton:animateWalk(dt)
    local currentCol = self.image.currentCol + dt*self.image.animVel*2
    row = self.image.height
    if currentCol > self.image.quadConfig.walkCols then
        currentCol = 0
    end

    self.image:update(currentCol, row)
end

function Skeleton:rotate()
    self.direction = -self.direction
    self.position.x = self.position.x - self.direction*self.image.width
end

function Skeleton:isWalking()
    return self.state == 'walking'
end

function Skeleton:setWalking()
    self.state = 'walking'
end

function Skeleton:isAttacking()
    return self.state == 'attacking'
end

function Skeleton:setAttacking()
    self.state = 'attacking'
end

function Skeleton:isIdle()
    return self.state == 'idle'
end

function Skeleton:setIdle()
    self.state = 'idle'
end