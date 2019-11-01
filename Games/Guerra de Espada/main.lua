function love.load ()
    Object = require('classic')

    require('Game')
    require('Player')
    require('Enemie')
    require('Gun')
    require('HitBox')
    require('Firework')
    require('Menu')
    require('Util')

    game = Game()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end