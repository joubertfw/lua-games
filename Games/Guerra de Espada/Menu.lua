Menu = Object:extend()

function Menu:new(x,y, options, imgPath)
    self.image = love.graphics.newImage(imgPath.. "box.png")
    self.backImage = love.graphics.newImage(imgPath.. "menu.png")
    self.backImageFront = love.graphics.newImage(imgPath.. "menu2.png")
    self.boxW, self.boxH = self.image:getDimensions()
    self.yBox = 100
    self.x = x
    self.y = y
    self.offsetY = 10
    self.yOption = 0
    self.optionSelected = 0
    self.options = options
    self.internalState = 0
end

function Menu:getSelected()
    return self.optionSelected
end

function Menu:getState()
    return self.internalState
end

function Menu:setState(state)
    self.internalState = state
end

function Menu:update(dt)
    if love.keyboard.isDown("down") and not pressedKey then
        self.optionSelected = self.optionSelected < #self.options - 1 and self.optionSelected + 1 or #self.options - 1
        pressedKey = true
    elseif love.keyboard.isDown("up") and not pressedKey then
        self.optionSelected = self.optionSelected > 0 and self.optionSelected - 1  or 0
        pressedKey = true
    elseif not love.keyboard.isDown("down") and not love.keyboard.isDown("up") then
        pressedKey = false
    end

    self.yBox = self.y + (self.optionSelected * self.offsetY*6 + 2) - self.boxH/3
end

function Menu:draw(dt)
    love.graphics.draw(self.backImage, 0, 0, 0, 1, 1)
    love.graphics.draw(self.backImageFront, self.x - 2*self.boxH, self.y-self.offsetY*3)
    love.graphics.draw(self.image, self.x - 2*self.boxH, self.yBox)
    for i, option in pairs(self.options) do 
        love.graphics.print(option, self.x - #option*4, self.y + (self.yOption * self.offsetY*6))
        self.yOption = self.yOption + 1
    end
    self.yOption = 0
end