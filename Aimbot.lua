--[[ 
    HUYẾT v55.1: SUPER-FIX (FINAL STABILITY)
    - FIXED: Aimbot Lock (Sử dụng logic quét mục tiêu mới).
    - FIXED: ESP (Tự động nhận diện sau khi đối thủ hồi sinh).
    - SPEED: Giữ nguyên Độ/Giây (Mặc định 50).
    - WALLCHECK: Nâng cấp logic phát hiện vật cản.
]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 1. DỌN DẸP SCRIPT LỖI
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
local SG = Instance.new("ScreenGui", CoreGui); SG.Name = "v55_Huyet_Stable_Fix"; SG.IgnoreGuiInset = true
local Main = Instance.new("Frame", SG); Main.AnchorPoint = Vector2.new(0.5, 0.5); Main.Position = UDim2.new(0.5, 0, 0.5, 0); Main.Size = UDim2.new(0, 280, 0, 440); Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Visible = false; Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main); Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 255, 150)

local Header = Instance.new("Frame", Main); Header.Size = UDim2.new(1, 0, 0, 25); Header.Position = UDim2.new(0, 0, 0, -28); Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", Header); Instance.new("UIStroke", Header).Color = Color3.fromRGB(0, 255, 150)
local MonTxt = Instance.new("TextLabel", Header); MonTxt.Size = UDim2.new(1, 0, 1, 0); MonTxt.BackgroundTransparency = 1; MonTxt.TextColor3 = Color3.new(1, 1, 1); MonTxt.Font = "GothamBold"; MonTxt.TextSize = 10; MonTxt.Text = "SYSTEM ACTIVE"

local Cont = Instance.new("ScrollingFrame", Main); Cont.Position = UDim2.new(0, 10, 0, 10); Cont.Size = UDim2.new(1, -20, 1, -20); Cont.BackgroundTransparency = 1; Cont.CanvasSize = UDim2.new(0,0,0,0); Cont.AutomaticCanvasSize = "Y"; Cont.ScrollBarThickness = 2
Instance.new("UIListLayout", Cont).Padding = UDim.new(0, 4)

-- 4. HUD MÁU CHUẨN (Y=90)
local HUD = Instance.new("Frame", SG); HUD.Name = "HealthHUD_v55_Fix"; HUD.Size = UDim2.new(0, 200, 0, 40); HUD.Position = UDim2.new(0.5, -95, 0, 90); HUD.BackgroundTransparency = 1
local HPLabel = Instance.new("TextLabel", HUD); HPLabel.Size = UDim2.new(1, 0, 0, 18); HPLabel.BackgroundTransparency = 1; HPLabel.TextColor3 = Color3.new(1, 1, 1); HPLabel.Font = "GothamBold"; HPLabel.TextSize = 12; HPLabel.TextXAlignment = "Left"; HPLabel.TextStrokeTransparency = 0.5
local RegenLabel = Instance.new("TextLabel", HUD); RegenLabel.Size = UDim2.new(1, 0, 0, 12); RegenLabel.Position = UDim2.new(0, 0, 0, 16); RegenLabel.BackgroundTransparency = 1; RegenLabel.TextColor3 = Color3.fromRGB(0, 255, 150); RegenLabel.Font = "GothamBold"; RegenLabel.TextSize = 9; RegenLabel.TextXAlignment = "Left"

-- Menu Helpers
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

-- --- LOGIC CORE ---
local lastHP, lastTick = 0, tick()

