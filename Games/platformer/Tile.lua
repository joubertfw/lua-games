Tile = class('Tile')

function Tile:initialize(x, y, isSolid, imgPath, config, size)
    self.x = x
    self.y = y
    self.size = size
    self.isSolid = isSolid or false
    -- self.image = love.graphics.newImage(imgPath)
    
    -- self.quad = love.graphics.newQuad( 0, 0, self.width, self.height, 0, 0)
    
    if config then --Quads-based image (spritesheet)
        self.image = Image(imgPath, config)
        self.image:update(self.image.currentCol, self.image.row)
    else --Simple image
        self.image = Image(imgPath)
    end
    self.width, self.height = self.image:getDimensions()

    -- self.width, self.height = quadConfig.quadWidth quadConfig.quadHeight
    if size then
        self.width = self.width*size
        self.height = self.height*size
    end
end

function Tile:update(x, y)
    
end

function Tile:draw()
    self.image:draw(self.x, self.y, 1)

    -- DEBUG
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    love.graphics.setColor( 0, 0, 0, 1 )

    love.graphics.setPointSize(10)

    love.graphics.points( self.x, self.y )
    love.graphics.print( "y", self.x, self.y )

    love.graphics.points( self.x + self.width, self.y + self.height )
    love.graphics.print( "y+h", self.x + self.width, self.y + self.height )

    love.graphics.setColor( 1, 1, 1, 1 )
end

function Tile:checkObjOnTop(obj, offset)
    offset = offset and offset or 0
    local x1, y1, w1, h1, x2, y2, w2, h2 = self.x, self.y, self.width, self.height, obj.x, obj.y, obj.width, obj.height
    return self.isSolid and 
        x2 < x1 + w1 and 
        x2 + w2 > x1 and
        y1 <= (y2 + h2) + offset and
        y1 > (y2 + h2) - offset
end

function Tile:checkObjBelow(obj, offset)
    offset = offset and offset or 0
    local x1, y1, w1, h1, x2, y2, w2, h2 = self.x, self.y, self.width, self.height, obj.x, obj.y, obj.width, obj.height
    return self.isSolid and 
        x2 < x1 + w1 and
        x2 + w2 > x1 and
        y2 > y1 and
        y2 > y1 + h1 + offset and
        y2 < y1 + h1
end

function Tile:checkObjOnLeftSide(obj, offset)
    offset = offset and offset or 10
    local x1, y1, w1, h1, x2, y2, w2, h2 = self.x, self.y, self.width, self.height, obj.x, obj.y, obj.width, obj.height
    return self.isSolid and y2 < y1 + h1 and y2 + h2 > y1 and
        x2 + w2 > x1 and x2 + w2 < x1 + offset
end

function Tile:checkObjOnRightSide(obj, offset)
    offset = offset and offset or 10
    local x1, y1, w1, h1, x2, y2, w2, h2 = self.x, self.y, self.width, self.height, obj.x, obj.y, obj.width, obj.height
    return self.isSolid  and y2 < y1 + h1 and y2 + h2 > y1 and
        x2 < x1 + w1 and x2 > x1 + w1 - offset
end

function Tile:setQuad(x, y, width, height)
    
end