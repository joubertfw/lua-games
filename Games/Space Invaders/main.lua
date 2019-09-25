Shoot = {x = 0, y = 0}
Enemy = {x = 0, y = 0}

function Shoot:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Shoot:draw ()
    love.graphics.draw(self.shootSprite, self.x, self.y)
end

function Shoot:update ()
    self.y = self.y - 12
end

function Enemy:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Enemy:draw ()
    love.graphics.draw(self.enemySprite, self.x, self.y)
end

function Enemy:update (move)
    if move == true then
        self.x = self.x + 0.5
        self.y = self.y + 0.08
    else
        self.x = self.x - 0.5
        self.y = self.y + 0.08
    end
end

function generateEnemies(line, row)
    enemies = {}
    for i = 1, row do
      for j = 1, line do
        table.insert(enemies, Enemy:new{enemySprite = love.graphics.newImage("/Assets/enemy.png"), x = (love.graphics.getWidth()/2 - 350) + i * 40, y = j * 40, width = 32, height = 14})
      end
    end
    return enemies
end

function isInside(point, retangle)
    return point >= retangle.x0 and point <= retangle.x1 and point >= retangle.y0 and point <= retangle.y1
end

-- ponto = (x,y)
function isColiding(objA, objB)
    coordA = {objA.x, objA.y, objA.x + objA.width, objA.y + objA.height}
    coordB = {objB.x, objB.y, objB.x + objB.width, objB.y + objB.height}
    return isInside(coordA[1], coordB) or isInside(coordA[2], coordB) or isInside(coordA[3], coordB) or isInside(coordA[4], coordB)
end

function love.load()
    ship = {
        x = (love.graphics.getWidth()/2) -25,
        y = love.graphics.getHeight() -150,
        width = 48,
        height = 48,
        velX = 0,
        velY = 0,
        acelX = 0,
        acelY = 0,
        sprite = love.graphics.newImage("/Assets/ship.png")
    }

    shoots = {}
    enemies = generateEnemies(5, 15)
    tShoot = 0.3
    tEnemy = 0
    moveDirection = true
end

function love.update(dt)
    -- calculo com atrito
    ship.velX = (ship.velX * 0.95) + ship.acelX * dt
    ship.velY = (ship.velY * 0.95) + ship.acelY * dt
    ship.x = ship.x + ship.velX * dt
    ship.y = ship.y + ship.velY * dt
    -- intervalo entre os tiros
    tShoot = tShoot + dt

    --intervalo entre a mudanca de direcao dos inimigos
    tEnemy = tEnemy + dt
    if tEnemy > 1 then
        tEnemy = 0
        moveDirection = not moveDirection
    end


    if love.keyboard.isDown("space") and tShoot > 0.3 then
        table.insert(shoots, Shoot:new{shootSprite = love.graphics.newImage("/Assets/shoot.png"), x = ship.x + ship.width/2 - 2, y = ship.y - 16, width = 4, height = 28})
        tShoot = 0
    end

    -- atualizar lista de tiros
    for i, shoot in ipairs(shoots) do
        shoot:update()
    end

    -- atualizar lista de inimigos
    for i, enemy in ipairs(enemies) do
        enemy:update(moveDirection)
    end

    if love.keyboard.isDown("down") and not love.keyboard.isDown("up") then
        ship.acelY = 750
    elseif love.keyboard.isDown("up") and not love.keyboard.isDown("down") then
        ship.acelY = -750
    elseif not love.keyboard.isDown("down") and not love.keyboard.isDown("up") then
        ship.acelY = 0
    end
    if love.keyboard.isDown("right") and not love.keyboard.isDown("left") then
        ship.acelX = 750
    elseif love.keyboard.isDown("left") and not love.keyboard.isDown("right") then
        ship.acelX = -750
    elseif not love.keyboard.isDown("left") and not love.keyboard.isDown("right") then
        ship.acelX = 0
    end
end

function love.draw()
    -- desenhar lista de tiros
    for i, shoot in ipairs(shoots) do
        shoot:draw()
    end

    -- desenhar lista de inimigos
    for i, enemy in ipairs(enemies) do
        enemy:draw()
    end

    love.graphics.draw(ship.sprite, ship.x, ship.y)
    love.graphics.print("Aceleracao: "..ship.acelX, 100, 100)
    love.graphics.print("Velocidade: "..ship.velX, 100, 115)
    love.graphics.print("teste", 100, 150)
    --love.graphics.print("Taxa: " .. 1/delta_t .. "fps", 100, 100)
    --isInside(point = 0)
    
end