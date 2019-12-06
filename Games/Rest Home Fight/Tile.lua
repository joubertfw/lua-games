Tile = Object:extend()

function Tile:new(x, y, imgPath, size)
    self.x = x
    self.y = y
    self.size = size
    self.image = love.graphics.newImage(imgPath)
    self.width, self.height = self.image:getDimensions()
    if size then
        self.width = self.width*size
        self.height = self.height*size
    end
end

function Tile:update(x, y)
    
end

function Tile:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, self.size, self.size)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

function Tile:checkCollision(player)
    local x1, y1, w1, h1, x2, y2, w2, h2 = self.x, self.y, self.width, self.height, player.x, player.y, player.width, player.height
    return x1 < x2 + w2 and
        x1 + w1 > x2 and
        y1 < y2 + h2 and
        y1 + h1 > y2
end