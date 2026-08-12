-- ============================================================
-- NEVERLOSE STYLE GUI - MURDER MYSTERY 2
-- ROCKET WAY / 2026
-- Стиль: CS:GO Neverlose (тёмный, неон, строгий)
-- Функции: ESP, SPEED, SPINBOT, AIMBOT (опционально)
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- ======== НАСТРОЙКИ ========
local ESP_ENABLED = true
local SPEED_ENABLED = true
local SPINBOT_ENABLED = true
local SPEED_MULTIPLIER = 3.5
local SPIN_SPEED = 10

-- ======== ГЛАВНОЕ GUI ========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Neverlose_Menu"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- ======== ОСНОВНАЯ ПАНЕЛЬ (стиль Neverlose) ========
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainPanel"
mainFrame.Size = UDim2.new(0, 380, 0, 520)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.ClipsDescendants = false
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Тень
local shadow = Instance.new("ImageLabel", mainFrame)
shadow.Size = UDim2.new(1.05, 0, 1.05, 0)
shadow.Position = UDim2.new(-0.025, 0, -0.025, 0)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.new(0, 0, 0)
shadow.ImageTransparency = 0.7
shadow.ZIndex = 0

-- Рамка с неоновой подсветкой
local border = Instance.new("Frame", mainFrame)
border.Size = UDim2.new(1, 0, 1, 0)
border.BackgroundTransparency = 1
border.ZIndex = 1
local uiStroke = Instance.new("UIStroke", border)
uiStroke.Thickness = 2
uiStroke.Color = Color3.fromRGB(0, 180, 255)
uiStroke.Transparency = 0.3

-- Заголовок (Neverlose стиль)
local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
header.BorderSizePixel = 0
header.ZIndex = 2

local headerLine = Instance.new("Frame", header)
headerLine.Size = UDim2.new(1, 0, 0, 2)
headerLine.Position = UDim2.new(0, 0, 1, 0)
headerLine.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
headerLine.BorderSizePixel = 0

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0.02, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "NEVERLOSE // MM2"
title.TextColor3 = Color3.fromRGB(0, 180, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.ZIndex = 3

local version = Instance.new("TextLabel", header)
version.Size = UDim2.new(0.3, 0, 1, 0)
version.Position = UDim2.new(0.68, 0, 0, 0)
version.BackgroundTransparency = 1
version.Text = "v1.0 | ROCKET"
version.TextColor3 = Color3.fromRGB(100, 100, 120)
version.TextXAlignment = Enum.TextXAlignment.Right
version.Font = Enum.Font.Gotham
version.TextSize = 11
version.ZIndex = 3

-- Кнопка закрытия (X)
local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.ZIndex = 3
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- ======== ВКЛАДКИ (TABS) ========
local tabContainer = Instance.new("Frame", mainFrame)
tabContainer.Size = UDim2.new(1, 0, 0, 32)
tabContainer.Position = UDim2.new(0, 0, 0, 45)
tabContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
tabContainer.BorderSizePixel = 0
tabContainer.ZIndex = 2

local tabs = {"AIM", "VISUALS", "MISC"}
local selectedTab = "AIM"

local tabButtons = {}
for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton", tabContainer)
    btn.Size = UDim2.new(0.333, -1, 1, 0)
    btn.Position = UDim2.new((i-1) * 0.333, 0.5, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = i == 1 and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(120, 120, 140)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 3
    btn.Name = name
    tabButtons[name] = btn
    
    local line = Instance.new("Frame", btn)
    line.Size = UDim2.new(0.5, 0, 0, 2)
    line.Position = UDim2.new(0.25, 0, 1, 0)
    line.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    line.Visible = (i == 1)
    line.Name = "Line"
    btn.Line = line
    
    btn.MouseButton1Click:Connect(function()
        for _, b in pairs(tabButtons) do
            b.TextColor3 = Color3.fromRGB(120, 120, 140)
            b.Line.Visible = false
        end
        btn.TextColor3 = Color3.fromRGB(0, 180, 255)
        btn.Line.Visible = true
        selectedTab = name
        updateContent(name)
    end)
end

-- ======== КОНТЕНТ ========
local contentFrame = Instance.new("ScrollingFrame", mainFrame)
contentFrame.Size = UDim2.new(1, -20, 1, -100)
contentFrame.Position = UDim2.new(0, 10, 0, 80)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 4
contentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
contentFrame.ZIndex = 2

-- Функция создания элемента (категория + переключатель)
local function createToggle(parent, label, defaultState, color, callback)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(1, -10, 0, 35)
    container.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 40 + 5)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    container.BorderSizePixel = 0
    container.ZIndex = 2
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 4)
    
    local lbl = Instance.new("TextLabel", container)
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Position = UDim2.new(0.02, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.ZIndex = 3
    
    local toggleBtn = Instance.new("TextButton", container)
    toggleBtn.Size = UDim2.new(0, 45, 0, 22)
    toggleBtn.Position = UDim2.new(1, -50, 0.5, -11)
    toggleBtn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 50)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = defaultState and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextScaled = true
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.ZIndex = 3
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)
    
    local state = defaultState
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 40, 50)
        toggleBtn.Text = state and "ON" or "OFF"
        callback(state)
    end)
    return toggleBtn
