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
    simulator:setScreen(1, "1x1")
    simulator:setProperty("ExampleNumberProperty", 123)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        simulator:setInputBool(1, simulator:getIsToggled(1))
        simulator:setInputNumber(1, simulator:getSlider(1) * 5000)
        simulator:setInputNumber(2, (simulator:getSlider(2) - 0.5))
        simulator:setInputNumber(3, (simulator:getSlider(3) - 0.5))
        simulator:setInputNumber(4, (simulator:getSlider(4) - 0.5))
        for i = 2, 8, 1 do
            simulator:setInputBool(i, math.random() > 0.5)
            simulator:setInputNumber(i * 4 - 3, math.random() * 5000)
            simulator:setInputNumber(i * 4 - 2, math.random() - 0.5)
            simulator:setInputNumber(i * 4 - 1, math.random() / 2)
        end
        simulator:setInputNumber(8, simulator:getSlider(7) * 10000 + 1)
        simulator:setInputNumber(12, simulator:getSlider(8))
        simulator:setInputNumber(16, simulator:getSlider(9))
        simulator:setInputNumber(20, simulator:getSlider(10))
    end
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

rAngle = 0
maxDist = 20000
maxTargets = 8
minOpacity = 192
targets = {}
function onTick()
    for i = 1, maxTargets, 1 do
        targets[i] = {}
        if input.getBool(i) then
            targets[i][1] = input.getBool(i)
            targets[i][2] = input.getNumber((i - 1) * 4 + 1)
            targets[i][3] = input.getNumber((i - 1) * 4 + 2)
            targets[i][4] = input.getNumber((i - 1) * 4 + 3)
        else
            targets[i][1] = input.getBool(i)
            targets[i][2] = 0
            targets[i][3] = 0
            targets[i][4] = 0 -- assign placeholders
        end
    end
    rAngle = input.getNumber(4) -- get radar current rotation
    maxDist = input.getNumber(8) -- get radar covered max distance
end

function onDraw()
    scrH = screen.getHeight()
    scrW = screen.getWidth()
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
