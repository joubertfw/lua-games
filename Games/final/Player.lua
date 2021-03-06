Player = class('Player')

--These values are global for every instance
--When overritten, all instances are affected
local default = {
    quadWidth = 200,
    quadHeight = 145,
    width = 70,
    height = 125,
    animVel = 5,
    idleCols = 4,
    walkCols = 6,
    jumpCols = 5,
    slideCols = 2,
    attackCols = 7,
    deathCols = 7,
    rows = 6,
    velHoriz = 3000,
    velVert = 1200,
    acelYOnJump = -1200,
    velYOnJump = -1200,
    acelYOnFall = 2000,
    dtAttack = 0.5,
    dtInvencible = 1.5,
    atritoSlide = 0.75
}

function Player:initialize(x, y, imgPath, buttons)
    -- Position and movement
    self.position = {x = x, y = y}
    self.vel = {x = 0, y = 0}
    self.acel = {x = 0, y = 0}
    self.width, self.height = default.width, default.height
    self.stateGround = 'falling'
    self.stateSides = 'none'
    self.direction = 1
    self.jumpRepeat = false
    self.joystick = love.joystick.getJoysticks()[1]

    -- Input
    self.input = Input(buttons)
    
    -- Quads and animation
    self.image = Image(imgPath, default)
    
    -- Attack and damage
    self.lifes = 3
    self.dtAttack = 0
    self.hitRepeat = false
    self.hitbox = CollisionBox(0, 0, 0, 0)
    self.hurtbox = CollisionBox(0, 0, 0, 0, 'hurtbox')
    self.dtInvencible = 0
    self.isInvencible = false
    self.isCacetinhoPowered = false
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
        self:resetJump()
        self:jumpCheck()
        -- if not love.keyboard.isDown(self.input.btJump) then
        --     self.jumpRepeat = false
        -- elseif not self.jumpRepeat then
        --     self.acel.y = default.acelYOnJump
        --     self.vel.y = default.velYOnJump
        --     self.jumpRepeat = true
        -- end
    elseif self:isSliding() then
        -- self.vel.x = 0
        self:resetJump()
        -- if not love.keyboard.isDown(self.input.btJump) then
        --     self.jumpRepeat = false
        -- elseif not self.jumpRepeat then
        --     self.acel.y = default.acelYOnJump
        --     self.vel.y = default.velYOnJump
        --     self.jumpRepeat = true
        -- end
    elseif not self:isOnFloor() and self.jumpRepeat == false then
        self:resetJump()
        self:jumpCheck()
        -- if not love.keyboard.isDown(self.input.btJump) then
        --     self.jumpRepeat = false
        -- elseif not self.jumpRepeat then
        --     self.acel.y = default.acelYOnJump
        --     self.vel.y = default.velYOnJump
        --     self.jumpRepeat = true
        -- end
    end

    -- After attributes-manipulation update
    self:calculatePosition(dt)
    
    -- Collision boxes updates
    -- Change to fixed box size
    self.hitbox:update(self.position.x - (self.width/2), self.position.y - (self.height/2), self.width, self.height)
    self.hurtbox:update(self.position.x , self.position.y - (self.height/4), (self.direction * self.height), self.width)
    
    --Idle animation
    if not player:isMovingLeft() and not player:isMovingRight() then
        if self:isOnFloor() and not self:isAttacking() then
            self:animateIdle(dt)
        end
        self.acel.x = 0
    end

    if self:isSliding() then
        self:animateSlide(dt)
    elseif not self:isOnFloor() then
        self:animateJump(dt)
    end

    if self.dtInvencible > 0 then
        self.dtInvencible = self.dtInvencible - dt
    else
        self.isInvencible = false
    end
end

function Player:draw()
    self.hitbox:draw()
    if self:isAttacking() then
        self.hurtbox:draw()
    end
    if self.isCacetinhoPowered then
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(love.math.random(), love.math.random(), love.math.random(), 1)
        self.image:draw(self.position.x, self.position.y, self.direction)
        love.graphics.setColor(r, g, b, a)
    elseif self.isInvencible then
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(r, g, b, love.math.random())
        self.image:draw(self.position.x, self.position.y, self.direction)
        love.graphics.setColor(r, g, b, a)
    else
        self.image:draw(self.position.x, self.position.y, self.direction)
    end
end

function Player:listenInput(dt)
    if self:isMovingLeft() and not self:isMovingRight() then
        self:moveLeft(dt)
        if not self:isAttacking() and not self:isFalling() then
            self:animateWalk(dt)
        end
        self.direction = -1
    end
    if self:isMovingRight() and not self:isMovingLeft() then
        self:moveRight(dt)
        if not self:isAttacking() and not self:isFalling() then
            self:animateWalk(dt)
        end
        self.direction = 1
    end
    if love.keyboard.isDown(self.input.btUp) and not love.keyboard.isDown(self.input.btDown) then
        --self:animateWalk(dt)
        --self:moveUp(dt)
    end
    if love.keyboard.isDown(self.input.btDown) and not love.keyboard.isDown(self.input.btUp) then
        --self:animateWalk(dt)
        --self:moveDown(dt) buga o pulo se apertar junto
    end

    if love.keyboard.isDown(self.input.btJump) and not self.spaceRepeat then
        -- self.vel.y = default.velYOnJump -- * 1.5 or default.velYOnJump
        -- self:moveUp(dt)
        -- self.spaceRepeat = true
    end

    --Attack verification
    if self:isAttackBt() and not self.hitRepeat and self:isOnFloor() then
        self.image.currentCol = 0
        self.dtAttack = default.dtAttack
        self.hitRepeat = true
    end
    --Attacking
    if self.dtAttack > 0 then
        self:animateAttack(dt)
        self.dtAttack = self.dtAttack - dt
        self.acel.x = 0
    elseif self:isAttackBt() then
        self.hitRepeat = true
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

