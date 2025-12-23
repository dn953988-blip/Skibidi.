--[[ 
    HUB NAME: v0.5.5 SUPREME V19 (LOCKED CENTER FOV)
    - FIXED: FOV Circle locked to absolute Screen Center.
    - FIXED: Aim scanning locked to absolute Screen Center.
    - FEATURES: Dynamic Speed (1-100), Team Check, Wall Check, ESP Highlights.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
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
    Aimbot = {Active = false, FOV = 150, Speed = 10, WallCheck = true, TeamCheck = false, TargetPart = "Head"},
    Hitbox = {Active = false, Size = 10, TargetPart = "HumanoidRootPart"},
    ESP = {Active = false, Highlight = false},
    Theme = {Accent = Color3.fromRGB(0, 255, 170), Dark = Color3.fromRGB(15, 15, 15), Trans = 0.65}
}

-- --- [3] UI BASE ---
local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = "v055SupremeV19"
local FOVGui = Instance.new("ScreenGui", CoreGui); FOVGui.Name = "FOV_UI"
local ESPContainer = Instance.new("ScreenGui", CoreGui); ESPContainer.Name = "ESP_CONTAINER"

-- KHÓA CỨNG VÒNG TRÒN TẠI TÂM
local Circle = Instance.new("Frame", FOVGui)
Circle.Name = "AimCircle"
Circle.AnchorPoint = Vector2.new(0.5, 0.5)
Circle.Position = UDim2.new(0.5, 0, 0.5, 0) -- LUÔN Ở GIỮA MÀN HÌNH
Circle.BackgroundTransparency = 1
Circle.Visible = false
Circle.Size = UDim2.new(0, Config.Aimbot.FOV * 2, 0, Config.Aimbot.FOV * 2)

local UICorner = Instance.new("UICorner", Circle)
UICorner.CornerRadius = UDim.new(1, 0)

local UIStroke = Instance.new("UIStroke", Circle)
UIStroke.Color = Config.Theme.Accent; UIStroke.Thickness = 1.5

-- Menu Toggle Button
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 80, 0, 30); OpenBtn.Position = UDim2.new(0, 10, 0.4, 0); OpenBtn.Text = "SUPREME"; OpenBtn.Visible = false
OpenBtn.BackgroundColor3 = Config.Theme.Accent; OpenBtn.TextColor3 = Color3.new(0,0,0); Instance.new("UICorner", OpenBtn)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 520, 0, 380); Main.Position = UDim2.new(0.5, -260, 0.5, -190)
Main.BackgroundColor3 = Config.Theme.Dark; Main.BackgroundTransparency = Config.Theme.Trans
Main.Active = true; Main.Draggable = true; Instance.new("UICorner", Main)

local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, 130, 1, -50); Sidebar.Position = UDim2.new(0, 10, 0, 45); Sidebar.BackgroundTransparency = 1
Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)

local Container = Instance.new("Frame", Main); Container.Size = UDim2.new(1, -160, 1, -50); Container.Position = UDim2.new(0, 150, 0, 45); Container.BackgroundTransparency = 1

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
local T_HIT = CreateTab("HITBOX")

AddBtn(T_AIM, "BẬT MAGNET AIM", function(s) Config.Aimbot.Active = s; Circle.Visible = s end, true)
AddBtn(T_AIM, "TEAM CHECK", function(s) Config.Aimbot.TeamCheck = s end, true)
AddBtn(T_AIM, "WALL CHECK", function(s) Config.Aimbot.WallCheck = s end, true)
AddInp(T_AIM, "Tốc độ Aim (1-100):", "10", function(v) Config.Aimbot.Speed = tonumber(v) or 10 end)
AddInp(T_AIM, "Vòng FOV:", "150", function(v) 
    Config.Aimbot.FOV = tonumber(v) or 150
    Circle.Size = UDim2.new(0, Config.Aimbot.FOV * 2, 0, Config.Aimbot.FOV * 2)
end)

