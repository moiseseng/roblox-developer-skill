--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Economy = require(ReplicatedStorage.Shared.Economy)

return function(t)
	t.describe("upgradeCost", function()
		t.it("starts at the base cost", function()
			t.expect(Economy.upgradeCost(0)).toBe(Config.Economy.UpgradeBaseCost)
		end)
		t.it("grows by the growth factor each level", function()
			local base, growth = Config.Economy.UpgradeBaseCost, Config.Economy.UpgradeGrowth
			for _, n in { 1, 5, 10, 20 } do
				t.expect(Economy.upgradeCost(n)).toBe(math.floor(base * growth ^ n + 0.5))
			end
		end)
		t.it("rejects negative or fractional levels", function()
			t.expect(function()
				Economy.upgradeCost(-1)
			end).toThrow()
			t.expect(function()
				Economy.upgradeCost(1.5)
			end).toThrow()
		end)
	end)

	t.describe("pacing", function()
		t.it("keeps time-to-next-upgrade bounded over the first 20 levels", function()
			for n = 0, 20 do
				t.expect(Economy.secondsToNextUpgrade(n)).toBeLessThan(600)
			end
		end)
	end)

	t.describe("format", function()
		t.it("formats small numbers plainly", function()
			t.expect(Economy.format(0)).toBe("0")
			t.expect(Economy.format(999)).toBe("999")
		end)
		t.it("uses suffixes and trims zeros", function()
			t.expect(Economy.format(1000)).toBe("1K")
			t.expect(Economy.format(1234)).toBe("1.23K")
			t.expect(Economy.format(1500000)).toBe("1.5M")
			t.expect(Economy.format(-2500)).toBe("-2.5K")
		end)
	end)
end
