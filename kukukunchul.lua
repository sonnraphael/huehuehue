-- ==========================================
-- TOWER AUTOFARM - TIMING CHAIN & NO CACHING
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Variabel Lokal (Tanpa System Caching)
local autofarmActive = false
local bossLoopCount = 30

local char = player.Character or player.CharacterAdded:Wait()
local charhrp = char:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(newChar)
	char = newChar
	charhrp = newChar:WaitForChild("HumanoidRootPart")
end)

local enemy = Vector3.new(-43.25008773803711, 14.51099967956543, -156.47109985351562)
local boss = Vector3.new(-44.33367919921875, 27.178205490112305, -652.2608642578125)

local function teleportToPosition(targetPosition)
	if charhrp and charhrp.Parent then
		charhrp.CFrame = CFrame.new(targetPosition + Vector3.new(0, 3, 0))
	end
end

-- Ambil Remote Events
local container = ReplicatedStorage:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("remo"):WaitForChild("src"):WaitForChild("container")
local Event = container:WaitForChild("attack")
local Event2 = container:WaitForChild("startTimeLimitChallengeReq")
local Event3 = container:WaitForChild("quitTimeLimitChallengeReq")
local Event4 = container:WaitForChild("rebirth")

-- ==========================================
-- PEMBUATAN INTERFACE GUI + TEXTBOX
-- ==========================================
local playerGui = player:WaitForChild("PlayerGui")
if playerGui:FindFirstChild("AutofarmMenu") then
	playerGui.AutofarmMenu:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutofarmMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

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
AmountBox.Text = tostring(bossLoopCount)
AmountBox.TextColor3 = Color3.fromRGB(255, 255, 255)
AmountBox.TextSize = 14
AmountBox.Font = Enum.Font.SourceSansBold
AmountBox.ClearTextOnFocus = false
AmountBox.Parent = Frame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 4)
BoxCorner.Parent = AmountBox

local isMinimized = false
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

AmountBox.FocusLost:Connect(function()
	local number = tonumber(AmountBox.Text)
	if number and number > 0 then
		bossLoopCount = math.round(number)
		AmountBox.Text = tostring(bossLoopCount)
	else
		AmountBox.Text = tostring(bossLoopCount)
	end
end)

-- ==========================================
-- TIMING CHAIN AUTOFARM (DENGAN KALKULASI DURASI)
-- ==========================================
local function startAutofarmLoop()
	task.spawn(function()
		while autofarmActive do
			if not autofarmActive then break end

			-- -------------------------------------------------------------------------
			-- TASK 1: ENEMY PHASE
			-- Kalkulasi Durasi: 1s (wait) + 1s (settle) + (15 * 0.3s) + 1s (cooldown) = 7.5 detik
			-- -------------------------------------------------------------------------
			local enemyTaskDuration = 1 + 1 + (15 * 0.3) + 1
			task.spawn(function()
				task.wait(1)
				teleportToPosition(enemy)
				task.wait(1)
				for i = 1, 15 do
					if not autofarmActive then break end
					pcall(function() Event:FireServer(i) end)
					task.wait(0.3)
				end
				task.wait(1)
			end)
			task.wait(enemyTaskDuration + 1) -- Jeda waktu total task + 1 detik pemisah

			if not autofarmActive then break end

			-- -------------------------------------------------------------------------
			-- TASK 2: BOSS PHASE
			-- Kalkulasi Durasi: 3s (teleport settle) + (bossLoopCount * 0.5s) + 1.5s = 4.5s + (bossLoopCount * 0.5s)
			-- -------------------------------------------------------------------------
			local bossTaskDuration = 3 + (bossLoopCount * 0.5) + 1.5
			task.spawn(function()
				teleportToPosition(boss)
				task.wait(3)
				for i = 1, bossLoopCount do
					if not autofarmActive then break end
					pcall(function() Event2:FireServer(3, 3, nil) end)
					task.wait(0.5)
				end
				task.wait(1.5)
			end)
			task.wait(bossTaskDuration + 1) -- Jeda waktu total task + 1 detik pemisah

			if not autofarmActive then break end

			-- -------------------------------------------------------------------------
			-- TASK 3: QUIT & REBIRTH PHASE
			-- Kalkulasi Durasi: 1.5s (quit) + 1.5s (rebirth) + 3s (cooldown akhir) = 6 detik
			-- -------------------------------------------------------------------------
			local finishTaskDuration = 1.5 + 1.5 + 3
			task.spawn(function()
				pcall(function() Event3:FireServer() end)
				task.wait(1.5)
				pcall(function() Event4:FireServer() end)
				task.wait(1.5)
				task.wait(3)
			end)
			task.wait(finishTaskDuration + 1) -- Jeda waktu total task + 1 detik pemisah siklus berikutnya
		end
	end)
end

ToggleButton.MouseButton1Click:Connect(function()
	autofarmActive = not autofarmActive
	if autofarmActive then
		ToggleButton.Text = "Status: ON"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		startAutofarmLoop()
	else
		ToggleButton.Text = "Status: OFF"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
end)