RunService.RenderStepped:Connect(function(dt)
    FOVCircle.Visible = Config.Aim.Act and not Main.Visible
    FOVCircle.Radius = Config.Aim.FOV; FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    MonTxt.Text = string.format("FPS: %d | PING: %dms", math.floor(1/dt), math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()))

    -- 1. HUD LOCAL PLAYER
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        local hum = LP.Character.Humanoid
        if tick() - lastTick >= 1 then
            RegenLabel.Text = string.format("REGEN: %+.2f%% / s", ((hum.Health - lastHP)/hum.MaxHealth)*100)
            lastHP, lastTick = hum.Health, tick()
        end
        HPLabel.Text = string.format("%.2f / %.0f HP", hum.Health, hum.MaxHealth)
        HPLabel.TextColor3 = Color3.fromHSV((math.clamp(hum.Health/hum.MaxHealth, 0, 1) * 0.35), 1, 1)
    end

    -- 2. AIMBOT FIX (SUPER LOCK)
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
                            local isVisible = true
                            if Config.Aim.Wall then
                                local parts = Camera:GetPartsObscuringTarget({part.Position}, {LP.Character, p.Character})
                                if #parts > 0 then isVisible = false end
                            end
                            if isVisible then shortestDist, targetPart = mag, part end
                        end
                    end
                end
            end
        end

        if targetPart then
            local aimPos = targetPart.Position + Vector3.new(Config.Aim.OX/10, Config.Aim.OY/10, 0)
            local targetCF = CFrame.new(Camera.CFrame.Position, aimPos)
            local maxAngle = math.rad(Config.Aim.DegreesPerSec) * dt
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, math.clamp(maxAngle, 0, 1))
        end
    end

    -- 3. ESP FIX (FULL RE-SCAN)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            local guiName, lineName = "v55_G_"..p.Name, "v55_L_"..p.Name
            local char = p.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")

            if char and hrp and hum and hum.Health > 0 and (not Config.ESP.Team or p.TeamColor ~= LP.TeamColor) then
                -- Billboard ESP
                if Config.ESP.Act or Config.ESP.Health then
                    local gui = CoreGui:FindFirstChild(guiName) or Instance.new("BillboardGui", CoreGui)
                    gui.Name = guiName; gui.AlwaysOnTop = true; gui.Size = UDim2.new(0,100,0,50); gui.Adornee = hrp
                    local lbl = gui:FindFirstChild("Txt") or Instance.new("TextLabel", gui)
                    lbl.Name = "Txt"; lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.new(1,1,1); lbl.Font = "GothamBold"; lbl.TextSize = 8; lbl.TextStrokeTransparency = 0
                    lbl.Text = (Config.ESP.Act and p.DisplayName or "")..(Config.ESP.Health and "\n"..math.floor(hum.Health).."%" or "")
                    gui.Enabled = true
                else
                    if CoreGui:FindFirstChild(guiName) then CoreGui[guiName]:Destroy() end
                end

                -- Line ESP
                if Config.ESP.Lines then
                    local pos, onS = Camera:WorldToViewportPoint(hrp.Position)
                    local line = SG:FindFirstChild(lineName) or Instance.new("Frame", SG)
                    if onS then
                        line.Name = lineName; line.BorderSizePixel = 0; line.BackgroundColor3 = Color3.new(0,1,1); line.AnchorPoint = Vector2.new(0.5, 0.5)
                        local start = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                        local targetPos = Vector2.new(pos.X, pos.Y)
                        line.Size = UDim2.new(0, (targetPos - start).Magnitude, 0, 1)
                        line.Position = UDim2.new(0, (start.X + targetPos.X)/2, 0, (start.Y + targetPos.Y)/2)
                        line.Rotation = math.deg(math.atan2(targetPos.Y - start.Y, targetPos.X - start.X))
                        line.Visible = true
                    else line.Visible = false end
                else
                    if SG:FindFirstChild(lineName) then SG[lineName]:Destroy() end
                end
            else
                -- Tự động dọn dẹp khi đối thủ thoát hoặc chết
                if CoreGui:FindFirstChild(guiName) then CoreGui[guiName]:Destroy() end
                if SG:FindFirstChild(lineName) then SG[lineName]:Destroy() end
            end
        end
    end
end)

-- --- CONTROLS ---
local QA = Instance.new("TextButton", SG); QA.Size = UDim2.new(0, 80, 0, 30); QA.Position = UDim2.new(0, 10, 0, 200); QA.Text = "AIM: OFF"; QA.BackgroundColor3 = Color3.fromRGB(150,0,0); QA.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", QA); QA.Active = true; QA.Draggable = true
QA.MouseButton1Click:Connect(function() 
    Config.Aim.Act = not Config.Aim.Act; QA.Text = "AIM: "..(Config.Aim.Act and "ON" or "OFF"); QA.BackgroundColor3 = Config.Aim.Act and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0) 
end)

local MB = Instance.new("TextButton", SG); MB.Size = UDim2.new(0, 30, 0, 30); MB.Position = UDim2.new(0, 10, 0, 165); MB.Text = "M"; MB.BackgroundColor3 = Color3.fromRGB(30,30,30); MB.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", MB); MB.Active = true; MB.Draggable = true
MB.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
