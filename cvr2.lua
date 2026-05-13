local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local DiscordLink = "https://discord.gg/9eYR7ecMu"

-----------------------------------------
-- SETTINGS & VARIABLES
-----------------------------------------
local Config = {
    Gameplay = { JumpPower = 25.5, JumpEnabled = false, WalkSpeed = 16, SpeedEnabled = false, TiltPower = 4000, TiltEnabled = false },
    Misc = { PhysicsList = {"Bounce", "Athletic", "Wide Reach", "Sprinter", "Solid form", "All Rounder"}, TechList = {"Backrow Blitz", "Mind Reader", "Unbreakable", "Wiper", "Stance", "Fast Approach"}, CurrentPhysics = 2, CurrentTech = 6, AttrEnabled = false },
    Visuals = { TimeOfDay = 14, CustomTime = false, FullBright = false },
    Settings = { ToggleKey = Enum.KeyCode.RightShift, UIOpen = false }
}

local OriginalLighting = { Ambient = Lighting.Ambient, GlobalShadows = Lighting.GlobalShadows, ClockTime = Lighting.ClockTime }

-----------------------------------------
-- KEY & HWID VERIFICATION
-----------------------------------------
local function VerifyKeyWithServer(key)
    local my_hwid = "UNKNOWN"
    if gethwid then
        pcall(function() my_hwid = gethwid() end)
    else
        pcall(function() my_hwid = game:GetService("RbxAnalyticsService"):GetClientId() end)
    end

    -- Link to your RAW Pastebin
    local database_url = "https://pastebin.com/raw/2aVHcEnn" 
    
    local success, database_text = pcall(function()
        return game:HttpGet(database_url)
    end)

    if not success then
        return false, "Error checking DB! Check your internet connection."
    end

    for line in string.gmatch(database_text, "[^\r\n]+") do
        local split = string.split(line, ":")
        if #split >= 2 then
            local db_key = split[1]
            local db_hwid = split[2]

            if key == db_key then
                if my_hwid == db_hwid then
                    return true, "Authentication Successful!"
                else
                    return false, "Key is locked to another HWID!"
                end
            end
        end
    end

    return false, "Invalid Key!"
end

-----------------------------------------
-- PREMIUM UI LIBRARY
-----------------------------------------
local UI = {}
UI.__index = UI

