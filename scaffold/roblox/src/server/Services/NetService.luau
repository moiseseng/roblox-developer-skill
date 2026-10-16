--!strict
-- Creates every declared remote before any other service runs (Priority 0).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Shared.Net)

local NetService = {}
NetService.Priority = 0

function NetService.Init()
	Net.Setup()
end

return NetService
