WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243 

Class = require 'class'
push = require 'push'

require 'Util'
require 'Map'

function love.load()
  -- Randomize level
  math.randomseed(os.time())
  -- Create level
  map = Map()
  -- Screen setup
  love.graphics.setDefaultFilter('nearest', 'nearest')
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    resizable = false,
    vsync = true
  })

  love.keyboard.keysPressed = {}

end -- eof function love.load()

function love.resize(w, h)
  push:resize(w, h)
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end

  love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
  return love.keyboard.keysPressed[key]
end

function love.update(dt)
  map:update(dt)

  love.keyboard.keysPressed = {}
end

function love.draw()
  push:apply('start')

  -- camera
  love.graphics.translate(math.floor(-map.camX), math.floor(-map.camY))

  -- background
  love.graphics.clear(108/255, 140/255, 255/255, 255/255)
  map:render()
  
  push:apply('end')
end