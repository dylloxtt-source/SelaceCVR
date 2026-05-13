-- [[ SELACE HUB: ANIME EDITION ]] --

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local DiscordLink = "https://discord.gg/9eYR7ecMu"

-----------------------------------------
-- УТИЛИТЫ АНИМАЦИИ
-----------------------------------------
local function CreateTween(obj, info, prop)
    local t = TweenService:Create(obj, TweenInfo.new(unpack(info)), prop)
    t:Play()
    return t
end

-----------------------------------------
-- UI ENGINE
-----------------------------------------
local UI = {}
UI.__index = UI

function UI.new()
    local self = setmetatable({}, UI)
    
    self.ScreenGui = Instance.new("ScreenGui", CoreGui)
    self.ScreenGui.Name = "SelaceAnimeHub"

    -- ОКНО АВТОРИЗАЦИИ (KEY SYSTEM)
    self.KeyFrame = Instance.new("CanvasGroup", self.ScreenGui)
    self.KeyFrame.Size = UDim2.new(0, 400, 0, 280)
    self.KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -140)
    self.KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    self.KeyFrame.BorderSizePixel = 0
    Instance.new("UICorner", self.KeyFrame).CornerRadius = UDim.new(0, 15)

    -- Аниме фон (Прозрачность 0.4 для читаемости)
    local BgImage = Instance.new("ImageLabel", self.KeyFrame)
    BgImage.Size = UDim2.new(1, 0, 1, 0)
    BgImage.Image = "rbxassetid://12502692237" -- ID аниме тян (можешь заменить)
    BgImage.ScaleType = Enum.ScaleType.Crop
    BgImage.ImageTransparency = 0.6
    BgImage.BackgroundTransparency = 1

    -- Свечение границ
    local Stroke = Instance.new("UIStroke", self.KeyFrame)
    Stroke.Thickness = 2
    Stroke.Color = Color3.fromRGB(138, 43, 226)
    Stroke.Transparency = 0.2

    local Title = Instance.new("TextLabel", self.KeyFrame)
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.Text = "Selace Hub"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.MontserratBold
    Title.TextSize = 28
    Title.BackgroundTransparency = 1
    
    -- Поле ввода ключа
    self.KeyInput = Instance.new("TextBox", self.KeyFrame)
    self.KeyInput.Size = UDim2.new(0.8, 0, 0, 40)
    self.KeyInput.Position = UDim2.new(0.1, 0, 0.25, 0)
    self.KeyInput.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    self.KeyInput.PlaceholderText = "Paste your key here..."
    self.KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.KeyInput.Font = Enum.Font.Montserrat
    Instance.new("UICorner", self.KeyInput).CornerRadius = UDim.new(0, 8)

    -- КНОПКИ
    local function CreateButton(name, pos, color)
        local btn = Instance.new("TextButton", self.KeyFrame)
        btn.Size = UDim2.new(0.8, 0, 0, 35)
        btn.Position = pos
        btn.BackgroundColor3 = color
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.MontserratBold
        btn.TextSize = 14
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        -- Эффект при наведении
        btn.MouseEnter:Connect(function()
            CreateTween(btn, {0.3}, {BackgroundColor3 = color:Lerp(Color3.new(1,1,1), 0.2)})
        end)
        btn.MouseLeave:Connect(function()
            CreateTween(btn, {0.3}, {BackgroundColor3 = color})
        end)
        
        return btn
    end

    self.GetHwidBtn = CreateButton("Get HWID", UDim2.new(0.1, 0, 0.45, 0), Color3.fromRGB(40, 40, 50))
    self.GetKeyBtn = CreateButton("Get Key (Discord)", UDim2.new(0.1, 0, 0.6, 0), Color3.fromRGB(88, 101, 242))
    self.EnterKeyBtn = CreateButton("Enter Key", UDim2.new(0.1, 0, 0.75, 0), Color3.fromRGB(138, 43, 226))

    -- ЛОГИКА КНОПОК АВТОРИЗАЦИИ
    self.GetHwidBtn.MouseButton1Click:Connect(function()
        local hwid = gethwid and gethwid() or game:GetService("RbxAnalyticsService"):GetClientId()
        setclipboard(hwid)
        self.GetHwidBtn.Text = "HWID Copied!"
        task.wait(2)
        self.GetHwidBtn.Text = "Get HWID"
    end)

    self.GetKeyBtn.MouseButton1Click:Connect(function()
        setclipboard(DiscordLink)
        self.GetKeyBtn.Text = "Link Copied to Clipboard!"
        task.wait(2)
        self.GetKeyBtn.Text = "Get Key (Discord)"
    end)

    self.EnterKeyBtn.MouseButton1Click:Connect(function()
        -- Тут твоя функция проверки VerifyKeyWithServer(self.KeyInput.Text)
        -- Если успешно:
        self:Transition()
    end)

    return self
end

function UI:Transition()
    -- Плавное исчезновение
    CreateTween(self.KeyFrame, {0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In}, {GroupTransparency = 1, Size = UDim2.new(0, 350, 0, 230)})
    task.wait(0.6)
    self.KeyFrame:Destroy()
    -- Тут вызываешь создание основного меню (MainFrame)
    print("Welcome to Selace Hub!")
end

-----------------------------------------
-- ЗАПУСК
-----------------------------------------
local App = UI.new()

-- Небольшое украшение: плавание окна (Floating effect)
task.spawn(function()
    while task.wait() do
        local yOffset = math.sin(tick() * 2) * 5
        App.KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -140 + yOffset)
    end
end)
