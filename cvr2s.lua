local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-----------------------------------------
-- НАСТРОЙКИ ЗНАЧЕНИЙ
-----------------------------------------
local Config = {
    Gameplay = {
        JumpPower = 25.5,
        JumpEnabled = false,
        WalkSpeed = 16,
        SpeedEnabled = false,
        TiltPower = 4000,
        TiltEnabled = false
    },
    Misc = {
        PhysicsList = {"Bounce", "Athletic", "Wide Reach", "Sprinter", "Solid form", "All Rounder"},
        TechList = {"Backrow Blitz", "Mind Reader", "Unbreakable", "Wiper", "Stance", "Fast Approach"},
        CurrentPhysics = 2,
        CurrentTech = 6,
        AttrEnabled = false
    },
    Visuals = {
        FOV = 70,
        FOVEnabled = false,
        FogDistance = 100000,
        FogColor = Color3.fromRGB(255, 255, 255),
        CustomFog = false,
        TimeOfDay = 14,
        CustomTime = false,
        FullBright = false
    }
}

-- Сохраняем оригинальные настройки освещения
local OriginalLighting = {
    Ambient = Lighting.Ambient,
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
    FogColor = Lighting.FogColor,
    ClockTime = Lighting.ClockTime
}

-----------------------------------------
-- UI БИБЛИОТЕКА (OOP + Вкладки)
-----------------------------------------
local UI = {}
UI.__index = UI

function UI.new(titleText)
    local self = setmetatable({}, UI)
    self.Tabs = {}
    self.CurrentTab = nil

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SelaceHub"
    self.ScreenGui.ResetOnSpawn = false
    pcall(function() self.ScreenGui.Parent = CoreGui end)
    if not self.ScreenGui.Parent then self.ScreenGui.Parent = player:WaitForChild("PlayerGui") end
    
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 450, 0, 550)
    self.MainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Active = true
    self.MainFrame.Draggable = true
    self.MainFrame.Parent = self.ScreenGui
    
    Instance.new("UICorner", self.MainFrame).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", self.MainFrame)
    Stroke.Color = Color3.fromRGB(138, 43, 226) -- Neon Purple
    Stroke.Thickness = 2
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.Montserrat
    Title.TextSize = 22
    Title.Parent = self.MainFrame
    
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Size = UDim2.new(1, -20, 0, 35)
    self.TabContainer.Position = UDim2.new(0, 10, 0, 50)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.Parent = self.MainFrame
    
    local TabLayout = Instance.new("UIListLayout", self.TabContainer)
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.Padding = UDim.new(0, 10)
    
    self.PageContainer = Instance.new("Frame")
    self.PageContainer.Size = UDim2.new(1, -20, 1, -100)
    self.PageContainer.Position = UDim2.new(0, 10, 0, 90)
    self.PageContainer.BackgroundTransparency = 1
    self.PageContainer.Parent = self.MainFrame

    return self
end

function UI:CreateTab(tabName)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 130, 1, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Text = tabName
    TabBtn.Font = Enum.Font.Montserrat
    TabBtn.TextSize = 14
    TabBtn.Parent = self.TabContainer
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Visible = false
    Page.Parent = self.PageContainer
    
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 10)
    PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local tabObj = {Btn = TabBtn, Page = Page}
    table.insert(self.Tabs, tabObj)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Page.Visible = false
            t.Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            t.Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    -- Активируем первую вкладку по умолчанию
    if #self.Tabs == 1 then
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    return Page
end

