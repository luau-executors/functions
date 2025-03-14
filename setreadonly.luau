local function setreadonly(instance, protected)
    if type(instance) ~= "table" then
        error("Expected a table as the first argument", 2)
    end

    if protected then
        local metatable = getmetatable(instance) or {}
        metatable.__newindex = function(t, k, v)
            error("Attempt to modify a read-only table", 2)
        end
        metatable.__index = instance -- Allow reading
        setmetatable(instance, metatable)
    else
        local metatable = getmetatable(instance)
        if metatable then
            metatable.__newindex = nil 
            setmetatable(instance, metatable)
        end
    end

    return true
end
