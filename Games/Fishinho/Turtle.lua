Turtle = Object:extend()

function Turtle:new(x, y, size)
    self.x = x
    self.y = y
    self.size = size
    self.img = love.graphics.newImage("assets/image/turtle.png")
    self.width = self.img:getWidth()*self.size
    self.height = self.img:getHeight()*self.size
    self.velX = 0
    self.velY = 0
    self.acelX = 0
    self.acelY = 0
    self.dtAnim = 1

    -- used to make the fish face the direction according to the arrow key used
    self.direction = 1
end

function Turtle:update(dt)    
    self.velX = (self.velX * 0.95) + self.acelX * dt
    self.velY = (self.velY * 0.95) + self.acelY * dt
    self.x = self.x + self.velX * dt
    self.y = self.y + self.velY * dt    

    if love.keyboard.isDown("down") and not love.keyboard.isDown("up") then
        self.acelY = 750
    elseif love.keyboard.isDown("up") and not love.keyboard.isDown("down") then
        self.acelY = -750
    elseif not love.keyboard.isDown("down") and not love.keyboard.isDown("up") then
        self.acelY = 300
    end
    if love.keyboard.isDown("right") and not love.keyboard.isDown("left") then
        self.acelX = 750
        self.direction = 1
        self.dtAnim = self.dtAnim + dt
    elseif love.keyboard.isDown("left") and not love.keyboard.isDown("right") then
        self.acelX = -750
        self.direction = -1
        self.dtAnim = self.dtAnim - dt
    elseif not love.keyboard.isDown("left") and not love.keyboard.isDown("right") then
        self.acelX = 0
    end
    
    if love.keyboard.isDown("lshift") then
        self.acelX = 1.5 * self.acelX
        self.acelY = 1.5 * self.acelY
    end

    self.dtAnim = self.dtAnim + (0.02 * self.direction)
    self.dtAnim = self.dtAnim < -1.0 and -1.0 or self.dtAnim
    self.dtAnim = self.dtAnim > 1.0 and 1.0 or self.dtAnim

    if self.x - self.width < 0 and self.direction == -1 then
        self.x = self.width
    elseif self.x < 0 and self.direction == 1 then
        self.x = 0
    elseif self.x > love.graphics.getWidth() - self.width then
        self.x = love.graphics.getWidth() - self.width
    end

    if self.y < 0 then
        self.y = 0
    elseif self.y > love.graphics.getHeight() - self.height then
        self.y = love.graphics.getHeight() - self.height
    end
end

function Turtle:draw()
    -- love.graphics.rectangle("fill", self.x, self.y,  self.width*(self.direction * 0.2 +(self.dtAnim * 0.8)), self.height)
    love.graphics.draw(self.img, self.x, self.y, 0, self.size*(self.direction * 0.2 +(self.dtAnim * 0.8)), self.size)
    love.graphics.print(self.size, self.x + ((self.direction * 0.2 +(self.dtAnim * 0.8)) * self.width/2), self.y + self.height/2, 0.4, 0.4)
end

function Turtle:grow(increment)
    self.size = self.size + increment
    self.width = self.img:getWidth()*self.size
    self.height = self.img:getHeight()*self.size
end