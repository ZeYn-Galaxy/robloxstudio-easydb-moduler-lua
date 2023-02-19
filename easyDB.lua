local EasyDB = {}
local Data = {}
Data.__index = Data

local CurrencyData = {}
CurrencyData.__index = CurrencyData

-- Service
local DataStore = game:GetService("DataStoreService"):GetDataStore("DATASTORE01")

function Data.new(plr, data, version)

	local Default = {}
	setmetatable(Default, Data)

	Default.User = plr.UserId
	Default.Version = version or 1
	Default.Data = data or {}

	Data[plr.UserId] = Default
	return Default

end

function CurrencyData.new(plr, name, ...)

	local Default = ...
	setmetatable(Default, CurrencyData)

	Default.User = plr.UserId
	Data[plr.UserId].Data[name] = Default
	return Default
end

function EasyDB:Load(Player)

	local data = nil

	local s,r = pcall(function()
		data = DataStore:GetAsync(Player.UserId.."_EasyDB")
	end)

	if s then
		print("Sukses")
		if data ~= nil then
			return Data.new(Player, data.Data, data.Version)
		end

		print("Creating Data...")
		local newData = Data.new(Player)
		local isSaved = false

		local s,r = pcall(function()
			DataStore:SetAsync(Player.UserId.."_EasyDB", { Data = newData.Data, Version = newData.Version })
			isSaved = true
		end)

		if s and isSaved then
			print("Data Berhasil dibuat")
		end

		return newData
	else
		print(Player)
		error(r)
	end

end

function EasyDB:Save(Player)

	local s,r = pcall(function()
		DataStore:UpdateAsync(Player.UserId.."_EasyDB", function(oldData)
			if Data[Player.UserId].Version > oldData.Version then
				return { Data = Data[Player.UserId].Data, Version = Data[Player.UserId].Version }
			else
				print("No one changes")
			end
		end)
	end)

	if s then
		--print("Sukses")
	end

end

function EasyDB:Get(Player, Name, ...)

	if Data[Player.UserId] then

		if Data[Player.UserId].Data[Name] then
			local Currency = CurrencyData.new(Player, Name, Data[Player.UserId].Data[Name])

			for i,v in pairs(...) do
				if not Currency[i] then
					Currency:Add(i,v)
				end
			end

			return Currency
		end

		local newC = CurrencyData.new(Player, Name, ...)
		Data[Player.UserId].Version += 1
		return newC

	end

end


function CurrencyData:GetData()
	return self
end

function CurrencyData:Increment(Target, Value)
	self[Target] += Value
	Data[self.User].Version += 1
end

function CurrencyData:Subtract(Target, Value)
	self[Target] -= Value
	Data[self.User].Version += 1
end

function CurrencyData:Set(Target, Value)
	self[Target] = Value
	Data[self.User].Version += 1
end

function CurrencyData:Add(Name, Value)
	self[Name] = Value
	Data[self.User].Version += 1
end


function CurrencyData:Show()
	for i,v in pairs(Data[self.User].Data) do
		for obj,val in pairs(v) do
			if  obj ~= "User" then
				if type(val) == "table" then
					val = "table"
				end
				print("|---------------------------------|")
				print("| NAMA_DATA : "..i.." |")
				print("| OBJECT >> "..obj)
				print("| VALUE  >> "..val)
				print("|_________________________________|")
			end
		end
	end
end

return EasyDB
