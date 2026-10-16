--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Economy = require(ReplicatedStorage.Shared.Economy)

return function(t)
	t.describe("upgradeCost", function()
		t.it("starts at the base cost", function()
			t.expect(Economy.upgradeCost(0)).toBe(Config.Economy.UpgradeBaseCost)
		end)
		t.it("matches the GDD §5 table (base 10, growth 1.15)", function()
			-- These numbers are copied from the GDD, not recomputed from the formula: when the GDD changes,
			-- change both. That is the whole point of the test.
			for n, cost in { [1] = 12, [5] = 20, [10] = 40, [20] = 164 } do
				t.expect(Economy.upgradeCost(n)).toBe(cost)
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
