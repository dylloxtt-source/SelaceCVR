local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

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
        TimeOfDay = 14,
        CustomTime = false,
        FullBright = false
    },
    Settings = {
        ToggleKey = Enum.KeyCode.RightShift,
        UIOpen = false -- Флаг состояния
    }
}

local OriginalLighting = {
    Ambient = Lighting.Ambient,
    GlobalShadows = Lighting.GlobalShadows,
    ClockTime = Lighting.ClockTime
}

-----------------------------------------
-- UI БИБЛИОТЕКА И АНИМАЦИИ
-----------------------------------------
local UI = {}
UI.__index = UI

function UI.new(titleText)
    local self = setmetatable({}, UI)
    self.Tabs = {}

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SelaceHub"
    self.ScreenGui.ResetOnSpawn = false
    pcall(function() self.ScreenGui.Parent = CoreGui end)
    if not self.ScreenGui.Parent then self.ScreenGui.Parent = player:WaitForChild("PlayerGui") end
    
    -- Экран загрузки (Loading Screen)
    self.LoadingFrame = Instance.new("Frame")
    self.LoadingFrame.Size = UDim2.new(0, 250, 0, 80)
    self.LoadingFrame.Position = UDim2.new(0.5, -125, 0.5, -40)
    self.LoadingFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    self.LoadingFrame.BackgroundTransparency = 1
    self.LoadingFrame.Parent = self.ScreenGui
    Instance.new("UICorner", self.LoadingFrame).CornerRadius = UDim.new(0, 8)
    local LoadStroke = Instance.new("UIStroke", self.LoadingFrame)
    LoadStroke.Color = Color3.fromRGB(138, 43, 226)
    LoadStroke.Transparency = 1
    
    self.LoadingText = Instance.new("TextLabel")
    self.LoadingText.Size = UDim2.new(1, 0, 1, 0)
    self.LoadingText.BackgroundTransparency = 1
    self.LoadingText.Text = "Injecting selace hub..."
    self.LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.LoadingText.Font = Enum.Font.Montserrat
    self.LoadingText.TextSize = 16
    self.LoadingText.TextTransparency = 1
    self.LoadingText.Parent = self.LoadingFrame

    -- Главное окно (CanvasGroup для плавного изменения прозрачности всего содержимого)
    self.MainFrame = Instance.new("CanvasGroup")
    self.MainFrame.Size = UDim2.new(0, 420, 0, 500) -- Чуть меньше по умолчанию для анимации
    self.MainFrame.Position = UDim2.new(0.5, -210, 0.5, -250)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.GroupTransparency = 1 -- Скрыто по умолчанию
    self.MainFrame.Visible = false
    self.MainFrame.Parent = self.ScreenGui
    
    Instance.new("UICorner", self.MainFrame).CornerRadius = UDim.new(0, 10)
    
    -- Делаем перемещаемым с помощью стандартного функционала внутри CanvasGroup
    local DragFrame = Instance.new("Frame", self.MainFrame)
    DragFrame.Size = UDim2.new(1, 0, 0, 50)
    DragFrame.BackgroundTransparency = 1
    DragFrame.Active = true
    DragFrame.Draggable = true
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.MontserratBold
    Title.TextSize = 20
    Title.Parent = DragFrame
    
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Size = UDim2.new(1, -20, 0, 35)
    self.TabContainer.Position = UDim2.new(0, 10, 0, 50)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.Parent = self.MainFrame
    
    local TabLayout = Instance.new("UIListLayout", self.TabContainer)
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.Padding = UDim.new(0, 6)
    
    self.PageContainer = Instance.new("Frame")
    self.PageContainer.Size = UDim2.new(1, -20, 1, -100)
    self.PageContainer.Position = UDim2.new(0, 10, 0, 90)
    self.PageContainer.BackgroundTransparency = 1
    self.PageContainer.Parent = self.MainFrame

    return self
end

