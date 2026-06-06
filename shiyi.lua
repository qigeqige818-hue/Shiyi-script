local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShiyiGui"
screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local SECRET_KEY = "@1145114"  -- 密钥
-- 验证界面

-- 验证界面
local verifyFrame,keyInput,confirmButton
task.spawn(function()
    verifyFrame = screenGui:WaitForChild("VerifyFrame")
    keyInput = verifyFrame:WaitForChild("KeyInput")
    confirmButton = verifyFrame:WaitForChild("ConfirmButton")
end)

  
local dynamicIsland,leftLabel,fpsLabel
task.spawn(function()
    dynamicIsland = screenGui:WaitForChild("DynamicIsland")
    leftLabel = dynamicIsland:WaitForChild("LeftLabel")
    fpsLabel = dynamicIsland:WaitForChild("FPSLabel")
end)
-- ========== 检测是否为移动端 ==========  
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled  
  
-- ========== 全局状态 ==========  
local isVerified = false  
local mainPanel = nil  
local islandTween = nil  
local hue = 0  
  
-- 功能开关（保留你原来的所有功能）  
local features = {  
	silentAim = false,  
	aimbot = false,  
	triggerBot = false,  
	hitboxExtender = false,  
	hitboxSize = 2,  
	speedHack = false,  
	speedValue = 50,  
	spinSpeed = false,  
	spinValue = 10,  
	bunnyHop = false,  
	bunnyHopPower = 60,  
	orbit = false,  
	orbitRange = 10,  
	orbitSpeed = 5,  
	fly = false,  
	flySpeed = 50,  
	noClip = false,  
	infiniteJump = false,  
	esp = false,  
	tracers = false,  
	customCrosshair = false,  
	panelTransparency = 0.1,  
	showUserInfo = true,  
}  
  
local espObjects = {}  
local tracerLines = {}  
local orbitTarget = nil  
local orbitConnection = nil  
local speedConnection = nil  
local spinConnection = nil  
local bunnyHopConnection = nil  
local flyConnection = nil  
local noClipConnection = nil  
local aimbotConnection = nil  
local triggerBotConnection = nil  
local espConnection = nil  
local tracerConnection = nil  
local notificationQueue = {}  
  
-- ========== UI尺寸适配 ==========  
local function getScale()  
	if isMobile then  
		return 1.6  
	end  
	return 1  
end  
  
-- ========== 初始灵动岛 ==========  
if dynamicIsland then
    dynamicIsland.Visible = false --这里保留你原来true/false
end  
dynamicIsland.Size = UDim2.new(0.35, 0, 0.06, 0)  
local clickButton = Instance.new("TextButton")  
clickButton.Size = UDim2.new(1, 0, 1, 0)  
clickButton.BackgroundTransparency = 1  
clickButton.Text = ""  
clickButton.Parent = dynamicIsland  
  
-- ========== FPS + 彩虹文字 ==========  
RunService.RenderStepped:Connect(function(deltaTime)  
	if dynamicIsland.Visible then  
		hue = (hue + deltaTime * 0.3) % 1  
		leftLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)  
		leftLabel.TextStrokeColor3 = Color3.fromHSV((hue + 0.5) % 1, 0.8, 1)  
	end  
	if deltaTime > 0 then  
		fpsLabel.Text = math.floor(1 / deltaTime) .. " FPS"  
	end  
end)  
  
-- ========== 功能提示系统 ==========  
local function showNotification(text, isOn)  
	local s = getScale()  
	local notif = Instance.new("Frame")  
	notif.Size = UDim2.new(0, 200 * s, 0, 35 * s)  
	notif.Position = UDim2.new(0.5, 0, 0.08, 0)  
	notif.AnchorPoint = Vector2.new(0.5, 0)  
	notif.BackgroundColor3 = Color3.fromRGB(15, 15, 15)  
	notif.BackgroundTransparency = 0.1  
	notif.BorderSizePixel = 0  
	notif.ZIndex = 100  
	notif.Parent = screenGui  
  
	local notifCorner = Instance.new("UICorner")  
	notifCorner.CornerRadius = UDim.new(0, 10 * s)  
	notifCorner.Parent = notif  
  
	local icon = Instance.new("TextLabel")  
	icon.Size = UDim2.new(0, 30 * s, 1, 0)  
	icon.Position = UDim2.new(0, 8 * s, 0, 0)  
	icon.BackgroundTransparency = 1  
	icon.Text = isOn and "✓" or "✗"  
	icon.TextColor3 = isOn and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 80, 80)  
	icon.TextSize = 18 * s  
	icon.Font = Enum.Font.GothamBold  
	icon.ZIndex = 101  
	icon.Parent = notif  
  
	local textLabel = Instance.new("TextLabel")  
	textLabel.Size = UDim2.new(1, -35 * s, 1, 0)  
	textLabel.Position = UDim2.new(0, 35 * s, 0, 0)  
	textLabel.BackgroundTransparency = 1  
	textLabel.Text = text  
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)  
	textLabel.TextSize = 14 * s  
	textLabel.TextXAlignment = Enum.TextXAlignment.Left  
	textLabel.Font = Enum.Font.GothamBold  
	textLabel.ZIndex = 101  
	textLabel.Parent = notif  
  
	-- 动画  
	notif.Position = UDim2.new(0.5, 0, -0.1, 0)  
	local slideIn = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0.08, 0) })  
	slideIn:Play()  
  
	task.wait(1.8)  
	local fadeOut = TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { BackgroundTransparency = 1 })  
	fadeOut:Play()  
	for _, child in ipairs(notif:GetChildren()) do  
		if child:IsA("TextLabel") then  
			local t = TweenService:Create(child, TweenInfo.new(0.5), { TextTransparency = 1 })  
			t:Play()  
		end  
	end  
	fadeOut.Completed:Connect(function()  
		notif:Destroy()  
	end)  
