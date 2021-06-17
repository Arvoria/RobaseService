# Introduction

Robase has been in development since June 2020 and has been released since August 2020. Development first began when the need to store larger and larger data grew and it became apparent that DataStores were not going to be the answer; ever.

??? summary "Extending the wrapper"
    If you are planning on writing a manager similar to ProfileService using RobaseService, knowledge of [Promises](https://eryn.io/roblox-lua-promise/) will likely be needed.

---

## What's the purpose?

RobaseService aims to provide a reliable and safe method of saving and loading data, no matter how big or small. But what lets DataStoreService down? Let me explain:

+ You are limited to 4MB of data per key, with keys having a smaller max length than Firebase.

+ You can only access top-level keys (generally, this is `Player.UserId`) and must define a path to a given point with table notation. (`table.this.that`).

+ DataStoreService's internals are not exposed, meaning it is a strenuous task to figure out how exactly every method works as well as some involved research. Robase is open-sourced, this means that it's source code is available to everyone and can be looked at and researched easily - especially with the source documentation! This will make extending and wrapping RobaseService simpler and creating a manager similar to [DataStore2](https://kampfkarren.github.io/Roblox/) by Kampfkarren or [ProfileService](https://madstudioroblox.github.io/ProfileService/) by loleris.

+ The methods are not guranteed to be race condition free, Robase uses [Promises](https://eryn.io/roblox-lua-promise/) by evaera to ensure race safety. Every async function will yield until a value is retrieved. {--In a future release, synchronous operations which return the promise may become available--}

+ Cannot be updated dynamically, from anywhere, at anytime. This makes systems such as FFlags not possible, A/B Testing extraneous, and timed-events that can turn on at a moment's notice in a live game - impossible. With Robase however, this is very simple.

### Storage limitations

Before using Robase something you may want to ask yourself is: Do I really need this? In most cases, DataStore2 or ProfileService will serve you well, though you won't be saving anything big or complex. If you are looking to store large, complex data, then Robase is something you will want in your arsenal.

Firebase's Spark plan provides you with 1GB storage in total per database/project and 10GB data downloaded per month. The Blaze plan is priced at how much you are using each, billed each month; each GB of storage costs $5 per month and each GB downloaded costs $1 per month. With the Blaze plan, a database using 1GB of storage and 100GB downloaded per month will be estimated to pay $105 per month. In addition to this you get other bonuses. 

The differences between the Spark and Blaze plan is documented [here](https://firebase.google.com/pricing)

[This example profile](https://pastebin.com/5zhfsfJb) shows just how complex and large data can be even when it has been optimised for storage. This profile will take up 3.6KB of data, that's not so much, right? Now imagine you have 100,000 unique players playing your game, that's now ~352MB, over a third of the capacity for the free plan. That's **a lot** of data!

But this is just player data, what about things that happen in a server? Think about: an experience-wide event, like "Double XP" and how would you handle it; or even the optimised metadata for every minigame played; FFlags deployment system. There is a lot of things you can do in the backend of your database and it can be controlled remotely.  

[This example server data](https://pastebin.com/98ZMUN4r) gives an example look at how a Firebase structure could be setup as a Lua table.  
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
    This is just one example of what one can do with large data. The possibilities are down to your imagination.

### Accessing deeply-nested keys

Being able to access a deeply-nested key can be helpful for a few reasons:

+ It can save on `HttpService` budget and lowers the amount of downloaded data
+ Saves unnecessary lines of code rooting through tables
+ Gruesome sanity checks are a thing of the past! Making a request to a key using `::GetAsync()` will always return profound information:  
    `(success: boolean, value: string | table)`  
    Success is either true or false - if the information was retrieved or sent successfully.  
    Value will be the response body with a successful request or the whole response dictionary if it fails.

### Extending Robase and managing your data

Writing your own manager similar to DataStore2 or ProfileService may seem daunting at first, but as long as you are safe and secure when handling your data, it does not need to be as developed and can simply be a primitive version of them, but take note:

!!! info "Key Information"
    + Cache is a necessity;

    + Session-Locking is recommended;

    + You should write parsers to form keys to access data when needed;

    + Downloading the whole database for each server is cumbersome and can lead to eating through your data usage, only access data thats needed, de-serialise your data appropriately;

    + Check out the source code for insight into how the code works!

### Why Promises?

!!! quote
    The way Roblox models asynchronous operations by default is by yielding (stopping) the thread and then resuming it when the future value is available. This model is not ideal because:

    + Functions you call can yield without warning, or only yield sometimes, leading to unpredictable and surprising results. Accidentally yielding the thread is the source of a large class of bugs and race conditions that Roblox developers run into.
    
    + It is difficult to deal with running multiple asynchronous operations concurrently and then retrieve all of their values at the end without extraneous machinery.
    
    + When an asynchronous operation fails or an error is encountered, Lua functions usually either raise an error or return a success value followed by the actual value. Both of these methods lead to repeating the same tired patterns many times over for checking if the operation was successful.
    
    + Yielding lacks easy access to introspection and the ability to cancel an operation if the value is no longer needed.

Source: *[why you should use promises](https://eryn.io/roblox-lua-promise/#why-you-should-use-promises)*


### Dynamic Updates

Every key in your Firebase Realtime Database can be modified from the Firebase Console. This allows for some unique behaviour that you couldn't otherwise do without loading up the client and entering the game yourself to modify DataStores through the command line - which is slow, and can be complicated.

With a Realtime Database you can have functions that check keys periodically or do something at specific times, or enable/disable beta features/content for your players depending on the value received.

As noted in our example, Double XP is a perfect example of a timed event that can run via your database. You can set a key, say "Activate" to true, and then watch as your game-code updates and displays that the event is in progress and updates accordingly.

You can have Fast Flags for your game, this is the deployment system Roblox uses to enable and disable content, it's also why bugs can just appear out of nowhere sometime.