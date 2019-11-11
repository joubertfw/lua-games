Util = Object:extend()

function Util:new()

end

function Util:mustBeRemoved(obj, offset)
    offset = offset or 0
    return obj.x > love.graphics.getWidth() + offset or
     obj.x + obj.width + offset < 0 or
     obj.y > love.graphics.getHeight() + offset or
     obj.y + obj.height + offset < 0
end

function Util:playersDirection(player1, player2)
    if player1.x >= player2.x + (player2.direction * player2.width/2) then
        player1:rotateLeft()
        player2:rotateRight()
        player1.screenPosition = 1
        player2.screenPosition = -1
    else
        player1:rotateRight()
        player2:rotateLeft()
        player1.screenPosition = -1
        player2.screenPosition = 1
    end
end