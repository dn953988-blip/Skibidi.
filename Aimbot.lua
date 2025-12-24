--[[ 
    HUB NAME: aimbot v5.8 (SMART ESP & ROTATING FOV)
    - FIXED: ESP Toggle and Visibility.
    - ADDED: Smart Health Bar & Distance.
    - ADDED: Rotating FOV Circle.
    - RESTORED: Target Part Selector.
]]

repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Config = {
    Aimbot = {Active = false, Speed = 0.15, FOV = 150, TargetPart = "Head", WallCheck = true, TeamCheck = true},
    Player = {WS = 16, JP = 50, CFrameActive = false, CFSpeed = 0.8, Active = false},
    ESP = {Active = false, Health = true, Distance = true},
    Theme = {Accent = Color3.fromRGB(0, 255, 170), Dark = Color3.fromRGB(15, 15, 15)}
}

-- Cleanup old UI
pcall(function() for _, v in pairs(CoreGui:GetChildren()) do if v.Name == "aimbot_v5_8" then v:Destroy() end end end)

local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = "aimbot_v5_8"; ScreenGui.IgnoreGuiInset = true

-- --- [1] ROTATING FOV SYSTEM ---
local FOV_Container = Instance.new("Frame", ScreenGui); FOV_Container.AnchorPoint = Vector2.new(0.5, 0.5); FOV_Container.Position = UDim2.new(0.5, 0, 0.5, 0); FOV_Container.Size = UDim2.new(0, Config.Aimbot.FOV*2, 0, Config.Aimbot.FOV*2); FOV_Container.BackgroundTransparency = 1; FOV_Container.Visible = false
for i = 1, 16 do
    local s = Instance.new("Frame", FOV_Container); s.Size = UDim2.new(0, 2, 0, 12); s.BackgroundColor3 = Config.Theme.Accent; s.BorderSizePixel = 0; s.AnchorPoint = Vector2.new(0.5, 0.5)
    local rad = math.rad((i-1)*(360/16)); s.Position = UDim2.new(0.5 + math.cos(rad)*0.5, 0, 0.5 + math.sin(rad)*0.5, 0); s.Rotation = ((i-1)*(360/16)) + 90; Instance.new("UICorner", s)
end

-- --- [2] MENU CONSTRUCTION ---
local Main = Instance.new("Frame", ScreenGui); Main.Size = UDim2.new(0, 310, 0, 380); Main.Position = UDim2.new(0.5, -155, 0.5, -190); Main.BackgroundColor3 = Config.Theme.Dark; Main.Visible = false; Main.Active = true; Main.Draggable = true; Instance.new("UICorner", Main); local Stroke = Instance.new("UIStroke", Main); Stroke.Color = Config.Theme.Accent

local TabBtnH = Instance.new("Frame", Main); TabBtnH.Size = UDim2.new(1, 0, 0, 35); TabBtnH.BackgroundTransparency = 1; Instance.new("UIListLayout", TabBtnH).FillDirection = "Horizontal"
local Pages = Instance.new("Frame", Main); Pages.Size = UDim2.new(1, -10, 1, -45); Pages.Position = UDim2.new(0, 5, 0, 40); Pages.BackgroundTransparency = 1

local function CreatePage(name)
    local p = Instance.new("ScrollingFrame", Pages); p.Name = name; p.Size = UDim2.new(1, 0, 1, 0); p.BackgroundTransparency = 1; p.Visible = false; p.ScrollBarThickness = 2; p.CanvasSize = UDim2.new(0, 0, 2.5, 0)
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 5)
    local b = Instance.new("TextButton", TabBtnH); b.Size = UDim2.new(0.25, 0, 1, 0); b.Text = name; b.Font = "GothamBold"; b.TextSize = 8; b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.TextColor3 = Color3.new(0.5, 0.5, 0.5); b.BorderSizePixel = 0
    b.MouseButton1Click:Connect(function()
        for _, pg in pairs(Pages:GetChildren()) do if pg:IsA("ScrollingFrame") then pg.Visible = false end end
        p.Visible = true
    end)
    return p
