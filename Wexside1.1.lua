-- ROCKET MM2 ESP + SPEED + SPINBOT + PHONE GUI
-- CLIENT-SIDE EXECUTION

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- ======== НАСТРОЙКИ ========
local ESP_ENABLED = true
local SPEED_ENABLED = true
local SPINBOT_ENABLED = true
local SPEED_MULTIPLIER = 3.5
local SPIN_SPEED = 10

-- ======== СОЗДАНИЕ ТЕЛЕФОННОГО GUI ========
local playerGui = player:WaitForChild("PlayerGui")

-- Main ScreenGui
local PhoneGui = Instance.new("ScreenGui")
PhoneGui.Name = "ROCKET_PhoneGUI"
PhoneGui.ResetOnSpawn = false
PhoneGui.IgnoreGuiInset = true
PhoneGui.Parent = playerGui

-- КНОПКА ОТКРЫТИЯ ТЕЛЕФОНА (всегда видна)
local OpenButton = Instance.new("ImageButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 60, 0, 60)
OpenButton.Position = UDim2.new(0.02, 0, 0.85, 0) -- левый нижний угол
OpenButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenButton.Image = "rbxassetid://99200728861959" -- иконка телефона
OpenButton.ImageTransparency = 0.1
OpenButton.ZIndex = 100
OpenButton.Parent = PhoneGui

-- Рамка кнопки
local OpenStroke = Instance.new("UIStroke", OpenButton)
OpenStroke.Thickness = 3
OpenStroke.Color = Color3.fromRGB(0, 200, 255)
Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(1, 0)

-- ТЕЛЕФОН (основной фрейм) — скрыт по умолчанию
local PhoneFrame = Instance.new("Frame")
PhoneFrame.Name = "PhoneFrame"
PhoneFrame.Size = UDim2.new(0, 280, 0, 380)
PhoneFrame.Position = UDim2.new(0.5, -140, 0.5, -190)
PhoneFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
PhoneFrame.BorderSizePixel = 0
PhoneFrame.ClipsDescendants = true
PhoneFrame.Visible = false -- СКРЫТ ПО УМОЛЧАНИЮ
PhoneFrame.ZIndex = 50
PhoneFrame.Parent = PhoneGui

Instance.new("UICorner", PhoneFrame).CornerRadius = UDim.new(0, 24)
local PhoneStroke = Instance.new("UIStroke", PhoneFrame)
PhoneStroke.Thickness = 7
PhoneStroke.Color = Color3.fromRGB(35, 35, 35)

-- Экран телефона (внутренний)
local Screen = Instance.new("Frame")
Screen.Size = UDim2.new(1, -10, 1, -10)
Screen.Position = UDim2.new(0, 5, 0, 5)
Screen.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Screen.BorderSizePixel = 0
Screen.Parent = PhoneFrame
Instance.new("UICorner", Screen).CornerRadius = UDim.new(0, 20)

-- Фоновое изображение (по желанию)
local Background = Instance.new("ImageLabel")
Background.Size = UDim2.new(1, 0, 1, 0)
Background.BackgroundTransparency = 1
Background.Image = "rbxassetid://99200728861959"
Background.ImageTransparency = 0.3
Background.Parent = Screen
Background.ZIndex = 1

-- Затемнение
local Overlay = Instance.new("Frame", Screen)
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.new(0, 0, 0)
Overlay.BackgroundTransparency = 0.4
Overlay.ZIndex = 2

-- СТАТУС БАР
local Status = Instance.new("Frame", Screen)
Status.Size = UDim2.new(1, 0, 0, 28)
Status.BackgroundTransparency = 1
Status.ZIndex = 10

local TimeLabel = Instance.new("TextLabel", Status)
TimeLabel.Size = UDim2.new(0.5, 0, 1, 0)
TimeLabel.Position = UDim2.new(0, 12, 0, 0)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = os.date("%H:%M")
TimeLabel.TextColor3 = Color3.new(1, 1, 1)
TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
TimeLabel.Font = Enum.Font.GothamBold
TimeLabel.TextSize = 14
TimeLabel.ZIndex = 10

local Battery = Instance.new("TextLabel", Status)
Battery.Size = UDim2.new(0.3, 0, 1, 0)
Battery.Position = UDim2.new(0.7, 0, 0, 0)
Battery.BackgroundTransparency = 1
Battery.Text = "⚡ 87%"
Battery.TextColor3 = Color3.new(0, 1, 0)
Battery.TextXAlignment = Enum.TextXAlignment.Right
Battery.Font = Enum.Font.GothamBold
Battery.TextSize = 13
Battery.ZIndex = 10

-- ЗАГОЛОВОК
local TitleBar = Instance.new("Frame", Screen)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 28)
TitleBar.BackgroundTransparency = 1
TitleBar.ZIndex = 10

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "📱 ROCKET PANEL"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.ZIndex = 10

