local turtle_utils=require('lib.turtle.utils')

local f=fs.open("dig2x.json", "r")
local config=textutils.unserialiseJSON(f.readAll())
f.close()
for j=1,config["tunnels"] do
    --do tunnel
    local i=0
    while i<config["depth"] do
        turtle_utils.check_fuel()
        turtle.dig()
        if turtle.forward() then i=i+1 end
        turtle.digUp()
        sleep(0)
    end
    turtle.turnLeft()
    turtle.turnLeft()
    i=0
    while i<config["depth"] do
        turtle_utils.check_fuel()
        if turtle.forward() then i=i+1 end
        sleep(0)
    end

    --move
    turtle.up()
    if config["direction"]=="left" then
        turtle.turnLeft()
    else
        turtle.turnRight()
    end
    i=0
    while i<config["turtles"]*3 do
        turtle_utils.check_fuel()
        if turtle.forward() then i=i+1 end
        sleep(0)
    end
    if config["direction"]=="left" then
        turtle.turnRight()
    else
        turtle.turnLeft()
    end
    turtle.down()
end
local spk=peripheral.wrap('left')
spk.playNote('chime')
