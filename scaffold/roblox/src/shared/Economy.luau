--!strict
-- Pure economy formulas. No instances, no services: everything here is unit-tested against the GDD table.

local Config = require(script.Parent.Config)

local Economy = {}

-- cost(n) = base * growth^n, rounded to the nearest coin. n is the current level (0 = first purchase).
function Economy.upgradeCost(level: number): number
	assert(level >= 0 and level == math.floor(level), "level must be a non-negative integer")
	return math.floor(Config.Economy.UpgradeBaseCost * Config.Economy.UpgradeGrowth ^ level + 0.5)
end

function Economy.canAfford(balance: number, cost: number): boolean
	return balance >= cost
end

-- Coins earned per second at a given upgrade level. Replace with the GDD's formula.
function Economy.incomePerSecond(level: number): number
	return Config.Economy.CoinsPerUpgradeLevel * (1 + level)
end

-- Seconds of income needed to afford the next upgrade; the GDD pacing table is written in these terms.
function Economy.secondsToNextUpgrade(level: number): number
	return Economy.upgradeCost(level) / Economy.incomePerSecond(level)
end

local SUFFIXES = { "", "K", "M", "B", "T", "Qa", "Qi" }

-- 1234 -> "1.23K", 999 -> "999", 1500000 -> "1.5M"
function Economy.format(amount: number): string
	if amount ~= amount then
		return "?"
	end
	local sign = if amount < 0 then "-" else ""
	local value = math.abs(amount)
	if value == math.huge then
		return sign .. "∞"
	end
	local tier = 1
	-- 999.5 so that 999 999 rounds to "1M", never "1000K"
	while value >= 999.5 and tier < #SUFFIXES do
		value /= 1000
		tier += 1
	end
	if tier == 1 then
		return sign .. tostring(math.floor(value))
	end
	local text = string.format("%.2f", value):gsub("%.?0+$", "")
	return sign .. text .. SUFFIXES[tier]
end

return Economy
