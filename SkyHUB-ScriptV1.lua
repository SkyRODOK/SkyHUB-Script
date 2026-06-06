--[[
    ███████╗██╗░░██╗██╗░░░██╗  ██╗░░██╗██╗░░░██╗██████╗░
    ██╔════╝██║░██╔╝╚██╗░██╔╝  ██║░░██║██║░░░██║██╔══██╗
    ███████╗█████═╝░░╚████╔╝░  ███████║██║░░░██║██████╦╝
    ╚════██║██╔═██╗░░░╚██╔╝░░  ██╔══██║██║░░░██║██╔══██╗
    ███████║██║░╚██╗░░░██║░░░  ██║░░██║╚██████╔╝██████╦╝
    ╚══════╝╚═╝░░╚═╝░░░╚═╝░░░  ╚═╝░░╚═╝░╚═════╝░╚═════╝░
    
    SKY HUB - ULTIMATE ROBLOX SCRIPT
    FITUR LENGKAP: ESP, HITBOX, AUTO AIM, INVISIBLE, AIRBREAK
    BY ZENA AI ☠️
--]]

-- CEK EXECUTOR
local Executors = {
    Synapse = pcall(function() return getexecutorname and getexecutorname() == "Synapse X" end),
    Krnl = pcall(function() return getexecutorname and getexecutorname() == "Krnl" end),
    Fluxus = pcall(function() return getexecutorname and getexecutorname() == "Fluxus" end),
    ScriptWare = pcall(function() return getexecutorname and getexecutorname() == "ScriptWare" end),
    Electron = pcall(function() return getexecutorname and getexecutorname() == "Electron" end),
    Delta = pcall(function() return getexecutorname and getexecutorname() == "Delta" end)
}

-- LOAD UI LIBRARY (RAYFIELD)
local Rayfield = nil
local LibraryOptions = {
    "https://sirius.menu/rayfield",
    "https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua",
    "https://pastebin.com/raw/rayfield_lib"
}

for _, url in pairs(LibraryOptions) do
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success and result then
        Rayfield = result
        break
    end
end

if not Rayfield then
    -- FALLBACK UI MANUAL
    Rayfield = {Notify = function() end}
end

-- ============ KONFIGURASI AWAL ============
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local LocalChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- ============ VARIABLE GLOBAL ============
local SkyHub = {
    -- ESP VARIABLES
    espEnabled = false,
    espBox = false,
    espTracer = false,
    espName = false,
    espDistance = false,
    espHealth = false,
    espChams = false,
    
    -- HITBOX VARIABLES
    hitboxEnabled = false,
    hitboxSize = 10,
    hitboxColor = Color3.fromRGB(255, 0, 0),
    hitboxTransparency = 0.5,
    
    -- AIMBOT VARIABLES
    aimbotEnabled = false,
    aimSmoothness = 0.3,
    aimFov = 200,
    aimPart = "Head",
    aimVisibleCheck = true,
    aimTeamCheck = false,
    aimPrediction = false,
    
    -- MOVEMENT VARIABLES
    flyEnabled = false,
    flySpeed = 50,
    noclipEnabled = false,
    speedHack = 16,
    jumpPower = 50,
    infiniteJump = false,
    airbreakEnabled = false,
    
    -- VISUAL VARIABLES
    invisibleEnabled = false,
    fullbright = false,
    fovChanger = 70,
    thirdPerson = false,
    
    -- WEAPON VARIABLES
    rapidFire = false,
    noRecoil = false,
    infiniteAmmo = false,
    silentAim = false,
    
    -- MISC VARIABLES
    autoClicker = false,
    autoClickDelay = 0.05,
    teleportEnabled = false,
    teleportPoint = nil
}

-- ============ STORAGE FOR ESP ============
local espObjects = {}
local hitboxObjects = {}

-- ============ FUNGSI UTAMA ============

-- NOTIFICATION
local function Notify(title, message, duration)
    if Rayfield.Notify then
        Rayfield:Notify({
            Title = title,
            Content = message,
            Duration = duration or 3
        })
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = message,
            Duration = duration or 3
        })
    end
end

