Player = Object:extend()
local util = Util()

function Player:new(x, y, imgPath, buttons)
    -- Position and movement
    self.x, self.y = x, y
    self.direction = 1
    self.velHoriz = 400
    self.velVert = 250
    self.velX = 0
    self.velY = 0
    self.acelX = 700
    self.acelY = 1000
    self:resetDtJump()
    self.state = 'falling'

    -- Input
    self.input = Input(buttons)
    
    -- Quads and animation
    self.direction = 1
    self.animVel = 10
    self.image = love.graphics.newImage(imgPath)
    self.quadQtd = 10
    self.stopQuad = 4
    self.width = 120
    self.height = 240
    self.quad = love.graphics.newQuad(0, 0, self.width, self.height, self.image:getDimensions())
    self.currentImg = 0
    
    self.life = 100

    -- Hitboxes
    self.hitbox = HitBox(self.x, self.y, self.width*self.direction, self.height)
end

local counter = 0

function love.keypressed(key, isrepeat)
    if key == "escape" then
        counter = counter + 1
    end
 end

function Player:update(dt)
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
    elseif not self:isOnFloor() then
        self:fall(dt)
    end
    
    if love.keyboard.isDown(self.input.btUp) and not love.keyboard.isDown(self.input.btDown) then
        --self:animate(dt)
        --self:moveUp(dt)
    end
    if love.keyboard.isDown(self.input.btDown) and not love.keyboard.isDown(self.input.btUp) then
        --self:animate(dt)
        --self:moveDown(dt)
    end
    if not love.keyboard.isDown(self.input.btLeft) and not love.keyboard.isDown(self.input.btRight) and not love.keyboard.isDown(self.input.btDown)and not love.keyboard.isDown(self.input.btUp) then
        self:stop()
    end
    --self:jumpCheck(dt)
    self.hitbox:update(self.x, self.y, self.width, self.height)
end

function Player:draw()
    self.hitbox:draw()
    love.graphics.draw(self.image,  self.quad, self.x, self.y, 0)
    love.graphics.print(self.direction, self.x, self.y)
    love.graphics.print(self.state, self.x, self.y + self.height + 5)
    love.graphics.print("KeypressTest (esc):" .. counter, 50, 50)
end

function Player:stop()
    local x, y, w, h = self.quad:getViewport()
    if self.direction == 1 then 
        self.stopQuad = 5
    else
        self.stopQuad = 4
    end
    self.quad:setViewport(w*self.stopQuad, y, w, h)
end

function Player:fall(dt)
    self.velY = self.velY + self.acelY * dt
    self.y = self.y + self.velY * dt
end

function Player:jump(dt)
    if self.dtJump > 0 then
        --self:animateJump()
        self.velY = (self.velY * 0.95) + self.acelY * dt
        self.y = self.y - self.velY * dt
        self.dtJump = self.dtJump - dt
    else
        self.velY = 0
        self:setFalling()
    end
end

function Player:resetDtJump()
    self.dtJump = 0.5
end
--[[
function Player:animateJump()
    local x, y, w, h = self.quad:getViewport()
    if self.direction == 1 then 
        self.stopQuad = 5
    else
        self.stopQuad = 4
    end
    self.quad:setViewport(w*self.stopQuad, y, w, h)
end
]]

function Player:animate(dt)
    local x, y, w, h = self.quad:getViewport()
    if self.direction == 1 then
        y = 0
    else
        y = h
    end
    -- TODO: verificar se player 1 está se afastando de player 2
    if self.direction > 0 then
        self.currentImg = self.currentImg + dt*self.animVel
    else
        self.currentImg = self.currentImg - dt*self.animVel
    end

    if self.currentImg >= self.quadQtd and self.direction > 0 then
        self.currentImg = 0
    end
    if self.currentImg <= 0  and self.direction < 0 then
        self.currentImg = self.quadQtd
    end
    self.quad:setViewport(w*math.floor(self.currentImg), y, w, h)
end

function Player:moveUp(dt)
    self.velY = -self.velVert
    self.y = self.y + self.velY*dt
end

function Player:moveDown(dt)
    self.velY = self.velVert
    self.y = self.y + self.velY*dt
end

function Player:moveLeft(dt)
    self.x = self.x + -self.velHoriz*dt
end

function Player:moveRight(dt)
    self.x = self.x + self.velHoriz*dt
end

--[[
function Player:jumpCheck(dt)
    if self.isJumping == true then
        self:jump()
        self.velY = self.velVert * self.dtJump * 2 
        self.dtJump = self.dtJump - dt
        self.y = self.y - self.velY*dt
        self.velX = self.velHoriz * self.direction
        self.x = self.x + self.velX*dt
    end
    if self.dtJump <= -1 and self.isJumping == true then
        self.isJumping = false
        self.dtJump = 1
        self.velY = 0
    end
end
]]

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