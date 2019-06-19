local skynet = require "skynet"
local queue = require "skynet.queue"
local cs = queue()

local log = require "log"
local libcenter = require "libcenter"
local libsocket = require "libsocket"
require "libstring"

local protopack = require "protopack"
local env = require "faci.env"

require "agent.agent_init"



local CMD = {}

local gate
local fd
local account


local default_dispatch
local service_dispatch
local dispatch


function default_dispatch(cmd, msg)
    local cb = env.dispatch[cmd]
    if type(cb) ~= "function" then
        ERROR("====== wsagent default_dispatch not found ========", inspect(account))
        return
    end
    -- DEBUG("%%%%default_dispatch%%%%%%%%", cmd, inspect(msg))
    local ret 
	local ok, msg = xpcall(function()
		ret = cb(msg)
	end, debug.traceback) 
	if not ok then
		error(msg)
    end
    return ret 
end

function service_dispatch(service_name, cmd, msg)
    local player = env.get_agent()
    local room_id = player.ext_info.room_id
    local service = env.service[room_id]
    if not service then
        ERROR("====== wsagent service_dispatch cmd not found ========", inspect(account), '   =======', inspect(env.service),'  room_id: ', room_id)
        return
    end
    
	local uid = player.base_info.uid
	local id = service.id
	local adress = service.adress
    return skynet.call(adress, "lua", "client_forward", "roomAction", "request", uid, cmd, msg)
end

function dispatch(_, _, str)
    local cmd, check, msg = protopack.unpack(str)
    local cmdlist = string.split(cmd, ".") 
    local length = #cmdlist
    local ret
    local r_msg
    if length == 2 then
        ret, r_msg = service_dispatch(cmdlist[1], cmdlist[2], msg)
    elseif length == 1 then
        ret = default_dispatch(cmd, msg)
    end
    if ret then
        if r_msg then
            CMD.send2client(r_msg)
        else
            CMD.send2client(ret)
        end
    end
end

skynet.register_protocol{
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = skynet.tostring,
	dispatch = dispatch, 
}

function CMD.start(conf)
	gate = conf.gate
	fd = conf.fd
    account = conf.account

    return env.login(account)
end

function CMD.agent_info()
    return env.get_agent()
end


function CMD.disconnect()
	--DEBUG("-------agent disconnect exit uid("..account.uid..")------")
    env.logout(account)
    return true
end

function CMD.kick(...)
    --local uid = select(1, ...)
    --DEBUG("-------agent kick exit uid("..uid..")------")
    --DEBUG("-------agent kick exit uid("..account.uid..")------")
	local kick=env.dispatch["kick_room"]
	kick()
    env.logout(account)
    return true
end 

function CMD.send2client(msg)
    local cmd = msg._cmd
	local check = msg._check
	msg._cmd = nil
	msg._check = nil
	local data = protopack.pack(cmd, check, msg)
	libsocket.send(fd, data)
end


skynet.start(function()
    -- If you want to fork a work thread , you MUST do it in CMD.login
	skynet.dispatch("lua",function(_, _, cmd, ...)
        local f = assert(CMD[cmd], cmd)
        skynet.retpack(cs(f, ...))
	end)
end)
