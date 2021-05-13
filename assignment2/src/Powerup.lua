Powerup = Class{}

function Powerup:init(skin)
    self.side = 16

    self.x = math.random(0, VIRTUAL_WIDTH - self.side)
    self.y = 96

    self.dy = 50

    self.skin = skin

    self.inPlay = true
end

function Powerup:collides(paddle)
    if self.x < paddle.x + paddle.width and self.x + self.side > paddle.x then
        if self.y < paddle.y + paddle.height and self.y + self.side > paddle.y then
            self.inPlay = false
            return true
        end
    end

    return false
end

function Powerup:update(dt)
    self.y = self.y + self.dy * dt
end

function Powerup:render()
    if self.inPlay then
        love.graphics.draw(gTextures['main'], gFrames['powerups'][self.skin],
            self.x, self.y)
    end
end
