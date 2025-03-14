function hookfunction(func, rep)
    -- iterate through all objects in garbage collection
    for _, obj in pairs(getgc()) do
        -- check if the object is a function or a table
        if type(obj) == "function" then
            -- if the object matches the target function, replace it
            if obj == func then
                obj = rep
            end
        elseif type(obj) == "table" then
            -- iterate through the table to find and replace the function
            for k, v in pairs(obj) do
                if v == func then
                    obj[k] = rep
                end
            end
        end
    end
    return rep
end
