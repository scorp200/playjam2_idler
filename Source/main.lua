import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "lib/uibutton"

local gfx <const> = playdate.graphics
local font = gfx.font.new('fonts/whiteglove-stroked')

power = 1
lastUpdate = 0

buttons = {}

upgrades = {
    [1] = {
        name = 'wind',
        count = 0,
        base = 10,
        generates = 1
    },
    [2] = {
        name = 'hydro',
        count = 0,
        base = 100,
        generates = 2
    },
    [3] = {
        name = 'coal',
        count = 0,
        base = 1000,
        generates = 5
    },
    [4] = {
        name = 'solar',
        count = 0,
        base = 10000,
        generates = 10
    },
    [5] = {
        name = 'nuclear',
        count = 0,
        base = 100000,
        generates = 25
    },
    [6] = {
        name = 'dyson',
        count = 0,
        base = 5000000,
        generates = 100
    }
}

function init()
    local inputHandlers = {
        cranked = function(change, accel)
            power = power + math.abs(change) / 10
        end
    }

    playdate.inputHandlers.push(inputHandlers)

    local bgImg = gfx.image.new('img/background_white.png')
    bgImg:drawScaled(0, 0, 2)

    local infoBarImg = gfx.image.new('img/bottom_bar.png')
    infoBarImg:drawScaled(8, 200, 2)

    local border_unselected = gfx.image.new('img/border_unselected.png'):scaledImage(2)
    local border_selected = gfx.image.new('img/border_selected_0.png'):scaledImage(2)
    local border_w, border_h = border_unselected:getSize()

    for x = 1, 2, 1 do
        buttons[x] = {}
        for y = 1, 3, 1 do
            local x_pos = border_w * (x - 1) + border_w / 2 + 5 + 3.5 * x
            local y_pos = border_h * (y - 1) + border_h / 2 + 6 + 2 * y
            local button = UIButton(x_pos, y_pos, border_unselected, border_selected)
            buttons[x][y] = button
        end
    end

    --local button = UIButton(103, 40, border_unselected, border_selected)

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
    return string.format('%.2f' .. formatTable[index], n / 10 ^ (index * 3))
end

function getCost(base, count)
    return base * (1.15 ^ count)
end