end

local PageAim = CreatePage("Aim"); local PagePlayer = CreatePage("Player"); local PageESP = CreatePage("ESP"); local PageBoost = CreatePage("Boost")
PageAim.Visible = true

-- UI Helpers
local function AddToggle(p, txt, default, cb)
    local act = default; local b = Instance.new("TextButton", p); b.Size = UDim2.new(0.95, 0, 0, 32); b.Text = txt..": "..(act and "ON" or "OFF"); b.BackgroundColor3 = act and Config.Theme.Accent or Color3.fromRGB(35, 35, 35); b.TextColor3 = act and Color3.new(0,0,0) or Color3.new(1,1,1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() act = not act; cb(act); b.Text = txt..": "..(act and "ON" or "OFF"); b.BackgroundColor3 = act and Config.Theme.Accent or Color3.fromRGB(35,35,35); b.TextColor3 = act and Color3.new(0,0,0) or Color3.new(1,1,1) end)
end

local function AddInput(p, label, default, cb)
    local f = Instance.new("Frame", p); f.Size = UDim2.new(0.95, 0, 0, 32); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.6, 0, 1, 0); l.Text = label; l.TextColor3 = Color3.new(0.8,0.8,0.8); l.TextXAlignment = "Left"; l.BackgroundTransparency = 1; l.Font = "Gotham"; l.TextSize = 10
    local i = Instance.new("TextBox", f); i.Size = UDim2.new(0.3, 0, 0.8, 0); i.Position = UDim2.new(0.7, 0, 0.1, 0); i.Text = tostring(default); i.BackgroundColor3 = Color3.fromRGB(40,40,40); i.TextColor3 = Config.Theme.Accent; Instance.new("UICorner", i)
    i.FocusLost:Connect(function() cb(i.Text) end)
end

-- --- [3] CONTENT ---
AddToggle(PageAim, "Master Aimbot", false, function(s) Config.Aimbot.Active = s; FOV_Container.Visible = s end)
local PartBtn = Instance.new("TextButton", PageAim); PartBtn.Size = UDim2.new(0.95,0,0,32); PartBtn.Text = "Target Part: Head"; PartBtn.BackgroundColor3 = Color3.fromRGB(45,45,45); PartBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", PartBtn)
PartBtn.MouseButton1Click:Connect(function()
    if Config.Aimbot.TargetPart == "Head" then Config.Aimbot.TargetPart = "HumanoidRootPart"; PartBtn.Text = "Target Part: Torso"
    else Config.Aimbot.TargetPart = "Head"; PartBtn.Text = "Target Part: Head" end
end)
AddInput(PageAim, "Aim Speed", 15, function(v) Config.Aimbot.Speed = (tonumber(v) or 15)/100 end)
AddInput(PageAim, "FOV Size", 150, function(v) Config.Aimbot.FOV = tonumber(v) or 150; FOV_Container.Size = UDim2.new(0, Config.Aimbot.FOV*2, 0, Config.Aimbot.FOV*2) end)

AddInput(PagePlayer, "WalkSpeed", 16, function(v) Config.Player.WS = tonumber(v) or 16 end)
AddToggle(PagePlayer, "Enable WalkSpeed", false, function(s) Config.Player.Active = s end)
AddInput(PagePlayer, "Jump Power", 50, function(v) Config.Player.JP = tonumber(v) or 50 end)
AddToggle(PagePlayer, "Enable Jump", false, function(s) if s then LocalPlayer.Character.Humanoid.JumpPower = Config.Player.JP end end)

AddToggle(PageESP, "Master ESP", false, function(s) Config.ESP.Active = s end)
AddToggle(PageESP, "Show Health Bar", true, function(s) Config.ESP.Health = s end)
AddToggle(PageESP, "Show Distance", true, function(s) Config.ESP.Distance = s end)

