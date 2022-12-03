import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics
local font = gfx.font.new('fonts/whiteglove-stroked')

power = 1
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
            power = power + math.abs(change) / 100
        end
    }

    playdate.inputHandlers.push(inputHandlers)

    gfx.setFont(font)
end

init()

function playdate.update()
    gfx.sprite.update()
    playdate.timer.updateTimers()

    local currentTime = playdate.getCurrentTimeMilliseconds()
    local deltaTime = (currentTime - lastUpdate) / 1000
    lastUpdate = currentTime

    for k, v in pairs(upgrades) do
        local produce = v.generates * v.count
        power = power + produce * deltaTime

        -- draw code goes next
    end

    gfx.drawText('power: ' .. formatDigits(power) .. 'w/s', 2, 30)
end

local formatTable <const> = {
    [0] = '',
    [1] = 'k',
    [2] = 'm',
    [3] = 'g',
    [4] = 't',
    [5] = 'p',
    [6] = 'e',
    [7] = 'z',
    [8] = 'y',
    [9] = 'q',
}

function formatDigits(n)
    local pow = math.floor(math.log(n, 10))
    local index = math.floor(pow / 3)
    return string.format('%.2f' .. formatTable[index], n / 10 ^ pow)
end

function getCost(base, count)
    return base * (1.15 ^ count)
end
