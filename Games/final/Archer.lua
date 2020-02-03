Archer = class('Archer')

--These values are global for every instance
--When overritten, all instances are affected
local default = {
    quadWidth = 300,
    quadHeight = 195,
    width = 80,
    height = 195,
    idleCols = 2,
    walkCols = 12,
    jumpCols = 6,
    attackCols = 6,
    deathCols = 4,
    row = 5,
    animVel = 3,
    acelOnWalking = 400,
    acelYOnHitted = 2000,
    dtKick = 0.2,
    dtDieAnimation = 5
}

local util = Util()

function Archer:initialize(x, y, direction, imgPath)
    -- Position and movement
    self.position = {x = x, y = y}
    self.vel = {x = 0, y = 0}
    self.acel = {x = 0, y = 0}
    self.width, self.height = default.width, default.height
    self.state = 'idle'
    self.direction = direction

    --Quads and animation
    self.image = Image(imgPath, default)
    
    -- Attack and damage
    self.hitbox = CollisionBox(0,0,0,0)
    self.dtDieAnimation = -default.dtDieAnimation/2

    self.isTalking = false
end

function Archer:update(dt)
    self:animateIdle(dt)

    -- After attributes-manipulation update
    self:calculatePosition(dt)

    self.hitbox:update(self.position.x - (self.width/2), self.position.y - (self.height/2), self.width, self.height)
end

function Archer:draw()
    self.hitbox:draw()
    self.image:draw(self.position.x, self.position.y, self.direction)
    if self.isTalking then
        love.graphics.setColor(0.65, 0.7, 0.81, 1)
        local posX = self.hitbox.x + self.direction*0.5*self.image.width
        local posY = self.hitbox.y - self.image.height
        love.graphics.rectangle("fill", posX, posY, -self.direction*1.25*self.image.width, self.image.height, 10, 10, 100)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.setFont(util.smallerFont)
        love.graphics.print('Finalmente você chegou!', posX + 5, posY + 5)
        love.graphics.print('Nossas tropas foram', posX + 5, posY + 30)
        love.graphics.print('totalmente derrotadas...', posX + 5, posY + 55)
        love.graphics.print('Rápido! Recupere o cetro', posX + 5, posY + 80)
        love.graphics.print('do rei para que possamos', posX + 5, posY + 105)
        love.graphics.print('bater em retirada', posX + 5, posY + 130)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(util.font)
    end
end

function Archer:wasHitted(hurtBox)
    if (self.hitbox:checkCollision(hurtBox)) then
        self.isHitted = true
        return true
    end
    return false
end

function Archer:die()
    self.acel.y = default.acelYOnHitted*self.dtDieAnimation
    local x, y, w, h = self.image.quad:getViewport()
    self.image.quad:setViewport(w*2, h, w, h)
end

function Archer:calculatePosition(dt)
    self.vel.y = (self.vel.y * 0.95) + self.acel.y * dt
    self.position.y = self.position.y + self.vel.y * dt
    self.vel.x = (self.vel.x * 0.95) + self.acel.x * dt
    self.position.x = self.position.x + self.vel.x * dt
end

function Archer:animateIdle(dt)
    local currentCol = self.image.currentCol + dt*self.image.animVel
    row = 0
    if currentCol > self.image.quadConfig.idleCols then
        currentCol = 0
    end

    self.image:update(currentCol, row)
end

function Archer:animate(dt)
    local currentCol = self.image.currentCol + dt*self.image.animVel
    row = 0
    if currentCol > self.image.quadConfig.cols then
        currentCol = 0
    end

    self.image:update(currentCol, row)
end

function Archer:rotate()
    self.direction = -self.direction
end

function Archer:isWalking()
    return self.state == 'walking'
end

function Archer:setWalking()
    self.state = 'walking'
end