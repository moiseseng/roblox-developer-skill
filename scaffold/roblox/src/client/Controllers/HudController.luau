--!strict
-- Minimal HUD bound to player attributes. Scale-based layout, safe-area aware, one request in flight at a time.
-- Replace with the GDD's UI; keep the patterns (attributes in, requests out, Strings for copy).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Economy = require(ReplicatedStorage.Shared.Economy)
local Net = require(ReplicatedStorage.Shared.Net)
local Strings = require(ReplicatedStorage.Shared.Strings)

local HudController = {}
HudController.Priority = 10

local FONT = Font.fromEnum(Enum.Font.GothamBold)
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
	label.FontFace = FONT
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
	gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets -- keeps controls out of notches and the Roblox top bar

	local coins = makeLabel(gui, "Coins", UDim2.fromScale(0.5, 0.03), UDim2.fromScale(0.3, 0.06))
	coins.AnchorPoint = Vector2.new(0.5, 0)

	local status = makeLabel(gui, "Status", UDim2.fromScale(0.5, 0.1), UDim2.fromScale(0.4, 0.04))
	status.AnchorPoint = Vector2.new(0.5, 0)
	status.Text = ""

	local version = makeLabel(gui, "Version", UDim2.fromScale(1, 1), UDim2.fromScale(0.2, 0.025))
	version.AnchorPoint = Vector2.new(1, 1)
	version.TextXAlignment = Enum.TextXAlignment.Right
	version.TextTransparency = 0.5
	version.Text = `v{Config.Version}`

	local button = Instance.new("TextButton")
	button.Name = "Upgrade"
	button.AnchorPoint = Vector2.new(0.5, 1)
	button.Position = UDim2.fromScale(0.5, 0.95)
	button.Size = UDim2.fromScale(0.26, 0.08)
	button.BackgroundColor3 = Color3.fromRGB(240, 196, 60)
	button.TextColor3 = Color3.fromRGB(30, 30, 30)
	button.TextScaled = true
	button.FontFace = FONT
	button.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.3, 0)
	corner.Parent = button
	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MinSize = Vector2.new(140, 44) -- touch target
	sizeConstraint.Parent = button

	local function refresh()
		local balance = player:GetAttribute("Coins")
		local level = player:GetAttribute("UpgradeLevel")
		coins.Text = if typeof(balance) == "number"
			then Strings.get("coins", { amount = Economy.format(balance) })
			else Strings.get("loading")
		if typeof(level) == "number" then
			button.Text =
				Strings.get("upgrade_level", { level = level, cost = Economy.format(Economy.upgradeCost(level)) })
		else
			button.Text = Strings.get("upgrade")
		end
	end

	player:GetAttributeChangedSignal("Coins"):Connect(refresh)
	player:GetAttributeChangedSignal("UpgradeLevel"):Connect(refresh)
	refresh()

	local request = Net.Function("RequestAction")
	local pending = false
	local function showStatus(text: string)
		status.Text = text
		task.delay(1.5, function()
			if status.Text == text then
				status.Text = ""
			end
		end)
	end
	button.Activated:Connect(function()
		if pending then
			return
		end
		pending = true
		button.AutoButtonColor = false
		button.BackgroundTransparency = 0.4
		local ok, result, reason = pcall(request.InvokeServer, request, { action = "upgrade" })
		pending = false
		button.AutoButtonColor = true
		button.BackgroundTransparency = 0
		if not ok then
			showStatus(Strings.get("err_generic"))
		elseif result ~= true then
			local key = `err_{tostring(reason)}`
			showStatus(Strings.get(key :: any) or Strings.get("err_generic"))
		end
	end)

	gui.Parent = player:WaitForChild("PlayerGui")
end

return HudController
