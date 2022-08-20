local function next_idx_wrap(idx, max_value)
    idx=idx+1
    if idx>max_value then idx=1 end
    return idx
end

return {next_idx_wrap=next_idx_wrap}