MenuScreen = Object:extend()

function MenuScreen:new(xOptions,yOptions, options, font, bgImg, xImg, yImg)
    self.xOptions, self.yOptions = xOptions, yOptions
    self.options = options
    self.font = font
    self.image = love.graphics.newImage(bgImg)
    self.width, self.height = self.image:getDimensions()
    self.xImg, self.yImg = xImg, yImg
    self.optionSelected = 0
    self.offsetY = font:getHeight()
end

function MenuScreen:getSelected()
    return self.optionSelected
end

function MenuScreen:update(dt)
    if love.keyboard.isDown("down") and not pressedKey then
        self.optionSelected = self.optionSelected < #self.options - 1 and self.optionSelected + 1 or #self.options - 1
        pressedKey = true
    elseif love.keyboard.isDown("up") and not pressedKey then
        self.optionSelected = self.optionSelected > 0 and self.optionSelected - 1  or 0
        pressedKey = true
    elseif not love.keyboard.isDown("down") and not love.keyboard.isDown("up") then
        pressedKey = false
    end
end

function MenuScreen:draw(dt)
    local defaultFont = love.graphics.getFont()
    love.graphics.setFont(self.font)
    love.graphics.draw(self.image, self.xImg, self.yImg)
    for i, option in pairs(self.options) do
        love.graphics.printf(option, self.xOptions, self.yOptions + (self.yOption * self.offsetY), self.width, 'center')
        self.yOption = self.yOption + 1
    end
    self.yOption = 0
    love.graphics.setFont(defaultFont)
end