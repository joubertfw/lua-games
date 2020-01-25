Game = class('Game')

function initState()
    state = 'menu'
    menu:reset()
    --Player creation
    spawnArea = {{x = screenDimensions.x/9, y = screenDimensions.y*0.7}}
    playerConfig = {quadWidth = 300, quadHeight = 300, animVel = 7, 
                cols = 9, rows = 11, idleCols = 5, moveCols = 8, punchCols = 5}
    player = Player(0, 0, 'assets/image/player/santa.png', {left = 'a', right = 'd', up = 'w', down = 's'},  playerConfig)
    spawnPlayer(player, 1)

    --Enemies creation
    enemies = {}
    enemieSpawns = {
        {x = screenDimensions.x*0.43, y = screenDimensions.y*0.98, range = 3, stop = 1, color = 'red', direction = -1},
        {x = screenDimensions.x*0.53, y = screenDimensions.y*0.86, range = 3, stop = 1.5, color = 'blue', direction = 1},
        {x = screenDimensions.x*0.6, y = screenDimensions.y*0.86, range = 2, stop = 2, color = 'red', direction = -1},
        {x = screenDimensions.x*0.83, y = screenDimensions.y*0.98, range = 7.8, stop = 2, color = 'red', direction = 1}
    }
    enemieConfig = {quadWidth = 100, quadHeight = 100, animVel = 6, cols = 4, rows = 3}
    for i, spawn in pairs(enemieSpawns) do
        table.insert(enemies, spawnEnemie(spawn, enemieConfig))
    end

    --Items creation
    items = {
        Item(screenDimensions.x, screenDimensions.y*0.95, 'assets/image/misc/cacetinho.png'),
        Item(screenDimensions.x*1.9, screenDimensions.y*0.4, 'assets/image/misc/cacetinho.png'),
        Item(screenDimensions.x*3.2, screenDimensions.y*0.6, 'assets/image/misc/bomba.png', true)
    }
    eskeleton = Eskeleton(spawnArea[1].x, spawnArea[1].y, 'assets/image/enemies/eskeleton/eskeleton.png')
end

function Game:initialize()
    -- Window configuration
    love.window.setMode(1920, 1080, {fullscreen = false})
    love.window.setTitle('Rest Home Fight')
    screenDimensions = {x = love.graphics.getWidth(), y = love.graphics.getHeight()}
    camera = Camera()
    camera:setBounds(0, 0, 6400, 1276) --cada tile tem 64x64
    camera:setFollowLerp(0.1)
    camera:setFollowStyle('PLATFORMER')

    util = Util()

    --Imgs
    backgroundImg = love.graphics.newImage("assets/image/scenario/sky.png")
    gameWonImg = love.graphics.newImage('assets/image/game_won.png')
    gameOverImg = love.graphics.newImage('assets/image/game_over.png')
    lifeImg = love.graphics.newImage("assets/image/misc/hat.png")

    --Font
    font = love.graphics.newFont('assets/fonts/vcr.ttf', 30)
    love.graphics.setFont(font)
    
    --Audio
    --menuTrack = love.audio.newSource("assets/audio/menu.mp3", "stream")
    --ingameTrack = love.audio.newSource("assets/audio/ingame.mp3", "stream")
    punchMp3 = love.audio.newSource("assets/audio/punch.mp3", "stream")
    hurtMp3 = love.audio.newSource("assets/audio/hurt.mp3", "stream")
    
    --Menu Screen
    menu = MenuScreen(
        0, 150, 
        {'Start Game', 'Exit'}, 
        'assets/fonts/vcr.ttf',
        'assets/image/menu/background.png',
        'assets/image/menu/selectionBox.png',
        0, 0
    )

    -- Reading map files
    map = jsonToMap('assets/maps/winter2.json')
    tiles = renderMap(map,  'assets/maps/platformPack_tilesheet.png')

    initState()

    fps = 0
end

