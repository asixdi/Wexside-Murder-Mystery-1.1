-- узел: meridian/wexside_overlay_mm2
-- deps: Synapse X / Krnl / Fluxus (Drawing API, getgenv, hookmetamethod)
-- параметры: TARGET_ENV (Roblox, Murder Mystery 2)

getgenv().WexsideConfig = {
    ESP_Enabled = false,
    GunESP_Enabled = false,
    Aimlock_Enabled = false,
    SilentAim_Enabled = false,
    Fly_Enabled = false,
    Speedhack_Enabled = false,
    Hitbox_Enabled = false,
    SpinBot_Enabled = false,
    BunnyHop_Enabled = false,
    SpeedMultiplier = 3,
    FlySpeed = 50,
    SpinSpeed = 15 -- Скорость вращения SpinBot
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Внутреннее хранилище объектов
local espCache = {}
local gunEspCache = {}
local targetPlayer = nil
local ToggleButtons = {}

local hitboxCircle = Drawing.new("Circle")
hitboxCircle.Visible = false
hitboxCircle.Color = Color3.fromRGB(255, 0, 0)
hitboxCircle.Thickness = 1
hitboxCircle.Transparency = 0.5
hitboxCircle.Filled = true

-- === УТИЛИТЫ ИДЕНТИФИКАЦИИ ===

local function getRoleColor(player)
    if player == LocalPlayer then return Color3.new(1, 1, 1) end
    local color = Color3.fromRGB(0, 255, 0) -- Innocent (Green)
    
    local function checkInventory(container)
        if not container then return false end
        for _, item in pairs(container:GetChildren()) do
            if item.Name:lower():match("knife") or item.Name:lower():match("blade") then
                color = Color3.fromRGB(255, 0, 0) -- Murderer (Red)
                return true
            elseif item.Name:lower():match("gun") or item.Name:lower():match("revolver") then
                color = Color3.fromRGB(0, 0, 255) -- Sheriff (Blue)
                return true
            end
        end
        return false
    end

    if player.Character and checkInventory(player.Character) then return color end
    if player:FindFirstChild("Backpack") and checkInventory(player.Backpack) then return color end
    
    return color
end

local function getNearestTarget()
    local nearest = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    nearest = player
                end
            end
        end
    end
    return nearest
end

-- === ESP & ХИТБОКС КОНТУР ===

local function createESP(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.new(1, 1, 1)
    box.Thickness = 1
    box.Filled = false

    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = true
    text.Color = Color3.new(1, 1, 1)
    text.Size = 16

    espCache[player] = {box = box, text = text}
end

local function removeESP(player)
    if espCache[player] then
        espCache[player].box:Remove()
        espCache[player].text:Remove()
        espCache[player] = nil
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
    -- Box ESP
    for player, esp in pairs(espCache) do
        local success, _ = pcall(function()
            if getgenv().WexsideConfig.ESP_Enabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local hrp = player.Character.HumanoidRootPart
                local head = player.Character:FindFirstChild("Head")
                
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    local hrp2D = Camera:WorldToViewportPoint(hrp.Position)
                    local head2D = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local leg2D = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    
                    local height = math.abs(head2D.Y - leg2D.Y)
                    local width = height * 0.6
                    
                    local roleColor = getRoleColor(player)
                    
                    esp.box.Size = Vector2.new(width, height)
                    esp.box.Position = Vector2.new(hrp2D.X - width / 2, head2D.Y)
                    esp.box.Color = roleColor
                    esp.box.Visible = true
                    
                    local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                    esp.text.Text = string.format("%s\n[%d] | %d HP", player.Name, dist, player.Character.Humanoid.Health)
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
        if not success then
            esp.box.Visible = false
            esp.text.Visible = false
        end
    end
    
    -- Gun ESP
    if getgenv().WexsideConfig.GunESP_Enabled then
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

    -- Hitbox Отрисовка
    if getgenv().WexsideConfig.Hitbox_Enabled and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and targetPlayer.Character:FindFirstChild("Humanoid") and targetPlayer.Character.Humanoid.Health > 0 then
        local success, _ = pcall(function()
            local hrp = targetPlayer.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                hitboxCircle.Position = Vector2.new(pos.X, pos.Y)
                hitboxCircle.Radius = math.clamp(1500 / dist, 15, 200) -- Масштабирование размера
                hitboxCircle.Visible = true
            else
                hitboxCircle.Visible = false
            end
        end)
        if not success then hitboxCircle.Visible = false end
    else
        hitboxCircle.Visible = false
    end
end)

-- === AIMLOCK КОНТУР ===

local aimlockActive = false
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and getgenv().WexsideConfig.Aimlock_Enabled then
        aimlockActive = true
        targetPlayer = getNearestTarget()
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aimlockActive = false
        targetPlayer = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if aimlockActive and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        pcall(function()
            local targetPos = targetPlayer.Character.Head.Position
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        end)
    end
end)

-- === SILENT AIM ПЕРЕХВАТ ===

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and getgenv().WexsideConfig.SilentAim_Enabled and method == "FireServer" then
        if self.Name == "ShootGun" or self.Name == "Fire" or tostring(self):match("Remote") then
            local nearest = getNearestTarget()
            if nearest and nearest.Character and nearest.Character:FindFirstChild("Head") then
                for i, v in ipairs(args) do
                    if typeof(v) == "Vector3" or typeof(v) == "CFrame" then
                        args[i] = nearest.Character.Head.Position
                    end
                end
                return oldNamecall(self, unpack(args))
            end
        end
    end
    return oldNamecall(self, ...)
end)

