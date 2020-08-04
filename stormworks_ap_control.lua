CHAR_W = 4
CHAR_H = 5
R = 200
G = 200
B = 200

MS_TO_KM_FACTOR = 3.6
MS_TO_KNOT_FACTOR = 1.943844
MS_TO_MILE_FACTOR = 2.23693629

SPD_HLD = false
AUTO_HEADING = false

unit_of_speed = property.getNumber('Speed Unit')

spdValueEditing = false
spdValueUpdate = false
xValueEditing = false
xValueUpdate = false
yValueEditing = false
yValueUpdate = false

spd_sp = 0
spd_sp_tmp = 0
x_sp = 0
x_sp_tmp = 0
y_sp = 0
y_sp_tmp = 0

function fmtDec(s, decPlc)
    decPlc = decPlc or 0
    return string.format('%0.'..decPlc..'f', s)
end

function strScreenWidth(s)
    return string.len(s) * CHAR_W + string.len(s)
end

function drawBkg(x, y, w, h, r, g, b, a)
    a = a or 255
    screen.setColor(r, g, b, a)
    screen.drawRectF(x, y, w, h)
    screen.setColor(R, G, B)
end

function drawTextSpan(x, y, w, txt_left, txt_right)
    screen.drawText(x, y, txt_left)
    screen.drawText(x + w - strScreenWidth(txt_right), y, txt_right)
end

function spdUnit2Factor(unit)
    if (unit == 1) then
        return MS_TO_KM_FACTOR
    end
    if (unit == 2) then
        return MS_TO_MILE_FACTOR
    end
    if (unit == 3) then
        return MS_TO_KNOT_FACTOR
    end

    return 1
end

function getTargetSpdTxt(spd, unit)
    if (unit == 1) then
        unitTxt = 'kph'
    end
    if (unit == 2) then
        unitTxt = 'mph'
    end
    if (unit == 3) then
        unitTxt = 'nmh'
    end

    spdTxt = fmtDec(spd)
    return spdTxt .. unitTxt
end

function calcBearing(x1, y1, x2, y2)
    dX = x2 - x1
    dY = y2 - y1
    deg = math.deg(math.atan(dX, dY))
    if (deg < 0) then
        return 360 + deg
    else
        return deg
    end
end

function touched(touchX, touchY, areaX, areaY, areaW, areaH)
    if (touchX >= areaX and touchX <= (areaX + areaW)) and
        (touchY >= areaY and touchY <= (areaY + areaH)) then
        return true
    end

    return false
end

function postProcessHDG(pv, sp)
    delta = pv - sp

    -- calculate offset
    if (sp > 180) then
        offset = 360 - sp
    else
        offset = sp * -1
    end

    -- finalize pv
    if ((pv + offset) > 180) then
        offset_pv = 360 - pv - offset
        offset_pv = offset_pv * -1
    else
        offset_pv = pv + offset
    end

    return offset_pv
end

