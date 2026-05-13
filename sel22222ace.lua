-- [[ SELACE HUB PREMIER EDITION ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local DiscordLink = "https://discord.gg/9eYR7ecMu"

-----------------------------------------
-- CONFIG & STATE
-----------------------------------------
local Config = {
    Gameplay = { WalkSpeed = 16, SpeedEnabled = false, JumpPower = 25.5, JumpEnabled = false, TiltPower = 4000, TiltEnabled = false },
    Misc = { PhysicsList = {"Bounce", "Athletic", "Wide Reach", "Sprinter", "Solid form", "All Rounder"}, TechList = {"Backrow Blitz", "Mind Reader", "Unbreakable", "Wiper", "Stance", "Fast Approach"}, CurrentPhysics = 1, CurrentTech = 1, AttrEnabled = false },
    Visuals = { TimeOfDay = 14, CustomTime = false, FullBright = false },
    Settings = { ToggleKey = Enum.KeyCode.RightShift, UIOpen = false, KeyExpiration = "Checking..." }
}

local OriginalLighting = { Ambient = Lighting.Ambient, GlobalShadows = Lighting.GlobalShadows, ClockTime = Lighting.ClockTime }

-----------------------------------------
-- SECURITY LOGIC (TIMED KEYS)
-----------------------------------------
local function VerifyKeyWithServer(key)
    local my_hwid = gethwid and gethwid() or game:GetService("RbxAnalyticsService"):GetClientId()
    local database_url = "https://pastebin.com/raw/2aVHcEnn" -- ТВОЯ ССЫЛКА
    
    local success, database_text = pcall(function() return game:HttpGet(database_url) end)
    if not success then return false, "Connection Error!" end

    local currentTime = os.time()

    for line in string.gmatch(database_text, "[^\r\n]+") do
        local split = string.split(line, ":")
        if #split >= 3 then
            local db_key, db_hwid, db_expiry = split[1], split[2], tonumber(split[3])

            if key == db_key then
                -- Проверка HWID
                if db_hwid ~= "NONE" and my_hwid ~= db_hwid then
                    return false, "HWID Mismatch!"
                end
                
                -- Проверка времени (0 = Lifetime)
                if db_expiry ~= 0 then
                    if currentTime > db_expiry then
                        return false, "Key Expired!"
                    else
                        local daysLeft = math.floor((db_expiry - currentTime) / 86400)
                        Config.Settings.KeyExpiration = daysLeft .. " days left"
                    end
                else
                    Config.Settings.KeyExpiration = "Lifetime"
                end
                
                return true, "Success!"
            end
        end
    end
    return false, "Invalid Key!"
end

-----------------------------------------
-- UI ENGINE (REMASTERED)
-----------------------------------------
local UI = {}
UI.__index = UI

function UI.new()
    local self = setmetatable({}, UI)
    self.Tabs = {}

    self.ScreenGui = Instance.new("ScreenGui", CoreGui)
    self.ScreenGui.Name = "SelacePremium"

    -- Blur Effect
    self.Blur = Instance.new("BlurEffect", Lighting)
    self.Blur.Size = 0

    -- Main Frame (Glass Style)
    self.MainFrame = Instance.new("CanvasGroup", self.ScreenGui)
    self.MainFrame.Size = UDim2.new(0, 460, 0, 520)
    self.MainFrame.Position = UDim2.new(0.5, -230, 0.5, -260)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    self.MainFrame.GroupTransparency = 1
    self.MainFrame.Visible = false
    Instance.new("UICorner", self.MainFrame).CornerRadius = UDim.new(0, 12)
    
    local Stroke = Instance.new("UIStroke", self.MainFrame)
    Stroke.Color = Color3.fromRGB(138, 43, 226)
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.5

    -- Header
    local Header = Instance.new("Frame", self.MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 60)
    Header.BackgroundTransparency = 1
    
    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.Text = "SELACE <font color='#8A2BE2'>HUB</font> PREMIER"
    Title.RichText = true
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.MontserratBold
    Title.TextSize = 22
    Title.TextXAlignment = Enum.TextXAlignment.Left

    self.TabContainer = Instance.new("Frame", self.MainFrame)
    self.TabContainer.Size = UDim2.new(0, 120, 1, -80)
    self.TabContainer.Position = UDim2.new(0, 15, 0, 70)
    self.TabContainer.BackgroundTransparency = 1
    
    local TabList = Instance.new("UIListLayout", self.TabContainer)
    TabList.Padding = UDim.new(0, 8)

    self.PageContainer = Instance.new("Frame", self.MainFrame)
    self.PageContainer.Size = UDim2.new(1, -160, 1, -80)
    self.PageContainer.Position = UDim2.new(0, 145, 0, 70)
    self.PageContainer.BackgroundTransparency = 1

    -- Key Screen (упрощенная версия для примера)
    self.KeyFrame = Instance.new("CanvasGroup", self.ScreenGui)
    self.KeyFrame.Size = UDim2.new(0, 320, 0, 200)
    self.KeyFrame.Position = UDim2.new(0.5, -160, 0.5, -100)
    self.KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    Instance.new("UICorner", self.KeyFrame).CornerRadius = UDim.new(0, 12)
    
    self.KeyInput = Instance.new("TextBox", self.KeyFrame)
    self.KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
    self.KeyInput.Position = UDim2.new(0.1, 0, 0.3, 0)
    self.KeyInput.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    self.KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.KeyInput.PlaceholderText = "Enter Key..."
    Instance.new("UICorner", self.KeyInput)

    self.VerifyBtn = Instance.new("TextButton", self.KeyFrame)
    self.VerifyBtn.Size = UDim2.new(0.8, 0, 0, 40)
    self.VerifyBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
    self.VerifyBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    self.VerifyBtn.Text = "Login"
    self.VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", self.VerifyBtn)

    self.VerifyBtn.MouseButton1Click:Connect(function()
        local success, err = VerifyKeyWithServer(self.KeyInput.Text)
        if success then
            self:TransitionToMain()
        else
            self.VerifyBtn.Text = err
            task.wait(1)
            self.VerifyBtn.Text = "Login"
        end
    end)

    return self
end

function UI:TransitionToMain()
    TweenService:Create(self.KeyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {GroupTransparency = 1}):Play()
    task.wait(0.5)
    self.KeyFrame.Visible = false
    self.MainFrame.Visible = true
    TweenService:Create(self.MainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
    TweenService:Create(self.Blur, TweenInfo.new(0.8), {Size = 15}):Play()
    Config.Settings.UIOpen = true
end

function UI:CreateTab(name)
    local TabBtn = Instance.new("TextButton", self.TabContainer)
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtn.Font = Enum.Font.MontserratSemiBold
    TabBtn.TextSize = 14
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    local Page = Instance.new("ScrollingFrame", self.PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 0
    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0, 10)

    TabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Tabs) do
            v.Page.Visible = false
            TweenService:Create(v.Btn, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundColor3 = Color3.fromRGB(20, 20, 25)}):Play()
        end
        Page.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = Color3.fromRGB(138, 43, 226)}):Play()
    end)

    table.insert(self.Tabs, {Btn = TabBtn, Page = Page})
    if #self.Tabs == 1 then
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    end
    return Page
