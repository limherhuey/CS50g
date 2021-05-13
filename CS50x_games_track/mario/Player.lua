Player = Class{}

local MOVE_SPEED = 100
local JUMP_VELOCITY = 350
local GRAVITY = 15

function Player:init(map)
    
    self.width = 16
    self.height = 20
    self.x = map.tileWidth * 10
    self.y = map.tileHeight * (map.mapHeight / 2 - 1) - self.height
    
    --offset from top left to centre to support sprite flipping
    self.xOffset = 8
    self.yOffset = 10

    self.dx = 0
    self.dy = 0    

    self.map = map
    self.texture = love.graphics.newImage('graphics/blue_alien.png')
    self.frames = generateQuads(self.texture, 16, 20)

    self.state = 'idle'
    self.direction = 'right'

    self.sounds = {
        ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
        ['hit'] = love.audio.newSource('sounds/hit.wav', 'static'),
        ['coin'] = love.audio.newSource('sounds/coin.wav', 'static')
    }

    --initialise all player animations
    self.animations = {
        --in Lua if the only argument to a function (Animation) is a table then can use just curly brackets
        ['idle'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[1]
            },
            interval = 1
        },
        ['walking'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[9], self.frames[10], self.frames[11]
            },
            interval = 0.15
        },
        ['jumping'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[3]
            },
            interval = 1
        }
    }

    --initialise animation and current frame we should render
    self.animation = self.animations['idle']
    self.currentFrame = self.animation:getCurrentFrame()

    --behavior we can call based on player state
    self.behaviours = {
        --first class functions: functions which can be treated like objects, can assign them to keys
        ['idle'] = function(dt)
            if love.keyboard.wasPressed('space') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
                self.sounds['jump']:play()
            elseif love.keyboard.isDown('a') then
                self.dx = -MOVE_SPEED
                self.state = 'walking'
                self.animations['walking']:restart()
                self.animation = self.animations['walking']
                self.direction = 'left'
            elseif love.keyboard.isDown('d') then
                self.dx = MOVE_SPEED
                self.state = 'walking'
                self.animations['walking']:restart()
                self.animation = self.animations['walking']
                self.direction = 'right'
            else
                self.dx = 0
            end
        end,
        ['walking'] = function(dt)
            if love.keyboard.wasPressed('space') then
                self.dy = -JUMP_VELOCITY
                self.state = 'jumping'
                self.animation = self.animations['jumping']
                self.sounds['jump']:play()
            elseif love.keyboard.isDown('a') then
                self.dx = -MOVE_SPEED
                self.direction = 'left'
            elseif love.keyboard.isDown('d') then
                self.dx = MOVE_SPEED
                self.direction = 'right'
            else
                self.dx = 0
                self.state = 'idle'
                self.animation = self.animations['idle']
            end

            --check for collisions left and right
            self:checkRightCollision()
            self:checkLeftCollision()

            --check collision below
            if not self.map:collides(self.map:tileAt(self.x, self.y + self.height)) and
                not self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then

                --if none, resets velocity and position and change state (into falling stage of 'jumping')
                self.state = 'jumping'
                self.animation = self.animations['jumping']
            end
        end,
        ['jumping'] = function(dt)
            --break if we go below the surface
            if self.y > 300 then return end

            if love.keyboard.isDown('a') then
                self.direction = 'left'
                self.dx = -MOVE_SPEED
            elseif love.keyboard.isDown('d') then                    
                self.direction = 'right'
                self.dx = MOVE_SPEED
            end
        
            self.dy = self.dy + GRAVITY
    
            --check if there is a tile below
            if self.map:collides(self.map:tileAt(self.x, self.y + self.height))
              or self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y + self.height)) then        
            
                --if yes, reset vertical velocity and change state to idle
                self.dy = 0
                self.state = 'idle'
                self.animation = self.animations[self.state]
                self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileHeight - self.height
            end

            --check for collisions left and right
            self:checkRightCollision()
            self:checkLeftCollision()
        end
    }
end

function Player:update(dt)
    self.behaviours[self.state](dt)
    self.animation:update(dt)
    self.currentFrame = self.animation:getCurrentFrame()
    self.x = self.x + self.dx * dt

    --jumping and block hitting logic
    if self.dy < 0 then
        --check if any collidable tiles are above
        if self.map:collides(self.map:tileAt(self.x, self.y)) or
            self.map:collides(self.map:tileAt(self.x + self.width - 1, self.y)) then
            --if yes, reset y velocity
            self.dy = 0

            --change block to different block and play sound if hit jump block
            local playCoin = false
            local playHit = false
            if self.map:tileAt(self.x, self.y).id == JUMP_BLOCK then
                self.map:setTile(math.floor(self.x / self.map.tileWidth) + 1, math.floor(self.y / self.map.tileHeight) + 1, JUMP_BLOCK_HIT)               
                playCoin = true
            else
                playHit = true
            end
            if self.map:tileAt(self.x + self.width - 1, self.y).id == JUMP_BLOCK then
                self.map:setTile(math.floor((self.x + self.width - 1) / self.map.tileWidth) + 1, math.floor(self.y / self.map.tileHeight) + 1, JUMP_BLOCK_HIT)
                playCoin = true
            else
                playHit = true
            end

            if playCoin then
                self.sounds['coin']:play()
            elseif playHit then
                self.sounds['hit']:play()
            end
        end
    end

    self.y = self.y + self.dy * dt

    
    --check if player reached flag (all 4 corners of player)
    if self.map:touchFlag(self.map:tileAt(self.x, self.y)) or self.map:touchFlag(self.map:tileAt(self.x, self.y + self.height - 1))
       or self.map:touchFlag(self.map:tileAt(self.x + self.width - 1, self.y)) or self.map:touchFlag(self.map:tileAt(self.x + self.width - 1, self.y + self.height - 1)) then

        --if yes, display end level message
        endLevel = true
    end
end

function Player:checkLeftCollision()
    if self.dx < 0 then
        --check if there is a collidable block to the left
        if self.map:collides(self.map:tileAt(self.x - 1, self.y)) or
          self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1)) then

            --if yes, reset x velocity and position
            self.dx = 0
            self.x = self.map:tileAt(self.x - 1, self.y).x * self.map.tileWidth
        end
    end
end

function Player:checkRightCollision()
    if self.dx > 0 then
        --check if there is a collidable block to the right
        if self.map:collides(self.map:tileAt(self.x + self.width, self.y)) or
          self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then

            --if yes, reset x velocity and position
            self.dx = 0
            self.x = (self.map:tileAt(self.x + self.width, self.y).x - 1) * self.map.tileWidth - self.width
        end
    end
end

function Player:render()

    --scaleX = -1 means flip the avatar around the y-axis (wrt the top left corner by default)
    local scaleX
    if self.direction == 'right' then
        scaleX = 1
    else
        scaleX = -1
    end

    love.graphics.draw(self.texture, self.currentFrame,
        --add self's width and height / 2 because we changed the reference point of the avatar (see 2 lines below)
        math.floor(self.x + self.xOffset), math.floor(self.y + self.yOffset),
            0, scaleX, 1,
            --make scaleX flip wrt the avatar's center
            self.xOffset, self.yOffset)
end