end  
  
-- ========== 辅助函数 ==========  
local function getAccountAge()  
	return player.AccountAge // 86400  
end  
  
local function getNearestPlayer(range)  
	local nearest = nil  
	local minDist = range or math.huge  
	local char = player.Character  
	if not char then return nil end  
	local root = char:FindFirstChild("HumanoidRootPart")  
	if not root then return nil end  
	for _, p in ipairs(Players:GetPlayers()) do  
		if p ~= player and p.Character then  
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")  
			local hum = p.Character:FindFirstChild("Humanoid")  
			if hrp and hum and hum.Health > 0 then  
				local dist = (hrp.Position - root.Position).Magnitude  
				if dist < minDist then  
					minDist = dist  
					nearest = p  
				end  
			end  
		end  
	end  
	return nearest  
end  
  
-- ========== 功能实现（保留你原来的所有逻辑） ==========  
local function enableSilentAim()  
	local mt = getrawmetatable(game)  
	local oldNamecall = mt.__namecall  
	setreadonly(mt, false)  
	mt.__namecall = newcclosure(function(self, ...)  
		local args = {...}  
		local method = getnamecallmethod()  
		if method == "FireServer" and self.Name == "RemoteEvent" and features.silentAim then  
			local target = getNearestPlayer(500)  
			if target and target.Character and target.Character:FindFirstChild("Head") then  
				args[2] = target.Character.Head.Position  
			end  
		end  
		return oldNamecall(self, unpack(args))  
	end)  
end  
enableSilentAim()  
  
local function toggleAimbot(v)  
	features.aimbot = v  
	if v then  
		aimbotConnection = RunService.RenderStepped:Connect(function()  
			if features.aimbot then  
				local target = getNearestPlayer(500)  
				if target and target.Character and target.Character:FindFirstChild("Head") then  
					local pos = Camera:WorldToViewportPoint(target.Character.Head.Position)  
					local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)  
					if not isMobile then  
						mousemoverel(pos.X - center.X, pos.Y - center.Y)  
					else  
						local direction = (target.Character.Head.Position - Camera.CFrame.Position).Unit  
						Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction)  
					end  
				end  
			end  
		end)  
	else  
		if aimbotConnection then aimbotConnection:Disconnect() end  
	end  
	showNotification("锁定自瞄", v)  
end  
  
local function toggleTriggerBot(v)  
	features.triggerBot = v  
	if v then  
		triggerBotConnection = RunService.RenderStepped:Connect(function()  
			local target = getNearestPlayer(300)  
			if target and target.Character and target.Character:FindFirstChild("Head") then  
				local pos = Camera:WorldToViewportPoint(target.Character.Head.Position)  
				local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)  
				if (pos - center).Magnitude < 30 then  
					mouse1click()  
				end  
			end  
		end)  
	else  
		if triggerBotConnection then triggerBotConnection:Disconnect() end  
	end  
	showNotification("自动扳机", v)  
end  
  
local function toggleHitboxExtender(v)  
	features.hitboxExtender = v  
	for _, p in ipairs(Players:GetPlayers()) do  
		if p ~= player and p.Character then  
			for _, part in ipairs(p.Character:GetChildren()) do  
				if part:IsA("BasePart") then  
					if v then  
						part.Size = part.Size * features.hitboxSize  
						part.Transparency = 0.5  
					end  
				end  
			end  
		end  
	end  
	showNotification("扩大命中框", v)  
end  
  
local function toggleSpeedHack(v)  
	features.speedHack = v  
	if v then  
		speedConnection = RunService.Heartbeat:Connect(function()  
			if player.Character and player.Character:FindFirstChild("Humanoid") then  
				player.Character.Humanoid.WalkSpeed = features.speedValue  
			end  
		end)  
	else  
		if speedConnection then speedConnection:Disconnect() end  
		if player.Character and player.Character:FindFirstChild("Humanoid") then  
			player.Character.Humanoid.WalkSpeed = 16  
		end  
	end  
	showNotification("人物加速", v)  
