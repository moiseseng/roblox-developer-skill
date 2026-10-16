--!strict
-- Runs on every spawn (StarterCharacterScripts). Put custom movement (coyote time, dash, wall jump) here.
-- The server owns truth (speed/teleport sanity checks); this script owns feel.

local character = script.Parent :: Model
local humanoid = character:WaitForChild("Humanoid") :: Humanoid

humanoid.Died:Once(function()
	-- Hook for death effects / respawn UI.
end)
