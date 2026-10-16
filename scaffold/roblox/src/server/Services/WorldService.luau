--!strict
-- Builds the map from code at server start so the place file stays a build artifact.

local WorldService = {}
WorldService.Priority = 5

local Hub = require(script.Parent.Parent.World.Hub)

function WorldService.Init()
	local existing = workspace:FindFirstChild("World")
	if existing then
		existing:Destroy()
	end
	local root = Instance.new("Folder")
	root.Name = "World"
	Hub.Build(root)
	root.Parent = workspace
end

return WorldService
