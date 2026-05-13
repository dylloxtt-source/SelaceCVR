-- [[ SELACE HUB: PREMIER EDITION ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local DiscordLink = "https://discord.gg/9eYR7ecMu"

-----------------------------------------
-- [ КОНФИГ - БЕЗ ИЗМЕНЕНИЙ ]
-----------------------------------------
local Config = {
    Gameplay = { JumpPower = 25.5, JumpEnabled = false, WalkSpeed = 16, SpeedEnabled = false, TiltPower = 4000, TiltEnabled = false },
    Misc = { PhysicsList = {"Bounce", "Athletic", "Wide Reach", "Sprinter", "Solid form", "All Rounder"}, TechList = {"Backrow Blitz", "Mind Reader", "Unbreakable", "Wiper", "Stance", "Fast Approach"}, CurrentPhysics = 2, CurrentTech = 6, AttrEnabled = false },
    Visuals = { TimeOfDay = 14, CustomTime = false, FullBright = false },
    Settings = { ToggleKey = Enum.KeyCode.RightShift, UIOpen = false }
}

local OriginalLighting = { Ambient = Lighting.Ambient, GlobalShadows = Lighting.GlobalShadows, ClockTime = Lighting.ClockTime }

-----------------------------------------
-- [ СИСТЕМА КЛЮЧЕЙ ]
-----------------------------------------
local function VerifyKeyWithServer(key)
    local my_hwid = gethwid and gethwid() or game:GetService("RbxAnalyticsService"):GetClientId()
    local database_url = "https://pastebin.com/raw/2aVHcEnn"
    local success, database_text = pcall(function() return game:HttpGet(database_url) end)
    if not success then return false, "Connection Error!" end
    local currentTime = os.time()

    for line in string.gmatch(database_text, "[^\r\n]+") do
        local split = string.split(line, ":")
        if #split >= 3 then
            local db_key, db_hwid, db_expiry = split[1], split[2], tonumber(split[3])
            if key == db_key then
                if db_hwid ~= "NONE" and my_hwid ~= db_hwid then return false, "Wrong HWID!" end
                if db_expiry ~= 0 and currentTime > db_expiry then return false, "Key Expired!" end
                return true, "Success"
            end
        end
    end
    return false, "Invalid Key"
end

-----------------------------------------
-- [ ОБНОВЛЕННЫЙ UI ]
-----------------------------------------
local UI = {}
UI.__index = UI

function UI.new()
    local self = setmetatable({}, UI)
    self.Tabs = {}

    self.ScreenGui = Instance.new("ScreenGui", CoreGui)
    self.ScreenGui.Name = "SelaceUltimate"

    self.Blur = Instance.new("BlurEffect", Lighting)
    self.Blur.Size = 0

    -- 1. ЭКРАН ЗАГРУЗКИ (ИНЖЕКТИНГ)
    self.LoadingFrame = Instance.new("CanvasGroup", self.ScreenGui)
    self.LoadingFrame.Size = UDim2.new(0, 400, 0, 150)
    self.LoadingFrame.Position = UDim2.new(0.5, -200, 0.5, -75)
    self.LoadingFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    self.LoadingFrame.GroupTransparency = 1
    Instance.new("UICorner", self.LoadingFrame).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", self.LoadingFrame).Color = Color3.fromRGB(138, 43, 226)

    local LoadTitle = Instance.new("TextLabel", self.LoadingFrame)
    LoadTitle.Size = UDim2.new(1, 0, 0, 80)
    LoadTitle.Text = "SELACE INJECTOR"
    LoadTitle.Font = Enum.Font.MontserratBold
    LoadTitle.TextSize = 24
    LoadTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadTitle.BackgroundTransparency = 1

    local ProgressBg = Instance.new("Frame", self.LoadingFrame)
    ProgressBg.Size = UDim2.new(0.8, 0, 0, 4)
    ProgressBg.Position = UDim2.new(0.1, 0, 0.7, 0)
    ProgressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Instance.new("UICorner", ProgressBg)

    local ProgressFill = Instance.new("Frame", ProgressBg)
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    ProgressFill.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    Instance.new("UICorner", ProgressFill)

    -- 2. LOGIN FRAME
    self.LoginFrame = Instance.new("CanvasGroup", self.ScreenGui)
    self.LoginFrame.Size = UDim2.new(0, 480, 0, 360)
    self.LoginFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
    self.LoginFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    self.LoginFrame.Visible = false
    self.LoginFrame.GroupTransparency = 1
    Instance.new("UICorner", self.LoginFrame).CornerRadius = UDim.new(0, 15)
    Instance.new("UIStroke", self.LoginFrame).Color = Color3.fromRGB(138, 43, 226)

    local Bg = Instance.new("ImageLabel", self.LoginFrame)
    Bg.Size = UDim2.new(1, 0, 1, 0)
    Bg.Image = "rbxassetid://12502692237"
    Bg.ImageTransparency = 0.55
    Bg.ScaleType = Enum.ScaleType.Crop
    Bg.BackgroundTransparency = 1

    -- 3. MAIN FRAME (С ШАПКОЙ)
    self.MainFrame = Instance.new("CanvasGroup", self.ScreenGui)
    self.MainFrame.Size = UDim2.new(0, 600, 0, 480)
    self.MainFrame.Position = UDim2.new(0.5, -300, 0.5, -240)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 17)
    self.MainFrame.Visible = false
    self.MainFrame.GroupTransparency = 1
    Instance.new("UICorner", self.MainFrame).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", self.MainFrame).Color = Color3.fromRGB(138, 43, 226)

    -- Header (ШАПКА)
    local Header = Instance.new("Frame", self.MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    Instance.new("UICorner", Header)

    local HeadTitle = Instance.new("TextLabel", Header)
    HeadTitle.Size = UDim2.new(1, -20, 1, 0)
    HeadTitle.Position = UDim2.new(0, 20, 0, 0)
    HeadTitle.Text = "SELACE HUB | PREMIUM EDITION"
    HeadTitle.Font = Enum.Font.MontserratBold
    HeadTitle.TextSize = 18
    HeadTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    HeadTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeadTitle.BackgroundTransparency = 1

    self.TabHolder = Instance.new("Frame", self.MainFrame)
    self.TabHolder.Size = UDim2.new(0, 160, 1, -60)
    self.TabHolder.Position = UDim2.new(0, 10, 0, 60)
    self.TabHolder.BackgroundTransparency = 1
    Instance.new("UIListLayout", self.TabHolder).Padding = UDim.new(0, 10)

    self.Container = Instance.new("Frame", self.MainFrame)
    self.Container.Size = UDim2.new(1, -190, 1, -70)
    self.Container.Position = UDim2.new(0, 180, 0, 60)
    self.Container.BackgroundTransparency = 1

    return self
end

function UI:Inject()
    self.LoadingFrame.GroupTransparency = 1
    TweenService:Create(self.LoadingFrame, TweenInfo.new(0.5), {GroupTransparency = 0}):Play()
    
    local fill = self.LoadingFrame:FindFirstChild("Fill", true)
    TweenService:Create(fill, TweenInfo.new(4.5, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    
    task.wait(5)
    
    TweenService:Create(self.LoadingFrame, TweenInfo.new(0.5), {GroupTransparency = 1}):Play()
    task.wait(0.5)
    self.LoadingFrame.Visible = false
    self.LoginFrame.Visible = true
    TweenService:Create(self.LoginFrame, TweenInfo.new(0.5), {GroupTransparency = 0}):Play()
end

function UI:StartMain()
    TweenService:Create(self.LoginFrame, TweenInfo.new(0.5), {GroupTransparency = 1}):Play()
    task.wait(0.5)
    self.LoginFrame.Visible = false
    self.MainFrame.Visible = true
    Config.Settings.UIOpen = true
    TweenService:Create(self.MainFrame, TweenInfo.new(0.5), {GroupTransparency = 0}):Play()
    TweenService:Create(self.Blur, TweenInfo.new(0.5), {Size = 15}):Play()
end

function UI:CreateTab(name)
    local btn = Instance.new("TextButton", self.TabHolder)
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.Text = name
    btn.TextSize = 18
    btn.Font = Enum.Font.MontserratBold
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Instance.new("UICorner", btn)

    local page = Instance.new("ScrollingFrame", self.Container)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 0
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 15)

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do t.Page.Visible = false t.Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35) end
        page.Visible = true btn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    end)

    table.insert(self.Tabs, {Btn = btn, Page = page})
    if #self.Tabs == 1 then page.Visible = true btn.BackgroundColor3 = Color3.fromRGB(138, 43, 226) end
    return page
end

-- [ ФУНКЦИИ-ПОМОЩНИКИ ]
local function AddToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    btn.Text = "  " .. text .. ": OFF"
    btn.TextSize = 18
    btn.Font = Enum.Font.MontserratBold
    btn.TextColor3 = Color3.fromRGB(200, 80, 80)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        callback(active)
        btn.Text = "  " .. text .. (active and ": ON" or ": OFF")
        btn.TextColor3 = active and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(200, 80, 80)
    end)
