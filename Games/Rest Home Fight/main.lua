function love.load ()
    Object = require('classic')

    require('Game')
    require('HitBox')
    require('Util')
    require('Input')
    require('MenuScreen')
    require('Player')
    require('Enemie')

    game = Game()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end