-- ============ ESP SYSTEM ============
local function CreateESP(player)
    if not SkyHub.espEnabled then return end
    if player == LocalPlayer then return end
    
    local espData = {}
    
    -- BOX ESP
    if SkyHub.espBox then
        local box = Drawing.new("Square")
        box.Visible = false
        box.Color = player.TeamColor and player.TeamColor.Color or Color3.fromRGB(255, 0, 0)
        box.Thickness = 2
        box.Filled = false
        box.Transparency = 0.7
        espData.box = box
    end
    
    -- TRACER LINE
    if SkyHub.espTracer then
        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Color = Color3.fromRGB(255, 0, 0)
        tracer.Thickness = 1
        espData.tracer = tracer
    end
    
    -- NAME TEXT
    if SkyHub.espName then
        local nameText = Drawing.new("Text")
        nameText.Visible = false
        nameText.Color = Color3.fromRGB(255, 255, 255)
        nameText.Size = 14
        nameText.Center = true
        nameText.Outline = true
        espData.name = nameText
    end
    
    -- DISTANCE TEXT
    if SkyHub.espDistance then
        local distText = Drawing.new("Text")
        distText.Visible = false
        distText.Color = Color3.fromRGB(255, 255, 0)
        distText.Size = 12
        distText.Center = true
        espData.distance = distText
    end
    
    -- HEALTH BAR
    if SkyHub.espHealth then
        local healthBar = Drawing.new("Square")
        healthBar.Visible = false
        healthBar.Color = Color3.fromRGB(0, 255, 0)
        healthBar.Thickness = 0
        healthBar.Filled = true
        espData.health = healthBar
    end
    
    espObjects[player] = espData
end

-- UPDATE ESP
local function UpdateESP()
    if not SkyHub.espEnabled then return end
    
    local viewportSize = Camera.ViewportSize
    
    for player, data in pairs(espObjects) do
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
            local rootPart = character.HumanoidRootPart
            local humanoid = character.Humanoid
            local position, onScreen = Camera:WorldToScreenPoint(rootPart.Position)
            
            if onScreen then
                local distance = (LocalChar and LocalChar:FindFirstChild("HumanoidRootPart") and 
                    (LocalChar.HumanoidRootPart.Position - rootPart.Position).Magnitude) or 0
                local boxSize = 3000 / distance
                local boxHeight = boxSize * 1.5
                
                -- UPDATE BOX
                if data.box then
                    data.box.Visible = true
                    data.box.Size = Vector2.new(boxSize, boxHeight)
                    data.box.Position = Vector2.new(position.X - boxSize/2, position.Y - boxHeight)
                end
                
                -- UPDATE TRACER
                if data.tracer then
                    data.tracer.Visible = true
                    data.tracer.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                    data.tracer.To = Vector2.new(position.X, position.Y)
                end
                
                -- UPDATE NAME
                if data.name then
                    data.name.Visible = true
                    data.name.Text = player.Name
                    data.name.Position = Vector2.new(position.X, position.Y - boxHeight - 10)
                end
                
                -- UPDATE DISTANCE
                if data.distance then
                    data.distance.Visible = true
                    data.distance.Text = math.floor(distance) .. "m"
                    data.distance.Position = Vector2.new(position.X, position.Y - boxHeight + 5)
                end
                
                -- UPDATE HEALTH BAR
                if data.health and humanoid then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    data.health.Visible = true
                    data.health.Size = Vector2.new(boxSize * healthPercent, 4)
                    data.health.Position = Vector2.new(position.X - boxSize/2, position.Y - boxHeight + boxHeight + 5)
                    if healthPercent > 0.6 then
                        data.health.Color = Color3.fromRGB(0, 255, 0)
                    elseif healthPercent > 0.3 then
                        data.health.Color = Color3.fromRGB(255, 255, 0)
                    else
                        data.health.Color = Color3.fromRGB(255, 0, 0)
                    end
                end
            else
                if data.box then data.box.Visible = false end
                if data.tracer then data.tracer.Visible = false end
                if data.name then data.name.Visible = false end
                if data.distance then data.distance.Visible = false end
                if data.health then data.health.Visible = false end
            end
        else
            if data.box then data.box.Visible = false end
            if data.tracer then data.tracer.Visible = false end
            if data.name then data.name.Visible = false end
            if data.distance then data.distance.Visible = false end
            if data.health then data.health.Visible = false end
        end
    end
