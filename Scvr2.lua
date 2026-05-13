local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local DiscordLink = "https://discord.gg/9eYR7ecMu"

-----------------------------------------
-- НАСТРОЙКИ ЗНАЧЕНИЙ
-----------------------------------------
local Config = {
    -- (Здесь остались все старые настройки)
    Gameplay = { JumpPower = 25.5, JumpEnabled = false, WalkSpeed = 16, SpeedEnabled = false, TiltPower = 4000, TiltEnabled = false },
    Misc = { PhysicsList = {"Bounce", "Athletic", "Wide Reach", "Sprinter", "Solid form", "All Rounder"}, TechList = {"Backrow Blitz", "Mind Reader", "Unbreakable", "Wiper", "Stance", "Fast Approach"}, CurrentPhysics = 2, CurrentTech = 6, AttrEnabled = false },
    Visuals = { TimeOfDay = 14, CustomTime = false, FullBright = false },
    Settings = { ToggleKey = Enum.KeyCode.RightShift, UIOpen = false }
}

local OriginalLighting = { Ambient = Lighting.Ambient, GlobalShadows = Lighting.GlobalShadows, ClockTime = Lighting.ClockTime }

-----------------------------------------
-- ФУНКЦИЯ ПРОВЕРКИ КЛЮЧА И HWID
-----------------------------------------
local function VerifyKeyWithServer(key)
    -- Получаем HWID (Если инжектор поддерживает gethwid, берем его, иначе используем Roblox ClientId как запасной вариант)
    local hwid = "UNKNOWN_HWID"
    if gethwid then
        hwid = gethwid()
    else
        pcall(function() hwid = game:GetService("RbxAnalyticsService"):GetClientId() end)
    end

    --[[ 
        ТУТ ДОЛЖЕН БЫТЬ ЗАПРОС К ТВОЕМУ СЕРВЕРУ (Например, KeyAuth)
        Пример использования:
        local response = game:HttpGet("https://твой-сервер.com/api/verify?key=" .. key .. "&hwid=" .. hwid)
        if response == "valid" then return true end
    ]]
    
    -- ВРЕМЕННАЯ ЗАГЛУШКА (пока ты не подключил KeyAuth):
    -- Если ключ равен "selace123", то пропускает. Удали это, когда подключишь API.
    if key == "selace123" then
        return true, "Success!"
    end

    return false, "Invalid or Expired Key!"
