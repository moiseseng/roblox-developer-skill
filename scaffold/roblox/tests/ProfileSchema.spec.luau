--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Runner = require(script.Parent.Runner)
local Config = require(ReplicatedStorage.Shared.Config)
local ProfileSchema = require(ReplicatedStorage.Shared.ProfileSchema)

return function(t: Runner.T)
	t.describe("template", function()
		t.it("matches the current version and config", function()
			local profile = ProfileSchema.template()
			t.expect(profile.version).toBe(ProfileSchema.VERSION)
			t.expect(profile.coins).toBe(Config.Economy.StartingCoins)
			t.expect(profile.purchases).toEqual({})
		end)
	end)

	t.describe("reconcile", function()
		t.it("fills missing keys without overwriting existing ones", function()
			local data = { coins = 42 }
			local result = ProfileSchema.reconcile(data, ProfileSchema.template())
			t.expect(result.coins).toBe(42)
			t.expect(result.upgradeLevel).toBe(0)
			t.expect(result.purchases).toEqual({})
		end)
		t.it("returns a copy of the template for non-table input", function()
			t.expect(ProfileSchema.reconcile(nil, { a = 1 })).toEqual({ a = 1 })
		end)
	end)

	t.describe("migrate", function()
		t.it("returns a fresh profile for nil data", function()
			t.expect(ProfileSchema.migrate(nil)).toEqual(ProfileSchema.template())
		end)
		t.it("keeps data already at the current version", function()
			local data = ProfileSchema.template()
			data.coins = 7
			t.expect(ProfileSchema.migrate(data).coins).toBe(7)
		end)
	end)
end
