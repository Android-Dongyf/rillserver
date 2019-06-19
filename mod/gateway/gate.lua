

local skynet = require "skynet"
local queue = require "skynet.queue"
local cs = queue()

local log = require "log"

local liblogin = require "liblogin"
local libcenter = require "libcenter"
local libagentpool = require "libwsagentpool"

local gateserver = require "faci.gateserver"


--local snapshot = require "snapshot"
--local snapshot_utils = require "snapshot_utils"
--local construct_indentation = snapshot_utils.construct_indentation
--local print_r = require "print_r"

local connection = {} -- fd -> { fd , ip, uid（登录后有）game（登录后有）key（登录后有）}
local name = "" --gated1

--local S1
--local S2

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
}

local handler = {}

function handler.open(source, conf)
	log.info("start listen port: %d", conf.port)
	name = conf.name
end

function handler.connect(fd, addr)
	local c = {
		fd = fd,
		ip = addr,
		uid = nil,
		agent = nil,
	}
	connection[fd] = c
	gateserver.openclient(fd)
	DEBUG("New client from: ", addr, " fd: ", fd)
end

function handler.message(fd, msg, sz)
	local c = connection[fd]
	local uid = c.uid
	local source = skynet.self()
	if uid then
		--fd为session，特殊用法
		skynet.redirect(c.agent, source, "client", fd, msg, sz)
	else
		local login = liblogin.fetch_login()
		--fd为session，特殊用法
		skynet.redirect(login, source, "client", fd, msg, sz)
	end
end

local CMD = {}

local function close_agent(fd)
	local c = connection[fd]
	if c then
		if c.uid then
			libcenter.logout(c.uid, c.key)

			libagentpool.recycle(c.agent)
			c.agent = nil
		end

		gateserver.closeclient(fd)
	end
	connection[fd] = nil
	--c = nil
	--S2 = snapshot()
	--
	--local diff = {}
	--for k,v in pairs(S2) do
	--	if not S1[k] then
	--		diff[k] = v
	--	end
	--end
	--
	--print_r(diff)
	--local result = construct_indentation(diff)
	--print_r(result)
	return true
end

local function clearAgent(uid, key, agent)
	libcenter.logout(uid, key)

	libagentpool.recycle(agent)
end

--true/false
function CMD.register(source, data)
	local c = connection[data.fd]
	if not c then
		clearAgent( data.uid, data.key, data.agent)
		return false
	end

	c.uid = data.uid
	c.agent = data.agent
	c.key = data.key
	return true
end

--true/false
function CMD.kick(source, fd)
	TRACE("cmd.kick fd:", fd)
	return close_agent(fd)
end

function handler.disconnect(fd)
	TRACE("handler.disconnect fd:", fd)
	return close_agent(fd)
end

function handler.error(fd, msg)
	TRACE("handler.error:", msg)
	handler.disconnect(fd)
end

function handler.warning(fd, size)
	TRACE("handler.warning fd:", fd, " size:", size)
end

function handler.command(cmd, source, ...)
	--DEBUG("gate server handler command:", cmd)
	local f = assert(CMD[cmd])
	return f(source, ...)
end
--S1 = snapshot()
gateserver.start(handler)