end  
  
local function toggleSpinSpeed(v)  
	features.spinSpeed = v  
	if v then  
		spinConnection = RunService.Heartbeat:Connect(function()  
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then  
				local root = player.Character.HumanoidRootPart  
				root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(features.spinValue), 0)  
			end  
		end)  
	else  
		if spinConnection then spinConnection:Disconnect() end  
	end  
	showNotification("人物旋转", v)  
end  
  
local wasInAir = false  
local function toggleBunnyHop(v)  
	features.bunnyHop = v  
	if v then  
		bunnyHopConnection = RunService.Heartbeat:Connect(function()  
			if player.Character then  
				local hum = player.Character:FindFirstChild("Humanoid")  
				local root = player.Character:FindFirstChild("HumanoidRootPart")  
				if hum and root then  
					local inAir = hum:GetState() == Enum.HumanoidStateType.Freefall  
						or hum:GetState() == Enum.HumanoidStateType.Jumping  
					if wasInAir and not inAir then  
						hum.Jump = true  
						root.Velocity = Vector3.new(root.Velocity.X, features.bunnyHopPower, root.Velocity.Z)  
					end  
					wasInAir = inAir  
				end  
			end  
		end)  
	else  
		if bunnyHopConnection then bunnyHopConnection:Disconnect() end  
		wasInAir = false  
	end  
	showNotification("兔子跳", v)  
end  
  
local function toggleOrbit(v)  
	features.orbit = v  
	if v then  
		orbitConnection = RunService.Heartbeat:Connect(function()  
			local target = orbitTarget  
			if not target or not target.Character or not target.Character:FindFirstChild("Humanoid") or target.Character.Humanoid.Health <= 0 then  
				target = getNearestPlayer(1000)  
				orbitTarget = target  
			end  
			if target and target.Character and player.Character then  
				local root = player.Character:FindFirstChild("HumanoidRootPart")  
				local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")  
				if root and targetRoot then  
					local angle = tick() * features.orbitSpeed  
					local offset = Vector3.new(math.cos(angle) * features.orbitRange, 0, math.sin(angle) * features.orbitRange)  
					root.CFrame = CFrame.new(targetRoot.Position + offset + Vector3.new(0, 5, 0))  
				end  
			end  
		end)  
	else  
		if orbitConnection then orbitConnection:Disconnect() end  
		orbitTarget = nil  
	end  
	showNotification("环绕敌人", v)  
end  
  
local function toggleFly(v)  
	features.fly = v  
	if v then  
		local char = player.Character  
		if char and char:FindFirstChild("HumanoidRootPart") then  
			local root = char.HumanoidRootPart  
			local bodyGyro = Instance.new("BodyGyro")  
			bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)  
			bodyGyro.P = 3000  
			bodyGyro.CFrame = root.CFrame  
			bodyGyro.Parent = root  
			local bodyVel = Instance.new("BodyVelocity")  
			bodyVel.MaxForce = Vector3.new(400000, 400000, 400000)  
			bodyVel.Velocity = Vector3.new(0, 0, 0)  
			bodyVel.Parent = root  
  
			if isMobile then  
				local hum = char:FindFirstChild("Humanoid")  
				flyConnection = RunService.Heartbeat:Connect(function()  
					local moveDir = Vector3.new(0, 0, 0)  
					if hum and hum.MoveDirection.Magnitude > 0 then  
						moveDir = hum.MoveDirection * features.flySpeed  
					end  
					if hum and hum.Jump then  
						moveDir = moveDir + Vector3.new(0, features.flySpeed, 0)  
					end  
					bodyVel.Velocity = moveDir  
					bodyGyro.CFrame = Camera.CFrame  
				end)  
			else  
				flyConnection = RunService.Heartbeat:Connect(function()  
					local moveDir = Vector3.new(0, 0, 0)  
					if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end  
					if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end  
					if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end  
					if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end  
					if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end  
					if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end  
					bodyVel.Velocity = moveDir * features.flySpeed  
					bodyGyro.CFrame = Camera.CFrame  
				end)  
			end  
		end  
	else  
		if flyConnection then flyConnection:Disconnect() end  
		if player.Character then  
			local root = player.Character:FindFirstChild("HumanoidRootPart")  
			if root then  
				local bg = root:FindFirstChild("BodyGyro")  
				local bv = root:FindFirstChild("BodyVelocity")  
				if bg then bg:Destroy() end  
				if bv then bv:Destroy() end  
			end  
		end  
	end  
	showNotification("飞行", v)  
end  
  
local function toggleNoClip(v)  
	features.noClip = v  
	if v then  
		noClipConnection = RunService.Stepped:Connect(function()  
			if player.Character then  
				for _, part in ipairs(player.Character:GetDescendants()) do  
					if part:IsA("BasePart") then part.CanCollide = false end  
				end  
			end  
		end)  
	else  
		if noClipConnection then noClipConnection:Disconnect() end  
		if player.Character then  
			for _, part in ipairs(player.Character:GetDescendants()) do  
				if part:IsA("BasePart") then part.CanCollide = true end  
			end  
		end  
	end  
	showNotification("穿墙", v)  
