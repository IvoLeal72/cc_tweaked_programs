other_pc=peripheral.find('computer')
other_pc.turnOn()
rednet.open('bottom')

function check_net()
    while true do
        id, msg=rednet.receive('train_control')
        if id==other_pc.getID() then
            if msg=='start' then
                rednet.send(id, 'started', 'train_control')
                rs.setOutput('back', true)
            end
            if msg=='started' then
                rs.setOutput('back', true)
            end
            sleep(1)
            rs.setOutput('back', false)
        end
    end
end

function check_rs()
    while true do
        os.pullEvent('redstone')
        if rs.getInput('top') then
            rednet.send(other_pc.getID(), 'start', 'train_control')
        end
    end
end

parallel.waitForAny(check_rs, check_net)
