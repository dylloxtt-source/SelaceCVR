local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-----------------------------------------
-- НАСТРОЙКИ ЗНАЧЕНИЙ
-----------------------------------------
local Settings = {
    Jump = { Power = 25.5, Enabled = false },
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
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SelaceHub"
    self.ScreenGui.ResetOnSpawn = false
    pcall(function() self.ScreenGui.Parent = CoreGui end)
    if not self.ScreenGui.Parent then self.ScreenGui.Parent = player:WaitForChild("PlayerGui") end
    
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 420, 0, 480)
    self.MainFrame.Position = UDim2.new(0.5, -210, 0.5, -240)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Active = true
    self.MainFrame.Draggable = true
    self.MainFrame.Parent = self.ScreenGui
    
    Instance.new("UICorner", self.MainFrame).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", self.MainFrame)
    Stroke.Color = Color3.fromRGB(50, 50, 50)
    Stroke.Thickness = 1.5
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.LilitaOne -- Уникальный шрифт для заголовка
    Title.TextSize = 22
    Title.Parent = self.MainFrame
    
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Size = UDim2.new(1, -20, 0, 35)
    self.TabContainer.Position = UDim2.new(0, 10, 0, 45)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.Parent = self.MainFrame
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.Padding = UDim.new(0, 8)
    TabListLayout.Parent = self.TabContainer
    
    self.PageContainer = Instance.new("Frame")
    self.PageContainer.Size = UDim2.new(1, -20, 1, -95)
    self.PageContainer.Position = UDim2.new(0, 10, 0, 85)
    self.PageContainer.BackgroundTransparency = 1
    self.PageContainer.Parent = self.MainFrame

    return self
end

function UIHub:CreateTab(tabName)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(0, 120, 1, 0)
    TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabButton.Text = tabName
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 13
    TabButton.Parent = self.TabContainer
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)
    
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 3
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Visible = false
    Page.Parent = self.PageContainer
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.Parent = Page
    
    TabButton.MouseButton1Click:Connect(function()
        for _, tabInfo in pairs(self.Tabs) do
            tabInfo.Page.Visible = false
            tabInfo.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            tabInfo.Button.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        Page.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    table.insert(self.Tabs, {Button = TabButton, Page = Page})
    if #self.Tabs == 1 then
        Page.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
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
    stroke.Color = Color3.fromRGB(60, 60, 60)
    
    InputBox.FocusLost:Connect(function() callback(InputBox.Text) end)
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
    
    Button.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #list then currentIndex = 1 end
        Button.Text = prefix .. ": " .. list[currentIndex]
        callback(currentIndex)
    end)
end

function UIHub:AddDualButton(page, callbackRun, callbackOff)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 38)
    Frame.BackgroundTransparency = 1
    Frame.Parent = page

    local BtnRun = Instance.new("TextButton")
    BtnRun.Size = UDim2.new(0.5, -5, 1, 0)
    BtnRun.Position = UDim2.new(0, 0, 0, 0)
    BtnRun.BackgroundColor3 = Color3.fromRGB(40, 120, 60)
    BtnRun.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnRun.Text = "RUN"
    BtnRun.Font = Enum.Font.GothamBold
    BtnRun.TextSize = 14
    BtnRun.Parent = Frame
    Instance.new("UICorner", BtnRun).CornerRadius = UDim.new(0, 6)

    local BtnOff = Instance.new("TextButton")
    BtnOff.Size = UDim2.new(0.5, -5, 1, 0)
    BtnOff.Position = UDim2.new(0.5, 5, 0, 0)
    BtnOff.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    BtnOff.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnOff.Text = "OFF"
    BtnOff.Font = Enum.Font.GothamBold
    BtnOff.TextSize = 14
    BtnOff.Parent = Frame
    Instance.new("UICorner", BtnOff).CornerRadius = UDim.new(0, 6)

    BtnRun.MouseButton1Click:Connect(callbackRun)
    BtnOff.MouseButton1Click:Connect(callbackOff)
end

-----------------------------------------
-- ПОСТРОЕНИЕ ИНТЕРФЕЙСА
-----------------------------------------
local Hub = UIHub.new("Made by selace")

