require "string"
require "table"

local path = read_config('path') or error ('you must initialize "path" option')

local lines = {}

function process_message()
    local timestamp = read_message('Timestamp')
    if timestamp == nil then
        return -1, "Timestamp can't be nil"
    end
    local timestr = string.format("%d", timestamp/1e9)

    while true do
	typ, key, value = read_next_field()
	if not typ then break end
        -- exclude bytes and internal fields starting with '_' char
	if typ ~= 1 and key:match'^(.)' ~= '_' then
            table.insert(lines, table.concat({
                key,
                value,
                timestr
            }, " ") .. '\n')
	end
    end

    return 0
end

function timer_event(ns)
    if next(lines) ~= nil then
        local fh = assert(io.open(path, "a"))
        fh:write(table.concat(lines, ''))
        fh:close()
        lines = {}
    end

    return 0
end
