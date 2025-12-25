--[[ 
    HUYẾT v55.0: PRO-LOGIC (DEGREES PER SECOND)
    - CONVERTED: Tốc độ Aim từ % sang Độ/Giây (Default: 50độ/s).
    - LOGIC: Di chuyển tâm mượt mà với vận tốc không đổi.
    - STABILITY: ESP Auto-Refresh & Single Target Lock.
    - HUD: Y=90 (Dưới thanh máu mặc định).
]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 1. CLEANUP
for _, v in pairs(CoreGui:GetChildren()) do
    if v:IsA("ScreenGui") and (v.Name:find("Huyet") or v.Name:find("v5")) then v:Destroy() end
end

local Config = {
    Aim = {Act = false, FOV = 150, Wall = true, Team = true, DegreesPerSec = 50, Part = "Head", OX = 0, OY = 0},
    ESP = {Act = false, Health = false, Lines = false, Team = true}
}

-- 2. FOV DRAWING
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.Color = Color3.fromRGB(0, 255, 150); FOVCircle.Transparency = 1; FOVCircle.Filled = false

-- 3. INTERFACE
local SG = Instance.new("ScreenGui", CoreGui); SG.Name = "v55_Huyet_Pro"; SG.IgnoreGuiInset = true
local Main = Instance.new("Frame", SG); Main.AnchorPoint = Vector2.new(0.5, 0.5); Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.Size = UDim2.new(0, 280, 0, 440); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Visible = false; Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main); Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 255, 150)

local Header = Instance.new("Frame", Main); Header.Size = UDim2.new(1, 0, 0, 25); Header.Position = UDim2.new(0, 0, 0, -28); Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", Header); Instance.new("UIStroke", Header).Color = Color3.fromRGB(0, 255, 150)
local MonTxt = Instance.new("TextLabel", Header); MonTxt.Size = UDim2.new(1, 0, 1, 0); MonTxt.BackgroundTransparency = 1; MonTxt.TextColor3 = Color3.new(1, 1, 1); MonTxt.Font = "GothamBold"; MonTxt.TextSize = 10; MonTxt.Text = "STABLE"

local Cont = Instance.new("ScrollingFrame", Main); Cont.Position = UDim2.new(0, 10, 0, 10); Cont.Size = UDim2.new(1, -20, 1, -20); Cont.BackgroundTransparency = 1; Cont.CanvasSize = UDim2.new(0,0,0,0); Cont.AutomaticCanvasSize = "Y"; Cont.ScrollBarThickness = 2
Instance.new("UIListLayout", Cont).Padding = UDim.new(0, 4)

-- 4. HUD CỐ ĐỊNH (Y=90)
local HUD = Instance.new("Frame", SG); HUD.Name = "HealthHUD_v55"; HUD.Size = UDim2.new(0, 200, 0, 40); HUD.Position = UDim2.new(0.5, -95, 0, 90); HUD.BackgroundTransparency = 1
local HPLabel = Instance.new("TextLabel", HUD); HPLabel.Size = UDim2.new(1, 0, 0, 18); HPLabel.BackgroundTransparency = 1; HPLabel.TextColor3 = Color3.new(1, 1, 1); HPLabel.Font = "GothamBold"; HPLabel.TextSize = 12; HPLabel.TextXAlignment = "Left"; HPLabel.TextStrokeTransparency = 0.5
local RegenLabel = Instance.new("TextLabel", HUD); RegenLabel.Size = UDim2.new(1, 0, 0, 12); RegenLabel.Position = UDim2.new(0, 0, 0, 16); RegenLabel.BackgroundTransparency = 1; RegenLabel.TextColor3 = Color3.fromRGB(0, 255, 150); RegenLabel.Font = "GothamBold"; RegenLabel.TextSize = 9; RegenLabel.TextXAlignment = "Left"

