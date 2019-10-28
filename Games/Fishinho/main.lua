function love.load ()
    Object = require('classic')

    require('Game')
    require('Turtle')
    require('Enemie')

    game = Game()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end