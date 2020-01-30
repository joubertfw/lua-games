function love.load ()
    class = require('lib.middleclass')
    Camera = require 'lib.Camera'
    require('Game')
    require('CollisionBox')
    require('Util')
    require('MenuScreen')
    require('Input')
    require('Image')
    require('Player')
    require('Enemie')
    require('Skeleton')
    require('Archer')
    require('TileMap')
    require('Tile')
    require('Item')
    push = require('Push')
    game = Game()
end

function love.conf(t)
	t.console = true
end

function love.keypressed(key, u)
    --Debug
    if key == "rctrl" then --set to whatever key you want to use
       debug.debug()
    end
 end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end