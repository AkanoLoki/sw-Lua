-- Author: <Authorname> (Please change this in user settings, Ctrl+Comma)
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    simulator = simulator
    simulator:setScreen(1, "9x5")
    simulator:setProperty("ExampleNumberProperty", 123)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        simulator:setInputBool(1, simulator:getIsToggled(1))
        simulator:setInputNumber(1,
            math.floor(simulator:getSlider(1) * 2 ^ 7 + 0.5) * 2 ^ 16 +
            math.floor((simulator:getSlider(2) - 0.5) * 2 ^ 7 + 0.5 + 2 ^ 7) * 2 ^ 8 +
            math.floor((simulator:getSlider(3) / 2 - 0.25) * 2 ^ 7 + 2 ^ 7))
        for i = 2, 30, 1 do
            -- simulator:setInputBool(i, math.random() > 0.5)
            simulator:setInputBool(i, math.random() > 0.5)
            simulator:setInputNumber(i, math.random(2 ^ 23))
        end
        simCoordX = simulator:getSlider(7) * 256000 - 128000
        simCoordY = simulator:getSlider(8) * 256000 - 128000
        simulator:setInputNumber(31,
            (math.floor(simCoordX / 128000 * 2 ^ 11 + 2 ^ 11 + 0.5)) * 2 ^ 12 +
            math.floor(simCoordY / 128000 * 2 ^ 11 + 2 ^ 11 + 0.5))
        simulator:setInputNumber(32,
            math.floor(math.floor((simulator:getSlider(10) + 1) * 10000) / 100 + 0.5) * 2 ^ 12 +
            math.floor((simulator:getSlider(9) - 0.5) * 2 ^ 11) + 2 ^ 11)
    end
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

rAngle = 0
maxDist = 20000
mapSize = 256000
maxTargets = 30
minOpacity = 192
targets = {}
function onTick()
    for i = 1, maxTargets, 1 do
        targets[i] = {}
        if input.getBool(i) then
            targets[i][1] = input.getBool(i)
            combined = math.floor(input.getNumber(i) + 0.5)
            targets[i][2] = math.floor(math.tointeger(combined) / 2 ^ 16 + 0.5) / 2 ^ 7 * maxDist
            targets[i][3] = math.floor(math.floor(math.tointeger(combined) / 2 ^ 8 + 0.5) % 2 ^ 8) / 2 ^ 7 - 1
            targets[i][4] = math.floor(math.tointeger(combined) % 2 ^ 8 + 0.5) / 2 ^ 7 - 1
        else
            targets[i][1] = input.getBool(i)
            targets[i][2] = 0
            targets[i][3] = 0
            targets[i][4] = 0 -- assign placeholders
        end
    end
    coord = input.getNumber(31)
    mapX = (math.floor(math.floor(math.tointeger(coord) / 2 ^ 12)) / 2 ^ 11 - 1) * mapSize / 2
    mapY = (math.floor(math.floor(coord + 0.5) % 2 ^ 12 + 0.5) / 2 ^ 11 - 1) * mapSize / 2
    rData = input.getNumber(32)
    rAngle = math.floor(math.floor(rData + 0.5) % 2 ^ 12 + 0.5) / 2 ^ 11 - 1
    maxDist = math.floor(math.floor(rData + 0.5) / 2 ^ 12 + 0.5) * 100
end

function onDraw()
    scrH = screen.getHeight()
    scrW = screen.getWidth()
    screen.setColor(0, 0, 0, 0)
    screen.drawClear()
    screen.setMapColorGrass(127, 127, 127, 64)
    screen.setMapColorLand(127, 127, 127, 64)
    screen.setMapColorSand(127, 127, 127, 64)
    screen.setMapColorOcean(127, 127, 127, 16)
    screen.setMapColorShallows(127, 127, 127, 32)
    screen.setMapColorSnow(127, 127, 127, 64)
    screen.drawMap(mapX, mapY, 10)
    drawRadius = (math.min(scrH, scrW) - 2) / 2
    screen.setColor(63, 255, 63, 255) -- Light green
    screen.drawCircle(scrW / 2, scrH / 2, drawRadius)
    screen.setColor(63, 255, 63, 63) -- Light green,25% opaque
    screen.drawLine(scrW / 2, 0, scrW / 2, scrH)
    screen.drawLine(0, scrH / 2, scrW, scrH / 2)
    -- draw radar current scan line, but cooler
    for i = 0, 4, 1 do
        screen.setColor(255, 63, 63, 128 - 16 * i) -- Light Red
        screen.drawLine(scrW / 2, scrH / 2, -math.sin(rAngle * 2 * math.pi - 0.05 * i) * drawRadius + scrW / 2,
            math.cos(rAngle * 2 * math.pi - 0.05 * i) * drawRadius + scrH / 2)
    end
    -- draw target location
    for i = 1, maxTargets, 1 do
        if targets[i][1] then
            targetAlt = math.sin(targets[i][4] * 2 * math.pi) * targets[i][2]
            targetHDist = math.cos(targets[i][4] * 2 * math.pi) * targets[i][2]
            targetX = -math.sin(targets[i][3] * 2 * math.pi) * (targetHDist / maxDist) * drawRadius + scrW / 2
            targetY = math.cos(targets[i][3] * 2 * math.pi) * (targetHDist / maxDist) * drawRadius + scrH / 2
            screen.setColor(255, 255, 255,
                math.min(255, math.floor(minOpacity + (255 - minOpacity) * (1 - (targetHDist / maxDist))))) -- fainter color when further, >= minOpacity
            if drawRadius > 32 then
                screen.drawRectF(targetX - 1, targetY - 1, 2, 2)
            else
                screen.drawRectF(targetX - 1, targetY - 1, 1, 1)
            end
            screen.setColor(191, 191, 191, 127)
            screen.drawText(targetX, targetY, tostring(math.floor(targetAlt)))
        end
    end
end
