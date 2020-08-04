CHAR_W = 4
CHAR_H = 5
R = 255
G = 0
B = 0
X = 0
Y = 0
HDG = 0
zoom_lvl = {0.1, 0.4, 1, 4, 10, 20, 30, 40, 50}
zoom_lvl_idx = 5 -- 10

function clamp(num, min, max)
    if (num < min) then
        return min
    end
    if (num > max) then
        return max
    end
    return num
end

function touch(touchX, touchY, areaX, areaY, areaW, areaH)
    if (touchX >= areaX and touchX <= (areaX + areaW)) and
        (touchY >= areaY and touchY <= (areaY + areaH)) then
        return true
    end

    return false
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

function toHDG(compassReading)
    return math.fmod(compassReading * -360 + 360, 360)
end

function onTick()
    X = input.getNumber(1)
    Y = input.getNumber(2)

    -- directional info
    HDG = toHDG(input.getNumber(3))
    
    -- touch event
    isTouch = input.getBool(4)
    touchX = input.getNumber(5)
    touchY = input.getNumber(6)
end

function drawBtn(x, y, isAdd)
	screen.setColor(255, 0, 0)
	screen.drawRectF(x, y, 10, 10)
	
	screen.setColor(0, 0, 0, 255)
	screen.drawRectF(x + 1, y + 1, 8, 8)
	
	screen.setColor(255, 0, 0)
	screen.drawRectF(x + 2, y + 4, 6, 2)
	if (isAdd) then
		screen.drawRectF(x + 4, y + 2, 2, 6)
	end
	
	screen.setColor(R, B, G)
end

function onDraw()
    w = screen.getWidth()
    h = screen.getHeight()
    
    if (isTouch and touch(touchX, touchY, w - 12, h - 24, 10, 10)) then
    	zoom_lvl_idx = zoom_lvl_idx - 1
    	zoom_lvl_idx = clamp(zoom_lvl_idx, 1, 9)
    end
	if (isTouch and touch(touchX, touchY, w - 12, h - 12, 10, 10)) then
    	zoom_lvl_idx = zoom_lvl_idx + 1
    	zoom_lvl_idx = clamp(zoom_lvl_idx, 1, 9)
	end

    screen.drawMap(X, Y, zoom_lvl[zoom_lvl_idx])
    screen.setColor(R, G, B)
    hdgTxt = 'HDG:' .. fmtDec(HDG)
    drawBkg(1, 1, strScreenWidth(hdgTxt), CHAR_H, 0, 0, 0)
    screen.drawText(1, 1, hdgTxt)
    screen.setColor(255, 0, 0)
    screen.drawRectF(w / 2 - 1, h / 2 - 1, 2, 2)

	drawBtn(w - 12, h - 24, true)
    drawBtn(w - 12, h - 12, false)

    screen.setColor(R, G, B)
end