-- Helpers
local function AddT(txt, start, cb)
    local b = Instance.new("TextButton", Cont); b.Size = UDim2.new(1, 0, 0, 26); b.Text = txt..": "..(start and "ON" or "OFF"); b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.TextColor3 = Color3.new(1, 1, 1); b.Font = "GothamBold"; b.TextSize = 9; Instance.new("UICorner", b)
    local s = start; b.MouseButton1Click:Connect(function() s = not s; b.Text = txt..": "..(s and "ON" or "OFF"); cb(s) end)
end

local function AddI(label, default, cb)
    local f = Instance.new("Frame", Cont); f.Size = UDim2.new(1, 0, 0, 26); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.5, 0, 1, 0); l.Text = label; l.TextColor3 = Color3.new(0.7,0.7,0.7); l.BackgroundTransparency = 1; l.TextXAlignment = "Left"; l.Font = "GothamBold"; l.TextSize = 8
    local i = Instance.new("TextBox", f); i.Size = UDim2.new(0.4, 0, 0.8, 0); i.Position = UDim2.new(0.6, 0, 0.1, 0); i.Text = tostring(default); i.BackgroundColor3 = Color3.fromRGB(40,40,40); i.TextColor3 = Color3.new(0, 1, 0.8); i.Font = "GothamBold"; i.TextSize = 9; Instance.new("UICorner", i)
    i.FocusLost:Connect(function() cb(i.Text) end)
end

-- --- MENU CONTENT ---
AddT("AIMBOT", false, function(s) Config.Aim.Act = s end)
AddT("TEAM CHECK", true, function(s) Config.Aim.Team = s end)
AddT("WALL CHECK", true, function(s) Config.Aim.Wall = s end)
AddI("ĐỘ / GIÂY", 50, function(v) Config.Aim.DegreesPerSec = tonumber(v) or 50 end)
AddI("BÁN KÍNH FOV", 150, function(v) Config.Aim.FOV = tonumber(v) or 150 end)
AddI("OFFSET X", 0, function(v) Config.Aim.OX = tonumber(v) or 0 end)
AddI("OFFSET Y", 0, function(v) Config.Aim.OY = tonumber(v) or 0 end)
AddT("ESP INFO", false, function(s) Config.ESP.Act = s end)
AddT("ESP % MÁU", false, function(s) Config.ESP.Health = s end)
AddT("ESP LINE", false, function(s) Config.ESP.Lines = s end)

-- --- CORE FUNCTIONS ---
local function getAngleBetween(cf1, cf2)
    local unit1 = cf1.LookVector
    local unit2 = (cf2.Position - cf1.Position).Unit
    return math.acos(math.clamp(unit1:Dot(unit2), -1, 1))
end

-- --- MAIN LOGIC LOOP ---
local lastHP, lastTick = 0, tick()

