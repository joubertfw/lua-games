Item = class('Item')

function Item:initialize(x, y, imgPath, isBomba)
    self.x = x
    self.y = y
    self.image = love.graphics.newImage(imgPath)
    self.width, self.height = self.image:getDimensions()
    self.isBomba = isBomba
end

function Item:update(dt)
    
end

function Item:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, self.size, self.size)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

function Item:checkCollision(other)
    return verifyPoints(self.x, self.y, self.width, self.height, other.x, other.y, other.width, other.height)
end

function verifyPoints(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
        x1 + w1 > x2 and
        y1 < y2 + h2 and
        y1 + h1 > y2 and w1 ~= 0 and w2 ~= 0
end