function onTick()
    if (spdValueEditing) then
        spd_sp_tmp = input.getNumber(1)
    end
    if (spdValueUpdate) then
        spd_sp = input.getNumber(1)
        spd_sp_tmp = spd_sp
        spdValueUpdate = false
    end
    if (xValueEditing) then
        x_sp_tmp = input.getNumber(1)
    end
    if (xValueUpdate) then
        x_sp = input.getNumber(1)
        x_sp_tmp = x_sp
        xValueUpdate = false
    end
    if (yValueEditing) then
        y_sp_tmp = input.getNumber(1)
    end
    if (yValueUpdate) then
        y_sp = input.getNumber(1)
        y_sp_tmp = y_sp
        yValueUpdate = false
    end

    -- speed hold
    spd_sp_ms = spd_sp / spdUnit2Factor(unit_of_speed)

    output.setBool(1, SPD_HLD)
    output.setNumber(2, spd_sp_ms)

    -- auto bearing
    x_pv = input.getNumber(2)
    y_pv = input.getNumber(3)
    bearing_pv = input.getNumber(4)

    bearing = calcBearing(x_pv, y_pv, x_sp, y_sp)
    bearing = postProcessHDG(bearing_pv, bearing)
    output.setBool(3, AUTO_HEADING)
    output.setNumber(4, bearing)

    -- touch event
    isTouch = input.getBool(5)
    touchX = input.getNumber(6)
    touchY = input.getNumber(7)
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()

    screen.setColor(R, G, B)

    screen.drawText(1, 1, 'AP CTRL')

    -- SPD HLD
    yPtr = CHAR_H * 2 + 4
    btnX = w - strScreenWidth('xxxxx')
    btnY = yPtr - 1
    btnW = strScreenWidth('xxxxx')
    btnH = CHAR_H + 2
    if (isTouch and touched(touchX, touchY, btnX, btnY, btnW, btnH)) then
        SPD_HLD = not SPD_HLD
    end
    drawBkg(btnX, btnY, btnW, btnH, SPD_HLD and 0 or 150, SPD_HLD and 150 or 0, 0)
    drawTextSpan(1, yPtr, w, 'SPD HLD', SPD_HLD and 'ON' or 'OFF')

    -- SPD HLD Value
    yPtr = yPtr + CHAR_H + 4
    btnX = w - strScreenWidth(getTargetSpdTxt(spd_sp_tmp, unit_of_speed))
    btnY = yPtr - 1
    btnW = strScreenWidth(getTargetSpdTxt(spd_sp_tmp, unit_of_speed))
    btnH = CHAR_H + 2
    if (isTouch) then
        spdValueUpdate = spdValueEditing
        if (touched(touchX, touchY, btnX, btnY, btnW, btnH)) then
            spdValueEditing = not spdValueEditing
        else
            spdValueEditing = false
        end
    end
    drawBkg(btnX, btnY, btnW, btnH, spdValueEditing and 50 or 0, spdValueEditing and 50 or 0, spdValueEditing and 50 or 0)
    drawTextSpan(1, yPtr, w, '', getTargetSpdTxt(spd_sp_tmp, unit_of_speed))

    -- auto heading
    yPtr = yPtr + CHAR_H * 2 + 4
    btnX = w - strScreenWidth('xxxxx')
    btnY = yPtr - 1
    btnW = strScreenWidth('xxxxx')
    btnH = CHAR_H + 2
    if (isTouch and touched(touchX, touchY, btnX, btnY, btnW, btnH)) then
        AUTO_HEADING = not AUTO_HEADING
    end
    drawBkg(btnX, btnY, btnW, btnH, AUTO_HEADING and 0 or 150, AUTO_HEADING and 150 or 0, 0)
    drawTextSpan(1, yPtr, w, 'WPY', AUTO_HEADING and 'ON' or 'OFF')

    yPtr = yPtr + CHAR_H + 4
    btnX = w - strScreenWidth(fmtDec(x_sp_tmp))
    btnY = yPtr - 1
    btnW = strScreenWidth(fmtDec(x_sp_tmp))
    btnH = CHAR_H + 2
    if (isTouch) then
        xValueUpdate = xValueEditing
        if (touched(touchX, touchY, btnX, btnY, btnW, btnH)) then
            xValueEditing = not xValueEditing
        else
            xValueEditing = false
        end
    end
    drawBkg(btnX, btnY, btnW, btnH, xValueEditing and 50 or 0, xValueEditing and 50 or 0, xValueEditing and 50 or 0)
    drawTextSpan(1, yPtr, w, 'X', fmtDec(x_sp_tmp)) -- x

    yPtr = yPtr + CHAR_H + 4
    btnX = w - strScreenWidth(fmtDec(y_sp_tmp))
    btnY = yPtr - 1
    btnW = strScreenWidth(fmtDec(y_sp_tmp))
    btnH = CHAR_H + 2
    if (isTouch) then
        yValueUpdate = yValueEditing
        if (touched(touchX, touchY, btnX, btnY, btnW, btnH)) then
            yValueEditing = not yValueEditing
        else
            yValueEditing = false
        end
    end
    drawBkg(btnX, btnY, btnW, btnH, yValueEditing and 50 or 0, yValueEditing and 50 or 0, yValueEditing and 50 or 0)
    drawTextSpan(1, yPtr, w, 'Y', fmtDec(y_sp_tmp)) -- y
end