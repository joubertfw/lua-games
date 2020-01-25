function love.load ()
    class = require('lib.middleclass')
    Camera = require 'lib.Camera'
    json = require("Json")

    require('Game')
    require('CollisionBox')
    require('Util')
    require('MenuScreen')
    require('Input')
    require('Image')
    require('Player')
    require('Enemie')
    require('Tile')
    require('Item')

    game = Game()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end