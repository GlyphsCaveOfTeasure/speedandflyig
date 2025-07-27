-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- VARIABLES
local LocalPlayer = Players.LocalPlayer
local flyEnabled = false
local BG, BV, root, character

local flySpeed = 50

local Control = {F = 0, B = 0, L = 0, R = 0, U = 0, D = 0}

-- Tween info for UI animations
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

-- Invisibility Cloak Equip + Activate + Unequip
local function equipActivateUnequipCloak()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end

    local char = LocalPlayer.Character
    if not char then return end

    local tool = backpack:FindFirstChild("Invisibility Cloak")
    if not tool then
        warn("Invisibility Cloak not found in backpack")
        return
    end

    tool.Parent = char
    task.wait(0.3)
    tool:Activate()
    task.wait(0.1)

    if tool.Parent == char then
        tool.Parent = backpack
    end
end

-- UI Setup
local flyGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
flyGui.Name = "FlyToggleGui"
flyGui.ResetOnSpawn = false

local flyFrame = Instance.new("Frame", flyGui)
flyFrame.Size = UDim2.new(0, 140, 0, 90)
flyFrame.Position = UDim2.new(0.4, 0, 0.55, 0)
flyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
flyFrame.BorderSizePixel = 0
flyFrame.Active = true
flyFrame.Draggable = true
Instance.new("UICorner", flyFrame).CornerRadius = UDim.new(0, 16)

local flyTitle = Instance.new("TextLabel", flyFrame)
flyTitle.Size = UDim2.new(1, 0, 0.35, 0)
flyTitle.Position = UDim2.new(0, 0, 0, 6)
flyTitle.BackgroundTransparency = 1
flyTitle.Font = Enum.Font.GothamBold
flyTitle.Text = "Fly Mode"
flyTitle.TextSize = 14
flyTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
flyTitle.TextStrokeTransparency = 0.4

local flyToggle = Instance.new("Frame", flyFrame)
flyToggle.Size = UDim2.new(0, 50, 0, 26)
flyToggle.Position = UDim2.new(0.5, -25, 0.6, 0)
flyToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Instance.new("UICorner", flyToggle).CornerRadius = UDim.new(0, 13)

local flyKnob = Instance.new("Frame", flyToggle)
flyKnob.Size = UDim2.new(0, 22, 0, 22)
flyKnob.Position = UDim2.new(0, 2, 0, 2)
flyKnob.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", flyKnob).CornerRadius = UDim.new(0, 11)

-- Visual Toggle Update
local function updateFlyVisual(on)
    if on then
        TweenService:Create(flyKnob, tweenInfo, {Position = UDim2.new(1, -24, 0, 2)}):Play()
        TweenService:Create(flyKnob, tweenInfo, {BackgroundColor3 = Color3.fromRGB(255, 0, 0)}):Play()
        TweenService:Create(flyToggle, tweenInfo, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
    else
        TweenService:Create(flyKnob, tweenInfo, {Position = UDim2.new(0, 2, 0, 2)}):Play()
        TweenService:Create(flyKnob, tweenInfo, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
        TweenService:Create(flyToggle, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
    end
end

-- Toggle Input
flyToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        flyEnabled = not flyEnabled
        updateFlyVisual(flyEnabled)

        if flyEnabled then
            character = LocalPlayer.Character
            if not character then return end
            root = character:FindFirstChild("HumanoidRootPart")
            if not root then return end

            equipActivateUnequipCloak() -- Invisibility cloak usage on fly toggle

            BG = Instance.new("BodyGyro", root)
            BG.P = 9e4
            BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            BG.CFrame = root.CFrame

            BV = Instance.new("BodyVelocity", root)
            BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            BV.Velocity = Vector3.new(0, 0, 0)
        else
            if BG then BG:Destroy() end
            if BV then BV:Destroy() end
        end
    end
end)

-- Movement Input
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then Control.F = 1 end
    if input.KeyCode == Enum.KeyCode.S then Control.B = 1 end
    if input.KeyCode == Enum.KeyCode.A then Control.L = 1 end
    if input.KeyCode == Enum.KeyCode.D then Control.R = 1 end
    if input.KeyCode == Enum.KeyCode.Space then Control.U = 1 end
    if input.KeyCode == Enum.KeyCode.LeftControl then Control.D = 1 end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then Control.F = 0 end
    if input.KeyCode == Enum.KeyCode.S then Control.B = 0 end
    if input.KeyCode == Enum.KeyCode.A then Control.L = 0 end
    if input.KeyCode == Enum.KeyCode.D then Control.R = 0 end
    if input.KeyCode == Enum.KeyCode.Space then Control.U = 0 end
    if input.KeyCode == Enum.KeyCode.LeftControl then Control.D = 0 end
end)

-- Fly Movement Handler
RunService.Heartbeat:Connect(function()
    if flyEnabled and root and BV and BG then
        local cam = workspace.CurrentCamera
        local cf = cam.CFrame

        local dir = Vector3.new(Control.R - Control.L, Control.U - Control.D, Control.F - Control.B)
        if dir.Magnitude > 0 then
            local moveDirection = (cf.RightVector * dir.X + cf.UpVector * dir.Y + cf.LookVector * dir.Z).Unit
            BV.Velocity = moveDirection * flySpeed
            BG.CFrame = CFrame.new(Vector3.new(), cf.LookVector)
        else
            BV.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- Initialize toggle UI visual
updateFlyVisual(false)
