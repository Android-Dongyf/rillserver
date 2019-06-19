local skynet = require "skynet"
local log = require "log"
local env = require "faci.env"

local libcenter = require "libcenter"
local libdbproxy = require "libdbproxy"

local runconf = require(skynet.getenv("runconfig"))
local games_common = runconf.games_common

local libmodules = {}

--local function init_modules()
--	setmetatable(libmodules, {
--		__index = function(t, k)
--			local mod = games_common[k]
--			if not mod then
--				return nil
--			end
--			local v = require(mod)
--			t[k] = v
--			return v
--		end
--	})
--end
--init_modules() -- local libmove = require "libmove"

local M = env.dispatch
local service = env.service
local room_id = nil --房间id
local create_id = nil 
local lib = nil
local cur_game=nil

local function cal_lib()
	return require "libroom"
end


function M.create_room(msg) 
	lib = cal_lib(msg.game)
	if not lib then
		ERROR("game not found: ", msg.game)
		msg.error = "game not found"
		return 
	end 
	create_id = libdbproxy.inc_room()
	--create_id=1000000
	local res, addr, roomInfo = lib.create(create_id, msg.game)
	local roomAddr = roomInfo.addr
	service[create_id] = {
		id = 'request',
		adress = roomAddr
	}

	local player = env.get_agent()
	player.ext_info.room_id = create_id

	msg.result = 0
	msg.room_id = create_id
	return msg 
end 

function M.enter_room(msg)
	if room_id then
		INFO("enter room fail, already in room")
		return msg
	end
	if not lib then
		lib=cal_lib(msg.game)
	end
	--暂时 这样处理
	--if not msg.id and create_id then
	--	msg.id = create_id
	--end 
	--msg.id=1000000
	msg.id = tonumber(msg.id)
	if not msg.id then
		ERROR("enter room msg.id is nil")
		msg.error="msg.id is nil"
		msg.result=-1
		return msg
	end

	local data = {
		uid = env.get_agent().base_info.uid,
		agent = skynet.self(),
		--node = node,
	}
	local isok, forward, roomInfo = lib.enter(msg.id, data)
	if isok then
		cur_game=msg.game
		msg.result = 0
		room_id = msg.id

		local player = env.get_agent()
		player.ext_info.room_id = room_id

		service[room_id] = {
			id = 'request',
			adress = roomInfo.addr
		}
	else
		if forward then
			msg.code=forward
		end
		msg.result = 1
	end
	return msg
end

function M.leave_room(msg)
	if not room_id then
		msg.error="not found room"
		msg.result=-1
		return
	end
	if not lib then
		lib=cal_lib(msg.game)
	end

	local uid = env.get_agent().base_info.uid
    if lib.leave(room_id, uid) then
		service[room_id] = nil
		room_id = nil
		local player = env.get_agent()
		player.ext_info.room_id = 0
	end
	msg.result=0
	return msg
end

--踢人或掉线时,对房间的清理操作
function M.kick_room()
	if not room_id then
		DEBUG("kick room,room id is nil")
		return
	end
	if not lib and cur_game then
		lib=cal_lib(cur_game)
	end

	local uid = env.get_agent().base_info.uid
	if lib.leave(room_id,uid) then
		service[room_id] = nil
		room_id = nil
		local player = env.get_agent()
		player.ext_info.room_id = 0
		--DEBUG("kick room,uid:"..uid)
	end
end

