local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-----------------------------------------
-- НАСТРОЙКИ ЗНАЧЕНИЙ (Переменные)
-----------------------------------------
local JumpSettings = {
    Power = 25.5,
    Enabled = true -- Прыжок работает всегда по твоей логике, но можно выключать
}

local AttributeSettings = {
    PhysicsList = {"Bounce", "Athletic", "Wide Reach", "Sprinter", "Solid form", "All Rounder"},
    TechList = {"Backrow Blitz", "Mind Reader", "Unbreakable", "Wiper", "Stance", "Fast Approach"},
    CurrentPhysicsIndex = 2, -- Athletic
    CurrentTechIndex = 6, -- Fast Approach
    Running = false
}

local TiltSettings = {
    Power = 4000,
    Running = false
}

-----------------------------------------
-- UI БИБЛИОТЕКА (OOP)
-----------------------------------------
local UIHub = {}
UIHub.__index = UIHub

function UIHub.new(titleText)
    local self = setmetatable({}, UIHub)
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "MinimalistControlHub"
    self.ScreenGui.ResetOnSpawn = false
    
    local success = pcall(function() self.ScreenGui.Parent = CoreGui end)
    if not success then self.ScreenGui.Parent = player:WaitForChild("PlayerGui") end
    
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 350, 0, 500)
    self.MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    self.MainFrame.Active = true
    self.MainFrame.Draggable = true -- Можно перетаскивать по экрану
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = self.MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.Parent = self.MainFrame
    
    -- Контейнер с прокруткой для элементов
    self.Container = Instance.new("ScrollingFrame")
    self.Container.Size = UDim2.new(1, 0, 1, -50)
    self.Container.Position = UDim2.new(0, 0, 0, 45)
    self.Container.BackgroundTransparency = 1
    self.Container.ScrollBarThickness = 4
    self.Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.Container.Parent = self.MainFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = self.Container
    
    return self
end

function UIHub:AddLabel(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.9, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = self.Container
end

function UIHub:AddInput(placeholder, defaultText, callback)
    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(0.9, 0, 0, 35)
    InputBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.PlaceholderText = placeholder
    InputBox.Text = defaultText
    InputBox.Font = Enum.Font.Gotham
    InputBox.TextSize = 14
    InputBox.Parent = self.Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = InputBox
    
    InputBox.FocusLost:Connect(function(enterPressed)
        callback(InputBox.Text)
    end)
end

function UIHub:AddCycleButton(prefix, list, startingIndex, callback)
    local currentIndex = startingIndex
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.9, 0, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Text = prefix .. ": " .. list[currentIndex]
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.Parent = self.Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #list then currentIndex = 1 end
        Button.Text = prefix .. ": " .. list[currentIndex]
        callback(currentIndex)
    end)
end

function UIHub:AddToggle(text, callback)
    local state = false
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.9, 0, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(180, 50, 50) -- Красный по умолчанию (Выкл)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Text = text .. " [OFF]"
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.Parent = self.Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        state = not state
        if state then
            Button.BackgroundColor3 = Color3.fromRGB(50, 180, 50) -- Зеленый (Вкл)
            Button.Text = text .. " [ON]"
        else
            Button.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
            Button.Text = text .. " [OFF]"
        end
        callback(state)
    end)
end

-----------------------------------------
-- ЛОГИКА ИГРЫ (Функции)
-----------------------------------------

-- 1. ЛОГИКА ПРЫЖКА
local function SetupJumpLock(character)
    local humanoid = character:WaitForChild("Humanoid")
    
    humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if JumpSettings.Enabled and humanoid.JumpPower ~= 0 and humanoid.JumpPower ~= JumpSettings.Power then
            humanoid.JumpPower = JumpSettings.Power
        end
    end)
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not JumpSettings.Enabled then return end
        if humanoid.Parent then
            if humanoid.JumpPower ~= 0 and humanoid.JumpPower ~= JumpSettings.Power then
                humanoid.JumpPower = JumpSettings.Power
            end
        else
            connection:Disconnect()
        end
    end)
end

if player.Character then SetupJumpLock(player.Character) end
player.CharacterAdded:Connect(SetupJumpLock)

-- 2. ЛОГИКА АТРИБУТОВ (Техника и Физика)
RunService.Heartbeat:Connect(function()
    if AttributeSettings.Running then
        local data = player:FindFirstChild("Data")
        if data then
            data:SetAttribute("Technical", AttributeSettings.TechList[AttributeSettings.CurrentTechIndex])
            data:SetAttribute("Physical", AttributeSettings.PhysicsList[AttributeSettings.CurrentPhysicsIndex])
        end
    end
end)

-- 3. ЛОГИКА ТИЛЬТОВ
RunService.Heartbeat:Connect(function()
    if TiltSettings.Running then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local tilt = char.HumanoidRootPart:FindFirstChild("Tilt")
            if tilt and tilt:IsA("AlignOrientation") or tilt:IsA("BodyPosition") or tilt.ClassName:match("Body") then
                -- Учитываем, что Tilt может быть разным типом BodyMover, просто меняем P
                pcall(function()
                    tilt.P = TiltSettings.Power
                end)
            end
        end
    end
end)

-----------------------------------------
-- ПОСТРОЕНИЕ ИНТЕРФЕЙСА
-----------------------------------------
local Hub = UIHub.new("Script Control Panel")

-- РАЗДЕЛ: ПРЫЖОК
Hub:AddLabel("--- JUMP SETTINGS ---")
Hub:AddInput("Установите силу прыжка", tostring(JumpSettings.Power), function(val)
    local num = tonumber(val)
    if num then
        JumpSettings.Power = num
        -- Сразу применяем к текущему персонажу, если он жив
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local hum = player.Character.Humanoid
            if hum.JumpPower ~= 0 then hum.JumpPower = num end
        end
    end
end)

-- РАЗДЕЛ: АТРИБУТЫ (Физика и Техника)
Hub:AddLabel("--- PHYSICS & TECHNICALS ---")
Hub:AddCycleButton("Physics", AttributeSettings.PhysicsList, AttributeSettings.CurrentPhysicsIndex, function(newIndex)
    AttributeSettings.CurrentPhysicsIndex = newIndex
end)

Hub:AddCycleButton("Technical", AttributeSettings.TechList, AttributeSettings.CurrentTechIndex, function(newIndex)
    AttributeSettings.CurrentTechIndex = newIndex
end)

Hub:AddToggle("Run Attributes", function(state)
    AttributeSettings.Running = state
end)

-- РАЗДЕЛ: ТИЛЬТЫ
Hub:AddLabel("--- TILT SETTINGS ---")
Hub:AddInput("Tilt Power (2000-4500)", tostring(TiltSettings.Power), function(val)
    local num = tonumber(val)
    if num then
        TiltSettings.Power = num
    end
end)

Hub:AddToggle("Run Tilts", function(state)
    TiltSettings.Running = state
end)
