-- [[ SELACE HUB: PREMIER ANIME EDITION ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local DiscordLink = "https://discord.gg/9eYR7ecMu"

-----------------------------------------
-- [ ТВОИ НАСТРОЙКИ - НЕ ИЗМЕНЕНО ]
-----------------------------------------
local Config = {
    Gameplay = { JumpPower = 25.5, JumpEnabled = false, WalkSpeed = 16, SpeedEnabled = false, TiltPower = 4000, TiltEnabled = false },
    Misc = { PhysicsList = {"Bounce", "Athletic", "Wide Reach", "Sprinter", "Solid form", "All Rounder"}, TechList = {"Backrow Blitz", "Mind Reader", "Unbreakable", "Wiper", "Stance", "Fast Approach"}, CurrentPhysics = 2, CurrentTech = 6, AttrEnabled = false },
    Visuals = { TimeOfDay = 14, CustomTime = false, FullBright = false },
    Settings = { ToggleKey = Enum.KeyCode.RightShift, UIOpen = true }
}

local OriginalLighting = { Ambient = Lighting.Ambient, GlobalShadows = Lighting.GlobalShadows, ClockTime = Lighting.ClockTime }

-----------------------------------------
-- [ НОВАЯ СИСТЕМА КЛЮЧЕЙ ]
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
                return true, "Welcome!"
            end
        end
    end
    return false, "Invalid Key!"
end

-----------------------------------------
-- [ НОВЫЙ UI С БОЛЬШИМИ ШРИФТАМИ ]
-----------------------------------------
local UI = {}
UI.__index = UI

function UI.new()
    local self = setmetatable({}, UI)
    self.Tabs = {}

    self.ScreenGui = Instance.new("ScreenGui", CoreGui)
    self.ScreenGui.Name = "SelaceUltimate"

    -- Blur Background
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Size = 0
    self.Blur = blur

    -- 1. LOGIN FRAME
    self.LoginFrame = Instance.new("CanvasGroup", self.ScreenGui)
    self.LoginFrame.Size = UDim2.new(0, 480, 0, 360)
    self.LoginFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
    self.LoginFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    Instance.new("UICorner", self.LoginFrame).CornerRadius = UDim.new(0, 15)
    
    local LoginStroke = Instance.new("UIStroke", self.LoginFrame)
    LoginStroke.Thickness = 3
    LoginStroke.Color = Color3.fromRGB(138, 43, 226)

    -- Anime Background
    local Bg = Instance.new("ImageLabel", self.LoginFrame)
    Bg.Size = UDim2.new(1, 0, 1, 0)
    Bg.Image = "rbxassetid://12502692237"
    Bg.ImageTransparency = 0.55
    Bg.ScaleType = Enum.ScaleType.Crop
    Bg.BackgroundTransparency = 1

    local LoginTitle = Instance.new("TextLabel", self.LoginFrame)
    LoginTitle.Size = UDim2.new(1, 0, 0, 80)
    LoginTitle.Text = "SELACE HUB"
    LoginTitle.Font = Enum.Font.GothamBold
    LoginTitle.TextSize = 34
    LoginTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoginTitle.BackgroundTransparency = 1

    self.KeyInput = Instance.new("TextBox", self.LoginFrame)
    self.KeyInput.Size = UDim2.new(0.85, 0, 0, 50)
    self.KeyInput.Position = UDim2.new(0.075, 0, 0.25, 0)
    self.KeyInput.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    self.KeyInput.PlaceholderText = "ENTER KEY..."
    self.KeyInput.TextSize = 20
    self.KeyInput.Font = Enum.Font.MontserratBold
    self.KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", self.KeyInput)

    local function CreateBtn(text, pos, color, callback)
        local btn = Instance.new("TextButton", self.LoginFrame)
        btn.Size = UDim2.new(0.85, 0, 0, 45)
        btn.Position = pos
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextSize = 20
        btn.Font = Enum.Font.MontserratBold
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", btn)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    self.HBtn = CreateBtn("GET HWID", UDim2.new(0.075, 0, 0.45, 0), Color3.fromRGB(45, 45, 55), function()
        setclipboard(tostring(game:GetService("RbxAnalyticsService"):GetClientId()))
        self.HBtn.Text = "COPIED!"
        task.wait(2) self.HBtn.Text = "GET HWID"
    end)

    self.KBtn = CreateBtn("GET KEY (DISCORD)", UDim2.new(0.075, 0, 0.6, 0), Color3.fromRGB(88, 101, 242), function()
        setclipboard(DiscordLink)
        self.KBtn.Text = "LINK COPIED!"
        task.wait(2) self.KBtn.Text = "GET KEY (DISCORD)"
    end)

    self.EBtn = CreateBtn("ENTER KEY", UDim2.new(0.075, 0, 0.75, 0), Color3.fromRGB(138, 43, 226), function()
        local success, msg = VerifyKeyWithServer(self.KeyInput.Text)
        if success then self:StartMain() else self.EBtn.Text = msg task.wait(2) self.EBtn.Text = "ENTER KEY" end
    end)

    -- 2. MAIN FRAME
    self.MainFrame = Instance.new("CanvasGroup", self.ScreenGui)
    self.MainFrame.Size = UDim2.new(0, 580, 0, 450)
    self.MainFrame.Position = UDim2.new(0.5, -290, 0.5, -225)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 17)
    self.MainFrame.Visible = false
    self.MainFrame.GroupTransparency = 1
    Instance.new("UICorner", self.MainFrame).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", self.MainFrame).Color = Color3.fromRGB(138, 43, 226)

    self.Sidebar = Instance.new("Frame", self.MainFrame)
    self.Sidebar.Size = UDim2.new(0, 160, 1, 0)
    self.Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
    
    self.TabHolder = Instance.new("Frame", self.Sidebar)
    self.TabHolder.Size = UDim2.new(1, -20, 1, -80)
    self.TabHolder.Position = UDim2.new(0, 10, 0, 70)
    self.TabHolder.BackgroundTransparency = 1
    Instance.new("UIListLayout", self.TabHolder).Padding = UDim.new(0, 12)

    self.Container = Instance.new("Frame", self.MainFrame)
    self.Container.Size = UDim2.new(1, -190, 1, -20)
    self.Container.Position = UDim2.new(0, 180, 0, 10)
    self.Container.BackgroundTransparency = 1

    return self
