Game = Object:extend()

function Game:new()
    -- Window configuration
    love.window.setMode(1920, 1080)
    love.window.setTitle('Rest Home Fight')
    screenHeight = love.graphics.getHeight()
    screenWidth = love.graphics.getWidth()
    
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
        Player(0, 0, 'assets/image/oldman.png', {jump = 'up'}),
        --Player(0, 0, 'assets/image/playerBlue/player.png')
    }
    for i, player in pairs(players) do
        respawnPlayer(player, i)
    end

    dtRespawn = {2, 2}

    crates = { 
        Tile(screenWidth/2, screenHeight*0.75, 'assets/image/wooden_crate.png'),
        Tile(screenWidth/3, screenHeight*0.75, 'assets/image/wooden_crate.png')
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
end

function respawnPlayer(player, i)
    player.velY = 0
    player.x = screenWidth/2
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