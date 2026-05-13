-- [[ SELACE HUB PREMIUM EDITION ]] --
-- [[ MADE BY SELACE ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local DiscordLink = "https://discord.gg/9eYR7ecMu"
local DatabaseURL = "https://pastebin.com/raw/2aVHcEnn"

-----------------------------------------
-- CONFIGURATION
-----------------------------------------
local Config = {
    Gameplay = { JumpPower = 25.5, JumpEnabled = false, WalkSpeed = 16, SpeedEnabled = false, TiltPower = 4000, TiltEnabled = false },
    Misc = { 
        PhysicsList = {"Bounce", "Athletic", "Wide Reach", "Sprinter", "Solid form", "All Rounder"}, 
        TechList = {"Backrow Blitz", "Mind Reader", "Unbreakable", "Wiper", "Stance", "Fast Approach"}, 
        CurrentPhysics = 2, CurrentTech = 6, AttrEnabled = false 
    },
    Visuals = { TimeOfDay = 14, CustomTime = false, FullBright = false },
    Settings = { ToggleKey = Enum.KeyCode.RightShift, UIOpen = false }
}

local OriginalLighting = { Ambient = Lighting.Ambient, GlobalShadows = Lighting.GlobalShadows, ClockTime = Lighting.ClockTime }

-----------------------------------------
-- UTILITIES
-----------------------------------------
local function GetHWID()
    local id = "UNKNOWN"
    pcall(function()
        if gethwid then id = gethwid()
        else id = game:GetService("RbxAnalyticsService"):GetClientId() end
    end)
    return id
end

local function VerifyKey(key)
    local my_hwid = GetHWID()
    local success, db_text = pcall(function() return game:HttpGet(DatabaseURL) end)
    if not success then return false, "Connection Error!" end

    for line in string.gmatch(db_text, "[^\r\n]+") do
        local split = string.split(line, ":")
        if #split >= 2 and key == split[1] and my_hwid == split[2] then
            return true, "Success!"
        end
    end
    return false, "Invalid Key / HWID Mismatch"
end

-----------------------------------------
-- UI CONSTRUCTION
-----------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SelaceHub"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

-- Loading Screen
local Loading = Instance.new("Frame", ScreenGui)
Loading.Size = UDim2.new(0, 250, 0, 70)
Loading.Position = UDim2.new(0.5, -125, 0.5, -35)
Loading.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", Loading)
local LoadLabel = Instance.new("TextLabel", Loading)
LoadLabel.Size = UDim2.new(1, 0, 1, 0)
LoadLabel.BackgroundTransparency = 1
LoadLabel.Text = "Injecting Selace Hub..."
LoadLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadLabel.Font = Enum.Font.MontserratBold
LoadLabel.TextSize = 16

-- Main Window
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 450, 0, 520)
Main.Position = UDim2.new(0.5, -225, 0.5, -260)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Active = true
Main.Draggable = true -- The whole menu is draggable
Instance.new("UICorner", Main)

-- Header (Static Text)
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 70)
Header.BackgroundTransparency = 1

local MainTitle = Instance.new("TextLabel", Header)
MainTitle.Size = UDim2.new(1, 0, 0, 30)
MainTitle.Position = UDim2.new(0, 0, 0, 15)
MainTitle.Text = "Selace Hub"
MainTitle.TextColor3 = Color3.fromRGB(160, 80, 255)
MainTitle.Font = Enum.Font.MontserratBold
MainTitle.TextSize = 26
MainTitle.BackgroundTransparency = 1

local SubTitle = Instance.new("TextLabel", Header)
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Position = UDim2.new(0, 0, 0, 42)
SubTitle.Text = "Made by Selace"
SubTitle.TextColor3 = Color3.fromRGB(120, 120, 140)
SubTitle.Font = Enum.Font.MontserratSemibold
SubTitle.TextSize = 12
SubTitle.BackgroundTransparency = 1

-- Tab Bar
local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(1, -20, 0, 35)
TabBar.Position = UDim2.new(0, 10, 0, 80)
TabBar.BackgroundTransparency = 1
local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.Padding = UDim.new(0, 8)

