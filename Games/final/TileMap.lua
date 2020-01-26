TileMap = class('TileMap')

function TileMap:initialize(tiles, imgPath)
    self.tiles = tiles
    self.tileset = love.graphics.newImage(imgPath)
    self.tileSize = 64
    self.width, self.height = self.tileset:getDimensions()
    self.quad = love.graphics.newQuad(0, 0, 0, 0, 0, 0)
end

function TileMap:update()
    
end

function TileMap:draw()
    for i, tile in pairs(tiles) do
        self.quad:setViewport((tile.tileNumber - 1) * self.tileSize % self.width , math.floor((tile.tileNumber - 1) / (self.width / self.tileSize)) * self.tileSize , self.tileSize, self.tileSize, self.width, self.height)
        love.graphics.draw(self.tileset, self.quad, tile.x, tile.y, 0)
    end
end
