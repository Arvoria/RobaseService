# API Reference

!!! warning 
    This page is still in the process of being documented.

## RobaseService
???+ stop "Caution"
    RobaseService cannot be used without first instantiating it with `.new` and providing a Firebase Database Url and a Secrets Authentication Token.
---

#### RobaseService.new
```{.lua class="apidoc"}
--@tparam baseUrl: string, the URL of your database, this can be seen from within the Realtime Database view of the Firebase Console
--@tparam token: string, the authentication token of your Firebase Realtime Database, currently the only supported authentication method is Database Secrets.
--@treturn RobaseService, a custom RobaseService for the Database specified at the baseUrl
RobaseService.new(baseUrl: string, token: string) --> RobaseService
```
Used to instantiate a new RobaseService with the provided Url and Auth Token.

#### RobaseService:GetRobase
```{.lua class="apidoc"}
--@tparam[opt] name: string, the name of the key in the database you want to access
--@tparam[opt] scope: string, the scope of the database, this is the location that will be searched from for 'name'
--@treturn Robase, the Robase object created to perform work on
RobaseService:GetRobase([name: string, [scope: string]]) --> Robase
```
Used to retrieve a Robase object with a path supplied from scope and name.

## Robase
???+ warning "Caution"
    Robase will handle failed requests automatically by throwing an error. They will never return `(false, any)` but they can return `(true, nil)`, for this reason it is recommended to wrap your method calls with a [pcall](https://developer.roblox.com/en-us/api-reference/lua-docs/Lua-Globals).
---

#### Robase:GetAsync
```{.lua class="apidoc"}
--@tparam key: string, the key (or url path separating keys with "/") you wish to access within the Robase object
--@treturn Success: bool, states whether or not the request succeeded, if it fails Robase will throw an error so this value is always true, if you wish to catch errors, use pcalls.
--@treturn Result: any, the result of the request, this is the Response Body
Robase:GetAsync(key: string) --> Success: Boolean, Result: any
```
Retrieves the data stored at the given key within the Robase.

#### Robase:SetAsync
```{.lua class="apidoc"}
--@tparam key: string, the key (or url path separating keys with "/") you wish to add data to
--@tparam data: table, the data to be added to the database
--@tparam[opt="PUT"] method: string, the method type to use
--@treturn Success: bool, states whether or not the request succeeded, if it fails Robase will throw an error so this value is always true, if you wish to catch errors, use pcalls.
--@treturn Result: any, the result of the request, this is the Response Body
Robase:SetAsync(key: string, data: any, [method: string]) --> Success: Boolean, Result: any
```
Adds data into the Robase at the key specified using the given method.

+ `PUT`/`PATCH`/`DELETE`/`POST` are all valid method types.

#### Robase:IncrementAsync
```{.lua class="apidoc"}
--@tparam key: string, the key (or url path separating keys with "/") you wish to increment
--@tparam[opt=1] delta: integer, the
--@treturn Success: bool, states whether or not the request succeeded, if it fails Robase will throw an error so this value is always true, if you wish to catch errors, use pcalls.
--@treturn Result: any, the result of the request, this is the Response Body
Robase:IncrementAsync(key: string, [delta: integer]) --> Success: Boolean, Result: any
```
??? stop "Usage restrictions"
    + You can only use `::IncrementAsync` on keys with integer values!

    + Delta *must* be an integer or nil!

Increments the data stored at the given key by the supplied delta. This only works on key's which have an integer value and with an integer-only delta (ex. 1.5 will not work)

Delta is an optional parameter and will default to 1 if not supplied.

#### Robase:DeleteAsync
```{.lua class="apidoc"}
--@tparam key: string, the key (or url path separating keys with "/") you wish to delete
--@treturn Success: bool, states whether or not the request succeeded, if it fails Robase will throw an error so this value is always true, if you wish to catch errors, use pcalls.
--@treturn Result: any, the result of the request, this is the Response Body
Robase:DeleteAsync(key: string) --> Success: Boolean, Result: any
```
!!! stop "Dangerous"
    This method is incredibly dangerous. It can delete entire trees of data and cannot be rolled back. It will return the data previously stored at the key given.

#### Robase:UpdateAsync
```{.lua class="apidoc"}
--@tparam key: string, the key (or url path separating keys with "/") you wish to update
--@tparam callback: function, the  updater function used to modify the data, it must return a table
--@tparam[opt] cache: table, the data currently stored in the current session located from the key, generally newer than a GetAsync(key) but you should always update the database first before updating the cache.
--@treturn Success: bool, states whether or not the request succeeded, if it fails Robase will throw an error so this value is always true, if you wish to catch errors, use pcalls.
--@treturn Result: any, the result of the request, this is the Response Body
Robase:UpdateAsync(key: string, callback: Function, [cache: table]) --> Success: Boolean, Result: any
```
Retrieves data from the Robase at the key given, or from the cache if provided and transforms it using the callback function and updates the key with a new value.

#### Robase:BatchUpdateAsync
```{.lua class="apidoc"}
--@tparam baseKey: string, the baseKey (or url path separating keys with "/") you wish to update the  specified keys of (provided by the keys in the callbacks table)
--@tparam callbacks: table, a table of updater functions the keys should be named according to the keys in the database you wish to update
--@tparam[opt] cache: table, the data currently stored in the current session located from baseKey, generally newer than a GetAsync(key) but you should always update the database first before updating the cache.
--@treturn Success: bool, states whether or not the request succeeded, if it fails Robase will throw an error so this value is always true, if you wish to catch errors, use pcalls.
--@treturn Result: any, the result of the request, this is the Response Body
Robase:BatchUpdateAsync(baseKey: string, callbacks: table, [cache: table]) --> Success: Boolean, Result: any
```
Similar in functionality to `:UpdateAsync` except given a baseKey, it will modify keys (given by the keys of the callbacks array) with the provided updater functions.