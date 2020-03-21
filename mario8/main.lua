
Class = require 'class'
push = require 'push'

require 'Animation'
require 'Map'
require 'Player'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243 

-- Randomize level
math.randomseed(os.time())
-- Create level
map = Map()
-- Screen setup
love.graphics.setDefaultFilter('nearest', 'nearest')

function love.load()
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    resizable = false,
    vsync = true
  })

  love.keyboard.keysPressed = {}
  love.keyboard.keysReleased = {}

end -- eof function love.load()

function love.resize(w, h)
  push:resize(w, h)
end

-- global key pressed function
function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end

-- global key released function
function love.keyboard.wasReleased(key)
    if (love.keyboard.keysReleased[key]) then
        return true
    else
        return false
    end
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end

  love.keyboard.keysPressed[key] = true
end

-- called whenever a key is released
function love.keyreleased(key)
    love.keyboard.keysReleased[key] = true
end

function love.update(dt)
  map:update(dt)

  love.keyboard.keysPressed = {}
  love.keyboard.keysReleased = {}
end

function love.draw()
  push:apply('start')
  -- background
  love.graphics.clear(108/255, 140/255, 255/255, 255/255)

  -- camera
  love.graphics.translate(math.floor(-map.camX + 0.5), math.floor(-map.camY + 0.5))

  map:render()
  
  push:apply('end')
end