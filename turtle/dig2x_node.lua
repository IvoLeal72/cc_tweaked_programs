local PROTOCOL_NAME = 'remote_dig'
local turtle_utils = require('lib.turtle.utils')
local utils = require('lib.utils')

local server_id = nil

local command_buffer = {}
local command_resp_buffer = {}

local function dig2x(depth)
    local i = 0
    while i < depth do
        turtle_utils.check_fuel()
        turtle.dig()
        if turtle.forward() then
            i = i + 1
        else
            turtle.attack()
        end
        turtle.digUp()
        sleep(0)
    end
    turtle.turnLeft()
    turtle.turnLeft()
    i = 0
    while i < depth do
        turtle_utils.check_fuel()
        if turtle.forward() then
            i = i + 1
        else
            turtle.dig()
            turtle.attack()
        end
        sleep(0)
    end
    return true
end

local function moveToNextTunnel(args)
    turtle.up()
    if args.direction == "left" then
        turtle.turnRight()
    else
        turtle.turnLeft()
    end
    local i = 0
    while i < args.ammount * 3 do
        turtle_utils.check_fuel()
        if turtle.forward() then i = i + 1 end
        sleep(0)
    end
    if args.direction == "left" then
        turtle.turnRight()
    else
        turtle.turnLeft()
    end
    turtle.down()
    return true
end

local function disconnect(args)
    return true
end

local function_map = {
    dig = dig2x,
    move = moveToNextTunnel,
    disconnect = disconnect
}

local function function_runner()
    while true do
        while #command_buffer ~= 0 do
            local data = table.remove(command_buffer, 0)
            local ret = function_map[data.func](data.args)
            table.insert(command_resp_buffer, {
                ['id'] = data.id,
                ['return_value'] = ret,
                ['func'] = data.func
            })
            os.queueEvent('new_response')
            if data.func == 'disconnect' then
                return
            end
        end
        os.pullEvent('new_cmd')
    end
end

local function send_response(id, return_value)
    rednet.send(server_id, {
        id = id,
        return_value = return_value
    }, PROTOCOL_NAME)
end

local function rednet_handler()
    while true do
        local id, msg = rednet.receive(PROTOCOL_NAME)
        if id == server_id then
            if msg.func == 'ping' then
                send_response(msg.id, true)
            elseif msg.func == 'locate' then
                send_response(msg.id, gps.locate())
            elseif function_map[msg.func] ~= nil then
                table.insert(command_buffer, msg)
                os.queueEvent('new_cmd')
            end

            if msg.func == 'disconnect' then
                return
            end
        end
    end
end

local function response_sender()
    while true do
        while #command_resp_buffer ~= 0 do
            local data = table.remove(command_resp_buffer, 0)
            send_response(data.id, data.return_value)
            if data.func == 'disconnect' then
                return
            end
        end
        os.pullEvent('new_response')
    end
end

local function connect()
    utils.rednet_all_modems()

    command_buffer = {}
    command_resp_buffer = {}

    while true do
        local id, msg = rednet.receive(PROTOCOL_NAME)
        if msg.func == 'search' then
            server_id = id
            send_response(msg.id, true)
        elseif msg.func == 'connect' and id==server_id then
            os.setComputerLabel(msg.args)
            send_response(msg.id, msg.args)
            return
        end
    end
end

os.setComputerLabel('waiting... (id='..os.getComputerID()..')')
connect()
print('left connect')
parallel.waitForAll(response_sender, function_runner, rednet_handler)
os.setComputerLabel(nil)