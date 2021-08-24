# Introduction

Robase has been in development since June 2020 and has been released since August 2020. Development first began when the need to store larger and larger data grew and it became apparent that DataStores were not going to be the answer; ever.

??? summary "Extending the wrapper"
    If you are planning on writing a manager similar to ProfileService using RobaseService, knowledge of [Promises](https://eryn.io/roblox-lua-promise/) will likely be needed.

---

## What's the purpose?

RobaseService aims to provide a reliable and safe method of saving and loading data, no matter how big or small. But what does it offer that DataStoreService doesn't?

+ You are no longer limited to 4MB of data per key, your database can hold 1GB of storage and you have complete control over how everything is stored.

+ You can access any key within the real-time database, simply use "/" to separate the keys. With DataStores you only have access to one point, making querying difficult and ensuring all data exists a slog with sanity checks.

+ Robase is open-sourced, this means that its source code is available to everyone and can be looked at and researched easily {-- - especially with the source documentation--}! This will make extending and wrapping RobaseService simpler and creating an extension similar to [DataStore2](https://kampfkarren.github.io/Roblox/) by Kampfkarren or a manager like [ProfileService](https://madstudioroblox.github.io/ProfileService/) by loleris.

+ The `Async` methods are guaranteed to be race condition free, Robase uses [Promises](https://eryn.io/roblox-lua-promise/) by evaera to ensure race safety. Every async function will yield until a value is retrieved.  
As of Robase 2.0.1-beta, there are now promise-returning methods that give developers full freedom over how their requests are handled and the methods will pass back the promise to be operated on. These methods are documented [here](../api/#promise-returning-methods).

+ Can be updated dynamically whenever and however you please. To update a DataStore you have to go into a live game or studio and use the Command Bar to force a key to change, sometimes this just isn't practical. Doing this with Firebase however is simple to do and can be done from your browser, it's even accessible on your mobile! Just go to the Firebase Console and update it from the database view.

### Storage Freedom

Before using Robase something you may want to ask yourself is: Do I need this? In most cases, DataStore2 or ProfileService will serve you well, though you won't be saving anything big or complex. If you are looking to store large, complex data, then Robase is something you will want in your arsenal.

Firebase's Spark plan provides you with 1GB storage in total per database/project and 10GB of downloaded data per month. The Blaze plan is priced at how much you use, billed each month; each GB of storage costs $5 per month and each GB downloaded costs $1 per month. With the Blaze plan, a database using 1GB of storage and 100GB downloaded per month will be estimated to pay $105 per month. In addition to this, you get other bonuses. 

The differences between the Spark and Blaze plan is documented [here](https://firebase.google.com/pricing)

[This example profile](https://pastebin.com/5zhfsfJb) shows just how complex and large data can be even when it has been vaguely optimised for storage. This profile will take up 3.6KB of data, that's not so much, right? Now imagine you have 100,000 unique players playing your game, that's now ~352MB, over a third of the capacity for the free plan. That's **a lot** of data!

But this is just player data, what about things that happen in a server? Think about: an experience-wide event, like "Double XP" and how you would handle it; or even the optimised metadata for every minigame played; or an FFlags deployment system. There are a lot of things you can do in the backend of your database and it can all be controlled remotely.

[This example server data](https://pastebin.com/98ZMUN4r) gives an example look at how a Firebase structure could be set up as a Lua table.  
This structure is approximately 2KB in storage. `ServerData.PlayedMinigames.Games` is approximately 1.5KB in size, each minigame's data equating to 105.5B. 
What if we asked how much this could grow? Imagine we have a small experience, with about 20,000 visits per day. Now let us say that on average every visit garners 1.8 minigame plays, we can scale this up to how much the database will grow each day. For 20,000 visits we would have 36,000 minigames played - that's roughly 3.62MB!

Just how scalable and manageable is this? Well first we have to allow some assumptions:

+ We reserve 500MB in data for player data, the server can use the rest of it.

+ Growth is static and the number of visits/plays per day remains the same (20,000).

+ Minigames Played to Experience Visits ratio is static at 1.8.

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
    This is just one example of what one can do with large data. The possibilities are down to your imagination.

### Accessing deeply-nested keys

Being able to access a deeply-nested key can be helpful for a few reasons:

+ It can save on the `HttpService` budget and lowers the amount of downloaded data
+ Saves unnecessary lines of code rooting through tables
+ Gruesome sanity checks are a thing of the past! Making a request to a key using `:GetAsync()` will always return profound information:  
    `(success: boolean, value: any)`  
    Success is either true or an error is thrown.  
    Value will be the response body with a successful request or the whole response dictionary if it fails.

### Extending Robase and managing your data

Writing a custom manager similar to DataStore2 or ProfileService may seem daunting at first, but as long as you are safe and secure when handling your data, it does not need to be as developed and can simply be a primitive version of them, but take note:

!!! info "Key Information"
    + Cache is a necessity;

    + Session-Locking is recommended;

    + You should write parsers to form keys to access data when needed;

    + Downloading the whole database for each server is cumbersome and can lead to eating through your data usage, only access data that's needed, de-serialise your data appropriately;

    + Check out the source code for insight into how the code works!

### Why Promises?

!!! crossref "[Why you should use promises](https://eryn.io/roblox-lua-promise/#why-you-should-use-promises)"
    The way Roblox models asynchronous operations by default is by yielding (stopping) the thread and then resuming it when the future value is available. This model is not ideal because:

    + Functions you call can yield without warning, or only yield sometimes, leading to unpredictable and surprising results. Accidentally yielding the thread is the source of a large class of bugs and race conditions that Roblox developers run into.
    
    + It is difficult to deal with running multiple asynchronous operations concurrently and then retrieve all of their values at the end without extraneous machinery.
    
    + When an asynchronous operation fails or an error is encountered, Lua functions usually either raise an error or return a success value followed by the actual value. Both of these methods lead to repeating the same tired patterns many times over for checking if the operation was successful.
    
    + Yielding lacks easy access to introspection and the ability to cancel an operation if the value is no longer needed.


### Dynamic Updates

Every key in your Firebase Realtime Database can be modified from the Firebase Console. This allows for some unique behaviour that you couldn't otherwise do without loading up the client and entering the game yourself to modify DataStores through the command bar - which is slow and can be complicated.

With a Realtime Database, you can have functions in-game that check keys periodically or do something at specific times, or enable/disable beta features/content for your players depending on the value received.

As noted in our example, Double XP is a perfect example of a timed event that can run via your database. You can set a key, say "Activate" to true, and then watch as your game-code updates and displays that the event is in progress and updates accordingly.

You can create a Fast-Flag deployment system for your game. This is the deployment system Roblox uses to enable and disable features. This is possible with DataStoreService but it isn't as easy or convenient.