CHAR_W = 4
CHAR_H = 5
R = 200
G = 200
B = 200

-- for fuel usage calcuation
tick = 0
fuelDelta = 0
fuelHistory = 0

-- for battery
batHistory = 1

function minsToCountDownTimerStr(mins)
    h = math.floor(mins / 60)
    m = math.floor(mins - math.floor(mins / 60) * 60)

    ret = ''

    if (h > 0) then
        ret = h .. 'H'
    end
    ret = ret .. m .. 'M'

    return ret
end

function drawBkg(x, y, w, h, r, g, b, a)
    a = a or 255
    screen.setColor(r, g, b, a)
    screen.drawRectF(x, y, w, h)
    screen.setColor(R, G, B)
end

function fmtDec(s, decPlc)
    decPlc = decPlc or 0
    return string.format('%0.'..decPlc..'f', s)
end

function strScreenWidth(s)
    return string.len(s) * CHAR_W + string.len(s)
end

function drawTextSpan(x, y, w, txt_left, txt_right)
    screen.drawText(x, y, txt_left)
    screen.drawText(x + w - strScreenWidth(txt_right), y, txt_right)
end

function onTick()
    CURR_FUEL = input.getNumber(1)
    MAX_FUEL = input.getNumber(2)
    BAT_LEVEL = input.getNumber(3)

    -- fuel calculation
    tick = tick + 1

    if (tick ~= 0 and math.fmod(tick, 60) == 0) then
        fuelDelta = CURR_FUEL - fuelHistory
        fuelHistory = CURR_FUEL
        tick = 0
    end
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    screen.setColor(R, G, B)

    -- Fuel Stat
    yPos = 1
    screen.drawText(1, yPos, 'FUEL STATS')

    yPos = yPos + CHAR_H * 2
    drawBkg(0, yPos, w, CHAR_H + 2, 30, 30, 30)
    drawTextSpan(2, yPos, w - 4, 'FUEL', fmtDec(CURR_FUEL))
    
    yPos = yPos + CHAR_H + 2
    drawBkg(0, yPos, w, CHAR_H + 2, 15, 15, 15)

    screen.setColor(255 - (255 * (CURR_FUEL / MAX_FUEL)), 255 * (CURR_FUEL / MAX_FUEL), 0)
    drawTextSpan(2, yPos, w - 2, '', fmtDec(CURR_FUEL / MAX_FUEL * 100, 1) .. '%')
    screen.drawRectF(0, yPos + CHAR_H + 1, h * (CURR_FUEL / MAX_FUEL), 1)
    screen.setColor(R, G, B)

    yPos = yPos + CHAR_H + 2
    drawBkg(0, yPos, w, CHAR_H + 2, 30, 30, 30)
    drawTextSpan(2, yPos, w - 4, 'DELTA', fmtDec(fuelDelta))

    depleteMin = (CURR_FUEL / math.abs(fuelDelta)) / 60
    yPos = yPos + CHAR_H + 2
    drawBkg(0, yPos, w, CHAR_H + 2, 30, 30, 30)
    drawTextSpan(2, yPos, w - 4, 'DEPLT', minsToCountDownTimerStr(depleteMin))

    -- Battery Stat
    yPos = yPos + CHAR_H * 3
    screen.drawText(1, yPos, 'BAT. STATS')
    screen.drawRectF(0, yPos - 4, w, 1)

    yPos = yPos + CHAR_H * 2
    drawBkg(0, yPos, w, CHAR_H + 2, 30, 30, 30)
    drawTextSpan(2, yPos, w - 4, 'BAT', '')
    if (batHistory > BAT_LEVEL) then
        screen.setColor(255, 0, 0)
    else
        screen.setColor(0, 255, 0)
    end
    drawTextSpan(2, yPos, w - 4, '', fmtDec(BAT_LEVEL / 1 * 100, 1) .. '%')
    screen.setColor(255 - (255 * (BAT_LEVEL / 1)), 255 * (BAT_LEVEL / 1), 0)
    screen.drawRectF(0, yPos + CHAR_H + 1, h * (BAT_LEVEL / 1), 1)
    screen.setColor(R, G, B)
    batHistory = BAT_LEVEL
end