function Player:animateJump(dt)
    local currentCol = self.image.currentCol + dt*self.image.animVel*2
    row = 2*self.image.height
    if currentCol > self.image.quadConfig.jumpCols then
        currentCol = 0
    end
    self.image:update(currentCol, row)
end

function Player:animateAttack(dt)
    local currentCol = self.image.currentCol + dt*self.image.animVel/default.dtAttack*1.3
    row = 4*self.image.height
    self.image:update(currentCol, row)
end

function Player:animateWalk(dt)
    local currentCol = self.image.currentCol + dt*self.image.animVel*1.5
    row = self.image.height
    if currentCol > self.image.quadConfig.walkCols then
        currentCol = 0
    end

    self.image:update(currentCol, row)
end

function Player:animateSlide(dt)
    local currentCol = self.image.currentCol + dt*self.image.animVel
    row = 3*self.image.height
    if currentCol > self.image.quadConfig.slideCols then
        currentCol = 0
    end

    self.image:update(currentCol, row)
end

function Player:calculatePosition(dt)
    self.vel.x = (self.vel.x * 0.90 ) + self.acel.x * dt* self.direction
    self.vel.y = ( self.acel.y * dt) + (self:isSliding() and self.vel.y  * default.atritoSlide or self.vel.y)
    self.vel.y = self.vel.y < 1000 and self.vel.y or 1000
    self.position.y = self.position.y + self.vel.y * dt
    if not self:isColliding() then
        self.position.x = self.position.x + self.vel.x * dt
    end
end

function Player:moveUp(dt)
    self.acel.y = default.velYOnJump
    -- self:setFalling()
    -- self.position.y = self.position.y + self.vel.y*dt
end

function Player:moveDown(dt)
    self.acel.y = default.velVert
    -- self.position.y = self.position.y + self.vel.y*dt
end

function Player:moveLeft(dt)
    self.acel.x = default.velHoriz
    -- if self.direction == 1 then
    --     self.position.x = self.position.x + self.hitbox.width*3
    -- end
    if self:isFalling() and self.jumpRepeat then
        self.acel.x = self.acel.x*1.3
    end
end

function Player:moveRight(dt)
    self.acel.x = default.velHoriz
    -- if self.direction == -1 then
    --     self.position.x = self.position.x - self.hitbox.width*3
    -- end
    if self:isFalling() and self.jumpRepeat then
        self.acel.x = self.acel.x*1.3
    end
end

function Player:interacted()
    return player:isInteracting()
end

function Player:isAttacking()
    return self.dtAttack > 0 and self.hitRepeat
end

function Player:isOnFloor()
    return self.stateGround == 'onFloor'
end

function Player:isFalling()
    return self.stateGround == 'falling'
end

function Player:setOnFloor()
    self.stateGround = 'onFloor'
end

function Player:setFalling()
    self.stateGround = 'falling'
end

function Player:isColliding()
    return self.stateSides == 'colisionLeft' or self.stateSides == 'colisionRight'
end

function Player:isSliding()
    return not self:isOnFloor() and (self.stateSides == 'colisionLeft' or self.stateSides == 'colisionRight')
end

function Player:colisionLeft()
    return self.stateSides == 'colisionLeft'
end

function Player:colisionRight()
    return self.stateSides == 'colisionRight'
end

function Player:setColisionLeft()
    self.stateSides = 'colisionLeft'
end

function Player:setColisionRight()
    self.stateSides = 'colisionRight'
end

function Player:setNoColision()
    self.stateSides = 'none'
end

function Player:setInvencibleDt()
    self.dtInvencible = default.dtInvencible
end

function Player:resetJump()
    if not self:isJumping() then
        self.jumpRepeat = false
    end
end

function Player:jumpCheck()
    if not self.jumpRepeat and self:isJumping() then
        self.acel.y = default.acelYOnJump
        self.vel.y = default.velYOnJump
        self.jumpRepeat = true
    end
end

function Player:isMovingLeft()
    if self.joystick then
        return love.keyboard.isDown(self.input.btLeft) or self.joystick:isGamepadDown(self.input.btJoyLeft)
    end
    return love.keyboard.isDown(self.input.btLeft)
end

function Player:isMovingRight()
    if self.joystick then
        return love.keyboard.isDown(self.input.btRight) or self.joystick:isGamepadDown(self.input.btJoyRight)
    end
    return love.keyboard.isDown(self.input.btRight)
end

function Player:isAttackBt()
    if self.joystick then
        return love.keyboard.isDown(self.input.btAttack) or self.joystick:isGamepadDown(self.input.btJoyAttack)
    end
    return love.keyboard.isDown(self.input.btAttack)
end

function Player:isJumping()
    if self.joystick then
        return love.keyboard.isDown(self.input.btJump) or self.joystick:isGamepadDown(self.input.btJoyJump)
    end
    return love.keyboard.isDown(self.input.btJump)
end

function Player:isInteracting()
    if self.joystick then
        return love.keyboard.isDown(self.input.btInteract) or self.joystick:isGamepadDown(self.input.btJoyInteract)
    end
    return love.keyboard.isDown(self.input.btInteract)
end
