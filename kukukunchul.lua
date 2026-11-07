-- ==========================================
-- TOWER AUTOFARM - DUAL TOGGLE + AUTO REBIRTH
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Variabel Status Terpisah (Tanpa Caching)
local enemyFarmActive = false
local bossFarmActive = false
local rebirthFarmActive = false
local isFarmRunning = false
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
-- PEMBUATAN INTERFACE GUI (3 TOGGLE + INPUT)
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
Frame.Size = UDim2.new(0, 220, 0, 215) -- Dipertinggi untuk 3 tombol
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
Title.Size = UDim2.new(0.75, 0, 0, 25)
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
MinimizeButton.Position = UDim2.new(0.85, 0, 0.02, 0)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 18
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.Parent = Frame

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 4)
MinimizeCorner.Parent = MinimizeButton

-- Tombol 1: Enemy Farm Toggle
local EnemyToggleBtn = Instance.new("TextButton")
EnemyToggleBtn.Size = UDim2.new(0.9, 0, 0, 28)
EnemyToggleBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
EnemyToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
EnemyToggleBtn.Text = "Enemy Farm: OFF"
EnemyToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EnemyToggleBtn.TextSize = 13
EnemyToggleBtn.Font = Enum.Font.SourceSansBold
EnemyToggleBtn.Parent = Frame

local EnemyCorner = Instance.new("UICorner")
EnemyCorner.CornerRadius = UDim.new(0, 6)
EnemyCorner.Parent = EnemyToggleBtn

-- Tombol 2: Boss Farm Toggle
local BossToggleBtn = Instance.new("TextButton")
BossToggleBtn.Size = UDim2.new(0.9, 0, 0, 28)
BossToggleBtn.Position = UDim2.new(0.05, 0, 0.33, 0)
BossToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
BossToggleBtn.Text = "Boss Farm: OFF"
BossToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BossToggleBtn.TextSize = 13
BossToggleBtn.Font = Enum.Font.SourceSansBold
BossToggleBtn.Parent = Frame

local BossCorner = Instance.new("UICorner")
BossCorner.CornerRadius = UDim.new(0, 6)
BossCorner.Parent = BossToggleBtn

-- Tombol 3: Auto Rebirth Toggle (Baru)
local RebirthToggleBtn = Instance.new("TextButton")
RebirthToggleBtn.Size = UDim2.new(0.9, 0, 0, 28)
RebirthToggleBtn.Position = UDim2.new(0.05, 0, 0.51, 0)
RebirthToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
RebirthToggleBtn.Text = "Auto Rebirth: OFF"
RebirthToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RebirthToggleBtn.TextSize = 13
RebirthToggleBtn.Font = Enum.Font.SourceSansBold
RebirthToggleBtn.Parent = Frame

local RebirthCorner = Instance.new("UICorner")
RebirthCorner.CornerRadius = UDim.new(0, 6)
RebirthCorner.Parent = RebirthToggleBtn

local InputLabel = Instance.new("TextLabel")
InputLabel.Size = UDim2.new(0.55, 0, 0, 28)
InputLabel.Position = UDim2.new(0.05, 0, 0.74, 0)
InputLabel.Text = "Boss Attack Loop:"
InputLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InputLabel.TextSize = 13
InputLabel.Font = Enum.Font.SourceSans
InputLabel.BackgroundTransparency = 1
InputLabel.TextXAlignment = Enum.TextXAlignment.Left
InputLabel.Parent = Frame

local AmountBox = Instance.new("TextBox")
AmountBox.Size = UDim2.new(0.3, 0, 0, 26)
AmountBox.Position = UDim2.new(0.65, 0, 0.75, 0)
AmountBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
AmountBox.BorderSizePixel = 0
AmountBox.Text = tostring(bossLoopCount)
AmountBox.TextColor3 = Color3.fromRGB(255, 255, 255)
AmountBox.TextSize = 13
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
		MinimizeButton.Position = UDim2.new(0.85, 0, 0.02, 0)
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
-- MASTER FARM MANAGER (SISTEM GILIRAN / TURN-TAKING)
-- ==========================================
local function startFarmManager()
	if isFarmRunning then return end
	isFarmRunning = true

	task.spawn(function()
		while enemyFarmActive or bossFarmActive or rebirthFarmActive do
			-- 1. Jalankan Enemy Farm jika aktif
			if enemyFarmActive then
				if not enemyFarmActive then break end
				teleportToPosition(enemy)
				
				task.wait(0.4)
				if not enemyFarmActive then break end
				
				for i = 1, 15 do
					if not enemyFarmActive then break end
					pcall(function() Event:FireServer(i) end)
					task.wait(0.2)
				end
				
				if not enemyFarmActive then break end
				task.wait(1.0)
			end

			if not enemyFarmActive and not bossFarmActive and not rebirthFarmActive then break end

			-- 2. Jalankan Boss Farm jika aktif (Tanpa Event3 & Event4)
			if bossFarmActive then
				if not bossFarmActive then break end
				teleportToPosition(boss)
				
				task.wait(1.5)
				if not bossFarmActive then break end
				
				for i = 1, bossLoopCount do
					if not bossFarmActive then break end
					pcall(function() Event2:FireServer(3, 3, nil) end)
					task.wait(0.3)
				end
				
				task.wait(0.8)
			end

			if not enemyFarmActive and not bossFarmActive and not rebirthFarmActive then break end

			-- 3. Jalankan Auto Rebirth Task (Event3 & Event4 yang dipisahkan)
			if rebirthFarmActive then
				if not rebirthFarmActive then break end
				pcall(function() Event3:FireServer() end)
				task.wait(0.8)
				
				if not rebirthFarmActive then break end
				pcall(function() Event4:FireServer() end)
				task.wait(2.0)
			end
			
			task.wait(0.1)
		end
		isFarmRunning = false
	end)
end

-- Event Tombol Enemy Farm
EnemyToggleBtn.MouseButton1Click:Connect(function()
	enemyFarmActive = not enemyFarmActive
	if enemyFarmActive then
		EnemyToggleBtn.Text = "Enemy Farm: ON"
		EnemyToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		startFarmManager()
	else
		EnemyToggleBtn.Text = "Enemy Farm: OFF"
		EnemyToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
end)

-- Event Tombol Boss Farm
BossToggleBtn.MouseButton1Click:Connect(function()
	bossFarmActive = not bossFarmActive
	if bossFarmActive then
		BossToggleBtn.Text = "Boss Farm: ON"
		BossToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		startFarmManager()
	else
		BossToggleBtn.Text = "Boss Farm: OFF"
		BossToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
end)

-- Event Tombol Auto Rebirth (Baru)
RebirthToggleBtn.MouseButton1Click:Connect(function()
	rebirthFarmActive = not rebirthFarmActive
	if rebirthFarmActive then
		RebirthToggleBtn.Text = "Auto Rebirth: ON"
		RebirthToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		startFarmManager()
	else
		RebirthToggleBtn.Text = "Auto Rebirth: OFF"
		RebirthToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
end)
