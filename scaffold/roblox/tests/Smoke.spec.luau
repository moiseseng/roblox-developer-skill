--!strict
-- Gate check run at every milestone: declarations consistent, remotes really exist, the world builds within
-- budget, tunables sane. Extend as systems appear (data tables, tags, zones).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ReplicatedStorage.Shared.Config)
local Net = require(ReplicatedStorage.Shared.Net)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Hub = require(ServerScriptService.Server.World.Hub)

local VALID_KINDS = { RemoteEvent = true, RemoteFunction = true, UnreliableRemoteEvent = true }
local WORLD_INSTANCE_BUDGET = 500 -- from tech-design §8; raise deliberately, never silently

return function(t)
	t.describe("Remotes", function()
		t.it("declares only valid kinds with PascalCase names", function()
			for name, kind in Remotes do
				t.expect(VALID_KINDS[kind]).toBeTruthy()
				t.expect(string.match(name, "^%u%w*$")).toBeTruthy()
			end
		end)
		t.it("exist with the declared class after Net.Setup", function()
			Net.Setup()
			for name, kind in Remotes do
				local remote = Net.Get(name)
				t.expect(remote.ClassName).toBe(kind)
			end
		end)
	end)

	t.describe("World", function()
		t.it("builds the hub within the instance budget", function()
			local sandbox = Instance.new("Folder")
			Hub.Build(sandbox)
			local count = #sandbox:GetDescendants()
			sandbox:Destroy()
			t.expect(count).toBeGreaterThan(0)
			t.expect(count).toBeLessThan(WORLD_INSTANCE_BUDGET)
		end)
	end)

	t.describe("Config", function()
		t.it("has a growth factor above 1 and a positive base cost", function()
			t.expect(Config.Economy.UpgradeGrowth).toBeGreaterThan(1)
			t.expect(Config.Economy.UpgradeBaseCost).toBeGreaterThan(0)
		end)
		t.it("keeps the session lock alive across autosaves", function()
			t.expect(Config.Data.AutosaveSeconds).toBeGreaterThan(29)
			t.expect(Config.Data.LockTimeoutSeconds).toBeGreaterThan(Config.Data.AutosaveSeconds * 3 - 1)
		end)
		t.it("ships with debug off and a version string", function()
			t.expect(Config.Debug).toBe(false)
			t.expect(string.match(Config.Version, "^%d+%.%d+%.%d+$")).toBeTruthy()
		end)
	end)
end
