--!strict
-- Grey-box hub: a floor and a spawn. M0 lives on primitives; final art replaces by name and size.

local Hub = {}

local function part(name: string, size: Vector3, cframe: CFrame, color: Color3, parent: Instance): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Color = color
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

function Hub.Build(parent: Instance)
	local hub = Instance.new("Folder")
	hub.Name = "Hub"

	part("Floor", Vector3.new(128, 2, 128), CFrame.new(0, -1, 0), Color3.fromRGB(99, 120, 95), hub)
	part("Marker", Vector3.new(4, 4, 4), CFrame.new(12, 2, 0), Color3.fromRGB(240, 196, 60), hub)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.CFrame = CFrame.new(0, 0.5, 0)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Parent = hub

	hub.Parent = parent
end

return Hub
