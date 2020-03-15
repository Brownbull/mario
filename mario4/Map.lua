require 'Util'
require 'Player'

Map = Class{}

-- Tiles from png image grid
TILE_BRICK = 1
TILE_EMPTY = 4

CLOUD_LEFT = 6
CLOUD_RIGHT = 7

BUSH_LEFT = 2
BUSH_RIGHT = 3

MUSHROOM_TOP = 10
MUSHROOM_BOTTOM = 11

JUMP_BLOCK = 5

local SCROLL_SPEED = 62

function Map:init()
  self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
  self.tileWidth = 16
  self.tileHeight = 16
  self.mapWidth = 30
  self.mapHeight = 28
  self.tiles = {}

  -- Player
  self.player = Player(self)

  -- Camera offsets
  self.camX = 0
  self.camY = 0

  -- Generate quads matrix for tiles
  self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)
  
  -- Escenario dimensions on pixels
  self.mapWidthPixels = self.mapWidth * self.tileWidth
  self.mapHeightPixels = self.mapHeight * self.tileHeight

  -- Filling map with empty tiles
  for y = 1, self.mapHeight do
    for x = 1, self.mapWidth do
      self:setTile(x, y, TILE_EMPTY)
    end
  end

  -- begin generating terraing using vertical scan lines
  local x = 1
  while x < self.mapWidth do
    -- 2% chance of cloud
    if x < self.mapWidth - 2 then
      if math.random(20) == 1 then
        -- choose a random vertical spot above where block/pipes generate
        local cloudStart = math.random(self.mapHeight / 2 - 6)
        self:setTile(x, cloudStart, CLOUD_LEFT)
        self:setTile(x + 1, cloudStart, CLOUD_RIGHT)
      end
    end
    
    -- 5% change to generate a mushroom
    if math.random(20) == 1 then
      self:setTile(x, self.mapHeight / 2 - 2, MUSHROOM_TOP)
      self:setTile(x, self.mapHeight / 2 - 1, MUSHROOM_BOTTOM)

      for y = self.mapHeight / 2, self.mapHeight do
        self:setTile(x, y, TILE_BRICK)
      end
      -- next vertical scan line
      x = x + 1

    -- 10% chance generate bush
    elseif math.random(10) == 1 and x < self.mapWidth - 3 then
      local bushLevel = self.mapHeight / 2 - 1

      -- place bush component and the column of bricks
      self:setTile(x, bushLevel, BUSH_LEFT)
      for y = self.mapHeight / 2, self.mapHeight do
        self:setTile(x, y, TILE_BRICK)
      end
      x = x + 1

      self:setTile(x, bushLevel, BUSH_RIGHT)
      for y = self.mapHeight / 2, self.mapHeight do
        self:setTile(x, y, TILE_BRICK)
      end
      x = x + 1

    -- 10% chance not generate anything
    elseif math.random(10) ~= 1 then

      -- creates column of tiles going to bottom of map
      for y = self.mapHeight / 2, self.mapHeight do
        self:setTile(x, y, TILE_BRICK)
      end

      if math.random(15) == 1 then
        self:setTile(x, self.mapHeight / 2 - 4, JUMP_BLOCK)
      end
      -- next vertical scan line
      x = x + 1
    else
      -- increment X so we skip two scanlines, for gaps
      x = x + 2
    end
  end -- eof while

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

  self.player:update(dt)
end -- eof function Map:update()

-- Put stuff in place on 1 dimensional map array, which is the escenario
function Map:setTile(x, y, tile)
  self.tiles[(y - 1) * self.mapWidth + x] = tile
end

-- Get  stuff in place on 1 dimensional map array, which is the escenario
function Map:getTile(x, y)
  return self.tiles[(y - 1) * self.mapWidth + x]
end

function Map:render()
  -- Level render
  for y = 1, self.mapHeight do
    for x = 1, self.mapWidth do
      local tile = self:getTile(x, y)
      if tile ~= TILE_EMPTY then
        love.graphics.draw(
          self.spritesheet,                     -- were to draw
          self.tileSprites[self:getTile(x, y)], -- what to draw
          (x - 1) * self.tileWidth,             -- x position
          (y - 1) * self.tileHeight)            -- y position 
      end
    end
  end -- eof -- Level render

  -- Player render
  self.player:render()

end -- eof function Map:render()