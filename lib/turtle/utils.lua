local utils=require('lib.utils')

local turtle_utils={}

function turtle_utils.next_slot_wrap()
    turtle.select(utils.next_idx_wrap(turtle.getSelectedSlot(), 16))
end

function turtle_utils.check_fuel()
    local slot=turtle.getSelectedSlot()
    while turtle.getFuelLevel()<10 do
        turtle.refuel()
        utils.next_slot_wrap()
        sleep(0)
    end
    turtle.select(slot)
end

return turtle_utils