end

local function AddInput(parent, text, default, callback)
    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(0.95, 0, 0, 50)
    box.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    box.Text = default
    box.PlaceholderText = text
    box.TextSize = 18
    box.Font = Enum.Font.MontserratBold
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", box)
    box.FocusLost:Connect(function() callback(box.Text) end)
end

local function AddCycle(parent, text, list, current, callback)
    local idx = current
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Text = "  " .. text .. ": " .. list[idx]
    btn.TextSize = 18
    btn.Font = Enum.Font.MontserratBold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        idx = idx + 1 if idx > #list then idx = 1 end
        btn.Text = "  " .. text .. ": " .. list[idx]
        callback(idx)
    end)
end

-----------------------------------------
-- [ СБОРКА ]
-----------------------------------------
local HubUI = UI.new()
local TabG = HubUI:CreateTab("Gameplay")
local TabM = HubUI:CreateTab("Misc")
local TabV = HubUI:CreateTab("Visuals")

-- Добавляем кнопки (для логина)
local function LoginBtn(text, pos, color, cb)
    local b = Instance.new("TextButton", HubUI.LoginFrame)
    b.Size = UDim2.new(0.85, 0, 0, 45)
    b.Position = pos
    b.BackgroundColor3 = color
    b.Text = text
    b.TextSize = 20
    b.Font = Enum.Font.MontserratBold
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(cb)
end

