Enemie = class('Enemie')

--These values are global for every instance
--When overritten, all instances are affected
local default = {
    acelOnWalking = 400,
    acelYOnHitted = 2000,
    dtKick = 0.2,
    dtDieAnimation = 5
}

function Enemie:initialize(x, y, direction, imgPath, dtWalking, stopedTime, config)
    -- Position and movement
    self.position = {x = x, y = y}
    self.vel = {x = 0, y = 0}
    self.acel = {x = 0, y = 0}
    self.state = 'walking'
    self.direction = -direction --it has to be negated because rotate() will be called on first run
    self.defaultDtWalking = dtWalking
    self.dtWalking = dtWalking
    self.dtStop = 0
    self.stopedTime = stopedTime
    
    --Quads and animation
    if config then --Quads-based image (spritesheet)
        self.image = Image(imgPath, config)
    else --Simple image
        self.image = Image(imgPath)
    end
    
    -- Attack and damage
    self.dtKick = 0
    self.hitbox = CollisionBox(self.position.x, self.position.y, self.image.width*self.direction, self.image.height)
    self.hurtbox = CollisionBox(self.position.x, self.position.y, self.image.width*self.direction, self.image.height, 'hurtbox')
    self.isHitted = false
    self.dtDieAnimation = -default.dtDieAnimation/2
end

function Enemie:update(dt)
    if self.isHitted then
        self.dtDieAnimation = self.dtDieAnimation + dt*8
        self:die()
    elseif self:isWalking() then
        if self.dtStop > 0 then
            --stoped
            self.dtStop = self.dtStop - dt
            self.vel.x = 0
            self.acel.x = 0
            self:stop()
        elseif self.dtWalking > 0 then
            if self.dtWalking == self.defaultDtWalking then
                --this means it has been reset and must rotate    
                self:rotate()
            end
            --walking
            self.acel.x = self.direction*default.acelOnWalking
            self.dtWalking = self.dtWalking - dt
            self:animate(dt)
        else
            self.dtStop = self.stopedTime
            self.dtWalking = self.defaultDtWalking
        end
    end

    -- After attributes-manipulation update
    self:calculatePosition(dt)

    self.hitbox:update(self.position.x + 25*self.direction, self.position.y + self.image.height/10, self.direction*(self.image.width/2), self.image.height*0.85)
end

function Enemie:draw()
    self.hitbox:draw()
    self.image:draw(self.position.x, self.position.y, self.direction)
end

function Enemie:wasHitted(hurtBox)
    if (self.hitbox:checkCollision(hurtBox)) then
        self.isHitted = true
        return true
    end
    return false
end

function Enemie:die()
    self.acel.y = default.acelYOnHitted*self.dtDieAnimation
    local x, y, w, h = self.image.quad:getViewport()
    self.image.quad:setViewport(w*2, h, w, h)
end

function Enemie:calculatePosition(dt)
    self.vel.y = (self.vel.y * 0.95) + self.acel.y * dt
    self.position.y = self.position.y + self.vel.y * dt
    self.vel.x = (self.vel.x * 0.95) + self.acel.x * dt
    self.position.x = self.position.x + self.vel.x * dt
end

function Enemie:stop()
    local x, y, w, h = self.image.quad:getViewport()
    self.image.quad:setViewport(0, y, w, h)
end

function Enemie:animate(dt)
    local currentCol = self.image.currentCol + dt*self.image.animVel
    row = 0
    if currentCol > self.image.quadConfig.cols then
        currentCol = 0
    end

    self.image:update(currentCol, row)
end

function Enemie:rotate()
    self.direction = -self.direction
    self.position.x = self.position.x - self.direction*self.image.width
end

function Enemie:isWalking()
    return self.state == 'walking'
end

function Enemie:setWalking()
    self.state = 'walking'
end

function Enemie:isAlreadyDead()
    return self.isHitted and self.dtDieAnimation > default.dtDieAnimation
end