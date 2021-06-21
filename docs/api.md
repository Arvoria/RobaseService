# API Reference

!!! warning 
    This page is still in the process of being documented.

## RobaseService
???+ stop "Caution"
    RobaseService cannot be used without first instantiating it with `.new` and providing a Firebase Database Url and a Secrets Authentication Token.
---

#### RobaseService.new
```{.lua}
RobaseService.new(baseUrl: string, token: string)
    --> RobaseService
```
Used to instantiate a new RobaseService with the provided Url and Auth Token.

#### RobaseService:GetRobase
```{.lua}
RobaseService:GetRobase([name: string, [scope: string]])
    --> Robase
```
Used to retrieve a Robase object with a path supplied from scope and name.

## Robase
???+ warning "Caution"
    Robase will handle failed requests automatically by throwing an error. They will never return `(false, any)` but they can return `(true, nil)`
---

#### Robase:GetAsync
```{.lua}
Robase:GetAsync(key: string)
    --> Success: Boolean, Result: any
```
Retrieves the data stored at the given key within the Robase.

#### Robase:SetAsync
```{.lua}
Robase:SetAsync(key: string, data: any, [method: string])
    --> Success: Boolean, Result: any
```
Adds data into the Robase at the key specified using the given method.

The `method` parameter is optional and is mainly used internally to differentiate requests.

+ `PUT`/`PATCH`/`DELETE`/`POST` are all valid method types.

+ Defaults to `PUT` requests.

#### Robase:IncrementAsync
```{.lua}
Robase:IncrementAsync(key: string, [delta: integer])
    --> Success: Boolean, Result: any
```
??? stop "Usage restrictions"
    + You can only use `::IncrementAsync` on keys with integer values!

    + Delta *must* be an integer or nil!

Increments the data stored at the given key by the supplied delta. This only works on key's which have an integer value and with an integer-only delta (ex. 1.5 will not work)

Delta is an optional parameter and will default to 1 if not supplied.

#### Robase:DeleteAsync
```{.lua}
Robase:DeleteAsync(key: string)
    --> Success: Boolean, Result: any
```
!!! stop "Dangerous"
    This method is incredible dangerous. It can delete entire trees of data and cannot be rolled back. It will return the data previously stored at the key given.

#### Robase:UpdateAsync
```{.lua}
Robase:UpdateAsync(key: string, callback: Function, [cache: table])
    --> Success: Boolean, Result: any
```
Retrieves data from the Robase at the key given, or from the cache if provided and transforms it using the callback function and updates the key with a new value.

#### Robase:BatchUpdateAsync
```{.lua}
Robase:BatchUpdateAsync(baseKey: string, callbacks: table, [cache: table])
    --> Success: Boolean, Result: any
```
Similar in functionality to `:UpdateAsync` except will take a baseKey and then use the keys from the callbacks array to form a key to update using the provided callback function to update the value.