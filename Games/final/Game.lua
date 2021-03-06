Game = class('Game')

lastbutton = "none"
 
function love.gamepadpressed(joystick, button)
    lastbutton = button
end

function initLevel(level)
    -- Just set the spawns for each level
    playerSpawn = {}
    camera:setBounds(0, 0, map.width * 64,  map.height * 64)
    if level == 1 then
        --Player creation
        playerSpawn = {x = 6 * 64, y = (map.height - 6) * 64}

        --Enemies creation
        skeletonSpawns = {
            {x = 21 * 64, y = (map.height - 6) * 64, range = 3, stop = 1, direction = 1},
            {x = 48 * 64, y = (map.height - 11) * 64, range = 2, stop = 1, direction = 1},
            {x = 31 * 64, y = 31 * 64, range = 4, stop = 1, direction = 1},
            {x = 70 * 64, y = (map.height - 5) * 64, range = 1, stop = 1, direction = 1}
        }

        npcSpawns = {
            {x = 16 * 64, y = (map.height - 2) * 64, direction = -1, type = 'archer'}
        }

        --Items creation
        items = {
            Item((map.width - 6) * 64, (map.height - 60) * 64, 'assets/image/misc/cacetinho.png'),
        }		
    elseif level == 2 then
        playerSpawn = {x = 2 * 64, y = 94 * 64}
        npcSpawns = {}
        items = {
            Item((map.width - 3) * 64, (map.height - 96) * 64, 'assets/image/misc/cacetinho.png'),
        }

        skeletonSpawns = {
            {x = (map.width - 8) * 64, y = (map.height - 69) * 64, range = 1, stop = 1, direction = 1},
            {x = (map.width - 21) * 64, y = (map.height - 26) * 64, range = 1, stop = 1, direction = 1}
        }
    elseif level == 3 then
        skeletonSpawns = {
            {x = 17 * 64, y = 40 * 64, range = 3, stop = 4, direction = 1},
            {x = 27 * 64, y = 38 * 64, range = 1, stop = 2, direction = 1},
            {x = 34 * 64, y = 23 * 64, range = 2, stop = 1, direction = 1},
            {x = 18 * 64, y = 20 * 64, range = 3, stop = 3, direction = 1},
            {x = 63 * 64, y = 45 * 64, range = 4, stop = 5, direction = 1},
            {x = 51 * 64, y = 34 * 64, range = 1, stop = 6, direction = 1}
        }

        playerSpawn = {x = 1 * 64, y = 36 * 64}
        npcSpawns = {}

        items = {
            Item((map.width - 4) * 64, (map.height - 4) * 64, 'assets/image/misc/bomba.png', true)
        }
    end
    -- Spawning
    spawnPlayer(player, level)

    skeletons = {}
    for i, spawn in pairs(skeletonSpawns) do
        table.insert(skeletons, spawnSkeleton(spawn))
    end

    npcs = {}
    for i, spawn in pairs(npcSpawns) do
        table.insert(npcs, spawnArcher(spawn))
    end
end

function Game:initialize()
    -- Window configuration
    playerSpawn = {x = 1 * 64, y = 36 * 64}
    love.window.setMode(1920, 1080, {fullscreen = false})
    love.window.setTitle('Game Jam Final')
    screenDimensions = {x = love.graphics.getWidth(), y = love.graphics.getHeight()}
    windowWidth, windowHeight = love.window.getDesktopDimensions()
    push:setupScreen(screenDimensions.x , screenDimensions.y, windowWidth, windowHeight, { fullscreen = true})
    util = Util()
    mapsName = {"Entrada Macabra", "Escadaria Quebrada", "Sala de prisao"}
    player = Player(0, 0, 'assets/image/player/adventurer.png', {left = 'a', right = 'd', up = 'w', down = 's'})
    camera = Camera(player.position.x, player.position.y, screenDimensions.x, screenDimensions.y)
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
    nivel = 1
    scoreTotal = 0
    dtNivelNome = 0
    resetMenu()
    loadMap(nivel)
    initLevel(nivel)
    
    -- camera:setBounds(0, 0, 6400, 1276) --cada tile tem 64x64
    camera:setFollowLerp(0.1)
    camera:setFollowStyle('PLATFORMER')

    fps = 0
end

function Game:update(dt)
    if state == 'ingame' then
        scoreTotal = scoreTotal + dt
        dtNivelNome = dtNivelNome + dt
    end
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
                    nivel = nivel + 1
                    loadMap(nivel)
                    initLevel(nivel)
                    dtNivelNome = 0
                end
            end
        end
        for i, npc in pairs(npcs) do
            npc:update(dt)
            -- check if player is near the npc and if is interacting
            if npc.hitbox:checkCollision(player.hitbox) and player:interacted() then
                npc.isTalking = true
            end
            if npc.isTalking and 
                util:distanceBetween(player.hitbox.x, player.hitbox.y, npc.hitbox.x, npc.hitbox.y) > 200 then
                npc.isTalking = false
            end
        end
        for i, enemie in pairs(skeletons) do
            enemie:update(dt)
            if enemie:isAlreadyDead() then
                table.remove(skeletons, i)
            elseif not enemie.isHitted then
                if player:isAttacking() and enemie:wasHitted(player.hurtbox) then
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
        player:setNoColision()
       for i, tile in pairs(tiles) do
            if tile:checkObjBelow(player.hitbox, 10, 20) then
                player.vel.y = 0
                --this prevents player from getting into the wall
                -- player.position.y = player.position.y + 0.2
                --player.acel.y = 0
            end
            if tile:checkObjOnTop(player.hitbox, 10, 10) then
                --this keeps the player always on same level when on floor
                player.position.y = tile.y - (player.hitbox.height/2)
                player:setOnFloor()
                -- break
            end
            if tile:checkObjOnLeftSide(player.hitbox, 32) then
               player.vel.x = 0
               --this prevents player from getting into the wall
               -- player.position.x = player.position.x - 0.125
               if not player:isOnFloor() and player:isMovingRight() then
                   player:setColisionRight()
               end
            end
            if tile:checkObjOnRightSide(player.hitbox, 32) then
               player.vel.x = 0
               if not player:isOnFloor() and player:isMovingLeft() then
                   player:setColisionLeft()
               end
            end
        end
        if util:isOutOfScreen(player.hitbox, 'down', map.height* 64) then
            loseLife()
            spawnPlayer(player, 1)
        end
        player:update(dt)
    elseif state == 'gameWon' then
        --ingameTrack:stop()
        if love.keyboard.isDown('return') then
            resetMenu()
            nivel = 1
        end
    elseif state == 'gameOver' then
        --ingameTrack:stop()
        if love.keyboard.isDown('return') then
            resetMenu()
            nivel = 1
        end
    end