end

-- ============ HITBOX SYSTEM ============
local function CreateHitbox(character)
    if not SkyHub.hitboxEnabled then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    
    -- HITBOX PARTS (HEAD, CHEST, ARMS, LEGS)
    local hitboxParts = {
        Head = {color = SkyHub.hitboxColor, size = SkyHub.hitboxSize},
        Chest = {color = SkyHub.hitboxColor, size = SkyHub.hitboxSize * 1.5},
        LeftArm = {color = SkyHub.hitboxColor, size = SkyHub.hitboxSize},
        RightArm = {color = SkyHub.hitboxColor, size = SkyHub.hitboxSize},
        LeftLeg = {color = SkyHub.hitboxColor, size = SkyHub.hitboxSize},
        RightLeg = {color = SkyHub.hitboxColor, size = SkyHub.hitboxSize}
    }
    
    for partName, config in pairs(hitboxParts) do
        local part = character:FindFirstChild(partName)
        if part then
            -- BUAT HITBOX VISUAL
            local hitbox = Instance.new("Part")
            hitbox.Name = "SkyHub_Hitbox_" .. partName
            hitbox.Size = Vector3.new(config.size, config.size, config.size)
            hitbox.BrickColor = BrickColor.new(config.color)
            hitbox.Material = Enum.Material.Neon
            hitbox.Transparency = SkyHub.hitboxTransparency
            hitbox.Anchored = false
            hitbox.CanCollide = false
            hitbox.Parent = character
            
            -- WELD KE PART ASLI
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = hitbox
            weld.Part1 = part
            weld.Parent = hitbox
            
            table.insert(hitboxObjects, hitbox)
        end
    end
end

local function UpdateHitboxes()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            CreateHitbox(player.Character)
        end
    end
end

-- ============ AIMBOT SYSTEM ============
local function GetClosestPlayer()
    if not SkyHub.aimbotEnabled then return nil end
    
    local closest = nil
    local shortestDist = SkyHub.aimFov
    local mouse = LocalPlayer:GetMouse()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if SkyHub.aimTeamCheck and player.Team == LocalPlayer.Team then
                -- SKIP TEAMMATE
            else
                local targetPart = player.Character:FindFirstChild(SkyHub.aimPart)
                if targetPart then
                    local pos, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                        if dist < shortestDist then
                            -- VISIBILITY CHECK
                            if SkyHub.aimVisibleCheck then
                                local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000)
                                local hit, hitPos = Workspace:FindPartOnRay(ray, LocalChar)
                                if hit and hit:IsDescendantOf(player.Character) then
                                    shortestDist = dist
                                    closest = player
                                end
                            else
                                shortestDist = dist
                                closest = player
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- AIMBOT LOOP
RunService.RenderStepped:Connect(function()
    if SkyHub.aimbotEnabled then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(SkyHub.aimPart) then
            local targetPos = target.Character[SkyHub.aimPart].Position
            
            -- PREDICTION FOR MOVING TARGETS
            if SkyHub.aimPrediction then
                local targetVelocity = target.Character.HumanoidRootPart.Velocity
                local distance = (LocalChar.HumanoidRootPart.Position - targetPos).Magnitude
                local bulletSpeed = 3000 -- KECEPATAN PROYEKTIL
                local predictionTime = distance / bulletSpeed
                targetPos = targetPos + (targetVelocity * predictionTime)
            end
            
            -- SET CAMERA LOOK DIRECTION
            local lookAt = CFrame.new(Camera.CFrame.Position, targetPos)
            local newCFrame = Camera.CFrame:Lerp(lookAt, SkyHub.aimSmoothness)
            Camera.CFrame = newCFrame
        end
    end
end)

-- ============ FLY + AIRBREAK SYSTEM ============
local flying = false
local flyBodyVelocity = nil
local flyGyro = nil

