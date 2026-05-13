local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-----------------------------------------
-- НАСТРОЙКИ ЗНАЧЕНИЙ (Переменные)
-----------------------------------------
local Settings = {
    Jump = { Power = 25.5, Enabled = true },
    Speed = { Power = 16, Enabled = false },
    Tilt = { Power = 4000, Running = false },
    Attributes = {
        PhysicsList = {"Bounce", "Athletic", "Wide Reach", "Sprinter", "Solid form", "All Rounder"},
        TechList = {"Backrow Blitz", "Mind Reader", "Unbreakable", "Wiper", "Stance", "Fast Approach"},
        CurrentPhysics = 2,
        CurrentTech = 6,
        Running = false
    },
    Visuals = {
        FOV = 70,
        Fullbright = false
    }
}

-----------------------------------------
-- UI БИБЛИОТЕКА (OOP) С ВКЛАДКАМИ
-----------------------------------------
local UIHub = {}
UIHub.__index = UIHub

function UIHub.new(titleText)
    local self = setmetatable({}, UIHub)
    self.Tabs = {}
    self.CurrentTab = nil
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SelaceHub"
    self.ScreenGui.ResetOnSpawn = false
    pcall(function() self.ScreenGui.Parent = CoreGui end)
    if not self.ScreenGui.Parent then self.ScreenGui.Parent = player:WaitForChild("PlayerGui") end
    
    -- Главное окно
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 400, 0, 450)
    self.MainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Очень темный фон
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    self.MainFrame.Active = true
    self.MainFrame.Draggable = true
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = self.MainFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(45, 45, 45)
    Stroke.Thickness = 1.5
    Stroke.Parent = self.MainFrame
    
    -- Заголовок
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 18
    Title.Parent = self.MainFrame
    
    -- Контейнер для кнопок вкладок
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Size = UDim2.new(1, -20, 0, 35)
    self.TabContainer.Position = UDim2.new(0, 10, 0, 45)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.Parent = self.MainFrame
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.Padding = UDim.new(0, 10)
    TabListLayout.Parent = self.TabContainer
    
    -- Контейнер для страниц
    self.PageContainer = Instance.new("Frame")
    self.PageContainer.Size = UDim2.new(1, -20, 1, -95)
    self.PageContainer.Position = UDim2.new(0, 10, 0, 85)
    self.PageContainer.BackgroundTransparency = 1
    self.PageContainer.Parent = self.MainFrame

    return self
end

function UIHub:CreateTab(tabName)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(0, 110, 1, 0)
    TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabButton.Text = tabName
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 13
    TabButton.Parent = self.TabContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = TabButton
    
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 3
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Visible = false
    Page.Parent = self.PageContainer
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = Page
    
    -- Логика переключения вкладок
    TabButton.MouseButton1Click:Connect(function()
        for _, tabInfo in pairs(self.Tabs) do
            tabInfo.Page.Visible = false
            tabInfo.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            tabInfo.Button.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        Page.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    table.insert(self.Tabs, {Button = TabButton, Page = Page})
    
    -- Если это первая вкладка, делаем ее активной по умолчанию
    if #self.Tabs == 1 then
        Page.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    return Page
end

function UIHub:AddInput(page, placeholder, defaultText, callback)
    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(1, -10, 0, 38)
    InputBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.PlaceholderText = placeholder
    InputBox.Text = defaultText
    InputBox.Font = Enum.Font.GothamMedium
    InputBox.TextSize = 14
    InputBox.Parent = page
    
    Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", InputBox)
    stroke.Color = Color3.fromRGB(50, 50, 50)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    InputBox.FocusLost:Connect(function()
        callback(InputBox.Text)
    end)
end

function UIHub:AddToggle(page, text, callback)
    local state = false
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 38)
    Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Button.TextColor3 = Color3.fromRGB(255, 100, 100) -- Красный цвет текста при OFF
    Button.Text = text .. " : OFF"
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.Parent = page
    
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", Button)
    stroke.Color = Color3.fromRGB(50, 50, 50)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    Button.MouseButton1Click:Connect(function()
        state = not state
        if state then
            Button.TextColor3 = Color3.fromRGB(100, 255, 100) -- Зеленый цвет текста при ON
            Button.Text = text .. " : ON"
        else
            Button.TextColor3 = Color3.fromRGB(255, 100, 100)
            Button.Text = text .. " : OFF"
        end
        callback(state)
    end)
end

function UIHub:AddCycleButton(page, prefix, list, startingIndex, callback)
    local currentIndex = startingIndex
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 38)
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Text = prefix .. ": " .. list[currentIndex]
    Button.Font = Enum.Font.GothamMedium
    Button.TextSize = 14
    Button.Parent = page
    
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", Button)
    stroke.Color = Color3.fromRGB(60, 60, 60)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    Button.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #list then currentIndex = 1 end
        Button.Text = prefix .. ": " .. list[currentIndex]
        callback(currentIndex)
    end)
end

function UIHub:AddButton(page, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 38)
    Button.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    Button.TextColor3 = Color3.fromRGB(20, 20, 20)
    Button.Text = text
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.Parent = page
    
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
    
    Button.MouseButton1Click:Connect(callback)
