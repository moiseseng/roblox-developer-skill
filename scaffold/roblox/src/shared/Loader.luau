--!strict
-- Requires every ModuleScript in a container, calls Init() on each (by Priority, lower first), then Start().
-- Init wires listeners without yielding or touching other modules' state; Start does the work.

export type Module = {
	Priority: number?,
	Init: (() -> ())?,
	Start: (() -> ())?,
}

type Entry = { name: string, module: Module }

local Loader = {}

local function collect(container: Instance): { Entry }
	local entries: { Entry } = {}
	for _, child in container:GetChildren() do
		if not child:IsA("ModuleScript") then
			continue
		end
		local ok, result = pcall(require :: any, child)
		if not ok then
			error(`[Loader] failed to require {child:GetFullName()}: {result}`)
		end
		if typeof(result) ~= "table" then
			error(`[Loader] {child:GetFullName()} must return a table`)
		end
		table.insert(entries, { name = child.Name, module = result :: Module })
	end
	table.sort(entries, function(a, b)
		local pa = a.module.Priority or 100
		local pb = b.module.Priority or 100
		if pa == pb then
			return a.name < b.name
		end
		return pa < pb
	end)
	return entries
end

function Loader.Load(container: Instance): { Entry }
	local entries = collect(container)
	for _, entry in entries do
		local init = entry.module.Init
		if init then
			local ok, err = pcall(init)
			if not ok then
				error(`[Loader] {entry.name}.Init failed: {err}`)
			end
		end
	end
	for _, entry in entries do
		local start = entry.module.Start
		if start then
			task.spawn(function()
				local ok, err = pcall(start)
				if not ok then
					warn(`[Loader] {entry.name}.Start failed: {err}`)
				end
			end)
		end
	end
	return entries
end

return Loader
