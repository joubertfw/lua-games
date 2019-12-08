MenuScreen = Object:extend()

function MenuScreen:new(xOptions,yOptions, options, font, bgImg, boxImage, xImg, yImg)
    self.xOptions, self.yOptions = xOptions, yOptions
    self.font = love.graphics.newFont(font, 30)
    self.image = love.graphics.newImage(bgImg)
    self.boxImage = love.graphics.newImage(boxImage)
    self.options = options
    self.width, self.height = self.image:getDimensions()
    self.widthBox, self.heightBox = self.boxImage:getDimensions()
    self.xImg, self.yImg = xImg, yImg
    self.optionSelected = 0
    self.internalState = -1
    self.yBox = 0
    self.offsetYMenu = self.height - self.height/3
    self.offsetY = self.font:getHeight()
end

function MenuScreen:getSelected()
    return self.optionSelected
end

function MenuScreen:getState()
    return self.internalState
end

function MenuScreen:update(dt)
    if love.keyboard.isDown("down") and not pressedKey then
        self.optionSelected = self.optionSelected < #self.options - 1 and self.optionSelected + 1 or #self.options - 1
        pressedKey = true
    elseif love.keyboard.isDown("up") and not pressedKey then
        self.optionSelected = self.optionSelected > 0 and self.optionSelected - 1  or 0
        pressedKey = true
    elseif love.keyboard.isDown("return") then
        self.internalState = self.optionSelected
    elseif not love.keyboard.isDown("down") and not love.keyboard.isDown("up") then
        pressedKey = false
    end
    
    self.yBox = self.offsetYMenu + (self.optionSelected * self.offsetY + 2)
end

function MenuScreen:draw(dt)
    local defaultFont = love.graphics.getFont()
    love.graphics.setFont(self.font)
    love.graphics.draw(self.image, self.xImg, self.yImg)
    love.graphics.draw(self.boxImage, ((self.width)/2) - (self.widthBox/2), self.yBox)
    for i, option in pairs(self.options) do
        love.graphics.printf(option, self.xOptions, self.offsetYMenu + (self.yOptions + (self.yOptions * self.offsetY)), self.width, 'center')
        self.yOptions = self.yOptions + 1
    end
    self.yOptions = 0
    love.graphics.setFont(defaultFont)
end