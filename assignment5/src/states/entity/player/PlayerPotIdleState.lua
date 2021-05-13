
PlayerPotIdleState = Class{__includes = EntityIdleState}

function PlayerPotIdleState:init(player)
    self.entity = player

    -- render offset for spaced character sprite
    self.entity.offsetY = 5
    self.entity.offsetX = 0

    self.entity:changeAnimation('pot-idle-' .. self.entity.direction)
end

function PlayerPotIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('pot-walk')
    end

    -- throw pot
    if love.keyboard.wasPressed('x') then
        for k, object in pairs(self.entity.objects) do
            if object.type == 'pot' then
                self.entity:throwPot(object)
            end
        end
        
        self.entity:changeState('idle')
    end

    EntityIdleState.update(self, dt)
end