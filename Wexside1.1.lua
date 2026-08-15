-- узел: meridian/wexside_ultimate_mm2
-- deps: Synapse X / Krnl / Fluxus (Drawing API, Highlight, getgenv, hookmetamethod)
-- параметры: TARGET_ENV (Roblox, Murder Mystery 2)

getgenv().Wexside = {
    Settings = {
        ESP_Enabled = false,
        GunESP_Enabled = false,
        Chams_Enabled = false,
        Hitbox_Enabled = false,
        Aimlock_Enabled = false,
        SilentAim_Enabled = false,
        SpinBot_Enabled = false,
        BunnyHop_Enabled = false,
        Fly_Enabled = false,
        Speedhack_Enabled = false,
        HighJump_Enabled = false,
        
        SpeedMultiplier = 3,
        JumpMultiplier = 2.5,
        SpinSpeed = 360,
        AimlockFOV = 120,
        AimlockSmooth = 0.3,
        SilentAimSpread = 1,
        FlySpeed = 50
    }
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local espCache = {}
local gunEspCache = {}
local chamsCache = {}
local targetPlayer = nil
local ToggleButtons = {}

local hitboxCircle = Drawing.new("Circle")
hitboxCircle.Visible = false
hitboxCircle.Color = Color3.fromRGB(255, 0, 0)
hitboxCircle.Thickness = 1
hitboxCircle.Transparency = 0.5
hitboxCircle.Filled = true

-- === УТИЛИТЫ ИДЕНТИФИКАЦИИ РОЛЕЙ ===

local function getRoleColor(player)
    if player == LocalPlayer then return Color3.fromRGB(255, 255, 255) end
    
    local function checkContainer(container)
        if not container then return nil end
        for _, item in pairs(container:GetChildren()) do
            local name = item.Name:lower()
            if name:match("knife") or name:match("blade") or name:match("dagger") then
                return Color3.fromRGB(255, 0, 0) -- Murderer (Red)
            elseif name:match("gun") or name:match("revolver") or name:match("sheriff") then
                return Color3.fromRGB(0, 0, 255) -- Sheriff (Blue)
            end
        end
        return nil
    end

    if player.Character then
        local col = checkContainer(player.Character)
        if col then return col end
    end
    
    if player:FindFirstChild("Backpack") then
        local col = checkContainer(player.Backpack)
        if col then return col end
    end
    
    return Color3.fromRGB(0, 255, 0) -- Default Innocent (Green)
end

-- === АИМЛОК С ПРЕДИКШЕНОМ И FOV ===

local function getBestTarget()
    local bestTarget = nil
    local shortestDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    local fovLimit = getgenv().Wexside.Settings.AimlockFOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local head = player.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local screenPos = Vector2.new(pos.X, pos.Y)
                local dist = (screenPos - mousePos).Magnitude
                if dist <= fovLimit and dist < shortestDist then
                    shortestDist = dist
                    bestTarget = player
                end
            end
        end
    end
    return bestTarget
end

-- === ESP И CHAMS КОНТУР ===

local function createESP(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1
    box.Filled = false

    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = true
    text.Size = 16

    espCache[player] = {box = box, text = text}
end

local function removeESP(player)
    if espCache[player] then
        espCache[player].box:Remove()
        espCache[player].text:Remove()
        espCache[player] = nil
    end
    if chamsCache[player] then
        chamsCache[player]:Destroy()
        chamsCache[player] = nil
    end
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then createESP(player) end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then createESP(player) end
end)

Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    -- Box ESP & Chams Update
    for player, esp in pairs(espCache) do
        pcall(function()
            local char = player.Character
            local roleColor = getRoleColor(player)
            
            -- Chams logic
            if getgenv().Wexside.Settings.Chams_Enabled and char then
                if not chamsCache[player] then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = CoreGui
                    highlight.Adornee = char
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    chamsCache[player] = highlight
                end
                chamsCache[player].Adornee = char
                chamsCache[player].FillColor = roleColor
                chamsCache[player].OutlineColor = roleColor
                chamsCache[player].Enabled = true
            else
                if chamsCache[player] then
                    chamsCache[player].Enabled = false
                end
            end

            -- Box ESP logic
            if getgenv().Wexside.Settings.ESP_Enabled and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local hrp = char.HumanoidRootPart
                local head = char:FindFirstChild("Head")
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen and head then
                    local hrp2D = Camera:WorldToViewportPoint(hrp.Position)
                    local head2D = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local leg2D = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    
                    local height = math.abs(head2D.Y - leg2D.Y)
                    local width = height * 0.6
                    
                    esp.box.Size = Vector2.new(width, height)
                    esp.box.Position = Vector2.new(hrp2D.X - width / 2, head2D.Y)
                    esp.box.Color = roleColor
                    esp.box.Visible = true
                    
                    local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                    esp.text.Text = string.format("%s\n[%d] | %d HP", player.Name, dist, char.Humanoid.Health)
                    esp.text.Position = Vector2.new(hrp2D.X, head2D.Y - 20)
                    esp.text.Color = roleColor
                    esp.text.Visible = true
                else
                    esp.box.Visible = false
                    esp.text.Visible = false
                end
            else
                esp.box.Visible = false
                esp.text.Visible = false
            end
        end)
    end
    
    -- Gun ESP
    if getgenv().Wexside.Settings.GunESP_Enabled then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Tool") and (obj.Name:lower():match("gun") or obj.Name:lower():match("revolver")) and obj.Parent == Workspace then
                if not gunEspCache[obj] then
                    local text = Drawing.new("Text")
                    text.Center = true
                    text.Outline = true
                    text.Color = Color3.fromRGB(255, 255, 0)
                    text.Size = 18
                    gunEspCache[obj] = text
                end
                local handle = obj:FindFirstChild("Handle")
                if handle then
                    local pos, onScreen = Camera:WorldToViewportPoint(handle.Position)
                    if onScreen then
                        local dist = math.floor((Camera.CFrame.Position - handle.Position).Magnitude)
                        gunEspCache[obj].Text = "GUN DROPPED [" .. dist .. "]"
                        gunEspCache[obj].Position = Vector2.new(pos.X, pos.Y)
                        gunEspCache[obj].Visible = true
                    else
                        gunEspCache[obj].Visible = false
                    end
                end
            end
        end
        for obj, text in pairs(gunEspCache) do
            if not obj or obj.Parent ~= Workspace then
                text:Remove()
                gunEspCache[obj] = nil
            end
        end
    else
        for obj, text in pairs(gunEspCache) do
            text.Visible = false
        end
    end

    -- Hitbox Draw
    if getgenv().Wexside.Settings.Hitbox_Enabled and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            local hrp = targetPlayer.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                hitboxCircle.Position = Vector2.new(pos.X, pos.Y)
                hitboxCircle.Radius = math.clamp(1500 / dist, 15, 200)
                hitboxCircle.Visible = true
            else
                hitboxCircle.Visible = false
            end
        end)
    else
        hitboxCircle.Visible = false
    end