function UI.new()
    local self = setmetatable({}, UI)
    self.Tabs = {}

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SelaceHubPremium"
    self.ScreenGui.ResetOnSpawn = false
    pcall(function() self.ScreenGui.Parent = CoreGui end)
    if not self.ScreenGui.Parent then self.ScreenGui.Parent = player:WaitForChild("PlayerGui") end
    
    -- LOADING SCREEN
    self.LoadingFrame = Instance.new("Frame", self.ScreenGui)
    self.LoadingFrame.Size = UDim2.new(0, 260, 0, 80)
    self.LoadingFrame.Position = UDim2.new(0.5, -130, 0.5, -40)
    self.LoadingFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    self.LoadingFrame.BackgroundTransparency = 1
    Instance.new("UICorner", self.LoadingFrame).CornerRadius = UDim.new(0, 8)
    local LoadStroke = Instance.new("UIStroke", self.LoadingFrame)
    LoadStroke.Color = Color3.fromRGB(138, 43, 226)
    LoadStroke.Transparency = 1
    
    self.LoadingText = Instance.new("TextLabel", self.LoadingFrame)
    self.LoadingText.Size = UDim2.new(1, 0, 1, 0)
    self.LoadingText.BackgroundTransparency = 1
    self.LoadingText.Text = "Injecting Selace Hub..."
    self.LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.LoadingText.Font = Enum.Font.MontserratBold
    self.LoadingText.TextSize = 16
    self.LoadingText.TextTransparency = 1

    -- KEY SYSTEM FRAME
    self.KeyFrame = Instance.new("CanvasGroup", self.ScreenGui)
    self.KeyFrame.Size = UDim2.new(0, 360, 0, 240)
    self.KeyFrame.Position = UDim2.new(0.5, -180, 0.5, -120)
    self.KeyFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    self.KeyFrame.BorderSizePixel = 0
    self.KeyFrame.GroupTransparency = 1
    self.KeyFrame.Visible = false
    Instance.new("UICorner", self.KeyFrame).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", self.KeyFrame).Color = Color3.fromRGB(40, 40, 50)
    
    local KeyTitle = Instance.new("TextLabel", self.KeyFrame)
    KeyTitle.Size = UDim2.new(1, 0, 0, 50)
    KeyTitle.BackgroundTransparency = 1
    KeyTitle.Text = "AUTHENTICATION"
    KeyTitle.TextColor3 = Color3.fromRGB(138, 43, 226)
    KeyTitle.Font = Enum.Font.MontserratBold
    KeyTitle.TextSize = 18

    self.KeyInput = Instance.new("TextBox", self.KeyFrame)
    self.KeyInput.Size = UDim2.new(0.9, 0, 0, 40)
    self.KeyInput.Position = UDim2.new(0.05, 0, 0, 55)
    self.KeyInput.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    self.KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.KeyInput.PlaceholderText = "Enter your premium key..."
    self.KeyInput.Text = ""
    self.KeyInput.Font = Enum.Font.Montserrat
    self.KeyInput.TextSize = 14
    Instance.new("UICorner", self.KeyInput).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", self.KeyInput).Color = Color3.fromRGB(50, 50, 65)

    self.HwidBtn = Instance.new("TextButton", self.KeyFrame)
    self.HwidBtn.Size = UDim2.new(0.43, 0, 0, 35)
    self.HwidBtn.Position = UDim2.new(0.05, 0, 0, 105)
    self.HwidBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    self.HwidBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.HwidBtn.Text = "Copy HWID"
    self.HwidBtn.Font = Enum.Font.MontserratBold
    self.HwidBtn.TextSize = 13
    Instance.new("UICorner", self.HwidBtn).CornerRadius = UDim.new(0, 6)

    self.DiscordBtn = Instance.new("TextButton", self.KeyFrame)
    self.DiscordBtn.Size = UDim2.new(0.43, 0, 0, 35)
    self.DiscordBtn.Position = UDim2.new(0.52, 0, 0, 105)
    self.DiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    self.DiscordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.DiscordBtn.Text = "Get Key"
    self.DiscordBtn.Font = Enum.Font.MontserratBold
    self.DiscordBtn.TextSize = 13
    Instance.new("UICorner", self.DiscordBtn).CornerRadius = UDim.new(0, 6)

    self.VerifyBtn = Instance.new("TextButton", self.KeyFrame)
    self.VerifyBtn.Size = UDim2.new(0.9, 0, 0, 40)
    self.VerifyBtn.Position = UDim2.new(0.05, 0, 0, 150)
    self.VerifyBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    self.VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.VerifyBtn.Text = "Verify Key"
    self.VerifyBtn.Font = Enum.Font.MontserratBold
    self.VerifyBtn.TextSize = 14
    Instance.new("UICorner", self.VerifyBtn).CornerRadius = UDim.new(0, 6)

    self.StatusText = Instance.new("TextLabel", self.KeyFrame)
    self.StatusText.Size = UDim2.new(1, 0, 0, 30)
    self.StatusText.Position = UDim2.new(0, 0, 0, 200)
    self.StatusText.BackgroundTransparency = 1
    self.StatusText.Text = "Waiting for key input..."
    self.StatusText.TextColor3 = Color3.fromRGB(120, 120, 130)
    self.StatusText.Font = Enum.Font.Montserrat
    self.StatusText.TextSize = 12

    -- MAIN HUB INTERFACE
    self.MainFrame = Instance.new("CanvasGroup", self.ScreenGui)
    self.MainFrame.Size = UDim2.new(0, 450, 0, 530)
    self.MainFrame.Position = UDim2.new(0.5, -225, 0.5, -265)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.GroupTransparency = 1
    self.MainFrame.Visible = false
    Instance.new("UICorner", self.MainFrame).CornerRadius = UDim.new(0, 10)
    local MainStroke = Instance.new("UIStroke", self.MainFrame)
    MainStroke.Color = Color3.fromRGB(138, 43, 226)
    MainStroke.Thickness = 1.5
    
    -- Draggable Top Bar
    local DragFrame = Instance.new("Frame", self.MainFrame)
    DragFrame.Size = UDim2.new(1, 0, 0, 65)
    DragFrame.BackgroundTransparency = 1
    DragFrame.Active = true
    DragFrame.Draggable = true
    
    local Title = Instance.new("TextLabel", DragFrame)
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.Position = UDim2.new(0, 0, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = "SELACE HUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.MontserratBold
    Title.TextSize = 24
    
    -- Gradient for the Title
    local TitleGradient = Instance.new("UIGradient", Title)
    TitleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 80, 255))
    }

    local SubTitle = Instance.new("TextLabel", DragFrame)
    SubTitle.Size = UDim2.new(1, 0, 0, 15)
    SubTitle.Position = UDim2.new(0, 0, 0, 42)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = "Made by Selace"
    SubTitle.TextColor3 = Color3.fromRGB(140, 140, 160)
    SubTitle.Font = Enum.Font.MontserratSemibold
    SubTitle.TextSize = 12
    
    -- Tab Container
    self.TabContainer = Instance.new("Frame", self.MainFrame)
    self.TabContainer.Size = UDim2.new(1, -30, 0, 40)
    self.TabContainer.Position = UDim2.new(0, 15, 0, 75)
    self.TabContainer.BackgroundTransparency = 1
    
    local TabLayout = Instance.new("UIListLayout", self.TabContainer)
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.Padding = UDim.new(0, 8)
    
    -- Page Container
    self.PageContainer = Instance.new("Frame", self.MainFrame)
    self.PageContainer.Size = UDim2.new(1, -30, 1, -155)
    self.PageContainer.Position = UDim2.new(0, 15, 0, 125)
    self.PageContainer.BackgroundTransparency = 1

    -- Bottom Hint Text
    local HintLabel = Instance.new("TextLabel", self.MainFrame)
    HintLabel.Size = UDim2.new(1, 0, 0, 25)
    HintLabel.Position = UDim2.new(0, 0, 1, -25)
    HintLabel.BackgroundTransparency = 1
    HintLabel.Text = "Press Right Shift to hide menu | Keybind can be changed in Settings"
    HintLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
    HintLabel.Font = Enum.Font.Montserrat
    HintLabel.TextSize = 11

    -- BUTTON LOGIC
    self.HwidBtn.MouseButton1Click:Connect(function()
        local my_hwid = "UNKNOWN"
        if gethwid then pcall(function() my_hwid = gethwid() end) else pcall(function() my_hwid = game:GetService("RbxAnalyticsService"):GetClientId() end) end
        if setclipboard then
            pcall(function() setclipboard(my_hwid) end)
            self.StatusText.Text = "HWID copied to clipboard!"
            self.StatusText.TextColor3 = Color3.fromRGB(50, 200, 50)
        else
            self.StatusText.Text = "Exploit doesn't support clipboard copying."
            self.StatusText.TextColor3 = Color3.fromRGB(200, 50, 50)
        end
    end)

    self.DiscordBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            pcall(function() setclipboard(DiscordLink) end)
            self.StatusText.Text = "Discord link copied!"
            self.StatusText.TextColor3 = Color3.fromRGB(50, 200, 50)
        else
            self.StatusText.Text = "Exploit doesn't support clipboard copying."
            self.StatusText.TextColor3 = Color3.fromRGB(200, 50, 50)
        end
    end)

    self.VerifyBtn.MouseButton1Click:Connect(function()
        self.VerifyBtn.Text = "Verifying..."
        local key = self.KeyInput.Text
        local isValid, msg = VerifyKeyWithServer(key)

        if isValid then
            self.StatusText.Text = msg
            self.StatusText.TextColor3 = Color3.fromRGB(50, 200, 50)
            self.VerifyBtn.Text = "Success"
            task.wait(1)
            self:TransitionToMain()
        else
            self.StatusText.Text = msg
            self.StatusText.TextColor3 = Color3.fromRGB(200, 50, 50)
            self.VerifyBtn.Text = "Verify Key"
        end
    end)

    return self
