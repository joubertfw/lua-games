Tile = class('Tile')

function Tile:initialize(x, y, tileNumber)
    self.x = x
    self.y = y
    self.tileNumber = tileNumber
    self.width = 64
    self.height = 64
end

function Tile:checkObjOnTop(obj, innerRange, deadzone)
    innerRange = innerRange and innerRange or 0
    deadzone = deadzone and deadzone or 0
    local x1, y1, w1, h1, x2, y2, w2, h2 = self.x, self.y, self.width, self.height, obj.x, obj.y, obj.width, obj.height
    return not self.isSolid and 
        x2 + deadzone < x1 + w1 and 
        x2 + w2 - deadzone > x1 and
        y1 <= (y2 + h2) + innerRange and
        y1 > (y2 + h2) - innerRange
end

function Tile:checkObjBelow(obj, innerRange, deadzone)
    innerRange = innerRange and innerRange or 0
    deadzone = deadzone and deadzone or 0
    local x1, y1, w1, h1, x2, y2, w2, h2 = self.x, self.y, self.width, self.height, obj.x, obj.y, obj.width, obj.height
    return self.isSolid and 
        x2 + deadzone < x1 + w1 and
        x2 + w2 - deadzone> x1 and
        y2 > y1 and
        y2 > y1 + h1 + innerRange and
        y2 < y1 + h1
end

function Tile:checkObjOnLeftSide(obj, innerRange, deadzone)
    innerRange = innerRange and innerRange or 10
    deadzone = deadzone and deadzone or 0
    local x1, y1, w1, h1, x2, y2, w2, h2 = self.x, self.y, self.width, self.height, obj.x, obj.y, obj.width, obj.height
    return self.isSolid and y2 + deadzone < y1 + h1 and y2 + h2 - deadzone > y1 and
        x2 + w2 > x1 and x2 + w2 < x1 + innerRange
end

function Tile:checkObjOnRightSide(obj, innerRange, deadzone)
    innerRange = innerRange and innerRange or 10
    deadzone = deadzone and deadzone or 0
    local x1, y1, w1, h1, x2, y2, w2, h2 = self.x, self.y, self.width, self.height, obj.x, obj.y, obj.width, obj.height
    return self.isSolid  and y2 + deadzone < y1 + h1 and y2 + h2 - deadzone > y1 and
        x2 < x1 + w1 and x2 > x1 + w1 - innerRange
end