-- GameData（ModuleScript）
-- 置く場所：ServerScriptService の中に ModuleScript を作り、名前を「GameData」にして、この中身を貼る
-- 役目：コインの管理と保存（DataStore）、無料コードの判定

local GameData = {}

local DataStoreService = game:GetService("DataStoreService")
local store = DataStoreService:GetDataStore("BattleGame_v1")

-- 無料コードと、もらえるコイン。公開するときに好きな言葉に変えてOK
local CODES = {
	["RELEASE"] = 100,
	["START"] = 50,
}

local data = {} -- [player] = { Coins = 数, UsedCodes = { コード = true } }

function GameData.Load(player)
	local d = { Coins = 0, UsedCodes = {} }
	local ok, saved = pcall(function()
		return store:GetAsync("u_" .. player.UserId)
	end)
	if ok and type(saved) == "table" then
		d = saved
	end
	data[player] = d

	player:SetAttribute("Ability", "Dash") -- 最初の能力はダッシュ

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = d.Coins
	coins.Parent = leaderstats

	return d
end

function GameData.AddCoins(player, amount)
	local d = data[player]
	if not d then return end
	d.Coins += amount
	local leaderstats = player:FindFirstChild("leaderstats")
	local coins = leaderstats and leaderstats:FindFirstChild("Coins")
	if coins then
		coins.Value = d.Coins
	end
end

function GameData.Redeem(player, code)
	code = string.upper(tostring(code or ""))
	local reward = CODES[code]
	if not reward then
		return false, "コードが違うみたいです"
	end
	local d = data[player]
	if not d then
		return false, "読み込み中です。少し待ってください"
	end
	if d.UsedCodes[code] then
		return false, "このコードはもう使っています"
	end
	d.UsedCodes[code] = true
	GameData.AddCoins(player, reward)
	return true, reward .. " コインもらいました！"
end

function GameData.Save(player)
	local d = data[player]
	if not d then return end
	pcall(function()
		store:SetAsync("u_" .. player.UserId, d)
	end)
	data[player] = nil
end

return GameData
