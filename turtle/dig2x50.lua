local turtle_utils=require('lib.turtle.utils')

local i=0
while i<50 do
    turtle_utils.check_fuel()
    turtle.dig()
    if turtle.forward() then i=i+1 end
    turtle.digUp()
    sleep(0)
end
local spk=peripheral.wrap('left')
spk.playNote('chime')