end)

-- === AIMLOCK С ПРЕДИКШЕНОМ ===

local aimlockActive = false
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and getgenv().Wexside.Settings.Aimlock_Enabled then
        aimlockActive = true
        targetPlayer = getBestTarget()
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimlockActive = false
        targetPlayer = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if aimlockActive and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            local head = targetPlayer.Character.Head
            local hrp = targetPlayer.Character.HumanoidRootPart
            -- Предикшн движения через Velocity
            local predictedPos = head.Position + (hrp.AssemblyLinearVelocity * 0.05)
            local currentCF = Camera.CFrame
            local targetCF = CFrame.new(currentCF.Position, predictedPos)
            Camera.CFrame = currentCF:Lerp(targetCF, getgenv().Wexside.Settings.AimlockSmooth)
        end)
    end
end)

-- === SILENT AIM С РАНДОМИЗАЦИЕЙ ===

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and getgenv().Wexside.Settings.SilentAim_Enabled and method == "FireServer" then
        local nearest = getBestTarget()
        if nearest and nearest.Character and nearest.Character:FindFirstChild("Head") then
            local headPos = nearest.Character.Head.Position
            local spread = getgenv().Wexside.Settings.SilentAimSpread
            local randomOffset = Vector3.new(math.random(-spread, spread), math.random(-spread, spread), math.random(-spread, spread)) * 0.1
            local finalPos = headPos + randomOffset
            
            for i, v in ipairs(args) do
                if typeof(v) == "Vector3" then
                    args[i] = finalPos
                elseif typeof(v) == "CFrame" then
                    args[i] = CFrame.new(v.Position, finalPos)
                end
            end
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

-- === ФИЗИКА (FLY, SPEED, HIGH JUMP, SPINBOT, BUNNYHOP) ===

