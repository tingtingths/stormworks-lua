function onTick()
    pv = input.getNumber(1)
    sp = input.getNumber(2)

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

    output.setNumber(1, offset_pv)
end
