local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyToggleGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 140, 0, 90)
Frame.Position = UDim2.new(0.6, 0, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local frameCorner = Instance.new("UICorner", Frame)
frameCorner.CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.35, 0)
Title.Position = UDim2.new(0, 0, 0, 6)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "Fly Mode"
Title.TextSize = 14
Title.TextColor3 = Color3.fromRGB(180, 180, 180)
Title.TextStrokeTransparency = 0.4
Title.Parent = Frame

local ToggleFrame = Instance.new("Frame")
ToggleFrame.Size = UDim2.new(0, 50, 0, 26)
ToggleFrame.Position = UDim2.new(0.5, -25, 0.6, 0)
ToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleFrame.Parent = Frame

local toggleCorner = Instance.new("UICorner", ToggleFrame)
toggleCorner.CornerRadius = UDim.new(0, 13)

local ToggleKnob = Instance.new("Frame")
ToggleKnob.Size = UDim2.new(0, 22, 0, 22)
ToggleKnob.Position = UDim2.new(0, 2, 0, 2)
ToggleKnob.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleKnob.Parent = ToggleFrame

local knobCorner = Instance.new("UICorner", ToggleKnob)
knobCorner.CornerRadius = UDim.new(0, 11)

local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function updateToggleVisual(on)
	if on then
		TweenService:Create(ToggleKnob, tweenInfo, {Position = UDim2.new(1, -26, 0, 2)}):Play()
		TweenService:Create(ToggleKnob, tweenInfo, {BackgroundColor3 = Color3.fromRGB(255, 0, 0)}):Play()
		TweenService:Create(ToggleFrame, tweenInfo, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
	else
		TweenService:Create(ToggleKnob, tweenInfo, {Position = UDim2.new(0, 2, 0, 2)}):Play()
		TweenService:Create(ToggleKnob, tweenInfo, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
		TweenService:Create(ToggleFrame, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
	end
end

-- Flying + Speed Lock Variables
local flying = false
local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local maxSpeed = 50

-- Invisible pushing blocks setup
local pushBlocks = {}
local blockCount = 5
local blockDistance = 3
local blockSize = Vector3.new(2, 2, 2)

local function createPushBlocks(character)
	for i = 1, blockCount do
		local block = Instance.new("Part")
		block.Anchored = true
		block.CanCollide = true
		block.Size = blockSize
		block.Transparency = 1
		block.Name = "InvisiblePushBlock"
		block.Parent = workspace
		pushBlocks[i] = block
	end
end

local function updatePushBlocksPosition(character)
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	for i, block in pairs(pushBlocks) do
		local offset = Vector3.new((i - math.ceil(blockCount / 2)) * blockDistance, 0, 0)
		block.CFrame = root.CFrame * CFrame.new(offset)
	end
end

local function clearPushBlocks()
	for _, block in pairs(pushBlocks) do
		block:Destroy()
	end
	pushBlocks = {}
end

-- Fly logic
local function flyLoop()
	local character = LocalPlayer.Character
	if not character then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	local hum = character:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end

	local bodyVelocity = root:FindFirstChild("FlyBodyVelocity")
	if not bodyVelocity then
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Name = "FlyBodyVelocity"
		bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		bodyVelocity.Parent = root
	end

	RunService:BindToRenderStep("FlyStep", Enum.RenderPriority.Character.Value, function()
		if flying then
			local moveVector = Vector3.new(CONTROL.R - CONTROL.L, CONTROL.E - CONTROL.Q, CONTROL.F - CONTROL.B)
			local cam = workspace.CurrentCamera
			local lookVector = cam.CFrame.LookVector
			local rightVector = cam.CFrame.RightVector
			local upVector = Vector3.new(0,1,0)

			local velocity = (lookVector * (CONTROL.F - CONTROL.B) + rightVector * (CONTROL.R - CONTROL.L) + upVector * (CONTROL.E - CONTROL.Q)).Unit * maxSpeed
			if velocity ~= velocity then velocity = Vector3.new(0,0,0) end -- fix NaN if no input

			bodyVelocity.Velocity = velocity
		else
			bodyVelocity.Velocity = Vector3.new(0,0,0)
			RunService:UnbindFromRenderStep("FlyStep")
		end
	end)
end

-- Input handling for fly controls
UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 1
		elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = 1
		elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = 1
		elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = 1
		elseif input.KeyCode == Enum.KeyCode.E then CONTROL.E = 1
		elseif input.KeyCode == Enum.KeyCode.Q then CONTROL.Q = 1
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 0
		elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = 0
		elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = 0
		elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = 0
		elseif input.KeyCode == Enum.KeyCode.E then CONTROL.E = 0
		elseif input.KeyCode == Enum.KeyCode.Q then CONTROL.Q = 0
		end
	end
end)

local function enableFly()
	local char = LocalPlayer.Character
	if not char then return end

	createPushBlocks(char)
	flying = true
	flyLoop()
end

local function disableFly()
	flying = false
	clearPushBlocks()
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if root then
		local bodyVelocity = root:FindFirstChild("FlyBodyVelocity")
		if bodyVelocity then
			bodyVelocity:Destroy()
		end
	end
	RunService:UnbindFromRenderStep("FlyStep")
end

-- Toggle UI
local flyOn = false
ToggleFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		flyOn = not flyOn
		updateToggleVisual(flyOn)

		if flyOn then
			enableFly()
		else
			disableFly()
		end
	end
end)

-- Clean up on respawn
LocalPlayer.CharacterAdded:Connect(function()
	flyOn = false
	updateToggleVisual(false)
	disableFly()
end)

updateToggleVisual(false)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- GUI setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedLockGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 140, 0, 90)
Frame.Position = UDim2.new(0.4, 0, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local frameCorner = Instance.new("UICorner", Frame)
frameCorner.CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.35, 0)
Title.Position = UDim2.new(0, 0, 0, 6)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "Speed Lock"
Title.TextSize = 14
Title.TextColor3 = Color3.fromRGB(180, 180, 180)
Title.TextStrokeTransparency = 0.4
Title.Parent = Frame

