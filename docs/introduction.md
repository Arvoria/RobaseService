# Introduction

Robase (formerly: Roblox-Firebase) has been in development since Summer 2020 and has been released since Early-Fall 2020. Development first began when the need to store larger and larger data grew and it became apparent that DataStores were not going to be the answer; ever.

---

## What's the purpose?

Unfortunately, DataStores have issues:

+ You cannot look at the source code directly, meaning you have to trust the documentation;

+ You are limited to 4MB of data per key

+ You can only access top-level keys (`Player.UserId`s) and must define a path to a given point with table notation. (`table.this.that`).

+ Exposing the internals of the API allow Robase to be easily extended upon and wrapped around to create a "manager" for your database; similar to the [ProfileService]() or [DataStore2]() modules.

+ [Promises]() ensure race safety. Every async function will yield until a value is retrieved.

+ Cannot be updated dynamically, from anywhere, at anytime. This makes systems such as FFlags not possible, A/B Testing extraneous, and timed-events that can turn on at a moment's notice in a live game - impossible.

### Trusting Documentation

More often than not you can trust what the documentation says, "it will do X", generally means it will "do X". However, there comes a time where you want to know "how does it 'do X'" and that can only be solved in two manners:

- You dive into the source code

- Or, you can see if the docs tell you

And unfortunately, Roblox doesn't provide extensive documentation on every single method and every single service, this would be a massive task. 

Source Docs - documentation within source code - are an amazing resource to use to help developers stay sane when looking at your codebase. Thankfully, Robase has this technical project documentation page *and* source docs!

### Storage limitations

Before using Robase something you may want to ask yourself is: Do I really need this? In most cases, DataStore2 or ProfileService will serve you well, though you won't be saving anything big or complex. If you are looking to store large, complex data, then Robase is something you will want in your arsenal.

Developing a game on Roblox means that you will have used one of the following: [DataStoreService](), DataStore2, or ProfileService; the latter two of which being wrappers/managers for the former.  
This informs me that you are currently saving simple player data: number of coins, stats and levels, minor inventory data, etc. 

### Accessing deeply-nested keys

Being able to access a deeply-nested key can be helpful for a few reasons:

+ It can save on `HttpService` budget and lowers the amount of downloaded data
+ Saves unnecessary lines of code rooting through tables
+ Saves on sanity checks: `if table.that.this then end`

As an example, we will use the following data structure:

``` lua
local PlayerProfile = {
    Stats = {

    }

    Inventory = {
        Pages = {

        }

        _metadata = {
            _totalSlots = 8,
            _totalPages = 1,
        }
    },

    InAppPurchases = {
        ["GamepassId"] = {
            PurchasedOn = "1/1/1970 00:00 UTC",

        }
    },

    _metadata = {
        _playTime = 0,
        _lastSessionDuration = 0,
        _currentSessionDuration = 0,
        _totalLevel = 10,
        _sessionLastLocked = "1/1/1970 00:00 UTC",
        _sessionLocked = true,
        _lastAutoSave = "1/1/1970 00:00 UTC",
        _lastManualSave = "1/1/1970 00:00 UTC",
    }
}
```