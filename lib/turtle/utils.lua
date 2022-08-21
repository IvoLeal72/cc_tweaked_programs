local utils=require('lib.utils')

local function next_slot_wrap()
    turtle.select(utils.next_idx_wrap(turtle.getSelectedSlot(), 16))
end

local function check_fuel()
    local slot=turtle.getSelectedSlot()
    while turtle.getFuelLevel()<10 do
        turtle.refuel()
        next_slot_wrap()
        sleep(0)
    end
    turtle.select(slot)
end

return {next_slot_wrap=next_slot_wrap, check_fuel=check_fuel}