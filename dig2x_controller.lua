local PROTOCOL_NAME = 'remote_dig'
local status = {DISCONNECTED = 'DISCONNECTED', 
                CONNECTING = 'CONNECTING', 
                CONNECTED = 'CONNECTED',
                DIGGING = 'DIGGING',
                MOVING = 'MOVING'}
local utils = require('lib.utils')

local names = {
    'Fenrir',
    'Odin',
    'Freya',
    'Karthus',
    'Ares',
    'Apollo',
    'Zeus',
    'Poseidon',
    'Hades',
    'Chronus',
    'Baco',
    'Nautilus',
    'Artemis',
    'Ornn',
    'Zed',
    'Thor',
    'Loki'
}

local function table_count(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

local turtles = {}
local run = true

local direction = 'left'
local depth = 60

local function send_cmd(func, args, turtle_id)
    local turtle = turtles[turtle_id]
    if turtle == nil then
        return nil
    end
    local job_id = turtle.last_job_id + 1
    local job = {
        id = job_id,
        func = func,
        args = args,
        ts = os.time()
    }
    turtle.pending_cmds[job_id] = job
    rednet.send(turtle_id, job, PROTOCOL_NAME)
end

local function gen_random_name()
    if table_count(turtles) >= #names then
        return nil
    end
    while true do
        local name = names[math.random(#names)]
        local ok = true
        for _, v in ipairs(turtles) do
            if v.name == name then
                ok = false
                break
            end
        end
        if ok then
            return name
        end
    end
end

local function msg_handler(id, msg)
    print(id .. ' ' .. textutils.serialise(msg))
    local turtle = turtles[id]
    if turtle == nil then
        return
    end

    if msg.id == nil then
        return
    end

    local job = turtle.pending_cmds[msg.id]
    if job == nil then
        return
    end

    local func = job.func
    local args = job.args
    local ret = msg.return_value

    if func == 'connect' then
        if turtle.status == status.CONNECTING then
            turtle.status = status.CONNECTED
            turtle.name = ret
            table.remove(turtle.pending_cmds, msg.id)
        end
    elseif func == 'dig' then
        if ret == nil then
            turtle.status = status.DIGGING
        else
            turtle.status = status.CONNECTED
            table.remove(turtle.pending_cmds, msg.id)
        end
    elseif func == 'move' then
        if ret == nil then
            turtle.status = status.MOVING
        else
            turtle.status = status.CONNECTED
            table.remove(turtle.pending_cmds, msg.id)
        end
    end
end

local function list_turtles()
    for k, v in pairs(turtles) do
        print(k .. ' ' .. v.name .. ' ' .. v.status)
    end
end



local function scan_mode()
    while true do
        utils.clearAndResetTerm()
        print('Searching for turtles...')
        print('Press "q" to stop')
        table.sort(turtles)
        list_turtles()
        rednet.broadcast({
            id = 0,
            func = 'search',
            args = nil
        }, PROTOCOL_NAME)
        local timer = os.startTimer(2)
        local event_data = { os.pullEvent() }
        local event = event_data[1]
        if event == 'rednet_message' then
            os.cancelTimer(timer)
            local id, msg = event_data[2], event_data[3]
            if id ~= nil then
                if msg.id == 0 then
                    if msg.return_value == true then
                        if turtles[id] ~= nil then
                            send_cmd('connect', turtles[id].name, id)
                        else
                            local name = gen_random_name()
                            if name ~= nil then
                                turtles[id] = {
                                    status = status.CONNECTING,
                                    name = name,
                                    last_job_id = 0,
                                    pending_cmds = {}
                                }
                                send_cmd('connect', name, id)
                            end
                        end
                    end
                else
                    msg_handler(id, msg)
                end
            end
        elseif event == 'char' then
            local character = event_data[2]
            if character == 'q' then
                return
            end
        end
    end
end

local function change_direction()
    if direction=='left' then
        direction ='right'
    else 
        direction = 'left' 
    end
end

local function set_depth()
    write('depth: ')
    local msg=read()
    local depth_num=tonumber(msg)
    if depth_num ~= nil then
        depth=depth_num
    end
end

local function dig()
    for k, v in pairs(turtles) do 
        send_cmd('dig', depth, k)
    end
end

local function move()
    for k, v in pairs(turtles) do 
        send_cmd('move', {direction = direction, ammount = table_count(turtles)}, k)
    end
end


local function main_menu()
    while true do
        utils.clearAndResetTerm()
        utils.write_center('Turtle Controller')
        term.setCursorPos(1,3)
        print(string.format('direction: %s, depth: %d, turtles: %d', direction, depth, table_count(turtles)))
        list_turtles()
        print('q -> quit')
        print('r -> change direction')
        print('t -> set depth')
        print('s -> scan mode')
        print('d -> dig')
        print('m -> move')
        local timer = os.startTimer(2)
        local event_data = { os.pullEvent() }
        local event = event_data[1]
        if event == 'char' then
            os.cancelTimer(timer)
            local character = event_data[2]
            if character == 'q' then break
            elseif character == 's' then scan_mode()
            elseif character == 'd' then dig()
            elseif character == 'm' then move()
            elseif character == 'r' then change_direction()
            elseif character == 't' then set_depth()
            end
        elseif event == 'rednet_message' then
            os.cancelTimer(timer)
            msg_handler(event_data[2], event_data[3])
        end
    end
end

local function startup()
    utils.rednet_all_modems()
    rednet.broadcast({ func = 'disconnect', args = {}, id = 0 }, PROTOCOL_NAME)
    term.setCursorPos(1, 1)
    term.clear()
    term.setCursorPos(1, 1)
    print('Starting...')
    sleep(1)
    turtles = {}
end

startup()
main_menu()
for k, _ in pairs(turtles) do
    send_cmd('disconnect', nil, k)
end
