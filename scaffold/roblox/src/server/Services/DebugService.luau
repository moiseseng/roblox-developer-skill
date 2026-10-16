--!strict
-- Studio-only commands for development and QA. Never runs in a published server.
--   game.ServerStorage.Debug:Invoke("GiveCoins", userId, 500)
--   game.ServerStorage.Debug:Invoke("ResetProfile", userId)
--   game.ServerStorage.Debug:Invoke("DeleteProfile", userId)   -- removes the stored key (dev store in Studio)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileSchema = require(ReplicatedStorage.Shared.ProfileSchema)
local DataService = require(script.Parent.DataService)
local EconomyService = require(script.Parent.EconomyService)
local PlayerService = require(script.Parent.PlayerService)

local DebugService = {}
DebugService.Priority = 90

type Command = (player: Player?, userId: number, ...any) -> any

local COMMANDS: { [string]: Command } = {
	DeleteProfile = function(_player, userId)
		return DataService.Erase(userId)
	end,
	GiveCoins = function(player, _userId, amount)
		assert(player, "player must be online")
		assert(typeof(amount) == "number", "amount must be a number")
		EconomyService.Award(player, amount)
		return DataService.Get(player)
	end,
	ResetProfile = function(player, _userId)
		assert(player, "player must be online")
		local profile = DataService.Get(player)
		assert(profile, "no profile loaded")
		local fresh = ProfileSchema.template()
		for key, value in fresh do
			(profile :: any)[key] = value
		end
		profile.createdAt = os.time()
		PlayerService.Publish(player)
		return profile
	end,
}

function DebugService.Init()
	if not RunService:IsStudio() then
		return
	end
	local bindable = Instance.new("BindableFunction")
	bindable.Name = "Debug"
	bindable.OnInvoke = function(command: string, userId: number, ...)
		local handler = COMMANDS[command]
		assert(handler, `unknown debug command "{command}"`)
		local player = Players:GetPlayerByUserId(userId) or Players:GetPlayers()[1]
		return handler(player, userId, ...)
	end
	bindable.Parent = ServerStorage
end

return DebugService