RunService.RenderStepped:Connect(function(dt)
    FOVCircle.Visible = Config.Aim.Act and not Main.Visible
    FOVCircle.Radius = Config.Aim.FOV; FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    MonTxt.Text = string.format("FPS: %d | PING: %dms", math.floor(1/dt), math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()))

    -- HUD LOCAL PLAYER
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        local hum = LP.Character.Humanoid
        if tick() - lastTick >= 1 then
            RegenLabel.Text = string.format("REGEN: %+.2f%% / s", ((hum.Health - lastHP)/hum.MaxHealth)*100)
            lastHP, lastTick = hum.Health, tick()
        end
        HPLabel.Text = string.format("%.2f / %.0f HP", hum.Health, hum.MaxHealth)
        HPLabel.TextColor3 = Color3.fromHSV((math.clamp(hum.Health/hum.MaxHealth, 0, 1) * 0.35), 1, 1)
    end

    -- AIMBOT (CONSTANT SPEED MODE)
    if Config.Aim.Act then
        local targetPart, shortestDist = nil, Config.Aim.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild(Config.Aim.Part) and p.Character.Humanoid.Health > 0 then
                if not Config.Aim.Team or p.TeamColor ~= LP.TeamColor then
                    local part = p.Character[Config.Aim.Part]
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if mag < shortestDist then
                            local hit = workspace:FindPartOnRayWithIgnoreList(Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 500), {LP.Character, p.Character})
                            if not Config.Aim.Wall or not hit then
                                shortestDist, targetPart = mag, part
                            end
                        end
                    end
                end
            end
        end
        
        if targetPart then
            local aimPos = targetPart.Position + Vector3.new(Config.Aim.OX/10, Config.Aim.OY/10, 0)
            local targetCF = CFrame.new(Camera.CFrame.Position, aimPos)
            local angle = getAngleBetween(Camera.CFrame, targetCF)
            local maxAngle = math.rad(Config.Aim.DegreesPerSec) * dt
            
            if angle > 0 then
                local ratio = math.min(maxAngle / angle, 1)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, ratio)
            end
        end
    end

    -- ESP SYSTEM (AUTO RE-SCAN)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            local char = p.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local guiName, lineName = "v55_ESP_"..p.Name, "v55_Line_"..p.Name

            if char and hrp and char.Humanoid.Health > 0 and (not Config.ESP.Team or p.TeamColor ~= LP.TeamColor) then
                -- Billboard
                local gui = CoreGui:FindFirstChild(guiName)
                if Config.ESP.Act or Config.ESP.Health then
                    if not gui then
                        gui = Instance.new("BillboardGui", CoreGui); gui.Name = guiName; gui.AlwaysOnTop = true; gui.Size = UDim2.new(0,80,0,45)
                        local l = Instance.new("TextLabel", gui); l.Size = UDim2.new(1,0,1,0); l.BackgroundTransparency = 1; l.TextColor3 = Color3.new(1,1,1); l.Font = "GothamBold"; l.TextSize = 8; l.TextStrokeTransparency = 0
                    end
                    gui.Adornee = hrp; gui.Enabled = true
                    gui.TextLabel.Text = (Config.ESP.Act and p.DisplayName or "")..(Config.ESP.Health and "\n"..math.floor(char.Humanoid.Health).."%" or "")
                elseif gui then gui:Destroy() end

                -- Line
                local line = SG:FindFirstChild(lineName)
                if Config.ESP.Lines then
                    local pos, onS = Camera:WorldToViewportPoint(hrp.Position)
                    if onS then
                        if not line then line = Instance.new("Frame", SG); line.Name = lineName; line.BorderSizePixel = 0; line.BackgroundColor3 = Color3.new(0,1,1); line.AnchorPoint = Vector2.new(0.5, 0.5) end
                        local start = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                        local targetPos = Vector2.new(pos.X, pos.Y)
                        line.Size = UDim2.new(0, (targetPos - start).Magnitude, 0, 1)
                        line.Position = UDim2.new(0, (start.X + targetPos.X)/2, 0, (start.Y + targetPos.Y)/2)
                        line.Rotation = math.deg(math.atan2(targetPos.Y - start.Y, targetPos.X - start.X)); line.Visible = true
                    elseif line then line.Visible = false end
                elseif line then line:Destroy() end
            else
                if CoreGui:FindFirstChild(guiName) then CoreGui[guiName]:Destroy() end
                if SG:FindFirstChild(lineName) then SG[lineName]:Destroy() end
            end
        end
    end
end)

-- --- BUTTONS ---
local QA = Instance.new("TextButton", SG); QA.Size = UDim2.new(0, 80, 0, 30); QA.Position = UDim2.new(0, 10, 0, 200); QA.Text = "AIM: OFF"; QA.BackgroundColor3 = Color3.fromRGB(150,0,0); QA.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", QA); QA.Active = true; QA.Draggable = true
QA.MouseButton1Click:Connect(function() 
    Config.Aim.Act = not Config.Aim.Act; QA.Text = "AIM: "..(Config.Aim.Act and "ON" or "OFF"); QA.BackgroundColor3 = Config.Aim.Act and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0) 
end)

local MB = Instance.new("TextButton", SG); MB.Size = UDim2.new(0, 30, 0, 30); MB.Position = UDim2.new(0, 10, 0, 165); MB.Text = "M"; MB.BackgroundColor3 = Color3.fromRGB(30,30,30); MB.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", MB); MB.Active = true; MB.Draggable = true
MB.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
