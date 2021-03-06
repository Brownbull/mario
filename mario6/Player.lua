Player = Class{}

require 'Animation'

local MOVE_SPEED = 80

function Player:init(map)
  self.width = 16
  self.height = 20

  self.x = map.tileWidth * 10
  self.y = map.tileHeight * (map.mapHeight / 2 - 1) - self.height

  self.texture = love.graphics.newImage('graphics/blue_alien.png')
  self.frames = generateQuads(self.texture, 16, 20)

  self.state = 'idle'
  self.direction = 'right'

  self.animations = {
    ['idle'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[1]
      },
      interval = 1
    },
    ['walking'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[9], self.frames[10], self.frames[11]
      },
      interval = 0.15
    }
  } -- eof self.animations = {
  
  self.animation = self.animations['idle']

  self.behaviors = {
    ['idle'] = function(dt)
      if love.keyboard.isDown('a') then
        self.x = self.x + dt * -MOVE_SPEED
        self.animation = self.animations['walking']
        self.direction = 'left'
      elseif love.keyboard.isDown('d') then 
        self.x = self.x + dt * MOVE_SPEED
        self.animation = self.animations['walking']
        self.direction = 'right'
      else
        self.animation = self.animations['idle']
      end
    end, -- eof ['idle'] = function(dt)
    ['walking'] = function(dt)
      if love.keyboard.isDown('a') then
        self.x = self.x + dt * -MOVE_SPEED
        self.animation = self.animations['walking']
        self.direction = 'left'
      elseif love.keyboard.isDown('d') then 
        self.x = self.x + dt * MOVE_SPEED
        self.animation = self.animations['walking']
        self.direction = 'right'
      else
        self.animation = self.animations['idle']
      end
    end -- eof ['walking'] = function(dt)
  } -- eof self.behaviors = {
end -- eof function Player:init(map)

function Player:update(dt)
  self.behaviors[self.state](dt)
  self.animation:update(dt)
end -- eof function Player:update(dt)

function Player:render()
  local scaleX
  if self.direction == 'right' then
    scaleX = 1
  else
    scaleX = -1
  end
  love.graphics.draw(
    self.texture, 
    self.animation:getCurrentFrame(), 
    math.floor(self.x + self.width / 2), 
    math.floor(self.y + self.height / 2),
    0, -- initial rotation
    scaleX, -- flip sprite
    1,
    self.width / 2, -- X origin of sprite
    self.height / 2 -- Y origin of sprite
  )
end