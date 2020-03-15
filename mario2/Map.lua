Map = Class{}

-- Tiles from png image grid
TILE_BRICK = 1
TILE_EMPTY = 4

local SCROLL_SPEED = 62

function Map:init()
  self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
  self.tileWidth = 16
  self.tileHeight = 16
  self.mapWidth = 30
  self.mapHeight = 28
  self.tiles = {}

  -- Camera offsets
  self.camX = 0
  self.camY = 0

  -- Generate quads matrix for tiles
  self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)
  
  -- Escenario dimensions on pixels
  self.mapWidthPixels = self.mapWidth * self.tileWidth
  self.mapHeightPixels = self.mapHeight * self.tileHeight

  -- Filling map with empty tiles
  for y = 1, self.mapHeight / 2 do
    for x = 1, self.mapWidth do
      self:setTile(x, y, TILE_EMPTY)
    end
  end

  -- Starts halfway down the map, populates with bricks
  for y = self.mapHeight / 2, self.mapHeight do
    for x = 1, self.mapWidth do
      self:setTile(x, y, TILE_BRICK)
    end
  end

end -- eof Map:init()

function Map:update(dt)
  if love.keyboard.isDown('w') then
    self.camY = math.max(0, self.camY + dt * -SCROLL_SPEED)
  elseif love.keyboard.isDown('a') then
    self.camX = math.max(0, self.camX + dt * -SCROLL_SPEED)
  elseif love.keyboard.isDown('s') then
    self.camY = math.min(self.mapHeightPixels - VIRTUAL_HEIGHT, self.camY + dt * SCROLL_SPEED)
  elseif love.keyboard.isDown('d') then
    self.camX = math.min(self.mapWidthPixels - VIRTUAL_WIDTH, self.camX + dt * SCROLL_SPEED)
  end
end -- eof function Map:update()

-- Put stuff in place on 1 dimensional map array, which is the escenario
function Map:setTile(x, y, tile)
  self.tiles[(y - 1) * self.mapWidth + x] = tile
end

-- PGet  stuff in place on 1 dimensional map array, which is the escenario
function Map:getTile(x, y)
  return self.tiles[(y - 1) * self.mapWidth + x]
end

function Map:render()
  for y = 1, self.mapHeight do
    for x = 1, self.mapWidth do
      love.graphics.draw(
        self.spritesheet,                     -- were to draw
        self.tileSprites[self:getTile(x, y)], -- what to draw
        (x - 1) * self.tileWidth,             -- x position
        (y - 1) * self.tileHeight)            -- y position 
    end
  end
end -- eof function Map:render()