--!strict
-- Every tunable the game has. The GDD and this file must agree; specs in tests/ check the numbers.

local Config = {
	GameName = "__GAME_NAME__",
	Version = "0.1.0", -- shown in the HUD so QA reports and live servers agree on what was tested
	SourceLanguage = "es", -- language of player-facing strings (Shared.Strings); GDD §8 decides
	Debug = false,

	Data = {
		StoreName = "PlayerData_v1", -- DataService appends "_dev" in Studio so dev never touches production
		AutosaveSeconds = 60,
		LockTimeoutSeconds = 300, -- keep >= 3x AutosaveSeconds or a slow autosave lets another server steal the lock
		LoadAttempts = 5,
	},

	Economy = {
		StartingCoins = 0,
		UpgradeBaseCost = 10,
		UpgradeGrowth = 1.15,
		MaxUpgradeLevel = 50,
		CoinsPerUpgradeLevel = 1,
		-- Pacing target from the GDD §5 table: within the first PacingHorizonLevels upgrades, a player never
		-- waits longer than TargetMaxSecondsToNextUpgrade for the next one. Late levels are allowed to slow down.
		PacingHorizonLevels = 20,
		TargetMaxSecondsToNextUpgrade = 60,
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
