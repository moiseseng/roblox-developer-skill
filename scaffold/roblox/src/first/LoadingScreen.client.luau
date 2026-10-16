--!strict
-- Replaces the default loading screen with a plain one and preloads critical assets.

local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TweenService = game:GetService("TweenService")

ReplicatedFirst:RemoveDefaultLoadingScreen()

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "LoadingScreen"
gui.IgnoreGuiInset = true
gui.DisplayOrder = 1000
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(1, 1)
frame.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local label = Instance.new("TextLabel")
label.AnchorPoint = Vector2.new(0.5, 0.5)
label.Position = UDim2.fromScale(0.5, 0.5)
label.Size = UDim2.fromScale(0.6, 0.1)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1, 1, 1)
label.TextScaled = true
label.FontFace = Font.fromEnum(Enum.Font.GothamBold)
label.Text = "…" -- ReplicatedFirst runs before Shared replicates; keep this script dependency-free
label.Parent = frame

gui.Parent = playerGui

if not game:IsLoaded() then
	game.Loaded:Wait()
end

-- Add asset ids / instances that must be ready before the first frame.
local toPreload: { Instance | string } = {}
if #toPreload > 0 then
	ContentProvider:PreloadAsync(toPreload)
end

local fade = TweenService:Create(frame, TweenInfo.new(0.4), { BackgroundTransparency = 1 })
TweenService:Create(label, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
fade:Play()
fade.Completed:Wait()
gui:Destroy()
