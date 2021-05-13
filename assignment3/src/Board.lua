--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class{}

function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.matches = {}
    
    -- determines the highest possible tile pattern according to level
    self.maxVariety = math.min(6, tonumber(level) / 2)

    -- 8 colours of tiles to choose from (from the 18 possible colours)
    self.someColours = {
        [1] = 1,
        [2] = 2,
        [3] = 7,
        [4] = 8,
        [5] = 11,
        [6] = 12,
        [7] = 15,
        [8] = 16
    }

    self:initializeTiles()
end

function Board:initializeTiles()
    self.tiles = {}

    for tileY = 1, 8 do
        
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            -- create a new tile at X,Y with a random color and variety (higher levels have more variety)
            table.insert(self.tiles[tileY], Tile(tileX, tileY, self.someColours[math.random(8)], math.random(self.maxVariety)))
        end
    end

    while self:calculateMatches() do
        
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles()
    end
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    local shiny = false

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color

        -- check for shiny tiles
        if self.tiles[y][1].shiny then
            shiny = true
        end

        matchNum = 1
        
        -- every horizontal tile
        for x = 2, 8 do
            
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
                
                -- check for shiny tiles
                if self.tiles[y][x].shiny then
                    shiny = true
                end
            else
                
                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    local match = {}

                    if shiny then
                        -- remember whole row for clearing if at least 1 matched tile is shiny
                        for x2 = 1, 8 do
                            table.insert(match, self.tiles[y][x2])                            
                        end
                        -- stop checking rest of row afterwards
                        x = 8
                    else
                        -- go backwards from here by matchNum
                        for x2 = x - 1, x - matchNum, -1 do                            
                            -- add each tile to the match that's in that match
                            table.insert(match, self.tiles[y][x2])
                        end
                    end

                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color

                if self.tiles[y][x].shiny then
                    shiny = true
                else
                    shiny = false
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    shiny = false
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}

            if shiny then
                -- remember whole row for clearing if at least 1 matched tile is shiny
                for x = 1, 8 do
                    table.insert(match, self.tiles[y][x])                            
                end
            else
                -- go backwards from end of last row by matchNum
                for x = 8, 8 - matchNum + 1, -1 do
                    table.insert(match, self.tiles[y][x])
                end
            end

            shiny = false

            table.insert(matches, match)
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color

        if self.tiles[1][x].shiny then
            shiny = true
        end

        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1

                if self.tiles[y][x].shiny then
                    shiny = true
                end
            else

                if matchNum >= 3 then
                    local match = {}

                    if shiny then
                        for y2 = 1, 8 do
                            table.insert(match, self.tiles[y2][x])                            
                        end
                        y = 8
                    else
                        for y2 = y - 1, y - matchNum, -1 do
                            table.insert(match, self.tiles[y2][x])
                        end
                    end

                    table.insert(matches, match)
                end
                
                colorToMatch = self.tiles[y][x].color

                if self.tiles[y][x].shiny then
                    shiny = true
                else
                    shiny = false
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    shiny = false
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}
            
            if shiny then
                for y = 1, 8 do
                    table.insert(match, self.tiles[y][x])                            
                end
            else
                -- go backwards from end of last row by matchNum
                for y = 8, 8 - matchNum + 1, -1 do
                    table.insert(match, self.tiles[y][x])
                end
            end

            shiny = false

            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            
            -- if our last tile was a space...
            local tile = self.tiles[y][x]
            
            if space then
                
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- now this position becomes a space
                    space = true
                    spaceY = y
                end
            elseif tile == nil then
                space = true
                
                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then

                -- new tile with random color and variety
                local tile = Tile(x, y, self.someColours[math.random(8)], math.random(self.maxVariety))
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

-- to check if there are possible matches in the board
function Board:possibleMatches()
    for y = 1, 8 do
        for x = 1, 8 do
            tile1 = self.tiles[y][x]
            -- check left swap // swap tiles, check for matches, then swap back
            if not (x == 1) then
                tile2 = self.tiles[y][x - 1]
                self:swapTiles(tile1, tile2)

                if self:calculateMatches() then
                    self:swapTiles(tile1, tile2)
                    return true
                end
                self:swapTiles(tile1, tile2)
            end

            -- check right swap
            if not (x == 8) then
                tile2 = self.tiles[y][x + 1]
                self:swapTiles(tile1, tile2)

                if self:calculateMatches() then
                    self:swapTiles(tile1, tile2)
                    return true
                end
                self:swapTiles(tile1, tile2)
            end

            -- check up swap
            if not (y == 1) then
                tile2 = self.tiles[y - 1][x]
                self:swapTiles(tile1, tile2)

                if self:calculateMatches() then
                    self:swapTiles(tile1, tile2)
                    return true
                end
                self:swapTiles(tile1, tile2)
            end

            -- check down swap
            if not (y == 8) then
                tile2 = self.tiles[y + 1][x]
                self:swapTiles(tile1, tile2)


                if self:calculateMatches() then
                    self:swapTiles(tile1, tile2)
                    return true
                end
                self:swapTiles(tile1, tile2)
            end
        end
    end

    -- if no possible matches in map
    return false
end

-- function to swap tiles
function Board:swapTiles(tile1, tile2)
    local tempX = tile1.gridX
    local tempY = tile1.gridY    

    -- swap grid positions of tiles
    tile1.gridX = tile2.gridX
    tile1.gridY = tile2.gridY
    tile2.gridX = tempX
    tile2.gridY = tempY

    -- swap tiles in the tiles table
    self.tiles[tile1.gridY][tile1.gridX] = tile1
    self.tiles[tile2.gridY][tile2.gridX] = tile2
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end