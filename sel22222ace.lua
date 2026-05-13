-- [[ SELACE HUB: ULTIMATE ANIME EDITION ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local DiscordLink = "https://discord.gg/9eYR7ecMu"

-----------------------------------------
-- CONFIGURATION
-----------------------------------------
local Config = {
    Gameplay = { JumpPower = 25.5, JumpEnabled = false, WalkSpeed = 16, SpeedEnabled = false, TiltPower = 4000, TiltEnabled = false },
    Misc = { 
        PhysicsList = {"Bounce", "Athletic", "Wide Reach", "Sprinter", "Solid form", "All Rounder"}, 
        TechList = {"Backrow Blitz", "Mind Reader", "Unbreakable", "Wiper", "Stance", "Fast Approach"}, 
        CurrentPhysics = 1, CurrentTech = 1, AttrEnabled = false 
    },
    Visuals = { TimeOfDay = 14, CustomTime = false, FullBright = false },
    Settings = { ToggleKey = Enum.KeyCode.RightShift, UIOpen = true, Verified = false }
}

local OriginalLighting = { Ambient = Lighting.Ambient, GlobalShadows = Lighting.GlobalShadows, ClockTime = Lighting.ClockTime }

-----------------------------------------
-- CORE UTILS
-----------------------------------------
local function Notify(text, color)
    -- Простая индикация статуса на кнопках
    return text
end

-----------------------------------------
-- UI LIBRARY
-----------------------------------------
local UI = {}
UI.__index = UI

function UI.new()
    local self = setmetatable({}, UI)
    self.Tabs = {}

    self.ScreenGui = Instance.new("ScreenGui", CoreGui)
    self.ScreenGui.Name = "SelaceUltimate"

    -- 1. LOGIN FRAME (Окно авторизации)
    self.LoginFrame = Instance.new("CanvasGroup", self.ScreenGui)
    self.LoginFrame.Size = UDim2.new(0, 450, 0, 350)
    self.LoginFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
    self.LoginFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    Instance.new("UICorner", self.LoginFrame).CornerRadius = UDim.new(0, 15)
    
    local LoginStroke = Instance.new("UIStroke", self.LoginFrame)
    LoginStroke.Thickness = 2.5
    LoginStroke.Color = Color3.fromRGB(138, 43, 226)

    -- Anime Background for Login
    local Bg = Instance.new("ImageLabel", self.LoginFrame)
    Bg.Size = UDim2.new(1, 0, 1, 0)
    Bg.Image = "rbxassetid://12502692237" -- Аниме тянка
    Bg.ImageTransparency = 0.6
    Bg.ScaleType = Enum.ScaleType.Crop
    Bg.BackgroundTransparency = 1

    local LoginTitle = Instance.new("TextLabel", self.LoginFrame)
    LoginTitle.Size = UDim2.new(1, 0, 0, 70)
    LoginTitle.Text = "SELACE HUB"
    LoginTitle.Font = Enum.Font.GothamBold
    LoginTitle.TextSize = 32
    LoginTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoginTitle.BackgroundTransparency = 1

    self.KeyInput = Instance.new("TextBox", self.LoginFrame)
    self.KeyInput.Size = UDim2.new(0.8, 0, 0, 45)
    self.KeyInput.Position = UDim2.new(0.1, 0, 0.25, 0)
    self.KeyInput.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    self.KeyInput.PlaceholderText = "ENTER KEY HERE..."
    self.KeyInput.TextSize = 18
    self.KeyInput.Font = Enum.Font.MontserratBold
    self.KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", self.KeyInput)

    local function CreateLoginBtn(text, pos, color, callback)
        local btn = Instance.new("TextButton", self.LoginFrame)
        btn.Size = UDim2.new(0.8, 0, 0, 40)
        btn.Position = pos
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextSize = 18
        btn.Font = Enum.Font.MontserratBold
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", btn)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    self.BtnHwid = CreateLoginBtn("GET HWID", UDim2.new(0.1, 0, 0.45, 0), Color3.fromRGB(45, 45, 55), function()
        setclipboard(tostring(game:GetService("RbxAnalyticsService"):GetClientId()))
        self.BtnHwid.Text = "COPIED!"
        task.wait(2)
        self.BtnHwid.Text = "GET HWID"
    end)

    self.BtnGetKey = CreateLoginBtn("GET KEY (DISCORD)", UDim2.new(0.1, 0, 0.6, 0), Color3.fromRGB(88, 101, 242), function()
        setclipboard(DiscordLink)
        self.BtnGetKey.Text = "LINK COPIED!"
        task.wait(2)
        self.BtnGetKey.Text = "GET KEY (DISCORD)"
    end)

    self.BtnEnter = CreateLoginBtn("ENTER KEY", UDim2.new(0.1, 0, 0.75, 0), Color3.fromRGB(138, 43, 226), function()
        self:StartMain()
    end)

    -- 2. MAIN FRAME (Основное меню)
    self.MainFrame = Instance.new("CanvasGroup", self.ScreenGui)
    self.MainFrame.Size = UDim2.new(0, 550, 0, 400)
    self.MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 17)
    self.MainFrame.Visible = false
    self.MainFrame.GroupTransparency = 1
    Instance.new("UICorner", self.MainFrame).CornerRadius = UDim.new(0, 12)
    
    local MainStroke = Instance.new("UIStroke", self.MainFrame)
    MainStroke.Thickness = 2
    MainStroke.Color = Color3.fromRGB(138, 43, 226)

    -- Sidebar & Container
    self.Sidebar = Instance.new("Frame", self.MainFrame)
    self.Sidebar.Size = UDim2.new(0, 150, 1, 0)
    self.Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
    
    self.TabHolder = Instance.new("Frame", self.Sidebar)
    self.TabHolder.Size = UDim2.new(1, -20, 1, -100)
    self.TabHolder.Position = UDim2.new(0, 10, 0, 80)
    self.TabHolder.BackgroundTransparency = 1
    Instance.new("UIListLayout", self.TabHolder).Padding = UDim.new(0, 10)

    local MainTitle = Instance.new("TextLabel", self.Sidebar)
    MainTitle.Size = UDim2.new(1, 0, 0, 60)
    MainTitle.Text = "SELACE"
    MainTitle.TextSize = 24
    MainTitle.Font = Enum.Font.GothamBold
    MainTitle.TextColor3 = Color3.fromRGB(138, 43, 226)
    MainTitle.BackgroundTransparency = 1

    self.Container = Instance.new("Frame", self.MainFrame)
    self.Container.Size = UDim2.new(1, -170, 1, -20)
    self.Container.Position = UDim2.new(0, 160, 0, 10)
    self.Container.BackgroundTransparency = 1

    return self
