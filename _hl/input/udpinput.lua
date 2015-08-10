-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

local socket = require "socket"
require "table"

local address = read_config("address") or "127.0.0.1"
local port = read_config("port") or 8125

local server = assert(socket.udp())
assert(server:setsockname(address, port))
server:settimeout(0)

local sockets = {server}

function process_message()
    while true do
        local ready = socket.select(sockets, nil, 1)
        if ready then
            for _, s in ipairs(ready) do
                if s == server then
                    local buffers = {}
                    while true do 
                        local buf, err = s:receive()
                        if buf == nil then break end
                        table.insert(buffers, buf)
                    end
                    for line in table.concat(buffers):gmatch("[^\r\n]+") do
                        inject_message({
                            Type = 'udp' .. port,
                            Payload = line .. '\n'
                        })
                    end
                end
            end
        end
    end
    return 0
end
