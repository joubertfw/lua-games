Player = class('Player')
local util = Util()

--These values are global for every instance
--When overritten, all instances are affected
local default = {
    dtJump = 0.4,
    velHoriz = 900,
    velVert = 900,
    acelYOnJump = -2500,
    velYOnJump = -1200,
    acelYOnFall = 2000,
    dtPunch = 0.2
}

function Player:initialize(x, y, imgPath, buttons, config)
    -- Position and movement
    self.position = {x = x, y = y}
    self.vel = {x = 0, y = 0}
    self.acel = {x = 0, y = 0}
    self.dtJump = default.dtJump
    self.state = 'falling'
    self.direction = 1
    self.jumpRepeat = false

    -- Input
    self.input = Input(buttons)
    
    -- Quads and animation
    if config then --Quads-based image (spritesheet)
        self.image = Image(imgPath, config)
    else --Simple image
        self.image = Image(imgPath)
    end
    
    -- Attack and damage
    self.dtPunch = 0
    self.hitRepeat = false
    self.hitbox = CollisionBox(0, 0, 0, 0)
    self.hurtbox = CollisionBox(0, 0, 0, 0, 'hurtbox')
end

function Player:update(dt)

    self.acel.y = default.acelYOnFall
    self:listenInput(dt)
    -- State-based manipulation

    if self:isOnFloor() then
        if self.vel.y >= 0 then
            self.acel.y = 0
            self.vel.y = 0
        end
        if not love.keyboard.isDown(self.input.btJump) then
            self.jumpRepeat = false
        else
            if not self.jumpRepeat then
                self.acel.y = default.acelYOnJump
                self.vel.y = default.velYOnJump
                self.jumpRepeat = true
            else
            end
        end
    end

    self:calculatePosition(dt)
    
    -- Collision boxes updates
    self.hitbox:update(self.position.x + 10*self.direction, self.position.y + self.image.height/2.7, self.direction*(self.image.width/3 - 20), self.image.height/3.5)
    self.hurtbox:update(self.position.x + 10*self.direction, self.position.y + self.image.height/2.7, self.direction*(self.image.width/3 - 20), self.image.height/3.5)
    
    -- After attributes-manipulation update
    
    --Idle animation
    if not love.keyboard.isDown(self.input.btLeft) 
        and not love.keyboard.isDown(self.input.btRight) then
            if self:isOnFloor() and not self:isPunching() then
                self:animateIdle(dt)
            end
            self.acel.x = 0
    end
end

function Player:draw()
    self.hitbox:draw()
    self.hurtbox:draw()    
    self.image:draw(self.position.x, self.position.y, self.direction)


    love.graphics.points( self.hitbox.x, self.hitbox.y )
    love.graphics.print( "y", self.hitbox.x, self.hitbox.y )

    love.graphics.points(self.hitbox.x , self.hitbox.y + self.hitbox.height)
    love.graphics.print( "y+h", self.hitbox.x + self.hitbox.width, self.hitbox.y + self.hitbox.height )

end

function Player:listenInput(dt)
    if love.keyboard.isDown(self.input.btLeft) and not love.keyboard.isDown(self.input.btRight) then
        self:moveLeft(dt)
        if not self:isPunching() and not self:isFalling() then
            self:animate(dt)
        end
        self.direction = -1
    end
    if love.keyboard.isDown(self.input.btRight) and not love.keyboard.isDown(self.input.btLeft) then
        self:moveRight(dt)
        if not self:isPunching() and not self:isFalling() then
            self:animate(dt)
        end
        self.direction = 1
    end
    if love.keyboard.isDown(self.input.btUp) and not love.keyboard.isDown(self.input.btDown) then
        --self:animate(dt)
        --self:moveUp(dt)
    end
    if love.keyboard.isDown(self.input.btDown) and not love.keyboard.isDown(self.input.btUp) then
        --self:animate(dt)
        --self:moveDown(dt) buga o pulo se apertar junto
    end

    if love.keyboard.isDown(self.input.btJump) and not self.spaceRepeat then
        -- self.vel.y = default.velYOnJump -- * 1.5 or default.velYOnJump
        self:moveUp(dt)
        self.spaceRepeat = true
    end

    --Attack verification
    if love.keyboard.isDown(self.input.btPunch) and not self.hitRepeat then
        self.image.currentCol = 0
        self.dtPunch = default.dtPunch
        self.hitRepeat = true
    end
    --Attacking
    if self.dtPunch > 0 then
        self:animatePunch(dt)
        self.dtPunch = self.dtPunch - dt
    else
        self.hitRepeat = false
    end
end

function Player:animateIdle(dt)
    local currentCol = self.image.currentCol + dt*self.image.animVel
    row = 0
    if currentCol > self.image.quadConfig.idleCols then
        currentCol = 0
    end

    self.image:update(currentCol, row)
end

function Player:animatePunch(dt)
    local currentCol = self.image.currentCol + (dt*self.image.animVel)/default.dtPunch*0.6
    row = 2*self.image.height
    self.image:update(currentCol, row)
end

function Player:animate(dt)
    local currentCol = self.image.currentCol + dt*self.image.animVel
    row = self.image.height
    if currentCol > self.image.quadConfig.moveCols then
        currentCol = 0
    end

    self.image:update(currentCol, row)
end

function Player:calculatePosition(dt)
    self.vel.x = (self.vel.x * 0.95) + self.acel.x * dt
    self.vel.y = self.vel.y + self.acel.y * dt
    self.vel.y = self.vel.y < 1000 and self.vel.y or 1000
    self.position.y = self.position.y + self.vel.y * dt
    self.position.x = self.position.x + self.vel.x * dt
end

function Player:moveUp(dt)
    self.acel.y = -default.velYOnJump
    -- self:setFalling()
    -- self.position.y = self.position.y + self.vel.y*dt
end

function Player:moveDown(dt)
    self.acel.y = default.velVert
    -- self.position.y = self.position.y + self.vel.y*dt
end

function Player:moveLeft(dt)
    self.acel.x = -default.velHoriz
    if self.direction == 1 then
        self.position.x = self.position.x + self.hitbox.width*1.25
    end
    if self:isFalling() and self.jumpRepeat then
        self.acel.x = self.acel.x*2
    end
end

function Player:moveRight(dt)
    self.acel.x = default.velHoriz
    if self.direction == -1 then
        self.position.x = self.position.x - self.hitbox.width*1.25
    end
    if self:isFalling() and self.jumpRepeat then
        self.acel.x = self.acel.x*2
    end
end

function Player:isPunching()
    return self.dtJump > 0 and self.hitRepeat
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