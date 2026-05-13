local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
task.wait(0.2) -- Задержка для стабильности

-----------------------------------------
-- НАСТРОЙКИ
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
-- UI СБОРКА
-----------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SelaceMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 400, 0, 450)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "MADE BY SELACE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame

-- Контейнер для вкладок
local TabButtons = Instance.new("Frame")
TabButtons.Size = UDim2.new(1, 0, 0, 40)
TabButtons.Position = UDim2.new(0, 0, 0, 50)
TabButtons.BackgroundTransparency = 1
TabButtons.Parent = MainFrame

local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -20, 1, -110)
PageContainer.Position = UDim2.new(0, 10, 0, 100)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = MainFrame

local Pages = {}
local function CreatePage(name, order)
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.ScrollBarThickness = 2
    Page.Visible = (order == 1)
    Page.Parent = PageContainer
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 10)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.Parent = Page
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.3, 0, 1, 0)
    Btn.Position = UDim2.new((order-1)*0.33, 0, 0, 0)
    Btn.BackgroundColor3 = (order == 1) and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(40, 40, 40)
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = TabButtons
    Instance.new("UICorner", Btn)
    
    Btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Page.Visible = false p.Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) end
        Page.Visible = true
        Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    
    Pages[name] = {Page = Page, Btn = Btn}
    return Page
end

local P_Gameplay = CreatePage("Gameplay", 1)
local P_Misc = CreatePage("Misc", 2)
local P_Visuals = CreatePage("Visuals", 3)

-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
local function AddInput(page, text, callback)
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -10, 0, 35)
    Box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Box.PlaceholderText = text
    Box.Text = ""
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.Gotham
    Box.Parent = page
    Instance.new("UICorner", Box)
    Box.FocusLost:Connect(function() callback(Box.Text) end)
end

local function AddDual(page, run, off)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 35)
    f.BackgroundTransparency = 1
    f.Parent = page
    local r = Instance.new("TextButton", f)
    r.Size = UDim2.new(0.48, 0, 1, 0)
    r.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    r.Text = "RUN"
    r.TextColor3 = Color3.fromRGB(255, 255, 255)
    r.Parent = f
    Instance.new("UICorner", r)
    local o = Instance.new("TextButton", f)
    o.Size = UDim2.new(0.48, 0, 1, 0)
    o.Position = UDim2.new(0.52, 0, 0, 0)
    o.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    o.Text = "OFF"
    o.TextColor3 = Color3.fromRGB(255, 255, 255)
    o.Parent = f
    Instance.new("UICorner", o)
    r.MouseButton1Click:Connect(run)
    o.MouseButton1Click:Connect(off)
end

-----------------------------------------
-- КОНТЕНТ
-----------------------------------------
-- Gameplay
AddInput(P_Gameplay, "Jump Power", function(v) Settings.Jump.Power = tonumber(v) or 25.5 end)
AddDual(P_Gameplay, function() Settings.Jump.Enabled = true end, function() Settings.Jump.Enabled = false end)
AddInput(P_Gameplay, "Speed", function(v) Settings.Speed.Power = tonumber(v) or 16 end)
AddDual(P_Gameplay, function() Settings.Speed.Enabled = true end, function() Settings.Speed.Enabled = false end)
AddInput(P_Gameplay, "Tilt P", function(v) Settings.Tilt.Power = tonumber(v) or 4000 end)
AddDual(P_Gameplay, function() Settings.Tilt.Running = true end, function() Settings.Tilt.Running = false end)

-- Misc
local PhysBtn = Instance.new("TextButton", P_Misc)
PhysBtn.Size = UDim2.new(1, -10, 0, 35)
PhysBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
PhysBtn.Text = "Physics: Athletic"
PhysBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", PhysBtn)
PhysBtn.MouseButton1Click:Connect(function()
    Settings.Attributes.CurrentPhysics = (Settings.Attributes.CurrentPhysics % #Settings.Attributes.PhysicsList) + 1
    PhysBtn.Text = "Physics: " .. Settings.Attributes.PhysicsList[Settings.Attributes.CurrentPhysics]
end)

local TechBtn = Instance.new("TextButton", P_Misc)
TechBtn.Size = UDim2.new(1, -10, 0, 35)
TechBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TechBtn.Text = "Tech: Fast Approach"
TechBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", TechBtn)
TechBtn.MouseButton1Click:Connect(function()
    Settings.Attributes.CurrentTech = (Settings.Attributes.CurrentTech % #Settings.Attributes.TechList) + 1
    TechBtn.Text = "Tech: " .. Settings.Attributes.TechList[Settings.Attributes.CurrentTech]
end)
AddDual(P_Misc, function() Settings.Attributes.Running = true end, function() Settings.Attributes.Running = false end)

-- Visuals
AddInput(P_Visuals, "FOV (Max 200)", function(v) 
    local n = tonumber(v)
    if n then 
        Settings.Visuals.FOV = math.clamp(n, 1, 200)
        local c = workspace.CurrentCamera
        if c then c.FieldOfView = Settings.Visuals.FOV end
    end
end)
AddInput(P_Visuals, "Fog End", function(v) Lighting.FogEnd = tonumber(v) or 100000 end)
AddDual(P_Visuals, function() Settings.Visuals.Fullbright = true end, function() Settings.Visuals.Fullbright = false Lighting.Ambient = Color3.new(0,0,0) end)

-----------------------------------------
-- ЦИКЛЫ
-----------------------------------------
RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    
    if Settings.Jump.Enabled and hum then
        if hum.JumpPower ~= 0 and hum.JumpPower ~= Settings.Jump.Power then
            hum.JumpPower = Settings.Jump.Power
        end
    end
    
    if Settings.Speed.Enabled and hum then
        if hum.WalkSpeed ~= Settings.Speed.Power then
            hum.WalkSpeed = Settings.Speed.Power
        end
    end
    
    if Settings.Tilt.Running then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:FindFirstChild("Tilt") then
            pcall(function() hrp.Tilt.P = Settings.Tilt.Power end)
        end
    end
    
    if Settings.Attributes.Running then
        local d = player:FindFirstChild("Data")
        if d then
            d:SetAttribute("Technical", Settings.Attributes.TechList[Settings.Attributes.CurrentTech])
            d:SetAttribute("Physical", Settings.Attributes.PhysicsList[Settings.Attributes.CurrentPhysics])
        end
    end
    
    if Settings.Visuals.Fullbright then Lighting.Ambient = Color3.new(1,1,1) end
end)
