--functions for functions

local function isColorValue(colorValue)
    local colorTable={
        colors.white, colors.orange, colors.magenta, colors.lightBlue,
        colors.yellow, colors.lime, colors.pink, colors.gray,
        colors.lightGray, colors.cyan, colors.purple, colors.blue,
        colors.brown, colors.green, colors.red, colors.black,
    }
    for color=1,#colorTable do
        if colorTable[color] == colorValue then
            return true
        end
    end
    return false
end

local function toboolean(input)
    if input then
        return true
    end
    return false
end

local function getFileLines(dir)
    if not fs.exists(dir) then error("'"..dir.."' is not an existing file") end
    local file=io.open(dir,"r")
    local output={}
    while true do
        local line=file:read("l")
        if line ~= nil then
            table.insert(output,line)
        else
            return output
        end
    end
end

local function writeToFile(file,text,indents,nextLine,compact)
    if not compact then
        for i=1,indents do
            file:write("    ")
        end
    end
    file:write(tostring(text))
    if nextLine and not compact then
        file:write("\n")
    elseif compact then
        file:write(" ")
    end
end

local function getBiggestIndex(matrix,returnBoth)
    local index1
    local index2 = 0
    for i = 1,#matrix do
        for j = 1,table.maxn(matrix[i]) do
            if j > index2 then
                index2 = j
                index1 = i
            end
        end
    end
    if returnBoth then
        return index1, index2
    end
    return index2
end

--opens class table
gameLib={}
gameLib.__index=gameLib



function gameLib:drawPixel(x, y, color)
    if self.gameMEM.monitor then

        self.gameMEM.monitor.setCursorPos(x, y)
        self.gameMEM.monitor.setBackgroundColor(color)
        self.gameMEM.monitor.write(" ")
    else

        term.setCursorPos(x, y)
        term.setBackgroundColor(color)
        term.write(" ")
    end
end

function gameLib:createSubTables(lvl)
    local keys = {}

    for key in lvl:gmatch("[^.]+") do
        table.insert(keys, key)
    end

    local node = self.gameMEM

    for i = 1, #keys do
        local key = keys[i]
        if node[key] == nil then
            node[key] = {}
        end
        node = node[key]
    end
end

