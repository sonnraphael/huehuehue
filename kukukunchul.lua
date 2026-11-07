local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local enemyFarmActive = false
local bossFarmActive = false
local rebirthFarmActive = false
local isFarmRunning = false

local enemyLoopCount = 3    
local bossPower = 50 
local bossLoop = 3  
local bossWaitTime = 30.0 -- Delay default setelah boss challenge (dalam detik)

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
-- PEMBUATAN INTERFACE GUI
-- ==========================================
local playerGui = player:WaitForChild("PlayerGui")
if playerGui:FindFirstChild("AutofarmMenu") then
	playerGui.AutofarmMenu:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutofarmMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 240, 0, 290) -- Tinggi Frame disesuaikan
Frame.AnchorPoint = Vector2.new(0.5, 0.5) 
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true      
Frame.Draggable = true   -- Membuat GUI dapat digerakkan bebas
Frame.ClipsDescendants = true 
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

-- Header Block (Selalu terlihat saat minimize)
local HeaderBar = Instance.new("Frame")
HeaderBar.Size = UDim2.new(1, 0, 0, 32)
HeaderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
HeaderBar.BorderSizePixel = 0
HeaderBar.Parent = Frame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = HeaderBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.75, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.Text = "TOWER AUTOFARM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = HeaderBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 24, 0, 24)
MinimizeButton.Position = UDim2.new(0.85, 0, 0.15, 0)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 18
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.Parent = HeaderBar

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 4)
MinimizeCorner.Parent = MinimizeButton

-- Container untuk seluruh menu isi di bawah header
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, 0, 1, -32)
ContentContainer.Position = UDim2.new(0, 0, 0, 32)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = Frame

-- 1. Enemy Farm Toggle & Textbox
local EnemyToggleBtn = Instance.new("TextButton")
EnemyToggleBtn.Size = UDim2.new(0.88, 0, 0, 26)
EnemyToggleBtn.Position = UDim2.new(0.06, 0, 0, 6)
EnemyToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
EnemyToggleBtn.Text = "Enemy Farm: OFF"
EnemyToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EnemyToggleBtn.TextSize = 12
EnemyToggleBtn.Font = Enum.Font.SourceSansBold
EnemyToggleBtn.Parent = ContentContainer

local EnemyCorner = Instance.new("UICorner")
EnemyCorner.CornerRadius = UDim.new(0, 6)
EnemyCorner.Parent = EnemyToggleBtn

local EnemyBox = Instance.new("TextBox")
EnemyBox.Size = UDim2.new(0.88, 0, 0, 22)
EnemyBox.Position = UDim2.new(0.06, 0, 0, 34)
EnemyBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
EnemyBox.BorderSizePixel = 0
EnemyBox.Text = tostring(enemyLoopCount)
EnemyBox.PlaceholderText = "Jumlah Loop Enemy"
EnemyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
EnemyBox.TextSize = 11
EnemyBox.Font = Enum.Font.SourceSansBold
EnemyBox.ClearTextOnFocus = false
EnemyBox.Parent = ContentContainer

local EnemyBoxCorner = Instance.new("UICorner")
EnemyBoxCorner.CornerRadius = UDim.new(0, 4)
EnemyBoxCorner.Parent = EnemyBox

-- 2. Boss Farm Toggle & Textbox Power
local BossToggleBtn = Instance.new("TextButton")
BossToggleBtn.Size = UDim2.new(0.88, 0, 0, 26)
BossToggleBtn.Position = UDim2.new(0.06, 0, 0, 60)
BossToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
BossToggleBtn.Text = "Boss Farm: OFF"
BossToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BossToggleBtn.TextSize = 12
BossToggleBtn.Font = Enum.Font.SourceSansBold
BossToggleBtn.Parent = ContentContainer

local BossCorner = Instance.new("UICorner")
BossCorner.CornerRadius = UDim.new(0, 6)
BossCorner.Parent = BossToggleBtn

local BossBox = Instance.new("TextBox")
BossBox.Size = UDim2.new(0.88, 0, 0, 22)
BossBox.Position = UDim2.new(0.06, 0, 0, 88)
BossBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
BossBox.BorderSizePixel = 0
BossBox.Text = tostring(bossPower)
BossBox.PlaceholderText = "Nilai Remote Boss"
BossBox.TextColor3 = Color3.fromRGB(255, 255, 255)
BossBox.TextSize = 11
BossBox.Font = Enum.Font.SourceSansBold
BossBox.ClearTextOnFocus = false
BossBox.Parent = ContentContainer

local BossBoxCorner = Instance.new("UICorner")
BossBoxCorner.CornerRadius = UDim.new(0, 4)
BossBoxCorner.Parent = BossBox

