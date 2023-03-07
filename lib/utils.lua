local utils = {}

function utils.next_idx_wrap(idx, max_value)
    idx=idx+1
    if idx>max_value then idx=1 end
    return idx
end

function utils.rednet_all_modems()
    peripheral.find('modem', function (name, _)
        rednet.open(name)
    end)
end

function utils.clearAndResetTerm()
    term.clear()
    term.setCursorPos(1,1)
end

function utils.write_center(text)
    local x, y = term.getCursorPos()
    local width, height = term.getSize()
    term.setCursorPos(math.floor((width - #text) / 2) + 1, y)
    term.write(text)
  end

return utils