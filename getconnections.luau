getgenv().getconnections(rl) = function()
    -- check if the first argument is a userdata
    if type(rl) ~= "userdata" then
        error("expected userdata as the first argument", 2)
    end

    -- get the 'connect' method from the userdata
    local connect = rl.connect
    if not connect then
        error("userdata does not have a 'connect' method", 2)
    end

    -- call the 'connect' method with the userdata and a blank function
    local signal = connect(rl, function() end)

    -- get the next signal in the linked list
    local next = signal.nextsignal

    -- create a table to store the connections
    local connections = {}
    local count = 1

    -- iterate through the linked list of connections
    while next ~= 0 do
        if connection_environment.connections[next] then
            -- if the connection already exists, reuse it
            table.insert(connections, connection_environment.connections[next])
        else
            -- create a new connection
            local new_connection = {
                object = next,
                oldstate = next.state
            }

            -- store the new connection in the table
            table.insert(connections, new_connection)

            -- add the connection to the global connections table
            connection_environment.connections[next] = new_connection
        end

        -- move to the next signal in the linked list
        next = next.nextsignal
        count = count + 1
    end

    -- call the 'disconnect' method on the signal
    signal:disconnect()

    -- return the table of connections
    return connections
end
