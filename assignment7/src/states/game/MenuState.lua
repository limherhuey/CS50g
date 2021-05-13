--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

MenuState = Class{__includes = BaseState}

function MenuState:init(incHP, incAtk, incDef, incSpd, pokemon, onClose)

    local HP, attack, defense, speed = pokemon.HP, pokemon.attack, pokemon.defense, pokemon.speed

    self.onClose = onClose or function() end

    -- menus to display stats data upon level up (left half)
    self.statsMenu = Menu {
        cursor = false,
        x = 0,
        y = VIRTUAL_HEIGHT - 64,
        width = VIRTUAL_WIDTH / 2,
        height = 64,

        items = {
            { text = 'HP: ' .. tostring(HP - incHP) .. ' + ' .. tostring(incHP) .. ' = ' .. tostring(HP)},
            { text = 'Attack: ' .. tostring(attack - incAtk) .. ' + ' .. tostring(incAtk) .. ' = ' .. tostring(attack)}
        }
    }
    -- right half
    self.menu = Menu {
        cursor = false,
        x = VIRTUAL_WIDTH / 2,
        y = VIRTUAL_HEIGHT - 64,
        width = VIRTUAL_WIDTH / 2,
        height = 64,

        items = {
            { text = 'Defense: ' .. tostring(defense - incDef) .. ' + ' .. tostring(incDef) .. ' = ' .. tostring(defense)},
            { text = 'Speed: ' .. tostring(speed - incSpd) .. ' + ' .. tostring(incSpd) .. ' = ' .. tostring(speed)}
        }
    }
end

function MenuState:update(dt)
    if love.keyboard.wasPressed('space') or love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateStack:pop()
        self.onClose()
    end
end

function MenuState:render()
    self.menu:render()
    self.statsMenu:render()
end