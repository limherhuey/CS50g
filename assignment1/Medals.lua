Medals = Class{}

function Medals:init()
    self.images = {
        ['gold'] = love.graphics.newImage('images/gold.png'),
        ['silver'] = love.graphics.newImage('images/silver.png'),
        ['bronze'] = love.graphics.newImage('images/bronze.png')
    }

    self.x = VIRTUAL_WIDTH / 2 - 22
    self.y = 107
end

function Medals:update(dt)

end

function Medals:render(score)
    -- print medal onto screen according to score
    if score > 10 then
        love.graphics.draw(self.images['gold'], self.x, self.y)
    elseif score > 5 and score <= 10 then
        love.graphics.draw(self.images['silver'], self.x, self.y)
    else
        love.graphics.draw(self.images['bronze'], self.x, self.y)
    end
end