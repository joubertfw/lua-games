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