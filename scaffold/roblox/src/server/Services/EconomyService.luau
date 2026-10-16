--!strict
-- Server authority for coins and upgrades. The client requests; this service validates, decides, mutates.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Economy = require(ReplicatedStorage.Shared.Economy)
local Net = require(ReplicatedStorage.Shared.Net)
local DataService = require(script.Parent.DataService)
local PlayerService = require(script.Parent.PlayerService)

local EconomyService = {}
EconomyService.Priority = 20

type Bucket = { count: number, resetAt: number }
local buckets: { [Player]: Bucket } = {}

local function allow(player: Player): boolean
	local now = os.clock()
	local bucket = buckets[player]
	if not bucket or now >= bucket.resetAt then
		buckets[player] = { count = 1, resetAt = now + 1 }
		return true
	end
	bucket.count += 1
	return bucket.count <= Config.Net.MaxRequestsPerSecond
end

function EconomyService.Award(player: Player, amount: number)
	local profile = DataService.Get(player)
	if not profile or amount <= 0 then
		return
	end
	profile.coins += amount
	PlayerService.Publish(player)
end

-- Returns (true) or (false, reasonCode). Reason codes are mapped to text on the client.
function EconomyService.TryUpgrade(player: Player): (boolean, string?)
	local profile = DataService.Get(player)
	if not profile then
		return false, "no_data"
	end
	if profile.upgradeLevel >= Config.Economy.MaxUpgradeLevel then
		return false, "max_level"
	end
	local cost = Economy.upgradeCost(profile.upgradeLevel)
	if not Economy.canAfford(profile.coins, cost) then
		return false, "poor"
	end
	profile.coins -= cost
	profile.upgradeLevel += 1
	PlayerService.Publish(player)
	return true
end

local function onRequest(player: Player, payload: any): (boolean, string?)
	if not allow(player) then
		return false, "rate"
	end
	if typeof(payload) ~= "table" or typeof(payload.action) ~= "string" then
		return false, "bad_request"
	end
	if payload.action == "upgrade" then
		return EconomyService.TryUpgrade(player)
	end
	return false, "unknown_action"
end

function EconomyService.Init()
	Net.Function("RequestAction").OnServerInvoke = onRequest
	Players.PlayerRemoving:Connect(function(player)
		buckets[player] = nil
	end)
end

function EconomyService.Start()
	-- Passive income tick; replace with the GDD's loop.
	while true do
		task.wait(1)
		for _, player in Players:GetPlayers() do
			local profile = DataService.Get(player)
			if profile then
				EconomyService.Award(player, Economy.incomePerSecond(profile.upgradeLevel))
			end
		end
	end
end

return EconomyService
