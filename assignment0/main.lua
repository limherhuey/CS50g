--[[
    GD50 2018
    Pong Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Originally programmed by Atari in 1972. Features two paddles, controlled by players,
    with the goal of getting the ball past your opponent's edge. First to 10 points wins.

    This version is built to more closely resemble the NES than the 
    original Pong machines or the Atari 2600 in terms of resolution,
    though in widescreen (16:9) so it looks nicer on modern systems.
]]



--push is a library that allows us to draw our game at a virtual resolution,
--instead of however large our window is; provides a more retro aesthetic
-- https://github.com/Ulydev/push
push = require 'push'

-- the "Class" library we're using will allow us to represent anything in our game
-- as code, rather than keeping track of many disparate variables and methods
Class = require 'class'
--any variable without 'local' keyword can be accessed globally (anywhere in the application)
require 'Ball'
require 'Paddle'


WINDOW_WIDTH = 1050
WINDOW_HEIGHT = 590

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

--this means 200 pixels/sec
PADDLE_SPEED = 200


-- Runs when the game first starts up, only once; used to initialize the game.
function love.load()
    
    -- set love's default filter to "nearest-neighbor", which essentially
    -- means there will be no filtering of pixels (blurriness), which is
    -- important for a nice crisp, 2D look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pong')

    math.randomseed(os.time())

    --set fonts used in game
    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    victoryFont = love.graphics.newFont('font.ttf', 16)

    --create a table for sounds
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    --initialise window with virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
            fullscreen = false,
            vsync = true,
            resizable = true
    })

    
    --init is called implicitly; paddles and ball are initialised
    paddle1 = Paddle(5, 20, 5, 20)
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 40, 5, 20)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5, 5)

    --initial value of scores
    player1Score = 0
    player2Score = 0

    --set serving player and ball direction towards player serving
    servingPlayer = math.random(2) == 1 and 1 or 2
    if servingPlayer == 1 then
        ball.dx = -100
    else
        ball.dx = 100
    end

    --take note of winning player for victory state
    winningPlayer = 0

    gameState = 'start'
end

function love.resize(w, h)
    push:resize(w, h)
end


--if you want to change anything in your game, override love.update()
--[[
    Runs every frame, with "dt" passed in, our delta in seconds 
    since the last frame, which LÖVE2D supplies us.
]]
function love.update(dt)

    --increment of scores and set serving player
    if gameState == 'play' then
        if ball.x <= 0 then
            sounds['score']:play()

            player2Score = player2Score + 1
            servingPlayer = 1
            ball:reset()
            ball.dx = -ball.dx
            paddle1.dy = 0
            paddle2.dy = 0

            if player2Score >= 10 then
                gameState = 'victory'
                winningPlayer = 2
            else
                gameState = 'serve'
            end
        end

        if ball.x >= VIRTUAL_WIDTH - 5 then
            sounds['score']:play()

            player1Score = player1Score + 1
            servingPlayer = 2
            ball:reset()
            paddle1.dy = 0
            paddle2.dy = 0

            if player1Score >= 10 then
                gameState = 'victory'
                winningPlayer = 1
            else
                gameState = 'serve'
            end
        end
    end


    --deflect ball when it collides with paddles and increase dx
    if ball:collides(paddle1) then
        sounds['paddle_hit']:play()
        
        ball.dx = -ball.dx * 1.05
        ball.x = paddle1.x + paddle1.width
        ball.dy = ball.dy * 1.05
    end

    if ball:collides(paddle2) then
        sounds['paddle_hit']:play()

        ball.dx = -ball.dx * 1.05
        ball.x = paddle2.x - ball.width
        ball.dy = ball.dy * 1.05
    end

    --deflect ball when it collides with top or bottom of window
    if ball.y <= 0 then
        ball.dy = -ball.dy
        ball.y = 0

        sounds['wall_hit']:play()
    end

    if ball.y >= VIRTUAL_HEIGHT - ball.height then
        ball.dy = -ball.dy
        ball.y = VIRTUAL_HEIGHT - ball.height

        sounds['wall_hit']:play()
    end

    --controls of paddles in game
    if gameState == 'play' then
        --player 1 movements
        if love.keyboard.isDown('w') then
            paddle1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            paddle1.dy = PADDLE_SPEED
        else
            paddle1.dy = 0
        end

        --player 2 movement
        if gameMode == 'pvp' then
            if love.keyboard.isDown('up') then
                paddle2.dy = -PADDLE_SPEED
            elseif love.keyboard.isDown('down') then
                paddle2.dy = PADDLE_SPEED
            else
                paddle2.dy = 0
            end
        else
            --AI section
            --paddle moves to fetch ball when within factor distance, predetermined by AI difficulty
            if (paddle2.x - ball.x + ball.width) < factor and ball.dx > 0 then
                if ball.y + ball.height / 2 < paddle2.y + paddle2.height / 2 then
                    paddle2.dy = -PADDLE_SPEED
                elseif ball.y + ball.height / 2 > paddle2.y + paddle2.height / 2 then
                    paddle2.dy = PADDLE_SPEED
                else
                    paddle2.dy = 0
                end
            elseif insane then
                --paddle moves back to centre when not fetching the ball
                --only for insane mode
                if paddle2.y + paddle2.height / 2> VIRTUAL_HEIGHT / 2 then
                    paddle2.dy = -PADDLE_SPEED
                elseif paddle2.y + paddle2.height / 2< VIRTUAL_HEIGHT / 2 then
                    paddle2.dy = PADDLE_SPEED
                else
                    paddle2.dy = 0
                end
            else
                paddle2.dy = 0
            end
        end
    end

    --movement of paddles and ensure they stay within window
    paddle1:update(dt)
    paddle2:update(dt)
    --movement of ball
    if gameState == 'play' then
        ball:update(dt)
    end
