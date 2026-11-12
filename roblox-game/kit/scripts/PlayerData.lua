-- PlayerData（Script）
-- 置く場所：ServerScriptService の中に Script を作り、名前を「PlayerData」にして、この中身を貼る
-- 役目：プレイヤーが入ったとき・出るときに、コインを読み書きする。コード入力の受け付けも用意する

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameData = require(script.Parent:WaitForChild("GameData"))

Players.PlayerAdded:Connect(function(player)
	GameData.Load(player)
end)

Players.PlayerRemoving:Connect(function(player)
	GameData.Save(player)
end)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		GameData.Save(player)
	end
end)

-- コード入力用の RemoteFunction を用意（クライアントの入力欄から呼ばれる）
local redeem = Instance.new("RemoteFunction")
redeem.Name = "RedeemCode"
redeem.Parent = ReplicatedStorage
redeem.OnServerInvoke = function(player, code)
	return GameData.Redeem(player, code)
end