-- --- [4] CORE LOOP ---
RunService.RenderStepped:Connect(function()
    -- Aim Logic
    if Config.Aimbot.Active then
        local target = nil; local minMag = Config.Aimbot.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Config.Aimbot.TargetPart) and p.Character.Humanoid.Health > 0 then
                if Config.Aimbot.TeamCheck and p.Team == LocalPlayer.Team then continue end
                local pos, vis = Camera:WorldToViewportPoint(p.Character[Config.Aimbot.TargetPart].Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mag < minMag then target = p.Character[Config.Aimbot.TargetPart]; minMag = mag end
                end
            end
        end
        if target then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Config.Aimbot.Speed) end
        FOV_Container.Rotation = FOV_Container.Rotation + 2 -- Quay tâm
    end

    -- Player Logic
    if Config.Player.Active and LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = Config.Player.WS end

    -- Smart ESP Logic
    for _, v in pairs(ScreenGui:GetChildren()) do if v.Name == "ESP_M" then v:Destroy() end end
    if Config.ESP.Active then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
                local headPos, headVis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if headVis then
                    local dist = math.floor((LocalPlayer.Character.Head.Position - p.Character.Head.Position).Magnitude)
                    local mainFrame = Instance.new("Frame", ScreenGui); mainFrame.Name = "ESP_M"; mainFrame.Size = UDim2.new(0, 100, 0, 40); mainFrame.Position = UDim2.new(0, headPos.X - 50, 0, headPos.Y - 60); mainFrame.BackgroundTransparency = 1
                    
                    local nameL = Instance.new("TextLabel", mainFrame); nameL.Size = UDim2.new(1, 0, 0, 15); nameL.Text = p.Name .. (Config.ESP.Distance and " ["..dist.."m]" or ""); nameL.TextColor3 = Color3.new(1,1,1); nameL.Font = "GothamBold"; nameL.TextSize = 10; nameL.BackgroundTransparency = 1; nameL.TextStrokeTransparency = 0
                    
                    if Config.ESP.Health then
                        local hBarBg = Instance.new("Frame", mainFrame); hBarBg.Size = UDim2.new(0.8, 0, 0, 3); hBarBg.Position = UDim2.new(0.1, 0, 0, 18); hBarBg.BackgroundColor3 = Color3.new(0,0,0); hBarBg.BorderSizePixel = 0
                        local hBar = Instance.new("Frame", hBarBg); hBar.Size = UDim2.new(p.Character.Humanoid.Health/p.Character.Humanoid.MaxHealth, 0, 1, 0); hBar.BackgroundColor3 = Color3.new(0,1,0); hBar.BorderSizePixel = 0
                    end
                end
            end
        end
    end
end)

-- Buttons
local M_B = Instance.new("TextButton", ScreenGui); M_B.Size = UDim2.new(0, 45, 0, 45); M_B.Position = UDim2.new(0, 20, 0, 160); M_B.Text = "M"; M_B.BackgroundColor3 = Color3.fromRGB(30, 30, 30); M_B.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", M_B).CornerRadius = UDim.new(1, 0)
local A_B = Instance.new("TextButton", ScreenGui); A_B.Size = UDim2.new(0, 45, 0, 45); A_B.Position = UDim2.new(0, 20, 0, 215); A_B.Text = "A"; A_B.BackgroundColor3 = Color3.fromRGB(200, 0, 0); A_B.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", A_B).CornerRadius = UDim.new(1, 0)
M_B.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
A_B.MouseButton1Click:Connect(function() Config.Aimbot.Active = not Config.Aimbot.Active; FOV_Container.Visible = Config.Aimbot.Active; A_B.BackgroundColor3 = Config.Aimbot.Active and Config.Theme.Accent or Color3.fromRGB(200, 0, 0) end)
