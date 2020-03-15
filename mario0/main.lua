WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243 

Class = require 'class'
push = require 'push'

require 'Util'
require 'Map'

function love.load()
  map = Map()

  -- Screen setup
  love.graphics.setDefaultFilter('nearest', 'nearest')
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    resizable = false,
    vsync = true
  })

end

function love.update()

end

function love.draw()
  push:apply('start')

  love.graphics.clear(108/255, 140/255, 255/255, 255/255)
  map:render()
  
  push:apply('end')
end