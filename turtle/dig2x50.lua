function check_fuel()
    while turtle.getFuelLevel()<10 do
        turtle.refuel()
        slot=turtle.getSelectedSlot()
        slot=slot+1
        if slot>16 then slot=1 end
        turtle.select(slot)
        sleep(1)
    end
end

i=0
while i<50 do
    check_fuel()
    turtle.dig()
    if turtle.forward() then i=i+1 end
    turtle.digUp()
    sleep(0)
end
spk=peripheral.wrap('left')
spk.playNote('chime')
