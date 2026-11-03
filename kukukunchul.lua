local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local state = {
	Active = false,
	BossLoopCount = 30,
	LoopToken = 0,
}

local function waitForChild(parent, childName, timeout)
	timeout = timeout or 30
	local child = parent:FindFirstChild(childName)
	if child then
		return child
	end

	local result = parent:WaitForChild(childName, timeout)
	return result
end

local function getCharacter()
	local character = player.Character
	if character then
		return character
	end
	return player.CharacterAdded:Wait()
end

local function getHumanoidRootPart(character)
	if not character then
		character = getCharacter()
	end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		return hrp
	end

	return waitForChild(character, "HumanoidRootPart", 10)
end

local character = getCharacter()
local characterHRP = getHumanoidRootPart(character)

player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	characterHRP = getHumanoidRootPart(newCharacter)
end)

local enemy = Vector3.new(-43.25008773803711, 30.51099967956543, -156.47109985351562)
local boss = Vector3.new(-44.33367919921875, 27.178205490112305, -652.2608642578125)

local function teleportToPosition(targetPosition)
	if characterHRP then
		characterHRP.CFrame = CFrame.new(targetPosition)
	end
end

local function safeFireRemote(remote, ...)
	if remote and remote.Parent then
		remote:FireServer(...)
	end
end

local remoteNames = {
	"attack",
	"startTimeLimitChallengeReq",
	"quitTimeLimitChallengeReq",
	"rebirth",
}

local remotes = {}

for _, name in ipairs(remoteNames) do
	local remote = ReplicatedStorage:FindFirstChild(name, true)
	if remote then
		remotes[name] = remote
	end
end

local function getRemote(name)
	return remotes[name]
end

local function setStatusText(enabled)
	-- call this from UI code later
end

local function startAutofarmLoop()
	state.LoopToken += 1
	local token = state.LoopToken

	task.spawn(function()
		while state.Active and token == state.LoopToken do
			teleportToPosition(enemy)
			task.wait(1)

			for i = 2, 15 do
				if not state.Active or token ~= state.LoopToken then
					return
				end

				local attackRemote = getRemote("attack")
				if attackRemote then
					safeFireRemote(attackRemote, i)
				end

				task.wait(0.35)
			end

			if not state.Active or token ~= state.LoopToken then
				return
			end

			task.wait(0.5)
			teleportToPosition(boss)
			task.wait(1.5)

			for i = 1, state.BossLoopCount do
				if not state.Active or token ~= state.LoopToken then
					return
				end

				local startChallengeRemote = getRemote("startTimeLimitChallengeReq")
				if startChallengeRemote then
					safeFireRemote(startChallengeRemote, 3, 3, nil)
				end

				task.wait(0.8)
			end

			if not state.Active or token ~= state.LoopToken then
				return
			end

			task.wait(1)

			local quitRemote = getRemote("quitTimeLimitChallengeReq")
			if quitRemote then
				safeFireRemote(quitRemote)
			end

			task.wait(1)

			local rebirthRemote = getRemote("rebirth")
			if rebirthRemote then
				safeFireRemote(rebirthRemote)
			end

			task.wait(0.3)
		end
	end)
end

local function createGui()
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
	Frame.ClipsDescendants = true
	Frame.Parent = ScreenGui

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 8)
	Corner.Parent = Frame

	-- Title / Toggle / Input / Minimize button...
	return {
		Frame = Frame,
		ToggleButton = ToggleButton,
		AmountBox = AmountBox,
		MinimizeButton = MinimizeButton,
	}
end
