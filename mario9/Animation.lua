Animation = Class{}

DEFAULT_INTERVAL = 0.05

function Animation:init(params)
  self.texture = params.texture
  self.frames = params.frames or {}
  self.interval = params.interval or DEFAULT_INTERVAL
  self.timer = 0
  self.currentFrame = 1
end

function Animation:getCurrentFrame()
  return self.frames[self.currentFrame]
end

function Animation:restart()
  self.timer = 0
  self.currentFrame = 1
end

function Animation:update(dt)
    self.timer = self.timer + dt

    -- iteratively subtract interval from timer to proceed in the animation,
    -- in case we skipped more than one frame
    while self.timer > self.interval do
        self.timer = self.timer - self.interval
        self.currentFrame = (self.currentFrame + 1) % #self.frames
        if self.currentFrame == 0 then self.currentFrame = 1 end
    end
end -- eof function Animation:update(dt)