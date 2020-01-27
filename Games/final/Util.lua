Util = class('Util')
local binser = require "lib.binser"
local TSerial = require "lib.TSerial"

function Util:initialize()
    self.font = love.graphics.newFont('assets/fonts/vcr.ttf', 30)
    self.smallerFont = love.graphics.newFont('assets/fonts/vcr.ttf', 25)
end

function Util:areVerticallyAligned(obj1, obj2)
    return obj1.y < obj2.y + obj2.height and obj1.y + obj1.height > obj2.y
end

function Util:areHorizontallyAligned(obj1, obj2)
    return obj1.x < obj2.x + obj2.width and obj1.x + self.width > obj2.x
end

function Util:distanceBetween(x1, y1, x2, y2)
    local dx = x1-x2
    local dy = y1-y2
    return math.sqrt((dx * dx + dy * dy))
end


function Util:isOutOfScreen(obj, side, offset)
    offset = offset or 0
    if side == 'up' then
        return obj.y + obj.height + offset < 0
    elseif side == 'down' then
        return obj.y > love.graphics.getHeight() + offset
    elseif side == 'left' then
        return obj.x + obj.width + offset < 0
    elseif side == 'right' then
        return obj.x > love.graphics.getWidth() + offset
    else
        print('You must pass a valid side as arg for isOutOfScreen()')
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