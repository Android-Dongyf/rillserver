local skynet = require "skynet.manager"
local log = require "log"

local CMD = {}

local pool = {}	 -- the least agent
local roomlist = {} -- all of agent, include dispatched
local roomname = nil
local maxnum = nil
local recyremove = nil 
local brokecachelen = nil


local name, id = ...
log.set_name(name..id)
local roomIdx = 1

local function selectRoomIdx()
	local has = false
	while true do
		for k, v in pairs(roomlist) do
			--DEBUG("roomIdx: ", roomIdx, "  id: ", v.id)
			if roomIdx == v.id then
				has = true
				roomIdx = roomIdx + 1
			end
		end
		if not has then
			break
		else
			has = false
		end
	end
end

function CMD.init_pool(cnf)
	roomname = cnf.roomname
	maxnum = cnf.maxnum
	recyremove = cnf.recyremove
	brokecachelen = cnf.brokecachelen
	for i = 1, maxnum do
		selectRoomIdx()
		--DEBUG("roomIdx: ", roomIdx)
		local idx = roomIdx
		roomIdx = roomIdx + 1
		local room = skynet.newservice(roomname, "room", idx)
		table.insert(pool, room)
		local isReset = false
		if roomIdx == 99999999999 then
			roomIdx = 1
			isReset = true
		end
		roomlist[room] = {
			room = room,
			id = roomIdx - 1
		}
		if isReset then
			roomlist[room].id = 99999999999 - 1
		end
	end
end 

function CMD.get()
	local room = table.remove(pool)
	if not room then
		selectRoomIdx()
		local idx = roomIdx
		roomIdx = roomIdx + 1
		room = assert(skynet.newservice(roomname, "room", idx))
		local isReset = false
		if roomIdx == 99999999999 then
			roomIdx = 1
			isReset = true
		end
		roomlist[room] = {
			room = room,
			id = roomIdx - 1
		}
		if isReset then
			roomlist[room].id = 99999999999 - 1
		end
	end
	
	return room
end

function CMD.recycle(room)
	assert(room)
	
	if recyremove == 1 and #pool >= maxnum then
		roomlist[room] = nil
		skynet.kill(room)
	else
		table.insert(pool, 1, room)
	end
end

skynet.start(function()
	skynet.dispatch("lua", function (_, address, cmd, ...)
		local f = assert(CMD[cmd])
		skynet.ret(skynet.pack(f(...)))
	end)

end)

