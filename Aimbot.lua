--[[ 
    HUB NAME: aimbot v2.1 (ULTIMATE CONTROL)
    - ADDED: Textboxes for Distance Offset & ESP Range.
    - FIXED: Better UI scaling for Mobile.
    - IMPROVED: Adaptive Accuracy logic.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- --- [1] DỌN DẸP ---
local function Clean()
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name:find("aimbot") or v.Name == "ESP_HOLDER" then v:Destroy() end
    end
end
Clean()

-- --- [2] CONFIG ---
local Config = {
    Aimbot = {
        Active = false, 
        Speed = 0.15, 
        FOV = 150, 
        WallCheck = true, 
        TeamCheck = true, 
        TargetPart = "Head",
        DistOffsetActive = true,
        OffsetAmount = 1.5, -- Độ lệch tâm
        StartDist = 150     -- Khoảng cách bắt đầu lệch
    },
    ESP = {Active = false, TextSize = 12, MaxDist = 1000},
    Theme = {Accent = Color3.fromRGB(0, 255, 170), Dark = Color3.fromRGB(15, 15, 15)}
}

-- --- [3] UI SETUP ---
local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = "aimbot_v2_1"; ScreenGui.IgnoreGuiInset = true
local ESP_Holder = Instance.new("Folder", ScreenGui); ESP_Holder.Name = "ESP_HOLDER"

local FOVCircle = Instance.new("Frame", ScreenGui)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5); FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.Size = UDim2.new(0, Config.Aimbot.FOV * 2, 0, Config.Aimbot.FOV * 2); FOVCircle.BackgroundTransparency = 1; FOVCircle.Visible = false
Instance.new("UIStroke", FOVCircle).Color = Config.Theme.Accent; Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0)

local function QuickBtn(txt, y, color)
    local b = Instance.new("TextButton", ScreenGui); b.Size = UDim2.new(0, 45, 0, 45); b.Position = UDim2.new(0, 20, 0, y); b.Text = txt; b.Font = "GothamBlack"; b.TextSize = 18; b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1,1,1); b.Active = true; b.Draggable = true; Instance.new("UICorner", b).CornerRadius = UDim.new(1,0); return b
end
local M_Btn = QuickBtn("M", 160, Color3.fromRGB(40,40,40))
local A_Btn = QuickBtn("A", 215, Color3.fromRGB(200, 0, 0))

-- --- [4] MENU ---
local Main = Instance.new("Frame", ScreenGui); Main.Size = UDim2.new(0, 280, 0, 450); Main.Position = UDim2.new(0.5, -140, 0.5, -225); Main.BackgroundColor3 = Config.Theme.Dark; Main.Visible = false; Main.Draggable = true; Main.Active = true; Instance.new("UICorner", Main)
local Scroll = Instance.new("ScrollingFrame", Main); Scroll.Size = UDim2.new(1, -10, 1, -20); Scroll.Position = UDim2.new(0, 5, 0, 10); Scroll.BackgroundTransparency = 1; Scroll.CanvasSize = UDim2.new(0,0,2.5,0); Scroll.ScrollBarThickness = 0
local Layout = Instance.new("UIListLayout", Scroll); Layout.Padding = UDim.new(0, 10); Layout.HorizontalAlignment = "Center"

local function AddInput(label, def, cb)
    local f = Instance.new("Frame", Scroll); f.Size = UDim2.new(0.95, 0, 0, 35); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.6, 0, 1, 0); l.Text = label; l.TextColor3 = Color3.new(0.8,0.8,0.8); l.Font = "Gotham"; l.TextSize = 11; l.TextXAlignment = "Left"; l.BackgroundTransparency = 1
    local i = Instance.new("TextBox", f); i.Size = UDim2.new(0.35, 0, 0.9, 0); i.Position = UDim2.new(0.65, 0, 0, 0); i.Text = def; i.BackgroundColor3 = Color3.fromRGB(40,40,40); i.TextColor3 = Config.Theme.Accent; i.Font = "GothamBold"; i.TextSize = 11; i.ClearTextOnFocus = false; Instance.new("UICorner", i)
    i.FocusLost:Connect(function() cb(i.Text) end)
end

