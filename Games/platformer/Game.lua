Game = class('Game')

local default = {

}

function Game:initialize()
    -- Window configuration
    love.window.setMode(1920, 1080)
    love.window.setTitle('Rest Home Fight')
    screenDimensions = {x = love.graphics.getWidth(), y = love.graphics.getHeight()}
    camera = Camera()
    camera:setFollowLerp(0.1)
    camera:setFollowStyle('PLATFORMER')

    util = Util()

    --Imgs
    backgroundImg = love.graphics.newImage("assets/image/scenario/sky.png")
    --gameEndImg = love.graphics.newImage('assets/image/namdlo_win.png')

    --Font
    font = love.graphics.newFont('assets/fonts/vcr.ttf', 30)
    love.graphics.setFont(font)
    
    --Audio
    --menuTrack = love.audio.newSource("assets/audio/menu.mp3", "stream")
    --ingameTrack = love.audio.newSource("assets/audio/ingame.mp3", "stream")
    
    --Menu Screen
    menu = MenuScreen(
        0, 150, 
        {'Start Game', 'Exit'}, 
        'assets/fonts/vcr.ttf',
        'assets/image/menu/background.png',
        'assets/image/menu/selectionBox.png',
        0, 0
    )

    state = 'menu'

    --Entities creation
    spawnArea = {{x = screenDimensions.x/2, y = screenDimensions.y/2}}
    imgConfig = {quadWidth = 300, quadHeight = 300, animVel = 7, 
                cols = 9, rows = 11, 
                idleCols = 5, moveCols = 8, punchCols = 5}
    player = Player(0, 0, 'assets/image/player/santa.png', {left = 'a', right = 'd', up = 'w', down = 's'}, {image = imgConfig})

    spawnPlayer(player, 1)

    tiles = {
        Tile(screenDimensions.x/12, screenDimensions.y*0.85, 'assets/image/scenario/floor_1.png', true),
        Tile(screenDimensions.x, screenDimensions.y*0.85, 'assets/image/scenario/floor_1.png', true)
    }
    items = {
        Item(screenDimensions.x, screenDimensions.y/2, 'assets/image/misc/cacetinho.png')
    }

    score = 0
end

function Game:update(dt)
    if state == 'menu' then
        menu:update(dt)
        --menuTrack:play()
        if menu:getState() == #menu.options - 1 then
            --exit
            love.event.quit()
        elseif menu:getState() == 0 then
            --begin game
            state = 'ingame'
            --menuTrack:stop()
            --ingameTrack:play()
        end

    elseif state == 'ingame' then
        camera:update(dt)
        camera:follow(player.hitbox.x, player.hitbox.y)
        --ingameTrack:play()
        local freeFall = true --not in collision
        player:update(dt)
        for i, item in pairs(items) do
            item:update()
            if item:checkCollision(player.hitbox) then
                score = score + 1
                table.remove(items, i)
                --gotCacetinhoFX()
            end
        end
        for i, tile in pairs(tiles) do
            if tile:checkObjOnTop(player.hitbox) then
                player:setOnFloor()
                player.position.y = tile.y - player.hitbox.height*2.2
                freeFall = false
            end
        end
        if freeFall then
            player:setFalling()
        end
    elseif state == 'gameEnd' then
        --ingameTrack:stop()
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
        camera:attach()
        love.graphics.draw(backgroundImg, 0, 0)
        for i, tile in pairs(tiles) do 
            tile:draw()
        end 
        for i, item in pairs(items) do
            item:draw()
        end
        player:draw()
        camera:detach()
        camera:draw()
    elseif state == 'gameEnd' then
        love.graphics.draw(gameEndImg, 0, 0)
    end

    -- DEBUG
    local base = 450
    love.graphics.print("acel.x:" .. player.acel.x, 50, base + 50)
    love.graphics.print("vel.x:" .. player.vel.x, 50, base + 100)
    love.graphics.print("state:" .. player.state, 50, base + 150)
    love.graphics.print("acel.x:" .. player.acel.y, 50, base + 200)
    love.graphics.print("vel.x:" .. player.vel.y, 50, base + 250)
    love.graphics.print("buttonRepeat:" .. (player.buttonRepeat  and 'true' or 'false'), 50, base + 300)
    love.graphics.print("score:" .. score, 50, base + 350)
    love.graphics.print("dtPunch:" .. player.dtPunch, 50, base + 400)
    love.graphics.print("hitRepeat:" .. (player.hitRepeat and 'true' or 'false'), 50, base + 450)
    love.graphics.print("currentCol:" .. player.image.currentCol, 50, base + 500)

end

function spawnPlayer(player, i)
    player.position.x = spawnArea[i].x
    player.position.y = spawnArea[i].y
end

function resetGame()
    --Reset things to default values
    menu:reset()
end