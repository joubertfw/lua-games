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
        player1 = Player(screenWidth/2, screenHeight/3, 'assets/image/oldman.png'),
        --player2 = Player(screenWidth/2 - 100, screenHeight/2, 'assets/image/playerBlue/player.png', "a", "d", "w", "s", "v")
    }
    crates = { 
        Tile(screenWidth/2, screenHeight*0.75, 'assets/image/wooden_crate.png') 
    }
    dtEnemies = 2
    enemies = {}
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
            for i, crate in pairs(crates) do 
                if crate:checkCollision(player) then
                    player:setOnFloor()
                else
                    player:setMiddleAir()
                end
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
        --[[ 
        for i, enemie in pairs(enemies) do
            enemie:draw(dt)
        end
        ]]
    elseif state == 'gameWon' then

    elseif state == 'gameLost' then

    end
end

function createEnemie()
    local x, y = 0, 0
    local enemie = Enemie(x, y, 'assets/image/enemie')
    return enemie
end

function enemieSpawn(dt)
    dtEnemies = dtEnemies - dt
    if dtEnemies <= 0 and #enemies <=3 then
        table.insert(enemies, createEnemie())
        dtEnemies = 1
    end
end

--Basic definition for future usage
function love.keypressed( key, scancode, isrepeat )
    if key == 'return' then
        print('Return key pressed')
    end
end