end

function UI:PlayStartupSequence()
    TweenService:Create(self.LoadingFrame, TweenInfo.new(1), {BackgroundTransparency = 0}):Play()
    TweenService:Create(self.LoadingFrame.UIStroke, TweenInfo.new(1), {Transparency = 0}):Play()
    TweenService:Create(self.LoadingText, TweenInfo.new(1), {TextTransparency = 0}):Play()
    
    task.wait(3.5)
    
    TweenService:Create(self.LoadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(self.LoadingFrame.UIStroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
    TweenService:Create(self.LoadingText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    
    task.wait(0.5)
    self.LoadingFrame:Destroy()
    
    self.KeyFrame.Visible = true
    TweenService:Create(self.KeyFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        GroupTransparency = 0
    }):Play()
end

function UI:TransitionToMain()
    local closeKey = TweenService:Create(self.KeyFrame, TweenInfo.new(0.4), {GroupTransparency = 1})
    closeKey:Play()
    closeKey.Completed:Connect(function()
        self.KeyFrame:Destroy()
        Config.Settings.UIOpen = true
        self.MainFrame.Visible = true
        TweenService:Create(self.MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            GroupTransparency = 0,
            Size = UDim2.new(0, 450, 0, 530)
        }):Play()
    end)
end

function UI:ToggleUI()
    if not self.KeyFrame or not self.KeyFrame.Parent then
        Config.Settings.UIOpen = not Config.Settings.UIOpen
        if Config.Settings.UIOpen then
            self.MainFrame.Visible = true
            TweenService:Create(self.MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                GroupTransparency = 0,
                Size = UDim2.new(0, 450, 0, 530)
            }):Play()
        else
            local tweenOut = TweenService:Create(self.MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                GroupTransparency = 1,
                Size = UDim2.new(0, 420, 0, 500)
            })
            tweenOut:Play()
            tweenOut.Completed:Connect(function()
                if not Config.Settings.UIOpen then self.MainFrame.Visible = false end
            end)
        end
    end
