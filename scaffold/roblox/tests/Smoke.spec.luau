--!strict
-- Gate check: declarations are consistent and tunables are sane. Extend with world/instance budgets.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

local VALID_KINDS = { RemoteEvent = true, RemoteFunction = true, UnreliableRemoteEvent = true }

return function(t)
	t.describe("Remotes", function()
		t.it("declares only valid kinds with PascalCase names", function()
			for name, kind in Remotes do
				t.expect(VALID_KINDS[kind]).toBeTruthy()
				t.expect(string.match(name, "^%u%w*$")).toBeTruthy()
			end
		end)
	end)

	t.describe("Config", function()
		t.it("has a growth factor above 1 and a positive base cost", function()
			t.expect(Config.Economy.UpgradeGrowth).toBeGreaterThan(1)
			t.expect(Config.Economy.UpgradeBaseCost).toBeGreaterThan(0)
		end)
		t.it("autosaves within the DataStore budget", function()
			t.expect(Config.Data.AutosaveSeconds).toBeGreaterThan(59)
		end)
		t.it("is not in debug mode", function()
			t.expect(Config.Debug).toBe(false)
		end)
	end)
end
