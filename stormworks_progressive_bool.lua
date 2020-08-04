PERIOD = property.getNumber('Period (Tick)') -- ? ticks
progress = 0

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
	toggle = input.getBool(1)
	step = 1 / PERIOD
	if (not toggle) then
		step = step * -1
	end
	
	-- calculate previous output value
	out = progress
	out = out + step
	
	progress = clamp(out, 0, 1)
	output.setNumber(1, progress)
end

function onDraw()
	screen.drawText(1, 1, progress)
end
