Pipe = Class{}

--only need to load image once, so define it externally
local PIPE_IMAGE = love.graphics.newImage('images/pipe.png')

function Pipe:init(orientation, y)
    self.x = VIRTUAL_WIDTH + 64
    self.y = y

    self.width = PIPE_WIDTH
    self.height = PIPE_HEIGHT
    
    self.orientation = orientation
end

function Pipe:update(dt)

end

function Pipe:render()
    love.graphics.draw(PIPE_IMAGE, self.x,
        --shift pipe down by its height if top pipe (flipped from bottom)
        (self.orientation == 'top' and self.y + PIPE_HEIGHT or self.y),
        0,   --rotation
        1,   --x scale
        self.orientation == 'top' and -1 or 1)  --y scale

end