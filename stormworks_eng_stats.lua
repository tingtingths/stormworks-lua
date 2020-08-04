CHAR_W = 4
CHAR_H = 5
R = 200
G = 200
B = 200
ENG_RPS = {}
ENG_TMP = {}
CLUTCH_ENGAGE = {}
MAX_TEMP = property.getNumber('Max Temp.')

function strScreenWidth(s)
    return string.len(s) * CHAR_W + string.len(s)
end

function fmtDec(s, decPlc)
    decPlc = decPlc or 0
    return string.format('%0.'..decPlc..'f', s)
end

function drawTextSpan(x, y, _w, txt_left, txt_right)
    screen.drawText(x, y, txt_left)
    screen.drawText(x + _w - strScreenWidth(txt_right), y, txt_right)
end

-- Tick function that will be executed every logic tick
function onTick()
    -- RPS
    ENG_RPS[0] = input.getNumber(1)
    ENG_RPS[1] = input.getNumber(2)
    ENG_RPS[2] = input.getNumber(3)
    ENG_RPS[3] = input.getNumber(4)
    ENG_RPS[4] = input.getNumber(5)
    ENG_RPS[5] = input.getNumber(6)

    -- Temperature
    ENG_TMP[0] = input.getNumber(7)
    ENG_TMP[1] = input.getNumber(8)
    ENG_TMP[2] = input.getNumber(9)
    ENG_TMP[3] = input.getNumber(10)
    ENG_TMP[4] = input.getNumber(11)
    ENG_TMP[5] = input.getNumber(12)

    -- clutch
    CLUTCH_ENGAGE[0] = input.getNumber(13)
    CLUTCH_ENGAGE[1] = input.getNumber(14)
end

function drawEngStats(x, y, w, h, engId)
    rps = ENG_RPS[engId]
    temp = ENG_TMP[engId]
    engTxt = 'ENG_'..engId + 1

    -- background
    if (math.fmod(engId, 2) ~= 0) then
        screen.setColor(15, 15, 15)
    else
        screen.setColor(30, 30, 30)
    end
    screen.drawRectF(x, y, w, h)
    screen.setColor(R, G, B)

    xPtr = x
    screen.drawText(xPtr, y, engTxt)

    xPtr = xPtr + CHAR_W * 7
    rpsTxt = fmtDec(rps)
    drawTextSpan(xPtr, y, strScreenWidth('xxx'), '', rpsTxt)

    xPtr = xPtr + CHAR_W * 4
    tempTxt = fmtDec(temp)
    tempRatio = (temp / MAX_TEMP)
    screen.setColor(255 * tempRatio, 255 - (255 * tempRatio), 0)
    drawTextSpan(xPtr, y, strScreenWidth('xxxx'), '', tempTxt)
    screen.setColor(R, G, B)
end

function drawClutchStat(x, y, w, h, clutchId)
    clutchVal = CLUTCH_ENGAGE[clutchId]

    screen.setColor(255 - (255 * (clutchVal / 1)), 255 * (clutchVal / 1), 0)
    screen.drawText(x, y, 'CTH_'..clutchId + 1)
    screen.setColor(R, G, B)
end

-- Draw function that will be executed when this script renders to a screen
function onDraw()
    w = screen.getWidth() -- Get the screen's width and height
    h = screen.getHeight()

    -- draw screen background
    screen.setColor(30, 30, 30)
    screen.drawRectF(0, 0, w, h)
    screen.setColor(R, G, B)

    screen.drawText(1, 1, 'ENGINE')
    screen.drawText(1, CHAR_H + 2, 'STAT')

    statW = w
    statH = CHAR_H + 2

    --screen.drawLine(w/2, 0, w/2, h)

    -- clutch info
    drawClutchStat(w/2 + CHAR_W * 2, 1, w/2, statH, 0)
    drawClutchStat(w/2 + CHAR_W * 2, CHAR_H + 2, w/2, statH, 1)

    -- engine info
    screen.drawText(w/2 - CHAR_W * 2, CHAR_H * 3, 'RPS TEMP')

    totalH = (CHAR_H * 1 + 2) * 6
    yPtr = h - totalH + 1
    drawEngStats(1, yPtr, statW, statH, 0)

    yPtr = yPtr + CHAR_H * 1 + 2
    drawEngStats(1, yPtr, statW, statH, 1)

    yPtr = yPtr + CHAR_H * 1 + 2
    drawEngStats(1, yPtr, statW, statH, 2)

    yPtr = yPtr + CHAR_H * 1 + 2
    drawEngStats(1, yPtr, statW, statH, 3)

    yPtr = yPtr + CHAR_H * 1 + 2
    drawEngStats(1, yPtr, statW, statH, 4)

    yPtr = yPtr + CHAR_H * 1 + 2
    drawEngStats(1, yPtr, statW, statH, 5)
end
