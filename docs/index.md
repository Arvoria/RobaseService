# RobaseService

RobaseService is a RESTful API wrapper for Firebase Realtime Database - written in untyped Luau - for Roblox Developers seeking an external database service with a simple to use Luau wrapper.

As mentioned, RobaseService seeks to be simple to use, but this is one of two core aims of this project. The second aim is to be an easy replacement to [DataStoreService](https://developer.roblox.com/en-us/api-reference/class/DataStoreService). You can find useful code to help with replacing old DataStore code and transferring data [here](Guide/robase-setup/#transferring-from-datastoreservice).

---

# Getting Help

If you wish to contact me regarding RobaseService there are a few ways to go about it, this list is in prefered order:

+ [Sloth Development Discord Server](https://discord.gg/aWKjrzR7Hx)
+ [Developer Forum Profile](https://devforum.roblox.com/u/shanesloth/summary)

# Recent Changes

+ RobaseService v2.1.0-beta has been released. This release adds querying support for most documented [Firebase URL Queries](https://firebase.google.com/docs/database/rest/retrieve-data#section-rest-filtering).

+ Added support for the following query parameters: `orderBy`, `shallow`, `limitToFirst`, `limitToLast`, `startAt`, `endAt`, and `equalTo`.

+ Documentation has been added for querying your database, [see here](API/Robase/QueryMethods/) for the API Reference.

+ Gave the API Reference page a makeover and changed the look of the "call-outs" (aka "caution", "tip", etc.) to fit better with the website theme.

+  [Github Release](https://github.com/Arvoria/RobaseService/releases/tag/v2.1.0-beta-rc) page now includes a `.rbxm` file for you to drop into your studio session. Documentation for this will be added soon.

+ Updated the [Roblox Model](https://www.roblox.com/library/7012135793/RobaseService) to current version.

+ You no longer have to wrap your Robase method calls with a `pcall` this is done behind the scenes (see: `HttpWrapper.lua` on Github).

+ Added proper error handling for `::GetAsync` and `::SetAsync`, this can be overridden if you know of `Promise` and have experience working with them you could use the `::Get` and `::Set` methods to alter generic behaviour of the functions.

+ Donation page and links have been set up, see [Donating](donating/) for more.