local function AddToggle(txt, active, cb)
    local b = Instance.new("TextButton", Scroll); b.Size = UDim2.new(0.95, 0, 0, 38); b.Text = txt; b.Font = "GothamBold"; b.TextSize = 12; b.BackgroundColor3 = active and Config.Theme.Accent or Color3.fromRGB(35,35,35); b.TextColor3 = active and Color3.new(0,0,0) or Color3.new(1,1,1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() active = not active; b.BackgroundColor3 = active and Config.Theme.Accent or Color3.fromRGB(35,35,35); b.TextColor3 = active and Color3.new(0,0,0) or Color3.new(1,1,1); cb(active) end)
end

-- Controls
AddInput("Tốc độ Aim (1-100):", "15", function(v) Config.Aimbot.Speed = (tonumber(v) or 15) / 100 end)
AddInput("Size Vòng Aim:", "150", function(v) Config.Aimbot.FOV = tonumber(v) or 150; FOVCircle.Size = UDim2.new(0, Config.Aimbot.FOV * 2, 0, Config.Aimbot.FOV * 2) end)
AddInput("Độ lệch tâm (1-10):", "1.5", function(v) Config.Aimbot.OffsetAmount = tonumber(v) or 1.5 end)
AddInput("Cách bao xa thì lệch:", "150", function(v) Config.Aimbot.StartDist = tonumber(v) or 150 end)
AddInput("Tầm xa ESP (m):", "1000", function(v) Config.ESP.MaxDist = tonumber(v) or 1000 end)

AddToggle("Team Check", true, function(s) Config.Aimbot.TeamCheck = s end)
AddToggle("Wall Check", true, function(s) Config.Aimbot.WallCheck = s end)
AddToggle("Bật ESP + Highlights", false, function(s) Config.ESP.Active = s end)

-- --- [5] CORE LOGIC ---
M_Btn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
A_Btn.MouseButton1Click:Connect(function()
    Config.Aimbot.Active = not Config.Aimbot.Active
    A_Btn.BackgroundColor3 = Config.Aimbot.Active and Config.Theme.Accent or Color3.fromRGB(200, 0, 0)
    FOVCircle.Visible = Config.Aimbot.Active
end)

RunService.RenderStepped:Connect(function()
    if Config.Aimbot.Active then
        local target, minMag = nil, Config.Aimbot.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Config.Aimbot.TargetPart) and p.Character.Humanoid.Health > 0 then
                if Config.Aimbot.TeamCheck and p.Team == LocalPlayer.Team then continue end
                local part = p.Character[Config.Aimbot.TargetPart]
                local pos, vis = Camera:WorldToViewportPoint(part.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mag < minMag then
                        if Config.Aimbot.WallCheck and #Camera:GetPartsObscuringTarget({part.Position}, {LocalPlayer.Character, p.Character}) > 0 then continue end
                        target = part; minMag = mag
                    end
                end
            end
        end
        if target then
            local targetPos = target.Position
            local dist = (LocalPlayer.Character.Head.Position - targetPos).Magnitude
            
            if dist > Config.Aimbot.StartDist then
                local scale = (dist / 100) * Config.Aimbot.OffsetAmount
                targetPos = targetPos + Vector3.new(math.random(-1,1)*scale, math.random(-1,1)*scale, math.random(-1,1)*scale)
            end
            
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), Config.Aimbot.Speed)
        end
    end

    -- ESP
    for _, p in pairs(Players:GetPlayers()) do
        local char = p.Character
        local tag = ESP_Holder:FindFirstChild(p.Name)
        if Config.ESP.Active and p ~= LocalPlayer and char and char:FindFirstChild("Head") and char.Humanoid.Health > 0 then
            local dist = math.floor((LocalPlayer.Character.Head.Position - char.Head.Position).Magnitude)
            if dist <= Config.ESP.MaxDist then
                if not tag then
                    tag = Instance.new("BillboardGui", ESP_Holder); tag.Name = p.Name; tag.Size = UDim2.new(0, 200, 0, 50); tag.AlwaysOnTop = true; tag.ExtentsOffset = Vector3.new(0, 3, 0)
                    local l = Instance.new("TextLabel", tag); l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1; l.Font = "GothamBold"; l.TextColor3 = Color3.new(1,1,1); Instance.new("UIStroke", l).Thickness = 1
                end
                tag.Adornee = char.Head
                tag.TextLabel.Text = string.format("%s\n%d HP | %dm", p.DisplayName, math.floor(char.Humanoid.Health), dist)
                
                local hl = char:FindFirstChild("Aimbot_HL")
                if not hl then hl = Instance.new("Highlight", char); hl.Name = "Aimbot_HL" end
                hl.Enabled = true
            elseif tag then tag:Destroy() end
        elseif tag then tag:Destroy() end
    end
end)