end

-- Функция обновления контента по вкладкам
local function updateContent(tab)
    for _, child in pairs(contentFrame:GetChildren()) do
        child:Destroy()
    end
    
    if tab == "AIM" then
        createToggle(contentFrame, "Aimbot (Lock)", false, Color3.fromRGB(0, 180, 255), function(val)
            print("Aimbot: " .. tostring(val))
        end)
        createToggle(contentFrame, "Silent Aim", false, Color3.fromRGB(200, 100, 255), function(val)
            print("Silent Aim: " .. tostring(val))
        end)
        createToggle(contentFrame, "Triggerbot", false, Color3.fromRGB(255, 150, 50), function(val)
            print("Triggerbot: " .. tostring(val))
        end)
    elseif tab == "VISUALS" then
        createToggle(contentFrame, "ESP", ESP_ENABLED, Color3.fromRGB(255, 0, 100), function(val)
            ESP_ENABLED = val
            if not val then
                for _, v in pairs(espObjects) do v:Destroy() end
                espObjects = {}
            else
                updateESP()
            end
        end)
        createToggle(contentFrame, "Chams", false, Color3.fromRGB(0, 255, 200), function(val)
            print("Chams: " .. tostring(val))
        end)
        createToggle(contentFrame, "Glow", false, Color3.fromRGB(255, 200, 0), function(val)
            print("Glow: " .. tostring(val))
        end)
        createToggle(contentFrame, "Box ESP", false, Color3.fromRGB(200, 200, 255), function(val)
            print("Box ESP: " .. tostring(val))
        end)
    elseif tab == "MISC" then
        createToggle(contentFrame, "Speed x" .. tostring(SPEED_MULTIPLIER), SPEED_ENABLED, Color3.fromRGB(0, 200, 255), function(val)
            SPEED_ENABLED = val
            setSpeed()
        end)
        createToggle(contentFrame, "SpinBot", SPINBOT_ENABLED, Color3.fromRGB(200, 200, 0), function(val)
            SPINBOT_ENABLED = val
            if not val then
                local root = character:FindFirstChild("HumanoidRootPart")
                if root then root.RotVelocity = Vector3.new(0, 0, 0) end
            end
        end)
        createToggle(contentFrame, "No Clip", false, Color3.fromRGB(255, 100, 100), function(val)
            print("No Clip: " .. tostring(val))
        end)
        createToggle(contentFrame, "Auto Respawn", false, Color3.fromRGB(100, 255, 100), function(val)
            print("Auto Respawn: " .. tostring(val))
        end)
    end
    
    -- Обновление CanvasSize
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, #contentFrame:GetChildren() * 40 + 20)
end

updateContent("AIM")

-- ======== КНОПКА ОТКРЫТИЯ (стиль Neverlose) ========
local openBtn = Instance.new("TextButton", screenGui)
openBtn.Size = UDim2.new(0, 50, 0, 50)
openBtn.Position = UDim2.new(0.02, 0, 0.02, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
openBtn.Text = "NL"
openBtn.TextColor3 = Color3.fromRGB(0, 180, 255)
openBtn.TextScaled = true
openBtn.Font = Enum.Font.GothamBold
openBtn.ZIndex = 100
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
local openStroke = Instance.new("UIStroke", openBtn)
openStroke.Thickness = 2
openStroke.Color = Color3.fromRGB(0, 180, 255)

openBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- ======== ХОТКЕЙ ========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- ======== ESP (без изменений) ========
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
    if role == "Murderer" then color = Color3.fromRGB(255, 0, 0)
    elseif role == "Sheriff" then color = Color3.fromRGB(0, 100, 255)
    elseif role == "Hero" then color = Color3.fromRGB(0, 255, 100)
    else color = Color3.fromRGB(200, 200, 200) end

    label.Text = "[" .. role .. "] " .. targetPlayer.Name
    label.TextColor3 = color

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

-- ======== ФИНАЛ ========
print("==========================================")
print("⚡ NEVERLOSE STYLE MENU LOADED ⚡")
print("   ROCKET WAY | 2026")
print("   INSERT = Открыть/Закрыть меню")
print("   Стиль: CS:GO Neverlose")
print("==========================================")
