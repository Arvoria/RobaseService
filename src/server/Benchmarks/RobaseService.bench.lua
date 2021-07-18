local TestUrl = "https://robasestore-test-default-rtdb.europe-west1.firebasedatabase.app/"
local TestAuth = "DOiy9dDWghkdUYJKiFLXV1MGYkPRuddjLTL3bQJi"

local RobaseService = require(game.ServerScriptService.Server.RobaseService).new(TestUrl, TestAuth)
local RobloxFirebase = require(5618676786)(TestUrl, TestAuth)
local DataStoreService = game:GetService("DataStoreService")

local SampleName = "PlayerData"
local SampleKey = "ShaneSloth"

local RobaseInfo = {
	Key = SampleKey,
	SetKey = ("%s/Name"):format(SampleKey),
	GetKey = ("%s/Name"):format(SampleKey),
	IncrementKey = ("/Level"):format(SampleKey),
	UpdateKey = SampleKey
}

local DataStoreInfo = {
	Key = "ShaneSloth",
	PlayerDataStore = SampleName,
	VistsDataStore = "Visits",
}

local function getFirebase(): table
	local _, Result = pcall(RobloxFirebase.GetFirebase, SampleName)
	return Result
end

local function robaseGetAsync(robase): boolean & any
	local _, Result = pcall(robase.GetAsync, RobaseInfo.GetKey)
	return Result
end

local function robaseSetAsync(robase, data): boolean & any
	local _, Result = pcall(robase.SetAsync, RobaseInfo.SetKey, data)
	return Result
end

local function robaseIncrementAsync(robase, delta): boolean & any
	local _, Result = pcall(robase.IncrementAsync, RobaseInfo.IncrementKey, delta)
	return Result
end

local function getRobase2(): table
	local _, Result = pcall(RobaseService.GetRobase, SampleName)
	return Result
end

local function robase2GetAsync(robase): boolean & any
	local _, Success, Result = pcall(robase.GetAsync, RobaseInfo.GetKey)
	return Success, Result
end

local function robase2SetAsync(robase, data): boolean & any
	local _, Success, Result = pcall(robase.SetAsync, RobaseInfo.SetKey, data)
	return Success, Result
end

local function robase2IncrementAsync(robase, delta): boolean & any
	local _, Success, Result = pcall(robase.IncrementAsync, RobaseInfo.IncrementKey, delta)
	return Success, Result
end

local function getDataStore(store): any
	local _, Result = pcall(DataStoreService.GetDataStore, store)
	return Result
end

local function datastoreGetAsync(datastore): any
	local _, Result = pcall(datastore.GetAsync, DataStoreInfo.Key)
	return Result
end

local function datastoreSetAsync(datastore, data): nil
	pcall(datastore.SetAsync, DataStoreInfo.Key, data)
	--return datastoreGetAsync(datastore)
	--return pcall(datastore.GetAsync, DataStoreInfo.Key)
end

local function datastoreReturnSetAsync(datastore, data): any
	datastoreSetAsync(datastore, data)
	--pcall(datastore.SetAsync, data)
	return datastoreGetAsync(datastore)
end

local function datastoreIncrementAsync(datastore)
	local _, Result = pcall(datastore.IncrementAsync, DataStoreInfo.Key, 1)
	return Result
end

return {
	ParameterGenerator = function()
	end;

	Functions = {
		["RobaseService <2.0.0-beta.1-bn>"] = function(Profiler)
			Profiler.Begin("GetRobase")
			local Robase
			--for i = 1, 500 do
				Robase = getRobase2()
			--end
			Profiler.End()

			Profiler.Begin("GetAsync")
			--for i = 1, 500 do
				robase2GetAsync(Robase)
			--end
			Profiler.End()

			Profiler.Begin("SetAsync")
			--for i = 1, 500 do
				robase2SetAsync(Robase, "NotShaneSloth")
			--end
			Profiler.End()

			Profiler.Begin("IncrementAsync")
			--for i = 1, 500 do
				robase2IncrementAsync(Robase, 1)
			--end
			Profiler.End()
		end,

		["Robase <1.0.1-beta.rc>"] = function(Profiler)
			Profiler.Begin("GetRobase")
			local Robase
			--for i = 1, 500 do
				Robase = getFirebase()
			--end
			Profiler.End()

			Profiler.Begin("GetAsync")
			--for i = 1, 500 do
				robaseGetAsync(Robase)
			--end
			Profiler.End()

			Profiler.Begin("SetAsync")
			--for i = 1, 500 do
				robaseSetAsync(Robase, "NotShaneSloth")
			--end
			Profiler.End()

			Profiler.Begin("IncrementAsync")
			--for i = 1, 500 do
				robaseIncrementAsync(Robase, 1)
			--end
			Profiler.End()
		end,

		["DataStoreService"] = function(Profiler)
			Profiler.Begin("GetDataStores")
			local visits
			local players
			--for i = 1, 500 do
				visits = getDataStore(DataStoreInfo.VistsDataStore)
				players = getDataStore(DataStoreInfo.PlayerDataStore)
			--end
			Profiler.End()

			Profiler.Begin("GetAsync")
			--for i = 1, 500 do
				datastoreGetAsync(players)
			--end
			Profiler.End()

			--[[Profiler.Begin("SetAsync")
			for i = 1, 100 do
				datastoreSetAsync(players, {Nickname="NotShaneSloth"})
			end
			Profiler.End()
			--]]
			Profiler.Begin("SetAsync") -- ReturnSetAsync
			--for i = 1, 100 do
				datastoreReturnSetAsync(players, {Nickname="NotShaneSloth"})
			--end
			Profiler.End()

			Profiler.Begin("IncrementAsync")
			--for i = 1, 100 do
				datastoreIncrementAsync(visits)
			--end
			Profiler.End()
		end
	}
}