local bodyVel = nil
RunService.Stepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        -- Speedhack (ТОЛЬКО WalkSpeed)
        if getgenv().Wexside.Settings.Speedhack_Enabled then
            hum.WalkSpeed = 16 * getgenv().Wexside.Settings.SpeedMultiplier
        else
            hum.WalkSpeed = 16
        end

        -- High Jump (ТОЛЬКО JumpPower)
        if getgenv().Wexside.Settings.HighJump_Enabled then
            hum.JumpPower = 50 * getgenv().Wexside.Settings.JumpMultiplier
        else
            hum.JumpPower = 50
        end

        -- SpinBot
        if getgenv().Wexside.Settings.SpinBot_Enabled and not getgenv().Wexside.Settings.Fly_Enabled then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(getgenv().Wexside.Settings.SpinSpeed * 0.1), 0)
        end

        -- BunnyHop (Мгновенный прыжок при касании земли и удержании Space, увеличенная высота)
        if getgenv().Wexside.Settings.BunnyHop_Enabled then
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                if hum.FloorMaterial ~= Enum.Material.Air then
                    hum.JumpPower = 80
                    hum.Jump = true
                end
            end
        end

        -- Fly (Независимый полёт с Shift вниз и Space вверх)
        if getgenv().Wexside.Settings.Fly_Enabled then
            hum.PlatformStand = true
            if not bodyVel then
                bodyVel = Instance.new("BodyVelocity")
                bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyVel.Parent = hrp
            end
            
            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            
            bodyVel.Velocity = moveDir * getgenv().Wexside.Settings.FlySpeed
        else
            hum.PlatformStand = false
            if bodyVel then
                bodyVel:Destroy()
                bodyVel = nil
            end
        end
    end)
end)

-- === ОБРАБОТЧИК КЛАВИШ ===

local function syncButton(configKey)
    if ToggleButtons[configKey] then
        local state = getgenv().Wexside.Settings[configKey]
        local btn = ToggleButtons[configKey].button
        local name = ToggleButtons[configKey].label
        if state then
            btn.Text = name .. " [ON]"
            btn.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            btn.Text = name .. " [OFF]"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then 
        getgenv().Wexside.Settings.Fly_Enabled = not getgenv().Wexside.Settings.Fly_Enabled
        syncButton("Fly_Enabled")
    end
    if input.KeyCode == Enum.KeyCode.X then 
        getgenv().Wexside.Settings.Speedhack_Enabled = not getgenv().Wexside.Settings.Speedhack_Enabled
        syncButton("Speedhack_Enabled")
    end
    if input.KeyCode == Enum.KeyCode.J then 
        getgenv().Wexside.Settings.HighJump_Enabled = not getgenv().Wexside.Settings.HighJump_Enabled
        syncButton("HighJump_Enabled")
    end
    if input.KeyCode == Enum.KeyCode.H then 
        getgenv().Wexside.Settings.Hitbox_Enabled = not getgenv().Wexside.Settings.Hitbox_Enabled
        syncButton("Hitbox_Enabled")
    end
    if input.KeyCode == Enum.KeyCode.V then 
        getgenv().Wexside.Settings.SpinBot_Enabled = not getgenv().Wexside.Settings.SpinBot_Enabled
        syncButton("SpinBot_Enabled")
    end
    if input.KeyCode == Enum.KeyCode.B then 
        getgenv().Wexside.Settings.BunnyHop_Enabled = not getgenv().Wexside.Settings.BunnyHop_Enabled
        syncButton("BunnyHop_Enabled")
    end
    if input.KeyCode == Enum.KeyCode.C then 
        getgenv().Wexside.Settings.Chams_Enabled = not getgenv().Wexside.Settings.Chams_Enabled
        syncButton("Chams_Enabled")
    end
end)

-- === ГРАФИЧЕСКИЙ ИНТЕРФЕЙС ===

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local TimerLabel = Instance.new("TextLabel")
local ScrollingContainer = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local CreditLabel = Instance.new("TextLabel")
local MobileButton = Instance.new("TextButton")

ScreenGui.Name = "WexsideUltimate"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Мобильная кнопка переключения GUI
MobileButton.Name = "MobileToggle"
MobileButton.Parent = ScreenGui
MobileButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MobileButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
MobileButton.Position = UDim2.new(0, 10, 0, 10)
MobileButton.Size = UDim2.new(0, 50, 0, 50)
MobileButton.Font = Enum.Font.SourceSansBold
MobileButton.Text = "≡"
MobileButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MobileButton.TextSize = 24
MobileButton.Visible = UserInputService.TouchEnabled

MobileButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

MainFrame.Name = "Main"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 240, 0, 480)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "WEXSIDE // ULTIMATE"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.TextSize = 16