end  
  
local function toggleInfiniteJump(v)  
	features.infiniteJump = v  
	if player.Character and player.Character:FindFirstChild("Humanoid") then  
		player.Character.Humanoid.UseJumpPower = not v  
		if v then player.Character.Humanoid.JumpPower = 100 end  
	end  
	showNotification("无限跳", v)  
end  
  
local function toggleESP(v)  
	features.esp = v  
	if v then  
		espConnection = RunService.RenderStepped:Connect(function()  
			for _, obj in ipairs(espObjects) do if obj then obj:Destroy() end end  
			espObjects = {}  
			for _, p in ipairs(Players:GetPlayers()) do  
				if p ~= player and p.Character and p.Character:FindFirstChild("Head") then  
					local head = p.Character.Head  
					local pos, onScreen = Camera:WorldToViewportPoint(head.Position)  
					if onScreen then  
						local box = Instance.new("Frame")  
						box.Size = UDim2.new(0, 40, 0, 60)  
						box.Position = UDim2.new(0, pos.X - 20, 0, pos.Y - 70)  
						box.BackgroundTransparency = 0.7  
						box.BorderColor3 = Color3.fromRGB(255, 0, 0)  
						box.BorderSizePixel = 2  
						box.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  
						box.Parent = screenGui  
						table.insert(espObjects, box)  
						local nameLabel = Instance.new("TextLabel")  
						nameLabel.Size = UDim2.new(1, 0, 0, 16)  
						nameLabel.Position = UDim2.new(0, 0, 0, -18)  
						nameLabel.BackgroundTransparency = 1  
						nameLabel.Text = p.Name  
						nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)  
						nameLabel.TextSize = 12  
						nameLabel.Parent = box  
					end  
				end  
			end  
		end)  
	else  
		if espConnection then espConnection:Disconnect() end  
		for _, obj in ipairs(espObjects) do if obj then obj:Destroy() end end  
		espObjects = {}  
	end  
	showNotification("ESP透视", v)  
end  
  
local function toggleTracers(v)  
	features.tracers = v  
	if v then  
		tracerConnection = RunService.RenderStepped:Connect(function()  
			for _, line in ipairs(tracerLines) do if line then line:Destroy() end end  
			tracerLines = {}  
			for _, p in ipairs(Players:GetPlayers()) do  
				if p ~= player and p.Character and p.Character:FindFirstChild("Head") then  
					local pos = Camera:WorldToViewportPoint(p.Character.Head.Position)  
					if pos.Z > 0 then  
						local line = Instance.new("Frame")  
						line.Size = UDim2.new(0, 1, 0, pos.Y)  
						line.Position = UDim2.new(0, pos.X, 0, 0)  
						line.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  
						line.BorderSizePixel = 0  
						line.Parent = screenGui  
						table.insert(tracerLines, line)  
					end  
				end  
			end  
		end)  
	else  
		if tracerConnection then tracerConnection:Disconnect() end  
		for _, line in ipairs(tracerLines) do if line then line:Destroy() end end  
		tracerLines = {}  
	end  
	showNotification("射线", v)  
end  
  
local function toggleCrosshair(v)  
	features.customCrosshair = v  
	local name = "CustomCrosshair"  
	local existing = screenGui:FindFirstChild(name)  
	if v then  
		if not existing then  
			local cross = Instance.new("Frame")  
			cross.Name = name  
			cross.Size = UDim2.new(0, 24, 0, 24)  
			cross.Position = UDim2.new(0.5, -12, 0.5, -12)  
			cross.BackgroundTransparency = 1  
			cross.ZIndex = 50  
			cross.Parent = screenGui  
			local h = Instance.new("Frame")  
			h.Size = UDim2.new(1, 0, 0, 2)  
			h.Position = UDim2.new(0, 0, 0.5, -1)  
			h.BackgroundColor3 = Color3.fromRGB(0, 255, 0)  
			h.Parent = cross  
			local vLine = Instance.new("Frame")  
			vLine.Size = UDim2.new(0, 2, 1, 0)  
			vLine.Position = UDim2.new(0.5, -1, 0, 0)  
			vLine.BackgroundColor3 = Color3.fromRGB(0, 255, 0)  
			vLine.Parent = cross  
		end  
	else  
		if existing then existing:Destroy() end  
	end  
	showNotification("自定义准星", v)  
end  
  
local function serverHop()  
	showNotification("正在搜索服务器...", true)  
	local success, result = pcall(function()  
		return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"))  
	end)  
	if success and result and result.data then  
		for _, server in ipairs(result.data) do  
			if server.playing < server.maxPlayers then  
				TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, player)  
				return  
			end  
		end  
	end  
	showNotification("未找到可用服务器", false)  
