--[[
    PlayState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The PlayState class is the bulk of the game, where the player actually controls the bird and
    avoids pipes. When the player collides with a pipe, we should go to the GameOver state, where
    we then go back to the main menu.
]]

PlayState = Class{__includes = BaseState}

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0
    self.pipeInterval = 2
    self.score = 0

    -- initialize last pipe's Y value : first pipe placed randomly (with specified constraints below)
    -- this y value is the top pipe's y
    self.lastY = -PIPE_HEIGHT + math.random(80) + 10
end

function PlayState:update(dt)
    -- pause and unpause game
    if love.keyboard.wasPressed('x') then
        if paused then
            paused = false
            sounds['music']:play()
        else
            paused = true
            sounds['music']:pause()
            sounds['pause']:play()
        end
    end

    if not paused then
        -- update timer for pipe spawning
        self.timer = self.timer + dt

        if self.timer > self.pipeInterval then
            --modify the last pipe's Y coordinate so consecutive pipe gaps aren't too far
            --but pipe is no higher than 10 pixels below top of screen
            --and no lower than 90 pixels from the bottom of screen
            local y = math.max(-PIPE_HEIGHT + 10, 
                math.min(self.lastY + math.random(-22, 22), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
            self.lastY = y

            -- add a new pipe pair at the end of the screen at new y
            table.insert(self.pipePairs, PipePair(y))

            -- reset timer
            self.timer = 0
            
            -- randomise interval between pipes spawning between 1.8-2.3 seconds
            self.pipeInterval = math.random(18, 23)
            self.pipeInterval = self.pipeInterval / 10
        end

        -- for every pair of pipes (in table), add a point if bird past it, ignore if already scored
        for k, pair in pairs(self.pipePairs) do
            if not pair.scored then
                if pair.x + PIPE_WIDTH < self.bird.x then
                    self.score = self.score + 1
                    pair.scored = true

                    sounds['score']:play()
                end
            end

            pair:update(dt)
        end

        -- delete pipes in this loop rather previous one because modifying the table in-place
        -- without explicit keys will result in skipping the next pipe, since all implicit 
        -- keys (numerical indices) are automatically shifted down after a key-value removal
        for k, pair in pairs(self.pipePairs) do
            if pair.remove then
                table.remove(self.pipePairs, k)
            end
        end

        -- game over if collide with top/bottom pipes in each pipe pair
        for k, pair in pairs(self.pipePairs) do
            for l, pipe in pairs(pair.pipes) do
                if self.bird:collides(pipe) then
                    sounds['explosion']:play()
                    sounds['hurt']:play()

                    -- change to score state and input score
                    gStateMachine:change('score', {
                        score = self.score
                    })
                end
            end
        end

        self.bird:update(dt)

        -- game over if hit ground
        if self.bird.y > VIRTUAL_HEIGHT - 16 then
            sounds['explosion']:play()
            sounds['hurt']:play()

            gStateMachine:change('score', {
                score = self.score
            })
        end
    end
end

function PlayState:render()
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

    self.bird:render()

    -- if game is paused
    if paused then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Paused', 0, 105, VIRTUAL_WIDTH, 'center')
    end
end

--Called when this state is transitioned to from another state.
function PlayState:enter()
    -- if we're coming from death, restart scrolling
    scrolling = true
end

--Called when this state changes to another state.
function PlayState:exit()
    -- stop scrolling for the death/score screen
    scrolling = false
end