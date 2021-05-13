--[[
    Super Mario Bros. Demo
    Author: Colton Ogden
    Original Credit: Nintendo

    Demonstrates rendering a screen of tiles.
]]

WINDOW_WIDTH = 1050
WINDOW_HEIGHT = 590

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

Class = require 'class'
push = require 'push'

require 'Map'
require 'Flag'
require 'Player'
require 'Animation'


--performs initialisation of all objects and data needed by programme
function love.load()  
    love.window.setTitle('Super Mario 50')
    
    love.graphics.setDefaultFilter('nearest', 'nearest')
    
    math.randomseed(os.time())

    love.graphics.setFont(love.graphics.newFont('fonts/font.ttf', 12))

    map_length = 50
    map = Map(map_length)
    endLevel = false

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })


    --you can add your own arbitrary values (we created keysPressed as a table here) to existing namespaces (.keyboard)
    love.keyboard.keysPressed = {}
    
end

--called whenever window is resized
function love.resize(w, h)
    push:resize(w, h)
end

--called whenever a key is pressed
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

--called every frame, with dt passed as delta time (time since last frame)
function love.update(dt)
    map:update(dt)

    --reset all keys pressed and released this frame
    love.keyboard.keysPressed = {}
end

--called each frame, used to render the screen
function love.draw()
    --begin virtual resolution drawing
    push:apply('start')
    
    love.graphics.clear(108 / 255, 140 / 255, 1, 1)

    love.graphics.translate(math.floor(-map.camX + 0.5), math.floor(-map.camY + 0.5))
    map:render()

    --display endLevel message
    if endLevel then
        love.graphics.print("Victory!", map.mapWidth * map.tileWidth - 4 * map.tileWidth, VIRTUAL_HEIGHT / 5)
    end

    --end virtual resolution
    push:apply('end')
end