Game = Object:extend()

function Game:new()
    love.window.setMode(816, 624)
    love.window.setTitle('Guerra de espada 2019')
    screenHeight = love.graphics.getHeight()
    screenWidth = love.graphics.getWidth()
    love.graphics.setNewFont("assets/fonts/vcr.ttf", 20)
    menuTrack = love.audio.newSource("assets/audio/menu.mp3", "stream")
    ingameTrack = love.audio.newSource("assets/audio/ingame.mp3", "stream")
    background = love.graphics.newImage("assets/image/background.png")
    menu = Menu(screenWidth/2 - 20, 200, {'Start Game 1P','Start Game 2P', 'Exit'}, "assets/image/")
    players = {
        player = Player(screenWidth/2, screenHeight/2, 'assets/image/playerRed'),
    }
    player2 = Player(screenWidth/2 - 100, screenHeight/2, 'assets/image/playerBlue', "a", "d", "w", "s", "space")
    score = 0
    enemies = {}
    dtEnemies = 2
    state = 0
    util = Util()
end

function Game:update(dt)
    if menu:getState() == 1 then
        for i, player in pairs(players) do 
            player:update(dt)
        end

        for i, enemie in pairs(enemies) do 
            enemie:update(dt)
            if enemie.state == 'gettingAway' and util:mustBeRemoved(enemie) then
                table.remove(enemies, i)
            end
        end
        for i, player in pairs(players) do
            for j, enemie in pairs(enemies) do
                for k, shoot in pairs(player.gun.fireworks) do
                    if enemie.hitbox:checkColision(shoot.hitbox) then
                        table.remove(enemies, j)
                        table.remove(player.gun.fireworks, k)
                        score = score + 1
                    end
                end
                for k, shoot in pairs(enemie.gun.fireworks) do
                    if player.hitbox:checkColision(shoot.hitbox) then
                        player.life = player.life - 1
                        table.remove(enemie.gun.fireworks, k)
                        if player.life <= 0 then
                            menu:setState(2)
                        end
                    end
                end
            end
        end
        generateEnemies(dt)
    elseif menu:getState() == 0 and love.keyboard.isDown("return") then
        if menu:getSelected() == 2 then
            love.event.quit()
        elseif menu:getSelected() == 1 then
            table.insert(players, player2)
            menu:setState(1)
            menuTrack:stop()
            ingameTrack:play()
        else
            menu:setState(1)
            menuTrack:stop()
            ingameTrack:play()
        end
    elseif menu:getState() == 0 then 
        menu:update(dt)
        menuTrack:play()
    elseif menu:getState() == 2 and love.keyboard.isDown("return") then
        ingameTrack:stop()
        self = Game()
    end
end

function Game:draw()
    love.graphics.draw(background)
    if menu:getState() == 1 then
        for i, player in pairs(players) do 
            player:draw()
        end
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle('fill', 0, 0, 200, 40)
        love.graphics.setColor(255,255,255)
        love.graphics.print('Score:' .. score, 0, 0, 0, 2, 2)
        love.graphics.print('Enemies:' .. #enemies, 0, 40, 0, 2, 2)
        for i, enemie in pairs(enemies) do
            enemie:draw(dt)
        end
    elseif menu:getState() == 0 then
        menu:draw(dt)
    elseif menu:getState() == 2 then
        love.graphics.print("Você se lenhou. Aperte Enter pra voltar pro menu.", 100, 550)
    end
end

function createEnemie()
    local color = love.math.random(0,1)
    if color == 0 then
        color = 'Yellow'
    else
        color = 'Green'
    end
    local enemie = Enemie(0, 0, 'assets/image/player'..color, love.math.random(screenWidth*2/3, screenWidth))
    enemie.y = love.math.random(love.graphics.getHeight()/6, screenHeight - enemie.height)
    --enemie.y = screenHeight/2
    enemie.x = love.math.random(0,1)*(screenWidth + enemie.width)
    if enemie.x == 0 then
        enemie.x = -enemie.width
        enemie.direction = 1
        enemie.shootPosition = screenWidth - enemie.shootPosition
    end
    return enemie
end

function generateEnemies(dt)
    dtEnemies = dtEnemies - dt
    if dtEnemies <= 0 and #enemies <=3 then
        table.insert(enemies, createEnemie())
        dtEnemies = 1
    end
end