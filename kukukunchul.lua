
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer


local function getCharacterParts()
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	local humanoid = char:WaitForChild("Humanoid", 5)
	return char, hrp, humanoid
end

local char, charhrp, humanoid = getCharacterParts()

player.CharacterAdded:Connect(function(newChar)
	char = newChar
	charhrp = newChar:WaitForChild("HumanoidRootPart", 5)
	humanoid = newChar:WaitForChild("Humanoid", 5)
end)

local enemy = Vector3.new(-43.25008773803711, 14.51099967956543, -156.47109985351562)
local boss = Vector3.new(-44.33367919921875, 27.178205490112305, -652.2608642578125)

local function teleportToPosition(targetPosition)
	-- Pastikan charhrp ada dan masih berada di dalam Workspace (belum hancur)
	if charhrp and charhrp.Parent then
		charhrp.CFrame = CFrame.new(targetPosition + Vector3.new(0, 3, 0))
	end
end


local rbxts = ReplicatedStorage:WaitForChild("rbxts_include", 15)
local node_modules = rbxts and rbxts:WaitForChild("node_modules", 15)
local rbxts_folder = node_modules and node_modules:WaitForChild("@rbxts", 15)
local remo = rbxts_folder and rbxts_folder:WaitForChild("remo", 15)
local container = remo and remo:WaitForChild("src", 15) and remo.src:WaitForChild("container", 15)

local Event = container and container:WaitForChild("attack", 15)
local Event2 = container and container:WaitForChild("startTimeLimitChallengeReq", 15)
local Event3 = container and container:WaitForChild("quitTimeLimitChallengeReq", 15)
local Event4 = container and container:WaitForChild("rebirth", 15)


local myEnv = (typeof(getgenv) == "function" and getgenv()) or _G
myEnv.AutofarmActive = false
myEnv.BossLoopCount = myEnv.BossLoopCount or 30 
local isMinimized = false


local existingGui = player:WaitForChild("PlayerGui"):FindFirstChild("AutofarmMenu")
if existingGui then
	existingGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutofarmMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local positionOpen = UDim2.new(0.5, 0, 0.85, 0)
local positionMin = UDim2.new(0.5, 0, 1, 55) 

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 140)
Frame.AnchorPoint = Vector2.new(0.5, 0.5) 
Frame.Position = positionOpen
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = false      
Frame.Draggable = false   
Frame.ClipsDescendants = true 
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.75, 0, 0, 30)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.Text = "TOWER AUTOFARM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 24, 0, 24)
MinimizeButton.Position = UDim2.new(0.85, 0, 0.03, 0)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 18
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.Parent = Frame

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 4)
MinimizeCorner.Parent = MinimizeButton

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.9, 0, 0, 35)
ToggleButton.Position = UDim2.new(0.05, 0, 0.25, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.Text = "Status: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = Frame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = ToggleButton

local InputLabel = Instance.new("TextLabel")
InputLabel.Size = UDim2.new(0.55, 0, 0, 30)
InputLabel.Position = UDim2.new(0.05, 0, 0.65, 0)
InputLabel.Text = "Boss Attack Loop:"
InputLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InputLabel.TextSize = 14
InputLabel.Font = Enum.Font.SourceSans
InputLabel.BackgroundTransparency = 1
InputLabel.TextXAlignment = Enum.TextXAlignment.Left
InputLabel.Parent = Frame

local AmountBox = Instance.new("TextBox")
AmountBox.Size = UDim2.new(0.3, 0, 0, 30)
AmountBox.Position = UDim2.new(0.65, 0, 0.65, 0)
AmountBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
AmountBox.BorderSizePixel = 0
AmountBox.Text = tostring(myEnv.BossLoopCount)
AmountBox.TextColor3 = Color3.fromRGB(255, 255, 255)
AmountBox.TextSize = 14
AmountBox.Font = Enum.Font.SourceSansBold
AmountBox.ClearTextOnFocus = false
AmountBox.Parent = Frame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 4)
BoxCorner.Parent = AmountBox

MinimizeButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		Frame:TweenPosition(positionMin, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
		MinimizeButton.Position = UDim2.new(0.85, 0, 0, 3)
		MinimizeButton.Text = "+"
	else
		Frame:TweenPosition(positionOpen, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
		MinimizeButton.Position = UDim2.new(0.85, 0, 0.03, 0)
		MinimizeButton.Text = "-"
	end
end)

AmountBox.FocusLost:Connect(function(enterPressed)
	local text = AmountBox.Text
	local number = tonumber(text)
	if number and number > 0 then
		local cleanNumber = math.round(number)
		myEnv.BossLoopCount = cleanNumber
		AmountBox.Text = tostring(cleanNumber)
	else
		AmountBox.Text = tostring(myEnv.BossLoopCount)
	end
end)


local function startAutofarmLoop()
	task.spawn(function()
		while myEnv.AutofarmActive do
			if not myEnv.AutofarmActive then break end
			
			if not humanoid or humanoid.Health <= 0 then
				task.wait(1)
				continue
			end

			task.wait(1)
			teleportToPosition(enemy)
			task.wait(1)

			for i = 1, 15 do
				if not myEnv.AutofarmActive then break end
				if Event then
					pcall(function()
						Event:FireServer(i)
					end)
				end
				task.wait(0.3)
			end 
			
			if not myEnv.AutofarmActive then break end
			task.wait(1)
			
			teleportToPosition(boss)
			task.wait(3)
			
			for i = 1, myEnv.BossLoopCount do
				if not myEnv.AutofarmActive then break end
				if Event2 then
					pcall(function()
						Event2:FireServer(3, 3, nil) 
					end)
				end
				task.wait(0.5)
			end
			
			if not myEnv.AutofarmActive then break end
			task.wait(1.5)
			
			if Event3 then
				pcall(function()
					Event3:FireServer()
				end)
			end
			
			task.wait(1.5)
			
			if Event4 then
				pcall(function()
					Event4:FireServer()
				end)
			end
			
			task.wait(3)
		end
	end)
end

ToggleButton.MouseButton1Click:Connect(function()
	myEnv.AutofarmActive = not myEnv.AutofarmActive
	if myEnv.AutofarmActive then
		ToggleButton.Text = "Status: ON"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		startAutofarmLoop()
	else
		ToggleButton.Text = "Status: OFF"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
end)l
