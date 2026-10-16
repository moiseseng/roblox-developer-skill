--!strict
-- Every tunable the game has. The GDD and this file must agree; specs in tests/ check the numbers.

local Config = {
	GameName = "__GAME_NAME__",
	Debug = false,

	Data = {
		StoreName = "PlayerData_v1",
		AutosaveSeconds = 120,
		LockTimeoutSeconds = 120,
		LoadAttempts = 5,
	},

	Economy = {
		StartingCoins = 0,
		UpgradeBaseCost = 10,
		UpgradeGrowth = 1.15,
		MaxUpgradeLevel = 50,
		CoinsPerUpgradeLevel = 1,
	},

	Player = {
		WalkSpeed = 16,
		JumpPower = 50,
	},

	Net = {
		MaxRequestsPerSecond = 10,
	},
}

return Config
