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
    self.y = self.y - 3
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
        table.insert(enemies, Enemy:new{enemySprite = love.graphics.newImage("/Assets/enemy.png"), x = (love.graphics.getWidth()/2 - 350) + i * 40, y = j * 40, width = 32, height = 14, delete = false})
      end
    end
    return enemies
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2 + w2 and x2 < x1 + 1 and y1 < y2 + h2 and y2 < y1 + h1
  end

function isColiding(objA, objB)
    v = CheckCollision(objA.x, objA.y, objA.width, objA.height, objB.x, objB.y, objB.width, objB.height)
    if (v == true )then
        return "TRUE"
    else
        return "FALSE"
    end
end

function ArrayRemove(t)
    local j, n = 1, #t;

    for i = 1,n do
        if (t[i].delete == false) then
            if (i ~= j) then
                t[j] = t[i];
                t[i] = nil;
            end
            j = j + 1;
        else
            t[i] = nil;
        end
    end

    return t;
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
    printShot = {}
    printEnemy = {}
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
        table.insert(shoots, Shoot:new{shootSprite = love.graphics.newImage("/Assets/shoot.png"), x = ship.x + ship.width/2 - 2, y = ship.y - 16, width = 4, height = 28, delete = false})
        tShoot = 0
    end

    -- atualizar lista de tiros
    for i = 1,#shoots do
    -- for i, shoot in ipairs(shoots) do
        shoots[i]:update()
        printShot = shoots[i].x
        for i = 1,#enemies do
            printEnemy = enemies[i].x
            printShoots[i] = isColiding(enemies[i], shoots)[i]
        end
    end

    -- shoots = ArrayRemove(shoots)
    -- enemies = ArrayRemove(enemies)

    -- atualizar lista de inimigos
    for i, enemy in ipairs(enemies) do
        enemy:update(moveDirection)
        -- printEnemy = enemy.x
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
    love.graphics.print(printShot, 100, 150)
    love.graphics.print(printEnemy, 100, 170)
    --[[if isInside({x = 4, y = 4}, {x0 = 0, y0 = 0, x1 = 4, y1 = 4}) then
        love.graphics.print("TRUE", 100, 150)
    else
        love.graphics.print("FALSE", 100, 150)
    end]]--
    --love.graphics.print("Taxa: " .. 1/delta_t .. "fps", 100, 100)
    --isInside(point = 0)
    
end