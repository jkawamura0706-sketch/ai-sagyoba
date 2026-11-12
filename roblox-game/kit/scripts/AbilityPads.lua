-- AbilityPads（Script）
-- 置く場所：ServerScriptService の中に Script を作り、名前を「AbilityPads」にして、この中身を貼る
-- 役目：ロビーにある3つの台（Pad_Dash / Pad_Power / Pad_Anchor）に乗ると、その能力に決まる

local Players = game:GetService("Players")

local pads = {
	Pad_Dash = "Dash",     -- 逃げる
	Pad_Power = "Power",   -- 押し出す
	Pad_Anchor = "Anchor", -- 耐える
}

local lastTouch = {}

for name, ability in pads do
	local pad = workspace:FindFirstChild(name)
	if pad then
		pad.Touched:Connect(function(hit)
			local char = hit.Parent
			local player = char and Players:GetPlayerFromCharacter(char)
			if not player then return end
			local now = os.clock()
			if lastTouch[player] and now - lastTouch[player] < 1 then return end
			lastTouch[player] = now
			player:SetAttribute("Ability", ability)
		end)
	else
		warn(name .. " が見つかりません。SETUPの手順で台を作ってください")
	end
end
