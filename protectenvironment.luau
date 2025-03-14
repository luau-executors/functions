--[[
  Solaras method of protecting their environment,
]]

local wrappercache = setmetatable({}, {__mode = "k"})

local vulnerableInstances = {
    ...
}

local blockedFunctions = {
    ...
}

local function fixString(str)
    ...
    return fixed
end

local function unwrap(wrapped)
    if type(wrapped) == "table" then
        local real = {}
        for k,v in next,wrapped do
            real[k] = unwrap(v)
        end
        return real
    else
        local real = wrappercache[wrapped]
        if real == nil then
            return wrapped
        end
        return real
    end
end

local function wrap(real)
    for w,r in next,wrappercache do
        if r == real then
            return w
        end
    end

    if type(real) == "userdata" then
        local fake = newproxy(true)
        local meta = getmetatable(fake)
        
        meta.__index = function(self, index)
            index = fixString(index)

            if table.find(blockedFunctions, index) then
                return function(...)
                    warn("Attempt to call blocked function '"..index.."'")
                end
            end

            if _typeof(real) == "Instance" and real.ClassName == "DataModel" then
                if index == "HttpGet" or index == "HttpGetAsync" then
                    return function(self, url)   
                        assert(type(url) == "string", "invalid argument #1 to 'HttpGet' (string expected, got "..type(url)..")")

                        return env.request({
                            Url = url
                        }).Body or ""
                    end

                elseif index == "GetObjects" then
                    return function(self, id)
                        assert(type(id) == "string", "invalid argument #1 to 'HttpGet' (string expected, got "..type(id)..")")

                        return { InsertService:LoadLocalAsset(id) }
                    end
                end
            end

            if index == "Parent" then
                if real.Parent == _game then
                    return env.game
                end

            elseif typeof(real[index] ) then
                return wrap(real[index], env.game)

            elseif type(real[index]) == "function" then
                return function(self, ...)
                    return real[index](real, ...)
                end
            end

            return real[index]
        end

        meta.__newindex = function(s,k,v)
            real[k] = v
        end

        meta.__tostring = function(s)
            return tostring(real)
        end

        wrappercache[fake] = real

        if table.find(vulnerableInstances, tostring(real)) then
            return fake
        end

        return (typeof(real) == "Instance" and real.ClassName ~= "DataModel") and real or fake

    elseif type(real) == "function" then
        local fake = function(...)
            local args = unwrap{...}
            local results = wrap{real(unpack(args))}
            return unpack(results)
        end
        wrappercache[fake] = real
        return fake

    elseif type(real) == "table" then
        local fake = {}
        for k,v in next,real do

            fake[k] = (typeof(v) == "Instance" and v.ClassName ~= "DataModel") and v or wrap(v)
        end
        return fake

    else
        return real
    end
