--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = require(script.Parent.Remotes)

local FOLDER_NAME = "Remotes"
local WAIT_SECONDS = 15

local Net = {}

local function folder(): Folder
	if RunService:IsServer() then
		local existing = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
		if existing then
			return existing :: Folder
		end
		local created = Instance.new("Folder")
		created.Name = FOLDER_NAME
		created.Parent = ReplicatedStorage
		return created
	end
	local found = ReplicatedStorage:WaitForChild(FOLDER_NAME, WAIT_SECONDS)
	assert(found, `Remotes folder not replicated after {WAIT_SECONDS}s; is the server running Net.Setup()?`)
	return found :: Folder
end

-- Server only: create every declared remote. Idempotent.
function Net.Setup()
	assert(RunService:IsServer(), "Net.Setup is server-only")
	local container = folder()
	for name, kind in Remotes do
		if not container:FindFirstChild(name) then
			local remote = (Instance.new :: any)(kind) :: Instance
			remote.Name = name
			remote.Parent = container
		end
	end
end

function Net.Get(name: string): Instance
	assert(Remotes[name], `Remote "{name}" is not declared in Shared.Remotes`)
	local container = folder()
	if RunService:IsServer() then
		local remote = container:FindFirstChild(name)
		assert(remote, `Remote "{name}" missing on server; call Net.Setup() first`)
		return remote
	end
	local remote = container:WaitForChild(name, WAIT_SECONDS)
	assert(remote, `Remote "{name}" not replicated after {WAIT_SECONDS}s`)
	return remote
end

function Net.Event(name: string): RemoteEvent
	return Net.Get(name) :: RemoteEvent
end

function Net.Function(name: string): RemoteFunction
	return Net.Get(name) :: RemoteFunction
end

function Net.Unreliable(name: string): UnreliableRemoteEvent
	return Net.Get(name) :: UnreliableRemoteEvent
end

return Net