TimerLabel.Parent = MainFrame
TimerLabel.BackgroundTransparency = 1
TimerLabel.Position = UDim2.new(0, 0, 0, 30)
TimerLabel.Size = UDim2.new(1, 0, 0, 25)
TimerLabel.Font = Enum.Font.Code
TimerLabel.Text = "ЦИКЛ: 00:00"
TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TimerLabel.TextSize = 14

ScrollingContainer.Parent = MainFrame
ScrollingContainer.BackgroundTransparency = 1
ScrollingContainer.Position = UDim2.new(0, 0, 0, 60)
ScrollingContainer.Size = UDim2.new(1, 0, 1, -85)
ScrollingContainer.CanvasSize = UDim2.new(0, 0, 0, 650)
ScrollingContainer.ScrollBarThickness = 4

UIListLayout.Parent = ScrollingContainer
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createToggle(name, configKey)
    local btn = Instance.new("TextButton")
    btn.Parent = ScrollingContainer
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Font = Enum.Font.Code
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Text = name .. " [OFF]"
    
    ToggleButtons[configKey] = {button = btn, label = name}
    
    btn.MouseButton1Click:Connect(function()
        getgenv().Wexside.Settings[configKey] = not getgenv().Wexside.Settings[configKey]
        syncButton(configKey)
    end)
end

local function createSlider(name, configKey, min, max)
    local container = Instance.new("Frame")
    container.Parent = ScrollingContainer
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(0.9, 0, 0, 45)
    
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Font = Enum.Font.Code
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 12
    label.Text = name .. ": " .. tostring(getgenv().Wexside.Settings[configKey])
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Parent = container
    sliderBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    sliderBtn.Position = UDim2.new(0, 0, 0, 22)
    sliderBtn.Size = UDim2.new(1, 0, 0, 18)
    sliderBtn.Text = ""
    
    local fill = Instance.new("Frame")
    fill.Parent = sliderBtn
    fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    fill.Size = UDim2.new((getgenv().Wexside.Settings[configKey] - min) / (max - min), 0, 1, 0)
    fill.BorderSizePixel = 0
    
    local dragging = false
    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp((input.Position.X - sliderBtn.AbsolutePosition.X) / sliderBtn.AbsoluteSize.X, 0, 1)
            local val = min + (max - min) * pos
            if max > 10 then val = math.floor(val) else val = math.floor(val * 10) / 10 end
            getgenv().Wexside.Settings[configKey] = val
            fill.Size = UDim2.new(pos, 0, 1, 0)
            label.Text = name .. ": " .. tostring(val)
        end
    end)
end

-- Инициализация элементов управления в UI
createToggle("Box ESP", "ESP_Enabled")
createToggle("Gun ESP", "GunESP_Enabled")
createToggle("Chams (Key C)", "Chams_Enabled")
createToggle("Hitboxes (Key H)", "Hitbox_Enabled")
createToggle("Aimlock (Hold RMB)", "Aimlock_Enabled")
createToggle("Silent Aim", "SilentAim_Enabled")
createToggle("SpinBot (Key V)", "SpinBot_Enabled")
createToggle("BunnyHop (Key B)", "BunnyHop_Enabled")
createToggle("Fly (Key F)", "Fly_Enabled")
createToggle("SpeedHack (Key X)", "Speedhack_Enabled")
createToggle("High Jump (Key J)", "HighJump_Enabled")

createSlider("Speed Multiplier", "SpeedMultiplier", 1, 10)
createSlider("Jump Multiplier", "JumpMultiplier", 1, 5)
createSlider("SpinBot Speed", "SpinSpeed", 100, 720)
createSlider("Aimlock FOV", "AimlockFOV", 30, 180)
createSlider("Aimlock Smooth", "AimlockSmooth", 0.1, 1.0)
createSlider("Silent Aim Spread", "SilentAimSpread", 0, 5)

-- Подпись Оператора
CreditLabel.Parent = MainFrame
CreditLabel.BackgroundTransparency = 1
CreditLabel.Position = UDim2.new(0, 0, 1, -20)
CreditLabel.Size = UDim2.new(1, -5, 0, 20)
CreditLabel.Font = Enum.Font.Code
CreditLabel.Text = "By Asixdi"
CreditLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
CreditLabel.TextSize = 11
CreditLabel.TextXAlignment = Enum.TextXAlignment.Right

-- === ЛОКАЛЬНЫЙ ТАЙМЕР ЦИКЛА ===

local roundTime = 0
RunService.Stepped:Connect(function(_, deltaTime)
    roundTime = roundTime + deltaTime
    local mins = math.floor(roundTime / 60)
    local secs = math.floor(roundTime % 60)
    TimerLabel.Text = string.format("ЦИКЛ: %02d:%02d", mins, secs)
end)