end  
  
-- ========== 动画 ==========  
local collapseInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In)  
local expandInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)  
local function hideIsland()  
	if islandTween then islandTween:Cancel() end  
	islandTween = TweenService:Create(dynamicIsland, collapseInfo, { Size = UDim2.new(0, 0, 0, 0) })  
	islandTween:Play()  
	islandTween.Completed:Connect(function()  
		dynamicIsland.Visible = false  
		islandTween = nil  
	end)  
end  
local function showIsland()  
	dynamicIsland.Visible = true  
	if islandTween then islandTween:Cancel() end  
	islandTween = TweenService:Create(dynamicIsland, expandInfo, { Size = UDim2.new(0.35, 0, 0.06, 0) })  
	islandTween:Play()  
	islandTween.Completed:Connect(function()  
		islandTween = nil  
	end)  
end  
  
-- ========== 拖动系统 ==========  
local function makeDraggable(frame, dragHandle)  
	local dragging = false  
	local dragStart = nil  
	local startPos = nil  
	dragHandle.InputBegan:Connect(function(input)  
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
			dragging = true  
			dragStart = input.Position  
			startPos = frame.Position  
		end  
	end)  
	dragHandle.InputEnded:Connect(function(input)  
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
			dragging = false  
		end  
	end)  
	UserInputService.InputChanged:Connect(function(input)  
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then  
			local delta = input.Position - dragStart  
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)  
		end  
	end)  
end  
  
