--!strict
-- Dependency-free test runner. Specs are ModuleScripts named "<Name>.spec" in this folder that return
-- function(t) and use t.describe / t.it / t.expect. Run from the command bar or the Studio MCP:
--   require(game.ServerStorage.Tests.Runner).Run()          -- all specs
--   require(game.ServerStorage.Tests.Runner).Run("Economy") -- specs whose name contains "Economy"

local Runner = {}

local function deepEqual(a: any, b: any): boolean
	if a == b then
		return true
	end
	if typeof(a) ~= "table" or typeof(b) ~= "table" then
		return false
	end
	for k, v in a do
		if not deepEqual(v, b[k]) then
			return false
		end
	end
	for k in b do
		if a[k] == nil then
			return false
		end
	end
	return true
end

local function show(value: any): string
	if typeof(value) == "string" then
		return `"{value}"`
	end
	if typeof(value) == "table" then
		local parts = {}
		for k, v in value do
			table.insert(parts, `{tostring(k)} = {show(v)}`)
		end
		table.sort(parts)
		return "{ " .. table.concat(parts, ", ") .. " }"
	end
	return tostring(value)
end

local function fail(message: string)
	error(message, 3)
end

export type Expectation = {
	toBe: (expected: any) -> (),
	toEqual: (expected: any) -> (),
	toBeCloseTo: (expected: number, epsilon: number?) -> (),
	toBeTruthy: () -> (),
	toBeFalsy: () -> (),
	toBeNil: () -> (),
	toBeGreaterThan: (other: number) -> (),
	toBeLessThan: (other: number) -> (),
	toThrow: (pattern: string?) -> (),
}

local function expect(value: any): Expectation
	local e = {} :: Expectation
	e.toBe = function(expected: any)
		if value ~= expected then
			fail(`expected {show(expected)}, got {show(value)}`)
		end
	end
	e.toEqual = function(expected: any)
		if not deepEqual(value, expected) then
			fail(`expected {show(expected)}, got {show(value)}`)
		end
	end
	e.toBeCloseTo = function(expected: number, epsilon: number?)
		local eps = epsilon or 1e-6
		if typeof(value) ~= "number" or math.abs(value - expected) > eps then
			fail(`expected {show(value)} to be within {eps} of {expected}`)
		end
	end
	e.toBeTruthy = function()
		if not value then
			fail(`expected truthy, got {show(value)}`)
		end
	end
	e.toBeFalsy = function()
		if value then
			fail(`expected falsy, got {show(value)}`)
		end
	end
	e.toBeNil = function()
		if value ~= nil then
			fail(`expected nil, got {show(value)}`)
		end
	end
	e.toBeGreaterThan = function(other: number)
		if typeof(value) ~= "number" or value <= other then
			fail(`expected {show(value)} > {other}`)
		end
	end
	e.toBeLessThan = function(other: number)
		if typeof(value) ~= "number" or value >= other then
			fail(`expected {show(value)} < {other}`)
		end
	end
	e.toThrow = function(pattern: string?)
		if typeof(value) ~= "function" then
			fail("toThrow needs a function")
		end
		local ok, err = pcall(value)
		if ok then
			fail("expected the function to throw")
		end
		if pattern and not string.find(tostring(err), pattern) then
			fail(`expected error matching "{pattern}", got {tostring(err)}`)
		end
	end
	return e
end

export type T = {
	describe: (name: string, body: () -> ()) -> (),
	it: (name: string, body: () -> ()) -> (),
	expect: (value: any) -> Expectation,
}

type Result = { name: string, ok: boolean, err: string? }

local function trace(err: any): string
	return debug.traceback(tostring(err), 2)
end

local function runSpec(specName: string, spec: (T) -> ()): { Result }
	local results: { Result } = {}
	local path: { string } = { specName }
	local t = {} :: T
	t.expect = expect
	t.describe = function(name: string, body: () -> ())
		table.insert(path, name)
		local ok, err = xpcall(body :: () -> ...any, trace)
		if not ok then
			table.insert(results, { name = table.concat(path, " › "), ok = false, err = tostring(err) })
		end
		table.remove(path)
	end
	t.it = function(name: string, body: () -> ())
		local fullName = table.concat(path, " › ") .. " › " .. name
		local ok, err = xpcall(body :: () -> ...any, trace)
		table.insert(results, { name = fullName, ok = ok, err = if ok then nil else tostring(err) })
	end
	local ok, err = xpcall(function(): ...any
		spec(t)
		return nil
	end, trace)
	if not ok then
		table.insert(results, { name = specName, ok = false, err = tostring(err) })
	end
	return results
end

function Runner.Run(filter: string?): (number, number)
	local passed, failed = 0, 0
	local started = os.clock()
	for _, child in script.Parent:GetChildren() do
		if not child:IsA("ModuleScript") or not string.match(child.Name, "%.spec$") then
			continue
		end
		if filter and not string.find(child.Name, filter, 1, true) then
			continue
		end
		local okRequire, spec = pcall(require :: any, child)
		if not okRequire or typeof(spec) ~= "function" then
			failed += 1
			warn(`✗ {child.Name}: could not load spec ({tostring(spec)})`)
			continue
		end
		for _, result in runSpec(child.Name, spec) do
			if result.ok then
				passed += 1
			else
				failed += 1
				warn(`✗ {result.name}\n{result.err}`)
			end
		end
	end
	local ms = math.floor((os.clock() - started) * 1000)
	print(`Tests: {passed} passed, {failed} failed ({ms} ms)`)
	return passed, failed
end

return Runner