end

function UI:StartMain()
    TweenService:Create(self.LoginFrame, TweenInfo.new(0.5), {GroupTransparency = 1}):Play()
    task.wait(0.5)
    self.LoginFrame.Visible = false
    self.MainFrame.Visible = true
    TweenService:Create(self.MainFrame, TweenInfo.new(0.5), {GroupTransparency = 0}):Play()
end

function UI:CreateTab(name)
    local btn = Instance.new("TextButton", self.TabHolder)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.Text = name
    btn.TextSize = 16
    btn.Font = Enum.Font.MontserratBold
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Instance.new("UICorner", btn)

    local page = Instance.new("ScrollingFrame", self.Container)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 2
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 12)

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Page.Visible = false
            t.Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    end)

    table.insert(self.Tabs, {Btn = btn, Page = page})
    if #self.Tabs == 1 then page.Visible = true btn.BackgroundColor3 = Color3.fromRGB(138, 43, 226) end
    return page
end

-- ЭЛЕМЕНТЫ УПРАВЛЕНИЯ
local function AddToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    btn.Text = "  " .. text .. ": OFF"
    btn.TextSize = 16
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
    local label = Instance.new("TextLabel", parent)
    label.Size = UDim2.new(0.95, 0, 0, 20)
    label.Text = "  " .. text
    label.TextSize = 14
    label.Font = Enum.Font.MontserratBold
    label.TextColor3 = Color3.fromRGB(150, 150, 150)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left

    local input = Instance.new("TextBox", parent)
    input.Size = UDim2.new(0.95, 0, 0, 40)
    input.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    input.Text = default
    input.TextSize = 16
    input.Font = Enum.Font.MontserratBold
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", input)
    input.FocusLost:Connect(function() callback(input.Text) end)
