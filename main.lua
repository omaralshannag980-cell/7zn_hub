--// lansher hub UI - Luau / Roblox

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- IDs الصور
local TOGGLE_IMAGE = "rbxassetid://128405788519714" -- صورة الزر
local WINDOW_IMAGE = "rbxassetid://96392873626158"  -- صورة الواجهة

-- أحجام الزر
local BUTTON_SIZES = {
	["كبير"] = 56,
	["متوسط"] = 38,
	["صغير"] = 22,
}

-- أحجام الواجهة
local WINDOW_SIZES = {
	["كبير"] = Vector2.new(520, 340),
	["متوسط"] = Vector2.new(400, 260),
	["صغير"] = Vector2.new(320, 210),
}

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "LansherHubUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

-- دالة السحب (ماوس + لمس)
local function makeDraggable(handle, target, onClick)
	local dragging = false
	local dragStart, startPos
	local moved = false

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			moved = false
			dragStart = input.Position
			startPos = target.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if not moved and onClick then
						onClick()
					end
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			if delta.Magnitude > 4 then
				moved = true
			end
			target.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- النافذة الرئيسية
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(WINDOW_SIZES["متوسط"].X, WINDOW_SIZES["متوسط"].Y)
main.Position = UDim2.new(0.5, -200, 0.5, -130)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(220, 40, 40)
mainStroke.Thickness = 1.5

-- الشريط العلوي
local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, 0, 0, 34)
topbar.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
topbar.BorderSizePixel = 0
topbar.Parent = main

local logo = Instance.new("ImageLabel")
logo.Size = UDim2.fromOffset(24, 24)
logo.Position = UDim2.fromOffset(8, 5)
logo.BackgroundTransparency = 1
logo.Image = WINDOW_IMAGE
logo.ScaleType = Enum.ScaleType.Fit
logo.Parent = topbar

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.fromOffset(38, 0)
title.Font = Enum.Font.ArialBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(255, 70, 70)
title.Text = "lansher hub"
title.Parent = topbar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(24, 24)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.ArialBold
closeBtn.TextSize = 13
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Parent = topbar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- القائمة الجانبية
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 110, 1, -34)
sidebar.Position = UDim2.fromOffset(0, 34)
sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0, 6)
local sidePad = Instance.new("UIPadding", sidebar)
sidePad.PaddingTop = UDim.new(0, 8)
sidePad.PaddingLeft = UDim.new(0, 8)
sidePad.PaddingRight = UDim.new(0, 8)

-- منطقة المحتوى
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -110, 1, -34)
content.Position = UDim2.fromOffset(110, 34)
content.BackgroundTransparency = 1
content.Parent = main

-- نظام التابات
local pages, tabButtons = {}, {}

local function selectTab(name)
	for n, page in pairs(pages) do
		page.Visible = (n == name)
	end
	for n, btn in pairs(tabButtons) do
		btn.BackgroundColor3 = (n == name) and Color3.fromRGB(200, 40, 40) or Color3.fromRGB(40, 40, 48)
	end
end

local function createTab(name)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	btn.Text = name
	btn.Font = Enum.Font.Arial
	btn.TextScaled = true
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Parent = sidebar
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	local limit = Instance.new("UITextSizeConstraint", btn)
	limit.MaxTextSize = 14

	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1, -16, 1, -16)