function Game:update(dt)
    fps = 1/dt

    if state == 'menu' then
        menu:update(dt)
        --menuTrack:play()
        if menu:getState() == #menu.options - 1 then
            --exit
            closeGame()
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
        -- itens check
        for i, item in pairs(items) do
            item:update()
            if item:checkCollision(player.hitbox) then
                if item.isBomba then
                    state = 'gameWon'
                else
                    table.remove(items, i)
                    player.isCacetinhoPowered = true
                    player.isInvencible = true
                    player:setInvencibleDt(true)
                end
            end
        end
        eskeleton:update(dt)
        for i, enemie in pairs(enemies) do
            enemie:update(dt)
            if enemie:isAlreadyDead() then
                table.remove(enemies, i)
            elseif not enemie.isHitted then
                if player:isPunching() and enemie:wasHitted(player.hurtbox) then
                punchMp3:play()
                end
                if player.hitbox:checkCollision(enemie.hitbox) and not player.isInvencible then
                    loseLife()
                    hurtMp3:play()
                    player.isInvencible = true
                    player:setInvencibleDt()
                end
            end
        end
        player:setFalling()
        for i, tile in pairs(tiles) do
            if tile:checkObjOnLeftSide(player.hitbox, nil, 32) and player.direction == 1 then
                player.vel.x = 0
                player.position.x = player.position.x - 0.5
                if not player:isOnFloor() then
                    player:setSlidingRight()
                end
            elseif tile:checkObjOnRightSide(player.hitbox, nil, 32) and player.direction == -1 then
                player.vel.x = 0
                player.position.x = player.position.x + 0.5
                if not player:isOnFloor() then
                    player:setSlidingLeft()
                end
            elseif tile:checkObjOnTop(player.hitbox, 10, 10) then
                --this keeps the player always on same level when on floor
                player.position.y = tile.y - player.hitbox.height*2.3
                player:setOnFloor()
                break
            end
        end
        if util:isOutOfScreen(player.hitbox, 'down', 1000) then
            loseLife()
            spawnPlayer(player, 1)
        end
        player:update(dt)
    elseif state == 'gameWon' then
        --ingameTrack:stop()
        if love.keyboard.isDown('return') then
            state = 'menu'
            initState()
        end
    elseif state == 'gameOver' then
        --ingameTrack:stop()
        if love.keyboard.isDown('return') then
            state = 'menu'
            initState()
        end
    end
end

function Game:draw()
    love.graphics.draw(backgroundImg, 0, 0)
    
    if state == 'menu' then
        menu:draw()
    elseif state == 'ingame' then
        camera:attach()

        for i, tile in pairs(tiles) do
            tile:draw()
        end
        for i, item in pairs(items) do
            item:draw()
        end
        for i, enemie in pairs(enemies) do
            enemie:draw()
        end
        eskeleton:draw()
        player:draw()
        
        camera:detach()
        for i = 0, player.lifes - 1 do
            love.graphics.draw(lifeImg, 120*i, 50)
        end
        camera:draw()
    elseif state == 'gameWon' then
        love.graphics.draw(gameWonImg, 0, 0)
    elseif state == 'gameOver' then
        love.graphics.draw(gameOverImg, 0, 0)
    end

    -- DEBUG
    local base = 450
    -- love.graphics.print("isPunching: " .. (player:isPunching() and 'true' or 'false'), 50, base)
    -- love.graphics.print("isHitted: " .. (enemies[1].isHitted and 'true' or 'false'), 50, base + 50)
    -- love.graphics.print("hitRepeat: " .. (player.hitRepeat and 'true' or 'false'), 50, base + 100)
    -- love.graphics.print("dtPunch: " .. (player.dtPunch ), 50, base + 180)
    -- love.graphics.print("acel.x:" .. player.acel.x, 50, base + 50)
    -- love.graphics.print("vel.x:" .. player.vel.x, 50, base + 100)
    --love.graphics.print("acel.y:" .. player.acel.y, 50, base + 200)
    --love.graphics.print("vel.y:" .. player.vel.y, 50, base + 250)
    --love.graphics.print("jumpRepeat:" .. (player.jumpRepeat  and 'true' or 'false'), 50, base + 300)
    -- love.graphics.print("dtPunch:" .. player.dtPunch, 50, base + 400)
    -- love.graphics.print("currentCol:" .. player.image.currentCol, 50, base + 500)

end

function loseLife()
    player.lifes = player.lifes - 1
    if player.lifes == 0 then
        state = 'gameOver'
    end
end

function spawnPlayer(player, i)
    player.position.x = spawnArea[i].x
    player.position.y = spawnArea[i].y
    player.vel.y = 0
    player.vel.x = 0
end

function spawnEnemie(spawn, imgConfig)
    return Enemie(spawn.x, spawn.y, spawn.direction, 'assets/image/npcs/eskimo/'..spawn.color..'.png', spawn.range, spawn.stop, imgConfig)
end

function getTile(number, tilewidth, tileheight)
    return {quadWidth = tilewidth, quadHeight = tileheight, animVel = 1, cols = 14, rows = 7, idleCols = 0, moveCols = 0, currentCol =(number-1)%14, row = math.floor((number-1)/13)*64}
end

function jsonToMap(file)
    local lines = love.filesystem.read(file)

    return json.decode(lines);
end

function renderMap(map, tilemap)
    local tiles = {}
    for i,layer in pairs(map.layers) do
        for j, number in pairs(layer.data) do
            if number ~= 0 then
                table.insert(tiles, Tile(((j-1) % layer.width)*map.tilewidth, math.floor((j-1)/layer.width)*map.tileheight, i == 1, tilemap, getTile(number, map.tilewidth, map.tileheight)))
            end
        end
    end
    return tiles
end

function closeGame()
    love.event.quit()
end