local function EnterKeyAction()
    local s, m = VerifyKeyWithServer(HubUI.KeyInput.Text)
    if s then HubUI:StartMain() else print(m) end
end

LoginBtn("GET HWID", UDim2.new(0.075, 0, 0.45, 0), Color3.fromRGB(45, 45, 55), function() setclipboard(tostring(game:GetService("RbxAnalyticsService"):GetClientId())) end)
LoginBtn("GET KEY (DISCORD)", UDim2.new(0.075, 0, 0.6, 0), Color3.fromRGB(88, 101, 242), function() setclipboard(DiscordLink) end)
LoginBtn("ENTER KEY", UDim2.new(0.075, 0, 0.75, 0), Color3.fromRGB(138, 43, 226), EnterKeyAction)

-- Наполнение вкладок
AddInput(TabG, "SPEED", "16", function(t) Config.Gameplay.WalkSpeed = tonumber(t) or 16 end)
AddToggle(TabG, "ENABLE SPEED", function(s) Config.Gameplay.SpeedEnabled = s end)
AddInput(TabG, "JUMP", "25.5", function(t) Config.Gameplay.JumpPower = tonumber(t) or 25.5 end)
AddToggle(TabG, "ENABLE JUMP", function(s) Config.Gameplay.JumpEnabled = s end)
AddInput(TabG, "TILT POWER", "4000", function(t) Config.Gameplay.TiltPower = tonumber(t) or 4000 end)
AddToggle(TabG, "ENABLE TILTS", function(s) Config.Gameplay.TiltEnabled = s end)

