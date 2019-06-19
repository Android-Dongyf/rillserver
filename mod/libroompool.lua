local skynet = require "skynet"

local runconf = require(skynet.getenv("runconfig"))
local servconf = runconf.service

local M = {}

local is_init = false
local roompool = {}
local roompool_num = 0

local function init()
	if is_init then
		return
	end
	local node = skynet.getenv("nodename")
	for i,v in pairs(servconf.roompool) do
		if node == v.node then
			table.insert(roompool, string.format("roompool%d", i))
            roompool_num = roompool_num + 1
		end
	end

	is_init = true
end


function M.get()
	init()
    local pool = roompool[math.random(1, roompool_num)]
    return skynet.call(pool, "lua", "get")
end

function M.recycle(room)
	init()
    local pool = roompool[math.random(1, roompool_num)]
    return skynet.call(pool, "lua", "recycle", room)
end

skynet.init(init)

return M