end

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
    
    -- ЭКРАН ЗАГРУЗКИ
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

    -- ЭКРАН КЛЮЧА (KEY SYSTEM)
    self.KeyFrame = Instance.new("CanvasGroup")
    self.KeyFrame.Size = UDim2.new(0, 350, 0, 200)
    self.KeyFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
    self.KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    self.KeyFrame.BorderSizePixel = 0
    self.KeyFrame.GroupTransparency = 1
    self.KeyFrame.Visible = false
    self.KeyFrame.Parent = self.ScreenGui
    Instance.new("UICorner", self.KeyFrame).CornerRadius = UDim.new(0, 10)
    
    local KeyTitle = Instance.new("TextLabel", self.KeyFrame)
    KeyTitle.Size = UDim2.new(1, 0, 0, 40)
    KeyTitle.BackgroundTransparency = 1
    KeyTitle.Text = "Authentication"
    KeyTitle.TextColor3 = Color3.fromRGB(138, 43, 226)
    KeyTitle.Font = Enum.Font.MontserratBold
    KeyTitle.TextSize = 18

    self.KeyInput = Instance.new("TextBox", self.KeyFrame)
    self.KeyInput.Size = UDim2.new(0.9, 0, 0, 40)
    self.KeyInput.Position = UDim2.new(0.05, 0, 0, 50)
    self.KeyInput.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    self.KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.KeyInput.PlaceholderText = "Enter your key here..."
    self.KeyInput.Text = ""
    self.KeyInput.Font = Enum.Font.Montserrat
    self.KeyInput.TextSize = 14
    Instance.new("UICorner", self.KeyInput).CornerRadius = UDim.new(0, 6)

    self.VerifyBtn = Instance.new("TextButton", self.KeyFrame)
    self.VerifyBtn.Size = UDim2.new(0.42, 0, 0, 40)
    self.VerifyBtn.Position = UDim2.new(0.05, 0, 0, 100)
    self.VerifyBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    self.VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.VerifyBtn.Text = "Verify Key"
    self.VerifyBtn.Font = Enum.Font.MontserratBold
    self.VerifyBtn.TextSize = 14
    Instance.new("UICorner", self.VerifyBtn).CornerRadius = UDim.new(0, 6)

    self.DiscordBtn = Instance.new("TextButton", self.KeyFrame)
    self.DiscordBtn.Size = UDim2.new(0.42, 0, 0, 40)
    self.DiscordBtn.Position = UDim2.new(0.53, 0, 0, 100)
    self.DiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242) -- Цвет Discord
    self.DiscordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.DiscordBtn.Text = "Get Key (Discord)"
    self.DiscordBtn.Font = Enum.Font.MontserratBold
    self.DiscordBtn.TextSize = 13
    Instance.new("UICorner", self.DiscordBtn).CornerRadius = UDim.new(0, 6)

    self.StatusText = Instance.new("TextLabel", self.KeyFrame)
    self.StatusText.Size = UDim2.new(1, 0, 0, 30)
    self.StatusText.Position = UDim2.new(0, 0, 0, 150)
    self.StatusText.BackgroundTransparency = 1
    self.StatusText.Text = "Waiting for key..."
    self.StatusText.TextColor3 = Color3.fromRGB(150, 150, 150)
    self.StatusText.Font = Enum.Font.Montserrat
    self.StatusText.TextSize = 12

    -- ГЛАВНЫЙ ИНТЕРФЕЙС (Скрыт до ввода ключа)
    self.MainFrame = Instance.new("CanvasGroup")
    self.MainFrame.Size = UDim2.new(0, 420, 0, 500)
    self.MainFrame.Position = UDim2.new(0.5, -210, 0.5, -250)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.GroupTransparency = 1
    self.MainFrame.Visible = false
    self.MainFrame.Parent = self.ScreenGui
    Instance.new("UICorner", self.MainFrame).CornerRadius = UDim.new(0, 10)
    
    local DragFrame = Instance.new("Frame", self.MainFrame)
    DragFrame.Size = UDim2.new(1, 0, 0, 50)
    DragFrame.BackgroundTransparency = 1
    DragFrame.Active = true
    DragFrame.Draggable = true
    
    local Title = Instance.new("TextLabel", DragFrame)
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.MontserratBold
    Title.TextSize = 20
    
    self.TabContainer = Instance.new("Frame", self.MainFrame)
    self.TabContainer.Size = UDim2.new(1, -20, 0, 35)
    self.TabContainer.Position = UDim2.new(0, 10, 0, 50)
    self.TabContainer.BackgroundTransparency = 1
    
    local TabLayout = Instance.new("UIListLayout", self.TabContainer)
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.Padding = UDim.new(0, 6)
    
    self.PageContainer = Instance.new("Frame", self.MainFrame)
    self.PageContainer.Size = UDim2.new(1, -20, 1, -100)
    self.PageContainer.Position = UDim2.new(0, 10, 0, 90)
    self.PageContainer.BackgroundTransparency = 1

    -- ЛОГИКА КНОПОК КЛЮЧА
    self.DiscordBtn.MouseButton1Click:Connect(function()
        -- setclipboard - это функция инжекторов для копирования текста в буфер обмена
        if setclipboard then
            setclipboard(DiscordLink)
            self.StatusText.Text = "Discord link copied to clipboard!"
            self.StatusText.TextColor3 = Color3.fromRGB(50, 200, 50)
        else
            self.StatusText.Text = "Your exploit doesn't support clipboard copying."
            self.StatusText.TextColor3 = Color3.fromRGB(200, 50, 50)
        end
    end)

    self.VerifyBtn.MouseButton1Click:Connect(function()
        self.VerifyBtn.Text = "Checking..."
        local key = self.KeyInput.Text
        local isValid, msg = VerifyKeyWithServer(key)

        if isValid then
            self.StatusText.Text = "Key Verified! Loading Hub..."
            self.StatusText.TextColor3 = Color3.fromRGB(50, 200, 50)
            self.VerifyBtn.Text = "Success"
            task.wait(1)
            self:TransitionToMain()
        else
            self.StatusText.Text = msg or "Invalid Key!"
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
    
    task.wait(4)
    
    TweenService:Create(self.LoadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(self.LoadingFrame.UIStroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
    TweenService:Create(self.LoadingText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    
    task.wait(0.5)
    self.LoadingFrame:Destroy()
    
    -- Открываем систему ключей вместо главного хаба
    self.KeyFrame.Visible = true
    TweenService:Create(self.KeyFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        GroupTransparency = 0
    }):Play()
end

function UI:TransitionToMain()
    -- Закрываем окно ключа
    local closeKey = TweenService:Create(self.KeyFrame, TweenInfo.new(0.4), {GroupTransparency = 1})
    closeKey:Play()
    closeKey.Completed:Connect(function()
        self.KeyFrame:Destroy()
        
        -- Открываем основной хаб
        Config.Settings.UIOpen = true
        self.MainFrame.Visible = true
        TweenService:Create(self.MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            GroupTransparency = 0,
            Size = UDim2.new(0, 450, 0, 500)
        }):Play()
    end)
end

function UI:ToggleUI()
    if not self.KeyFrame or not self.KeyFrame.Parent then -- Можно открывать/закрывать только если ключ уже введен
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
                if not Config.Settings.UIOpen then self.MainFrame.Visible = false end
            end)
        end
    end
end

-- (Оставшиеся функции CreateTab, AddLabel, AddInput, AddToggle, AddCycleButton скопируй из прошлого сообщения, они остались абсолютно такими же)

-- [[ ВСТАВЬ СЮДА ФУНКЦИИ CreateTab, AddLabel И Т.Д. ИЗ ПРОШЛОГО КОДА ]]

-- [[ ПОСЛЕ НИХ ВСТАВЬ ВЕСЬ БЛОК "ПОСТРОЕНИЕ ИНТЕРФЕЙСА" И "ЛОГИКА ИГРЫ" ИЗ ПРОШЛОГО КОДА ]]

-- ЗАПУСК
task.spawn(function()
    Hub:PlayStartupSequence()
end)
