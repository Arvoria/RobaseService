# API Reference

!!! warning 
    This page is still in the process of being documented.

## RobaseService
!!! stop "Caution"
    RobaseService cannot be used without first instantiating it with `.new` and providing a Firebase Database Url and a Secrets Authentication Token.

#### RobaseService.new

Used to instantiate a new RobaseService with the provided Url and Auth Token.

`#!lua-api-ref RobaseService.new(baseUrl: string, token: string) --> RobaseService`
: This method will create a new RobaseService for the provided database.

    `baseUrl: string`
    :   This is the URL of your database, it can be found at the top of the database view in the Firebase Console.

    `token: string`
    :   This is your Database Secrets Authentication Token. Currently, RobaseService only accepts this method of authentication.

#### RobaseService:GetRobase

Used to retrieve a Robase object with a path supplied from scope and name.

`#!lua-api-ref RobaseService:GetRobase([name: string, [scope: string]]) --> Robase`
:   This method will create a new Robase object at the path determined by scope and name.

    `name?: string`
    :   Optional (but recommended) parameter for the name of the key you wish to locate the Robase object from.

    `scope?: string`
    :   Optional parameter for the scope (directory depth) you wish to start searching for "name". This should be a path going through your database with keys separated by "/".

---

## Robase
!!! warning "Caution"
    Robase will handle failed requests automatically by throwing an error. They will never return `(false, any)` but they can return `(true, nil)`, for this reason, it is recommended to wrap your method calls with a [pcall](https://developer.roblox.com/en-us/api-reference/lua-docs/Lua-Globals).

### Promise-returning methods

Promise returning methods allow you to abstract over the original async methods of Robase so that you can implement custom functionality. This requires knowledge of Promises to implement and even further knowledge on them to perform meaningful tasks that Robase does not. These are retrieved synchronously but consumed asynchronously.

#### Get

Returns a promise associated with retrieving a value from the database.

`#!lua-api-ref Robase:Get(key: string) --> Promise`
:   Returns a promise synchronously for an asynchronous get operation.

    `key: string`
    :   The name of the key you wish to retrieve data from.

---

#### Set

Returns a promise associated with adding a value into the database.

`#!lua-api-ref Robase:Set(key: string, data: any [, method: string]) --> Promise`
:   Returns a promise synchronously for an asynchronous set operation.

    `key: string`
    :   The name of the key you wish to add data into (will create a new key if one does not exist).

    `data: any`
    :   The data you wish to add to the database

    `method?: string`
    :   Optional parameter defining the HTTP Method to use, this will default to "PUT".

---

### Async methods returning values

The asynchronous methods of Robase are here to immediately retrieve information and perform operations on your database. These are simple and have no side effects outside of the HTTP Requests they perform. 
These are useful if you don't wish to do anything on top of what Robase already does and just wish to use the core functions.

Internally, Robase uses the Promise-returning methods and consumes them with an `:await()` call.

#### Robase:GetAsync

Retrieves the data stored at the given key within the Robase.

`#!lua-api-ref Robase:GetAsync(key: string) --> Success: Boolean, Result: any`
:   Retrieves data from the database from the given key.

    `key: string`
    :   The name of the key you wish to retrieve data from.

---

#### Robase:SetAsync

Adds data into the Robase at the key specified using the given method.

`#!lua-api-ref Robase:SetAsync(key: string, data: any, [method: string]) --> Success: Boolean, Result: any`
:   Adds data into the Robase at the key specified using the given method if provided, or "PUT" otherwise.

    `key: string`
    :   The name of the key you wish to add data into (will create a new key if one does not exist).

    `data: any`
    :   The data you wish to put into the database.

    `method?: string`
    :   Optional parameter defining the HTTP Method to use, this will default to "PUT".

---

#### Robase:IncrementAsync

Increments the data stored at the given key by the supplied delta. This only works on key's which have an integer value and with an integer-only delta (ex. 1.5 will not work)

Delta is an optional parameter and will default to 1 if not supplied.

`#!lua-api-ref Robase:IncrementAsync(key: string, [delta: integer]) --> Success: Boolean, Result: any`
:   This method will increment an integer-typed value belong to the given key by either 1 or delta

    `key: string`
    :   The key you wish to increment

    `delta?: integer`
    :   An optional parameter for how much you wish to increment by, will default to 1

        This parameter **must** be an integer, it can not be a number (5.7 for example).

!!! stop "Usage restrictions"
    + You can only use `::IncrementAsync` on keys with integer values!

    + Delta *must* be an integer or nil!

---

#### Robase:DeleteAsync
`#!lua-api-ref Robase:DeleteAsync(key: string) --> Success: Boolean, Result: any`
:   This method will delete a key entirely from the database and returns the previously stored value.

    `key: string`
    :   The key you wish to delete from the database

!!! stop "Dangerous"
    This method is incredibly dangerous. It can delete entire trees of data and cannot be rolled back. It will return the data previously stored at the key given.

---

#### Robase:UpdateAsync

Retrieves data from the Robase at the given key, or from the cache if provided and transforms it using the callback function and updates the key with a new value.

`#!lua-api-ref Robase:UpdateAsync(key, callback [, cache])`
:   This method will take a key and modify its data using the callback ('updater') function. Optionally, it can take in a cache table whose contents match that of the key you are updating.

    `key: string`
    :   This is the key you are trying to modify the data of, it must be a table.

    `callback: function(oldData)`
    :   This is the function used to update (or modify) the data within the key.

    `cache?: {[string]=table,...}`
    :   Optional parameter used to provide Robase with data that should be newer than what the database has stored. Though it is strongly suggested that you update your database before updating your cache, else you risk losing data if your game crashes before the server can update the database with the cache.

---

#### Robase:BatchUpdateAsync

Similar in functionality to `:UpdateAsync` except given a baseKey, it will modify keys with the provided updater (callback) functions.

`#!lua-api-ref Robase:BatchUpdateAsync(baseKey, callbacks [, cache])`
:   This method takes in a baseKey and a table of callback ('updater') functions whose key's are children of the 'baseKey'. Optionally, it can take in a cache table whose keys match the callbacks table and should be the point of which baseKey starts in your database.

    `baseKey: string`
    :   This is the parent key of the keys you are trying to update, see the [usage guide]() for more information.

    `callbacks: {[string]=function(oldData),...}`
    :   A dictionary of string-keys and function-values, the keys of this table should be the same name as the keys you wish to modify within the 'baseKey' of your database. 
        
        These functions take a single parameter `oldData` and should return a table of modified data.        
        This parameter is retrieved internally either from `#!lua cache[key]` where `key` is a key from `callbacks`, or it will be equal to a `#!lua :GetAsync(key)` request if a cache is not provided.

    `cache?: {[string]=table]}`
    :   Optional parameter used to provide Robase with data that should be newer than what the database has stored. Though it is strongly suggested that you update your database before updating your cache, else you risk losing data if your game crashes before the server can update the database with the cache.