end


function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()

    elseif key == 'enter' or key == 'return' then
        if gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'victory' then
            gameState = 'serve'
            ball:reset()
            player1Score = 0
            player2Score = 0
        end
    
    elseif key == 'r' then
        ball:reset()
        player1Score = 0
        player2Score = 0
        gameState = 'start'
        
        servingPlayer = math.random(2) == 1 and 1 or 2
        if servingPlayer == 1 then
            ball.dx = -100
        else
            ball.dx = 100
        end
    end

    --choosing game mode
    if gameState == 'start' then
        if key == '1' then
            gameMode = 'pvp'
            gameState = 'serve'
        elseif key == '2' then
            gameMode = 'pva'
            gameState = 'chooseAI'
        elseif key == 'c' then
            gameState = 'controls'
        end

    --if AI mode, factor determines difficulty, where factor is
    --the distance from the ball when the AI paddle starts moving
    elseif gameState == 'chooseAI' then
        if key == '1' then
            factor = VIRTUAL_WIDTH / 5
            gameState = 'serve'
        elseif key == '2' then
            factor = VIRTUAL_WIDTH / 4
            gameState = 'serve'
        elseif key == '3' then
            factor = VIRTUAL_WIDTH * 3 / 4
            insane = 1
            gameState = 'serve'
        end
    end
end

function love.draw()
    push:apply('start')

    --set background colour
    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

    --display messages
    love.graphics.setFont(smallFont)

    if gameState == 'start' then
        love.graphics.printf("Welcome to Pong!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press 1 for Player vs Player", 0, 32, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press 2 for Player vs AI", 0, 40, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press c to see controls", 0, 48, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press esc to quit game.", 0, 56, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'chooseAI' then
        love.graphics.printf("Choose your level of difficulty:", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press 1 for Easy", 0, 32, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press 2 for Hard", 0, 40, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press 3 for Insane", 0, 48, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'controls' then
        love.graphics.printf("Game Controls", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Player 1: w for up, s for down", 0, 32, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Player 2: arrowup for up, arrowdown for down", 0, 40, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press r to return to Main Menu!", 0, 50, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s turn", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Serve!", 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'victory' then
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player " .. tostring(winningPlayer) .. " wins!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to play again!", 0, 42, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press r to return to Main Menu!", 0, 50, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        --no UI messages to display
    end

    --display scores
    if gameState == 'serve' or gameState == 'victory' or gameState == 'play' then
        love.graphics.setFont(scoreFont)
        love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
        love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
    end

    --make paddles and ball
    paddle1:render()
    paddle2:render()
    ball:render()

    --see function below
    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    --string concatenation
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
    
    --set colour back to white for drawing other stuff later on
    love.graphics.setColor(1, 1, 1, 1)
end