function UI:PlayStartupSequence()
    -- 1. Появление экрана загрузки
    TweenService:Create(self.LoadingFrame, TweenInfo.new(1), {BackgroundTransparency = 0}):Play()
    TweenService:Create(self.LoadingFrame.UIStroke, TweenInfo.new(1), {Transparency = 0}):Play()
    TweenService:Create(self.LoadingText, TweenInfo.new(1), {TextTransparency = 0}):Play()
    
    -- 2. Ждем 5 секунд
    task.wait(5)
    
    -- 3. Исчезновение экрана загрузки
    TweenService:Create(self.LoadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(self.LoadingFrame.UIStroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
    TweenService:Create(self.LoadingText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    
    task.wait(0.5)
    self.LoadingFrame:Destroy()
    
    -- 4. Плавное открытие главного интерфейса
    Config.Settings.UIOpen = true
    self.MainFrame.Visible = true
    self.MainFrame.Size = UDim2.new(0, 420, 0, 450) -- Начальный размер (сжатый)
    
    TweenService:Create(self.MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        GroupTransparency = 0,
        Size = UDim2.new(0, 450, 0, 500)
    }):Play()
end

function UI:ToggleUI()
    Config.Settings.UIOpen = not Config.Settings.UIOpen
    
    if Config.Settings.UIOpen then
        self.MainFrame.Visible = true
        TweenService:Create(self.MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            GroupTransparency = 0,
            Size = UDim2.new(0, 450, 0, 500)
        }):Play()
    else
        local tweenOut = TweenService:Create(self.MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            GroupTransparency = 1,
            Size = UDim2.new(0, 420, 0, 450)
        })
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            if not Config.Settings.UIOpen then
                self.MainFrame.Visible = false
            end
        end)
    end
end

function UI:CreateTab(tabName)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 100, 1, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtn.Text = tabName
    TabBtn.Font = Enum.Font.Montserrat
    TabBtn.TextSize = 13
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

    table.insert(self.Tabs, {Btn = TabBtn, Page = Page})
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Page.Visible = false
            TweenService:Create(t.Btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(25, 25, 30),
                TextColor3 = Color3.fromRGB(150, 150, 150)
            }):Play()
        end
        Page.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(138, 43, 226),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)
    
    if #self.Tabs == 1 then
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    return Page
end

local function AddLabel(parent, text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.95, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(120, 120, 140)
    Label.Font = Enum.Font.Montserrat
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent
end

local function AddInput(parent, placeholder, defaultText, callback)
    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(0.95, 0, 0, 35)
    InputBox.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.PlaceholderText = placeholder
    InputBox.Text = defaultText
    InputBox.Font = Enum.Font.Montserrat
    InputBox.TextSize = 14
    InputBox.Parent = parent
    Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 6)
    
    InputBox.FocusLost:Connect(function() callback(InputBox.Text) end)
end

local function AddCycleButton(parent, prefix, list, startingIndex, callback)
    local currentIndex = startingIndex
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.95, 0, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
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
    Button.BackgroundColor3 = Color3.fromRGB(28, 28, 35) 
    Button.TextColor3 = Color3.fromRGB(180, 50, 50)
    Button.Text = text .. " [ OFF ]"
    Button.Font = Enum.Font.Montserrat
    Button.TextSize = 14
    Button.Parent = parent
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
    
    Button.MouseButton1Click:Connect(function()
        state = not state
        if state then
            TweenService:Create(Button, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(50, 200, 50)}):Play()
            Button.Text = text .. " [ ON ]"
        else
            TweenService:Create(Button, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(180, 50, 50)}):Play()
            Button.Text = text .. " [ OFF ]"
        end
        callback(state)
    end)
    return Button
end

-----------------------------------------
-- ПОСТРОЕНИЕ ИНТЕРФЕЙСА
-----------------------------------------
local Hub = UI.new("Made by selace")

-- 1. GAMEPLAY
local TabGameplay = Hub:CreateTab("Gameplay")
AddLabel(TabGameplay, "— Speed & Jump")
AddInput(TabGameplay, "WalkSpeed (Default: 16)", tostring(Config.Gameplay.WalkSpeed), function(val)
    local num = tonumber(val)
    if num then Config.Gameplay.WalkSpeed = num end
end)
AddToggle(TabGameplay, "Enable WalkSpeed", function(state) Config.Gameplay.SpeedEnabled = state end)

