local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

local function activateCloak()
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	local char = LocalPlayer.Character
	if not backpack or not char then return end
	local tool = backpack:FindFirstChild("Invisibility Cloak")
	if not tool then return end
	tool.Parent = char
	task.wait(0.1)
	tool:Activate()
	task.wait(0.1)
	if tool.Parent == char then
		tool.Parent = backpack
	end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedCloakGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 140, 0, 90)
Frame.Position = UDim2.new(0.6, 0, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.35, 0)
Title.Position = UDim2.new(0, 0, 0, 6)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "Super Speed"
Title.TextSize = 14
Title.TextColor3 = Color3.fromRGB(180, 180, 180)
Title.TextStrokeTransparency = 0.4
Title.Parent = Frame

local ToggleFrame = Instance.new("Frame")
ToggleFrame.Size = UDim2.new(0, 50, 0, 26)
ToggleFrame.Position = UDim2.new(0.5, -25, 0.6, 0)
ToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleFrame.Parent = Frame
Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 13)

local ToggleKnob = Instance.new("Frame")
ToggleKnob.Size = UDim2.new(0, 22, 0, 22)
ToggleKnob.Position = UDim2.new(0, 2, 0, 2)
ToggleKnob.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleKnob.Parent = ToggleFrame
Instance.new("UICorner", ToggleKnob).CornerRadius = UDim.new(1, 0)

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

local toggleOn = false
local speedBoost = 80
local connection
local cooldown = false

local function startSpeed()
	connection = RunService.Heartbeat:Connect(function()
		if Humanoid and HRP then
			local moveDir = Humanoid.MoveDirection
			if moveDir.Magnitude > 0 then
				local vel = HRP.Velocity
				-- Preserve Y velocity for jump/fall
				HRP.Velocity = Vector3.new(moveDir.X * speedBoost, vel.Y, moveDir.Z * speedBoost)
			else
				local vel = HRP.Velocity
				-- Stop horizontal movement but keep Y velocity (for gravity, jump)
				HRP.Velocity = Vector3.new(0, vel.Y, 0)
			end
		end
	end)
end

local function stopSpeed()
	if connection then
		connection:Disconnect()
		connection = nil
	end
end

ToggleFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and not cooldown then
		if toggleOn then
			toggleOn = false
			updateToggleVisual(false)
			stopSpeed()
			cooldown = true
			task.delay(2, function()
				cooldown = false
			end)
		else
			toggleOn = true
			updateToggleVisual(true)
			activateCloak()
			startSpeed()
		end
	end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	HRP = char:WaitForChild("HumanoidRootPart")
	stopSpeed()
	toggleOn = false
	updateToggleVisual(false)
	cooldown = false
end)


local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Equip + activate + unequip the cloak function
local function activateCloak()
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	local char = LocalPlayer.Character
	if not backpack or not char then return end
	local tool = backpack:FindFirstChild("Invisibility Cloak")
	if not tool then return end
	tool.Parent = char
	task.wait(0.1)
	tool:Activate()
	task.wait(0.1)
	if tool.Parent == char then
		tool.Parent = backpack
	end
end

-- GUI setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyToggleGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 140, 0, 90)
Frame.Position = UDim2.new(0.6, 0, 0.5, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.35, 0)
Title.Position = UDim2.new(0, 0, 0, 6)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "Fly"
Title.TextSize = 14
Title.TextColor3 = Color3.fromRGB(180, 180, 180)
Title.TextStrokeTransparency = 0.4
Title.Parent = Frame

local ToggleFrame = Instance.new("Frame")
ToggleFrame.Size = UDim2.new(0, 50, 0, 26)
ToggleFrame.Position = UDim2.new(0.5, -25, 0.6, 0)
ToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleFrame.Parent = Frame
Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 13)

local ToggleKnob = Instance.new("Frame")
ToggleKnob.Size = UDim2.new(0, 22, 0, 22)
ToggleKnob.Position = UDim2.new(0, 2, 0, 2)
ToggleKnob.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleKnob.Parent = ToggleFrame
Instance.new("UICorner", ToggleKnob).CornerRadius = UDim.new(0, 11)

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

local flying = false
local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local maxSpeed = 50

local function flyLoop()
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local bv = root:FindFirstChild("FlyBodyVelocity")
	if not bv then
		bv = Instance.new("BodyVelocity")
		bv.Name = "FlyBodyVelocity"
		bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bv.Velocity = Vector3.new(0, 0, 0)
		bv.Parent = root
	end

	RunService:BindToRenderStep("FlyStep", Enum.RenderPriority.Character.Value, function()
		if flying then
			local cam = workspace.CurrentCamera
			local v = (cam.CFrame.LookVector * (CONTROL.F - CONTROL.B) + cam.CFrame.RightVector * (CONTROL.R - CONTROL.L) + Vector3.new(0,1,0) * (CONTROL.E - CONTROL.Q))
			if v.Magnitude > 0 then
				bv.Velocity = v.Unit * maxSpeed
			else
				bv.Velocity = Vector3.new(0,0,0)
			end
		else
			bv.Velocity = Vector3.new(0,0,0)
			RunService:UnbindFromRenderStep("FlyStep")
		end
	end)
end

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
	flying = true
	activateCloak()
	flyLoop()
end

local function disableFly()
	flying = false
	local char = LocalPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if root then
		local bv = root:FindFirstChild("FlyBodyVelocity")
		if bv then bv:Destroy() end
	end
	RunService:UnbindFromRenderStep("FlyStep")
end

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

LocalPlayer.CharacterAdded:Connect(function()
	flyOn = false
	updateToggleVisual(false)
	disableFly()
end)

updateToggleVisual(false)