end

function UI:CreateTab(tabName)
    local TabBtn = Instance.new("TextButton", self.TabContainer)
    TabBtn.Size = UDim2.new(0, 95, 1, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtn.Text = tabName
    TabBtn.Font = Enum.Font.MontserratBold
    TabBtn.TextSize = 12
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    local BtnStroke = Instance.new("UIStroke", TabBtn)
    BtnStroke.Color = Color3.fromRGB(40, 40, 50)
    
    local Page = Instance.new("ScrollingFrame", self.PageContainer)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)
    Page.Visible = false
    
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 12)
    PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

    table.insert(self.Tabs, {Btn = TabBtn, Page = Page, Stroke = BtnStroke})
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Page.Visible = false
            TweenService:Create(t.Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 22, 28), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
            t.Stroke.Color = Color3.fromRGB(40, 40, 50)
        end
        Page.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(138, 43, 226), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        BtnStroke.Color = Color3.fromRGB(160, 80, 255)
    end)
    
    if #self.Tabs == 1 then
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        BtnStroke.Color = Color3.fromRGB(160, 80, 255)
    end
    return Page
end

local function AddLabel(parent, text)
    local Label = Instance.new("TextLabel", parent)
    Label.Size = UDim2.new(0.95, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(150, 150, 170)
    Label.Font = Enum.Font.MontserratBold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
end

local function AddInput(parent, placeholder, defaultText, callback)
    local InputBox = Instance.new("TextBox", parent)
    InputBox.Size = UDim2.new(0.95, 0, 0, 40)
    InputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.PlaceholderText = placeholder
    InputBox.Text = defaultText
    InputBox.Font = Enum.Font.Montserrat
    InputBox.TextSize = 14
    Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", InputBox).Color = Color3.fromRGB(45, 45, 55)
    InputBox.FocusLost:Connect(function() callback(InputBox.Text) end)
end

local function AddCycleButton(parent, prefix, list, startingIndex, callback)
    local currentIndex = startingIndex
    local Button = Instance.new("TextButton", parent)
    Button.Size = UDim2.new(0.95, 0, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Text = prefix .. ": " .. list[currentIndex]
    Button.Font = Enum.Font.Montserrat
    Button.TextSize = 14
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", Button).Color = Color3.fromRGB(45, 45, 55)
    
    Button.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #list then currentIndex = 1 end
        Button.Text = prefix .. ": " .. list[currentIndex]
        callback(currentIndex)
    end)
end

local function AddToggle(parent, text, callback)
    local state = false
    local Button = Instance.new("TextButton", parent)
    Button.Size = UDim2.new(0.95, 0, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(25, 25, 32) 
    Button.TextColor3 = Color3.fromRGB(200, 60, 60)
    Button.Text = text .. " [ OFF ]"
    Button.Font = Enum.Font.MontserratBold
    Button.TextSize = 14
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
    local BtnStroke = Instance.new("UIStroke", Button)
    BtnStroke.Color = Color3.fromRGB(200, 60, 60)
    
    Button.MouseButton1Click:Connect(function()
        state = not state
        if state then
            TweenService:Create(Button, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(60, 200, 60)}):Play()
            TweenService:Create(BtnStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(60, 200, 60)}):Play()
            Button.Text = text .. " [ ON ]"
        else
            TweenService:Create(Button, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(200, 60, 60)}):Play()
            TweenService:Create(BtnStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(200, 60, 60)}):Play()
            Button.Text = text .. " [ OFF ]"
        end
        callback(state)
    end)