end

local function AddDropdown(parent, text, list, current, callback)
    local idx = current
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Text = "  " .. text .. ": " .. list[idx]
    btn.TextSize = 16
    btn.Font = Enum.Font.MontserratBold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        idx = idx + 1
        if idx > #list then idx = 1 end
        btn.Text = "  " .. text .. ": " .. list[idx]
        callback(idx)
    end)
end

-----------------------------------------
-- BUILDING CONTENT
-----------------------------------------
local Hub = UI.new()
local MainTab = Hub:CreateTab("Gameplay")
local MiscTab = Hub:CreateTab("Misc")
local VisualTab = Hub:CreateTab("Visuals")

-- GAMEPLAY
AddInput(MainTab, "WALK SPEED", "16", function(t) Config.Gameplay.WalkSpeed = tonumber(t) or 16 end)
AddToggle(MainTab, "ENABLE SPEED", function(s) Config.Gameplay.SpeedEnabled = s end)
AddInput(MainTab, "JUMP POWER", "25.5", function(t) Config.Gameplay.JumpPower = tonumber(t) or 25.5 end)
AddToggle(MainTab, "ENABLE JUMP", function(s) Config.Gameplay.JumpEnabled = s end)
AddInput(MainTab, "TILT POWER", "4000", function(t) Config.Gameplay.TiltPower = tonumber(t) or 4000 end)
AddToggle(MainTab, "ENABLE TILTS", function(s) Config.Gameplay.TiltEnabled = s end)

-- MISC
AddDropdown(MiscTab, "PHYSICS", Config.Misc.PhysicsList, Config.Misc.CurrentPhysics, function(i) Config.Misc.CurrentPhysics = i end)
AddDropdown(MiscTab, "TECHNICAL", Config.Misc.TechList, Config.Misc.CurrentTech, function(i) Config.Misc.CurrentTech = i end)
AddToggle(MiscTab, "SPOOF ATTRIBUTES", function(s) Config.Misc.AttrEnabled = s end)

-- VISUALS
AddToggle(VisualTab, "FULLBRIGHT", function(s) 
    Config.Visuals.FullBright = s 
    if not s then Lighting.Ambient = OriginalLighting.Ambient Lighting.GlobalShadows = OriginalLighting.GlobalShadows end
end)
AddInput(VisualTab, "TIME OF DAY (0-24)", "14", function(t) Config.Visuals.TimeOfDay = tonumber(t) or 14 end)
AddToggle(VisualTab, "CUSTOM TIME", function(s) 
    Config.Visuals.CustomTime = s 
    if not s then Lighting.ClockTime = OriginalLighting.ClockTime end
end)

-----------------------------------------
-- MAIN LOOPS
-----------------------------------------
RunService.Heartbeat:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        if Config.Gameplay.SpeedEnabled then hum.WalkSpeed = Config.Gameplay.WalkSpeed end
        if Config.Gameplay.JumpEnabled then hum.UseJumpPower = true hum.JumpPower = Config.Gameplay.JumpPower end
    end

    if Config.Gameplay.TiltEnabled and char and char:FindFirstChild("HumanoidRootPart") then
        local tilt = char.HumanoidRootPart:FindFirstChild("Tilt")
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

-- Toggle Key
UserInputService.InputBegan:Connect(function(input, g)
    if not g and input.KeyCode == Config.Settings.ToggleKey then
        Config.Settings.UIOpen = not Config.Settings.UIOpen
        Hub.MainFrame.Visible = Config.Settings.UIOpen
    end
end)

-- Floating Animation for Login
task.spawn(function()
    while task.wait() do
        if Hub.LoginFrame.Visible then
            local y = math.sin(tick() * 2) * 8
            Hub.LoginFrame.Position = UDim2.new(0.5, -225, 0.5, -175 + y)
        end
    end
end)
