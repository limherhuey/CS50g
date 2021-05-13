--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    -- timer to update spawning of powerups
    self.timer = 0

    -- table to store spawned powerup cubes
    self.powerups = {}

    -- table at each powerup's skin index storing whether it has been spawned
    self.powerupsActive = {}
    for i = 1, 10 do
        self.powerupsActive[i] = false
    end

    -- table storing all balls in this level
    self.balls = {}

    -- if key has been collected this level & if locked brick is present
    self.key = false
    self.lockedBrick = false

    -- initial points (for each level) to increase paddle size
    self.paddlePoints = 3000

    -- what was passed on from previous state (serving)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.level = params.level

    self.recoverPoints = params.recoverPoints

    -- first ball
    ball = params.ball
    ball.dx = math.random(-200, 200)
    ball.dy = math.random(-60, -80)
    table.insert(self.balls, ball)
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('p') then
            self.paused = false
            gSounds['pause']:play()
        else
            -- don't update game if paused
            return
        end
    elseif love.keyboard.wasPressed('p') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)

    -- balls
    for k, ball in pairs(self.balls) do
        ball:update(dt)

        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end
    end

    -- powerups
    self.timer = self.timer + dt

    -- spawn a powerup if conditions met every 15 seconds
    if self.timer > 15 then
        self.timer = 0

        -- double ball powerup
        if not self.powerupsActive[7] and math.random(3) == 1 then
            p = Powerup(7)
            table.insert(self.powerups, p)

            -- remember that this powerup type has been spawned
            -- (only one of each type allowed at any point in time)
            self.powerupsActive[7] = true

        -- key powerup
        elseif self.lockedBrick and not self.powerupsActive[10] and math.random(4) == 1 then
            p = Powerup(10)
            table.insert(self.powerups, p)
            self.powerupsActive[10] = true
        end
    end

    for k, powerup in pairs(self.powerups) do
        if powerup.inPlay then
            powerup:update(dt)

            -- if player collects the powerup then initiate it
            if powerup:collides(self.paddle) then
                if powerup.skin == 7 then
                    powerup.inPlay = false
                    -- create 2 more balls
                    for i = 1, 2 do
                        ball = Ball(math.random(7))
                        ball.x = self.paddle.x + (self.paddle.width / 2) - 4
                        ball.y = self.paddle.y - 8
                        ball.dx = math.random(-200, 200)
                        ball.dy = math.random(60, 80)
                        table.insert(self.balls, ball)
                    end

                elseif powerup.skin == 10 then
                    powerup.inPlay = false
                    -- key collected! now with ability to destroy locked block
                    self.key = true
                end
            -- if not collected, reset the powerup's type so it may spawn again
            elseif powerup.y > VIRTUAL_HEIGHT then
                powerup.inPlay = false
                self.powerupsActive[powerup.skin] = false
            end
        end
    end

    -- detect collision across all bricks with all balls
    for i, ball in pairs(self.balls) do
        if ball.inPlay then
            for k, brick in pairs(self.bricks) do

                -- only check collision if we're in play
                if brick.inPlay and ball:collides(brick) then
                    
                    -- cannot destroy locked brick when key not collected
                    if brick.locked and not self.key then
                        -- self.locked tells us if this level has a locked brick (so key powerup should spawn)
                        self.lockedBrick = true
                        goto hit
                    end

                    -- add to score (extra for locked brick)
                    if brick.locked then
                        self.score = self.score + 3000
                    else
                        self.score = self.score + (brick.tier * 200 + brick.color * 25)
                    end

                    -- trigger the brick's hit function, which removes it from play
                    brick:hit()

                    -- if we have enough points, recover a point of health
                    if self.score > self.recoverPoints then
                        -- can't go above 3 health
                        self.health = math.min(3, self.health + 1)

                        -- multiply recover points by 2
                        self.recoverPoints = math.min(100000, self.recoverPoints * 2)

                        -- play recover sound effect
                        gSounds['recover']:play()
                    end

                    -- if enough points, increase paddle size by 1
                    if self.score > self.paddlePoints then
                        if self.paddle.size < 4 then
                            self.paddle.size = self.paddle.size + 1
                            self.paddle.width = self.paddle.width + 32

                            -- increase points required to upsize paddle next time
                            self.paddlePoints = self.paddlePoints * 2.4
                        end
                    end

                    -- go to our victory screen if there are no more bricks left
                    if self:checkVictory() then
                        gSounds['victory']:play()

                        gStateMachine:change('victory', {
                            level = self.level,
                            paddle = self.paddle,
                            health = self.health,
                            score = self.score,
                            highScores = self.highScores,
                            recoverPoints = self.recoverPoints
                        })
                    end

                    --
                    -- collision code for bricks
                    --
                    ::hit::
                    -- we check to see if the opposite side of our velocity is outside of the brick;
                    -- if it is, we trigger a collision on that side. else we're within the X + width of
                    -- the brick and should check to see if the top or bottom edge is outside of the brick,
                    -- colliding on the top or bottom accordingly 
                    --

                    -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                    -- so that flush corner hits register as Y flips, not X flips
                    if ball.x + 2 < brick.x and ball.dx > 0 then
                        
                        -- flip x velocity and reset position outside of brick
                        ball.dx = -ball.dx
                        ball.x = brick.x - 8
                    
                    -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                    -- so that flush corner hits register as Y flips, not X flips
                    elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                        
                        -- flip x velocity and reset position outside of brick
                        ball.dx = -ball.dx
                        ball.x = brick.x + 32
                    
                    -- top edge if no X collisions, always check
                    elseif ball.y < brick.y then
                        
                        -- flip y velocity and reset position outside of brick
                        ball.dy = -ball.dy
                        ball.y = brick.y - 8
                    
                    -- bottom edge if no X collisions or top collision, last possibility
                    else
                        
                        -- flip y velocity and reset position outside of brick
                        ball.dy = -ball.dy
                        ball.y = brick.y + 16
                    end

                    -- slightly scale the y velocity to speed up the game, capping at +- 150
                    if math.abs(ball.dy) < 150 then
                        ball.dy = ball.dy * 1.02
                    end

                    -- only allow colliding with one brick, for corners
                    break
                end
            end
        end
    end

    -- if all balls goes below bounds, revert to serve state and decrease health
    for k, ball in pairs(self.balls) do
        if ball.inPlay == true and ball.y >= VIRTUAL_HEIGHT then
            ball.inPlay = false
            
            if self:checkLoseHealth() then
                self.health = self.health - 1
                gSounds['hurt']:play()

                -- shrink paddle size when health lost
                if self.paddle.size > 1 then
                    self.paddle.size = self.paddle.size - 1
                    self.paddle.width = self.paddle.width - 32
                end

                if self.health == 0 then
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                else
                    gStateMachine:change('serve', {
                        paddle = self.paddle,
                        bricks = self.bricks,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        level = self.level,
                        recoverPoints = self.recoverPoints
                    })
                end
            end
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()

    for k, ball in pairs(self.balls) do
        if ball.inPlay then
            ball:render()
        end
    end

    for k, powerup in pairs(self.powerups) do
        if powerup.inPlay then
            powerup:render()
        end
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end

function PlayState:checkLoseHealth()
    for k, ball in pairs(self.balls) do
        if ball.inPlay then
            return false
        end
    end

    return true
end