--[==[ 
    DEBUG START 
--]==]
print("--- SELACE HUB: STARTING INJECTION ---")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local DiscordLink = "https://discord.gg/9eYR7ecMu"

-- Ожидание загрузки игрока
if not player:FindFirstChild("PlayerGui") then
    player:WaitForChild("PlayerGui", 10)
end

print("--- SELACE HUB: SERVICES LOADED ---")

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
-- VERIFICATION SYSTEM
-----------------------------------------
local function VerifyKey(key)
    print("--- SELACE HUB: VERIFYING KEY ---")
    local my_hwid = "UNKNOWN"
    
    -- Проверка HWID
    local success_hwid, res_hwid = pcall(function()
        if gethwid then return gethwid() end
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    my_hwid = success_hwid and res_hwid or "ERROR"

    -- Получение базы данных
    local db_url = "https://pastebin.com/raw/2aVHcEnn"
    local success_db, db_text = pcall(function()
        return game:HttpGet(db_url)
    end)

    if not success_db then return false, "Database Connection Error!" end

    for line in string.gmatch(db_text, "[^\r\n]+") do
        local split = string.split(line, ":")
        if #split >= 2 and key == split[1] and my_hwid == split[2] then
            return true, "Success!"
        end
    end

    return false, "Invalid Key or HWID Lock!"
end

-----------------------------------------
-- UI CONSTRUCTION (CLEAN VERSION)
-----------------------------------------
print("--- SELACE HUB: BUILDING UI ---")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SelaceHubXeno"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player.PlayerGui

-- MAIN WINDOW
local Main = Instance.new("Frame", ScreenGui)
Main.Name = "Main"
Main.Size = UDim2.new(0, 450, 0, 500)
Main.Position = UDim2.new(0.5, -225, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = false -- Скрыто до проверки ключа

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 10)

-- TITLE SECTION
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "SELACE HUB"
Title.TextColor3 = Color3.fromRGB(160, 80, 255)
Title.Font = Enum.Font.MontserratBold
Title.TextSize = 24

local SubTitle = Instance.new("TextLabel", Main)
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Position = UDim2.new(0, 0, 0, 40)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Made by Selace"
SubTitle.TextColor3 = Color3.fromRGB(120, 120, 140)
SubTitle.Font = Enum.Font.MontserratSemibold
SubTitle.TextSize = 12

-- KEY SYSTEM WINDOW
local KeyUI = Instance.new("Frame", ScreenGui)
KeyUI.Size = UDim2.new(0, 350, 0, 220)
KeyUI.Position = UDim2.new(0.5, -175, 0.5, -110)
KeyUI.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
KeyUI.BorderSizePixel = 0
Instance.new("UICorner", KeyUI).CornerRadius = UDim.new(0, 10)

local KeyHeader = Instance.new("TextLabel", KeyUI)
KeyHeader.Size = UDim2.new(1, 0, 0, 50)
KeyHeader.Text = "AUTHENTICATION"
KeyHeader.TextColor3 = Color3.fromRGB(160, 80, 255)
KeyHeader.Font = Enum.Font.MontserratBold
KeyHeader.TextSize = 18
KeyHeader.BackgroundTransparency = 1

local KeyBox = Instance.new("TextBox", KeyUI)
KeyBox.Size = UDim2.new(0.9, 0, 0, 40)
KeyBox.Position = UDim2.new(0.05, 0, 0, 60)
KeyBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
KeyBox.PlaceholderText = "Enter Key..."
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", KeyBox)

local VerifyBtn = Instance.new("TextButton", KeyUI)
VerifyBtn.Size = UDim2.new(0.9, 0, 0, 40)
VerifyBtn.Position = UDim2.new(0.05, 0, 0, 110)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(160, 80, 255)
VerifyBtn.Text = "VERIFY"
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.Font = Enum.Font.MontserratBold
Instance.new("UICorner", VerifyBtn)

local CopyHwid = Instance.new("TextButton", KeyUI)
CopyHwid.Size = UDim2.new(0.9, 0, 0, 30)
CopyHwid.Position = UDim2.new(0.05, 0, 0, 160)
CopyHwid.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
CopyHwid.Text = "COPY HWID"
CopyHwid.TextColor3 = Color3.fromRGB(200, 200, 200)
Instance.new("UICorner", CopyHwid)

-- TAB SYSTEM
local TabHolder = Instance.new("Frame", Main)
TabHolder.Size = UDim2.new(1, -20, 0, 40)
TabHolder.Position = UDim2.new(0, 10, 0, 70)
TabHolder.BackgroundTransparency = 1
local TabLayout = Instance.new("UIListLayout", TabHolder)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 5)

