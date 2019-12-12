Game = Object:extend()

function Game:new()
    -- Window configuration
    love.window.setMode(1920, 1080)
    love.window.setTitle('Rest Home Fight')
    screenHeight = love.graphics.getHeight()
    screenWidth = love.graphics.getWidth()
    spawnArea = {200, love.graphics.getWidth() - 300}
    util = Util()

    background = love.graphics.newImage("assets/image/sky.png")
    font = love.graphics.newFont('assets/fonts/vcr.ttf', 30)
    love.graphics.setFont(font)
    menuTrack = love.audio.newSource("assets/audio/menu.mp3", "stream")
    ingameTrack = love.audio.newSource("assets/audio/ingame.mp3", "stream")
    
    menu = MenuScreen(
        0, 150, 
        {'Start Game', 'Exit'}, 
        'assets/fonts/vcr.ttf',
        'assets/image/menu.png',
        'assets/image/box.png',
        0, 0
    )
    state = 'gameEnd'
    score = 0
    players = {
        Player(0, 0, 'assets/image/oldman.png', 'assets/image/indicator.png' , {jump = 'w', down = 's', left = 'a', right = 'd', punch = 'f', kick = 'g'}, 1),
        Player(0, 0, 'assets/image/namdlo.png', 'assets/image/indicator.png' , {jump = 'up'}, 2)
    }
    for i, player in pairs(players) do
        respawnPlayer(player, i)
    end

    dtRespawn = {2, 2}

    crates = { 
        Tile(screenWidth/12, screenHeight*0.85, 'assets/image/floor_1.png', true),
        Tile(screenWidth/6, screenHeight/1.5, 'assets/image/wooden_crate_1.png', false),
        Tile(screenWidth*0.8, screenHeight/3, 'assets/image/wooden_crate_1.png', false),
        Tile(screenWidth/12, screenHeight/3, 'assets/image/wooden_crate_1.png', false),
        Tile(screenWidth*0.7, screenHeight/1.5, 'assets/image/wooden_crate_1.png', false),
        Tile(screenWidth/2 - 125, screenHeight/2, 'assets/image/wooden_crate_1.png', true)
    }

    whoWon = 'none'
end

function Game:update(dt)
    if state == 'menu' then
        menu:update(dt)
        menuTrack:play()
        if menu:getState() == #menu.options - 1 then
            --exit
            love.event.quit()
        elseif menu:getState() == 0 then
            --begin game
            state = 'ingame'
            menuTrack:stop()
            ingameTrack:play()
        end
    elseif state == 'ingame' then
        ingameTrack:play()
        players[2]:isHitted(players[1].hurtbox, players[1].hitType, dt)
        players[1]:isHitted(players[2].hurtbox, players[2].hitType, dt)
        for i, player in pairs(players) do 
            player:update(dt)
            if isBelowScreenView(player) then
                dtRespawn[i] = dtRespawn[i] - dt
                if dtRespawn[i] < 0 then
                    resetDtRespawn(i)
                    respawnPlayer(player, i)
                end
            end
            local freeFall = true --not in collision
            for i, crate in pairs(crates) do 
                if crate.isSolid then
                    if crate:checkPlayerOnLeftSide(player.hitbox) and player.direction == 1 then
                        player.velX = 0
                        -- player.x = player.x - 1
                        if not player:isOnFloor() then
                            player:setSlidingRight()
                            freeFall = false
                        end
                    elseif crate:checkPlayerOnRightSide(player.hitbox) and player.direction == -1 then
                        player.velX = 0
                        -- player.x = player.x + 1
                        if not player:isOnFloor() then
                            player:setSlidingLeft()
                            freeFall = false
                        end
                    elseif crate:checkPlayerBelow(player.hitbox) then
                        player:fall(true)
                        player:setFalling()
                    elseif crate:checkPlayerOnTop(player.hitbox) then
                        player:setOnFloor()
                        player.y = crate.y - player.height + 1
                        freeFall = false
                    end
                elseif crate:checkPlayerOnTop(player.hitbox) then
                    player:setOnFloor()
                    player.y = crate.y - player.height + 1
                    freeFall = false
                end
            end
            if freeFall then
                player:setFalling()
            end

            if player.lifes <= 0 then
                if i == 1 then
                    state = 'gameEnd'
                    whoWon = 'namdlo'
                else
                    state = 'gameEnd'
                    whoWon = 'oldman'
                end
            end
        end

    elseif state == 'gameEnd' then
        ingameTrack:stop()
        if love.keyboard.isDown('return') then
            state = 'menu'
            resetGame()
        end
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
    elseif state == 'gameEnd' then
        if whoWon == 'namdlo' then
            love.graphics.draw(love.graphics.newImage('assets/image/namdlo_win.png'), 0, 0)
            love.graphics.print("Press enter to restart", 700, 950)
        else
            love.graphics.draw(love.graphics.newImage('assets/image/oldman_win.png'), 0, 0)
            love.graphics.print("Press enter to restart", 700, 950)
        end
    end
    
    -- DEBUG
    love.graphics.print("acelX:" .. players[1].acelX, 50, 100)
    love.graphics.print("velX:" .. players[1].velX, 50, 150)
    love.graphics.print("state:" .. players[1].state, 50, 350)
    love.graphics.print("acelY:" .. players[1].acelY, 50, 400)
    love.graphics.print("velY:" .. players[1].velY, 50, 450)
    love.graphics.print("dtJump:" .. players[1].dtJump, 50, 500)
    love.graphics.print("spaceRepeat:" .. (players[1].spaceRepeat  and 'true' or 'false'), 50, 550)

    love.graphics.print("acelX:" .. players[2].acelX, 550, 100)
    love.graphics.print("velX:" .. players[2].velX, 550, 150)
    love.graphics.print("state:" .. players[2].state, 550, 350)
    love.graphics.print("acelY:" .. players[2].acelY, 550, 400)
    love.graphics.print("velY:" .. players[2].velY, 550, 450)
    love.graphics.print("dtJump:" .. players[2].dtJump, 550, 500)
    love.graphics.print("spaceRepeat:" .. ( players[2].spaceRepeat and 'true' or 'false'), 550, 550)
    --
    love.graphics.print("MENU:" .. menu.yBox, 800, 100)
    love.graphics.print("MENU:" .. menu.optionSelected, 800, 150)
    love.graphics.print("MENU:" .. menu.internalState, 800, 200)

end

function respawnPlayer(player, i)
    player.lifes = player.lifes - 1
    player.velY = 0
    player.x = spawnArea[i]
    player.y = screenHeight/3
    player.indicator = false
end

function resetDtRespawn(i)
    dtRespawn[i] = 2
end

function isBelowScreenView(player)
    return player.y > screenHeight
end

function resetGame()
    menu:reset()
    players[1].lifes = 4
    players[2].lifes = 4
end