local PROTOCOL_NAME = 'remote_dig'
local status = { DISCONNECTED = 'DISCONNECTED', CONNECTING = 'CONNECTING', CONNECTED = 'CONNECTED' }
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

local turtles = {}

local function send_cmd(func, args, turtle_id)
    local turtle=turtles[turtle_id]
    if turtle==nil then
        return nil
    end
    local job_id=turtle.last_job_id+1
    local job={
        func=func,
        args=args
    }
    turtle.pending_cmds[job_id]=job
    rednet.send(turtle_id, job, PROTOCOL_NAME)
end

local function gen_random_name()
    if #turtles >= #names then
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
    print(id..' '..textutils.serialise(msg))
    local turtle = turtles[id]
    if turtle==nil then
        return
    end

    if msg.id==nil then
        return
    end

    local job=table.remove(turtle.pending_cmds, msg.id)
    if job==nil then
        return
    end

    local func=job.func
    local args=job.args
    local ret=msg.ret

    if func=='connect' then
        turtle.status=status.CONNECTED
        turtle.name=ret
    end
end

local function list_turtles()
    for k,v in pairs(turtles) do
        print(k .. ' ' .. v.name .. v.status)
    end
end

local function scan_mode()
    while true do
        utils.clearAndResetTerm()
        print(os.clock())
        print('Searching for turtles...')
        print('Press "q" to stop')
        table.sort(turtles)
        list_turtles()
        rednet.broadcast({
            id = 0,
            func = 'search',
            args = nil
        }, PROTOCOL_NAME)
        local timer=os.startTimer(2)
        local event_data={os.pullEvent()}
        local event=event_data[1]
        if event == 'rednet_message' then
            os.cancelTimer(timer)
            local id, msg=event_data[2], event_data[3]
            if id ~= nil then
                if msg.id==0 then
                    if msg.return_value==true then
                        local name = gen_random_name()
                        if name ~= nil then
                            turtles[id] = {
                                status = status.CONNECTING,
                                name = name,
                                last_job_id=0,
                                pending_cmds = {}
                            }
                            send_cmd('connect', name, id)
                        end
                    end
                else
                    msg_handler(id, msg)
                end
            end
        elseif event == 'char' then
            local character=event_data[2]
            if character == 'q' then
                return
            end
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
    scan_mode()
    utils.clearAndResetTerm()
    list_turtles()
end

startup()