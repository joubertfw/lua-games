Game = Object:extend()

function Game:new()
    
    love.window.setMode( 1010, 720 )
    screenHeight = love.graphics.getHeight()
    screenWidth = love.graphics.getWidth()
    background = {img = love.graphics.newImage("assets/image/background.png")}
    love.graphics.setNewFont("assets/font/soopafre.ttf", 50)
    menuTrack = love.audio.newSource("assets/audio/menu.ogg", "stream")
    ingameTrack = love.audio.newSource("assets/audio/ingame.mp3", "stream")

    dtBreath = 10
    bubble = {img = love.graphics.newImage("assets/image/bubble.png"), size = 0.4}
    bubble.width = bubble.img:getWidth()*bubble.size
    bubble.height = bubble.img:getHeight()*bubble.size

    score = 0

    turtle = Turtle(screenWidth/2, screenHeight/2, 0.2)
    gameStarted = false
    enemiesTable = {}
    dtEnemies = 1
end

function Game:update(dt)
    if gameStarted then
        turtle:update(dt)

        generateEnemies(dt)

        if turtle.y <= 10 then
            dtBreath = 10
        end

        dtBreath = dtBreath - dt
        if dtBreath <= 0 then
            gameLost()
        end
        
        for i,enemie in pairs(enemiesTable) do
            enemie:update(dt)
            if checkColision(turtle, enemie) then
                if enemie.size < turtle.size then
                    table.remove(enemiesTable, i)
                    turtle:grow(0.005)
                    score = score + math.floor(enemie.size*10)
                else
                    gameLost()
                end
            end
        end
    else
        menuTrack:play()
        if love.keyboard.isDown('return') then
            startGame()
        end
    end
end

function Game:draw()
    love.graphics.draw(background.img, 0, background.y)
    if gameStarted then
        turtle:draw()
        for i,enemie in pairs(enemiesTable) do
            enemie:draw()
        end
        for i = 0, math.floor(dtBreath) do
            love.graphics.draw(bubble.img, i*(5+bubble.width), 0, 0, bubble.size, bubble.size)
            love.graphics.print('Score: '..score, 0, screenHeight/15, 0, 0.7, 0.7)
        end
    else
        love.graphics.print('Press enter to start', screenWidth/4, screenHeight/2)
    end
end

function verifyPoints(x1, y1, w1, h1, x2, y2, w2, h2)
    if x1 < x2 + w2 and
        x1 + w1 > x2 and
        y1 < y2 + h2 and
        y1 + h1 > y2 then
        return true
    end
end

function checkColision(objA, objB)
    local x1 = objA.x
    local w1 = objA.width

    local x2 = objB.x
    local w2 = objB.width

    if objA.direction == -1 then
        x1 = objA.x - objA.width --[[ * 0.2 +(objA.dtAnim * 0.8))]]
    end

    if objB.direction == -1 then
        x2 = objB.x - objB.width
    end

    return verifyPoints(x1, objA.y, w1, objA.height, x2, objB.y, w2, objB.height)
end

function generateEnemies(dt)
    dtEnemies = dtEnemies - dt
    if dtEnemies < 0 then
        local enemie = randomEnemie(turtle.size)
        table.insert(enemiesTable, enemie)
        dtEnemies = 1
    end
end

function randomEnemie(size)
    local x = love.math.random(0,1)*(screenWidth + 50)
    local y = love.math.random(0, screenHeight)
    local direction = -1
    if x == 0 then
        x = -50
        direction = 1
    end
    local size = love.math.random(size*70, size*130)/100
    local img = love.math.random(5)
    return Enemie(x, y, size, direction, img)
end

function startGame()
    gameStarted = true
    menuTrack:stop()
    ingameTrack:play()
end

function gameLost()
    ingameTrack:stop()
    love.load()
end