AddCycle(TabM, "PHYSICS", Config.Misc.PhysicsList, Config.Misc.CurrentPhysics, function(i) Config.Misc.CurrentPhysics = i end)
AddCycle(TabM, "TECHNICAL", Config.Misc.TechList, Config.Misc.CurrentTech, function(i) Config.Misc.CurrentTech = i end)
AddToggle(TabM, "SPOOF ATTRIBUTES", function(s) Config.Misc.AttrEnabled = s end)

AddToggle(TabV, "FULLBRIGHT", function(s) 
    Config.Visuals.FullBright = s 
    if not s then Lighting.Ambient = OriginalLighting.Ambient Lighting.GlobalShadows = OriginalLighting.GlobalShadows end
end)

-----------------------------------------
-- [ ФИЗИКА - ОРИГИНАЛЬНАЯ ЛОГИКА ]
-----------------------------------------
local function SetupHumanoid(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if Config.Gameplay.SpeedEnabled and humanoid.WalkSpeed ~= Config.Gameplay.WalkSpeed then humanoid.WalkSpeed = Config.Gameplay.WalkSpeed end
    end)
    humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if Config.Gameplay.JumpEnabled and humanoid.JumpPower ~= 0 and humanoid.JumpPower ~= Config.Gameplay.JumpPower then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = Config.Gameplay.JumpPower
        end
    end)
end

if player.Character then SetupHumanoid(player.Character) end
player.CharacterAdded:Connect(SetupHumanoid)

RunService.Heartbeat:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local hum = player.Character.Humanoid
        if Config.Gameplay.SpeedEnabled and hum.WalkSpeed ~= Config.Gameplay.WalkSpeed then hum.WalkSpeed = Config.Gameplay.WalkSpeed end
        if Config.Gameplay.JumpEnabled and hum.JumpPower ~= 0 and hum.JumpPower ~= Config.Gameplay.JumpPower then hum.UseJumpPower = true hum.JumpPower = Config.Gameplay.JumpPower end
    end
    if Config.Gameplay.TiltEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local tilt = player.Character.HumanoidRootPart:FindFirstChild("Tilt")
        if tilt then pcall(function() tilt.P = Config.Gameplay.TiltPower end) end
    end
    if Config.Misc.AttrEnabled then
        local data = player:FindFirstChild("Data")
        if data then
            data:SetAttribute("Technical", Config.Misc.TechList[Config.Misc.CurrentTech])
            data:SetAttribute("Physical", Config.Misc.PhysicsList[Config.Misc.CurrentPhysics])
        end
    end
    if Config.Visuals.CustomTime then Lighting.ClockTime = Config.Visuals.TimeOfDay end
    if Config.Visuals.FullBright then Lighting.Ambient = Color3.fromRGB(255, 255, 255) Lighting.GlobalShadows = false end
end)

-- Toggle
UserInputService.InputBegan:Connect(function(input, g)
    if not g and input.KeyCode == Config.Settings.ToggleKey then
        Config.Settings.UIOpen = not Config.Settings.UIOpen
        HubUI.MainFrame.Visible = Config.Settings.UIOpen
        TweenService:Create(HubUI.Blur, TweenInfo.new(0.3), {Size = Config.Settings.UIOpen and 15 or 0}):Play()
    end
end)

-- Start Injection
task.spawn(function() HubUI:Inject() end)
