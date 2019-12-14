Enemie = Object:extend()

function Enemie:new(x, y, imgPath)
    self.x, self.y = x, y
    self.image = love.graphics.newImage(imgPath)
    self.direction = 1
    self.acelHoriz = aceleracao
    self.acelVert = aceleracao
    self.currentImg = 0
    self.width = quadWidth
    self.height = quadHeight
    self.quad = love.graphics.newQuad(0, 0, self.width, self.height, self.image:getDimensions())
    self.state = ''

    self.hitbox = HitBox(self.x, self.y, self.width*self.direction, self.height)
end

function Enemie:update(dt)
    if self.state == '' then

    elseif self.state == '' then

    end
    self.hitbox:update(self.x, self.y, self.width*self.direction, self.height)
end

function Enemie:draw()
    self.hitbox:draw()
    love.graphics.draw(self.image,  self.quad, self.x, self.y, 0, self.direction)
end

function Enemie:stop()
    local x, y, w, h = self.quad:getViewport()
    self.quad:setViewport(w*7, y, w, h)
end

function Enemie:animate(dt)
    local x, y, w, h = self.quad:getViewport()
    self.currentImg = self.currentImg + dt*velocidadeAnimacao
    if self.currentImg >= qntQuads then
        self.currentImg = 0
    end
    self.quad:setViewport(w*math.floor(self.currentImg), y, w, h)
end

function Enemie:rotateLeft()
    self.direction = -1
    self.x = self.x + self.width
end

function Enemie:rotateRight()
    self.direction = 1
    self.x = self.x - self.width
end