-- Textbox Boss Loop (Di bawah bossPower)
local BossLoopBox = Instance.new("TextBox")
BossLoopBox.Size = UDim2.new(0.88, 0, 0, 22)
BossLoopBox.Position = UDim2.new(0.06, 0, 0, 112)
BossLoopBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
BossLoopBox.BorderSizePixel = 0
BossLoopBox.Text = tostring(bossLoop)
BossLoopBox.PlaceholderText = "Jumlah Loop Boss"
BossLoopBox.TextColor3 = Color3.fromRGB(255, 255, 255)
BossLoopBox.TextSize = 11
BossLoopBox.Font = Enum.Font.SourceSansBold
BossLoopBox.ClearTextOnFocus = false
BossLoopBox.Parent = ContentContainer

local BossLoopBoxCorner = Instance.new("UICorner")
BossLoopBoxCorner.CornerRadius = UDim.new(0, 4)
BossLoopBoxCorner.Parent = BossLoopBox

-- Textbox Boss Wait Time (Pengatur delay task.wait boss)
local BossWaitBox = Instance.new("TextBox")
BossWaitBox.Size = UDim2.new(0.88, 0, 0, 22)
BossWaitBox.Position = UDim2.new(0.06, 0, 0, 136)
BossWaitBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
BossWaitBox.BorderSizePixel = 0
BossWaitBox.Text = tostring(bossWaitTime)
BossWaitBox.PlaceholderText = "Delay Boss Wait (detik)"
BossWaitBox.TextColor3 = Color3.fromRGB(255, 255, 255)
BossWaitBox.TextSize = 11
BossWaitBox.Font = Enum.Font.SourceSansBold
BossWaitBox.ClearTextOnFocus = false
BossWaitBox.Parent = ContentContainer

local BossWaitBoxCorner = Instance.new("UICorner")
BossWaitBoxCorner.CornerRadius = UDim.new(0, 4)
BossWaitBoxCorner.Parent = BossWaitBox

-- 3. Auto Rebirth Toggle
local RebirthToggleBtn = Instance.new("TextButton")
RebirthToggleBtn.Size = UDim2.new(0.88, 0, 0, 28)
RebirthToggleBtn.Position = UDim2.new(0.06, 0, 0, 164)
RebirthToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
RebirthToggleBtn.Text = "Auto Rebirth: OFF"
RebirthToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RebirthToggleBtn.TextSize = 12
RebirthToggleBtn.Font = Enum.Font.SourceSansBold
RebirthToggleBtn.Parent = ContentContainer

local RebirthCorner = Instance.new("UICorner")
RebirthCorner.CornerRadius = UDim.new(0, 6)
RebirthCorner.Parent = RebirthToggleBtn

-- Minimize / Maximize Logic
local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		Frame:TweenSize(UDim2.new(0, 240, 0, 32), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
		ContentContainer.Visible = false
		MinimizeButton.Text = "+"
	else
		Frame:TweenSize(UDim2.new(0, 240, 0, 290), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
		ContentContainer.Visible = true
		MinimizeButton.Text = "-"
	end
end)

EnemyBox.FocusLost:Connect(function()
	local num = tonumber(EnemyBox.Text)
	if num and num > 0 then
		enemyLoopCount = math.round(num)
		EnemyBox.Text = tostring(enemyLoopCount)
	else
		EnemyBox.Text = tostring(enemyLoopCount)
	end
end)

BossBox.FocusLost:Connect(function()
	local num = tonumber(BossBox.Text)
	if num then
		bossPower = math.round(num)
		BossBox.Text = tostring(bossPower)
	else
		BossBox.Text = tostring(bossPower)
	end
end)

BossLoopBox.FocusLost:Connect(function()
	local num = tonumber(BossLoopBox.Text)
	if num and num > 0 then
		bossLoop = math.round(num)
		BossLoopBox.Text = tostring(bossLoop)
	else
		BossLoopBox.Text = tostring(bossLoop)
	end
end)

BossWaitBox.FocusLost:Connect(function()
	local num = tonumber(BossWaitBox.Text)
	if num and num >= 0 then
		bossWaitTime = num
		BossWaitBox.Text = tostring(bossWaitTime)
	else
		BossWaitBox.Text = tostring(bossWaitTime)
	end
end)

-- ==========================================
-- MASTER FARM MANAGER
-- ==========================================
local function startFarmManager()
	if isFarmRunning then return end
	isFarmRunning = true

	task.spawn(function()
		while enemyFarmActive or bossFarmActive or rebirthFarmActive do
			-- 1. Jalankan Enemy Farm
			if enemyFarmActive then
				for r = 1, enemyLoopCount do
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
			end

			if not enemyFarmActive and not bossFarmActive and not rebirthFarmActive then break end

			-- 2. Jalankan Boss Farm
			if bossFarmActive then
				for k = 1, bossLoop do
					if not bossFarmActive then break end
					teleportToPosition(boss)
					
					task.wait(1.5)
					if not bossFarmActive then break end
					
					pcall(function() 
						Event2:FireServer(3, 4, bossPower) 
					end)
					
					task.wait(bossWaitTime) -- Menggunakan delay kustom dari TextBox
				end
			end
		  
			if not enemyFarmActive and not bossFarmActive and not rebirthFarmActive then break end

			-- 3. Jalankan Auto Rebirth Task
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

-- Event Tombol Auto Rebirth
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