-- === ФИЗИЧЕСКИЙ КОНТУР (FLY, SPEED, SPINBOT, BUNNYHOP) ===

local bodyVel = nil
RunService.Stepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        -- Speedhack
        if getgenv().WexsideConfig.Speedhack_Enabled then
            hum.WalkSpeed = 16 * getgenv().WexsideConfig.SpeedMultiplier
            hum.JumpPower = 50 * getgenv().WexsideConfig.SpeedMultiplier
        else
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end

        -- SpinBot (блокируется полётом)
        if getgenv().WexsideConfig.SpinBot_Enabled and not getgenv().WexsideConfig.Fly_Enabled then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(getgenv().WexsideConfig.SpinSpeed), 0)
        end

        -- BunnyHop
        if getgenv().WexsideConfig.BunnyHop_Enabled then
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                if hum.FloorMaterial ~= Enum.Material.Air and hum.MoveDirection.Magnitude > 0 then
                    hum.Jump = true
                end
            end
        end

        -- Fly
        if getgenv().WexsideConfig.Fly_Enabled then
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
            
            bodyVel.Velocity = moveDir * getgenv().WexsideConfig.FlySpeed
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
        local state = getgenv().WexsideConfig[configKey]
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
        getgenv().WexsideConfig.Fly_Enabled = not getgenv().WexsideConfig.Fly_Enabled
        syncButton("Fly_Enabled")
    end
    if input.KeyCode == Enum.KeyCode.X then 
        getgenv().WexsideConfig.Speedhack_Enabled = not getgenv().WexsideConfig.Speedhack_Enabled
        syncButton("Speedhack_Enabled")
    end
    if input.KeyCode == Enum.KeyCode.H then 
        getgenv().WexsideConfig.Hitbox_Enabled = not getgenv().WexsideConfig.Hitbox_Enabled
        syncButton("Hitbox_Enabled")
    end
    if input.KeyCode == Enum.KeyCode.V then 
        getgenv().WexsideConfig.SpinBot_Enabled = not getgenv().WexsideConfig.SpinBot_Enabled
        syncButton("SpinBot_Enabled")
    end
    if input.KeyCode == Enum.KeyCode.B then 
        getgenv().WexsideConfig.BunnyHop_Enabled = not getgenv().WexsideConfig.BunnyHop_Enabled
        syncButton("BunnyHop_Enabled")
    end
end)

-- === ГРАФИЧЕСКИЙ ИНТЕРФЕЙС ===

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local TimerLabel = Instance.new("TextLabel")
local UIListLayout = Instance.new("UIListLayout")
local CreditLabel = Instance.new("TextLabel")

ScreenGui.Name = "WexsideOverlay"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "Main"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 430)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0) -- Красный акцент для Wexside
MainFrame.Active = true
MainFrame.Draggable = true

Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.Code
Title.Text = "WEXSIDE // ОВЕРЛЕЙ"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold

TimerLabel.Parent = MainFrame
TimerLabel.BackgroundTransparency = 1
TimerLabel.Position = UDim2.new(0, 0, 0, 30)
TimerLabel.Size = UDim2.new(1, 0, 0, 25)
TimerLabel.Font = Enum.Font.Code
TimerLabel.Text = "ТАЙМЕР: 00:00"
TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TimerLabel.TextSize = 14

local ButtonContainer = Instance.new("Frame")
ButtonContainer.Parent = MainFrame
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Position = UDim2.new(0, 0, 0, 60)
ButtonContainer.Size = UDim2.new(1, 0, 1, -85)

UIListLayout.Parent = ButtonContainer
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createToggle(name, configKey)
    local btn = Instance.new("TextButton")
    btn.Parent = ButtonContainer
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Font = Enum.Font.Code
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Text = name .. " [OFF]"
    
    ToggleButtons[configKey] = {button = btn, label = name}
    
    btn.MouseButton1Click:Connect(function()
        getgenv().WexsideConfig[configKey] = not getgenv().WexsideConfig[configKey]
        syncButton(configKey)
    end)
end

-- Инициализация кнопок
createToggle("Box ESP", "ESP_Enabled")
createToggle("Gun ESP", "GunESP_Enabled")
createToggle("Hitboxes (Key H)", "Hitbox_Enabled")
createToggle("Aimlock (Hold RMB)", "Aimlock_Enabled")
createToggle("Silent Aim", "SilentAim_Enabled")
createToggle("SpinBot (Key V)", "SpinBot_Enabled")
createToggle("BunnyHop (Key B)", "BunnyHop_Enabled")
createToggle("Fly (Key F)", "Fly_Enabled")
createToggle("Speedhack (Key X)", "Speedhack_Enabled")

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

-- === ЛОКАЛЬНЫЙ ТАЙМЕР ===

local roundTime = 0
RunService.Stepped:Connect(function(_, deltaTime)
    roundTime = roundTime + deltaTime
    local mins = math.floor(roundTime / 60)
    local secs = math.floor(roundTime % 60)
    TimerLabel.Text = string.format("ЦИКЛ: %02d:%02d", mins, secs)
end)
