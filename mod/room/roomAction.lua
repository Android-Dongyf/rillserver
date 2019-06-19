local env = require "faci.env"
local faci = require "faci.module"

local module = faci.get_module("roomAction")
local dispatch = module.dispatch
local forward = module.forward


local ROOM 

function dispatch.start(...)
    local room_type = select(1, ...)

    local module = room_type .. ".room"
    ROOM = require(module):new()
    ROOM:roomInit(room_type)
end 

function dispatch.enter(data)
    --TODO:判断超过人数上限
    if ROOM:is_player_num_overload() then
		ERROR("enter err player num overload")
        return false, DESK_ERROR.player_no_seat
    end 

	return ROOM:enter(data)
end

function dispatch.leave(uid)
	return ROOM:leave(uid)
end

function forward.request(...)
    ROOM:onRequest(...)
    local cmd = select(2, ...)
    return {_cmd = cmd, status = '成功'}
end