-- Content Container
local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -30, 1, -165)
Container.Position = UDim2.new(0, 15, 0, 125)
Container.BackgroundTransparency = 1

-- Bottom Hint
local Hint = Instance.new("TextLabel", Main)
Hint.Size = UDim2.new(1, 0, 0, 25)
Hint.Position = UDim2.new(0, 0, 1, -25)
Hint.Text = "Press Right Shift to hide | Change keybind in Settings"
Hint.TextColor3 = Color3.fromRGB(100, 100, 110)
Hint.Font = Enum.Font.Montserrat
Hint.TextSize = 11
Hint.BackgroundTransparency = 1

-- KEY SYSTEM
local KeyFrame = Instance.new("Frame", ScreenGui)
KeyFrame.Size = UDim2.new(0, 350, 0, 220)
KeyFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
KeyFrame.Visible = false
Instance.new("UICorner", KeyFrame)

local KeyBox = Instance.new("TextBox", KeyFrame)
KeyBox.Size = UDim2.new(0.9, 0, 0, 40)
KeyBox.Position = UDim2.new(0.05, 0, 0, 60)
KeyBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
KeyBox.Text = ""
KeyBox.PlaceholderText = "Enter Key..."
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", KeyBox)

local VerifyBtn = Instance.new("TextButton", KeyFrame)
VerifyBtn.Size = UDim2.new(0.9, 0, 0, 40)
VerifyBtn.Position = UDim2.new(0.05, 0, 0, 110)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
VerifyBtn.Text = "Verify Key"
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.Font = Enum.Font.MontserratBold
Instance.new("UICorner", VerifyBtn)

local HwidBtn = Instance.new("TextButton", KeyFrame)
HwidBtn.Size = UDim2.new(0.43, 0, 0, 35)
HwidBtn.Position = UDim2.new(0.05, 0, 0, 160)
HwidBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
HwidBtn.Text = "Copy HWID"
HwidBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
Instance.new("UICorner", HwidBtn)

local DiscordBtn = Instance.new("TextButton", KeyFrame)
DiscordBtn.Size = UDim2.new(0.43, 0, 0, 35)
DiscordBtn.Position = UDim2.new(0.52, 0, 0, 160)
DiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
DiscordBtn.Text = "Get Key"
DiscordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", DiscordBtn)

