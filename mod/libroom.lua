local skynet = require "skynet"
local log = require "log"
local M = {}

local runconf = require(skynet.getenv("runconfig"))
local gpconf = runconf.gp
local MAX_GLOBAL_COUNT = #gpconf.global


local function fetch_global(id)
    if not id then
        return gpconf.global[1]
    end
    local index = id % MAX_GLOBAL_COUNT + 1
    return gpconf.global[index]
end

local function call(cmd, id, ...)
    local global = fetch_global()
    if not global then
        ERROE("cmd:"..cmd..",id:"..id.." is nil")
        return false
    end
    return skynet.call(global, "lua", cmd, id, ...)
end


function M.create(id, room_type)
    local ret, addr, roomInfo =call("roomManager.create", id, room_type)
    return ret, addr, roomInfo
end

function M.enter(id, uid, data)
    return call("roomManager.enter", id, uid, data)
end

function M.leave(id, uid)
    return call("roomManager.leave", id, uid)
end

function M.get_forward(id)
    return fetch_global(id)
end


return M
