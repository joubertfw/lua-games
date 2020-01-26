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
        {x = screenDimensions.x*0.43, y = screenDimensions.y*0.8, range = 3, stop = 1, direction = -1}
    }
    for i, spawn in pairs(enemieSpawns) do
        table.insert(enemies, spawnEnemie(spawn))
    end

    --Items creation
    items = {
        Item(screenDimensions.x, screenDimensions.y*0.95, 'assets/image/misc/cacetinho.png'),
        Item(screenDimensions.x*1.9, screenDimensions.y*0.4, 'assets/image/misc/cacetinho.png'),
        Item(screenDimensions.x*3.2, screenDimensions.y*0.6, 'assets/image/misc/bomba.png', true)
    }
end

function Game:initialize()
    -- Window configuration
    love.window.setMode(1920, 1080, {fullscreen = false})
    love.window.setTitle('Rest Home Fight')
    screenDimensions = {x = love.graphics.getWidth(), y = love.graphics.getHeight()}
    camera = Camera()
    -- camera:setBounds(0, 0, 6400, 1276) --cada tile tem 64x64
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
    -- map = jsonToMap('assets/maps/winter2.json')
    map = require('assets/maps/Map1')
    tiles = renderMap(map)
    tilemap = TileMap(tiles, 'assets/maps/Tileset.png')
    -- co = coroutine.create(function ()
    --     tiles = renderMap(map)
    --     tilemap = TileMap(tiles, 'assets/maps/tilemap.png')
    --   end)
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
            
            -- coroutine.resume(co)
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
        if util:isOutOfScreen(player.hitbox, 'down', 1000000) then
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
        tilemap:draw()
        for i, item in pairs(items) do
            item:draw()
        end
        for i, enemie in pairs(enemies) do
            enemie:draw()
        end
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

function spawnEnemie(spawn)
    return Skeleton(spawn.x, spawn.y, spawn.direction, 'assets/image/enemies/skeleton/skeleton.png', spawn.range, spawn.stop)
end

function renderMap(map)
    local tiles = {}
    for i,layer in pairs(map.layers) do
        for j, number in pairs(layer.data) do
            if number ~= 0 then
                table.insert(tiles, Tile(((j-1) % layer.width)*map.tilewidth, math.floor((j-1)/layer.width)*map.tileheight, number))-- , i == 1, tilemap, getTile(number, map.tilewidth, map.tileheight)
            end
        end
    end
    return tiles
end

function closeGame()
    love.event.quit()
end