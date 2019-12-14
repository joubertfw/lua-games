function love.load ()
    class = require('lib.middleclass')
    Camera = require 'lib.Camera'

    require('Game')
    require('CollisionBox')
    require('Util')
    require('Input')
    require('MenuScreen')
    require('Player')
    require('Image')
    require('Tile')

    game = Game()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end