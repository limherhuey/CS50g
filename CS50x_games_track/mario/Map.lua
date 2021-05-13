require 'Util'

Map = Class{}

--the different types of tiles from spritesheet
TILE_BRICK = 1
TILE_EMPTY = 4

CLOUD_LEFT = 6
CLOUD_RIGHT = 7

BUSH_LEFT = 2
BUSH_RIGHT = 3

MUSHROOM_TOP = 10
MUSHROOM_BOTTOM = 11

JUMP_BLOCK = 5
JUMP_BLOCK_HIT = 9

FLAGPOLE_TOP = 8
FLAGPOLE_MID = 12
FLAGPOLE_BOTTOM = 16

local SCROLL_SPEED = 62

function Map:init(width)

    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = width
    self.mapHeight = 28
    self.tiles = {}

    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
    --sprites used synonymously with quads
    self.tileSprites = generateQuads(self.spritesheet, self.tileWidth, self.tileHeight)
    self.music = love.audio.newSource('sounds/music.wav', 'static')

    --associate player and flag with map
    self.player = Player(self)
    self.flag = Flag(self)

    --camera offsets
    self.camX = 0
    self.camY = 0

    --width and height of map in pixels
    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    --fill map with empty tiles
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    --begin generating terrain using vertical scan lines
    local x = 1
    --leave the last 10 vertical scan lines empty
    while x < self.mapWidth - 9 do
        --away from extreme right of screen
        if x < self.mapWidth - 2 then
            --5% chance of generating a cloud
            if math.random(20) == 1 then
                --choose a random vertical spot above where blocks/pipes generate
                local cloudStart = math.random(self.mapHeight / 2 - 6)

                self:setTile(x, cloudStart, CLOUD_LEFT)
                self:setTile(x + 1, cloudStart, CLOUD_RIGHT)
            end
        end

        --chance of generating a mushroom
        if math.random(15) == 1 then
            self:setTile(x, self.mapHeight / 2 - 2, MUSHROOM_TOP)
            self:setTile(x, self.mapHeight / 2 - 1, MUSHROOM_BOTTOM)

            --build the bricks below the mushroom
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end

            --next vertical scan line
            x = x + 1
        
        --or chance to generate a bush, away from far right
        elseif math.random(8) == 1 and x < self.mapWidth - 3 then
            local bushLevel = self.mapHeight / 2 - 1

            self:setTile(x, bushLevel, BUSH_LEFT)
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            x = x + 1

            self:setTile(x, bushLevel, BUSH_RIGHT)
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end
            x = x + 1

        --or chance to generate only brick tiles
        elseif math.random(10) ~= 1 then
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, TILE_BRICK)
            end

            --chance to create a block for Mario to hit
            if math.random(10) == 1 then
                self:setTile(x, self.mapHeight / 2 - 4, JUMP_BLOCK)
            end

            x = x + 1

        --or create a 2-tile gap
        else
            x = x + 2
        end
    end

    --generate end game: pyramid and flag
    --flat land of bricks in last 10 vertical scan lines
    for x = self.mapWidth - 9, self.mapWidth do
        for y = self.mapHeight / 2, self.mapHeight do
            self:setTile(x, y, TILE_BRICK)
        end
    end

    --flagpole
    self:setTile(self.mapWidth - 2, self.mapHeight / 2 - 4, FLAGPOLE_TOP)
    self:setTile(self.mapWidth - 2, self.mapHeight / 2 - 3, FLAGPOLE_MID)
    self:setTile(self.mapWidth - 2, self.mapHeight / 2 - 2, FLAGPOLE_MID)
    self:setTile(self.mapWidth - 2, self.mapHeight / 2 - 1, FLAGPOLE_BOTTOM)
    
    --4-layer brick pyramid
    for x = self.mapWidth - 8, self.mapWidth - 5 do
        for y = 1, x - self.mapWidth + 9 do
            self:setTile(x, self.mapHeight / 2 - y, TILE_BRICK)
        end
    end

    
    --start background music
    self.music:setLooping(true)
    self.music:setVolume(0.25)
    self.music:play()
end

function Map:collides(tile)
    local collidables = {
        TILE_BRICK, JUMP_BLOCK, JUMP_BLOCK_HIT, MUSHROOM_TOP, MUSHROOM_BOTTOM
    }

    -- iterate and return true if our tile type matches collidable tiles
    --for every key-value pair in ipairs (iterate pairs)
    for _, v in ipairs(collidables) do
        if tile.id == v then
            return true
        end
    end

    return false
end

function Map:touchFlag(position)
    local flagpole = {
        FLAGPOLE_TOP, FLAGPOLE_MID, FLAGPOLE_BOTTOM
    }
    for _, v in ipairs(flagpole) do
        if position.id == v then
            return true
        end
    end

    return false
end

function Map:update(dt)
    --clamping the map to not go beyond the left edge
    self.camX = math.max(0,
        --keep player in the middle of the screen
        math.min(self.player.x - VIRTUAL_WIDTH / 2,
            --not go beyond the right edge
            math.min(self.mapWidthPixels - VIRTUAL_WIDTH, self.player.x)))
    
    self.player:update(dt)
    self.flag:update(dt)
end

--given coordinate of pixels, return the tile type at that tile position and its tile coordinates
function Map:tileAt(x, y)
    return {
        x = math.floor(x / self.tileWidth) + 1,
        y = math.floor(y / self.tileHeight) + 1,
        id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }
end

--given coordinate of tiles, return tile type at that tile position
function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

--assign a type of tile (integer value) to a tile at coordinate of tiles
function Map:setTile(x, y, tile)
    self.tiles[(y - 1) * self.mapWidth + x] = tile
end

--renders map to the screen, to be called by main's render
function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            love.graphics.draw(self.spritesheet, self.tileSprites[self:getTile(x, y)], 
                (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
        end
    end

    self.player:render()
    self.flag:render()
end
