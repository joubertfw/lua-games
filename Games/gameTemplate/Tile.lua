Tile = Object:extend()

function Tile:new(x, y, imgPath, isSolid, size)
    self.x = x
    self.y = y
    self.size = size
    self.isSolid = isSolid or false
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

function Tile:checkObjOnTop(obj, offset)
    offset = offset or 0
    local x1, y1, w1, h1, x2, y2, w2, h2 = self.x, self.y, self.width, self.height, obj.x, obj.y, obj.width, obj.height
    return x2 < x1 + w1 and x2 + w2 > x1 and
        y1 > y2 and
        y2 + h2 > y1 and
        y2 + h2 < y1 + h1 + offset
end

function Tile:checkObjBelow(obj, offset)
    offset = offset or 0
    local x1, y1, w1, h1, x2, y2, w2, h2 = self.x, self.y, self.width, self.height, obj.x, obj.y, obj.width, obj.height
    return x2 < x1 + w1 and x2 + w2 > x1 and
        y2 > y1 and
        y2 > y1 + h1 + offset and
        y2 < y1 + h1
end

function Tile:checkObjOnLeftSide(obj, offset)
    offset = offset or 0
    local x1, y1, w1, h1, x2, y2, w2, h2 = self.x, self.y, self.width, self.height, obj.x, obj.y, obj.width, obj.height
    return y2 < y1 + h1 and y2 + h2 > y1 and
        x2 + w2 > x1 and x2 + w2 < x1 + offset
end

function Tile:checkObjOnRightSide(obj, offset)
    offset = offset or 0
    local x1, y1, w1, h1, x2, y2, w2, h2 = self.x, self.y, self.width, self.height, obj.x, obj.y, obj.width, obj.height
    return y2 < y1 + h1 and y2 + h2 > y1 and
        x2 < x1 + w1 and x2 > x1 + w1 + offset
end