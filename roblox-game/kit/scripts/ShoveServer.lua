-- ShoveServer（Script）
-- 置く場所：ServerScriptService の中に Script を作り、名前を「ShoveServer」にして、この中身を貼る
-- 役目：「おす」攻撃と、能力（ダッシュ／パワー／アンカー）の処理

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shoveEvent = Instance.new("RemoteEvent")
shoveEvent.Name = "ShoveEvent"
shoveEvent.Parent = ReplicatedStorage

local abilityEvent = Instance.new("RemoteEvent")
abilityEvent.Name = "AbilityEvent"
abilityEvent.Parent = ReplicatedStorage

-- 調整できる数字
local SHOVE_RANGE = 7      -- 「おす」が届く距離
local SHOVE_POWER = 60     -- 押す力
local SHOVE_COOLDOWN = 0.8 -- 「おす」の間隔（秒）
local ABILITY_COOLDOWN = 8 -- 能力の間隔（秒）

local lastShove = {}
local lastAbility = {}

local function hrpOf(player)
	local char = player.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function push(target, fromPos, power)
	if target:GetAttribute("Anchored") then
		return -- アンカー中は押し出されない
	end
	local hrp = hrpOf(target)
	if not hrp then return end
	local dir = hrp.Position - fromPos
	dir = Vector3.new(dir.X, 0, dir.Z)
	if dir.Magnitude > 0.1 then
		dir = dir.Unit
	else
		dir = Vector3.new(1, 0, 0)
	end
	local m = hrp.AssemblyMass
	hrp:ApplyImpulse(dir * power * m + Vector3.new(0, power * 0.3 * m, 0))
end

shoveEvent.OnServerEvent:Connect(function(player)
	local now = os.clock()
	if lastShove[player] and now - lastShove[player] < SHOVE_COOLDOWN then return end
	lastShove[player] = now

	local hrp = hrpOf(player)
	if not hrp then return end

	local power = SHOVE_POWER
	if player:GetAttribute("PowerReady") then
		power = power * 1.8 -- パワー能力の効果中は強く押す
	end

	for _, other in Players:GetPlayers() do
		if other ~= player then
			local o = hrpOf(other)
			if o and (o.Position - hrp.Position).Magnitude <= SHOVE_RANGE then
				push(other, hrp.Position, power)
			end
		end
	end
end)

abilityEvent.OnServerEvent:Connect(function(player)
	local now = os.clock()
	if lastAbility[player] and now - lastAbility[player] < ABILITY_COOLDOWN then return end

	local hrp = hrpOf(player)
	if not hrp then return end
	lastAbility[player] = now

	local ability = player:GetAttribute("Ability") or "Dash"
	if ability == "Dash" then
		-- 逃げる：向いている方向へ勢いよく進む
		local look = hrp.CFrame.LookVector
		local dir = Vector3.new(look.X, 0, look.Z)
		if dir.Magnitude > 0.1 then
			hrp:ApplyImpulse(dir.Unit * 70 * hrp.AssemblyMass)
		end
	elseif ability == "Power" then
		-- 押し出す：5秒間、「おす」が強くなる
		player:SetAttribute("PowerReady", true)
		task.delay(5, function()
			player:SetAttribute("PowerReady", false)
		end)
	elseif ability == "Anchor" then
		-- 耐える：3秒間、押し出されなくなる
		player:SetAttribute("Anchored", true)
		task.delay(3, function()
			player:SetAttribute("Anchored", false)
		end)
	end
end)
