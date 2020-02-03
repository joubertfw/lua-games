Image = class('Image')

function Image:initialize(path, quadConfig)
    self.drawable = love.graphics.newImage(path)
    self.quadConfig = quadConfig
    if quadConfig then
        self.width = quadConfig.quadWidth
        self.height = quadConfig.quadHeight
        self.animVel = quadConfig.animVel
        self.currentCol = 0
        self.row = quadConfig.row
        self.quad = love.graphics.newQuad(0, 0, self.width, self.height, self.drawable:getDimensions())
    else
        self.width, self.height = self.drawable:getDimensions()
    end
end

-- Only for quadBased images
function Image:update(currentCol, row)
    self.currentCol = currentCol
    if self.quadConfig then
        self.quad:setViewport(self.width*math.floor(self.currentCol), row, self.width, self.height)
    end
end

function Image:draw(x, row, direction)
    if self.quadConfig then
        love.graphics.draw(self.drawable, self.quad, x, row, 0, direction, 1, self.width/2, self.height/2)
    else
        love.graphics.draw(self.drawable, x, row, 0, direction, 1)
    end
end

function Image:getScale()
    return self.imageScale
end

function Image:getDimensions()
    return self.width, self.height
end