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

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(3, simulator:getIsToggled(3))
        simulator:setInputNumber(9, screenConnection.width)
        simulator:setInputNumber(10, screenConnection.height)
        simulator:setInputNumber(11, screenConnection.touchX)
        simulator:setInputNumber(12, screenConnection.touchY)

        simulator:setInputBool(1, simulator:getIsToggled(1))
        simulator:setInputNumber(1, simulator:getSlider(1) * 3000)
        simulator:setInputNumber(2, (simulator:getSlider(2) - 0.5))
        simulator:setInputNumber(3, (simulator:getSlider(3) - 0.5))
        simulator:setInputNumber(4, (simulator:getSlider(4) - 0.5))

        for i = 2, 8, 1 do
            simulator:setInputBool(i, false)
        end


        simulator:setInputNumber(8, simulator:getSlider(8)) -- set input 31 to the value of slider 10
        simulator:setInputNumber(12, simulator:getSlider(9)) -- set input 31 to the value of slider 10
        simulator:setInputNumber(16, simulator:getSlider(10)) -- set input 31 to the value of slider 10
    end
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

rAngle = 0
rSweep = 0
YFOV = 0

maxTargets = 8
maxDist = 3200
minOpacity = 127
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
    if rAngle > 0.5 then
        rAngle = rAngle - 1
    end
    rSweep = input.getNumber(8) -- get radar covered azimuth angle
    YFOV = input.getNumber(12) -- get radar covered azimuth angle
end

function onDraw()
    scrH = screen.getHeight()
    scrW = screen.getWidth()
    screen.setColor(63, 255, 63, 255) -- Light green
    screen.drawRect(2, 8, scrW - 5, scrH - 10)
    screen.setColor(63, 255, 63, 63) -- Light green,25% opaque
    screen.drawLine(1 + scrW / 3, 9, 1 + scrW / 3, scrH - 2)
    screen.drawLine(scrW * 2 / 3 - 1, 9, scrW * 2 / 3 - 1, scrH - 2)
    screen.drawLine(3, (scrH - 13) / 2 + 10, scrW - 3, (scrH - 13) / 2 + 10)
    -- draw radar rotation angle
    screen.setColor(255, 63, 63, 255) -- Light Red
    screen.drawTextBox(0, 0, 10, 4, tostring(math.floor(rSweep * 180)), 0, -1)
    screen.setColor(63, 255, 63, 255) -- Light green
    screen.drawTextBox(scrW - 9, 0, 10, 4, tostring(math.floor(rSweep * 180)), 0, -1)
    -- draw radar current scan line
    scanLineX = (scrW - 7) * (rAngle / rSweep) + scrW / 2
    screen.setColor(255, 63, 63, 127) -- Light Red
    screen.drawLine(scanLineX, 9, scanLineX, scrH - 2)
    -- draw target location
    for i = 1, maxTargets, 1 do
        if targets[i][1] then
            targetX = (scrW - 7) * ((targets[i][3]) / rSweep) + scrW / 2
            targetY = (scrH - 12) * (-targets[i][4] / (YFOV / 2)) + (scrH - 13) / 2 + 10
            screen.setColor(255, 255, 255,
                math.floor(minOpacity + (255 - minOpacity) * (1 - (targets[i][2] / maxDist)))) -- fainter color when further, >= minOpacity
            screen.drawRectF(targetX - 1, targetY - 1, 1, 1)
            screen.drawRectF((scrW - maxTargets) / 2 + i, 0, 1, 1)
        end
    end
end
