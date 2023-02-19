local easyDB = require(game.ServerScriptService.EasyDB)

game.Players.PlayerAdded:Connect(function(plr)
	easyDB:Load(plr)
	
	local data = easyDB:Get(plr, "data", 
		{
			Coins = 0,
			Gems = 3,
			Weapon = { {Name = "Weapon Kayu", Damage = 10} }
		})
	data:Show()
end)
