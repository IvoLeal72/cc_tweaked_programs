local BUFFER_SIZE=23

input = peripheral.wrap('left')

output= peripheral.wrap('right')

function count_items()

    local ctt=0

    for k,v in pairs(input.list()) do

        ctt=ctt+v.count

    end

    return ctt

end

function move_items(ctt)

    local moved=0

    local i=1

    while moved<ctt do

        moved=moved+input.pushItems('right', i, ctt-moved)

        i=i+1

    end

end

function check_time(ctt)

    if ctt~=last_ctt then

        last_update=os.clock()

        last_ctt=ctt

    elseif ctt==last_ctt and os.clock()-last_update>2 then

        move_items(ctt)

    end

end

local last_update=os.clock()

local last_ctt=0

while true do

    local ctt=count_items()

    if ctt>=BUFFER_SIZE then

        move_items(BUFFER_SIZE)

    else check_time(ctt) end

    sleep(0.5)

end
