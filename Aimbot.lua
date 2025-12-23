--[[ 
    HUB NAME: v0.5.5 SUPREME V21 (SPEED TEXTBOX FIX)
    - FIXED: Aim Speed Textbox (Default 180, Max 360).
    - REMOVED: Size Textbox.
    - ADDED: Targeted Body Part Buttons.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- --- [1] CLEAN UP ---
local function Clean()
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name:find("v055") or v.Name == "FOV_UI" or v.Name == "ESP_CONTAINER" then v:Destroy() end
    end
end
Clean()

-- --- [2] CONFIG ---
local Config = {
    Aimbot = {Active = false, FOV = 150, Speed = 180, WallCheck = true, TeamCheck = false, TargetPart = "Head"},
    ESP = {Active = false, Highlight = false},
    Theme = {Accent = Color3.fromRGB(0, 255, 170), Dark = Color3.fromRGB(15, 15, 15), Trans = 0.65}
}

-- --- [3] UI CONSTRUCTION ---
local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = "v055SupremeV21"
local FOVGui = Instance.new("ScreenGui", CoreGui); FOVGui.Name = "FOV_UI"

local Circle = Instance.new("Frame", FOVGui)
Circle.AnchorPoint = Vector2.new(0.5, 0.5); Circle.Position = UDim2.new(0.5, 0, 0.5, 0)
Circle.BackgroundTransparency = 1; Circle.Visible = false
Circle.Size = UDim2.new(0, Config.Aimbot.FOV*2, 0, Config.Aimbot.FOV*2)
Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
local Stroke = Instance.new("UIStroke", Circle); Stroke.Color = Config.Theme.Accent; Stroke.Thickness = 1.5

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 500, 0, 350); Main.Position = UDim2.new(0.5, -250, 0.5, -175)
Main.BackgroundColor3 = Config.Theme.Dark; Main.BackgroundTransparency = Config.Theme.Trans
Main.Active = true; Main.Draggable = true; Instance.new("UICorner", Main)

local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, 120, 1, -50); Sidebar.Position = UDim2.new(0, 10, 0, 45); Sidebar.BackgroundTransparency = 1
Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)

local Container = Instance.new("Frame", Main); Container.Size = UDim2.new(1, -150, 1, -50); Container.Position = UDim2.new(0, 140, 0, 45); Container.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name)
    local f = Instance.new("ScrollingFrame", Container); f.Size = UDim2.new(1,0,1,0); f.BackgroundTransparency = 1; f.Visible = false; f.ScrollBarThickness = 0
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 10)
    local b = Instance.new("TextButton", Sidebar); b.Size = UDim2.new(1, 0, 0, 35); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(30,30,30); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Visible = false end; f.Visible = true
        for _, btn in pairs(Sidebar:GetChildren()) do if btn:IsA("TextButton") then btn.BackgroundColor3 = Color3.fromRGB(30,30,30); btn.TextColor3 = Color3.new(1,1,1) end end
        b.BackgroundColor3 = Config.Theme.Accent; b.TextColor3 = Color3.new(0,0,0)
    end)
    Tabs[name] = f return f
end

local function AddBtn(parent, text, cb, toggle)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(0.95, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.TextColor3 = Color3.new(1,1,1); b.Text = text; Instance.new("UICorner", b)
    local on = false
    b.MouseButton1Click:Connect(function()
        if toggle then on = not on; b.BackgroundColor3 = on and Config.Theme.Accent or Color3.fromRGB(40,40,40); b.TextColor3 = on and Color3.new(0,0,0) or Color3.new(1,1,1) end
        cb(on)
    end)
end

local function AddInp(parent, label, def, cb)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(0.95, 0, 0, 40); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.6, 0, 1, 0); l.Text = label; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextXAlignment = "Left"
    local i = Instance.new("TextBox", f); i.Size = UDim2.new(0.35, 0, 0.8, 0); i.Position = UDim2.new(0.65, 0, 0.1, 0); i.Text = def; i.BackgroundColor3 = Color3.fromRGB(30,30,30); i.TextColor3 = Config.Theme.Accent; Instance.new("UICorner", i)
    i.FocusLost:Connect(function() cb(i.Text) end)
end

-- TABS SETUP
local T_AIM = CreateTab("AIM BOT")
local T_VIS = CreateTab("VISUALS")

-- AIM SETTINGS
AddBtn(T_AIM, "BẬT MAGNET AIM", function(s) Config.Aimbot.Active = s; Circle.Visible = s end, true)
AddInp(T_AIM, "Tốc độ (Max 360):", "180", function(v) 
    local num = tonumber(v) or 180
    Config.Aimbot.Speed = math.clamp(num, 1, 360) 
end)
AddBtn(T_AIM, "NHẮM VÀO: ĐẦU", function() Config.Aimbot.TargetPart = "Head" end, false)
AddBtn(T_AIM, "NHẮM VÀO: THÂN", function() Config.Aimbot.TargetPart = "UpperTorso" end, false)
AddBtn(T_AIM, "WALL CHECK", function(s) Config.Aimbot.WallCheck = s end, true)

-- VISUAL SETTINGS
AddBtn(T_VIS, "BẬT HIGHLIGHTS", function(s) Config.ESP.Highlight = s end, true)

-- --- [4] CORE LOGIC ---
RunService.RenderStepped:Connect(function(dt)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if Config.Aimbot.Active then
        local target, dist = nil, Config.Aimbot.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Config.Aimbot.TargetPart) and p.Character.Humanoid.Health > 0 then
                local part = p.Character[Config.Aimbot.TargetPart]
                local pos, vis = Camera:WorldToViewportPoint(part.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    if mag < dist then
                        if Config.Aimbot.WallCheck and #Camera:GetPartsObscuringTarget({part.Position}, {LocalPlayer.Character, p.Character}) > 0 then continue end
                        dist = mag; target = part
                    end
                end
            end
        end
        if target then
            -- Tốc độ aim mượt dựa trên dt và giá trị nhập vào
            local smoothValue = Config.Aimbot.Speed / 10
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), math.clamp(dt * smoothValue, 0, 1))
        end
    end

    -- Highlights Logic
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hl = p.Character:FindFirstChild("SupremeHL")
            if Config.ESP.Highlight then
                if not hl then hl = Instance.new("Highlight", p.Character); hl.Name = "SupremeHL" end
                hl.Enabled = true; hl.FillColor = Config.Theme.Accent
            elseif hl then hl.Enabled = false end
        end
    end
end)

-- UI Toggles
local Close = Instance.new("TextButton", Main); Close.Size = UDim2.new(0,25,0,25); Close.Position = UDim2.new(1,-30,0,5); Close.Text = "X"; Close.BackgroundColor3 = Color3.new(0.6,0,0); Instance.new("UICorner", Close)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy(); Clean() end)

T_AIM.Visible = true