-- ========== 核心：Galaxy风格UI创建 ==========  
local function createMainPanel()  
	if mainPanel then mainPanel:Destroy() end  
	local s = getScale()  
	local panelWidth = isMobile and 0.75 or 0.55  
	local panelHeight = isMobile and 0.7 or 0.75  
  
	-- 主面板整体  
	mainPanel = Instance.new("Frame")  
	mainPanel.Name = "MainPanel"  
	mainPanel.Size = UDim2.new(panelWidth, 0, panelHeight, 0)  
	mainPanel.Position = UDim2.new(0.5, 0, 0.5, 0)  
	mainPanel.AnchorPoint = Vector2.new(0.5, 0.5)  
	mainPanel.BackgroundColor3 = Color3.fromRGB(30, 32, 40)  
	mainPanel.BackgroundTransparency = features.panelTransparency  
	mainPanel.BorderSizePixel = 0  
	mainPanel.ClipsDescendants = true  
	mainPanel.Active = true  
	mainPanel.ZIndex = 10  
	mainPanel.Parent = screenGui  
  
	local mainCorner = Instance.new("UICorner")  
	mainCorner.CornerRadius = UDim.new(0, 16 * s)  
	mainCorner.Parent = mainPanel  
  
	-- 顶部标题栏（可拖动）  
	local topBar = Instance.new("Frame")  
	topBar.Size = UDim2.new(1, 0, 0, 45 * s)  
	topBar.BackgroundColor3 = Color3.fromRGB(35, 38, 48)  
	topBar.BorderSizePixel = 0  
	topBar.Active = true  
	topBar.Parent = mainPanel  
	local topCorner = Instance.new("UICorner")  
	topCorner.CornerRadius = UDim.new(0, 16 * s)  
	topCorner.Parent = topBar  
	local topCover = Instance.new("Frame")  
	topCover.Size = UDim2.new(1, 0, 0.5, 0)  
	topCover.Position = UDim2.new(0, 0, 0.5, 0)  
	topCover.BackgroundColor3 = Color3.fromRGB(35, 38, 48)  
	topCover.BorderSizePixel = 0  
	topCover.Parent = topBar  
	makeDraggable(mainPanel, topBar)  
  
	-- 标题文字  
	local title = Instance.new("TextLabel")  
	title.Size = UDim2.new(0.4, 0, 1, 0)  
	title.Position = UDim2.new(0, 12 * s, 0, 0)  
	title.BackgroundTransparency = 1  
	title.Text = "Galaxy\nversion 2.0.1"  
	title.TextColor3 = Color3.fromRGB(255, 255, 255)  
	title.TextSize = 16 * s  
	title.Font = Enum.Font.GothamBold  
	title.TextXAlignment = Enum.TextXAlignment.Left  
	title.TextYAlignment = Enum.TextYAlignment.Center  
	title.Parent = topBar  
  
	-- 关闭按钮  
	local closeBtn = Instance.new("TextButton")  
	closeBtn.Size = UDim2.new(0, 28 * s, 0, 28 * s)  
	closeBtn.Position = UDim2.new(1, -34 * s, 0.5, -14 * s)  
	closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)  
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)  
	closeBtn.Text = "✕"  
	closeBtn.TextSize = 14 * s  
	closeBtn.Font = Enum.Font.GothamBold  
	closeBtn.ZIndex = 11  
	closeBtn.Parent = topBar  
	local closeCorner = Instance.new("UICorner")  
	closeCorner.CornerRadius = UDim.new(0, 8 * s)  
	closeCorner.Parent = closeBtn  
	closeBtn.MouseButton1Click:Connect(function()  
		if mainPanel then mainPanel:Destroy(); mainPanel = nil end  
		showIsland()  
	end)  
  
	-- 左侧导航栏  
	local sidebar = Instance.new("Frame")  
	sidebar.Size = UDim2.new(0.3, 0, 1, -45 * s)  
	sidebar.Position = UDim2.new(0, 0, 0, 45 * s)  
	sidebar.BackgroundColor3 = Color3.fromRGB(25, 27, 35)  
	sidebar.BorderSizePixel = 0  
	sidebar.Parent = mainPanel  
	local sideCorner = Instance.new("UICorner")  
	sideCorner.CornerRadius = UDim.new(0, 16 * s)  
	sideCorner.Parent = sidebar  
	local sideCover = Instance.new("Frame")  
	sideCover.Size = UDim2.new(0.5, 0, 1, 0)  
	sideCover.Position = UDim2.new(0.5, 0, 0, 0)  
	sideCover.BackgroundColor3 = Color3.fromRGB(25, 27, 35)  
	sideCover.BorderSizePixel = 0  
	sideCover.Parent = sidebar  
  
	-- 右侧网格内容区  
	local contentArea = Instance.new("Frame")  
	contentArea.Size = UDim2.new(0.7, 0, 1, -45 * s)  
	contentArea.Position = UDim2.new(0.3, 0, 0, 45 * s)  
	contentArea.BackgroundColor3 = Color3.fromRGB(30, 32, 40)  
	contentArea.BorderSizePixel = 0  
	contentArea.Parent = mainPanel  
	local contentCorner = Instance.new("UICorner")  
	contentCorner.CornerRadius = UDim.new(0, 12 * s)  
	contentCorner.Parent = contentArea  
  
	local scrollFrame = Instance.new("ScrollingFrame")  
	scrollFrame.Size = UDim2.new(1, -10 * s, 1, -10 * s)  
	scrollFrame.Position = UDim2.new(0, 5 * s, 0, 5 * s)  
	scrollFrame.BackgroundTransparency = 1  
	scrollFrame.BorderSizePixel = 0  
	scrollFrame.ScrollBarThickness = 4 * s  
	scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)  
	scrollFrame.CanvasSize = UDim2.new(0, 0, 2, 0)  
	scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y  
	scrollFrame.ElasticBehavior = Enum.ElasticBehavior.Always  
	scrollFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always  
	scrollFrame.Parent = contentArea  
  
	local contentContainer = Instance.new("Frame")  
	contentContainer.Size = UDim2.new(1, 0, 2, 0)  
	contentContainer.BackgroundTransparency = 1  
	contentContainer.Parent = scrollFrame  
  
	-- ===== 创建网格功能按钮（和示例一样的卡片样式） =====  
	local function createGridButton(parent, iconText, name, desc, callback, x, y)  
		local btn = Instance.new("TextButton")  
		btn.Size = UDim2.new(0.31, 0, 0, 65 * s)  
		btn.Position = UDim2.new(x, 0, 0, y)  
		btn.BackgroundColor3 = Color3.fromRGB(40, 42, 50)  
		btn.BorderSizePixel = 0  
		btn.ZIndex = 11  
		btn.Parent = parent  
  
		local btnCorner = Instance.new("UICorner")  
		btnCorner.CornerRadius = UDim.new(0, 10 * s)  
		btnCorner.Parent = btn  
  
		-- 图标  
		local icon = Instance.new("TextLabel")  
		icon.Size = UDim2.new(0, 24 * s, 0, 24 * s)  
		icon.Position = UDim2.new(0.1, 0, 0.15, 0)  
		icon.BackgroundTransparency = 1  
		icon.Text = iconText  
		icon.TextColor3 = Color3.fromRGB(200, 200, 200)  
		icon.TextSize = 18 * s  
		icon.Font = Enum.Font.GothamBold  
		icon.Parent = btn  
  
		-- 名称  
		local nameLabel = Instance.new("TextLabel")  
		nameLabel.Size = UDim2.new(1, -10 * s, 0, 16 * s)  
		nameLabel.Position = UDim2.new(0, 5 * s, 0.5, -5)  
		nameLabel.BackgroundTransparency = 1  
		nameLabel.Text = name  
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)  
		nameLabel.TextSize = 11 * s  
		nameLabel.Font = Enum.Font.GothamBold  
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left  
		nameLabel.Parent = btn  
  
		-- 状态描述  
		local descLabel = Instance.new("TextLabel")  
		descLabel.Size = UDim2.new(1, -10 * s, 0, 14 * s)  
		descLabel.Position = UDim2.new(0, 5 * s, 0.7, 0)  
		descLabel.BackgroundTransparency = 1  
		descLabel.Text = desc  
		descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)  
		descLabel.TextSize = 9 * s  
		descLabel.Font = Enum.Font.Gotham  
		descLabel.TextXAlignment = Enum.TextXAlignment.Left  
		descLabel.Parent = btn  
  
		btn.MouseButton1Click:Connect(function()  
			callback()  
			-- 点击反馈动画  
			local tween = TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(60, 62, 70)})  
			tween:Play()  
			task.wait(0.1)  
			local tween2 = TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(40, 42, 50)})  
			tween2:Play()  
		end)  
  
		return btn, descLabel  
	end  
  
	-- ===== 分类按钮 =====  
	local categories = {  
		{name = "主页", icon = "🏠"},  
		{name = "战斗", icon = "⚔️"},  
		{name = "移动传送", icon = "🚀"},  
		{name = "生存脚本", icon = "⛏️"},  
		{name = "渲染", icon = "👁️"},  
		{name = "其他", icon = "⚙️"},  
		{name = "用户", icon = "👤"},  
	}  
  
	local selectedBtn = nil  
	for i, cat in ipairs(categories) do  
		local btn = Instance.new("TextButton")  
		btn.Size = UDim2.new(0.85, 0, 0, 38 * s)  
		btn.Position = UDim2.new(0.075, 0, 0, 15 * s + (i - 1) * 45 * s)  
		btn.BackgroundColor3 = Color3.fromRGB(30, 32, 40)  
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)  
		btn.Text = cat.icon .. " " .. cat.name  
		btn.TextSize = 13 * s  
		btn.Font = Enum.Font.GothamBold  
		btn.ZIndex = 11  
		btn.Parent = sidebar  
  
		local btnCorner = Instance.new("UICorner")  
		btnCorner.CornerRadius = UDim.new(0, 10 * s)  
		btnCorner.Parent = btn  
  
		btn.MouseButton1Click:Connect(function()  
			if selectedBtn then  
				selectedBtn.BackgroundColor3 = Color3.fromRGB(30, 32, 40)  
			end  
			selectedBtn = btn  
			btn.BackgroundColor3 = Color3.fromRGB(50, 80, 220)  
  
			-- 旧内容渐出动画  
			for _, child in ipairs(contentContainer:GetChildren()) do  
				if child:IsA("Frame") or child:IsA("TextButton") then  
					local outTween = TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1.2, 0, child.Position.Y.Scale, 0), Transparency = 1})  
					outTween:Play()  
				end  
			end  
			task.wait(0.2)  
			for _, child in ipairs(contentContainer:GetChildren()) do  
				if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end  
			end  
  
			local y = 10 * s  
			local xOffset = 0.02  
  
			-- 按分类加载功能（保留你原来的所有功能）  
			if cat.name == "战斗" then  
				createGridButton(contentContainer, "🎯", "静默自瞄", features.silentAim and "开启" or "关闭", function()  
					features.silentAim = not features.silentAim  
					showNotification("静默自瞄", features.silentAim)  
				end, xOffset, y)  
				xOffset += 0.33  
				createGridButton(contentContainer, "🔫", "锁定自瞄", features.aimbot and "开启" or "关闭", function()  
					toggleAimbot(not features.aimbot)  
				end, xOffset, y)  
				xOffset += 0.33  
				createGridButton(contentContainer, "💥", "自动扳机", features.triggerBot and "开启" or "关闭", function()  
					toggleTriggerBot(not features.triggerBot)  
				end, xOffset, y)  
				xOffset = 0.02  
				y += 75 * s  
				createGridButton(contentContainer, "📦", "扩大命中框", features.hitboxExtender and "开启" or "关闭", function()  
					toggleHitboxExtender(not features.hitboxExtender)  
				end, xOffset, y)  
  
			elseif cat.name == "移动传送" then  
				createGridButton(contentContainer, "✈️", "踏空", features.fly and "开启" or "关闭", function()  
					toggleFly(not features.fly)  
				end, xOffset, y)  
				xOffset += 0.33  
				createGridButton(contentContainer, "🌀", "反虚空", features.noClip and "开启" or "关闭", function()  
					toggleNoClip(not features.noClip)  
				end, xOffset, y)  
				xOffset += 0.33  
				createGridButton(contentContainer, "🦘", "兔子跳", features.bunnyHop and "开启" or "关闭", function()  
					toggleBunnyHop(not features.bunnyHop)  
				end, xOffset, y)  
				xOffset = 0.02  
				y += 75 * s  
				createGridButton(contentContainer, "🚀", "飞船", features.orbit and "开启" or "关闭", function()  
					toggleOrbit(not features.orbit)  
				end, xOffset, y)  
  
			elseif cat.name == "生存脚本" then  
				createGridButton(contentContainer, "🏃", "人物加速", features.speedHack and "开启" or "关闭", function()  
					toggleSpeedHack(not features.speedHack)  
				end, xOffset, y)  
				xOffset += 0.33  
				createGridButton(contentContainer, "🔄", "人物旋转", features.spinSpeed and "开启" or "关闭", function()  
					toggleSpinSpeed(not features.spinSpeed)  
				end, xOffset, y)  
				xOffset += 0.33  
				createGridButton(contentContainer, "⬆️", "无限跳", features.infiniteJump and "开启" or "关闭", function()  
					toggleInfiniteJump(not features.infiniteJump)  
				end, xOffset, y)  
  
			elseif cat.name == "渲染" then  
				createGridButton(contentContainer, "👁️", "ESP透视", features.esp and "开启" or "关闭", function()  
					toggleESP(not features.esp)  
				end, xOffset, y)  
				xOffset += 0.33  
				createGridButton(contentContainer, "📊", "射线", features.tracers and "开启" or "关闭", function()  
					toggleTracers(not features.tracers)  
				end, xOffset, y)  
				xOffset += 0.33  
				createGridButton(contentContainer, "🎯", "自定义准星", features.customCrosshair and "开启" or "关闭", function()  
					toggleCrosshair(not features.customCrosshair)  
				end, xOffset, y)  
  
			elseif cat.name == "其他" then  
				createGridButton(contentContainer, "🔀", "跳服务器", "点击执行", serverHop, xOffset, y)  
				xOffset += 0.33  
				createGridButton(contentContainer, "🔁", "重连", "点击执行", function()  
					TeleportService:Teleport(game.PlaceId)  
				end, xOffset, y)  
  
			elseif cat.name == "用户" then  
				local infoLabel = Instance.new("TextLabel")  
				infoLabel.Size = UDim2.new(1, -10 * s, 0, 350 * s)  
				infoLabel.Position = UDim2.new(0, 5 * s, 0, 10 * s)  
				infoLabel.BackgroundTransparency = 1  
				infoLabel.TextColor3 = Color3.fromRGB(235, 235, 235)  
				infoLabel.TextSize = 12.5 * s  
				infoLabel.TextXAlignment = Enum.TextXAlignment.Left  
				infoLabel.TextYAlignment = Enum.TextYAlignment.Top  
				infoLabel.TextWrapped = true  
				infoLabel.Font = Enum.Font.GothamBold  
				infoLabel.Parent = contentContainer  
  
				RunService.RenderStepped:Connect(function(dt)  
					if infoLabel and infoLabel.Parent and dt > 0 then  
						local fpsNum = math.floor(1 / dt)  
						infoLabel.Text = [[  
╔══════════════════════════╗  
║  ｜ ｜ ｜ 此脚本在持续更新 ｜ ｜ ｜  
║   预计更新到 120+ 功能  
╚══════════════════════════╝  
  
👤 用户名: ]]..player.Name..[[  
  
📅 注册天数: ]]..getAccountAge()..[[ 天  
  
🆔 用户ID: ]]..player.UserId..[[  
  
📊 实时帧率: ]]..fpsNum..[[  
  
📜 脚本: 拾忆脚本  
📌 版本: v1.0  
  
🎨 UI风格: 模仿 Creeper Box  
        (我的世界第三方辅助 - 苦力怕盒子)  
  
作者QQ: 3985643364  
  
祝您使用愉快！  
						]]  
					end  
				end)  
			end  
  
			scrollFrame.CanvasSize = UDim2.new(0, 0, 0, y + 100 * s)  
		end)  
	end  
  
	mainPanel.Visible = true  
