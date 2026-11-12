-- RoundManager（Script）
-- 置く場所：ServerScriptService の中に Script を作り、名前を「RoundManager」にして、この中身を貼る
-- 役目：試合の進行役。ロビーで待つ → カウントダウン → 試合 → 落ちたら負け → 最後の1人が勝ち → ロビーへ戻る、を繰り返す

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameData = require(script.Parent:WaitForChild("GameData"))

-- 調整できる数字（ここだけ直せばゲームの性格が変わります）
local CONFIG = {
	MIN_PLAYERS = 2,    -- 試合を始める最少人数
	COUNTDOWN_TIME = 3, -- カウントダウンの秒数
	MATCH_TIME = 180,   -- 試合の制限時間（秒）
	JOIN_COINS = 10,    -- 参加した全員がもらえるコイン
	WIN_COINS = 50,     -- 勝った人がもらえるコイン
	FALL_MARGIN = 12,   -- 土俵（Ring）よりこの高さぶん下に落ちたら負け
}

local lobbySpawn = workspace:WaitForChild("LobbySpawn")
local ring = workspace:WaitForChild("Ring")
local arenaSpawns = {}
for i = 1, 8 do
	local s = workspace:FindFirstChild("ArenaSpawn" .. i)
	if s then
		table.insert(arenaSpawns, s)
	end
end

-- 画面上の案内表示（クライアントが読む）
local status = Instance.new("StringValue")
status.Name = "MatchStatus"
status.Value = "ロビーで待っています"
status.Parent = ReplicatedStorage

local alive = {} -- 試合に残っている人 [player] = true
local running = false

local function setStatus(text)
	status.Value = text
end

local function teleport(player, part)
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp and part then
		hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
		hrp.AssemblyLinearVelocity = Vector3.zero
	end
end

local function aliveCount()
	local n = 0
	for _ in alive do
		n += 1
	end
	return n
end

Players.PlayerRemoving:Connect(function(player)
	alive[player] = nil
end)

local function runMatch()
	if #arenaSpawns == 0 then
		setStatus("ArenaSpawn がありません。SETUPの手順を確認してください")
		return
	end
	running = true

	local fighters = Players:GetPlayers()
	for i, player in fighters do
		alive[player] = true
		teleport(player, arenaSpawns[((i - 1) % #arenaSpawns) + 1])
		GameData.AddCoins(player, CONFIG.JOIN_COINS)
	end

	for t = CONFIG.COUNTDOWN_TIME, 1, -1 do
		setStatus("試合開始まで " .. t)
		task.wait(1)
	end
	setStatus("試合中！ 土俵に最後まで残ろう")

	local elapsed = 0
	while aliveCount() > 1 and elapsed < CONFIG.MATCH_TIME do
		task.wait(0.3)
		elapsed += 0.3
		for player in alive do
			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp and hrp.Position.Y < ring.Position.Y - CONFIG.FALL_MARGIN then
				alive[player] = nil
				teleport(player, lobbySpawn)
				setStatus(player.DisplayName .. " が落ちた！ 残り " .. aliveCount() .. " 人")
			end
		end
	end

	local winner = nil
	for player in alive do
		winner = player
	end
	if winner and aliveCount() == 1 then
		GameData.AddCoins(winner, CONFIG.WIN_COINS)
		setStatus("勝ちは " .. winner.DisplayName .. "！ +" .. CONFIG.WIN_COINS .. " コイン")
	else
		setStatus("時間切れ！ 引き分けです")
	end

	table.clear(alive)
	task.wait(5)
	for _, player in Players:GetPlayers() do
		teleport(player, lobbySpawn)
	end
	running = false
end

while true do
	local n = #Players:GetPlayers()
	if n >= CONFIG.MIN_PLAYERS and not running then
		setStatus("まもなく試合が始まります")
		task.wait(2)
		if #Players:GetPlayers() >= CONFIG.MIN_PLAYERS then
			runMatch()
		end
	else
		setStatus("ロビーで待っています（あと " .. math.max(0, CONFIG.MIN_PLAYERS - n) .. " 人で開始）")
		task.wait(1)
	end
end
