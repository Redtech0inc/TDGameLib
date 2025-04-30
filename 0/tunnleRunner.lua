-- Load the game library
os.loadAPI("disk/zAssets/TDGameLib.lib") -- Make sure TDGameLib.lua is in the same directory

-- Create the Game Environment & get base variables
local game = TDGameLib.gameLib:create("Tunnel Runner")
local termWidth=game:getGameMEMValue("screenWidth")
local termHeight=game:getGameMEMValue("screenHeight")
local gameQuit = false

-- Load Sprites

--get all player sprites
local playerSprite = game:getShapeSprite(nil,1,1,colors.cyan)  -- Small sprite for player
local playerCanDashSprite = game:getShapeSprite(nil,1,1,colors.lightBlue) --sprite for when the dash ability is available
local playerPhaseSprite = game:getShapeSprite(nil,1,1,colors.gray)
local playerSlowMotionSprite = game:getShapeSprite(nil,1,1,colors.red)

--load all Obstacle sprites
local wallSprites = {}
table.insert(wallSprites,game:loadImage("disk/zAssets/sprites/wall1.nfp"))
table.insert(wallSprites,game:loadImage("disk/zAssets/sprites/wall2.nfp"))
table.insert(wallSprites,game:loadImage("disk/zAssets/sprites/wall3.nfp"))
table.insert(wallSprites,game:loadImage("disk/zAssets/sprites/wall4.nfp"))
table.insert(wallSprites,game:loadImage("disk/zAssets/sprites/wall5.nfp"))

local slowMotionWallSprites={}
table.insert(slowMotionWallSprites,game:loadImage("disk/zAssets/sprites/slowMotionWall1.nfp"))
table.insert(slowMotionWallSprites,game:loadImage("disk/zAssets/sprites/slowMotionWall2.nfp"))
table.insert(slowMotionWallSprites,game:loadImage("disk/zAssets/sprites/slowMotionWall3.nfp"))
table.insert(slowMotionWallSprites,game:loadImage("disk/zAssets/sprites/slowMotionWall4.nfp"))
table.insert(slowMotionWallSprites,game:loadImage("disk/zAssets/sprites/slowMotionWall5.nfp"))

--load all Dash sprites
local dashSpriteOn = game:loadImage("disk/zAssets/sprites/dash_on.nfp") --dash available hud sprite
local dashSpriteOff = game:loadImage("disk/zAssets/sprites/dash_off.nfp") --dash on cooldown hud sprite
local dashSpriteBlink = game:loadImage("disk/zAssets/sprites/dash_blink.nfp") --dash blinking sprite

--load all Phase sprites
local phaseSpriteOn = game:loadImage("disk/zAssets/sprites/phase_on.nfp")
local phaseSpriteOff = game:loadImage("disk/zAssets/sprites/phase_off.nfp")
local phaseSpriteBlink = game:loadImage("disk/zAssets/sprites/phase_blink.nfp")

--load all SlowMotion sprites
local slowMotionSpriteOn = game:loadImage("disk/zAssets/sprites/slowMotion_on.nfp")
local slowMotionSpriteOff = game:loadImage("disk/zAssets/sprites/slowMotion_off.nfp")
local slowMotionSpriteBlink = game:loadImage("disk/zAssets/sprites/slowMotion_blink.nfp")

-- Initialize Player
local playerX = 5  -- Static horizontal position
local playerY = math.floor(termHeight / 2)  -- Start in the middle

--initialize dash variables
local dashScore =75 --score at which you unlock Dash
local canDash = false --determines if the player can dash right now
local dashCooldown = 0 --cooldown for the dash ability
local dashDistance = 5 --is the distance dashed

--initialize phase variables
local phaseScore =150 --score at which you unlock Phase
local canPhase= false --determines if the player can phase right now
local phaseCooldown = 0 --cooldown for the phase ability
local phaseActive = false --tells the program if the phase is active once ability unlocks
local phaseLength=10 --length in seconds of the phase ability's activity

--initialize slowMotion variables
local slowMotionScore =300 --score at which you unlock slow motion ability
local canSlowMotion = false --determines if the player can slow everything down right now
local slowMotionCooldown = 0 --cooldown for the slow motion ability
local slowMotionActive = false --tells the program if slow motion is active once unlocked
local slowMotionLength = 10 --is the time for which the slow motion ability is active
local slowMotionCooldownLength = 10 --is the length of the cooldown for the slow motion ability

game:addSprite("object.player", playerSprite, nil, playerX, playerY)

--initialize Hud

--dash ability hud
game:addSprite("hud.dash", {{}}, nil , 12, 1)
game:addHologram("hud.dashCooldown", "Dash:"..dashScore, {gray=1}, {}, nil, 11, 1)