end

-----------------------------------------
-- ПОСТРОЕНИЕ ИНТЕРФЕЙСА
-----------------------------------------
local Hub = UIHub.new("Made by selace")

-- ВКЛАДКИ
local TabGameplay = Hub:CreateTab("Геймплей")
local TabMisc = Hub:CreateTab("Миск")
local TabVisuals = Hub:CreateTab("Визуалс")

-- =====================================
-- ВКЛАДКА 1: ГЕЙМПЛЕЙ (Jump, Speed, Tilt)
-- =====================================
Hub:AddInput(TabGameplay, "Сила прыжка", tostring(Settings.Jump.Power), function(val)
    local num = tonumber(val)
    if num then Settings.Jump.Power = num end
end)

Hub:AddToggle(TabGameplay, "Включить Прыжок", function(state)
    Settings.Jump.Enabled = state
end)

Hub:AddInput(TabGameplay, "Скорость бега", tostring(Settings.Speed.Power), function(val)
    local num = tonumber(val)
    if num then Settings.Speed.Power = num end
end)

Hub:AddToggle(TabGameplay, "Включить Скорость", function(state)
    Settings.Speed.Enabled = state
end)

Hub:AddInput(TabGameplay, "Сила Тильта", tostring(Settings.Tilt.Power), function(val)
    local num = tonumber(val)
    if num then Settings.Tilt.Power = num end
end)

Hub:AddToggle(TabGameplay, "Включить Тильты", function(state)
    Settings.Tilt.Running = state
end)


-- =====================================
-- ВКЛАДКА 2: МИСК (Technicals & Physics)
-- =====================================
Hub:AddCycleButton(TabMisc, "Physics", Settings.Attributes.PhysicsList, Settings.Attributes.CurrentPhysics, function(idx)
    Settings.Attributes.CurrentPhysics = idx
end)

Hub:AddCycleButton(TabMisc, "Technical", Settings.Attributes.TechList, Settings.Attributes.CurrentTech, function(idx)
    Settings.Attributes.CurrentTech = idx
end)

Hub:AddToggle(TabMisc, "Run Attributes", function(state)
    Settings.Attributes.Running = state
end)


-- =====================================
-- ВКЛАДКА 3: ВИЗУАЛС (FOV, Fog, Extra)
-- =====================================
Hub:AddInput(TabVisuals, "FOV (Макс 200)", tostring(Settings.Visuals.FOV), function(val)
    local num = tonumber(val)
    if num then 
        Settings.Visuals.FOV = math.clamp(num, 1, 200) -- Ограничение до 200
        camera.FieldOfView = Settings.Visuals.FOV
    end
end)

Hub:AddButton(TabVisuals, "Убрать Туман", function()
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
end)

Hub:AddToggle(TabVisuals, "Fullbright (Без теней)", function(state)
    Settings.Visuals.Fullbright = state
    if state then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
        Lighting.ColorShift_Top = Color3.new(1, 1, 1)
    else
        Lighting.Ambient = Color3.fromRGB(0, 0, 0) -- Дефолтный сброс
    end
end)


-----------------------------------------
-- ЛОГИКА ИГРЫ (ОБНОВЛЕНИЕ)
-----------------------------------------
local function SetupCharacterHooks(character)
    local humanoid = character:WaitForChild("Humanoid")
    
    humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if Settings.Jump.Enabled and humanoid.JumpPower ~= 0 and humanoid.JumpPower ~= Settings.Jump.Power then
            humanoid.JumpPower = Settings.Jump.Power
        end
    end)
    
    humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if Settings.Speed.Enabled and humanoid.WalkSpeed ~= Settings.Speed.Power then
            humanoid.WalkSpeed = Settings.Speed.Power
        end
    end)
end

if player.Character then SetupCharacterHooks(player.Character) end
player.CharacterAdded:Connect(SetupCharacterHooks)

RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    
    -- Поддержание JumpPower
    if Settings.Jump.Enabled and humanoid and humanoid.JumpPower ~= 0 and humanoid.JumpPower ~= Settings.Jump.Power then
        humanoid.JumpPower = Settings.Jump.Power
    end
    
    -- Поддержание WalkSpeed
    if Settings.Speed.Enabled and humanoid and humanoid.WalkSpeed ~= Settings.Speed.Power then
        humanoid.WalkSpeed = Settings.Speed.Power
    end
    
    -- Тильты
    if Settings.Tilt.Running then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local tilt = hrp:FindFirstChild("Tilt")
            if tilt then
                pcall(function() tilt.P = Settings.Tilt.Power end)
            end
        end
    end
    
    -- Атрибуты
    if Settings.Attributes.Running then
        local data = player:FindFirstChild("Data")
        if data then
            data:SetAttribute("Technical", Settings.Attributes.TechList[Settings.Attributes.CurrentTech])
            data:SetAttribute("Physical", Settings.Attributes.PhysicsList[Settings.Attributes.CurrentPhysics])
        end
    end
    
    -- Поддержание Fullbright
    if Settings.Visuals.Fullbright then
        Lighting.Ambient = Color3.new(1, 1, 1)
    end
end)
