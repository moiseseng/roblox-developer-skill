--!strict
-- Player lifecycle: load profile on join, publish public state as attributes, release on leave.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local DataService = require(script.Parent.DataService)

local PlayerService = {}
PlayerService.Priority = 10

local function publish(player: Player)
	local profile = DataService.Get(player)
	if not profile then
		return
	end
	player:SetAttribute("Coins", profile.coins)
	player:SetAttribute("UpgradeLevel", profile.upgradeLevel)
end
PlayerService.Publish = publish

local function onCharacterAdded(character: Model)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if humanoid and humanoid:IsA("Humanoid") then
		humanoid.WalkSpeed = Config.Player.WalkSpeed
		humanoid.UseJumpPower = true
		humanoid.JumpPower = Config.Player.JumpPower
	end
end

local handled: { [Player]: boolean } = {}

local function onPlayerAdded(player: Player)
	if handled[player] then
		return -- PlayerAdded and Start's GetPlayers can both deliver the same player
	end
	handled[player] = true
	player.CharacterAdded:Connect(onCharacterAdded)
	if player.Character then
		onCharacterAdded(player.Character)
	end
	local profile = DataService.Load(player)
	if profile then
		publish(player)
		player:SetAttribute("DataReady", true)
	end
end

function PlayerService.Init()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(function(player)
		handled[player] = nil
		DataService.Release(player)
	end)
end

function PlayerService.Start()
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
end

return PlayerService
