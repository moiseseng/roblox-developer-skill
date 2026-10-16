--!strict
-- The saved player profile: template, reconcile (fill missing fields) and migrations. Pure; unit-tested.

local Config = require(script.Parent.Config)

export type Profile = {
	version: number,
	coins: number,
	upgradeLevel: number,
	purchases: { [string]: number },
	createdAt: number,
	lastSeen: number,
}

local ProfileSchema = {}

ProfileSchema.VERSION = 1

function ProfileSchema.template(): Profile
	return {
		version = ProfileSchema.VERSION,
		coins = Config.Economy.StartingCoins,
		upgradeLevel = 0,
		purchases = {},
		createdAt = 0,
		lastSeen = 0,
	}
end

-- Migrations run in order from data.version to VERSION. MIGRATIONS[v] upgrades v -> v + 1.
local MIGRATIONS: { [number]: (data: any) -> () } = {
	-- [1] = function(data) data.newField = 0 end,
}

local function deepCopy(value: any): any
	if typeof(value) ~= "table" then
		return value
	end
	local copy = {}
	for k, v in value do
		copy[k] = deepCopy(v)
	end
	return copy
end

-- Adds every key of `template` missing in `data` (recursively for tables). Never overwrites.
function ProfileSchema.reconcile(data: any, template: any): any
	if typeof(data) ~= "table" then
		return deepCopy(template)
	end
	for key, templateValue in template do
		local current = data[key]
		if current == nil then
			data[key] = deepCopy(templateValue)
		elseif typeof(templateValue) == "table" and typeof(current) == "table" then
			ProfileSchema.reconcile(current, templateValue)
		end
	end
	return data
end

function ProfileSchema.migrate(data: any): Profile
	if typeof(data) ~= "table" then
		return ProfileSchema.template()
	end
	local version = if typeof(data.version) == "number" then data.version else 1
	if version > ProfileSchema.VERSION then
		-- A newer build wrote this profile (rollback in progress). Keep every field, run no migration.
		warn(`[ProfileSchema] profile version {version} is newer than this build ({ProfileSchema.VERSION})`)
		return ProfileSchema.reconcile(data, ProfileSchema.template()) :: Profile
	end
	while version < ProfileSchema.VERSION do
		local step = MIGRATIONS[version]
		assert(step, `No migration from profile version {version}`)
		step(data)
		version += 1
		data.version = version
	end
	return ProfileSchema.reconcile(data, ProfileSchema.template()) :: Profile
end

return ProfileSchema
