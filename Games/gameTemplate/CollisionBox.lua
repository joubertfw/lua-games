CollisionBox = Object:extend()

function CollisionBox:new(x, y, width, height, type)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.type = type or 'hitbox'
end

function CollisionBox:update(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    
    if self.width < 0 then
        self.x = self.x + self.width
        self.width = -self.width
    end
end

function CollisionBox:draw()
    if self:isHitBox() then
        love.graphics.setColor(1, 0, 0)
    else
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.rectangle( "line", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1, 1)
end

function CollisionBox:checkColision(other)
    return verifyPoints(self.x, self.y, self.width, self.height, other.x, other.y, other.width, other.height)
end

function verifyPoints(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
        x1 + w1 > x2 and
        y1 < y2 + h2 and
        y1 + h1 > y2 and w1 ~= 0 and w2 ~= 0
end

function CollisionBox:isHitBox()
    return self.type == 'hitbox'
end