function gameLib:getSubTable(lvl,returnLast)
    if returnLast == nil then returnLast=true end

    local keys = {}

    for key in lvl:gmatch("[^.]+") do
        table.insert(keys, key)
    end

    local node = self.gameMEM

    for i = 1, #keys - 1 do
        local key = keys[i]
        if node[key] == nil then
            node[key] = {}
        end
        node = node[key]
    end

    if returnLast then
        return node[keys[#keys]]
    else
        return node,keys
    end
end

function gameLib:isSubTable(lvl,intro)

    local keys = {}
    local node

    for key in lvl:gmatch("[^.]+") do
        table.insert(keys, key)
    end
    if intro then
        node = intro
    else
        node=self.gameMEM
    end

    for i = 1, #keys do
        local key = keys[i]
        if node[key] == nil then
            return false
        end
        node = node[key]
    end
    return true
end

function gameLib:cleanGameMEM(lvl)
    local keys = {}

    for key in lvl:gmatch("[^.]+") do
        table.insert(keys, key)
    end

    local node = self.gameMEM
    local br = false
    for _= 1,#keys do
        for i = 1, #keys do
            if not br then
                local key = keys[i]
                if node[key] == nil then
                    node[key] = {}
                end
                node = node[key]
                if type(node) == "table" then
                    if #node < 1 then
                        node = nil
                        br = true
                    end
                end
            end
        end
    end
end

function gameLib:wrapHologramText(text, x)
    local text = tostring(text)
    local textTable = {}
    local line = ""

    local width = self.gameMEM.screenWidth - (x - 1)

    -- Split into lines at \n first
    for rawLine in text:gmatch("([^\n]*)\n?") do
        local words = {}
        for word in rawLine:gmatch("%S+") do
            table.insert(words, word)
        end

        local i = 1
        while i <= #words do
            local word = words[i]

            if #word > width then
                if #line > 0 then
                    table.insert(textTable, line)
                    line = ""
                end
                -- Split long word
                while #word > width do
                    table.insert(textTable, word:sub(1, width))
                    word = word:sub(width + 1)
                end
                line = word
            elseif #line + #word + (line == "" and 0 or 1) > width then
                table.insert(textTable, line)
                line = word
            else
                line = (#line > 0) and (line .. " " .. word) or word
            end

            i = i + 1
        end

        -- End of manual line → flush current line
        if #line > 0 then
            table.insert(textTable, line)
            line = ""
        end
    end

    -- Just in case something is still in `line` (shouldn't happen)
    if #line > 0 then
        table.insert(textTable, line)
    end

    -- Calculate max line width
    local maxWidth = 0
    for i = 1, #textTable do
        if #textTable[i] > maxWidth then
            maxWidth = #textTable[i]
        end
    end

    return textTable, maxWidth
end

function gameLib:subRenderComponentBackground()
    for i = 1, self.gameMEM.screenWidth do
        for j = 1, self.gameMEM.screenHeight do
            if self.gameMEM.LVL.background[i] then
                if isColorValue(self.gameMEM.LVL.background[i][j]) then
                    self:drawPixel(i + self.gameMEM.renderStartX, j + self.gameMEM.renderStartY, self.gameMEM.LVL.background[i][j])
                    if not self.gameMEM.LVL.screen[i] then
                        self.gameMEM.LVL.screen[i] = {}
                    end
                    self.gameMEM.LVL.screen[i][j] = self.gameMEM.LVL.background[i][j]
                end
            end
        end
    end
end

function gameLib:subRenderComponentBackgroundHolograms(renderOBJ)
    local node = self:getSubTable(renderOBJ) --self.gameMEM.objects.render.renderList.backgroundHolograms[i]

    if node ~= nil then

        -- get values from the given Hologram path
        local renderText = node.text
        local renderTextColor = node.textColor
        local renderTextBackgroundColor = node.textBackgroundColor
        if node.type == "hologramClone" then
            local obj = self:getSubTable(node.text)
            renderText = obj.text
            renderTextColor = obj.textColor
            renderTextBackgroundColor = obj.textBackgroundColor
        end

        local renderX = node.x or 1
        local renderY = node.y or 1

        local textColorTable = {}
        if type(renderTextColor) == "table" then
            for color, textPos in pairs(renderTextColor) do
                textColorTable[textPos] = colors[color]
            end
        end

        local textBackgroundColorTable = {}
        if type(renderTextBackgroundColor) == "table" then
            for color, textPos in pairs(renderTextBackgroundColor) do
                textBackgroundColorTable[textPos] = colors[color]
            end
        end

        local textBackgroundColorSet = false
        local textColorPos = 0
        local textOut = ""
        for i =1, #renderText do

            if self.gameMEM.monitor then
                self.gameMEM.monitor.setCursorPos(renderX + self.gameMEM.renderStartX, renderY + self.gameMEM.renderStartY + (i - 1))
                self.gameMEM.monitor.setTextColor(colors.white)
            else
                term.setCursorPos(renderX + self.gameMEM.renderStartX, renderY + self.gameMEM.renderStartY + (i - 1))
                term.setTextColor(colors.white)
            end

            textOut = tostring(renderText[i])

            for j = 1, #renderText[i] do
                if isColorValue(textColorTable[j]) then
                    if self.gameMEM.monitor then
                        self.gameMEM.monitor.setTextColor(textColorTable[j+textColorPos])
                    else
                        term.setTextColor(textColorTable[j+textColorPos])
                    end
                end
                if isColorValue(textBackgroundColorTable[j+textColorPos]) then
                    if self.gameMEM.monitor then
                        self.gameMEM.monitor.setBackgroundColor(textBackgroundColorTable[j+textColorPos])
                    else
                        term.setBackgroundColor(textBackgroundColorTable[j+textColorPos])
                    end
                    textBackgroundColorSet = true
                elseif self.gameMEM.LVL.screen[renderX + (j - 1)] then
                    if isColorValue(self.gameMEM.LVL.screen[renderX + (j - 1)][renderY + (i - 1)]) and not textBackgroundColorSet then
                        if self.gameMEM.monitor then
                            self.gameMEM.monitor.setBackgroundColor(self.gameMEM.LVL.screen[renderX + (j - 1)][renderY + (i - 1)])
                        else
                            term.setBackgroundColor(self.gameMEM.LVL.screen[renderX + (j - 1)][renderY + (i - 1)])
                        end
                    end
                end

                if self.gameMEM.monitor then
                    self.gameMEM.monitor.write(string.sub(textOut, j, j))
                else
                    term.write(string.sub(textOut, j, j))
                end
            end
            textColorPos = textColorPos + #textOut
        end
    end
end

function gameLib:subRenderComponentSprites(renderOBJ)
    if self.gameMEM.monitor then
        self.gameMEM.monitor.setCursorPos(1,1)
    else
        term.setCursorPos(1,1)
    end

    local node = self:getSubTable(renderOBJ)

    -- get values from the given Sprite path
    local renderSprite = node.sprite or {}
    if node.type == "spriteClone" then
        local obj = self:getSubTable(node.sprite) 
        renderSprite = obj.sprite or {}
    end

    local renderX = node.x or 1
    local renderY = node.y or 1
    renderX = renderX - 1
    renderY = renderY -1

    for i = 1, #renderSprite do
        for j = 1, table.maxn(renderSprite[i]) do
            if isColorValue(renderSprite[i][j]) then
                self:drawPixel(i + renderX + self.gameMEM.renderStartX, j + renderY + self.gameMEM.renderStartY, renderSprite[i][j])
                if self.gameMEM.LVL.screen[i + renderX] then
                    if self.gameMEM.LVL.screen[i + renderX][j + renderY] and isColorValue(renderSprite[i][j]) then
                        self.gameMEM.LVL.screen[i + renderX][j + renderY] = renderSprite[i][j]
                    end
                end
            end
        end
    end
end

function gameLib:subRenderComponentHolograms(renderOBJ)
    local node = self:getSubTable(renderOBJ)

    if node ~= nil then

        -- get values from the given Hologram path
        local renderText = node.text
        local renderTextColor = node.textColor
        local renderTextBackgroundColor = node.textBackgroundColor
        if node.type == "hologramClone" then
            local obj = self:getSubTable(node.text)
            renderText = obj.text
            renderTextColor = obj.textColor
            renderTextBackgroundColor = obj.textBackgroundColor
        end

        local renderX = node.x or 1
        local renderY = node.y or 1

        local textColorTable = {}
        if type(renderTextColor) == "table" then
            for color, textPos in pairs(renderTextColor) do
                textColorTable[textPos] = colors[color]
            end
        end

        local textBackgroundColorTable = {}
        if type(renderTextBackgroundColor) == "table" then
            for color, textPos in pairs(renderTextBackgroundColor) do
                textBackgroundColorTable[textPos] = colors[color]
            end
        end

        if self.gameMEM.monitor then
            self.gameMEM.monitor.setTextColor(colors.white)
        else
            term.setTextColor(colors.white)
        end

        local textBackgroundColorSet = false
        local textColorPos = 0
        local textOut = ""
        for i =1, #renderText do

            if self.gameMEM.monitor then
                self.gameMEM.monitor.setCursorPos(renderX + self.gameMEM.renderStartX, renderY + self.gameMEM.renderStartY + (i - 1))
            else
                term.setCursorPos(renderX + self.gameMEM.renderStartX, renderY + self.gameMEM.renderStartY + (i - 1))
            end

            textOut = tostring(renderText[i])

            for j = 1, #renderText[i] do
                if isColorValue(textColorTable[j+textColorPos]) then
                    if self.gameMEM.monitor then
                        self.gameMEM.monitor.setTextColor(textColorTable[j+textColorPos])
                    else
                        term.setTextColor(textColorTable[j+textColorPos])
                    end
                end
                if isColorValue(textBackgroundColorTable[j+textColorPos]) then
                    if self.gameMEM.monitor then
                        self.gameMEM.monitor.setBackgroundColor(textBackgroundColorTable[j+textColorPos])
                    else
                        term.setBackgroundColor(textBackgroundColorTable[j+textColorPos])
                    end
                    textBackgroundColorSet = true
                elseif self.gameMEM.LVL.screen[renderX + (j - 1)] then
                    if isColorValue(self.gameMEM.LVL.screen[renderX + (j - 1)][renderY + (i - 1)]) and not textBackgroundColorSet then
                        if self.gameMEM.monitor then
                            self.gameMEM.monitor.setBackgroundColor(self.gameMEM.LVL.screen[renderX + (j - 1)][renderY + (i - 1)])
                        else
                            term.setBackgroundColor(self.gameMEM.LVL.screen[renderX + (j - 1)][renderY + (i - 1)])
                        end
                    end
                end
                if self.gameMEM.monitor then
                    self.gameMEM.monitor.write(string.sub(textOut, j, j))
                else
                    term.write(string.sub(textOut, j, j))
                end
            end
            textColorPos = textColorPos + #textOut
        end
    end
end

function gameLib:updateRenderLists()

    self.gameMEM.objects.render.renderList.backgroundHolograms={}
    for i=1,#self.gameMEM.objects.render.list.backgroundHolograms do
        if self.gameMEM.objects.render.list.backgroundHolograms[i] ~= nil then
            self.gameMEM.objects.render.renderList.backgroundHolograms[self.gameMEM.objects.render.list.backgroundHolograms[i][2]] = self.gameMEM.objects.render.list.backgroundHolograms[i][1]
        end
    end
    self.gameMEM.objects.render.listLen.backgroundHolograms = #self.gameMEM.objects.render.list.backgroundHolograms

    self.gameMEM.objects.render.renderList.sprites={}
    for i=1,#self.gameMEM.objects.render.list.sprites do
        if self.gameMEM.objects.render.list.sprites[i] ~= nil then
            self.gameMEM.objects.render.renderList.sprites[self.gameMEM.objects.render.list.sprites[i][2]] = self.gameMEM.objects.render.list.sprites[i][1]
        end
    end
    self.gameMEM.objects.render.listLen.sprites = #self.gameMEM.objects.render.list.sprites

    self.gameMEM.objects.render.renderList.holograms={}
    for i=1,#self.gameMEM.objects.render.list.holograms do
        if self.gameMEM.objects.render.list.holograms[i] ~= nil then
            self.gameMEM.objects.render.renderList.holograms[self.gameMEM.objects.render.list.holograms[i][2]] = self.gameMEM.objects.render.list.holograms[i][1]
        end
    end
    self.gameMEM.objects.render.listLen.holograms = #self.gameMEM.objects.render.list.holograms
end

--gameFrameWork based functions

---creates a framework for a 2D game
---@param gameName any name of the game given to the game.gameName
---@param useMonitor boolean|nil if true will make the game render on a connected monitor. defaults to false if not provided
---@param pixelSize number|nil is the size of a pixel on a monitor can range from 0.5 to 5 (REQUIRES MONITOR)
---@param monitorFilter table|nil is the name of the monitor that gets picked (REQUIRES MONITOR)
---@param screenStartX number|nil is the X coordinate at which the render starts, defaults to 1 if not provided
---@param screenStartY number|nil is the Y coordinate at which the render starts, defaults to 1 if not provided
---@param screenEndX number|nil is the X coordinate at which the render ends, defaults to output object width if not provided
---@param screenEndY number|nil is the Y coordinate at which the render ends, defaults to output object height if not provided
---@return metatable gameENV an object which is the game Framework
function gameLib:create(gameName,useMonitor,monitorFilter,pixelSize,screenStartX,screenStartY,screenEndX,screenEndY)
    -- Initialize gameENV as an empty table
    local gameENV = {}

    screenStartX = screenStartX or 1
    screenStartY = screenStartY or 1

    local width, height
    local monitor
    if useMonitor then
        monitor = peripheral.find("monitor",function(name, monitor)
            if monitorFilter then 
                for i =1,#monitorFilter do
                    if name == monitorFilter[i] then
                        return true
                    end
                end
                return false
            end
            return true
        end)

        if not monitor then
            if monitorFilter then
                error("could not find monitor, make sure that a monitor named:"..textutils.serialise(monitorFilter,{compact=true}).." is attached or disable the useMonitor variable")
            else
                error("could not find monitor, make sure that a monitor is attached or disable the useMonitor variable")
            end
        end

        if type(pixelSize) == "number" then
            if pixelSize >= 0.5 and pixelSize <= 5 then 
                monitor.setTextScale(pixelSize) 
            else
                error("Screen size must be in range of 0.5 to 5")
            end
        end

        width, height = monitor.getSize()
    else
        width, height = term.getSize()
    end

    screenEndX = screenEndX or width
    screenEndY = screenEndY or height

    -- GameName is either passed in or defaults
    local gameName = tostring(gameName) or "Game"  

    -- Initialize gameMEM as a table with LVL
    gameENV.gameMEM = {LVL={background={}}}
    for i = 1,width do
        gameENV.gameMEM.LVL.background[i] = {}
        for j = 1,height do
            --set black as default background
            gameENV.gameMEM.LVL.background[i][j] = colors.black
        end
    end

    setmetatable(gameENV, self)
    -- Ensure __index is set
    self.__index = self

    local tablesToRegister={"objects.render.list.","objects.render.renderList."}
    for i=1,#tablesToRegister do
        gameENV:createSubTables(tablesToRegister[i].."backgroundHolograms")
        gameENV:createSubTables(tablesToRegister[i].."sprites")
        gameENV:createSubTables(tablesToRegister[i].."holograms")
    end

    gameENV:createSubTables("groups.list")
    gameENV:createSubTables("spriteClones.list")
    gameENV:createSubTables("hologramClones.list")
    gameENV:createSubTables("LVL.screen")
    gameENV:createSubTables("dataFileCache.clones")
    gameENV:createSubTables("objects.render.subTasks")

    gameENV:setGameMEMValue("objects.render.listLen.backgroundHolograms",-1)
    gameENV:setGameMEMValue("objects.render.listLen.sprites",-1)
    gameENV:setGameMEMValue("objects.render.listLen.holograms",-1)

    gameENV:setGameMEMValue("gameName",gameName)
    gameENV:setGameMEMValue("screenWidth",screenEndX-(screenStartX-1))
    gameENV:setGameMEMValue("screenHeight",screenEndY-(screenStartY-1))
    gameENV:setGameMEMValue("renderStartX",screenStartX-1)
    gameENV:setGameMEMValue("renderStartY",screenStartY-1)
    gameENV:setGameMEMValue("renderEndX",screenEndX)
    gameENV:setGameMEMValue("renderEndY",screenEndY)
    gameENV:setGameMEMValue("monitor",monitor)

    return gameENV
end

---ends the game and removes the framework
---@param restart boolean|nil if true restarts the computer otherwise just resets the terminal/monitor. If not provided defaults to false
function gameLib:quit(restart,exitMessage,exitMessageColor)
    if type(restart) ~= "boolean" then
        restart=false
    end

    if not isColorValue(exitMessageColor)  then
        exitMessageColor = colors.white
    end

    if self.gameMEM.monitor then
        self.gameMEM.monitor.setTextScale(1)
    end

    if not restart then
        if self.gameMEM.monitor then
            self.gameMEM.monitor.clear()
            self.gameMEM.monitor.setCursorPos(1,1)
        end
        term.clear()
        term.setCursorPos(1,1)
        if exitMessage then
            local currentTextColor= term.getTextColor()
            term.write(self.gameMEM.gameName..": ")
            term.setTextColor(exitMessageColor)
            print(exitMessage)
            term.setTextColor(currentTextColor)
        end
        setmetatable(self, {
            __index = function()
                return
            end
        })
        sleep(0.2)
    else
        os.reboot()
    end
end

---lets you load in game assets from a .data(.html and .xml mix: tag based) notation file. Will return an error if the .data file has invalid data or something went wrong whilst adding or grouping objects
---@param fileDir string the directory of the file that you want to load
function gameLib:useDataFile(fileDir)

    if not fs.exists(fileDir) then error("'"..tostring(fileDir).."' is not an existing File") return end

    local index={data={"<body>","</body>" , "<background>","</background>","<sprites>","</sprites>","<clones>","</clones>","<holograms>","</holograms>","<groups>","</groups>" , "<object>","</object>","<image>","</image>","<br>"}, lua={"{","}" , "background={","},","sprites={","},","clones={","},","holograms={","},","groups={","}," , "{","},","{{","}}","},{"}}
    local output = ""
    local fileOver = false

    for line in io.lines(fileDir) do
        if not fileOver then
            for i=1,#index.data do
                if string.find(line,"</body>",nil,true) then
                    fileOver=true
                end
            line = string.gsub(line,index.data[i],index.lua[i])
            end

            while string.find(line,"<",nil,true) do
                local startTag=string.find(line,"<",nil,true) or 1
                local stopTag =string.find(line,">",nil,true) or #line

                line = string.gsub(line, string.sub(line,startTag,stopTag), "")
            end

        else
            line=""
        end

        output = output .. line
    end

    if textutils.unserialise(output) then
        output = textutils.unserialise(output)
    else
        error("'"..tostring(fileDir).."' doesn't contain valid Data!")
    end

    if output.background then
        self:setBackgroundImage(output.background[1])
    end
    if output.sprites then
        for i=1,#output.sprites do
            self:addSprite(output.sprites[i][1],output.sprites[i][2],output.sprites[i][3],output.sprites[i][4],output.sprites[i][5],output.sprites[i][6])
        end
    end
    if output.clones then
        self:setGameMEMValue("dataFileCache.clones",output.clones)
    end
    if output.holograms then
        for i=1,#output.holograms do
            self:addHologram(output.holograms[i][1],output.holograms[i][2],output.holograms[i][3],output.holograms[i][4],output.holograms[i][5],output.holograms[i][6],output.holograms[i][7],output.holograms[i][8],output.holograms[i][9],output.holograms[i][10])
        end
    end
    if output.groups then
        for i=1,#output.groups do
            self:groupObjects(output.groups[i][1],output.groups[i][2])
        end
    end
end

---lets you take all objects & groups and turn them into a .data(.html and .xml mix: tag based) file
---@param fileDir string is the directory where the file will be saved
---@param compact boolean|nil if true will compact the content into one line useful for space saving otherwise uses indentation for readability. defaults to false if not provided
function gameLib:makeDataFile(fileDir,compact)

    --phase 1: fetch data and compile list!

    local data = {}

    if self:isSubTable("LVL.background") then

        data.background={}

        for i=1,#self.gameMEM.LVL.background do
            data.background[i]={}
            for j=1,table.maxn(self.gameMEM.LVL.background[i]) do
                data.background[i][j] = self.gameMEM.LVL.background[i][j]
            end
        end
    end

    if #self.gameMEM.objects.render.list.sprites > 0 then

        data.sprites={}

        local list = self.gameMEM.objects.render.list.sprites

        for i=1,#self.gameMEM.objects.render.list.sprites do

            local node = self:getSubTable(list[i][1])

            if node and node.type == "sprite" then
                table.insert(data.sprites, {list[i][1], node.sprite, list[i][2], node.x, node.y})
            elseif node and node.type == "spriteClone" then
                if data.clones == nil then
                    data.clones ={}
                end

                table.insert(data.clones, {node.sprite, list[i][2], node.x, node.y, node.isGrouped})
            end
        end
    end

    if #self.gameMEM.objects.render.list.holograms > 0 then

        data.holograms={}
        local list = self.gameMEM.objects.render.list.holograms

        for i=1,#self.gameMEM.objects.render.list.holograms do


            local node = self:getSubTable(list[i][1])
            local textOut

            if node and node.type == "hologram" then
                for j=1, #node.text do

                    if j ~= 1 then
                        textOut = textOut .. node.text[j]
                    else
                        textOut = node.text[j]
                    end


                end

                table.insert(data.holograms, {list[i][1], textOut, node.textColor, node.textBackgroundColor, list[i][2], node.x, node.y})
            elseif node and node.type == "hologramClone" then
                if data.clones == nil then
                    data.clones ={}
                end
                
                table.insert(data.clones, {node.text, list[i][2], node.x, node.y, node.isGrouped})
            end
        end
    end

    if #self.gameMEM.objects.render.list.backgroundHolograms > 0 then

        if not data.holograms then
            data.holograms={}
        end
        local list = self.gameMEM.objects.render.list.backgroundHolograms

        for i=1,#self.gameMEM.objects.render.list.backgroundHolograms do

            local node = self:getSubTable(list[i][1])
            local textOut

            if node and node.type == "hologram" then
                for j=1, #node.text do

                    if j ~= 1 then
                        textOut = textOut .. " " .. node.text[j]
                    else
                        textOut = node.text[j]
                    end

                end

                table.insert(data.holograms, {list[i][1], textOut, node.textColor, node.textBackgroundColor, list[i][2], node.x, node.y, false})
            elseif node and node.type == "hologramClone" then
                if data.clones == nil then
                    data.clones ={}
                end
                
                table.insert(data.clones, {node.text, list[i][2], node.x, node.y, node.isGrouped})
            end
        end
    end

    if self:isSubTable("groups.list") then

        data.groups = {}
        local list = self.gameMEM.groups.list

        for i=1,#self.gameMEM.groups.list do

            local node = self:getSubTable(list[i])

            if node then
                table.insert(data.groups, {list[i], node.lvlTable})
            end
        end
    end

    --phase 2: compile and write the .data(xml like) file

    local file=io.open(fileDir,"w")

    writeToFile(file,"<body>",0,true,compact)

    if data.background then

        local backgroundString=textutils.serialise(data.background,{compact=true})

        writeToFile(file,"<background>",1,true,compact)

        backgroundString = string.gsub(backgroundString, "{{","<image>")

        while string.find(backgroundString,"},{",nil,true) do
            backgroundString=string.gsub(backgroundString,"},{","<br>")
        end

        backgroundString = string.gsub(backgroundString, "},}","</image>")

        writeToFile(file,backgroundString,2,true,compact)
        writeToFile(file,"</background>",1,true,compact)
    end

    if data.sprites  then
        writeToFile(file,"<sprites>",1,true,compact)
        for i=1,#data.sprites do
            writeToFile(file,"<object>",2,true,compact)
            if not compact then
                file:write("            ")
            end

            for j=1,6 do

                if type(data.sprites[i][j]) == "string" then

                    file:write("\""..tostring(data.sprites[i][j]).."\", ")
                elseif type(data.sprites[i][j]) == "table" then

                    local imageString=textutils.serialise(data.sprites[i][j],{compact=true})

                    imageString = string.gsub(imageString, "{{","<image>")

                    while string.find(imageString,"},{",nil,true) do
                        imageString=string.gsub(imageString,"},{","<br>")
                    end

                    imageString = string.gsub(imageString, "},}","</image>")
                    file:write(imageString..", ")
                else

                    file:write(tostring(data.sprites[i][j])..", ")
                end
            end
            if not compact then
                file:write("\n")
            end
            writeToFile(file,"</object>",2,true,compact)
        end
        writeToFile(file,"</sprites>",1,true,compact)
    end

    if data.holograms then
        writeToFile(file,"<holograms>",1,true,compact)

        for i=1,#data.holograms do

            writeToFile(file,"<object>",2,true,compact)
            if not compact then
                file:write("            ")
            end

            for j=1,10 do

                if type(data.holograms[i][j]) == "string" then

                    file:write("\""..data.holograms[i][j].."\", ")
                elseif type(data.holograms[i][j]) == "table" then

                    file:write(textutils.serialise(data.holograms[i][j],{compact=true})..", ")
                else

                    file:write(tostring(data.holograms[i][j])..", ")
                end
            end
            writeToFile(file,"",0,true,compact)
            writeToFile(file,"</object>",2,true,compact)
        end
        writeToFile(file,"</holograms>",1,true,compact)
    end

    if data.clones  then
        writeToFile(file,"<clones>",1,true,compact)
        for i=1,#data.clones do
            writeToFile(file,"<object>",2,true,compact)
            if not compact then
                file:write("            ")
            end

            for j=1,6 do

                if type(data.clones[i][j]) == "string" then

                    file:write("\""..tostring(data.clones[i][j]).."\", ")
                else

                    file:write(tostring(data.clones[i][j])..", ")
                end
            end
            if not compact then
                file:write("\n")
            end
            writeToFile(file,"</object>",2,true,compact)
        end
        writeToFile(file,"</clones>",1,true,compact)
    end

    if data.groups then
        writeToFile(file,"<groups>",1,true,compact)

        for i=1,#data.groups do

            writeToFile(file,"<object>",2,true,compact)
            if not compact then
                file:write("            ")
            end

            for j=1,2 do

                if type(data.groups[i][j]) == "string" then

                    file:write("\""..data.groups[i][j].."\", ")
                elseif type(data.groups[i][j]) == "table" then
                    file:write("<object> ")
                    for k=1,#data.groups[i][j] do
                        file:write("\""..tostring(data.groups[i][j][k]).."\", ")
                    end
                    writeToFile(file,"</object>",0,true,compact)
                end
            end

            writeToFile(file,"</object>",2,true,compact)
        end

        writeToFile(file,"</groups>",1,true,compact)
    end

    writeToFile(file,"</body>",0,false,compact)
    --file:write("\n\n",textutils.serialise(data.sprites,{compact=true}),"\n",textutils.serialise(self.gameMEM.LVL.background,{compact=true}))
    file:close()
end


--self.gameMEM based functions

---lets you set a value in the Game Matrix/Memory to save values that are accessible to the gameLib
---@param lvl string is a string that gives it the hierarchy e.g: "test.string"
---@param value any is the value that in our case 'test.string' is set to e.g: value="hello world" --> self.gameMEM.test.string="hello world"
function gameLib:setGameMEMValue(lvl, value)

    local node, keys = self:getSubTable(lvl,false)

    node[keys[#keys]] = value
end

---lets you look inside the self.gameMEM hierarchy
---@param place string|nil place to look in the self.gameMEM hierarchy
---@return table table will return all values from the given place on in the hierarchy or self.gameMEM if place is nil
function gameLib:getGameMEMValue(place)
    if place ~= nil then
        local keys = {}

        for key in place:gmatch("[^.]+") do
            table.insert(keys, key)
        end

        local node = self.gameMEM

        for i = 1, #keys - 1 do
            local key = keys[i]
            if node[key] == nil then
                return {}
            end
            node = node[key]
        end

        return node[keys[#keys]]
    else
        return self.gameMEM
    end
end

--image based functions

---lets you load in a .nfp correctly!
---@param imgDir string is the path that get's loaded as image table
---@return table image the image as Matrix made of color values
function gameLib:loadImage(imgDir)
    if not fs.exists(imgDir) then error("'"..tostring(imgDir).."' is not an existing File") return end

    --make a matrix out of the imageFile's Content
    local img={}
    local fileLines = getFileLines(imgDir)
    for i=1,#fileLines do
        if img[i] == nil then
            img[i]={}
        end
        for j=1,#fileLines[i] do
            if type(fileLines[i]) == "string" then
                table.insert(img[i],string.sub(fileLines[i],j,j))
            end
        end
    end

    --convert from '0123456789abcdef' to colorValue
    local newImg={}
    for i=1,#img do
        for j=1,table.maxn(img[i]) do
            if newImg[j] == nil then
                newImg[j]={}
            end
            newImg[j][i]=colors.fromBlit(img[i][j])
        end
    end

    --return image Matrix
    return newImg
end

---generates a sprite of geometric shapes
---@param shape string|nil is the geometric shape which you want ot generate a sprite for e.g: "circle","triangle","square"
---@param width number|nil is the width/radius(if it's a circle) of the shape must be provided for shapes: "square" & "circle"
---@param height number|nil is the height of the shape must be provided for shapes: "square" & "triangle"
---@param color number is the color of the shape
---@param rightAngled boolean|nil will make a triangle right angled. Will default to false if not provided
---@param side string|nil will determine if the upper or lower half of the right angled triangle is given. Will default to "lower" if not provided
---@return table img is the image matrix of the shape
function gameLib:getShapeSprite(shape,width,height,color,rightAngled,side)
    local shapeSprite = {}

    if shape == "circle" then
        local center = width + 1

        for i= 1, 2*width + 1 do
            shapeSprite[i]={}
            for j= 1, 2*width+1 do
                local dx = j - center
                local dy = i - center
                if dx * dx + dy * dy <= width * width then
                    shapeSprite[i][j] = color
                end
            end
        end
    elseif shape == "triangle" then
        if rightAngled then

            for i = 1, height do
                shapeSprite[i] = {}
                for j = 1, height do
                    if j <= i and (not side) or side == "upper" then
                        shapeSprite[i][j] = color
                    elseif j >= i and side then
                        shapeSprite[i][j] = color
                    end
                end
            end
        else
            shapeSprite = {}
            local centerX = height

            for i = 1,height do
                for j = 1,height * 2 do
                    if not shapeSprite[j] then
                        shapeSprite[j] = {}
                    end
                    if j >= centerX - (i-1) and j<= centerX + (i-1) then
                        shapeSprite[j][i] = color
                    end
                end
            end
        end
    else
        for i=1,width do
            shapeSprite[i]={}
            for j=1,height do
                shapeSprite[i][j]=color
            end
        end
    end

    return shapeSprite
end

---lets you turn the given sprite in increments of 90 Degrees by the number of times you inputted
---@param sprite table is the sprite that gets turned
---@param times number is the amount of times it will iterate of rotations of 90 degrees
---@return table sprite is the rotated matrix of the sprite
function gameLib:turnSprite(sprite, times)
    if not sprite then error("the sprite variable has to be a 2D Image(Matrix)") end
    if type(times) ~= "number" then times = 0 end

    times = times % 4  -- Only need 0 to 3 turns

    for _ = 1, times do
        local rotated = {}
        local rows = #sprite
        local maxCol = 0
        for i = 1, #sprite do
            maxCol = math.max(maxCol, #sprite[i])
        end

        for x = 1, maxCol do
            rotated[x] = {}
            for y = rows, 1, -1 do
            rotated[x][rows - y + 1] = sprite[y][x] or nil
            end
        end

        sprite={}
        for i=1,#rotated do
            sprite[i]={}
            for j=1,table.maxn(rotated[i]) do
                sprite[i][j] = rotated[i][j]
            end
        end
    end

    return sprite
end



---lets you set a background via gameLib:loadImage advised to be the length & width of the terminal
---@param img table matrix give by gameLib:loadImage
function gameLib:setBackgroundImage(img)
    self.gameMEM.LVL.background=img
end

--object based functions

---adds a Sprite to the render
---@param lvl string is a string that gives it the hierarchy e.g: "test.string"
---@param img table is the sprite of the game as matrix can be loaded using gameLib:loadImage
---@param priority number|nil level of priority when rendering will default to the highest when nil higher priority gets rendered over lower
---@param x number|nil X position of the Sprite (will start rendering at that x pos). defaults to 1 if not provided
---@param y number|nil Y position of the sprite (will start rendering at that y pos). defaults to 1 if not provided
---@param screenBound boolean|nil if false the object can go as far off screen as it wants. defaults to true if not provided
function gameLib:addSprite(lvl,img,priority,x,y,screenBound)

    if screenBound == nil then screenBound = true end

    if type(img) ~= "table" then error("image has to be a table ('"..type(img).."' was supplied)") end

    if type(priority) ~= "number" then
        priority=#self.gameMEM.objects.render.list.sprites+1
    end
    if type(x) ~= "number" then
        x=1
    end
    if type(y) ~= "number" then
        y=1
    end
    if (x < 1-#img or x > self.gameMEM.screenWidth) and screenBound then
        x=1
    end
    if (y < 1-table.maxn(img[1]) or y > self.gameMEM.screenHeight) and screenBound then
        y=1
    end

    local node, keys=self:getSubTable(lvl,false)

    -- Assign value at the deepest key
    node[keys[#keys]] = {type="sprite", sprite=img, x=math.floor(x), y=math.floor(y), screenBound = toboolean(screenBound), elementNum=#self.gameMEM.objects.render.list.sprites+1}
    table.insert(self.gameMEM.objects.render.list.sprites,{lvl,priority})
end

---adds a Hologram/Text to the render
---@param lvl string is a string that gives it the hierarchy e.g: "test.string"
---@param text string is the text that is going to be displayed
---@param textColor table|nil is the text color of the displayed Text. If nil defaults to colors.white
---@param textBackgroundColor table|nil is the background color of the displayed Text. If not supplied will render with background Color of background
---@param priority number|nil level of priority when rendering will default to the highest when nil higher priority gets rendered over lower
---@param x number|nil X position of the Hologram (will print at that x pos). defaults to 1 if not provided
---@param y number|nil Y position of the Hologram (will print at that y pos). defaults to 1 if not provided
---@param dynamic boolean|nil if false will render it behind every sprite but it can not adjust to the sprite background colors. doesn't change the way it collides! will default to true if not provided
---@param wrapped boolean|nil if false won't wrap the text when to big (smart wrapping: wraps at last space if there is one in the current line otherwise wraps to screen size). will default to true if not provided
---@param screenBound boolean|nil if false the object can go as far off screen as it wants. defaults to true if not provided
function gameLib:addHologram(lvl,text,textColor,textBackgroundColor,priority,x,y,dynamic,wrapped,screenBound)

    if dynamic == nil then dynamic = true end
    if wrapped == nil then wrapped = true end
    if screenBound == nil then screenBound = true end

    self:createSubTables("objects.render.list.holograms")

    if type(priority) ~= "number" then
        if dynamic then
            priority=#self.gameMEM.objects.render.list.holograms+1
        else
            priority=#self.gameMEM.objects.render.list.backgroundHolograms+1
        end
    end
    if type(x) ~= "number" then
        x=1
    end
    if type(y) ~= "number" then
        y=1
    end
    if type(textColor) ~= "table" then
        textColor={white=1}
    end
    if type(textBackgroundColor) ~= "table" then
        textBackgroundColor = nil
    end
    local textOut, textMaxWidth, correctionsCycles, elementNum
    if wrapped then correctionsCycles=3 else correctionsCycles = 1 end

    for i=1,correctionsCycles do
        if wrapped then
            textOut, textMaxWidth = self:wrapHologramText(text,x)
        else
            textOut = {text}
            textMaxWidth = #text
        end

        if (x < 1-textMaxWidth or x > self.gameMEM.screenWidth) and screenBound then
            x=1
        end
        if (y < 1 or y > self.gameMEM.screenHeight) and screenBound then
            y=1
        end
    end

    if dynamic then
        elementNum = #self.gameMEM.objects.render.list.holograms+1
    else
        elementNum = #self.gameMEM.objects.render.list.backgroundHolograms+1
    end

    local node, keys=self:getSubTable(lvl,false)

    node[keys[#keys]] = {type="hologram", dynamic=dynamic, text=textOut, textMaxWidth=textMaxWidth, textColor=textColor, textBackgroundColor=textBackgroundColor, x=math.floor(x), y=math.floor(y), screenBound = toboolean(screenBound), elementNum=elementNum, wrapped = toboolean(wrapped)}
    if dynamic then
        table.insert(self.gameMEM.objects.render.list.holograms,{lvl,priority})
    else
        table.insert(self.gameMEM.objects.render.list.backgroundHolograms,{lvl,priority})
    end
end

---lets you manipulate all data of an existing Sprite
---@param lvl string is a string that gives it the hierarchy e.g: "test.string"
---@param img table|nil is the sprite that will be displayed can be loaded from .nfp file through gameLib:loadImage won't change if not supplied
---@param x number|nil X position on screen that it starts to be rendered at. Won't change if not supplied
---@param y number|nil Y position on screen that it starts to be rendered at. Won't change if not supplied
---@param screenBound boolean|nil if false the object can go as far off screen as it wants. defaults to true if not provided
function gameLib:changeSpriteData(lvl,img,x,y,screenBound)
    self:createSubTables(lvl)

    local node = self:getSubTable(lvl)

    if screenBound ~= nil then node.screenBound = toboolean(screenBound) end

    if node.sprite then
        if type(x) == "number" then
            if not (x < 2-#node.sprite) and not (x > self.gameMEM.screenWidth) then
                node.x = math.floor(x)
            elseif not node.screenBound then
                node.x = math.floor(x)
            end
        end
        if type(y) == "number" then
            if not (y < 2-table.maxn(node.sprite[1])) and not (y > self.gameMEM.screenHeight) then
                node.y = math.floor(y)
            elseif not node.screenBound then
                node.y = math.floor(y)
            end
        end
    end
    if type(img) =="table" and node.sprite then
        node.sprite = img
    end
end

--lets you manipulate all data fo an existing Hologram
---@param lvl string is a string that gives it the hierarchy e.g: "test.string"
---@param text string|nil is the text that is being displayed. Won't change if not supplied
---@param textColor table|nil is the color of the displayed text won't change if not supplied
---@param textBackgroundColor table|nil is the background color of the text that is being displayed. Won't change if not supplied
---@param x number|nil X position on screen that it gets written at. Won't change if not supplied
---@param y number|nil Y position on screen that it gets written at. Won't change if not supplied
---@param screenBound boolean|nil if false the object can go as far off screen as it wants. defaults to true if not provided
function gameLib:changeHologramData(lvl,text,textColor,textBackgroundColor,x,y,wrapped,screenBound)
    self:createSubTables(lvl)

    local node = self:getSubTable(lvl)

    if wrapped == nil then wrapped = node.wrapped end
    if screenBound ~= nil then node.screenBound = toboolean(screenBound) end

    -- Traverse the table, creating sub-tables as needed

    local correctionsCycles
    if wrapped then correctionsCycles=3 else correctionsCycles = 1 end

    for i=1,correctionsCycles do
        if node.text ~= nil then
            if type(x) == "number" then
                if not (x < 2-node.textMaxWidth) and not (x > self.gameMEM.screenWidth) then
                    node.x = math.floor(x)
                elseif not node.screenBound then
                    node.x = math.floor(x)
                end
            end
            if type(y) == "number" then
                if not (y < 1) and not (y > self.gameMEM.screenHeight) then
                    node.y = math.floor(y)
                elseif not node.screenBound then
                    node.y = math.floor(y)
                end
            end
        end

        if text then
            if wrapped then
                node.text, node.textMaxWidth = self:wrapHologramText(text,node.x)
            else
                node.text = {text}
                node.textMaxWidth = #text
            end
        end
    end

    if type(textColor) == "table" then
        node.textColor = textColor
    end
    if type(textBackgroundColor) == "table" then
        node.textBackgroundColor = textBackgroundColor
    end
end

---allows you to make a clone of a sprite this wll create a object that share the same texture as it's parent object
---@param lvl string is the string that gives it the hierarchy to clone e.g:"test.string" (only sprites)
---@param priority number|nil level of priority when rendering will default to the highest when nil higher priority gets rendered over lower. can not be the priority of thr original sprite
---@param x number|nil X position of the Sprite (will start rendering at that x pos). defaults to 1 if not provided
---@param y number|nil Y position of the Sprite (will start rendering at that x pos). defaults to 1 if not provided
---@param groupClones boolean|nil if true will create/add objects to a group named: lvl+".spriteClone.group"  (e.g: "test.string.spriteClone.group") consisting of the parent object and all it's spriteClones (useful for checking for collisions of parent and spriteClones). defaults to false if not provided
---@param screenBound boolean|nil if false the object can go as far off screen as it wants. defaults to true if not provided
function gameLib:cloneObject(lvl,priority,x,y,groupClones,screenBound)

    if screenBound == nil then screenBound = true end
    
    local cloneObj, name
    local node =self:getSubTable(lvl)

    if not node then return end
    if node.type == "spriteClone" or node.type == "hologramClone" or node.type == "group" then error("input object can't be a clone/group Object") end

    self:updateRenderLists()

    if node.type == "sprite" then
        if type(priority) ~= "number" then
            priority=#self.gameMEM.objects.render.list.sprites+1
        end

        if self.gameMEM.objects.render.renderList.sprites[priority] == lvl then error("can't override the original object") end

        local img = node.sprite

        if type(x) ~= "number" then
            x=1
        end
        if type(y) ~= "number" then
            y=1
        end
        if (x < 1-#img or x > self.gameMEM.screenWidth) and screenBound then
            x=1
        end
        if (y < 1-table.maxn(img[1]) or y > self.gameMEM.screenHeight) and screenBound then
            y=1
        end

        self:createSubTables("spriteClones.list."..lvl)

        cloneObj = self:getSubTable("spriteClones.list."..lvl)

        name = lvl..".clone"..#cloneObj+1

        if groupClones and not self:isSubTable(lvl..".clone.group") then
            self:groupObjects(lvl..".clone.group",{lvl,name})
        elseif groupClones then
            self:addObjectToGroup(lvl..".clone.group",{name})
        end

        local node, keys=self:getSubTable(name,false)

        node[keys[#keys]]={type="spriteClone", sprite=lvl, x=math.floor(x), y=math.floor(y), screenBound = toboolean(screenBound), elementNum=#self.gameMEM.objects.render.list.sprites+1, isGrouped=toboolean(groupClones)}
        table.insert(self.gameMEM.objects.render.list.sprites,{name,priority})

    elseif node.type == "hologram" then

        local dynamic, wrapped, textMaxWidth = node.dynamic, node.wrapped, node.textMaxWidth
        local textColor, textBackgroundColor

        if type(priority) ~= "number" then
            if dynamic then
                priority=#self.gameMEM.objects.render.list.holograms+1
            else
                priority=#self.gameMEM.objects.render.list.backgroundHolograms+1
            end
        end

        if self.gameMEM.objects.render.renderList.holograms[priority] == lvl then error("can't override the original object") end

        if type(x) ~= "number" then
            x=1
        end
        if type(y) ~= "number" then
            y=1
        end
        if type(textColor) ~= "table" then
            textColor={white=1}
        end
        if type(textBackgroundColor) ~= "table" then
            textBackgroundColor = nil
        end
        local correctionsCycles, elementNum
        if wrapped then correctionsCycles=3 else correctionsCycles = 1 end

        for i=1,correctionsCycles do

            if (x < 1-textMaxWidth or x > self.gameMEM.screenWidth) and screenBound then
                x=1
            end
            if (y < 1 or y > self.gameMEM.screenHeight) and screenBound then
                y=1
            end
        end

        self:createSubTables("hologramClones.list."..lvl)

        cloneObj = self:getSubTable("hologramClones.list."..lvl)

        name = lvl..".clone"..#cloneObj+1

        if groupClones and not self:isSubTable(lvl..".clone.group") then
            self:groupObjects(lvl..".clone.group",{lvl,name})
        elseif groupClones then
            self:addObjectToGroup(lvl..".clone.group",{name})
        end

        if dynamic then
            elementNum = #self.gameMEM.objects.render.list.holograms+1
        else
            elementNum = #self.gameMEM.objects.render.list.backgroundHolograms+1
        end

        local node, keys=self:getSubTable(name,false)

        node[keys[#keys]] = {type="hologramClone", dynamic=dynamic, text=lvl, textMaxWidth=textMaxWidth, x=math.floor(x), y=math.floor(y), screenBound = toboolean(screenBound), elementNum=elementNum, wrapped = wrapped, isGrouped=toboolean(groupClones)}
        if dynamic then
            table.insert(self.gameMEM.objects.render.list.holograms,{name,priority})
        else
            table.insert(self.gameMEM.objects.render.list.backgroundHolograms,{name,priority})
        end
    end

    if cloneObj then
        table.insert(cloneObj,name)
        if name then
            return true
        end
    end
end

---lets you group objects together. They will still render separately and their behavior won't change at all. Is useful if you want to check for multiple collisions at once or change common data for all objects. !!! WARNING: groups can contain groups may have impact on other functions like gameLib:isColliding or gameLib:changeGroupData !!!
---@param groupLvl string is a string that gives it the hierarchy e.g: "test.string"
---@param lvlTable table is a table of object (= sprites, holograms, clones) hierarchies that are a part of this group e.g: "test.string","test.number",ect...
function gameLib:groupObjects(groupLvl,lvlTable)
    self:createSubTables(groupLvl)

    local node, keys = self:getSubTable(groupLvl,false)

    node[keys[#keys]] = {type="group", lvlTable=lvlTable}

    table.insert(self.gameMEM.groups.list,groupLvl)
end

---lets you add a table of objects to an already existing group
---@param groupLvl string is a string that gives it the hierarchy e.g: "test.string"
---@param lvlTable table is a table of object (= sprites, holograms, clones) hierarchies that get added to this group e.g: "test.string","test.number",ect...
function gameLib:addObjectToGroup(groupLvl,lvlTable)
    self:createSubTables(groupLvl)

    local node = self:getSubTable(groupLvl)

    if not node.lvlTable then error("Can't modify non existing group") end

    for i=1,table.maxn(lvlTable) do

        table.insert(node.lvlTable,lvlTable[i])
    end
end

---lets you change common data of objects (=sprites, hologram, clones)
---@param groupLvl string is a string that gives it the hierarchy e.g: "test.string"
---@param x number|nil is the number that is added to/subtracted(if negative) from the objects X coordinate
---@param y number|nil is the number that is added to/subtracted(if negative) from the objects Y coordinate
function gameLib:changeGroupData(groupLvl,x,y)
    self:createSubTables(groupLvl)

    local node = self:getSubTable(groupLvl)

    if not node.lvlTable then error("Can't modify non existing group") end

    local groupList = node.lvlTable

    for i=1,table.maxn(groupList) do
        self:createSubTables(groupList[i])

        local obj = self:getSubTable(groupList[i])

        if type(x) == "number" and obj.x and not (obj.x+x < 1) and not obj.x+x > self.gameMEM.screenWidth then
            --modifies unlike gameLib:changeSpriteData
            obj.x = math.floor(obj.x + x)
        elseif type(x) == "number" and not node.screenBound then
            obj.x = math.floor(x)
        end

        if type(x) == "number" and obj.y and not (obj.y+y < 1) and not obj.y+y > self.gameMEM.screenHeight then
            --modifies unlike gameLib:changeSpriteData
            obj.y = math.floor(obj.y + y)
        elseif type(x) == "number" and not node.screenBound then
            obj.y = math.floor(y)
        end
    end
end

---lets you remove objects from the render !!!Will delete all object data!!!
---@param lvl string is a string that gives it the hierarchy to remove e.g: "test.string"
function gameLib:removeObject(lvl)
    self:createSubTables("objects.render.list.sprites")
    self:createSubTables("objects.render.list.holograms")
    local node = self:getSubTable(lvl)

    if not node then return end

    if node.type == "sprite" or node.type == "spriteClone" then
        if self:isSubTable("spriteClones.list."..lvl) then
            local spriteCloneList = self:getSubTable("spriteClones.list."..lvl)
            for i= 1, #spriteCloneList do
                self:removeObject(spriteCloneList[i])
            end
        end
        if 0 < #self.gameMEM.objects.render.list.sprites then
            for i=1,#self.gameMEM.objects.render.list.sprites do
                if type(self.gameMEM.objects.render.list.sprites[i]) == "table" then
                    if self.gameMEM.objects.render.list.sprites[i][1] == lvl then
                        table.remove(self.gameMEM.objects.render.list.sprites,i)
                    end
                end
            end
        end
    elseif node.type == "hologram" or node.type == "hologramClone" then
        if self:isSubTable("hologramClones.list."..lvl) then
            local hologramCloneList = self:getSubTable(lvl)
            for i=1, #hologramCloneList do
                self:removeObject(hologramCloneList[i])
            end
        end
        if node.dynamic then
            if 0 < #self.gameMEM.objects.render.list.holograms then
                for i=1,#self.gameMEM.objects.render.list.holograms do
                    if type(self.gameMEM.objects.render.list.holograms[i]) == "table" then
                        if self.gameMEM.objects.render.list.holograms[i][1] == lvl then
                            table.remove(self.gameMEM.objects.render.list.holograms,i)
                        end
                    end
                end
            end
        else
            if 0 < #self.gameMEM.objects.render.list.backgroundHolograms then
                for i=1,#self.gameMEM.objects.render.list.backgroundHolograms do
                    if type(self.gameMEM.objects.render.list.backgroundHolograms[i]) == "table" then
                        if self.gameMEM.objects.render.list.backgroundHolograms[i][1] == lvl then
                            table.remove(self.gameMEM.objects.render.list.backgroundHolograms,i)
                        end
                    end
                end
            end
        end
    end

    self:updateRenderLists()
    self:cleanGameMEM(lvl)

    local node,keys = self:getSubTable(lvl,false)
    node[keys[#keys]] = nil

end

---lets you remove Objects from the group lvl table
---@param groupLvl string is a string that gives it the hierarchy e.g: "test.string"
---@param lvlTable table is a table of object (= sprites, holograms) hierarchies that you want to remove e.g: "test.string","test.number",ect...
function gameLib:removeObjectFromGroup(groupLvl,lvlTable)
    local node = self:getSubTable(groupLvl)

    if not node.lvlTable then error("Can't modify non existing group") end

    for i=1,table.maxn(node.lvlTable) do

        for j=1,#lvlTable do

            if node.lvlTable[i] == lvlTable[j] then

                table.remove(node.lvlTable,i)
            end
        end
    end
end

---lets you check if an object (including groups) is on top of an other object (including groups) returns true if it is, otherwise it returns false uses bounding boxes. Waring may fail if supplied, a group containing more groups (due to lua function stacking prevention)!
---@param lvl string is a string that gives it the hierarchy of the first object (including groups) to check e.g: "test.string"
---@param lvl2 string is a string that gives it the hierarchy of the second object (including groups) to check e.g: "test.number"
---@param isTransparent boolean|nil if true an empty space colliding counts as a collision. Defaults to false if not supplied
---@returns boolean
function gameLib:isColliding(lvl, lvl2, isTransparent)
    local obj1 = self:getSubTable(lvl)
    local obj2 = self:getSubTable(lvl2)

    if isTransparent == nil then
        isTransparent = false
    end
    if not obj1 or not obj2 or not obj1.type or not obj2.type then return false end

    if obj1.type == "group" and obj2.type == "group" then
        local groupList1=obj1.lvlTable
        local groupList2=obj2.lvlTable

        if type(groupList1) ~= "table" or type(groupList2) ~= "table" then return false end

        for i=1,table.maxn(groupList1) do

            for j=1,table.maxn(groupList2) do

                if self:isColliding(groupList1[i], groupList2[j], isTransparent) then
                    return true
                end
            end
        end

        return false
    elseif obj1.type == "group" and obj2.type ~= "group" then
        local groupList=obj1.lvlTable

        if type(groupList) ~= "table" then return false end

        for i=1,table.maxn(groupList) do

            if self:isColliding(groupList[i], lvl2, isTransparent) then
                return true
            end
        end

        return false
    elseif obj1.type ~= "group" and obj2.type == "group" then
        local groupList=obj2.lvlTable

        if type(groupList) ~= "table" then return false end

        for i=1,table.maxn(groupList) do

            if self:isColliding(groupList[i], lvl, isTransparent) then
                return true
            end
        end

        return false
    end

    if not (obj1.x and obj1.y and obj2.x and obj2.y) then return false end

    local x1, y1 = obj1.x + self.gameMEM.renderStartX, obj1.y + self.gameMEM.renderStartY
    local x2, y2 = obj2.x + self.gameMEM.renderStartX, obj2.y + self.gameMEM.renderStartY
    local w1, h1, w2, h2 = 0, 0, 0, 0

    -- Get width and height for each object type
    if obj1.type == "sprite" or obj1.type == "spriteClone" then

        if not obj1.sprite then return false end

        if obj1.type == "spriteClone" then
            local node = self:getSubTable(obj1.sprite)
            if not node.sprite then return false end

            w1, h1 = #node.sprite, getBiggestIndex(node.sprite)
        else

            w1, h1 = #obj1.sprite, getBiggestIndex(obj1.sprite) 
        end
    elseif obj1.type == "hologram" or obj1.type == "hologramClone" then

        if not obj1.text then return false end
        local text

        if obj1.type == "hologramClone" then
            local node = self:getSubTable(obj1.text)
            if not node.text then return false end
            text = node.text
        else
            text = obj1.text
        end

        for i=1,#text do
            if w1 < #tostring(text[i]) then
                w1 = #tostring(text[i])
            end
        end

        h1 = #text
    end

    if obj2.type == "sprite" or obj2.type == "spriteClone" then

        if not obj2.sprite then return false end

        if obj2.type == "spriteClone" then
            local node = self:getSubTable(obj2.sprite)
            if not node.sprite then return false end

            w2, h2 = #obj2.sprite, getBiggestIndex(node.sprite)
        else

            w2, h2 = #obj2.sprite, getBiggestIndex(obj2.sprite)
        end
    elseif obj2.type == "hologram" or obj2.type == "hologramClone" then

        if not obj2.text then return false end
        local text

        if obj2.type == "hologramClone" then
            local node = self:getSubTable(obj2.text)
            if not node.text then return false end
            text = node.text
        else
            text = obj2.text
        end

        for i=1,#text do
            if w2 < #tostring(text[i]) then
                w2 = #tostring(text[i])
            end
        end

        h2 = #text
    end

    -- Refined Bounding box check (avoid false positives where they just touch)
    if x1 + w1 <= x2 or x1 >= x2 + w2 or y1 + h1 <= y2 or y1 >= y2 + h2 then
        return false
    end

    -- Sprite vs Sprite (Pixel-perfect collision)
    if (obj1.type == "sprite" or obj1.type == "spriteClone") and (obj2.type == "sprite" or obj2.type == "spriteClone") then
        local sprite1, sprite2 = obj1.sprite, obj2.sprite

        if obj1.type=="spriteClone" then
            local node = self:getSubTable(obj1.sprite)
            sprite1 = node.sprite
        end
        if obj2.type=="spriteClone" then
            local node = self:getSubTable(obj2.sprite)
            sprite2 = node.sprite
        end
        if not (sprite1 and sprite2) then return false end

        for i = 1, #sprite1 do
            for j = 1, table.maxn(sprite1[i]) do
                local px1, py1 = x1 + i - 1, y1 + j - 1
                local relX, relY = px1 - x2 + 1, py1 - y2 + 1
                if relX > 0 and relY > 0 and sprite2[relX] and sprite2[relX][relY] then
                    if (not isTransparent) and (isColorValue(sprite1[i][j]) and isColorValue(sprite2[relX][relY])) then
                        return true
                    elseif isTransparent then
                        return true
                    end
                end
            end
        end
    end

    -- Sprite vs Hologram
    if (obj1.type == "sprite" or obj1.type == "spriteClone") and (obj2.type == "hologram" or obj2.type == "hologramClone") then
        local sprite = obj1.sprite
        if obj1.type=="spriteClone" then
            local node = self:getSubTable(obj1.sprite)
            sprite = node.sprite
        end

        local text = obj2.text
        if obj2.type == "hologramClone" then
            local node = self:getSubTable(obj2.text)
            text = node.text
        end

        if not sprite then return false end

        for i = 1, #sprite do
            for j = 1, table.maxn(sprite[i]) do
                local px, py = x1 + i - 1, y1 + j - 1 -- Actual world position of pixel
                local relY = py - y2 + 1 -- Adjust to hologram text coordinates

                -- Ensure relY is within obj2's text bounds
                if relY >= 1 and relY <= #text then
                    local textLine = text[relY]
                    local startX = x2 + (text[relY]:find("%S") or 1) - 1 -- First non-space X in obj2

                    local relX = px - startX + 1 -- Adjusted X position in text

                    -- Ensure relX is within obj2's text bounds
                    if relX >= 1 and relX <= #textLine then
                        local textChar = textLine:sub(relX, relX)

                        -- If the sprite pixel is not transparent and the textChar is not a space, collision detected
                        if sprite[i][j] and textChar ~= " " and not isTransparent then
                            return true
                        elseif isTransparent then
                            return true
                        end
                    end
                end
            end
        end
    end

    -- Hologram vs Sprite (flipped case)
    if obj1.type == "hologram" and (obj2.type == "sprite" or obj2.type == "spriteClone") then
        return self:isColliding(lvl2, lvl, isTransparent)
    end

    -- Hologram vs Hologram
    if (obj1.type == "hologram" or obj1.type == "hologramClone") and (obj2.type == "hologram" or obj2.type == "hologramClone") then
        local text1, text2 = obj1.text, obj2.text

        if obj1.type == "hologramClone" then
            local node = self:getSubTable(obj1.text)
            text1 = node.text
        end
        if obj2.type == "hologramClone" then
            local node = self:getSubTable(obj2.text)
            text2 = node.text
        end
        for i = 1, #text1 do
            local relY = y1 + (i - 1) - y2 + 1 -- Adjust vertical alignment

            -- Ensure relY is within obj2's text bounds
            if relY >= 1 and relY <= #text2 then
                local textLine1 = text1[i]
                local textLine2 = text2[relY]

                local startX1 = x1 + (text1[i]:find("%S") or 1) - 1 -- First non-space X in obj1
                local startX2 = x2 + (text2[relY]:find("%S") or 1) - 1 -- First non-space X in obj2

                for j = 1, #textLine1 do
                    local relX = startX1 + (j - 1) - startX2 + 1 -- Adjusted X position

                    -- Ensure relX is within obj2's text bounds
                    if relX >= 1 and relX <= #textLine2 then
                        local char1 = textLine1:sub(j, j)
                        local char2 = textLine2:sub(relX, relX)

                        -- If both characters are non-space, collision detected
                        if char1 ~= " " and char2 ~= " " and not isTransparent then
                            return true
                        elseif isTransparent then
                            return true
                        end
                    end
                end
            end
        end
    end

    return false
end

---lets you check if a object (including groups) is rendered at certain X,Y Coordinates. Waring may fail if supplied, a group containing more groups (due to lua function stacking prevention)!
---@param xIn number is the X coordinate for the collision check
---@param yIn number is the Y coordinate for the collision check
---@param lvl string is a string that gives it the hierarchy of the object to check e.g: "test.string"
---@param isTransparent boolean|nil if true an empty space colliding counts as a collision. Defaults to false if not supplied
---@returns boolean
function gameLib:isCollidingRaw(xIn, yIn, lvl, isTransparent)
    local obj = self:getSubTable(lvl)

    if isTransparent == nil then
        isTransparent = false
    end

    if not obj or not obj.type then return false end

    if obj.type == "group" then
        local groupList=obj.lvlTable

        if type(groupList) ~= "table" then return false end

        for i=1,#groupList do

            if self:isCollidingRaw(xIn, yIn, groupList[i], isTransparent) then

                return true
            end
        end

        return false
    end

    if not (obj.x and obj.y) then return false end

    local x, y = obj.x + self.gameMEM.renderStartX, obj.y + self.gameMEM.renderStartY
    local w, h = 0, 0

    -- Get width and height for each object type
    if obj.type == "sprite" or obj.type == "spriteClone" then
        if not obj.sprite then return false end
        if obj.type == "spriteClone" then
            local node = self:getSubTable(obj.sprite)
            if not node.sprite then return false end

            w, h = #node.sprite, getBiggestIndex(node.sprite)
        else
            w, h = #obj.sprite, getBiggestIndex(obj.sprite)
        end
    elseif obj.type == "hologram" or obj.type == "hologramClone" then
        if not obj.text then return false end
        local text = obj.text
        if obj.type == "hologramClone" then
            local node = self:getSubTable(obj.text)
            text = node.text
        end

        for i=1,#text do
            if w < #tostring(text[i]) then
                w = #tostring(text[i])
            end
        end

        h = #text
    end

    -- Bounding box check
    if xIn < x or xIn >= x + w or yIn < y or yIn >= y + h then
        return false
    end

    -- Pixel-perfect check (for sprites only)
    if obj.type == "sprite" or obj.type == "spriteClone" then
        local sprite = obj.sprite
        if obj.type == "spriteClone" then
            local node = self:getSubTable(obj.sprite)
            sprite=node.sprite
        end

        if not sprite then return false end

        local spriteX = xIn - x + 1
        local spriteY = yIn - y + 1
        local pixel = sprite[spriteX] and sprite[spriteX][spriteY]

        -- Check if the pixel is actually "solid"
        if not isColorValue(pixel) and not isTransparent then
            return false
        end
    end

    if obj.type == "hologram" or obj.type == "hologramClone" then
        local text = obj.text
        if obj.type == "hologramClone" then
            local node = self:getSubTable(obj.text)
            text = node.text
        end

        local textX = xIn - x + 1
        local textY = yIn - y + 1
        local line = text[textY]

        if line then
            local char = line:sub(textX, textX)

            if char == " " and not isTransparent then
                return false
            end
        else

            return false
        end
    end

    return true
end

--rendering based functions

---lets you render the game
function gameLib:render()
    
    for i=1,#self.gameMEM.dataFileCache.clones do
        if self.gameMEM.dataFileCache.clones[i] then
            if self:cloneObject(self.gameMEM.dataFileCache.clones[i][1],self.gameMEM.dataFileCache.clones[i][2],self.gameMEM.dataFileCache.clones[i][3],self.gameMEM.dataFileCache.clones[i][4],self.gameMEM.dataFileCache.clones[i][5],self.gameMEM.dataFileCache.clones[i][6]) then
                table.remove(self.gameMEM.dataFileCache.clones,i)
            end
        end
    end

    self.gameMEM.objects.render.subTasks = {}
    local CurX, CurY
    local currentBackgroundColor
    local currentTextColor

    if self.gameMEM.monitor then
        CurX, CurY = self.gameMEM.monitor.getCursorPos()
        currentBackgroundColor = self.gameMEM.monitor.getBackgroundColor()
        currentTextColor = self.gameMEM.monitor.getTextColor()
    else
        CurX, CurY = term.getCursorPos()
        currentBackgroundColor = term.getBackgroundColor()
        currentTextColor = term.getTextColor()
    end

    --Rendering background (threaded)
    table.insert(self.gameMEM.objects.render.subTasks,function() self:subRenderComponentBackground() end)

    --create renderList for backgroundHolograms
    if self.gameMEM.objects.render.listLen.backgroundHolograms ~= #self.gameMEM.objects.render.list.backgroundHolograms then
        self.gameMEM.objects.render.renderList.backgroundHolograms = {}
        for i = 1, #self.gameMEM.objects.render.list.backgroundHolograms do
            if self.gameMEM.objects.render.list.backgroundHolograms[i] ~= nil then
                self.gameMEM.objects.render.renderList.backgroundHolograms[self.gameMEM.objects.render.list.backgroundHolograms[i][2]] = self.gameMEM.objects.render.list.backgroundHolograms[i][1]
                self.gameMEM.objects.render.listLen.backgroundHolograms = #self.gameMEM.objects.render.list.backgroundHolograms
            end
        end
    end

    --crate renderList for sprites
    if self.gameMEM.objects.render.listLen.sprites ~= #self.gameMEM.objects.render.list.sprites then
        self.gameMEM.objects.render.renderList.sprites = {}
        for i = 1, #self.gameMEM.objects.render.list.sprites do
            if self.gameMEM.objects.render.list.sprites[i] ~= nil then
                self.gameMEM.objects.render.renderList.sprites[self.gameMEM.objects.render.list.sprites[i][2]] = self.gameMEM.objects.render.list.sprites[i][1]
                self.gameMEM.objects.render.listLen.sprites = #self.gameMEM.objects.render.list.sprites
            end
        end
    end

    --crate renderList for holograms (dynamic)
    if self.gameMEM.objects.render.listLen.holograms ~= #self.gameMEM.objects.render.list.holograms then
        self.gameMEM.objects.render.renderList.holograms = {}
        for i = 1, #self.gameMEM.objects.render.list.holograms do
            if self.gameMEM.objects.render.list.holograms[i] ~= nil then
                self.gameMEM.objects.render.renderList.holograms[self.gameMEM.objects.render.list.holograms[i][2]] = self.gameMEM.objects.render.list.holograms[i][1]
                self.gameMEM.objects.render.listLen.holograms = #self.gameMEM.objects.render.list.holograms
            end
        end
    end

    --Rendering backgroundHolograms (threaded)
    for i = 1,table.maxn(self.gameMEM.objects.render.renderList.backgroundHolograms) do
        if self.gameMEM.objects.render.renderList.backgroundHolograms[i] ~= nil then
            table.insert(self.gameMEM.objects.render.subTasks,function ()
                self:subRenderComponentBackgroundHolograms(self.gameMEM.objects.render.renderList.backgroundHolograms[i])
            end)
        end
    end

    --Rendering sprites (threaded)
    for i = 1, table.maxn(self.gameMEM.objects.render.renderList.sprites) do
        if self.gameMEM.objects.render.renderList.sprites[i] ~= nil then
            if self:isSubTable(self.gameMEM.objects.render.renderList.sprites[i]) then

                table.insert(self.gameMEM.objects.render.subTasks,function ()
                    self:subRenderComponentSprites(self.gameMEM.objects.render.renderList.sprites[i])
                end)
            end
        end
    end

    --Rendering holograms (dynamic) (threaded)
    for i = 1,table.maxn(self.gameMEM.objects.render.renderList.holograms) do
        if self.gameMEM.objects.render.renderList.holograms[i] ~= nil then
            table.insert(self.gameMEM.objects.render.subTasks,function ()
                self:subRenderComponentHolograms(self.gameMEM.objects.render.renderList.holograms[i])   
            end)
        end
    end

    --[[for i =1,#self.gameMEM.objects.render.subTasks do
        parallel.waitForAny(self.gameMEM.objects.render.subTasks[i])
    end]]

    parallel.waitForAll(table.unpack(self.gameMEM.objects.render.subTasks))

    if self.gameMEM.monitor then
        self.gameMEM.monitor.setTextColor(currentTextColor)
        self.gameMEM.monitor.setBackgroundColor(currentBackgroundColor)
        self.gameMEM.monitor.setCursorPos(CurX, CurY)
    else
        term.setTextColor(currentTextColor)
        term.setBackgroundColor(currentBackgroundColor)
        term.setCursorPos(CurX, CurY)
    end
end