-- Вспомогательные функции для элементов внутри вкладок
local function AddLabel(parent, text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.95, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(150, 150, 180)
    Label.Font = Enum.Font.Montserrat
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent
end

local function AddInput(parent, placeholder, defaultText, callback)
    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(0.95, 0, 0, 35)
    InputBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.PlaceholderText = placeholder
    InputBox.Text = defaultText
    InputBox.Font = Enum.Font.Montserrat
    InputBox.TextSize = 14
    InputBox.Parent = parent
    Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", InputBox).Color = Color3.fromRGB(50, 50, 60)
    
    InputBox.FocusLost:Connect(function()
        callback(InputBox.Text)
    end)
end

local function AddCycleButton(parent, prefix, list, startingIndex, callback)
    local currentIndex = startingIndex
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.95, 0, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Text = prefix .. ": " .. list[currentIndex]
    Button.Font = Enum.Font.Montserrat
    Button.TextSize = 14
    Button.Parent = parent
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
    
    Button.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #list then currentIndex = 1 end
        Button.Text = prefix .. ": " .. list[currentIndex]
        callback(currentIndex)
    end)
end

local function AddToggle(parent, text, callback)
    local state = false
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.95, 0, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 35) 
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    Button.Text = text .. " [ OFF ]"
    Button.Font = Enum.Font.Montserrat
    Button.TextSize = 14
    Button.Parent = parent
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", Button)
    stroke.Color = Color3.fromRGB(180, 50, 50)
    
    Button.MouseButton1Click:Connect(function()
        state = not state
        if state then
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.Text = text .. " [ ON ]"
            stroke.Color = Color3.fromRGB(50, 180, 50)
        else
            Button.TextColor3 = Color3.fromRGB(200, 200, 200)
            Button.Text = text .. " [ OFF ]"
            stroke.Color = Color3.fromRGB(180, 50, 50)
        end
        callback(state)
    end)
end

-----------------------------------------
-- ПОСТРОЕНИЕ ИНТЕРФЕЙСА
-----------------------------------------
local Hub = UI.new("Made by selace")

-- 1. ВКЛАДКА: GAMEPLAY
local TabGameplay = Hub:CreateTab("Gameplay")
AddLabel(TabGameplay, "— Character Speed")
AddInput(TabGameplay, "WalkSpeed (Default: 16)", tostring(Config.Gameplay.WalkSpeed), function(val)
    local num = tonumber(val)
    if num then Config.Gameplay.WalkSpeed = num end
end)
AddToggle(TabGameplay, "Enable WalkSpeed", function(state) Config.Gameplay.SpeedEnabled = state end)

AddLabel(TabGameplay, "— Character Jump")
AddInput(TabGameplay, "JumpPower", tostring(Config.Gameplay.JumpPower), function(val)
    local num = tonumber(val)
    if num then Config.Gameplay.JumpPower = num end
end)
AddToggle(TabGameplay, "Enable Custom Jump", function(state) Config.Gameplay.JumpEnabled = state end)

AddLabel(TabGameplay, "— Mechanics")
AddInput(TabGameplay, "Tilt Power (2000-4500)", tostring(Config.Gameplay.TiltPower), function(val)
    local num = tonumber(val)
    if num then Config.Gameplay.TiltPower = num end
end)
AddToggle(TabGameplay, "Run Tilts", function(state) Config.Gameplay.TiltEnabled = state end)

-- 2. ВКЛАДКА: MISC
local TabMisc = Hub:CreateTab("Misc")
AddLabel(TabMisc, "— Attributes Settings")
AddCycleButton(TabMisc, "Physics", Config.Misc.PhysicsList, Config.Misc.CurrentPhysics, function(idx)
    Config.Misc.CurrentPhysics = idx
end)
AddCycleButton(TabMisc, "Technical", Config.Misc.TechList, Config.Misc.CurrentTech, function(idx)
    Config.Misc.CurrentTech = idx
end)
AddToggle(TabMisc, "Spoof Attributes", function(state) Config.Misc.AttrEnabled = state end)

