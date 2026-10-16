--!strict
-- The only module that talks to DataStoreService. Session-locked profiles, UpdateAsync, retries,
-- autosave, save on leave, BindToClose. Other services mutate the profile table in memory and the
-- changes are saved here. See references/roblox/data-persistence.md.

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local ProfileSchema = require(ReplicatedStorage.Shared.ProfileSchema)
local Signal = require(ReplicatedStorage.Shared.Signal)
local Strings = require(ReplicatedStorage.Shared.Strings)

type Profile = ProfileSchema.Profile
type Lock = { jobId: string, time: number }
type Record = { data: any, lock: Lock? }

local DataService = {}
DataService.Priority = 1
DataService.ProfileLoaded = Signal.new() -- (player: Player, profile: Profile)
DataService.ProfileReleased = Signal.new() -- (player: Player)

-- Studio writes to a separate store so development never touches production data.
local storeName = Config.Data.StoreName .. (if RunService:IsStudio() then "_dev" else "")
local store = DataStoreService:GetDataStore(storeName)
local profiles: { [Player]: Profile } = {}
local memoryOnly: { [Player]: boolean } = {}
local loading: { [Player]: boolean } = {}
local releasing: { [Player]: boolean } = {}

local function keyFor(player: Player): string
	return `Player_{player.UserId}`
end

local function lockIsForeign(lock: Lock?): boolean
	if not lock then
		return false
	end
	if lock.jobId == game.JobId then
		return false
	end
	return os.time() - lock.time < Config.Data.LockTimeoutSeconds
end

-- Returns (profile) or (nil, "locked" | "error").
local function tryLoad(player: Player): (Profile?, string?)
	local loaded: Profile? = nil
	local outcome: string? = nil
	local ok, err = pcall(function()
		store:UpdateAsync(keyFor(player), function(stored: any): any
			local record: Record = if typeof(stored) == "table" then stored else { data = nil, lock = nil }
			if lockIsForeign(record.lock) then
				outcome = "locked"
				return nil -- abort, don't take the lock
			end
			record.data = ProfileSchema.migrate(record.data)
			record.lock = { jobId = game.JobId, time = os.time() }
			loaded = record.data
			return record
		end)
	end)
	if not ok then
		warn(`[DataService] load failed for {player.Name}: {err}`)
		return nil, "error"
	end
	if outcome == "locked" then
		return nil, "locked"
	end
	return loaded, nil
end

local function write(player: Player, profile: Profile, release: boolean): boolean
	if memoryOnly[player] then
		return true
	end
	profile.lastSeen = os.time()
	for attempt = 1, 3 do
		local lostLock = false
		local ok, err = pcall(function()
			store:UpdateAsync(keyFor(player), function(stored: any): any
				local record: Record = if typeof(stored) == "table" then stored else { data = nil, lock = nil }
				if lockIsForeign(record.lock) then
					lostLock = true
					return nil -- someone else owns it now; don't clobber
				end
				record.data = profile
				record.lock = if release then nil else { jobId = game.JobId, time = os.time() }
				return record
			end)
		end)
		if ok and lostLock then
			warn(`[DataService] save skipped for {player.Name}: another server holds the session lock`)
			return false
		end
		if ok then
			return true
		end
		warn(`[DataService] save attempt {attempt} failed for {player.Name}: {err}`)
		task.wait(2 ^ attempt)
	end
	return false
end

-- Loads (or waits for) the player's profile. Yields. Returns nil if the player left or the data is locked elsewhere.
function DataService.Load(player: Player): Profile?
	if profiles[player] then
		return profiles[player]
	end
	if loading[player] then
		-- Another Load for the same player is in flight (PlayerAdded and Start can both fire); share its result.
		repeat
			task.wait(0.1)
		until not loading[player]
		return profiles[player]
	end
	loading[player] = true
	for attempt = 1, Config.Data.LoadAttempts do
		local profile, reason = tryLoad(player)
		-- The player may have left while UpdateAsync yielded. Release the lock we just took, or the profile
		-- leaks: autosave would refresh the lock forever and lock them out of every other server.
		if not player.Parent or not loading[player] then
			if profile then
				write(player, profile, true)
			end
			loading[player] = nil
			return nil
		end
		if profile then
			if profile.createdAt == 0 then
				profile.createdAt = os.time()
			end
			profiles[player] = profile
			loading[player] = nil
			DataService.ProfileLoaded:Fire(player, profile)
			return profile
		end
		if reason == "error" and RunService:IsStudio() then
			-- No API access in Studio: run in memory so development continues, loudly.
			warn(`[DataService] Studio without API access: {player.Name} runs on an in-memory profile`)
			local fallback = ProfileSchema.template()
			fallback.createdAt = os.time()
			profiles[player] = fallback
			memoryOnly[player] = true
			loading[player] = nil
			DataService.ProfileLoaded:Fire(player, fallback)
			return fallback
		end
		task.wait(attempt * 2)
	end
	loading[player] = nil
	player:Kick(Strings.get("err_load"))
	return nil
end

function DataService.Get(player: Player): Profile?
	return profiles[player]
end

function DataService.SaveNow(player: Player): boolean
	local profile = profiles[player]
	if not profile then
		return false
	end
	return write(player, profile, false)
end

function DataService.Release(player: Player)
	loading[player] = nil -- a Load still in flight sees this and releases its lock instead of storing
	local profile = profiles[player]
	if not profile or releasing[player] then
		return -- PlayerRemoving and BindToClose can both call this; save once
	end
	releasing[player] = true
	write(player, profile, true)
	profiles[player] = nil
	memoryOnly[player] = nil
	releasing[player] = nil
	DataService.ProfileReleased:Fire(player)
end

-- Permanently deletes a stored profile (right-to-be-forgotten requests). Kicks the player if online.
-- In Studio this hits the "_dev" store; production erasures run from a live server admin path or Open Cloud.
function DataService.Erase(userId: number): boolean
	local online = Players:GetPlayerByUserId(userId)
	if online then
		profiles[online] = nil
		memoryOnly[online] = nil
		online:Kick(Strings.get("err_load"))
	end
	local ok, err = pcall(function()
		store:RemoveAsync(`Player_{userId}`)
	end)
	if not ok then
		warn(`[DataService] erase failed for {userId}: {err}`)
	end
	return ok
end

function DataService.Init()
	game:BindToClose(function()
		local pending = 0
		local snapshot = {}
		for player in profiles do
			table.insert(snapshot, player)
		end
		for _, player in snapshot do
			pending += 1
			task.spawn(function()
				DataService.Release(player)
				pending -= 1
			end)
		end
		local deadline = os.clock() + (if RunService:IsStudio() then 3 else 25)
		while pending > 0 and os.clock() < deadline do
			task.wait(0.1)
		end
	end)
end

function DataService.Start()
	while true do
		task.wait(Config.Data.AutosaveSeconds)
		local snapshot = {}
		for player in profiles do
			table.insert(snapshot, player)
		end
		for _, player in snapshot do
			if profiles[player] then
				task.spawn(DataService.SaveNow, player)
				task.wait(0.5) -- stagger to respect the request budget
			end
		end
	end
end

return DataService
