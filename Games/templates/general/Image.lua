Image = class('Image')

function Image:initialize(path, quadConfig)
    self.drawable = love.graphics.newImage(path)
    self.quadConfig = quadConfig
    if quadConfig then
        self.width = quadConfig.quadWidth
        self.height = quadConfig.quadHeight
        self.animVel = quadConfig.animVel
        self.quadQtd = quadConfig.quadQtd
        self.currentImg = 0
        self.quad = love.graphics.newQuad(0, 0, self.width, self.height, self.drawable:getDimensions())
    else
        self.width, self.height = self.drawable:getDimensions()
    end
end

-- Only for quadBased images
function Image:update(currentImg, y)
    if self.quadConfig then
        self.quad:setViewport(self.width*math.floor(self.currentImg), y, self.width, self.height)
    end
end

function Image:draw(x, y)
    if self.quadConfig then
        love.graphics.draw(self.drawable, self.quad, x, y)
    else
        love.graphics.draw(self.drawable, x, y)
    end
end