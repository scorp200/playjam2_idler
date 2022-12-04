import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "lib/uibutton"

local gfx <const> = playdate.graphics
local font = gfx.font.new('fonts/whiteglove-stroked')

power = 1
lastUpdate = 0

selected = {
    x = 1,
    y = 1
}

buttons = {}


upgrades = {
    [1] = {
        name = 'wind',
        count = 0,
        base = 10,
        generates = 0.5
    },
    [2] = {
        name = 'hydro',
        count = 0,
        base = 200,
        generates = 5
    },
    [3] = {
        name = 'coal',
        count = 0,
        base = 1000,
        generates = 35
    },
    [4] = {
        name = 'solar',
        count = 0,
        base = 10000,
        generates = 250
    },
    [5] = {
        name = 'nuclear',
        count = 0,
        base = 100000,
        generates = 1100
    },
    [6] = {
        name = 'dyson',
        count = 0,
        base = 5000000,
        generates = 25000
    }
}

function init()
    local inputHandlers = {
        cranked = function(change, accel)
            power = power + math.abs(change) / 100
        end
    }

    playdate.inputHandlers.push(inputHandlers)

    local bgImg = gfx.image.new('img/background_white.png')
    bgImg:drawScaled(0, 0, 2)

    local infoBarImg = gfx.image.new('img/bottom_bar.png')
    infoBarImg:drawScaled(8, 200, 2)

    local border_unselected = gfx.image.new('img/border_unselected_alt.png'):scaledImage(2)
    local border_selected = gfx.image.new('img/border_selected_0.png'):scaledImage(2)
    local border_w, border_h = border_unselected:getSize()

    for x = 1, 2, 1 do
        buttons[x] = {}
        for y = 1, 3, 1 do
            local x_pos = border_w * (x - 1) + border_w / 2 + 5 + 3.5 * x
            local y_pos = border_h * (y - 1) + border_h / 2 + 6 + 2 * y
            local index = x * 3 + y - 3

            local button = UIButton(x_pos, y_pos, border_unselected, border_selected)
            buttons[x][y] = button

            local img = gfx.image.new('img/' .. upgrades[index].name .. '.png'):scaledImage(2)
            local img_w = img:getSize()

            local sprt = gfx.sprite.new()
            sprt:setImage(img)
            sprt:moveTo(x_pos - border_w / 4 - img_w / 4, y_pos)
            sprt:setZIndex(11)
            sprt:add()

            upgrades[index].sprite = sprt
            button.data = upgrades[index]
        end
    end

    --local button = UIButton(103, 40, border_unselected, border_selected)

    gfx.setFont(font)
end

init()

function playdate.update()
    gfx.sprite.update()
    playdate.timer.updateTimers()

    if playdate.buttonJustPressed(playdate.kButtonUp) and selected.y > 1 then
        selected.y = selected.y - 1
    elseif playdate.buttonJustPressed(playdate.kButtonDown) and selected.y <= 2 then
        selected.y = selected.y + 1
    end

    if playdate.buttonJustPressed(playdate.kButtonLeft) and selected.x > 1 then
        selected.x = selected.x - 1
    elseif playdate.buttonJustPressed(playdate.kButtonRight) and selected.x < 2 then
        selected.x = selected.x + 1
    end

    if playdate.buttonJustPressed(playdate.kButtonA) then
        local upgrade = buttons[selected.x][selected.y].data
        local cost = getCost(upgrade.base, upgrade.count)

        if cost <= power then
            upgrade.count = upgrade.count + 1
            power = power - cost
        end
    elseif playdate.buttonJustPressed(playdate.kButtonB) then
        local upgrade = buttons[selected.x][selected.y].data
        local cost = getCost(upgrade.base, upgrade.count)

            upgrade.count = upgrade.count + 1
    end

    for x = 1, 2, 1 do
        for y = 1, 3, 1 do
            buttons[x][y]:setSelected(x == selected.x and y == selected.y)
        end
    end

    local currentTime = playdate.getCurrentTimeMilliseconds()
    local deltaTime = (currentTime - lastUpdate) / 1000
    lastUpdate = currentTime

    for k, v in pairs(upgrades) do
        local produce = getProduce(v.generates, v.count) * deltaTime
        power = power + produce

        -- draw code goes next

        gfx.drawText(v.name .. ' x' .. v.count, v.sprite.x + 30, v.sprite.y - 25)
        gfx.drawText('price: ' .. formatDigits(getCost(v.base, v.count)) .. 'w/s', v.sprite.x + 30, v.sprite.y - 10)
        if produce > 0 then
            gfx.drawText('+ ' .. formatDigits(produce / deltaTime) .. 'w/s', v.sprite.x + 30, v.sprite.y + 5)
        end
    end

    gfx.drawTextAligned(formatDigits(power) .. 'w/s', 200, 210, kTextAlignment.center)
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
    if index < 0 then
        index = 0
    end
    if pow % 3 ~= 0 and n > 1 then
        return string.format('%.0f' .. formatTable[index], n / 10 ^ (index * 3))
    else
        return string.format('%.2f' .. formatTable[index], n / 10 ^ (index * 3))
    end
end

function getCost(base, count)
    return base * (1.15 ^ count)
end

local bonusTable <const> = {
    [0] = 0,
    [1] = 1,
    [2] = 1,
    [3] = 1.5,
    [4] = 1.5,
    [5] = 1.5,
    [6] = 2,
    [7] = 3,
}

function getProduce(generates, count)
    local level = math.floor(count / 25)
    local bonus = 1
    for i = 0, level, 1 do
        bonus = bonus + bonusTable[i]
    end
    return generates * count * bonus
end
