# Query Methods

All query methods are an implementation of the Firebase REST API's query parameters, for more information please [visit the documentation](https://firebase.google.com/docs/database/rest/retrieve-data#section-rest-uri-params) on retrieving data and how query parameters are used. This section of the documentation will not cover the specifics of each case and will instead provide a general overview of the Robase API.

## Shallow Data

Shallow data is an important query useful for large datasets where you don't need to know all the information at a given place or its child data, and only need to know it exists.

Setting this to true will limit the depth of the data returned. If the data at the specified location is a JSON primitive data type, it will return the data exclusively. Otherwise, the values for each key will be truncated to `true`.

### setShallow

!!! stop "Usage Limitation"
    Shallow queries are independent queries and cannot be combined with other query methods for [Ordering Data](#ordering-data)

```{.lua .api-ref}
Robase:setShallow(value: boolean) --> Robase
```
:   Returns a modified Robase object with its shallow query parameter set to the value given. This will truncate all values to `true` if the target location is a JSON object, or the literal value if the target location is a JSON primitive.

    `value: boolean`
    :   The value of the query parameter

---

## Ordering Data

!!! stop "Limitation"
    Results returned by `orderBy` are unsorted because JSON interpreters do not enforce any ordering on the result. When combined with a `startAt`, `endAt`, `limitToFirst`, or `limitToLast` to retrieve a subset of the data, though these results will be unsorted.

    Thus, if necessary, sorting must be done manually.

!!! stop "Requirement"
    The `orderBy` query parameter requires string values to be escaped as literal strings in the URL, so your strings should escape `"` quotes. For example:
    ```lua
    Robase:orderBy("\"$key\"")
    ----
    Robase:orderBy('"$key"')
    ----
    Robase:equalTo( ("\"%s\""):format("$priority") )
    ```

Ordering data is simple to do by constructing queries based on certain factors. Initially, you must define *how* you want your data to be ordered - by key, value, or priority - using the `orderBy` method, this will return a modified Robase object with an ordering query setup. This Robase is now ready to be used with filtering methods: `startAt`, `endAt`, `equalTo`, `limitToFirst`, and `limitToLast`.

### orderBy

The `orderBy` method is used to tell Robase what method the filtering queries should be ordered with, the options are:
:   
    + `orderBy=$key`: will filter results based on their key.
    
    + `orderBy=$value`: will filter results based on their value.
    
    + `orderBy=$priority`: will filter results on their priority.

```{.lua .api-ref}
Robase:orderBy(value: any) --> Robase
```
:   Returns a new, modified Robase with its ordering query parameter set.

    `value: any`
    :   The ordering method or child key to be used when filtering data. This value must be convertible to the `string` data type.

Furthermore, you can also order by a specific **child key**, which put simply: allows you to filter results based on a specific key. For example, a `Level` node in the database where player data is stored and each player has a level, like so:

```json
{
    "Player1": {
        Level: 10
    },
    "Player2": {
        Level: 2
    }
}
```

!!! caution
    If you are ordering by child key, any **node** at the target location that does not contain that specific key will be returned as `null` and should be handled appropriately.

---

## Range Queries

!!! advice "Useful Tip"
    Range queries are useful when you need to paginate your data!

!!! stop "Requirement"
    The Range query parameters require string values to be escaped as literal strings in the URL, so your strings should escape `"` quotes. For example:
    ```lua
    Robase:startAt("\"$key\"")
    ----
    Robase:endAt('"$value"')
    ----
    Robase:equalTo( ("\"%s\""):format("$priority") )

### startAt

```{.lua .api-ref}
Robase:startAt(value: string) --> Robase
```
:   Returns a modified Robase object with its startAt query parameter set to the value given. This will give all results that start at (inclusive), and not before, the given value.

    `value: string`
    :   The value of which the results gathered should start. Results that do not start at this point (for example, "b", will exclude any result that ends before this).

---

### endAt

```{.lua .api-ref}
Robase:endAt(value: string) --> Robase
```
:   Returns a modified Robase object with its endAt query parameter set to the value given. This will return all results that end before (inclusive) the given value.

    `value: string`
    :   The value of which the results gathered should end. Results that start after this point will not be returned (for example calling `Robase:endAt("c")` will return all results that start and end up to the letter "c")

!!! advice "Tip"
    It is common to want to combine a startAt and endAt query to set the range of values that get returned, this is possible using Robase, you would simply chain the methods together.

    The example from the [Firebase documentation](https://firebase.google.com/docs/database/rest/retrieve-data#range-queries) would look like this:

    ```lua
    Robase:orderBy("$key"):startAt("b"):endAt("b\uf8ff")
    ```

    This example would return all results that start at 'b' and end before 'c'. The `\uf8ff` character used in the above example is a very high code point in the Unicode range

---

### equalTo

```{.lua .api-ref}
Robase:equalTo(value: string) --> Robase
```
:   Returns a modified Robase object with its equalTo query parameter set to the value given. This will return results that are equal to the value given from the target location of the Robase.

    `value: string`
    :   The value of which all results returned will be equal to.

---

## Limit Queries

!!! stop "Requirement"
    The Limit query parameters are required to be integers (whole numbers). For example:
    ```lua
    Robase:limitToFirst(100)
    ----
    Robase:limitToLast(10)
    ```

Limit queries are used to limit the amount of data returned from a request. The query parameters `limitToFirst` and `limitToLast` are used to set a maximum number of children to be returned. If the number of results is less than the limit, all of those results will be returned, otherwise if there are more results than the limit, only the limit will be returned.

### limitToFirst

```{.lua .api-ref}
Robase:limitToFirst(limit: integer) --> Robase
```
:   Returns a modified Robase object with its limitToLast query parameter set to the value given. This will return the first `{limit}` children at the target location.

    `limit: integer`
    :   The number of results to be returned by the request.

---

### limitToLast

```{.lua .api-ref}
Robase:limitToLast(limit: integer) --> Robase
```
:   Returns a modified Robase object with its limitToLast query parameter set to the value given. This will return the last `{limit}` children at the target location.

    `limit: integer`
    :   The number of results to be returned by the request.

---