-- 3. ВКЛАДКА: VISUALS
local TabVisuals = Hub:CreateTab("Visuals")
AddLabel(TabVisuals, "— Camera FOV (Zoom out)")
AddInput(TabVisuals, "FOV Value (1 - 300)", tostring(Config.Visuals.FOV), function(val)
    local num = tonumber(val)
    if num then Config.Visuals.FOV = math.clamp(num, 1, 300) end
end)
AddToggle(TabVisuals, "Enable Custom FOV", function(state) Config.Visuals.FOVEnabled = state end)

AddLabel(TabVisuals, "— Fog Settings")
AddInput(TabVisuals, "Fog Distance (e.g. 50, 1000)", "100000", function(val)
    local num = tonumber(val)
    if num then Config.Visuals.FogDistance = num end
end)
AddInput(TabVisuals, "Fog Color (R, G, B) e.g. 255, 0, 0", "255, 255, 255", function(val)
    local args = string.split(val, ",")
    if #args == 3 then
        pcall(function()
            Config.Visuals.FogColor = Color3.fromRGB(tonumber(args[1]), tonumber(args[2]), tonumber(args[3]))
        end)
    end
end)
AddToggle(TabVisuals, "Override Fog", function(state) 
    Config.Visuals.CustomFog = state 
    if not state then
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.FogColor = OriginalLighting.FogColor
    end
end)

AddLabel(TabVisuals, "— Environment")
AddToggle(TabVisuals, "FullBright (Remove Shadows)", function(state)
    Config.Visuals.FullBright = state
    if not state then
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
    end
end)

AddInput(TabVisuals, "Time of Day (0-24)", tostring(Config.Visuals.TimeOfDay), function(val)
    local num = tonumber(val)
    if num then Config.Visuals.TimeOfDay = num end
end)
AddToggle(TabVisuals, "Custom Time", function(state) 
    Config.Visuals.CustomTime = state 
    if not state then Lighting.ClockTime = OriginalLighting.ClockTime end
end)

-----------------------------------------
-- ЛОГИКА ИГРЫ (Loops)
-----------------------------------------

-- Поддержание параметров Хуманоида (Speed и Jump)
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

-- Основной цикл для всего остального
RunService.Heartbeat:Connect(function()
    
    -- 1. Gameplay: Хуманоид фолбэк (на всякий случай)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local hum = player.Character.Humanoid
        if Config.Gameplay.SpeedEnabled and hum.WalkSpeed ~= Config.Gameplay.WalkSpeed then
            hum.WalkSpeed = Config.Gameplay.WalkSpeed
        end
        if Config.Gameplay.JumpEnabled and hum.JumpPower ~= 0 and hum.JumpPower ~= Config.Gameplay.JumpPower then
            hum.UseJumpPower = true
            hum.JumpPower = Config.Gameplay.JumpPower
        end
    end

    -- 2. Gameplay: Тильты
    if Config.Gameplay.TiltEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        local tilt = hrp:FindFirstChild("Tilt")
        if tilt then
            pcall(function() tilt.P = Config.Gameplay.TiltPower end)
        end
    end

    -- 3. Misc: Атрибуты
    if Config.Misc.AttrEnabled then
        local data = player:FindFirstChild("Data")
        if data then
            data:SetAttribute("Technical", Config.Misc.TechList[Config.Misc.CurrentTech])
            data:SetAttribute("Physical", Config.Misc.PhysicsList[Config.Misc.CurrentPhysics])
        end
    end

    -- 4. Visuals: FOV
    if Config.Visuals.FOVEnabled then
        camera.FieldOfView = Config.Visuals.FOV
    end

    -- 5. Visuals: Туман
    if Config.Visuals.CustomFog then
        Lighting.FogEnd = Config.Visuals.FogDistance
        Lighting.FogColor = Config.Visuals.FogColor
    end

    -- 6. Visuals: Время суток
    if Config.Visuals.CustomTime then
        Lighting.ClockTime = Config.Visuals.TimeOfDay
    end

    -- 7. Visuals: FullBright
    if Config.Visuals.FullBright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.GlobalShadows = false
    end
end)