end

-- Вспомогательные функции для UI элементов
local function AddToggle(parent, text, callback)
    local Frame = Instance.new("TextButton", parent)
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Frame.Text = "  " .. text
    Frame.TextColor3 = Color3.fromRGB(200, 200, 200)
    Frame.TextXAlignment = Enum.TextXAlignment.Left
    Frame.Font = Enum.Font.Montserrat
    Instance.new("UICorner", Frame)
    
    local Indicator = Instance.new("Frame", Frame)
    Indicator.Size = UDim2.new(0, 10, 0, 10)
    Indicator.Position = UDim2.new(1, -25, 0.5, -5)
    Indicator.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
    
    local active = false
    Frame.MouseButton1Click:Connect(function()
        active = not active
        callback(active)
        TweenService:Create(Indicator, TweenInfo.new(0.3), {BackgroundColor3 = active and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)}):Play()
    end)
end

-----------------------------------------
-- INITIALIZATION
-----------------------------------------
local MainUI = UI.new()

-- Табы
local GameplayPage = MainUI:CreateTab("Gameplay")
local VisualsPage = MainUI:CreateTab("Visuals")
local SettingsPage = MainUI:CreateTab("Settings")

AddToggle(GameplayPage, "Speed Hack", function(s) Config.Gameplay.SpeedEnabled = s end)
AddToggle(GameplayPage, "Infinite Jump", function(s) Config.Gameplay.JumpEnabled = s end)
AddToggle(VisualsPage, "Fullbright", function(s) 
    Config.Visuals.FullBright = s 
    if not s then
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
    end
end)

-- Информация о подписке в настройках
local Info = Instance.new("TextLabel", SettingsPage)
Info.Size = UDim2.new(1, 0, 0, 30)
Info.BackgroundTransparency = 1
Info.TextColor3 = Color3.fromRGB(138, 43, 226)
Info.Text = "Subscription: " .. Config.Settings.KeyExpiration
Info.Font = Enum.Font.Montserrat

-----------------------------------------
-- LOOPS
-----------------------------------------
RunService.Heartbeat:Connect(function()
    if Config.Gameplay.SpeedEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = Config.Gameplay.WalkSpeed
    end
    
    if Config.Visuals.FullBright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.GlobalShadows = false
    end
end)

-- Toggle Menu
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Config.Settings.ToggleKey then
        Config.Settings.UIOpen = not Config.Settings.UIOpen
        local targetAlpha = Config.Settings.UIOpen and 0 or 1
        local targetBlur = Config.Settings.UIOpen and 15 or 0
        
        TweenService:Create(MainUI.MainFrame, TweenInfo.new(0.5), {GroupTransparency = targetAlpha}):Play()
        TweenService:Create(MainUI.Blur, TweenInfo.new(0.5), {Size = targetBlur}):Play()
        MainUI.MainFrame.Visible = Config.Settings.UIOpen
    end
end)