AddBtn(T_VIS, "BẬT ESP TÊN", function(s) Config.ESP.Active = s end, true)
AddBtn(T_VIS, "BẬT HIGHLIGHTS", function(s) Config.ESP.Highlight = s end, true)

AddBtn(T_HIT, "BẬT FAKE HITBOX", function(s) Config.Hitbox.Active = s end, true)
AddInp(T_HIT, "Kích thước:", "10", function(v) Config.Hitbox.Size = tonumber(v) or 10 end)

-- --- [4] CORE LOGIC ---
RunService.RenderStepped:Connect(function(dt)
    -- Tâm màn hình tuyệt đối (Viewport Center)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if Config.Aimbot.Active then
        local target, dist = nil, Config.Aimbot.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Config.Aimbot.TargetPart) and p.Character.Humanoid.Health > 0 then
                if Config.Aimbot.TeamCheck and p.Team == LocalPlayer.Team then continue end
                
                local part = p.Character[Config.Aimbot.TargetPart]
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                
                if onScreen then
                    local mag = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if mag < dist then
                        -- Kiểm tra xuyên tường
                        if Config.Aimbot.WallCheck and #Camera:GetPartsObscuringTarget({part.Position}, {LocalPlayer.Character, p.Character}) > 0 then continue end
                        dist = mag; target = part
                    end
                end
            end
        end
        if target then
            local smoothScale = (Config.Aimbot.Speed / 100)
            local targetRotation = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetRotation, math.clamp(dt * 60 * smoothScale, 0, 1))
        end
    end

    -- ESP & Highlight & Hitbox Logic
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local isTeam = (Config.Aimbot.TeamCheck and p.Team == LocalPlayer.Team)
            
            -- Highlights
            local hl = char:FindFirstChild("SupremeHL")
            if Config.ESP.Highlight and not isTeam then
                if not hl then hl = Instance.new("Highlight", char); hl.Name = "SupremeHL" end
                hl.Enabled = true; hl.FillColor = Config.Theme.Accent
            elseif hl then hl.Enabled = false end

            -- ESP
            local esp = ESPContainer:FindFirstChild(p.Name)
            if Config.ESP.Active and not isTeam and char:FindFirstChild("Head") then
                local headPos, vis = Camera:WorldToViewportPoint(char.Head.Position)
                if vis then
                    if not esp then esp = Instance.new("TextLabel", ESPContainer); esp.Name = p.Name; esp.BackgroundTransparency = 1; esp.TextColor3 = Color3.new(1,1,1); esp.Font = "GothamBold"; esp.TextSize = 14; esp.Size = UDim2.new(0,200,0,20) end
                    esp.Visible = true; esp.Position = UDim2.new(0, headPos.X - 100, 0, headPos.Y - 45)
                    esp.Text = p.DisplayName.."\n"..math.floor((LocalPlayer.Character.Head.Position - char.Head.Position).Magnitude).."m"
                elseif esp then esp.Visible = false end
            elseif esp then esp:Destroy() end

            -- Hitbox
            if Config.Hitbox.Active and not isTeam then
                local root = char:FindFirstChild(Config.Hitbox.TargetPart)
                if root then root.Size = Vector3.new(Config.Hitbox.Size, Config.Hitbox.Size, Config.Hitbox.Size); root.Transparency = 0.7; root.CanCollide = false end
            end
        end
    end
end)

-- UI Toggles
local Close = Instance.new("TextButton", Main); Close.Size = UDim2.new(0,25,0,25); Close.Position = UDim2.new(1,-30,0,5); Close.Text = "X"; Close.BackgroundColor3 = Color3.new(0.6,0,0); Instance.new("UICorner", Close)
Close.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

T_AIM.Visible = true; Tabs["AIM BOT"].BackgroundColor3 = Config.Theme.Accent; Tabs["AIM BOT"].TextColor3 = Color3.new(0,0,0)
