turtle.select(1)
while true do
    while turtle.getItemCount()<4 do
        turtle.select(turtle.getSelectedSlot()+1)
    end
    if turtle.placeDown() then
        -- go to second chest and place it
        turtle.up()
        turtle.forward()
        turtle.placeDown()
        -- go to third chest and place it
        turtle.up()
        turtle.forward()
        turtle.placeDown()
        -- go to fourth chest and place it
        turtle.up()
        turtle.back()
        turtle.placeDown()
        -- go to next loop position
        turtle.back()
        turtle.down()
        turtle.down()
        turtle.down()
        turtle.turnRight()
        if not turtle.forward() then
            break
        end
        turtle.turnLeft()
    else
        turtle.turnRight()
        if not turtle.forward() then
            break
        end
        turtle.turnLeft()
    end
end