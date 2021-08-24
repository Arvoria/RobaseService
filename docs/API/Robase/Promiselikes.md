# Promise-like methods

Promise returning methods allow you to abstract over the original async methods of Robase so that you can implement custom functionality. This requires knowledge of Promises to implement and even further knowledge on them to perform meaningful tasks that Robase does not. These are retrieved synchronously but consumed asynchronously.

## Get

Returns a promise associated with retrieving a value from the database.

```{.lua .api-ref}
Robase:Get(key: string) --> Promise
```
:   Returns a promise synchronously for an asynchronous get operation.

    `key: string`
    :   The name of the key you wish to retrieve data from.

---

## Set

Returns a promise associated with adding a value into the database.

```{.lua .api-ref} 
Robase:Set(key: string, data: any [, method: string]) --> Promise
```
:   Returns a promise synchronously for an asynchronous set operation.

    `key: string`
    :   The name of the key you wish to add data into (will create a new key if one does not exist).

    `data: any`
    :   The data you wish to add to the database

    `method?: string`
    :   Optional parameter defining the HTTP Method to use, this will default to "PUT".

---