--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "CleanHUD"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local hud = Instance.new("Frame")
hud.Parent = gui
hud.Size = UDim2.new(0, 210, 0, 105)
hud.AnchorPoint = Vector2.new(0.5, 0.5)
hud.Position = UDim2.new(0.5, 0, 0.33, 0)
hud.BackgroundColor3 = Color3.fromRGB(0,0,0)
hud.BackgroundTransparency = 0.45
hud.BorderSizePixel = 0
hud.Active = true

local corner = Instance.new("UICorner", hud)
corner.CornerRadius = UDim.new(0, 10)

--// DRAG HUD (MOBILE + PC)
do
	local dragging, dragInput, dragStart, startPos

	hud.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = hud.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	hud.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			hud.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

--// TEXT MAKER
local function makeText(y)
	local t = Instance.new("TextLabel")
	t.Parent = hud
	t.Size = UDim2.new(1, -12, 0, 18)
	t.Position = UDim2.new(0, 6, 0, y)
	t.BackgroundTransparency = 1
	t.TextColor3 = Color3.new(1,1,1)
	t.Font = Enum.Font.Gotham
	t.TextSize = 14
	t.TextXAlignment = Enum.TextXAlignment.Left
	return t
end

local speedText = makeText(6)
local jumpText  = makeText(24)
local hpText    = makeText(42)
local rateText  = makeText(60)

--// HP BAR
local barBG = Instance.new("Frame", hud)
barBG.Size = UDim2.new(1, -12, 0, 7)
barBG.Position = UDim2.new(0, 6, 0, 84)
barBG.BackgroundColor3 = Color3.fromRGB(70,70,70)
barBG.BorderSizePixel = 0

local barBGCorner = Instance.new("UICorner", barBG)
barBGCorner.CornerRadius = UDim.new(1,0)

local bar = Instance.new("Frame", barBG)
bar.Size = UDim2.new(1,0,1,0)
bar.BackgroundColor3 = Color3.fromRGB(0,255,0)
bar.BorderSizePixel = 0

local barCorner = Instance.new("UICorner", bar)
barCorner.CornerRadius = UDim.new(1,0)

--// CHARACTER DATA
local char, hum, root
local lastPos
local lastHP, lastHPTime

local jumpStartY
local maxJump = 0

local function setup(c)
	char = c
	hum = c:WaitForChild("Humanoid")
	root = c:WaitForChild("HumanoidRootPart")
	lastPos = root.Position
	lastHP = hum.Health
	lastHPTime = tick()
	maxJump = 0
	jumpStartY = nil
end

if player.Character then setup(player.Character) end
player.CharacterAdded:Connect(setup)

--// UPDATE LOOP
RunService.RenderStepped:Connect(function(dt)
	if not (hum and root) then return end

	-- SPEED
	local dist = (root.Position - lastPos).Magnitude
	local speed = dist / dt
	lastPos = root.Position
	speedText.Text = string.format("Speed: %.1f stud/s", speed)

	-- JUMP (KHÔNG MẤT)
	if hum.FloorMaterial == Enum.Material.Air then
		if not jumpStartY then
			jumpStartY = root.Position.Y
			maxJump = 0
		end
		local h = root.Position.Y - jumpStartY
		if h > maxJump then
			maxJump = h
		end
	else
		jumpStartY = nil
	end
	jumpText.Text = string.format("Jump: %.1f stud", maxJump)

	-- HP TEXT
	local hp = hum.Health
	local maxhp = hum.MaxHealth
	hpText.Text = string.format("HP: %d / %d", hp, maxhp)

	-- HP BAR
	bar.Size = UDim2.new(math.clamp(hp / maxhp, 0, 1), 0, 1, 0)

	-- HP RATE
	local now = tick()
	local rate = (hp - lastHP) / (now - lastHPTime)
	lastHP = hp
	lastHPTime = now
	rateText.Text = string.format("HP Rate: %.1f /s", rate)
end)
