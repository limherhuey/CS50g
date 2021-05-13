--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def, x, y)
    -- string identifying this object type
    self.type = def.type

    self.texture = def.texture
    self.frame = def.frame or 1

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    -- whether it acts as an obstacle or not
    self.solid = def.solid

    -- whether it will follow player position // after being thrown by player (for pots)
    self.trackPlayer = def.trackPlayer or false
    self.projectile = def.projectile or false
    self.dy = def.dy or 0
    self.dx = def.dx or 0
    self.travelledX = 0
    self.travelledY = 0
    self.maxY = def.maxY or MAP_HEIGHT
    self.maxX = def.maxX or MAP_WIDTH
    self.damage = def.damage or 0

    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height

    -- default empty collision callback
    self.onCollide = function() end
    self.onConsume = function() end
end

function GameObject:update(dt)
    if self.projectile then
        -- keep track of distance travelled
        self.travelledX = self.travelledX + math.abs(self.dx * dt)
        self.travelledY = self.travelledY + math.abs(self.dy * dt)

        -- actual travel
        self.x = self.x + self.dx * dt
        self.y = self.y + self.dy * dt
    end
end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
end