-- ClientControls（LocalScript）
-- 置く場所：StarterPlayerScripts の中に LocalScript を作り、名前を「ClientControls」にして、この中身を貼る
-- 役目：操作（おす＝Fキー／能力＝Qキー、スマホでは画面ボタン）、案内表示、コード入力欄

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer

local shoveEvent = ReplicatedStorage:WaitForChild("ShoveEvent")
local abilityEvent = ReplicatedStorage:WaitForChild("AbilityEvent")
local redeem = ReplicatedStorage:WaitForChild("RedeemCode")
local status = ReplicatedStorage:WaitForChild("MatchStatus")

-- 操作：Fキー＝おす、Qキー＝能力。スマホでは画面にボタンが出ます
local function onShove(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		shoveEvent:FireServer()
	end
end
local function onAbility(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		abilityEvent:FireServer()
	end
end
ContextActionService:BindAction("Shove", onShove, true, Enum.KeyCode.F)
ContextActionService:SetTitle("Shove", "おす")
ContextActionService:BindAction("Ability", onAbility, true, Enum.KeyCode.Q)
ContextActionService:SetTitle("Ability", "能力")

-- 画面の部品を用意
local gui = Instance.new("ScreenGui")
gui.Name = "BattleUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- 上の案内表示
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.8, 0, 0, 44)
label.Position = UDim2.new(0.1, 0, 0, 12)
label.BackgroundTransparency = 0.35
label.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.GothamBold
label.TextScaled = true
label.Text = status.Value
label.Parent = gui
status:GetPropertyChangedSignal("Value"):Connect(function()
	label.Text = status.Value
end)

-- コード入力欄（左下）
local box = Instance.new("TextBox")
box.PlaceholderText = "コードを入力"
box.Text = ""
box.Size = UDim2.new(0, 170, 0, 36)
box.Position = UDim2.new(0, 12, 1, -48)
box.Font = Enum.Font.Gotham
box.TextScaled = true
box.Parent = gui

local button = Instance.new("TextButton")
button.Text = "コードを使う"
button.Size = UDim2.new(0, 110, 0, 36)
button.Position = UDim2.new(0, 190, 1, -48)
button.Font = Enum.Font.GothamBold
button.TextScaled = true
button.Parent = gui

local message = Instance.new("TextLabel")
message.Size = UDim2.new(0, 320, 0, 30)
message.Position = UDim2.new(0, 12, 1, -86)
message.BackgroundTransparency = 1
message.TextColor3 = Color3.fromRGB(255, 230, 120)
message.Font = Enum.Font.GothamBold
message.TextScaled = true
message.Text = ""
message.Parent = gui

button.Activated:Connect(function()
	if box.Text == "" then return end
	local _, text = redeem:InvokeServer(box.Text)
	message.Text = text or ""
	box.Text = ""
	task.delay(4, function()
		message.Text = ""
	end)
end)
