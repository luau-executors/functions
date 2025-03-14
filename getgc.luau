local function getgc()
    local gc = {}

    -- get the global environment
    local globalenv = getgenv()

    -- iterate through the global environment
    for _, v in pairs(globalenv) do
        if type(v) == "function" or type(v) == "table" then
            table.insert(gc, v)
        end
    end

    -- optionally, iterate through loaded modules (exploit-specific)
    if getloadedmodules then
        for _, module in pairs(getloadedmodules()) do
            for _, v in pairs(module) do
                if type(v) == "function" or type(v) == "table" then
                    table.insert(gc, v)
                end
            end
        end
    end

    -- optionally, iterate through nil instances (most exploits have this i think)
    if getnilinstances then
        for _, instance in pairs(getnilinstances()) do
            for _, v in pairs(instance) do
                if type(v) == "function" or type(v) == "table" then
                    table.insert(gc, v)
                end
            end
        end
    end

    return gc
end
