function generateQuads(atlas, tilewidth, tileheight)
    --number of tiles in the sheet horizontally and vertically
    local sheetWidth = atlas:getWidth() / tilewidth
    local sheetHeight = atlas:getHeight() / tileheight

    --Lua convention, tables start index at 1, not 0
    --but still 0 index pixel-wise
    local sheetCounter = 1
    --a table in Lua, in this case used like a list in Python
    local quads = {}

    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            quads[sheetCounter] = love.graphics.newQuad(x * tilewidth, y * tileheight, tilewidth, tileheight, atlas:getDimensions())
            sheetCounter = sheetCounter + 1
        end
    end

    return quads
end
