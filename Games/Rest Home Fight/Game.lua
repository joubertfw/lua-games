Game = Object:extend()

function Game:new()
    -- Window configuration
    love.window.setMode(1920, 1080)
    love.window.setTitle('Rest Home Fight')
    screenHeight = love.graphics.getHeight()
    screenWidth = love.graphics.getWidth()
    spawnArea = {200, love.graphics.getWidth() - 200}
    util = Util()

    background = love.graphics.newImage("assets/image/sky.png")
    font = love.graphics.newFont('assets/fonts/vcr.ttf', 30)
    love.graphics.setFont(font)
    menuTrack = love.audio.newSource("assets/audio/menu.mp3", "stream")
    ingameTrack = love.audio.newSource("assets/audio/ingame.mp3", "stream")
    
    menu = MenuScreen(
        0, 0, 
        {'Start Game 1P','Start Game 2P', 'Exit'}, 
        'assets/fonts/vcr.ttf',
        'assets/image/sky.png',
        0, 0
    )
    state = 'ingame'
    score = 0
    players = {
        Player(0, 0, 'assets/image/oldman.png', {jump = 'space'}),
        Player(50, 0, 'assets/image/oldman.png', {up = 'w', down = 's', left = 'a', right = 'd', jump = 'i', punch = 'o', kick = 'p'})
    }
    for i, player in pairs(players) do
        respawnPlayer(player, i)
    end

    dtRespawn = {2, 2}

    crates = { 
        Tile(spawnArea[1]-200, screenHeight*0.95, 'assets/image/floor.png'),
        Tile(spawnArea[1], screenHeight*0.95, 'assets/image/floor.png'),
        Tile(spawnArea[1]+200, screenHeight*0.95, 'assets/image/floor.png'),
        Tile(spawnArea[1]+400, screenHeight*0.95, 'assets/image/floor.png'),
        Tile(spawnArea[1]+600, screenHeight*0.95, 'assets/image/floor.png'),
        Tile(spawnArea[1]+800, screenHeight*0.95, 'assets/image/floor.png'),

        Tile(spawnArea[2]-600, screenHeight*0.95, 'assets/image/floor.png'),
        Tile(spawnArea[2]-400, screenHeight*0.95, 'assets/image/floor.png'),
        Tile(spawnArea[2]-200, screenHeight*0.95, 'assets/image/floor.png'),
        Tile(spawnArea[2], screenHeight*0.95, 'assets/image/floor.png')
    }
end

function Game:update(dt)
    if state == 'menu' then
        menu:update(dt)
        if menu:getSelected() == #menu.options and love.keyboard.isDown("return") then
            --exit
            love.event.quit()
        elseif menu:getSelected() == 1 then
            --begin game
            state = 'ingame'
            menuTrack:stop()
            --ingameTrack:play()
        end
    elseif state == 'ingame' then
        players[2]:isHitted(players[1].hurtbox, dt)
        players[1]:isHitted(players[2].hurtbox, dt)
        for i, player in pairs(players) do 
            player:update(dt)
            if isBelowScreenView(player) then
                dtRespawn[i] = dtRespawn[i] - dt
                if dtRespawn[i] < 0 then
                    resetDtRespawn(i)
                    respawnPlayer(player, i)
                end
            end
            local mustFall = true
            for i, crate in pairs(crates) do 
                if crate:checkCollision(player) then
                    player:setOnFloor()
                    mustFall = false
                    --player:resetDtJump()
                end
            end
            if mustFall and not player:isJumping() then 
                player:setFalling()
            end
        end

    elseif state == 'gameWon' then

    elseif state == 'gameLost' then

    end
end

function Game:draw()
    if state == 'menu' then
        menu:draw()
    elseif state == 'ingame' then
        love.graphics.draw(background, 0, -300)
        for i, crate in pairs(crates) do 
            crate:draw()
        end
        for i, player in pairs(players) do 
            player:draw()
        end
    elseif state == 'gameWon' then

    elseif state == 'gameLost' then

    end
    
    -- DEBUG
    love.graphics.print("acelX:" .. players[1].acelX, 50, 100)
    love.graphics.print("velX:" .. players[1].velX, 50, 150)
    love.graphics.print("state fly:" .. players[1].dtTimeFly, 50, 300)
    love.graphics.print("state:" .. players[1].state, 50, 350)
    love.graphics.print("acelY:" .. players[1].acelY, 50, 400)
    love.graphics.print("velY:" .. players[1].velY, 50, 450)
    love.graphics.print("dtJump:" .. players[1].dtJump, 50, 500)
    love.graphics.print("spaceRepeat:" .. (players[1].spaceRepeat  and 'true' or 'false'), 50, 550)

    love.graphics.print("acelX:" .. players[2].acelX, 550, 100)
    love.graphics.print("velX:" .. players[2].velX, 550, 150)
    love.graphics.print("state fly:" .. players[2].dtTimeFly, 550, 300)
    love.graphics.print("state:" .. players[2].state, 550, 350)
    love.graphics.print("acelY:" .. players[2].acelY, 550, 400)
    love.graphics.print("velY:" .. players[2].velY, 550, 450)
    love.graphics.print("dtJump:" .. players[2].dtJump, 550, 500)
    love.graphics.print("spaceRepeat:" .. ( players[2].spaceRepeat and 'true' or 'false'), 550, 550)
    --
end

function respawnPlayer(player, i)
    player.velY = 0
    player.x = spawnArea[i]
    player.y = screenHeight/3
end

function resetDtRespawn(i)
    dtRespawn[i] = 2
end

function isBelowScreenView(player)
    return player.y > screenHeight
end

--Basic definition for future usage
function love.keypressed( key, scancode, isrepeat )
    if key == 'return' then
        print('Return key pressed')
    end
end