-- КНОПКА ЗАКРЫТИЯ (X)
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 3)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 0.2, 0.2)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 15

-- КОНТЕНТ (кнопки управления функциями)
local Content = Instance.new("ScrollingFrame", Screen)
Content.Size = UDim2.new(1, -16, 1, -100)
Content.Position = UDim2.new(0, 8, 0, 75)
Content.BackgroundTransparency = 1
Content.ZIndex = 5
Content.CanvasSize = UDim2.new(0, 0, 0, 320)
Content.ScrollBarThickness = 4

-- Функция создания кнопки-переключателя
local function createToggleButton(parent, text, color, defaultState, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 45 + 5)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.Text = text .. " [" .. (defaultState and "ON" or "OFF") .. "]"
    btn.TextColor3 = defaultState and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 10
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 1.5
    stroke.Color = color

    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. " [" .. (state and "ON" or "OFF") .. "]"
        btn.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
        callback(state)
    end)
    return btn
end

-- СОЗДАНИЕ КНОПОК
local btnY = 0

-- ESP Toggle
local espBtn = createToggleButton(Content, "ESP", Color3.fromRGB(255, 0, 100), ESP_ENABLED, function(val)
    ESP_ENABLED = val
    if not val then
        for _, v in pairs(espObjects) do v:Destroy() end
        espObjects = {}
    else
        updateESP()
    end
end)

-- Speed Toggle
local speedBtn = createToggleButton(Content, "Speed x" .. tostring(SPEED_MULTIPLIER), Color3.fromRGB(0, 200, 255), SPEED_ENABLED, function(val)
    SPEED_ENABLED = val
    setSpeed()
end)

-- SpinBot Toggle
local spinBtn = createToggleButton(Content, "SpinBot", Color3.fromRGB(200, 200, 0), SPINBOT_ENABLED, function(val)
    SPINBOT_ENABLED = val
    if not val then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then root.RotVelocity = Vector3.new(0, 0, 0) end
    end
end)

-- Кнопка "Сбросить персонажа" (полезно)
local resetBtn = Instance.new("TextButton", Content)
resetBtn.Size = UDim2.new(1, -10, 0, 40)
resetBtn.Position = UDim2.new(0, 5, 0, #Content:GetChildren() * 45 + 5)
resetBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
resetBtn.Text = "🔄 Reset Character"
resetBtn.TextColor3 = Color3.new(1, 1, 1)
resetBtn.TextScaled = true
resetBtn.Font = Enum.Font.GothamBold
resetBtn.ZIndex = 10
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 8)
resetBtn.MouseButton1Click:Connect(function()
    if player.Character then
        player.Character.Humanoid.Health = 0
    end
end)

