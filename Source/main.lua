import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics
local font = gfx.font.new('fonts/whiteglove-stroked')

power = 0
lastUpdate = 0

upgrades = {
    wind = {
        count = 0,
        base = 100,
        generates = 2
    }
}

function init()
    local inputHandlers = {
        cranked = function(change, accel)
            power = power + change / 100
        end
    }

    playdate.inputHandlers.push(inputHandlers)
end

init()

function playdate.update()
    local currentTime = playdate.getCurrentTimeMilliseconds()
    local deltaTime = (currentTime - lastUpdate) / 1000
    lastUpdate = currentTime

    for k, v in pairs(upgrades) do
        local produce = v.generates * v.count
        power = power + produce * deltaTime

        -- draw code goes next
    end
end

function formatDigits(n)
    if n >= 10 ^ 9 then
        return string.format("%.2fgw", n / 10 ^ 9)
    elseif n >= 10 ^ 6 then
        return string.format("%.2fmw", n / 10 ^ 6)
    elseif n >= 10 ^ 3 then
        return string.format("%.2fkw", n / 10 ^ 3)
    else
        return string.format("%.0fw", n)
    end
end
