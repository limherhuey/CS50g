--[[
    This is CS50 2019.
    Games Track
    Pong

    -- Paddle Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]


Paddle = Class{}

--:init() function describes how to create new instances of this class
--colon indicates this function will run on each individual object when they are created
function Paddle:init(x, y, width, height)
    --self is the object's reference to itself
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
end

function Paddle:update(dt)
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    elseif self.dy > 0 then
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end