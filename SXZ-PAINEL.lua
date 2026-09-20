local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local player = Players.LocalPlayer
local flying = false
local espOn = false
local speed = 75
local MIN, MAX = 10, 200
local killed = false
local hrp, humanoid
local espObjects = {}

local function setupChar(char)
	hrp = char:WaitForChild("HumanoidRootPart")
	humanoid = char:WaitForChild("Humanoid")
end
setupChar(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(setupChar)

-- trava animacao --
local function stopTracks()
	pcall(function()
		local an = humanoid and humanoid:FindFirstChildOfClass("Animator")
		if an then
			for _,t in pairs(an:GetPlayingAnimationTracks()) do
				t:AdjustSpeed(0) t:Stop(0)
			end
		end
	end)
end
local function setNoAnim(on)
	local char = player.Character
	if not char then return end
	local animate = char:FindFirstChild("Animate")
	if animate and animate:IsA("LocalScript") then
		animate.Disabled = on
	end
	if on then stopTracks() end
end

local function clearESP()
	for _,v in pairs(espObjects) do pcall(function() v:Destroy() end) end
	table.clear(espObjects)
end
local function attachESP(plr, char)
	if not espOn or killed then return end
	if plr == player then return end
	char:WaitForChild("Head",5)
	if char:FindFirstChild("SXZ_ESP_HL") then return end
	local hl = Instance.new("Highlight")
	hl.Name = "SXZ_ESP_HL"
	hl.FillColor = Color3.fromRGB(255,0,0)
	hl.FillTransparency = 0.5
	hl.OutlineColor = Color3.new(1,1,1)
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = char
	table.insert(espObjects, hl)
	local bb = Instance.new("BillboardGui")
	bb.Name = "SXZ_ESP_BB"
	bb.Size = UDim2.new(0,100,0,40)
	bb.StudsOffset = Vector3.new(0,2.5,0)
	bb.AlwaysOnTop = true
	bb.Parent = char
	table.insert(espObjects, bb)
	local tl = Instance.new("TextLabel")
	tl.Name = "Tag" tl.BackgroundTransparency = 1 tl.Size = UDim2.new(1,0,1,0)
	tl.Font = Enum.Font.GothamBold tl.TextSize = 13 tl.TextColor3 = Color3.new(1,1,1)
	tl.TextStrokeTransparency = 0 tl.Text = plr.Name tl.Parent = bb
end
local function enableESP()
	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player then
			if plr.Character then pcall(function() attachESP(plr, plr.Character) end) end
			plr.CharacterAdded:Connect(function(c) pcall(function() attachESP(plr, c) end) end)
		end
	end
end
Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(c) pcall(function() attachESP(plr, c) end) end)
end)
RS.RenderStepped:Connect(function()
	if killed or not espOn then return end
	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local bb = plr.Character:FindFirstChild("SXZ_ESP_BB")
			if bb then
				local tag = bb:FindFirstChild("Tag")
				if tag and hrp and plr.Character:FindFirstChild("HumanoidRootPart") then
					local d = math.floor((hrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude)
					tag.Text = plr.Name.." ["..d.."m]"
				end
			end
		end
	end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "FlyGui" gui.ResetOnSpawn = false gui.DisplayOrder = 999
gui.Parent = player:WaitForChild("PlayerGui")
local main = Instance.new("Frame")
main.Size = UDim2.new(0,200,0,170)
main.Position = UDim2.new(1,-220,0,150)
main.BackgroundColor3 = Color3.fromRGB(18,18,18)
main.BackgroundTransparency = 0.15
main.Active = true main.Draggable = true
main.Parent = gui
local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,12) c.Parent = main

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X" closeBtn.Font = Enum.Font.GothamBlack closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.fromRGB(160,160,160) closeBtn.BackgroundTransparency = 1
closeBtn.Size = UDim2.new(0,24,0,24) closeBtn.Position = UDim2.new(0,6,0,4) closeBtn.Parent = main
closeBtn.MouseButton1Click:Connect(function()
	killed = true flying = false espOn = false
	pcall(function() humanoid.PlatformStand = false end)
	setNoAnim(false) clearESP() gui:Destroy()
end)

local title = Instance.new("TextLabel")
title.Text = "SXZ PAINEL" title.Font = Enum.Font.GothamBlack title.TextSize = 15
title.TextColor3 = Color3.new(1,1,1) title.TextXAlignment = Enum.TextXAlignment.Center
title.BackgroundTransparency = 1 title.Size = UDim2.new(1,0,0,28) title.Position = UDim2.new(0,0,0,2) title.Parent = main

local function makeRow(text, y)
	local l = Instance.new("TextLabel")
	l.Text = "  "..text l.Font = Enum.Font.GothamBold l.TextSize = 15 l.TextColor3 = Color3.new(1,1,1)
	l.TextXAlignment = Enum.TextXAlignment.Left l.BackgroundTransparency = 1
	l.Size = UDim2.new(1,-70,0,30) l.Position = UDim2.new(0,0,0,y) l.Parent = main
	local bg = Instance.new("TextButton")
	bg.Text = "" bg.Size = UDim2.new(0,50,0,26) bg.Position = UDim2.new(1,-60,0,y+2)
	bg.BackgroundColor3 = Color3.fromRGB(80,80,80) bg.AutoButtonColor = false bg.Parent = main
	local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(1,0) cc.Parent = bg
	local kn = Instance.new("Frame")
	kn.Size = UDim2.new(0,22,0,22) kn.Position = UDim2.new(0,2,0.5,-11)
	kn.BackgroundColor3 = Color3.new(1,1,1) kn.Parent = bg
	local cc2 = Instance.new("UICorner") cc2.CornerRadius = UDim.new(1,0) cc2.Parent = kn
	return bg, kn
end
local espBg, espKnob = makeRow("ESP", 30)
local flyBg, flyKnob = makeRow("FLY", 60)

local speedLabel = Instance.new("TextLabel")
speedLabel.Text = "  Speed" speedLabel.Font = Enum.Font.Gotham speedLabel.TextSize = 14
speedLabel.TextColor3 = Color3.new(1,1,1) speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.BackgroundTransparency = 1 speedLabel.Size = UDim2.new(0,100,0,20)
speedLabel.Position = UDim2.new(0,0,0,95) speedLabel.Parent = main
local speedVal = Instance.new("TextLabel")
speedVal.Text = tostring(speed) speedVal.Font = Enum.Font.Gotham speedVal.TextSize = 13
speedVal.TextColor3 = Color3.fromRGB(180,180,180) speedVal.TextXAlignment = Enum.TextXAlignment.Right
speedVal.BackgroundTransparency = 1 speedVal.Size = UDim2.new(0,60,0,20)
speedVal.Position = UDim2.new(1,-70,0,95) speedVal.Parent = main
local bar = Instance.new("TextButton")
bar.Text = "" bar.Size = UDim2.new(1,-30,0,6) bar.Position = UDim2.new(0,15,0,125)
bar.BackgroundColor3 = Color3.fromRGB(90,90,90) bar.AutoButtonColor = false bar.Parent = main
local c4 = Instance.new("UICorner") c4.CornerRadius = UDim.new(1,0) c4.Parent = bar
local fill = Instance.new("Frame") fill.BorderSizePixel = 0 fill.BackgroundColor3 = Color3.new(1,1,1) fill.Parent = bar
local c5 = Instance.new("UICorner") c5.CornerRadius = UDim.new(1,0) c5.Parent = fill
local sliderKnob = Instance.new("Frame") sliderKnob.Size = UDim2.new(0,16,0,16) sliderKnob.BackgroundColor3 = Color3.new(1,1,1) sliderKnob.Parent = bar
local c6 = Instance.new("UICorner") c6.CornerRadius = UDim.new(1,0) c6.Parent = sliderKnob

local function updateUI()
	local a = (speed-MIN)/(MAX-MIN)
	fill.Size = UDim2.new(a,0,1,0)
	sliderKnob.Position = UDim2.new(a,-8,0.5,-8)
	speedVal.Text = tostring(math.floor(speed))
end
updateUI()
local function setToggle(bg, kn, on)
	bg.BackgroundColor3 = on and Color3.fromRGB(160,160,160) or Color3.fromRGB(80,80,80)
	kn:TweenPosition(on and UDim2.new(1,-24,0.5,-11) or UDim2.new(0,2,0.5,-11), "Out", "Quad", 0.15, true)
end
local function setFly(on)
	if killed then return end
	flying = on setToggle(flyBg, flyKnob, on)
	if humanoid then humanoid.PlatformStand = on end
	setNoAnim(on)
end
local function setESP(on)
	if killed then return end
	espOn = on setToggle(espBg, espKnob, on)
	if on then enableESP() else clearESP() end
end
flyBg.MouseButton1Click:Connect(function() setFly(not flying) end)
espBg.MouseButton1Click:Connect(function() setESP(not espOn) end)
UIS.InputBegan:Connect(function(i,g) if killed or g then return end if i.KeyCode == Enum.KeyCode.F then setFly(not flying) end end)

local dragging = false
local function setFromX(x)
	local rel = math.clamp((x - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
	speed = MIN + rel*(MAX-MIN)
	updateUI()
end
bar.InputBegan:Connect(function(i) if killed then return end if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging=true setFromX(i.Position.X) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging=false end end)
UIS.InputChanged:Connect(function(i) if dragging and not killed and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setFromX(i.Position.X) end end)

RS.Heartbeat:Connect(function(dt)
	if killed then return end
	if not flying or not hrp or not humanoid then return end
	humanoid.PlatformStand = true
	stopTracks()
	local camCF = workspace.CurrentCamera.CFrame
	local move = Vector3.new()
	local hasKey = false
	if UIS:IsKeyDown(Enum.KeyCode.W) then move += camCF.LookVector hasKey=true end
	if UIS:IsKeyDown(Enum.KeyCode.S) then move -= camCF.LookVector hasKey=true end
	if UIS:IsKeyDown(Enum.KeyCode.D) then move += camCF.RightVector hasKey=true end
	if UIS:IsKeyDown(Enum.KeyCode.A) then move -= camCF.RightVector hasKey=true end
	if not hasKey and humanoid.MoveDirection.Magnitude > 0.1 then
		local fFlat = Vector3.new(camCF.LookVector.X,0,camCF.LookVector.Z)
		local rFlat = Vector3.new(camCF.RightVector.X,0,camCF.RightVector.Z)
		if fFlat.Magnitude>0 and rFlat.Magnitude>0 then
			local f = humanoid.MoveDirection:Dot(fFlat.Unit)
			local r = humanoid.MoveDirection:Dot(rFlat.Unit)
			move = camCF.LookVector*f + camCF.RightVector*r
		else move = humanoid.MoveDirection end
	end
	local up = 0
	if UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.E) then up+=1 end
	if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.Q) then up-=1 end
	if move.Magnitude>0 then move = move.Unit end
	hrp.CFrame = hrp.CFrame + (move*speed*dt) + Vector3.new(0,up*speed*dt,0)
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero
end)