local TabGameplay = Hub:CreateTab("Геймплей")
local TabMisc = Hub:CreateTab("Миск")
local TabVisuals = Hub:CreateTab("Визуалс")

-- =====================================
-- ВКЛАДКА 1: ГЕЙМПЛЕЙ
-- =====================================
Hub:AddInput(TabGameplay, "Сила прыжка", tostring(Settings.Jump.Power), function(val)
    local num = tonumber(val)
    if num then Settings.Jump.Power = num end
end)
Hub:AddDualButton(TabGameplay, 
    function() Settings.Jump.Enabled = true end, 
    function() Settings.Jump.Enabled = false end -- Просто отключаем
)

Hub:AddInput(TabGameplay, "Скорость бега", tostring(Settings.Speed.Power), function(val)
    local num = tonumber(val)
    if num then Settings.Speed.Power = num end
end)
Hub:AddDualButton(TabGameplay, 
    function() Settings.Speed.Enabled = true end, 
    function() Settings.Speed.Enabled = false end -- Просто отключаем
)

Hub:AddInput(TabGameplay, "Сила Тильта", tostring(Settings.Tilt.Power), function(val)
    local num = tonumber(val)
    if num then Settings.Tilt.Power = num end
end)
Hub:AddDualButton(TabGameplay, 
    function() Settings.Tilt.Running = true end, 
    function() Settings.Tilt.Running = false end
)

-- =====================================
-- ВКЛАДКА 2: МИСК
-- =====================================
Hub:AddCycleButton(TabMisc, "Physics", Settings.Attributes.PhysicsList, Settings.Attributes.CurrentPhysics, function(idx)
    Settings.Attributes.CurrentPhysics = idx
end)
Hub:AddCycleButton(TabMisc, "Technical", Settings.Attributes.TechList, Settings.Attributes.CurrentTech, function(idx)
    Settings.Attributes.CurrentTech = idx
end)
Hub:AddDualButton(TabMisc, 
    function() Settings.Attributes.Running = true end, 
    function() Settings.Attributes.Running = false end
)

-- =====================================
-- ВКЛАДКА 3: ВИЗУАЛС
-- =====================================
Hub:AddInput(TabVisuals, "FOV (Макс 200)", tostring(Settings.Visuals.FOV), function(val)
    local num = tonumber(val)
    if num then 
        Settings.Visuals.FOV = math.clamp(num, 1, 200)
        camera.FieldOfView = Settings.Visuals.FOV
    end
end)

Hub:AddInput(TabVisuals, "Дальность Тумана (FogEnd)", tostring(Lighting.FogEnd), function(val)
    local num = tonumber(val)
    if num then Lighting.FogEnd = num end
end)

Hub:AddDualButton(TabVisuals, 
    function() 
        Settings.Visuals.Fullbright = true
        Lighting.Ambient = Color3.new(1, 1, 1)
    end, 
    function() 
        Settings.Visuals.Fullbright = false
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
    end
)

-----------------------------------------
-- ЛОГИКА ИГРЫ (Синхронизация)
-----------------------------------------
local function SetupCharacterHooks(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    
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
    
    if Settings.Jump.Enabled and humanoid and humanoid.Parent then
        if humanoid.JumpPower ~= 0 and humanoid.JumpPower ~= Settings.Jump.Power then
            humanoid.JumpPower = Settings.Jump.Power
        end
    end
    
    if Settings.Speed.Enabled and humanoid and humanoid.Parent then
        if humanoid.WalkSpeed ~= Settings.Speed.Power then
            humanoid.WalkSpeed = Settings.Speed.Power
        end
    end
    
    if Settings.Tilt.Running then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local tilt = hrp:FindFirstChild("Tilt")
            if tilt then
                pcall(function() tilt.P = Settings.Tilt.Power end)
            end
        end
    end
    
    if Settings.Attributes.Running then
        local data = player:FindFirstChild("Data")
        if data then
            data:SetAttribute("Technical", Settings.Attributes.TechList[Settings.Attributes.CurrentTech])
            data:SetAttribute("Physical", Settings.Attributes.PhysicsList[Settings.Attributes.CurrentPhysics])
        end
    end
    
    if Settings.Visuals.Fullbright then
        Lighting.Ambient = Color3.new(1, 1, 1)
    end
end)
