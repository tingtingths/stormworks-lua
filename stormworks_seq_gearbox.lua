GEAR = 1
GB_1 = false
GB_2 = false
GB_R = false
UP_LAST = false
DOWN_LAST = false

function clamp(num, min, max)
    if (num < min) then
        return min
    end
    if (num > max) then
        return max
    end
    return num
end

function onTick()
    up = input.getBool(1)
    down = input.getBool(2)

    if (up or down) then
        if (up) then
            GEAR = GEAR + 1
        end
        if (down) then
            GEAR = GEAR - 1
        end
        GEAR = clamp(GEAR, 0, 4)
    end

    -- set gearboxs on/off
    if (GEAR == 0) then
        GB_1 = false
        GB_2 = false
        GB_R = true
    end
    if (GEAR == 1) then
        GB_1 = false
        GB_2 = false
        GB_R = false
    end
    if (GEAR == 2) then
        GB_1 = true
        GB_2 = false
        GB_R = false
    end
    if (GEAR == 3) then
        GB_1 = false
        GB_2 = true
        GB_R = false
    end
    if (GEAR == 4) then
        GB_1 = true
        GB_2 = true
        GB_R = false
    end

    if (GEAR == 0) then
        gearDisplay = -1
    else
        gearDisplay = GEAR
    end

    output.setBool(1, GB_1)
    output.setBool(2, GB_2)
    output.setBool(3, GB_R)
    output.setNumber(4, gearDisplay)
end