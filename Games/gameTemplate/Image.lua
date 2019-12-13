Image = Object:extend()

function Image:new(path, config, quadBased)
    if quadBased then
        self.quadWidth = config.quadWidth
        self.quadHeight = config.quadHeight
        self.animVel = config.animVel
        self.quadQtd = config.quadQtd
        self.stopQuad = config.stopQuad
        self.currentImg = 0
        self.quad = love.graphics.newQuad(0, 0, self.quadWidth, self.quadHeight, self.image:getDimensions())
    end
    self.drawable = love.graphics.newImage(imgPath)
end

-- Only for quadBased images
function Image:update(currentImg, y)
    if quadBased then
        self.quad:setViewport(self.quadWidth*math.floor(self.currentImg), y, self.quadWidth, self.quadHeight)
    end
end

function Image:draw(x, y)
    if quadBased then
        love.graphics.draw(self.drawable, self.quad, x, y)
    else
        love.graphics.draw(self.drawable, x, y)
    end
end