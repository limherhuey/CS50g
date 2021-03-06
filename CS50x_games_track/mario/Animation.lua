--[[
    Holds a collection of frames that switch depending on how much time has
    passed.
]]

Animation = Class{}

function Animation:init(params)
    self.texture = params.texture
    
    --table of quads defining this animation
    self.frames = params.frames

    --time in seconds each frame takes (0.05 by default)
    self.interval = params.interval or 0.05

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

        --# is number of elements in the table
        -- +1 to #self.frames so don't skip over last frame when it gets there
        self.currentFrame = (self.currentFrame + 1) % (#self.frames + 1)

        --after the last frame, the above equation will == 0 due to modulo, then loop back to first frame
        if self.currentFrame == 0 then self.currentFrame = 1 end
    end       
end