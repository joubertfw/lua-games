Util = Object:extend()
local binser = require "binser"
local TSerial = require "TSerial"

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

function Util:saveTable(filename, table)
    --print(love.filesystem.getSaveDirectory())
    local function drop(data)
        return "Data couldn't be serialized" 
    end
    local string = TSerial.pack(table, drop, true)
    -- love.filesystem reads/writes to application data's folder
    love.filesystem.write(filename, string)
end

function Util:loadTable(filepath)
    -- binser reads/writes to game folder
    return binser.readFile(filepath)
end