PipePair = Class{}

function PipePair:init(y)
    self.x = VIRTUAL_WIDTH + 32
    -- y value is for the top pipe
    self.y = y

    -- randomised gap height from 75-95
    local GAP_HEIGHT = math.random(75, 95)

    self.pipes = {
        ['upper'] = Pipe('top', self.y),
        ['lower'] = Pipe('bottom', self.y + PIPE_HEIGHT + GAP_HEIGHT)
    }

    self.remove = false

    self.scored = false
end

function PipePair:update(dt)
    --if pipe is beyond left edge of screen, remove, else move it from right to left
    if self.x > -PIPE_WIDTH then
        self.x = self.x - PIPE_SPEED * dt
        self.pipes['upper'].x = self.x
        self.pipes['lower'].x = self.x
    else
        self.remove = true
    end
end

function PipePair:render()
    for k, pipe in pairs(self.pipes) do
        pipe:render()
    end
end