-- ОБНОВЛЕНИЕ CanvasSize
Content.CanvasSize = UDim2.new(0, 0, 0, #Content:GetChildren() * 45 + 20)

-- ======== ЛОГИКА ОТКРЫТИЯ/ЗАКРЫТИЯ ========
local phoneVisible = false

OpenButton.MouseButton1Click:Connect(function()
    phoneVisible = not phoneVisible
    PhoneFrame.Visible = phoneVisible
    -- Анимация появления (опционально)
    if phoneVisible then
        PhoneFrame.Position = UDim2.new(0.5, -140, 0.5, -190)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    phoneVisible = false
    PhoneFrame.Visible = false
end)

-- ======== ESP (ОСТАЁТСЯ БЕЗ ИЗМЕНЕНИЙ) ========
local espObjects = {}
local function createESP(targetPlayer)
    if espObjects[targetPlayer] then return end
    local folder = Instance.new("Folder")
    folder.Name = "ESP_" .. targetPlayer.Name

    local billboard = Instance.new("BillboardGui", folder)
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Color3.new(1, 1, 1)

    local roleValue = targetPlayer:FindFirstChild("Role")
    local role = roleValue and roleValue.Value or "Innocent"
    local color
    if role == "Murderer" then color = Color3.new(1, 0, 0)
    elseif role == "Sheriff" then color = Color3.new(0, 0, 1)
    elseif role == "Hero" then color = Color3.new(0, 1, 0)
    else color = Color3.new(1, 1, 1) end

    label.Text = role .. " | " .. targetPlayer.Name
    label.TextColor3 = color

    local line = Instance.new("Frame", billboard)
    line.Size = UDim2.new(0, 2, 0, 30)
    line.BackgroundColor3 = color
    line.Position = UDim2.new(0.5, -1, -0.5, 0)

    folder.Parent = targetPlayer.Character or targetPlayer.CharacterAdded:Wait()
    espObjects[targetPlayer] = folder
end

local function updateESP()
    if not ESP_ENABLED then
        for _, v in pairs(espObjects) do v:Destroy() end
        espObjects = {}
        return
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            createESP(plr)
        end
    end
end

Players.PlayerAdded:Connect(updateESP)
Players.PlayerRemoving:Connect(function(plr)
    if espObjects[plr] then
        espObjects[plr]:Destroy()
        espObjects[plr] = nil
    end
end)
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(updateESP)
end)
updateESP()

-- ======== SPEED ========
local function setSpeed()
    if not SPEED_ENABLED then
        humanoid.WalkSpeed = 16
        return
    end
    humanoid.WalkSpeed = 16 * SPEED_MULTIPLIER
end

player.CharacterAdded:Connect(function(char)
    humanoid = char:WaitForChild("Humanoid")
    setSpeed()
end)

RunService.Heartbeat:Connect(function()
    if SPEED_ENABLED and humanoid then
        if humanoid.WalkSpeed ~= 16 * SPEED_MULTIPLIER then
            humanoid.WalkSpeed = 16 * SPEED_MULTIPLIER
        end
    end
end)

-- ======== SPINBOT ========
local function spinBot()
    if not SPINBOT_ENABLED then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        root.RotVelocity = Vector3.new(0, SPIN_SPEED * 1.5, 0)
    end
end

RunService.Heartbeat:Connect(function()
    if SPINBOT_ENABLED then
        spinBot()
    end
end)

-- ======== ГОРЯЧИЕ КЛАВИШИ (ДОПОЛНЕНЫ) ========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        ESP_ENABLED = not ESP_ENABLED
        if not ESP_ENABLED then
            for _, v in pairs(espObjects) do v:Destroy() end
            espObjects = {}
        else updateESP() end
        -- Обновляем кнопку в GUI (находим по тексту)
        for _, child in pairs(Content:GetChildren()) do
            if child:IsA("TextButton") and string.find(child.Text, "ESP") then
                local state = ESP_ENABLED
                child.Text = "ESP [" .. (state and "ON" or "OFF") .. "]"
                child.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
            end
        end
    end
    if input.KeyCode == Enum.KeyCode.F2 then
        SPEED_ENABLED = not SPEED_ENABLED
        setSpeed()
        for _, child in pairs(Content:GetChildren()) do
            if child:IsA("TextButton") and string.find(child.Text, "Speed") then
                local state = SPEED_ENABLED
                child.Text = "Speed x" .. tostring(SPEED_MULTIPLIER) .. " [" .. (state and "ON" or "OFF") .. "]"
                child.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
            end
        end
    end
    if input.KeyCode == Enum.KeyCode.F3 then
        SPINBOT_ENABLED = not SPINBOT_ENABLED
        if not SPINBOT_ENABLED then
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then root.RotVelocity = Vector3.new(0, 0, 0) end
        end
        for _, child in pairs(Content:GetChildren()) do
            if child:IsA("TextButton") and string.find(child.Text, "SpinBot") then
                local state = SPINBOT_ENABLED
                child.Text = "SpinBot [" .. (state and "ON" or "OFF") .. "]"
                child.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
            end
        end
    end
end)

print("ROCKET MM2 SCRIPT LOADED. F1=ESP, F2=Speed, F3=SpinBot")
print("📱 Нажми на иконку телефона в левом нижнем углу для открытия GUI")
