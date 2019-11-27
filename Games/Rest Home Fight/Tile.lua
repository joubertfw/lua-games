Tile = Object:extend()

function Tile:new(x, y, imgPath)
    self.x = x
    self.y = y
    self.image = love.graphics.newImage(imgPath)
    self.width, self.height = self.image:getDimensions()
end

function Tile:update(x, y)
    
end

function Tile:draw()
    love.graphics.draw(self.image, self.x, self.y)
end

function Tile:checkCollision(player)
    local x1, y1, w1, h1, x2, y2, w2, h2 = self.x, self.y, self.width, self.height, player.x, player.y, player.width, player.height
    return x1 < x2 + w2 and
        x1 + w1 > x2 and
        y1 < y2 + h2 and
        y1 + h1 > y2
end