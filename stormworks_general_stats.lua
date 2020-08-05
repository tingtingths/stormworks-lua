CHAR_W = 4
CHAR_H = 5
R = 200
G = 200
B = 200

MS_TO_KM_FACTOR = 3.6
MS_TO_KNOT_FACTOR = 1.943844
MS_TO_MILE_FACTOR = 2.23693629
MINS_IN_HOUR = 1440

tick = 0
timeSep = ':'
unit_of_speed = property.getNumber('Speed Unit')

function minsToTimeStr(mins, sep)
    return string.format('%02d', math.floor(mins / 60)) .. sep .. string.format('%02d', math.floor(mins - math.floor(mins / 60) * 60))
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

function toHDG(compassReading)
    return math.fmod(compassReading * -360 + 360, 360)
end

function drawSteeringIndicator(steering)
    lvl = math.ceil(math.abs(steering) * 6)

    x = 2
    y = h - CHAR_H

    for i = 5, 0, -1 do
        if (steering < 0 and lvl > i) then
            drawLeftRightTri(x, y, 'l')
        end
        x = x + CHAR_W + 1
        y = h - CHAR_H
    end

    for i = 0, 5, 1 do
        if (steering > 0 and lvl > i) then
            drawLeftRightTri(x, y, 'r')
        end
        x = x + CHAR_W + 1
        y = h - CHAR_H
    end
end

function drawThrottleIndicator(throttle)
    lvl = math.ceil(math.abs(throttle) * 6)

    x = w / 2
    y = h - CHAR_H * 2 - 4

    for i = 1, 6, 1 do
        if (lvl >= i) then
            drawUpTri(x, y)
        end

        y = y - CHAR_H - 2
    end

    y = y + CHAR_H
    screen.drawLine(x - 2, y, x + 2, y)
end

function drawSpd(x, y, spd, unit)
    if (unit_of_speed == 1) then
        factor = MS_TO_KM_FACTOR
        unitTxt = 'kph'
    end
    if (unit_of_speed == 2) then
        factor = MS_TO_MILE_FACTOR
        unitTxt = 'mph'
    end
    if (unit_of_speed == 3) then
        factor = MS_TO_KNOT_FACTOR
        unitTxt = 'nmh'
    end

    spdTxt = fmtDec(spd * factor)
    drawInfoTxt(x, y, unitTxt, spdTxt)
end

function drawHDG(x, y, bearing)
    drawInfoTxt(x, y, 'HDG', fmtDec(bearing))
end

function drawInfoTxt(x, y, header, value)
    screen.drawText(x, y, header)
    y = y + CHAR_H + 2
    drawTextSpan(x, y, w / 2 - (CHAR_W + 1), '', value)
end

function drawGear(x, y, gear)
    if (gear < 0) then
        txt = 'R' .. fmtDec(math.abs(gear))
    else
        txt = fmtDec(gear)
    end
    drawInfoTxt(x, y, 'Gear', txt)
end

function drawRPSSetPoint(x, y, sp)
    drawInfoTxt(x, y, 'RPS SP', fmtDec(sp, 1))
end

function drawThrottle(x, y, throttle)
    throttle = throttle * 100
    drawInfoTxt(x, y, 'THR', fmtDec(throttle, 0))
end

function drawLeftRightTri(x, y, leftOrRight)
    if (leftOrRight == 'l') then
        screen.drawTriangleF(x, y + CHAR_H / 2, x + CHAR_W, y, x + CHAR_W, y + CHAR_H)
    end

    if (leftOrRight == 'r') then
        screen.drawTriangleF(x, y, x, y + CHAR_H, x + CHAR_W, y + CHAR_H / 2)
    end
end

function drawUpTri(x, y)
    screen.drawTriangleF(x, y, x - CHAR_W / 2, y + CHAR_H, x + CHAR_W / 2, y + CHAR_H)
end

function clamp(num, min, max)
    if (num < min) then
        return min
    end
    if (num > max) then
        return max
    end
    return num
end

function deadzone(num, zone)
    if (math.abs(num) <= zone) then
        return 0
    end
    return num
end

function onTick()
    steering = deadzone(input.getNumber(1), 0.01) -- -1..1
    throttle = clamp(input.getNumber(2), 0, 1) -- 0..1
    bearing = toHDG(input.getNumber(3))
    spd = input.getNumber(4) -- m/s
    clock = input.getNumber(5) -- 0..1
    gear = input.getNumber(6)
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    screen.setColor(R, G, B)

    tick = tick + 1
    if (tick ~= 0 and math.fmod(tick, 60) == 0) then
        if (timeSep == ' ') then
            timeSep = ':'
        else
            timeSep = ' '
        end
        tick = 0
    end
    screen.drawText(w / 2 - strScreenWidth('00:11') / 2, 1, minsToTimeStr(clock * MINS_IN_HOUR, timeSep))

    drawSteeringIndicator(steering)
    drawThrottleIndicator(throttle)

    drawSpd(1, CHAR_H * 2, spd, unit_of_speed)
    drawHDG(1, CHAR_H * 4 + 8, bearing)
    drawGear(w / 2 + CHAR_W, CHAR_H * 2, gear)
    drawThrottle(w / 2 + CHAR_W, CHAR_H * 4 + 8, throttle)
    --drawRPSSetPoint(w / 2 + CHAR_W, CHAR_H * 4 + 8, rpsSP)
end
