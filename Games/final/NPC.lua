NPC = class('NPC')

--These values are global for every instance
--When overritten, all instances are affected
local default = {
    acelOnWalking = 400,
    acelYOnHitted = 2000,
    dtKick = 0.2,
    dtDieAnimation = 5
}

function NPC:initialize(x, y, direction, imgPath, config)
    -- Position and movement
    self.position = {x = x, y = y}
    self.vel = {x = 0, y = 0}
    self.acel = {x = 0, y = 0}
    self.state = 'walking'
    self.direction = -direction --it has to be negated because rotate() will be called on first run
    self.dtStop = 0
    
    --Quads and animation
    self.image = Image(imgPath, config)
    
    -- Attack and damage
    self.hitbox = CollisionBox(self.position.x, self.position.y, self.image.width*self.direction, self.image.height)
    self.dtDieAnimation = -default.dtDieAnimation/2
end

function NPC:update(dt)

    -- After attributes-manipulation update
    self:calculatePosition(dt)

    self.hitbox:update(self.position.x + 25*self.direction, self.position.y + self.image.height/10, self.direction*(self.image.width/2), self.image.height*0.85)
end

function NPC:draw()
    self.hitbox:draw()
    self.image:draw(self.position.x, self.position.y, self.direction)
end

function NPC:wasHitted(hurtBox)
    if (self.hitbox:checkCollision(hurtBox)) then
        self.isHitted = true
        return true
    end
    return false
end

function NPC:die()
    self.acel.y = default.acelYOnHitted*self.dtDieAnimation
    local x, y, w, h = self.image.quad:getViewport()
    self.image.quad:setViewport(w*2, h, w, h)
end

function NPC:calculatePosition(dt)
    self.vel.y = (self.vel.y * 0.95) + self.acel.y * dt
    self.position.y = self.position.y + self.vel.y * dt
    self.vel.x = (self.vel.x * 0.95) + self.acel.x * dt
    self.position.x = self.position.x + self.vel.x * dt
end

function NPC:stop()
    local x, y, w, h = self.image.quad:getViewport()
    self.image.quad:setViewport(0, y, w, h)
end

function NPC:animate(dt)
    local currentCol = self.image.currentCol + dt*self.image.animVel
    row = 0
    if currentCol > self.image.quadConfig.cols then
        currentCol = 0
    end

    self.image:update(currentCol, row)
end

function NPC:rotate()
    self.direction = -self.direction
    self.position.x = self.position.x - self.direction*self.image.width
end

function NPC:isWalking()
    return self.state == 'walking'
end

function NPC:setWalking()
    self.state = 'walking'
end