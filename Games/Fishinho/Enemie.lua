Enemie = Object:extend()

function Enemie:new(x, y, size, direction, img)
    self.x = x
    self.y = y
    self.speed = 200
    self.movementDt = 0
    self.movementY = 0.5
    self.size = size
    self.direction = direction
    self.images = {}
    table.insert(self.images, love.graphics.newImage("assets/image/fish_1.png"))
    table.insert(self.images, love.graphics.newImage("assets/image/fish_2.png"))
    table.insert(self.images, love.graphics.newImage("assets/image/fish_3.png"))
    table.insert(self.images, love.graphics.newImage("assets/image/fish_4.png"))
    table.insert(self.images, love.graphics.newImage("assets/image/fish_5.png"))
    self.img = self.images[img]
    self.width = self.img:getWidth()*self.size
    self.height = self.img:getHeight()*self.size
end

function Enemie:update(dt)
    self.movementDt = self.movementDt + dt

    if self.movementDt > 1 then
        self.movementDt = 0
        self.movementY= - self.movementY
    end

    self.y = self.y + self.movementY
    self.x = self.x + self.direction
end

function Enemie:draw()
    love.graphics.draw(self.img, self.x, self.y, 0, self.direction*self.size, self.size)
    love.graphics.print(self.size, self.x + (self.direction * self.width/2), self.y + self.height/2, 0.2, 0.2)
end