local function FlyEnabled(state)
    if state then
        if not flyBodyVelocity then
            flyBodyVelocity = Instance.new("BodyVelocity")
            flyGyro = Instance.new("BodyGyro")
            flyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            flyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        end
        
        flyBodyVelocity.Parent = LocalChar.HumanoidRootPart
        flyGyro.Parent = LocalChar.HumanoidRootPart
        flying = true
    else
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        if flyGyro then flyGyro:Destroy() end
        flying = false
        if LocalChar and LocalChar.Humanoid then
            LocalChar.Humanoid.PlatformStand = false
        end
    end
end

-- AIRBREAK (BERHENTI INSTAN)
local function Airbreak()
    if LocalChar and LocalChar.HumanoidRootPart then
        LocalChar.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        LocalChar.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        LocalChar.HumanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end

-- FLY UPDATE
RunService.RenderStepped:Connect(function()
    if flying and SkyHub.flyEnabled then
        local moveDirection = Vector3.new()
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        flyBodyVelocity.Velocity = moveDirection * SkyHub.flySpeed
        flyGyro.CFrame = Camera.CFrame
        
        if LocalChar.Humanoid then
            LocalChar.Humanoid.PlatformStand = true
        end
    end
    
    -- AIRBREAK HOTKEY (HOLD X)
    if UserInputService:IsKeyDown(Enum.KeyCode.X) and SkyHub.airbreakEnabled then
        Airbreak()
    end
end)

-- ============ INVISIBLE SYSTEM ============
local originalTransparency = {}

local function SetInvisible(state)
    if not LocalChar then return end
    
    for _, part in pairs(LocalChar:GetDescendants()) do
        if part:IsA("BasePart") then
            if state then
                originalTransparency[part] = part.Transparency
                part.Transparency = 1
            else
                if originalTransparency[part] then
                    part.Transparency = originalTransparency[part]
                else
                    part.Transparency = 0
                end
            end
        end
    end
    
    if state and LocalChar.Humanoid then
        -- MAKIN MAKHLUK GAIB
        for _, accessory in pairs(LocalChar:GetChildren()) do
            if accessory:IsA("Accessory") then
                accessory.Handle.Transparency = 1
            end
        end
    end
end

-- ============ NOCLIP SYSTEM ============
local function SetNoclip(state)
    if state then
        RunService.Stepped:Connect(function()
            if LocalChar and LocalChar.HumanoidRootPart then
                LocalChar.HumanoidRootPart.CanCollide = false
                for _, part in pairs(LocalChar:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

-- ============ WEAPON MODS ============
local function GetCurrentTool()
    return LocalChar and LocalChar:FindFirstChildOfClass("Tool")
end

-- RAPID FIRE
RunService.RenderStepped:Connect(function()
    if SkyHub.rapidFire then
        local tool = GetCurrentTool()
        if tool and tool:FindFirstChild("Values") then
            -- COBA UBAH FIRERATE
            for _, v in pairs(tool:GetDescendants()) do
                if v.Name:lower():find("firerate") or v.Name:lower():find("cooldown") then
                    pcall(function()
                        v.Value = 0
                    end)
                end
            end
        end
    end
end)

-- NO RECOIL
local oldRecoil = nil
RunService.RenderStepped:Connect(function()
    if SkyHub.noRecoil then
        if LocalPlayer.PlayerScripts:FindFirstChild("Weapons") then
            -- RESET RECOIL VALUE
        end
    end
end)

-- SILENT AIM
RunService.RenderStepped:Connect(function()
    if SkyHub.silentAim then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            -- MODIFIKASI SHOOT DIRECTION
        end
    end
end)

-- ============ AUTO CLICKER ============
local autoClicking = false

local function StartAutoClicker()
    autoClicking = true
    while autoClicking and SkyHub.autoClicker do
        local args = {["Button"] = "Left"}
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game:GetService("UserInputService").Enum.UserInputType.MouseButton1, 0)
        task.wait(SkyHub.autoClickDelay)
        game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game:GetService("UserInputService").Enum.UserInputType.MouseButton1, 0)
        task.wait(SkyHub.autoClickDelay)
    end
end

-- ============ TELEPORT SYSTEM ============
local function TeleportToMouse()
    local mouse = LocalPlayer:GetMouse()
    local hit = mouse.Target
    if hit then
        SkyHub.teleportPoint = hi
