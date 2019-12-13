Game = Object:extend()

local default = {

}

function Game:new()
    -- Window configuration
    love.window.setMode(1920, 1080)
    love.window.setTitle('Rest Home Fight')
    screenDimensions = {x = love.graphics.getWidth(), y = love.graphics.getHeight()}
    util = Util()

    --Imgs
    backgroundImg = love.graphics.newImage("assets/image/sky.png")
    gameEndImg = love.graphics.newImage('assets/image/namdlo_win.png')

    --Font
    font = love.graphics.newFont('assets/fonts/vcr.ttf', 30)
    love.graphics.setFont(font)
    
    --Audio
    menuTrack = love.audio.newSource("assets/audio/menu.mp3", "stream")
    ingameTrack = love.audio.newSource("assets/audio/ingame.mp3", "stream")
    
    --Menu Screen
    menu = MenuScreen(
        0, 150, 
        {'Start Game', 'Exit'}, 
        'assets/fonts/vcr.ttf',
        'assets/image/menu.png',
        'assets/image/box.png',
        0, 0
    )

    state = 'menu'

    --Entities creation
    spawnArea = {{x = 0, y = 0}, {x = 0, y = 0}}
    players = {
        Player(0, 0, 'assets/image/oldman.png'))
    }

    for i, player in pairs(players) do
        spawnPlayer(player, i)
    end

    tiles = {
        Tile(screenWidth/12, screenHeight*0.85, 'assets/image/scenario/floor_1.png', true)
    }
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
        for i, player in pairs(players) do 
            player:update(dt)
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
        love.graphics.draw(background, 0, 0)
        for i, tile in pairs(tiles) do 
            tile:draw()
        end
        for i, player in pairs(players) do 
            player:draw()
        end
    elseif state == 'gameEnd' then
        love.graphics.draw(gameEndImg, 0, 0)
    end

end

function spawnPlayer(player, i)
    player.x = spawnArea[i].x
    player.y = spawnArea[i].y
end

function resetGame()
    --Reset things to default values
    menu:reset()
end