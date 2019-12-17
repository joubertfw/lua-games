Game = class('Game')

--These values are global for every instance
--When overritten, all instances are affected
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
    map = jsonToMap('/assets/maps/winter.json')
    tiles = renderMap(map,  '/assets/maps/tilemap.png')

    --Player creation
    spawnArea = {{x = screenDimensions.x/2, y = screenDimensions.y*1.3}}
    playerConfig = {quadWidth = 300, quadHeight = 300, animVel = 7, 
                cols = 9, rows = 11, idleCols = 5, moveCols = 8, punchCols = 5}
    player = Player(0, 0, 'assets/image/player/santa.png', {left = 'a', right = 'd', up = 'w', down = 's'},  playerConfig)
    spawnPlayer(player, 1)

    --Enemies creation
    enemies = {}
    enemieSpawns = {{x = screenDimensions.x*0.8, y = screenDimensions.y*1.34, range = 12, color = 'red', direction = -1},
                    {x = screenDimensions.x*0.45, y = screenDimensions.y*0.98, range = 4.5, color = 'blue', direction = 1}}
    enemieConfig = {quadWidth = 100, quadHeight = 100, animVel = 6, cols = 4, rows = 3}
    for i, spawn in pairs(enemieSpawns) do
        table.insert(enemies, spawnEnemie(spawn, enemieConfig))
    end

    --Items creation
    items = {
        Item(screenDimensions.x, screenDimensions.y/2, 'assets/image/misc/cacetinho.png')
    }

    score = 0
    fps = 0
end

function Game:update(dt)
    fps = 1/dt
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
        player:update(dt)
        for i, item in pairs(items) do
            item:update()
            if item:checkCollision(player.hitbox) then
                score = score + 1
                table.remove(items, i)
                --gotCacetinhoFX()
            end
        end
        for i, enemie in pairs(enemies) do
            enemie:update(dt)
        end
        local freeFall = true --not in collision
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
    love.graphics.draw(backgroundImg, 0, 0)
    
    if state == 'menu' then
        menu:draw()
    elseif state == 'ingame' then
        camera:attach()
        -- love.graphics.draw(backgroundImg, 0, 0)

        for i, tile in pairs(tiles) do 
            tile:draw()
        end
        for i, enemie in pairs(enemies) do
            enemie:draw()
        end

        -- DEBUG TILES
        -- love.graphics.setColor( 0, 0, 0, 1 )
        -- for i,layer in pairs(map.layers) do
        --     for j, number in pairs(layer.data) do
        --             -- table.insert(tiles, Tile(((j-1) % layer.width)*map.tilewidth, math.floor((j-1)/layer.width)*map.tileheight, true, '/assets/maps/tilemap.png', getTile(number, map.tilewidth, map.tileheight)))
        --         love.graphics.print(number.. ' ' .. math.floor(number/5) ..' ' .. (((number-1)%5)), ((j-1) % layer.width)*map.tilewidth, math.floor((j-1)/layer.width)*map.tileheight)
        --     end
        -- end
        -- love.graphics.setColor( 1, 1, 1, 0 )

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
    love.graphics.print("fps: " .. fps, 50, base + 500)

end

function spawnPlayer(player, i)
    player.position.x = spawnArea[i].x
    player.position.y = spawnArea[i].y
end

function spawnEnemie(spawn, imgConfig)
    return Enemie(spawn.x, spawn.y, spawn.direction, 'assets/image/enemie/'..spawn.color..'.png', spawn.range, imgConfig)
end

function resetGame()
    --Reset things to default values
    menu:reset()
end

function getTile(number, tilewidth, tileheight)
    return {quadWidth = tilewidth, quadHeight = tileheight, animVel = 1, cols = 5, rows = 4, idleCols = 0, moveCols = 0, currentCol =(number-1)%5, row = math.floor((number-1)/5)*128}
end

function jsonToMap(file)
    local f = io.open(arg[1] ..file, "rb")
    local lines = {}
    lines = f:read("*a")

    return json.decode(lines);
end

function renderMap(map, tilemap)
    local solidBlocks = {[5] = true, [8] = true, [10] = true, [17] = true, [18] = true}
    local tiles = {}
    for i,layer in pairs(map.layers) do
        for j, number in pairs(layer.data) do
            if number ~= 0 then
                table.insert(tiles, Tile(((j-1) % layer.width)*map.tilewidth, math.floor((j-1)/layer.width)*map.tileheight, not (solidBlocks[number]), tilemap, getTile(number, map.tilewidth, map.tileheight)))
            end
        end
    end
    return tiles
end