--phase ability hud
game:addSprite("hud.phase", {{}}, nil, 18, 1)
game:addHologram("hud.phaseCooldown", "Phase:"..phaseScore, {gray=1}, {}, nil, 19, 1)

--slow motion ability hud
game:addSprite("hud.slowMotion", {{}}, nil, 24, 1)
game:addHologram("hud.slowMotionCooldown", "Slow Mo.:"..slowMotionScore, {gray=1}, {}, nil, 29, 1)

--initialize wall values
local walls = {}
local wallSpeeds = {}
local maxSpeed = 1
local maxWalls = 5

game:groupObjects("group.walls",{})

-- Initialize Score
local score = 0
local scoreColor="lightGray"

game:addHologram("score.display", "Score: 0", {lightGray=1}, {black=1}, nil, 1, 1)

--Function for getting a random sprite of all loaded Wall sprites
local function getAWallSprite()
    local sprite=math.random(1,#wallSprites)
    sprite=wallSprites[sprite]
    return sprite
end

local function getAConvertedWallSprite()
    local sprite=math.random(1,#slowMotionWallSprites)
    sprite=slowMotionWallSprites[sprite]
    return sprite
end

local function ConvertWall(wallID,direction)

    local wallIDSprite=game:getGameMEMValue(wallID..".sprite")

    if not direction then

        for i=1,#slowMotionWallSprites do
            if wallIDSprite == wallSprites[i] then
                game:changeSpriteData(wallID,slowMotionWallSprites[i])
            end
        end

    elseif direction then

        for i=1,#slowMotionWallSprites do
            if wallIDSprite == slowMotionWallSprites[i] then
                game:changeSpriteData(wallID,wallSprites[i])
            end
        end

    end
end

-- Function to Spawn a New Wall at the Right Edge
local function spawnWall()
    local wallY = math.random(2, termHeight - 1)
    local wallID = "object.wall" .. #walls + 1
    if slowMotionActive then
        game:addSprite(wallID, getAConvertedWallSprite(), nil, termWidth, wallY)
    else
        game:addSprite(wallID, getAWallSprite(), nil, termWidth, wallY)
    end
    game:addObjectToGroup("group.walls",{wallID})
    table.insert(walls, wallID)
    table.insert(wallSpeeds, math.random(1,maxSpeed))
end

-- Function to Handle Player Input
local function handleInput()
    while not gameQuit do
        local _, key = os.pullEvent("key")

        if key == keys.w then
            playerY = math.max(1, playerY - 1)  -- Move up, prevent going off-screen
        elseif key == keys.s then
            playerY = math.min(termHeight, playerY + 1)  -- Move down
        elseif (key==keys.a or key==keys.d) and canDash then
            if key == keys.a then
                playerY = math.min(termHeight, playerY - dashDistance)
            elseif key == keys.d then
                playerY = math.min(termHeight, playerY + dashDistance)
            end
            canDash = false
            dashCooldown = 5
            game:changeSpriteData("object.player",playerSprite)
            game:changeSpriteData("hud.dash",dashSpriteOff)
        elseif key == keys.e and canPhase then
            phaseActive=true
            canPhase = false
            canDash = false
            phaseCooldown = -1*phaseLength
            game:changeSpriteData("hud.phase",phaseSpriteBlink)
            game:changeSpriteData("object.player",playerPhaseSprite)

        elseif key == keys.r and canSlowMotion then
            slowMotionActive = true
            canSlowMotion = false
            slowMotionCooldown = -1*slowMotionLength
            game:changeSpriteData("hud.slowMotion",slowMotionSpriteBlink)
            game:changeSpriteData("object.player",playerSlowMotionSprite)

            for i = #walls, 1, -1 do
                ConvertWall(walls[i])
            end

        elseif key == keys.q then
            gameQuit = true
            -- Quit the game and include the final score in the quit message
            game:quit(false, "Thanks for playing. Final Score: " .. score, colors.green)  -- Quit game with green message
            sleep(0.5)
            return  -- Stop function execution
        end

        if not gameQuit then
            game:changeSpriteData("object.player",nil, nil, playerY)
        end
    end
end

-- Function to Move Walls Left and Detect Collisions
local function updateWallsAndScore()
    while not gameQuit do
        for i = #walls, 1, -1 do
            local wallID = walls[i]
            local wallSpeed = wallSpeeds[i]
            local wallX = 1

            if gameQuit then return end  -- Stop execution if the game is quitting

            if slowMotionActive then wallSpeed = wallSpeed - 1 end

            for j = 1, wallSpeed do

                -- Move wall left
                wallX = game:getGameMEMValue(wallID .. ".x") or 1
                game:changeSpriteData(wallID,nil, wallX - 1)

                -- Check for collision with player
                if game:isColliding("object.player",wallID) and not phaseActive then
                    gameQuit = true
                    game:quit(nil, "Game Over! You crashed into a wall. Final Score: " .. score, colors.red)  -- Game over with red message
                    sleep(0.5)
                    return  -- Stop function execution
                end

            end

            if slowMotionActive then
                if game:isColliding("object.player",wallID) and not phaseActive then
                    gameQuit = true
                    game:quit(nil, "Game Over! You crashed into a wall. Final Score: " .. score, colors.red)  -- Game over with red message
                    sleep(0.5)
                    return  -- Stop function execution
                end
            end
            
            if game:isColliding("object.player","score.display") then
                game:changeSpriteData("object.player",nil,nil,2)
            end

            -- Remove wall if it goes off-screen
            if wallX < 1 then
                local newWallY = math.random(2, termHeight - 1)
                if slowMotionActive then
                    game:changeSpriteData(wallID,getAConvertedWallSprite(),termWidth,newWallY)
                else
                    game:changeSpriteData(wallID,getAWallSprite(),termWidth,newWallY)
                end

                wallSpeeds[i]= math.random(1,maxSpeed)
                -- Increase the score when the player successfully avoids a wall
                score = score + 1
                if score > 1000 and scoreColor ~= "red" then
                    game:changeHologramData("score.display",nil,{red=1})
                    scoreColor = "red"
                    maxWalls=23
                    maxSpeed= 3
                    dashDistance=10
                    phaseLength=20
                    slowMotionLength=16
                elseif score > 900 then
                    phaseLength=18
                    slowMotionCooldownLength=16
                    slowMotionLength=14
                elseif score >800 and scoreColor ~= "orange" and scoreColor ~= "red" then
                    game:changeHologramData("score.display",nil,{orange=1})
                    scoreColor = "orange"
                    maxWalls=20
                    dashDistance=8
                elseif score > 600 and scoreColor ~= "yellow" and scoreColor ~= "orange" and scoreColor ~= "red" then
                    game:changeHologramData("score.display",nil,{yellow=1})
                    scoreColor = "yellow"
                    maxWalls=27
                    dashDistance=7
                elseif score >  500 then
                    phaseLength=14
                    slowMotionCooldownLength=14
                    slowMotionLength=12
                elseif score > 400 and scoreColor ~= "lime" and scoreColor ~= "yellow" and scoreColor ~= "orange" and scoreColor ~= "red" then
                    game:changeHologramData("score.display",nil,{lime=1})
                    scoreColor="lime"
                    maxWalls=15
                elseif score > 300 then
                    phaseLength = 12
                elseif score > 200 and scoreColor ~= "green" and scoreColor ~= "lime" and scoreColor ~= "yellow" and scoreColor ~= "orange" and scoreColor ~= "red" then
                    game:changeHologramData("score.display",nil,{green=1})
                    scoreColor="green"
                    maxWalls=12
                    dashDistance=6
                elseif score >100 and scoreColor ~= "lightBlue" and scoreColor ~= "green" and scoreColor ~= "lime" and scoreColor ~= "yellow" and scoreColor ~= "orange" and scoreColor ~= "red" then
                    game:changeHologramData("score.display",nil,{lightBlue=1})
                    scoreColor="lightBlue"
                    maxWalls=10
                elseif score >50 and scoreColor ~= "blue" and scoreColor ~= "lightBlue" and scoreColor ~= "green" and scoreColor ~= "lime" and scoreColor ~= "yellow" and scoreColor ~= "orange" and scoreColor ~= "red" then
                    game:changeHologramData("score.display",nil,{blue=1})
                    scoreColor="blue"
                    maxSpeed = 2
                    maxWalls=7
                end

                game:changeHologramData("score.display", "Score: ".. score)  -- White text on black background
            end
        end

        if not gameQuit then
            -- Randomly spawn new walls
            if math.random(1, 3) == 1 and #walls < maxWalls then
                spawnWall()
            end
            game:render()
        end
        sleep(0.1) -- Control game speed
    end

end


local function dashAbility()
    while not gameQuit do
        if score >= dashScore and dashCooldown < 1 and not canDash then
            if not phaseActive then
                canDash = true
                game:changeHologramData("hud.dashCooldown","AorD",{orange=1},{},13,2)
                game:changeSpriteData("object.player",playerCanDashSprite)
            else
                game:changeHologramData("hud.dashCooldown"," ",{},{},13,2)
                sleep(0.2)
            end
            game:changeSpriteData("hud.dash",dashSpriteOn)
        elseif score >= dashScore and dashCooldown == 1 then
            game:changeHologramData("hud.dashCooldown"," 1",{orange=1})
            game:changeSpriteData("hud.dash",dashSpriteBlink)
            game:changeSpriteData("object.player",playerCanDashSprite)
            sleep(0.25)

            game:changeHologramData("hud.dashCooldown"," 1",{white=1})
            game:changeSpriteData("hud.dash",dashSpriteOff)
            game:changeSpriteData("object.player",playerSprite)
            sleep(0.25)

            game:changeHologramData("hud.dashCooldown"," 1",{orange=1})
            game:changeSpriteData("hud.dash",dashSpriteBlink)
            game:changeSpriteData("object.player",playerCanDashSprite)
            sleep(0.25)

            game:changeHologramData("hud.dashCooldown"," 0",{orange=1})
            game:changeSpriteData("object.player",playerSprite)
            dashCooldown = 0
            sleep(0.25)

        elseif score >= dashScore and dashCooldown > 0 then
            dashCooldown = dashCooldown - 1
            game:changeHologramData("hud.dashCooldown"," "..tostring(dashCooldown),{})
            sleep(1)
        else
            sleep(0.2)
        end
    end
end

local function phaseAbility()
    while not gameQuit do
        if score >= phaseScore and phaseCooldown == 0 and not (canPhase or phaseActive) then
            canPhase = true
            game:changeSpriteData("hud.phase",phaseSpriteOn)
            game:changeHologramData("hud.phaseCooldown", "E", {blue=1}, {}, 20, 3)
        elseif score >= phaseScore and phaseCooldown == 1 then
            game:changeSpriteData("hud.phase",phaseSpriteBlink)
            sleep(0.25)

            game:changeSpriteData("hud.phase",phaseSpriteOff)
            sleep(0.25)

            game:changeSpriteData("hud.phase",phaseSpriteBlink)
            sleep(0.25)

            game:changeHologramData("hud.phaseCooldown","0")
            phaseCooldown = 0
            sleep(0.25)

        elseif score >= phaseScore and phaseCooldown > 0 then
            phaseCooldown = phaseCooldown - 1
            game:changeHologramData("hud.phaseCooldown",tostring(phaseCooldown),{})
            sleep(1)
        elseif score >= phaseScore and phaseCooldown < 0 then

            phaseCooldown = phaseCooldown + 1
            game:changeHologramData("hud.phaseCooldown",tostring(math.abs(phaseCooldown)),{blue=1})
            game:changeSpriteData("object.player",playerPhaseSprite)

            if phaseCooldown == 0 then
                game:changeSpriteData("hud.phase",phaseSpriteOff)
                game:changeSpriteData("object.player",playerSprite)
                phaseCooldown = 10
                phaseActive = false
            end

            sleep(1)
        else
            sleep(0.2)
        end
    end
end

local function slowMotionAbility()
    while not gameQuit do
        if score >= slowMotionScore and slowMotionCooldown == 0 and not (slowMotionActive or canSlowMotion) then
            canSlowMotion = true
            game:changeSpriteData("hud.slowMotion",slowMotionSpriteOn)
            game:changeHologramData("hud.slowMotionCooldown", "R", {blue=1}, {}, 26, 3)
        elseif score >= slowMotionScore and slowMotionCooldown == 1 then
            game:changeSpriteData("hud.slowMotion",slowMotionSpriteBlink)
            sleep(0.25)

            game:changeSpriteData("hud.slowMotion",slowMotionSpriteOff)
            sleep(0.25)

            game:changeSpriteData("hud.slowMotion",slowMotionSpriteBlink)
            sleep(0.25)

            game:changeHologramData("hud.slowMotionCooldown","0")
            slowMotionCooldown = 0
            sleep(0.25)

        elseif score >= slowMotionScore and slowMotionCooldown > 0 then
            slowMotionCooldown = slowMotionCooldown - 1
            game:changeHologramData("hud.slowMotionCooldown",tostring(slowMotionCooldown),{white=1})
            sleep(1)
        elseif score >= slowMotionScore and slowMotionCooldown < 0 then
            
            slowMotionCooldown = slowMotionCooldown + 1
            game:changeHologramData("hud.slowMotionCooldown",tostring(math.abs(slowMotionCooldown)),{red=1})
            game:changeSpriteData("object.player",playerSlowMotionSprite)

            if slowMotionCooldown == 0 then
                game:changeSpriteData("hud.slowMotion",slowMotionSpriteOff)
                game:changeSpriteData("object.player",playerSprite)
                slowMotionCooldown = slowMotionCooldownLength
                slowMotionActive = false

                
                for i = #walls, 1, -1 do
                    ConvertWall(walls[i],true)
                end
            end

            sleep(1)
        else
            sleep(0.2)
        end
    end
end

-- Run Input, Wall Updates and ability Logic in Parallel (starts all game Loops)
parallel.waitForAny(updateWallsAndScore, handleInput, dashAbility, phaseAbility, slowMotionAbility)