local ToggleFrame = Instance.new("Frame")
ToggleFrame.Size = UDim2.new(0, 50, 0, 26)
ToggleFrame.Position = UDim2.new(0.5, -25, 0.6, 0)
ToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleFrame.Parent = Frame

local toggleCorner = Instance.new("UICorner", ToggleFrame)
toggleCorner.CornerRadius = UDim.new(0, 13)

local ToggleKnob = Instance.new("Frame")
ToggleKnob.Size = UDim2.new(0, 22, 0, 22)
ToggleKnob.Position = UDim2.new(0, 2, 0, 2)
ToggleKnob.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleKnob.Parent = ToggleFrame

local knobCorner = Instance.new("UICorner", ToggleKnob)
knobCorner.CornerRadius = UDim.new(0, 11)

-- Tween Info
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Toggle visuals function
local function updateToggleVisual(on)
	if on then
		TweenService:Create(ToggleKnob, tweenInfo, {Position = UDim2.new(1, -26, 0, 2)}):Play()
		TweenService:Create(ToggleKnob, tweenInfo, {BackgroundColor3 = Color3.fromRGB(255, 0, 0)}):Play()
		TweenService:Create(ToggleFrame, tweenInfo, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
	else
		TweenService:Create(ToggleKnob, tweenInfo, {Position = UDim2.new(0, 2, 0, 2)}):Play()
		TweenService:Create(ToggleKnob, tweenInfo, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
		TweenService:Create(ToggleFrame, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
	end
end

local freezeIsOn = false
local desiredSpeed = 105

-- Lock speed
local function lockSpeed()
	local char = LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	hum.WalkSpeed = desiredSpeed
	hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if freezeIsOn and hum.WalkSpeed ~= desiredSpeed then
			hum.WalkSpeed = desiredSpeed
		end
	end)
end

-- Reset speed
local function unlockSpeed()
	local char = LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	hum.WalkSpeed = 16
end

-- Equip + activate + unequip the cloak
local function activateCloak()
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	local char = LocalPlayer.Character
	if not backpack or not char then return end

	local tool = backpack:FindFirstChild("Invisibility Cloak")
	if not tool then
		warn("Invisibility Cloak not found in backpack")
		return
	end

	tool.Parent = char
	task.wait(0.1)
	tool:Activate()
	task.wait(0.1)
	if tool.Parent == char then
		tool.Parent = backpack
	end
end

-- Toggle handler
ToggleFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		freezeIsOn = not freezeIsOn
		updateToggleVisual(freezeIsOn)

		if freezeIsOn then
			lockSpeed()
			activateCloak()
		else
			unlockSpeed()
		end
	end
end)

-- Reset toggle OFF on respawn
LocalPlayer.CharacterAdded:Connect(function()
	freezeIsOn = false
	updateToggleVisual(false)
	unlockSpeed()
end)

-- Initialize toggle OFF
updateToggleVisual(false)