local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -20, 1, -150)
Container.Position = UDim2.new(0, 10, 0, 120)
Container.BackgroundTransparency = 1

local Hint = Instance.new("TextLabel", Main)
Hint.Size = UDim2.new(1, 0, 0, 20)
Hint.Position = UDim2.new(0, 0, 1, -20)
Hint.Text = "Press Right Shift to Toggle | Settings to change"
Hint.TextColor3 = Color3.fromRGB(100, 100, 110)
Hint.TextSize = 10
Hint.BackgroundTransparency = 1

-----------------------------------------
-- FUNCTIONALITY
-----------------------------------------

CopyHwid.MouseButton1Click:Connect(function()
    local hwid = "ERROR"
    pcall(function() hwid = gethwid and gethwid() or game:GetService("RbxAnalyticsService"):GetClientId() end)
    if setclipboard then setclipboard(hwid) CopyHwid.Text = "COPIED!" task.wait(1) CopyHwid.Text = "COPY HWID" end
end)

VerifyBtn.MouseButton1Click:Connect(function()
    local success, msg = VerifyKey(KeyBox.Text)
    if success then
        KeyUI:Destroy()
        Main.Visible = true
        Config.Settings.UIOpen = true
    else
        VerifyBtn.Text = msg
        task.wait(2)
        VerifyBtn.Text = "VERIFY"
    end
end)

-- Простая система вкладок
local function CreateTab(name)
    local b = Instance.new("TextButton", TabHolder)
    b.Size = UDim2.new(0, 100, 1, 0)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", b)
    
    local p = Instance.new("ScrollingFrame", Container)
    p.Size = UDim2.new(1, 0, 1, 0)
    p.Visible = false
    p.BackgroundTransparency = 1
    p.CanvasSize = UDim2.new(0,0,2,0)
    Instance.new("UIListLayout", p).Padding = UDim.new(0,10)

    b.MouseButton1Click:Connect(function()
        for _, v in pairs(Container:GetChildren()) do v.Visible = false end
        p.Visible = true
    end)
    return p
end

local TabG = CreateTab("Gameplay")
local TabM = CreateTab("Misc")
local TabV = CreateTab("Visuals")
local TabS = CreateTab("Settings")
TabG.Visible = true

-- Наполнение (Пример кнопок)
local function AddToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Text = text .. " [OFF]"
    btn.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    Instance.new("UICorner", btn)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. (state and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = state and Color3.fromRGB(30, 40, 30) or Color3.fromRGB(40, 30, 30)
        btn.TextColor3 = state and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        callback(state)
    end)
end

AddToggle(TabG, "Speed", function(s) Config.Gameplay.SpeedEnabled = s end)
AddToggle(TabG, "Jump", function(s) Config.Gameplay.JumpEnabled = s end)
AddToggle(TabV, "FullBright", function(s) Config.Visuals.FullBright = s end)

-- TOGGLE
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Config.Settings.ToggleKey then
        Config.Settings.UIOpen = not Config.Settings.UIOpen
        Main.Visible = Config.Settings.UIOpen
    end
end)

-- LOOP
RunService.Heartbeat:Connect(function()
    pcall(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local h = player.Character.Humanoid
            if Config.Gameplay.SpeedEnabled then h.WalkSpeed = Config.Gameplay.WalkSpeed end
            if Config.Gameplay.JumpEnabled then h.JumpPower = Config.Gameplay.JumpPower h.UseJumpPower = true end
        end
        if Config.Visuals.FullBright then Lighting.Ambient = Color3.fromRGB(255,255,255) Lighting.GlobalShadows = false end
    end)
end)

print("--- SELACE HUB: FULLY LOADED ---")
