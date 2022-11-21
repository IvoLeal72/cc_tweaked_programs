local turtle_utils = require('lib.turtle.utils')

local expect_m = require('cc.expect')
local expect, field, range = expect_m.expect, expect_m.field, expect_m.range

local PING_MAX_TIME = 5000
local controller = -1
local connected = false
local ping_timer = nil

local queue = {}

local function dig_1x2(cmd_table)
    expect(1, cmd_table, "table")
    field(cmd_table, "depth", "number")
    depth = cmd_table["depth"]
    range(depth, 0)

    local i = 0
    while i < depth do
        turtle_utils.check_fuel()
        turtle.dig()
        if turtle.forward() then i = i + 1
        else turtle.attack() end
        turtle.digUp()
        sleep(0)
    end

    turtle.turnLeft()
    turtle.turnLeft()

    i = 0
    while i < depth do
        turtle_utils.check_fuel()
        if turtle.forward() then i = i + 1
        else
            turtle.dig()
            turtle.attack()
        end
        sleep(0)
    end
end

local function move(cmd_table)
    expect(1, cmd_table, "table")
    field(cmd_table, "left", "boolean")
    left = cmd_table["left"]
    field(cmd_table, "ammount", "number")
    ammount = cmd_table["ammount"]
    range(ammount, 0)

    turtle.up()
    if left then
        turtle.turnRight()
    else
        turtle.turnLeft()
    end
    i = 0
    while i < ammount * 3 do
        turtle_utils.check_fuel()
        if turtle.forward() then i = i + 1
        else turtle.attack() end
        sleep(0)
    end
    if left then
        turtle.turnRight()
    else
        turtle.turnLeft()
    end
    turtle.down()
end

local function cmd_response(cmd_table, return_value)
    rednet.send(controller, { ["task_id"] = cmd_table["task_id"], ["return"] = return_value }, "turtle_command_response")
end

local function disconnect()
    if ping_timer ~= nil then
        os.cancelTimer(ping_timer)
        ping_timer = nil
    end
    connected = false
    os.setComputerLabel("disconnected (id:" .. os.getComputerID() .. ")")
end

local function queue_cmd(cmd_table)
    table.insert(queue, cmd_table)
    os.queueEvent("new_cmd")
end

local function refresh_ping_timer()
    if ping_timer ~= nil then
        os.cancelTimer(ping_timer)
    end
    ping_timer = os.startTimer(PING_MAX_TIME)
end

local function process_cmd(cmd_table)
    expect(1, cmd_table, "table")
    action = cmd_table["action"]

    if action == "locate" then cmd_response(cmd_table, gps.locate())
    elseif action == "ping" then
        refresh_ping_timer()
        cmd_response(cmd_table, true)
    elseif action == "disconnect" then
        cmd_response(cmd_table, true)
        disconnect()
    else
        queue_cmd(cmd_table)
    end
end

local function try_connect(id)
    rednet.send(id, os.getComputerID(), "turtle_miner_connect")
    new_id, msg = rednet.receive("turtle_miner_connect_response")
    if new_id == id then
        controller = id
        connected = true
        os.setComputerLabel(msg)
        refresh_ping_timer()
    end
    rednet.send(controller, true, "turtle_miner_connect_confirm")
end

local function coms_thread()
    disconnect()
    rednet.open("left")
    while true do
        if not connected then --disconnected
            id = rednet.receive("turtle_miner_search")
            if controller < 0 or id == controller then
                try_connect(id)
            end
        else --connected
            event, id, msg, protocol = os.pullEvent()
            if event == "rednet_message" then
                if id == controller and protocol == "turtle_miner_command" then process_cmd(msg) end
            elseif event == "timer" then
                if id == ping_timer then
                    disconnect()
                end
            end
        end
    end
end

local function queue_thread()
    while true do
        if #queue > 0 then
            cmd_table = table.remove(queue, 0)
            action = cmd_table["action"]
            valid_cmd = true
            if action == "dig_1x2" then
                dig_1x2(cmd_table)
            elseif action == "move" then
                move(cmd_table)
            else
                valid_cmd = false
            end
            if controller >= 0 then
                cmd_response(cmd_table, valid_cmd)
            end
        else
            os.pullEvent("new_cmd")
        end
    end
end

parallel.waitForAny(queue_thread, coms_thread)
