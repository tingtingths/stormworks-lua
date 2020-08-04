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

function onTick()
    x1 = input.getNumber(1)
    y1 = input.getNumber(2)
    x2 = input.getNumber(3)
    y2 = input.getNumber(4)

    bearing = calcBearing(x1, y1, x2, y2)
    output.setNumber(1, bearing)
end