end  
  
-- ========== 点击灵动岛 ==========  
local PatriotLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/SyndromeXph/Patriot-Key-System-Ui-Library/main/PatriotUi.luau"))()  
local cfg = {  
	Username = player.Name,  
	Executor = getexecutorname and getexecutorname() or "Unknown",  
	Platform = isMobile and "Mobile" or "PC",  
	HWID = gethwid and gethwid() or "N/A",  
	Time = os.date("%H:%M:%S"),  
       Date = os.date("%Y-%m-%d")  
}  
local KeyUI = PatriotLib:New(cfg,{  
	GetKeyLink = "",  
	Changelog = {{Ver="v1.0",Date="2026-06-02",Note="Script Release"}},  
	KeyCallback = function(inputKey)  
		if inputKey == "@1145114" then  
			isVerified = true  
			KeyUI:Close()  
			hideIsland()  
			createMainPanel()  
			showNotification("Verified",true)  
		else  
			PatriotLib:Notify("Wrong Key","Check your input")  
		end  
	end  
})  
local clickButton = Instance.new("TextButton")  
clickButton.Size = UDim2.new(1,0,1,0)  
clickButton.BackgroundTransparency = 1  
clickButton.Text = ""  
clickButton.Parent = dynamicIsland  
clickButton.MouseButton1Click:Connect(function()  
	if not isVerified then return end  
	if mainPanel then  
		mainPanel:Destroy()  
		mainPanel = nil  
		showIsland()  
	else  
		hideIsland()  
		createMainPanel()  
	end  
end)  
