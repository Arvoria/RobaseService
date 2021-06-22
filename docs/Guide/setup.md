# Setting up Robase

!!! warning 
    This page is still in the process of being documented.

`RobaseService` is made to be a replication of `DataStoreService` so that setup and transferring data is simple to do. 

## Setup Example

Code that once looked like this:  
```lua
local DataStoreService = game:GetService("DataStoreService")
local ExampleDataStore = DataStoreService:GetDataStore("Example")
local ExampleData = ExampleDataStore:GetAsync("123456789")
```  
Will now look like this:  
```lua
local RobaseServiceModule = require(path.to.robase)
local RobaseService = RobaseServiceModule.new("URL", "AUTH")
local ExampleRobase = RobaseService:GetRobase("NAME")
local Success, Result = ExampleRobase:GetAsync("KEY")
```

Every method call to a `Robase` will return a `Success` and a `Result`, check the [API Reference](../../api/) for more detailed information.


## Transferring from DataStoreService

The following is relevant code to transfer player data from DataStoreService to RobaseService  
``` {.lua linenums="1"}
local DataStoreName = "Enter DataStore Name"
local FirebaseAuthKey = "Enter Firebase Auth Key"
local FirebaseDBUrl = "Enter Firebase DB Url"
local RobaseName = "Enter Robase Name"

local DataStoreService = game:GetService("DataStoreService")
local RobaseServiceModule = require("path.to.robase")
local RobaseService = RobaseServiceModule.new(FirebaseDBUrl, FirebaseAuthKey)

local GlobalDataStore = game:GetDataStore(DataStoreName)
local GlobalRobase = RobaseService:GetRobase(RobaseName)

game:GetService("Players").PlayerAdded:Connect(function(player)
    local DS_Key = string.format("%d", player.UserId) -- replace with DataStore key format, for example: string.format("Players/%d", player.UserId)
    local RobaseKey = string.format("%d", player.UserId) -- replace with Robase key format for example: string.format("Players/%d", player.UserId)

    local ExistsInRobase, Result = GlobalRobase:GetAsync(RobaseKey)
    local SavedData = GlobalDataStore:GetAsync(DS_Key) or nil

    if not ExistsInRobase and SavedData then
        -- Key does not exist in the Firebase and data was found in the DataStore
        -- so we save it
        ExistsInRobase, Result = GlobalRobase:SetAsync(RobaseKey, SavedData, "POST")
        
        --[[if ExistsInRobase then
            -- perform sanity checks however you wish            
        end]]
    end
end)
```