--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions (for rendering)
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety

    -- chance for a tile that destroy whole row on match
    self.shiny = math.random(20) == 1 and true or false
end

function Tile:render(x, y)
    -- (x, y) is the board's position
    
    -- draw shadow
        love.graphics.setColor(34/255, 32/255, 52/255, 1)

    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    -- twinkles for shiny tiles to appear shiny
    if self.shiny then
        love.graphics.setColor(255/255, 255/255, 209/255, 209/255)
        love.graphics.circle('fill', self.x + (VIRTUAL_WIDTH - 272) + 8,
            self.y + 16 + 8, 3)
        love.graphics.circle('fill', self.x + (VIRTUAL_WIDTH - 272) + 14,
            self.y + 16 + 9, 1)
        love.graphics.circle('fill', self.x + (VIRTUAL_WIDTH - 272) + 10,
            self.y + 16 + 14, 1)
    end
end