local function check_fuel()
    local slot=turtle.getSelectedSlot()
    while turtle.getFuelLevel()<10 do
        turtle.refuel()
        slot=turtle.getSelectedSlot()
        slot=slot+1
        if slot>16 then slot=1 end
        turtle.select(slot)
        sleep(0)
    end
    x=turtle.select(slot)
    
end

return {check_fuel=check_fuel}