-----------------------------------------
-- UI FUNCTIONS
-----------------------------------------
local function CreateTab(name)
    local b = Instance.new("TextButton", TabBar)
    b.Size = UDim2.new(0, 95, 1, 0)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    b.TextColor3 = Color3.fromRGB(180, 180, 180)
    b.Font = Enum.Font.MontserratBold
    b.TextSize = 12
    Instance.new("UICorner", b)
    
    local p = Instance.new("ScrollingFrame", Container)
    p.Size = UDim2.new(1, 0, 1, 0)
    p.Visible = false
    p.BackgroundTransparency = 1
    p.ScrollBarThickness = 2
    p.CanvasSize = UDim2.new(0,0,2,0)
    Instance.new("UIListLayout", p).Padding = UDim.new(0,10)

    b.MouseButton1Click:Connect(function()
        for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
        for _, v in pairs(TabBar:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(180, 180, 180) end end
        p.Visible = true
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    return p
end

local function AddToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 40)
    btn.Text = text .. " [OFF]"
    btn.BackgroundColor3 = Color3.fromRGB(30, 25, 25)
    btn.TextColor3 = Color3.fromRGB(255, 80, 80)
    btn.Font = Enum.Font.MontserratBold
    Instance.new("UICorner", btn)
    
    local s = false
    btn.MouseButton1Click:Connect(function()
        s = not s
        btn.Text = text .. (s and " [ON]" or " [OFF]")
        btn.TextColor3 = s and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
        btn.BackgroundColor3 = s and Color3.fromRGB(25, 30, 25) or Color3.fromRGB(30, 25, 25)
        callback(s)
    end)
end

local function AddInput(parent, placeholder, callback)
    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(0.95, 0, 0, 40)
    box.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", box)
    box.FocusLost:Connect(function() callback(box.Text) end)
end

-----------------------------------------
-- TABS SETUP
-----------------------------------------
local TabG = CreateTab("Gameplay")
local TabM = CreateTab("Misc")
local TabV = CreateTab("Visuals")
local TabS = CreateTab("Settings")
TabG.Visible = true

AddInput(TabG, "Speed (Default 16)", function(t) Config.Gameplay.WalkSpeed = tonumber(t) or 16 end)
AddToggle(TabG, "Enable Speed", function(s) Config.Gameplay.SpeedEnabled = s end)
AddInput(TabG, "Jump (Default 50)", function(t) Config.Gameplay.JumpPower = tonumber(t) or 50 end)
AddToggle(TabG, "Enable Jump", function(s) Config.Gameplay.JumpEnabled = s end)
AddInput(TabG, "Tilt Power (0-10000)", function(t) Config.Gameplay.TiltPower = math.clamp(tonumber(t) or 4000, 0, 10000) end)
AddToggle(TabG, "Enable Tilts", function(s) Config.Gameplay.TiltEnabled = s end)

AddToggle(TabV, "FullBright", function(s) Config.Visuals.FullBright = s end)
AddInput(TabV, "Time of Day (0-24)", function(t) Config.Visuals.TimeOfDay = tonumber(t) or 14 end)
AddToggle(TabV, "Enable Custom Time", function(s) Config.Visuals.CustomTime = s end)

-- Settings Keybind
local BindBtn = Instance.new("TextButton", TabS)
BindBtn.Size = UDim2.new(0.95, 0, 0, 40)
BindBtn.Text = "Toggle Key: " .. Config.Settings.ToggleKey.Name
BindBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
BindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", BindBtn)

local binding = false
BindBtn.MouseButton1Click:Connect(function()
    binding = true
    BindBtn.Text = "... Press Key ..."
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if binding and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.Settings.ToggleKey = input.KeyCode
        BindBtn.Text = "Toggle Key: " .. input.KeyCode.Name
        binding = false
    elseif not gp and input.KeyCode == Config.Settings.ToggleKey then
        Config.Settings.UIOpen = not Config.Settings.UIOpen
        Main.Visible = Config.Settings.UIOpen
    end
end)

-----------------------------------------
-- LOGIC & AUTH
-----------------------------------------
HwidBtn.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard(GetHWID()) HwidBtn.Text = "COPIED!" task.wait(1) HwidBtn.Text = "Copy HWID" end
end)

DiscordBtn.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard(DiscordLink) DiscordBtn.Text = "COPIED!" task.wait(1) DiscordBtn.Text = "Get Key" end
end)

VerifyBtn.MouseButton1Click:Connect(function()
    VerifyBtn.Text = "Checking..."
    local ok, msg = VerifyKey(KeyBox.Text)
    if ok then
        KeyFrame:Destroy()
        Main.Visible = true
        Config.Settings.UIOpen = true
    else
        VerifyBtn.Text = msg
        task.wait(2)
        VerifyBtn.Text = "Verify Key"
    end
end)

-- Main Loop
RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid
            if Config.Gameplay.SpeedEnabled then hum.WalkSpeed = Config.Gameplay.WalkSpeed end
            if Config.Gameplay.JumpEnabled then hum.JumpPower = Config.Gameplay.JumpPower hum.UseJumpPower = true end
        end
        if Config.Gameplay.TiltEnabled and char:FindFirstChild("HumanoidRootPart") then
            local t = char.HumanoidRootPart:FindFirstChild("Tilt")
            if t then t.P = Config.Gameplay.TiltPower end
        end
        if Config.Visuals.FullBright then Lighting.Ambient = Color3.fromRGB(255, 255, 255) Lighting.GlobalShadows = false end
        if Config.Visuals.CustomTime then Lighting.ClockTime = Config.Visuals.TimeOfDay end
    end)
end)

-- Start Sequence
task.spawn(function()
    task.wait(5) -- 5 second wait for loading
    Loading:Destroy()
    KeyFrame.Visible = true
end)
