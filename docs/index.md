# Robase

!!! warning "Site in progress"
    This website is still a work in progress and changes are being made daily.
    
Robase is a RESTful API wrapper for Firebase Realtime Database - written in untyped Luau - for Roblox Developers seeking an external database service with a simple to use wrapper.

As mentioned, Robase seeks to be simple to use, but this is one of two core aims of this project. The second aim is to be an easy replacement to [DataStoreService](). You can find useful code to help with replacing old DataStore code and transferring data [here](#examples).

---

## Why Robase?

Robase was developed to solve a few problem areas of DataStores

+ Storing large amounts of data (>4MB) is impossible without using external databases

+ DataStores are only accessible at one point, Robase can access any key no matter how deeply nested it may be and get or update it's data (Explained later on).

+ Easily extensible and wrappable and should allow for "managers" to be easily made for your data.

+ Thanks to [Promises]() you can be sure each async function yields and returns a value, thus no worry over race conditions.

### **Storing a large amount of data**

If you're developing a game on Roblox it is very likely you have encountered [DataStoreService]() and you may have even used [ProfileService]() or [DataStore2]() for easier management of your data. You will also likely be saving simple player data: how much money they have; which missions they have completed; what buffs they may have from Gamepasses or Developer Products; etc. However, there could come a point where a player's data could exceed the 4MB limitation of DataStores, this would result in the partial loss of the data. It is unlikely you will reach this limitation if you are only looking to store *simple* data, Robase, however, is best used if you're looking to store more complex data: exact inventory content; several different skill tree buffs; a list of missions and their completion steps with completed steps flagged as such.

Firebase has a free plan ([Spark]()) which limits you to:

+ 1GB Storage capacity

+ 10GB of downloads (Get requests) per month#

However, the "pay as you go" plan ([Blaze]()) is enticing with:

+ Storage costs $5/GB/mo (Storing 2GB = $10/month)

+ Downloaded data costs $1/GB/mo (100GB downloaded in a month = $100)

### **Accessing deeply-nested keys**

Being able to directly access a deeply-nested key is extremely helpful, not only is it simple to do, it also saves on downloading an entire key, quite possibly, for multiple ocassions.

As an example, we will use the following data structure:

``` lua
local Profile = {
    Inventory = {
        _metadata = {
            _currentPage = 1,
            _isFull = false,
            _totalCapacity = 32,
            _numItems = 0,
        }

        Pages = {
            [1] = {
                Slots = {
                    [1] = {--[[Item Data]]},
                    [2] = {--[[Item Data]]},
                    [3] = {--[[Item Data]]},
                    [4] = {--[[Item Data]]},
                    [5] = {--[[Item Data]]},
                    [6] = {--[[Item Data]]},
                    [7] = {--[[Item Data]]},
                    [8] = {--[[Item Data]]},
                }
            },
            ...
        }
    },
    Skills = {
        ["Woodcutting"] = {
            Title = "Woodcutting",
            Aliases = { },
            Level = 5,
            Description = "Speeds up woodcutting",
        },
        ...
    }

    Missions = {
        InProgress = {
            ["QuestId"] = {
                Stage = "some stage Id",
            },
            ...
        },

        Completed = {
            "QuestId", "QuestId2", ...
        }
    }


}
```

Accessing and navigating this data structure, which could expand even further than it does, could be very daunting. First you would need to get the data at the base key, then you would need to assign a variable to point to a given key in this data structure (`Data.Missions.Completed` for example), and then you could access it.  
However, with Robase and Firebase, you could perform a single `GetAsync` request to  
`"{Data}/Missions/Completed"` where `{Data}` is the top-level key to access a Player's data. No longer do you need to perform sanity checks to see if the data exists or not, if it's not in the database Robase will tell you that and what specifically went wrong! If this data is non-existent, then you can create or do something about it.