end

function UI:StartMain()
    TweenService:Create(self.LoginFrame, TweenInfo.new(0.5), {GroupTransparency = 1}):Play()
    task.wait(0.5)
    self.LoginFrame.Visible = false
    self.MainFrame.Visible = true
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
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 15)

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do t.Page.Visible = false t.Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35) end
        page.Visible = true btn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    end)

    table.insert(self.Tabs, {Btn = btn, Page = page})
    if #self.Tabs == 1 then page.Visible = true btn.BackgroundColor3 = Color3.fromRGB(138, 43, 226) end
    return page
end

-- Вспомогательные элементы (БОЛЬШИЕ)
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
-- [ ПОСТРОЕНИЕ МЕНЮ ]
-----------------------------------------
local HubUI = UI.new()
local TabG = HubUI:CreateTab("Gameplay")
local TabM = HubUI:CreateTab("Misc")
local TabV = HubUI:CreateTab("Visuals")

-- Вкладка Геймплей
AddInput(TabG, "WALK SPEED", tostring(Config.Gameplay.WalkSpeed), function(t) Config.Gameplay.WalkSpeed = tonumber(t) or 16 end)
AddToggle(TabG, "ENABLE SPEED", function(s) Config.Gameplay.SpeedEnabled = s end)
AddInput(TabG, "JUMP POWER", tostring(Config.Gameplay.JumpPower), function(t) Config.Gameplay.JumpPower = tonumber(t) or 25.5 end)
AddToggle(TabG, "ENABLE JUMP", function(s) Config.Gameplay.JumpEnabled = s end)
AddInput(TabG, "TILT POWER", tostring(Config.Gameplay.TiltPower), function(t) Config.Gameplay.TiltPower = tonumber(t) or 4000 end)
AddToggle(TabG, "ENABLE TILTS", function(s) Config.Gameplay.TiltEnabled = s end)

-- Вкладка Разное
AddCycle(TabM, "PHYSICS", Config.Misc.PhysicsList, Config.Misc.CurrentPhysics, function(i) Config.Misc.CurrentPhysics = i end)
AddCycle(TabM, "TECHNICAL", Config.Misc.TechList, Config.Misc.CurrentTech, function(i) Config.Misc.CurrentTech = i end)
AddToggle(TabM, "SPOOF ATTRIBUTES", function(s) Config.Misc.AttrEnabled = s end)

-- Вкладка Визуалы
AddToggle(TabV, "FULLBRIGHT", function(s) 
    Config.Visuals.FullBright = s 
    if not s then Lighting.Ambient = OriginalLighting.Ambient Lighting.GlobalShadows = OriginalLighting.GlobalShadows end
end)
AddInput(TabV, "TIME (0-24)", tostring(Config.Visuals.TimeOfDay), function(t) Config.Visuals.TimeOfDay = tonumber(t) or 14 end)
AddToggle(TabV, "CUSTOM TIME", function(s) 
    Config.Visuals.CustomTime = s if not s then Lighting.ClockTime = OriginalLighting.ClockTime end
end)

-----------------------------------------
-- [ ФИЗИКА - АБСОЛЮТНО БЕЗ ИЗМЕНЕНИЙ ]
-----------------------------------------
local function SetupHumanoid(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if Config.Gameplay.SpeedEnabled and humanoid.WalkSpeed ~= Config.Gameplay.WalkSpeed then
            humanoid.WalkSpeed = Config.Gameplay.WalkSpeed
        end
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
        if Config.Gameplay.JumpEnabled and hum.JumpPower ~= 0 and hum.JumpPower ~= Config.Gameplay.JumpPower then
            hum.UseJumpPower = true
            hum.JumpPower = Config.Gameplay.JumpPower
        end
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
    if Config.Visuals.FullBright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.GlobalShadows = false
    end
end)

-- Toggle Menu
UserInputService.InputBegan:Connect(function(input, g)
    if not g and input.KeyCode == Config.Settings.ToggleKey then
        Config.Settings.UIOpen = not Config.Settings.UIOpen
        HubUI.MainFrame.Visible = Config.Settings.UIOpen
        HubUI.Blur.Size = Config.Settings.UIOpen and 15 or 0
    end
end)

-- Анимация плавного парения окна логина
task.spawn(function()
    while task.wait() do
        if HubUI.LoginFrame.Visible then
            local y = math.sin(tick() * 2) * 8
            HubUI.LoginFrame.Position = UDim2.new(0.5, -240, 0.5, -180 + y)
        end
    end
end)
