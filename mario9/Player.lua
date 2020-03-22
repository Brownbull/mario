Player = Class{}

local WALKING_SPEED = 140
local JUMP_VELOCITY = 550

function Player:init(map)
  self.x = 0
  self.y = 0
  self.width = 16
  self.height = 20

  -- offset from top left to center to support sprite flipping
  self.xOffset = 8
  self.yOffset = 10

  self.map = map
  self.texture = love.graphics.newImage('graphics/blue_alien.png')

  self.sounds = {
    ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
    ['hit'] = love.audio.newSource('sounds/hit.wav', 'static'),
    ['coin'] = love.audio.newSource('sounds/coin.wav', 'static')
  }
  self.frames = {}
  self.currentFrame = nil
  self.state = 'idle'
  self.direction = 'left'

  -- x and y velocity
  self.dx = 0
  self.dy = 0

  -- position on top of map tiles
  self.y = map.tileHeight * ((map.mapHeight - 2) / 2) - self.height
  self.x = map.tileWidth * 10

  self.animations = {
    ['idle'] = Animation ({
      texture = self.texture,
      frames = {
        love.graphics.newQuad(0, 0, 16, 20, self.texture:getDimensions())
      }
    }),
    ['walking'] = Animation ({
      texture = self.texture,
      frames = {
        love.graphics.newQuad(128, 0, 16, 20, self.texture:getDimensions()),
        love.graphics.newQuad(144, 0, 16, 20, self.texture:getDimensions()),
        love.graphics.newQuad(160, 0, 16, 20, self.texture:getDimensions()),
        love.graphics.newQuad(144, 0, 16, 20, self.texture:getDimensions()),
      },
      interval = 0.15
    }),
    ['jumping'] = Animation ({
      texture = self.texture,
      frames = {
        love.graphics.newQuad(32, 0, 16, 20, self.texture:getDimensions())
      }
    })
  } -- eof self.animations = {
  
  self.animation = self.animations['idle']
  self.currentFrame = self.animation:getCurrentFrame()

  self.behaviors = {
    ['idle'] = function(dt)

      if love.keyboard.wasPressed('space') then 
        self.dy= -JUMP_VELOCITY
        self.state = 'jumping'
        self.animation = self.animations['jumping']
        self.sounds['jump']:play()
      elseif love.keyboard.isDown('a') then
        self.direction = 'left'
        self.dx = -WALKING_SPEED
        self.state = 'walking'
        self.animations['walking']:restart()
        self.animation = self.animations['walking']
      elseif love.keyboard.isDown('d') then 
        self.direction = 'right'
        self.dx = WALKING_SPEED
        self.state = 'walking'
        self.animations['walking']:restart()
        self.animation = self.animations['walking']
      else
        self.dx = 0
      end
    end, -- eof ['idle'] = function(dt)
    ['walking'] = function(dt)
      if love.keyboard.wasPressed('space') then 
        self.dy= -JUMP_VELOCITY
        self.state = 'jumping'
        self.animation = self.animations['jumping']
        self.sounds['jump']:play()
      elseif love.keyboard.isDown('a') then
        self.direction = 'left'
        self.dx = -WALKING_SPEED
      elseif love.keyboard.isDown('d') then 
        self.direction = 'right'
        self.dx = WALKING_SPEED
      else
        self.dx = 0
        self.state = 'idle'
        self.animation = self.animations['idle']
      end

      self:checkRightCollision()
      self:checkLeftCollision()

      if not self.map:collides(self.map:tileAt(self.x, self.y + self.height)) and
        not self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then 

        self.state = 'jumping'
        self.animation = self.animations['jumping']
      end
    end, -- eof ['walking'] = function(dt)
    ['jumping'] = function(dt)
      if self.y > 300 then
        return
      end

      if love.keyboard.isDown('a') then
        self.direction = 'left'
        self.dx = -WALKING_SPEED
      elseif love.keyboard.isDown('d') then
        self.direction = 'right'
        self.dx = WALKING_SPEED
      end

      self.dy = self.dy + self.map.gravity

      if self.map:collides(self.map:tileAt(self.x, self.y + self.height)) or
        self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then

        self.dy = 0
        self.state = 'idle'
        self.animation = self.animations['idle']
        self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileHeight - self.height
      end

      self:checkRightCollision()
      self:checkLeftCollision()
    end -- eof ['jumping'] = function(dt)
  } -- eof self.behaviors = {
end -- eof function Player:init(map)

function Player:update(dt)
  self.behaviors[self.state](dt)
  self.animation:update(dt)
  self.currentFrame = self.animation:getCurrentFrame()
  self.x = self.x + self.dx * dt

  self:calculateJumps()
  -- appluy velocity
  self.y = self.y + self.dy * dt
end

function Player:calculateJumps()
  -- collision
   if self.dy < 0 then
    if self.map:tileAt(self.x, self.y).id ~= TILE_EMPTY or
      self.map:tileAt(self.x + self.width - 1, self.y).id ~= TILE_EMPTY then
      -- reset y velocity
      self.dy = 0

      -- change block to different block
      local playCoin = false
      local playHit = false
      if self.map:tileAt(self.x, self.y).id == JUMP_BLOCK then
        self.map:setTile(math.floor(self.x / self.map.tileWidth) + 1,
          math.floor(self.y / self.map.tileHeight) + 1, JUMP_BLOCK_HIT)
        playCoin = true
      else
          playHit = true
      end
      if self.map:tileAt(self.x + self.width - 1, self.y).id == JUMP_BLOCK then
        self.map:setTile(math.floor((self.x + self.width - 1) / self.map.tileWidth) + 1,
          math.floor(self.y / self.map.tileHeight) + 1, JUMP_BLOCK_HIT)
        playCoin = true
      else
        playHit = true
      end
      if playCoin then
        self.sounds['coin']:play()
      elseif playHit then
        self.sounds['hit']:play()
      end
    end
  end -- eof collistion
end -- eof function Player:update(dt)

function Player:checkLeftCollision()
  if self.dx < 0 then
    if self.map:collides(self.map:tileAt(self.x - 1, self.y)) or
      self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1)) then
      self.dx = 0
      self.x = self.map:tileAt(self.x - 1, self.y).x * self.map.tileWidth 
    end
  end
end -- eof function Player:checkLeftCollision()

function Player:checkRightCollision()
  if self.dx > 0 then
    if self.map:collides(self.map:tileAt(self.x + self.width, self.y)) or
      self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then
      self.dx = 0
      self.x = (self.map:tileAt(self.x + self.width, self.y).x - 1) * self.map.tileWidth - self.width
    end
  end
end -- eof function Player:checkLeftCollision()

function Player:render()
  local scaleX
  if self.direction == 'right' then
    scaleX = 1
  else
    scaleX = -1
  end

  love.graphics.draw(
    self.texture, 
    self.currentFrame, 
    math.floor(self.x + self.xOffset), 
    math.floor(self.y + self.yOffset),
    0, -- initial rotation
    scaleX, -- flip sprite
    1,
    self.xOffset, -- X origin of sprite
    self.yOffset -- Y origin of sprite
  )
end