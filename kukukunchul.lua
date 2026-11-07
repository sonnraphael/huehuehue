-- ==========================================
-- TOWER AUTOFARM - DRAGGABLE GUI & BOTTOM TEXTBOX
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Variabel Status & Konfigurasi (Tanpa Caching)
local enemyFarmActive = false
local bossFarmActive = false
local rebirthFarmActive = false
local isFarmRunning = false

local enemyLoopCount = 1   -- Jumlah pengulangan farm enemy
local bossLoopCount = 30   -- Jumlah penaklukan boss

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
-- PEMBUATAN INTERFACE GUI (GERAK BEBAS & MINIMIZE BERSIH)
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
Frame.Size = UDim2.new(0, 240, 0, 240)
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

-- 1. Enemy Farm Toggle (Atas) & Textbox di Bawahnya
local EnemyToggleBtn = Instance.new("TextButton")
EnemyToggleBtn.Size = UDim2.new(0.88, 0, 0, 30)
EnemyToggleBtn.Position = UDim2.new(0.06, 0, 0.05, 0)
EnemyToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
EnemyToggleBtn.Text = "Enemy Farm: OFF"
EnemyToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EnemyToggleBtn.TextSize = 13
EnemyToggleBtn.Font = Enum.Font.SourceSansBold
EnemyToggleBtn.Parent = ContentContainer

local EnemyCorner = Instance.new("UICorner")
EnemyCorner.CornerRadius = UDim.new(0, 6)
EnemyCorner.Parent = EnemyToggleBtn

local EnemyBox = Instance.new("TextBox")
EnemyBox.Size = UDim2.new(0.88, 0, 0, 26)
EnemyBox.Position = UDim2.new(0.06, 0, 0.23, 0)
EnemyBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
EnemyBox.BorderSizePixel = 0
EnemyBox.Text = tostring(enemyLoopCount)
EnemyBox.PlaceholderText = "Jumlah Loop Enemy"
EnemyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
EnemyBox.TextSize = 12
EnemyBox.Font = Enum.Font.SourceSansBold
EnemyBox.ClearTextOnFocus = false
EnemyBox.Parent = ContentContainer

local EnemyBoxCorner = Instance.new("UICorner")
EnemyBoxCorner.CornerRadius = UDim.new(0, 4)
EnemyBoxCorner.Parent = EnemyBox

-- 2. Boss Farm Toggle (Tengah) & Textbox di Bawahnya
local BossToggleBtn = Instance.new("TextButton")
BossToggleBtn.Size = UDim2.new(0.88, 0, 0, 30)
BossToggleBtn.Position = UDim2.new(0.06, 0, 0.43, 0)
BossToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
BossToggleBtn.Text = "Boss Farm: OFF"
BossToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BossToggleBtn.TextSize = 13
BossToggleBtn.Font = Enum.Font.SourceSansBold
BossToggleBtn.Parent = ContentContainer

local BossCorner = Instance.new("UICorner")
BossCorner.CornerRadius = UDim.new(0, 6)
BossCorner.Parent = BossToggleBtn

local BossBox = Instance.new("TextBox")
BossBox.Size = UDim2.new(0.88, 0, 0, 26)
BossBox.Position = UDim2.new(0.06, 0, 0.61, 0)
BossBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
BossBox.BorderSizePixel = 0
BossBox.Text = tostring(bossLoopCount)
BossBox.PlaceholderText = "Jumlah Loop Boss"
BossBox.TextColor3 = Color3.fromRGB(255, 255, 255)
BossBox.TextSize = 12
BossBox.Font = Enum.Font.SourceSansBold
BossBox.ClearTextOnFocus = false
BossBox.Parent = ContentContainer

local BossBoxCorner = Instance.new("UICorner")
BossBoxCorner.CornerRadius = UDim.new(0, 4)
BossBoxCorner.Parent = BossBox

-- 3. Auto Rebirth Toggle (Bawah)
local RebirthToggleBtn = Instance.new("TextButton")
RebirthToggleBtn.Size = UDim2.new(0.88, 0, 0, 32)
RebirthToggleBtn.Position = UDim2.new(0.06, 0, 0.79, 0)
RebirthToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
RebirthToggleBtn.Text = "Auto Rebirth: OFF"
RebirthToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RebirthToggleBtn.TextSize = 13
RebirthToggleBtn.Font = Enum.Font.SourceSansBold
RebirthToggleBtn.Parent = ContentContainer

local RebirthCorner = Instance.new("UICorner")
RebirthCorner.CornerRadius = UDim.new(0, 6)
RebirthCorner.Parent = RebirthToggleBtn

-- Minimize / Maximize Logic (Menyisakan 1 Block Header)
local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		Frame:TweenSize(UDim2.new(0, 240, 0, 32), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
		ContentContainer.Visible = false
		MinimizeButton.Text = "+"
	else
		Frame:TweenSize(UDim2.new(0, 240, 0, 240), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
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
	if num and num > 0 then
		bossLoopCount = math.round(num)
		BossBox.Text = tostring(bossLoopCount)
	else
		BossBox.Text = tostring(bossLoopCount)
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
			-- 1. Jalankan Enemy Farm
			if enemyFarmActive then
				if not enemyFarmActive then return end
				
				for r = 1, enemyLoopCount do
					if not enemyFarmActive then return end
					teleportToPosition(enemy)
					
					task.wait(0.4)
					if not enemyFarmActive then return end
					
					for i = 1, 15 do
						if not enemyFarmActive then return end
						pcall(function() Event:FireServer(i) end)
						task.wait(0.2)
					end
					
					if not enemyFarmActive then return end
					task.wait(1.0)
				end
			end

			if not enemyFarmActive and not bossFarmActive and not rebirthFarmActive then break end

			-- 2. Jalankan Boss Farm
			if bossFarmActive then
				if not bossFarmActive then return end
				teleportToPosition(boss)
				
				task.wait(1.5)
				if not bossFarmActive then return end
				
				for i = 1, bossLoopCount do
					if not bossFarmActive then return end
					pcall(function() Event2:FireServer(3, 3, nil) end)
					task.wait(0.3)
				end
				
				task.wait(0.8)
			end

			if not enemyFarmActive and not bossFarmActive and not rebirthFarmActive then break end

			-- 3. Jalankan Auto Rebirth Task
			if rebirthFarmActive then
				if not rebirthFarmActive then return end
				pcall(function() Event3:FireServer() end)
				task.wait(0.8)
				
				if not rebirthFarmActive then return end
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
