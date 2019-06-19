local skynet = require "skynet"

local timer = {}

function timer.new(self)
	local t = {}

	setmetatable(t, self)

	self.__index = self

	return t
end

function timer.init(self, interval)
	if not interval then
		interval = 100
	end

	self.inc = 0

	self.once = false

	self.interval = interval

	self.timer_idx = 0

	self.callbacks = {}

	self.timer_idxs = {}

	skynet.timeout(self.interval, function()
		self:on_time_out()
	end)
end

function timer.on_time_out(self)
	skynet.timeout(self.interval, function()
		self:on_time_out()
	end)

	self.inc = self.inc + 1

	local callbacks = self.callbacks[self.inc]

	if not callbacks then
		return
	end
	for idx, cb in pairs(callbacks) do
		cb.func(cb.parms)
		local sec = self.timer_idxs[idx].sec
		self.timer_idxs[idx] = nil
		if not self.once then
			--skynet.error('idx: ' .. idx)
			--skynet.error('sec: ' .. sec)
			self:register(sec, cb.func, cb.loop, cb.parms)
		end
	end
	self.callbacks[self.inc] = nil
end

function timer.register(self, sec, f, loop,parms)
	assert(type(sec) == "number" and sec > 0)

	local delay = self.inc + sec

	self.timer_idx = self.timer_idx + 1

	self.timer_idxs[self.timer_idx] = {
		delay = delay,
		sec = sec
	}

	if not self.callbacks[delay] then
		self.callbacks[delay] = {}
	end

	local callbacks = self.callbacks[delay]

	if not loop then
		loop = false
	end

	local cb={}
	cb.func=f
	cb.parms=parms
	cb.loop=loop
	callbacks[self.timer_idx] =cb
	return self.timer_idx
end

function timer.registerOnce(self, sec, f, loop,parms)
	assert(type(sec) == "number" and sec > 0)

	local delay = self.inc + sec

	self.timer_idx = self.timer_idx + 1

	self.timer_idxs[self.timer_idx] = {
		delay = delay,
		sec = sec
	}

	if not self.callbacks[delay] then
		self.callbacks[delay] = {}
	end

	local callbacks = self.callbacks[delay]

	if not loop then
		loop = false
	end

	self.once = true

	local cb={}
	cb.func=f
	cb.parms=parms
	cb.loop=loop
	callbacks[self.timer_idx] =cb
	return self.timer_idx
end

function timer.unregister(self, idx)
	local sec = self.timer_idxs[idx]

	if not sec then
		return
	end

	local callbacks = self.callbacks[sec]

	callbacks[idx] = nil

	self.timer_idxs[idx] = nil
end

return timer
