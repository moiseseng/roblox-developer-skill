--!strict
-- Minimal signal. Handlers run in their own thread so one failing handler never blocks the others.

type Handler = { fn: (...any) -> (), once: boolean }

export type Connection = {
	Connected: boolean,
	Disconnect: (self: Connection) -> (),
}

local Signal = {}
Signal.__index = Signal

export type Signal = typeof(setmetatable({} :: { _handlers: { Handler } }, Signal))

function Signal.new(): Signal
	return setmetatable({ _handlers = {} }, Signal)
end

local function connect(self: Signal, fn: (...any) -> (), once: boolean): Connection
	local handler: Handler = { fn = fn, once = once }
	table.insert(self._handlers, handler)
	local connection = {} :: Connection
	connection.Connected = true
	connection.Disconnect = function(conn: Connection)
		if not conn.Connected then
			return
		end
		conn.Connected = false
		local index = table.find(self._handlers, handler)
		if index then
			table.remove(self._handlers, index)
		end
	end
	return connection
end

function Signal.Connect(self: Signal, fn: (...any) -> ()): Connection
	return connect(self, fn, false)
end

function Signal.Once(self: Signal, fn: (...any) -> ()): Connection
	return connect(self, fn, true)
end

function Signal.Fire(self: Signal, ...: any)
	-- Iterate a copy so handlers may disconnect during the fire.
	local snapshot = table.clone(self._handlers)
	for _, handler in snapshot do
		if handler.once then
			local index = table.find(self._handlers, handler)
			if index then
				table.remove(self._handlers, index)
			end
		end
		task.spawn(handler.fn, ...)
	end
end

function Signal.Wait(self: Signal): ...any
	local thread = coroutine.running()
	connect(self, function(...)
		task.spawn(thread, ...)
	end, true)
	return coroutine.yield()
end

function Signal.Destroy(self: Signal)
	table.clear(self._handlers)
end

return Signal