AddInput(TabGameplay, "JumpPower", tostring(Config.Gameplay.JumpPower), function(val)
    local num = tonumber(val)
    if num then Config.Gameplay.JumpPower = num end
end)
AddToggle(TabGameplay, "Enable Custom Jump", function(state) Config.Gameplay.JumpEnabled = state end)

AddLabel(TabGameplay, "— Tilts (Max 10000)")
AddInput(TabGameplay, "Tilt Power (0 - 10000)", tostring(Config.Gameplay.TiltPower), function(val)
    local num = tonumber(val)
    if num then Config.Gameplay.TiltPower = math.clamp(num, 0, 10000) end
end)
AddToggle(TabGameplay, "Run Tilts", function(state) Config.Gameplay.TiltEnabled = state end)

-- 2. MISC
local TabMisc = Hub:CreateTab("Misc")
AddLabel(TabMisc, "— Spoof Attributes")
AddCycleButton(TabMisc, "Physics", Config.Misc.PhysicsList, Config.Misc.CurrentPhysics, function(idx)
    Config.Misc.CurrentPhysics = idx
end)
AddCycleButton(TabMisc, "Technical", Config.Misc.TechList, Config.Misc.CurrentTech, function(idx)
    Config.Misc.CurrentTech = idx
end)
AddToggle(TabMisc, "Enable Attributes", function(state) Config.Misc.AttrEnabled = state end)

-- 3. VISUALS
local TabVisuals = Hub:CreateTab("Visuals")
AddLabel(TabVisuals, "— Environment")
AddToggle(TabVisuals, "FullBright", function(state)
    Config.Visuals.FullBright = state
    if not state then
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
    end
end)

AddLabel(TabVisuals, "— Time Settings")
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
AddLabel(TabSettings, "— Interface Control")

local isBinding = false
local BindBtn = Instance.new("TextButton")
BindBtn.Size = UDim2.new(0.95, 0, 0, 40)
BindBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
BindBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
BindBtn.Text = "Toggle Key: " .. Config.Settings.ToggleKey.Name
BindBtn.Font = Enum.Font.MontserratBold
BindBtn.TextSize = 14
BindBtn.Parent = TabSettings
Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 6)

BindBtn.MouseButton1Click:Connect(function()
    isBinding = true
    BindBtn.Text = "... Press Any Key ..."
    TweenService:Create(BindBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(138, 43, 226)}):Play()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.Settings.ToggleKey = input.KeyCode
        BindBtn.Text = "Toggle Key: " .. input.KeyCode.Name
        TweenService:Create(BindBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        isBinding = false
        return
    end
    
    -- Проверка на открытие/закрытие
    if input.KeyCode == Config.Settings.ToggleKey and not gameProcessed then
        Hub:ToggleUI()
    end
end)

-----------------------------------------
-- ЛОГИКА ИГРЫ
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
    
    -- Gameplay: Хуманоид
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

    -- Gameplay: Тильты
    if Config.Gameplay.TiltEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        local tilt = hrp:FindFirstChild("Tilt")
        if tilt then
            pcall(function() tilt.P = Config.Gameplay.TiltPower end)
        end
    end

    -- Misc: Атрибуты
    if Config.Misc.AttrEnabled then
        local data = player:FindFirstChild("Data")
        if data then
            data:SetAttribute("Technical", Config.Misc.TechList[Config.Misc.CurrentTech])
            data:SetAttribute("Physical", Config.Misc.PhysicsList[Config.Misc.CurrentPhysics])
        end
    end

    -- Visuals: Время суток
    if Config.Visuals.CustomTime then
        Lighting.ClockTime = Config.Visuals.TimeOfDay
    end

    -- Visuals: FullBright
    if Config.Visuals.FullBright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.GlobalShadows = false
    end
end)

-- ЗАПУСК АНИМАЦИИ ОТКРЫТИЯ
task.spawn(function()
    Hub:PlayStartupSequence()
end)
