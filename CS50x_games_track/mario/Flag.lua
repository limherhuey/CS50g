Flag = Class{}

function Flag:init(map)
    self.map = map

    --location of flag
    self.x = map.tileWidth * (map.mapWidth - 2)
    self.y = map.tileHeight * (map.mapHeight / 2 - 5)

    --initialise animation
    self.animations = {
        ['flag'] = Animation {
            texture = map.spritesheet,
            frames = {
                map.tileSprites[13], map.tileSprites[14], map.tileSprites[15]
            },
            interval = 0.30
        }
    }

    self.animation = self.animations['flag']
end


function Flag:update(dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
end

function Flag:render()
    love.graphics.draw(map.spritesheet, self.currentFrame, self.x, self.y)
end