end

-----------------------------------------
-- BUILDING THE INTERFACE
-----------------------------------------
local Hub = UI.new()

-- 1. GAMEPLAY
local TabGameplay = Hub:CreateTab("Gameplay")
AddLabel(TabGameplay, "CHARACTER SPEED")
AddInput(TabGameplay, "WalkSpeed (Default: 16)", tostring(Config.Gameplay.WalkSpeed), function(val)
    local num = tonumber(val)
    if num then Config.Gameplay.WalkSpeed = num end
end)
AddToggle(TabGameplay, "Enable Custom Speed", function(state) Config.Gameplay.SpeedEnabled = state end)

AddLabel(TabGameplay, "CHARACTER JUMP")
AddInput(TabGameplay, "JumpPower", tostring(Config.Gameplay.JumpPower), function(val)
    local num = tonumber(val)
    if num then Config.Gameplay.JumpPower = num end
end)
AddToggle(TabGameplay, "Enable Custom Jump", function(state) Config.Gameplay.JumpEnabled = state end)

AddLabel(TabGameplay, "PHYSICS MECHANICS")
AddInput(TabGameplay, "Tilt Power (0 - 10000)", tostring(Config.Gameplay.TiltPower), function(val)
    local num = tonumber(val)
    if num then Config.Gameplay.TiltPower = math.clamp(num, 0, 10000) end
end)
AddToggle(TabGameplay, "Enable Tilts Override", function(state) Config.Gameplay.TiltEnabled = state end)

-- 2. MISC
local TabMisc = Hub:CreateTab("Misc")
AddLabel(TabMisc, "SPOOF ATTRIBUTES")
AddCycleButton(TabMisc, "Physics", Config.Misc.PhysicsList, Config.Misc.CurrentPhysics, function(idx) Config.Misc.CurrentPhysics = idx end)
AddCycleButton(TabMisc, "Technical", Config.Misc.TechList, Config.Misc.CurrentTech, function(idx) Config.Misc.CurrentTech = idx end)
AddToggle(TabMisc, "Enable Fake Attributes", function(state) Config.Misc.AttrEnabled = state end)

-- 3. VISUALS
local TabVisuals = Hub:CreateTab("Visuals")
AddLabel(TabVisuals, "ENVIRONMENT")
AddToggle(TabVisuals, "Enable FullBright", function(state)
    Config.Visuals.FullBright = state
    if not state then
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
    end
end)

AddLabel(TabVisuals, "TIME SETTINGS")
AddInput(TabVisuals, "Time of Day (0-24) (14=Day, 0=Night)", tostring(Config.Visuals.TimeOfDay), function(val)
    local num = tonumber(val)
    if num then Config.Visuals.TimeOfDay = math.clamp(num, 0, 24) end
end)
AddToggle(TabVisuals, "Enable Custom Time", function(state) 
    Config.Visuals.CustomTime = state 
    if not state then Lighting.ClockTime = OriginalLighting.ClockTime end
end)

-- 4. SETTINGS
local TabSettings = Hub:CreateTab("Settings")
AddLabel(TabSettings, "INTERFACE CONTROLS")

local isBinding = false
local BindBtn = Instance.new("TextButton", TabSettings)
BindBtn.Size = UDim2.new(0.95, 0, 0, 45)
BindBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
BindBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
BindBtn.Text = "Toggle Keybind: [" .. Config.Settings.ToggleKey.Name .. "]"
BindBtn.Font = Enum.Font.MontserratBold
BindBtn.TextSize = 14
Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", BindBtn).Color = Color3.fromRGB(45, 45, 55)

BindBtn.MouseButton1Click:Connect(function()
    isBinding = true
    BindBtn.Text = "... Press Any Key ..."
    TweenService:Create(BindBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(138, 43, 226)}):Play()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.Settings.ToggleKey = input.KeyCode
        BindBtn.Text = "Toggle Keybind: [" .. input.KeyCode.Name .. "]"
        TweenService:Create(BindBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        isBinding = false
        return
    end
    if input.KeyCode == Config.Settings.ToggleKey and not gameProcessed then
        Hub:ToggleUI()
    end
end)

-----------------------------------------
-- GAME LOGIC
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

-- LAUNCH
task.spawn(function()
    Hub:PlayStartupSequence()
end)
