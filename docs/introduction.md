# Introduction

Robase (formerly: Roblox-Firebase) has been in development since Summer 2020 and has been released since Early-Fall 2020. Development first began when the need to store larger and larger data grew and it became apparent that DataStores were not going to be the answer; ever.

---

## What's the purpose?

Unfortunately, DataStores have issues:

+ You are limited to 4MB of data per key

+ You can only access top-level keys (`Player.UserId`s) and must define a path to a given point with table notation. (`table.this.that`).

+ Exposing the internals of the API allow Robase to be easily extended upon and wrapped around to create a "manager" for your database; similar to the [ProfileService]() or [DataStore2]() modules.

+ [Promises]() ensure race safety. Every async function will yield until a value is retrieved.

+ Cannot be updated dynamically, from anywhere, at anytime. This makes systems such as FFlags not possible, A/B Testing extraneous, and timed-events that can turn on at a moment's notice in a live game - impossible.

### Storage limitations

Before using Robase something you may want to ask yourself is: Do I really need this? In most cases, DataStore2 or ProfileService will serve you well, though you won't be saving anything big or complex. If you are looking to store large, complex data, then Robase is something you will want in your arsenal.

Firebase's Spark plan provides you with 1GB storage in total per database/project and 10GB data downloaded per month. The Blaze plan is priced at how much you are using each, billed each month; each GB of storage costs $5 per month and each GB downloaded costs $1 per month. With the Blaze plan, a database using 1GB of storage and 100GB downloaded per month will be estimated to pay $105 per month. In addition to this you get other bonuses. 

The differences between the Spark and Blaze plan is documented [here](https://firebase.google.com/pricing)

[This example profile](https://pastebin.com/5zhfsfJb) shows just how complex and large data can be even when it has been optimised for storage. This profile will take up 3.6KB of data, that's not so much, right? Now imagine you have 100,000 unique players playing your game, that's now ~352MB, over a third of the capacity for the free plan. That's **a lot** of data!

But this is just player data, what about things that happen in a server? Think about: an experience-wide event, like "Double XP" and how would you handle it; or even the optimised metadata for every minigame played; FFlags deployment system. There is a lot of things you can do in the backend of your database and it can be controlled remotely. [This example server data]() gives an example look at how a Firebase structure could be setup as a Lua table.  
This structure is approximately 2KB in storage. `ServerData.PlayedMinigames.Games` is approximately 1.5KB in size, each minigame's data equating to 105.5B. 
What if we asked how much this could grow? Imagine we have a small experience, with about 20,000 visits per day. Now lets say that on average every visit garners 1.8 minigame plays, we can scale this up to how much the database will grow each day. For 20,000 visits we would have 36,000 minigames played - that's roughly 3.62MB!

Just how scalable and manageable is this? Well first we have to allow some assumptions:

+ We reserve 500MB in data for player data, the server can use the rest of it.

+ Growth is static and the number of visists remain the same.

+ Minigames Played to Visits ratio is 1.8.

```lua
local MaxServerData = 1 * 1024 * 1024 * 1024 -- 1GB in Bytes
local VisitsPerDay = 20 * 1000 -- 20,000 Visits per day
local MinigamesVisitsRatio = 1.8 -- Every visit receives on average 1.8 minigame plays
local MinigamesPerDay = VisitsPerDay * MinigamesVisitsRatio -- do mult

local MinigamesStorageCostPerDay = 105.5 * MinigamesPerDay -- in Bytes/day

local MaxUsage = MaxServerData / 2
local DaysUntilMaxUsage = MaxUsage / MinigamesStorageCostPerDay
print(DaysUntilMaxUsage)

-->> 141.35...
```

!!! info "Info"
    This is just one example of what one can do with large data. The possibiblities are down to your imagination.

### Accessing deeply-nested keys

Being able to access a deeply-nested key can be helpful for a few reasons:

+ It can save on `HttpService` budget and lowers the amount of downloaded data
+ Saves unnecessary lines of code rooting through tables
+ Saves on sanity checks: `if table.that.this then end`

###