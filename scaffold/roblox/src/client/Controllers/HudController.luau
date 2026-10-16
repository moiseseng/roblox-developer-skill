--!strict
-- Minimal HUD bound to player attributes. Scale-based layout so it fits phones; replace with the GDD's UI.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Economy = require(ReplicatedStorage.Shared.Economy)
local Net = require(ReplicatedStorage.Shared.Net)

local HudController = {}
HudController.Priority = 10

local REASON_TEXT: { [string]: string } = {
	poor = "No tienes suficientes monedas",
	max_level = "Nivel máximo",
	rate = "Demasiado rápido",
	no_data = "Cargando datos…",
}

local player = Players.LocalPlayer

local function makeLabel(parent: Instance, name: string, position: UDim2, size: UDim2): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Position = position
	label.Size = size
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.5
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = parent
	local constraint = Instance.new("UITextSizeConstraint")
	constraint.MinTextSize = 14
	constraint.MaxTextSize = 36
	constraint.Parent = label
	return label
end

function HudController.Start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Hud"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local coins = makeLabel(gui, "Coins", UDim2.fromScale(0.5, 0.03), UDim2.fromScale(0.3, 0.06))
	coins.AnchorPoint = Vector2.new(0.5, 0)

	local status = makeLabel(gui, "Status", UDim2.fromScale(0.5, 0.1), UDim2.fromScale(0.4, 0.04))
	status.AnchorPoint = Vector2.new(0.5, 0)
	status.Text = ""

	local button = Instance.new("TextButton")
	button.Name = "Upgrade"
	button.AnchorPoint = Vector2.new(0.5, 1)
	button.Position = UDim2.fromScale(0.5, 0.95)
	button.Size = UDim2.fromScale(0.26, 0.08)
	button.BackgroundColor3 = Color3.fromRGB(240, 196, 60)
	button.TextColor3 = Color3.fromRGB(30, 30, 30)
	button.TextScaled = true
	button.Font = Enum.Font.GothamBold
	button.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.3, 0)
	corner.Parent = button
	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MinSize = Vector2.new(140, 44)
	sizeConstraint.Parent = button

	local function refresh()
		local balance = player:GetAttribute("Coins")
		local level = player:GetAttribute("UpgradeLevel")
		coins.Text = if typeof(balance) == "number" then `{Economy.format(balance)} monedas` else "…"
		if typeof(level) == "number" then
			button.Text = `Mejorar (nivel {level}) · {Economy.format(Economy.upgradeCost(level))}`
		else
			button.Text = "Mejorar"
		end
	end

	player:GetAttributeChangedSignal("Coins"):Connect(refresh)
	player:GetAttributeChangedSignal("UpgradeLevel"):Connect(refresh)
	refresh()

	local request = Net.Function("RequestAction")
	button.Activated:Connect(function()
		local ok, reason = request:InvokeServer({ action = "upgrade" })
		if ok then
			status.Text = ""
		else
			status.Text = REASON_TEXT[reason] or "No se pudo"
			task.delay(1.5, function()
				if status.Text == (REASON_TEXT[reason] or "No se pudo") then
					status.Text = ""
				end
			end)
		end
	end)

	gui.Parent = player:WaitForChild("PlayerGui")
end

return HudController
