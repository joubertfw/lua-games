function love.load ()
    Object = require('classic')

    require('Game')
    require('Player')
    require('Enemie')
    require('HitBox')
    require('MenuScreen')
    require('Util')

    game = Game()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end