end

function Game:draw(dt)
    push:start()
    love.graphics.draw(backgroundImg, 0, 0)
    
    if state == 'menu' then
        menu:draw()
    elseif state == 'ingame' then
        camera:attach()
        backTilemap:draw()
        tilemap:draw()
        for i, item in pairs(items) do
            item:draw()
        end
        for i, enemie in pairs(skeletons) do
            enemie:draw()
        end
        for i, npc in pairs(npcs) do
            npc:draw()
        end
        player:draw()
        camera:detach()
        for i = 0, player.lifes - 1 do
            love.graphics.draw(lifeImg, 120*i, 50)
        end
        camera:draw()
    elseif state == 'gameWon' then
        love.graphics.draw(gameWonImg, 0, 0)
        love.graphics.print("Seu tempo: " .. string.format("%.2f", scoreTotal), (screenDimensions.x/2) -100 , 400)
    elseif state == 'gameOver' then
        love.graphics.draw(gameOverImg, 0, 0)
        love.graphics.print("Seu tempo: " .. string.format("%.2f", scoreTotal), (screenDimensions.x/2) -100 , 400)
    end

    if dtNivelNome < 3 and state == 'ingame' then
        love.graphics.print( mapsName[nivel], (screenDimensions.x/2) -100, 400)
    end
    
    -- DEBUG
    local base = 200
    --    love.graphics.print("Last gamepad button pressed: ".. lastbutton, 600, 50)
    love.graphics.print("pos.x:" .. player.position.x, 50, base + 50)
    love.graphics.print("spawn x:" .. playerSpawn.x, 50, base + 100)
    
    love.graphics.print("pos.y:" .. player.position.y, 50, base + 150)
    love.graphics.print("spawn y:" .. playerSpawn.y, 50, base + 200)
    love.graphics.print("nivel: " .. nivel, 50, base + 300)
    love.graphics.print("state: " .. state, 50, base + 350)
    
    -- love.graphics.print("state: " .. (player.stateSides ), 50, base + 300)
    -- love.graphics.print("state: " .. (player.stateGround ), 50, base + 350)

    -- love.graphics.print("isAttacking: " .. (player:isAttacking() and 'true' or 'false'), 50, base)
    -- love.graphics.print("isHitted: " .. (skeletons[1].isHitted and 'true' or 'false'), 50, base + 50)
    -- love.graphics.print("hitRepeat: " .. (player.hitRepeat and 'true' or 'false'), 50, base + 100)
    -- love.graphics.print("height:  " .. windowHeight, 50, 300)
    -- love.graphics.print("dim:    " .. screenDimensions.y, 50, 350)
    --love.graphics.print("jumpRepeat:" .. (player.jumpRepeat  and 'true' or 'false'), 50, base + 300)
    -- love.graphics.print("dtPunch:" .. player.dtPunch, 50, base + 400)
    -- love.graphics.print("currentCol:" .. player.image.currentCol, 50, base + 500)

    push:finish()
end

function loseLife()
    player.lifes = player.lifes - 1
    if player.lifes == 0 then
        state = 'gameOver'
    end
end

function resetMenu()
    state = 'menu'
    menu:reset()
end

function spawnPlayer(player, i)
    player.position.x = playerSpawn.x
    player.position.y = playerSpawn.y
    player.vel.y = 0
    player.vel.x = 0
end

function spawnArcher(spawn)
    return Archer(spawn.x, spawn.y, spawn.direction, 'assets/image/npcs/'..spawn.type..'.png')
end

function spawnSkeleton(spawn)
    return Skeleton(spawn.x, spawn.y, spawn.direction, 'assets/image/enemies/skeleton/skeleton.png', spawn.range, spawn.stop)
end

function renderMap(map)
    local tiles, backtiles = {}, {}
    for i,layer in pairs(map.layers) do
        for j, number in pairs(layer.data) do
            if number ~= 0 then
                if layer.id == 1 then
                    table.insert(tiles, Tile(((j-1) % layer.width)*map.tilewidth, math.floor((j-1)/layer.width)*map.tileheight, number))
                else
                    table.insert(backtiles, Tile(((j-1) % layer.width)*map.tilewidth, math.floor((j-1)/layer.width)*map.tileheight, number))
                end
            end
        end
    end
    return tiles, backtiles
end

function loadMap(number)
    -- Reading map files
    -- map = jsonToMap('assets/maps/winter2.json')
    map = require('assets/maps/Map'..number)
    tiles, backtiles = renderMap(map)
    tilemap = TileMap(tiles, 'assets/maps/Tileset.png')
    backTilemap = TileMap(backtiles, 'assets/maps/Tileset.png', 'backTiles')
end

function closeGame()
    love.event.quit()
end