--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Player = Class{__includes = Entity}

function Player:init(def)
    Entity.init(self, def)

    -- whether player is currently holding a pot
    self.pot = false
    -- objects linked to player (eg. the pot player is carrying currently)
    self.objects = {}
    -- whether player is lifting a pot currently
    self.liftPot = false
end

function Player:update(dt)
    Entity.update(self, dt)
end

function Player:collides(target)
    local selfY, selfHeight = self.y + self.height / 2, self.height - self.height / 2
    
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
                selfY + selfHeight < target.y or selfY > target.y + target.height)
end

function Player:throwPot(pot)
    -- pot as a projectile
    self.liftPot = false
    self.pot = false
    pot.trackPlayer = false
    pot.projectile = true
    gSounds['hit-player']:play()

    -- velocity depends on player direction
    if self.direction == 'left' then
        pot.dx = -70
    elseif self.direction == 'right' then
        pot.dx = 70
    elseif self.direction == 'up' then
        pot.dy = -70
    else
        pot.dy = 70
    end
end

function Player:render()
    Entity.render(self)
    
    -- love.graphics.setColor(255, 0, 255, 255)
    -- love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    -- love.graphics.setColor(255, 255, 255, 255)
end