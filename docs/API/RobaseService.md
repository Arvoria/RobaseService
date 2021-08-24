# RobaseService
!!! stop "Danger"
    RobaseService cannot be used without first instantiating it with `.new` and providing a Firebase Database Url and a Secrets Authentication Token.

## new

Used to instantiate a new RobaseService with the provided Url and Auth Token.

```{.lua .api-code}
RobaseService.new(baseUrl: string, token: string) --> RobaseService
```
: This method will create a new RobaseService for the provided database.

    ```{.lua .api-param}
    baseUrl: string
    ```
    :   This is the URL of your database, it can be found at the top of the database view in the Firebase Console.
    
    ```{.lua .api-param}
    token: string
    ```
    :   This is your Database Secrets Authentication Token. Currently, RobaseService only accepts this method of authentication.

!!! stop "Danger"
    You must **not** store your Authentication Token and Database URL in your source code as plain-text. You should consider saving them (and any other secret information) into a DataStore and acquiring it from there.

---

## GetRobase

Used to retrieve a Robase object with a path supplied from scope and name.

```{.lua .api-ref}
RobaseService:GetRobase([name: string, [scope: string]]) --> Robase
```
:   This method will create a new Robase object at the path determined by scope and name.

    `name?: string`
    :   Optional (but recommended) parameter for the name of the key that the Robase points toward.

    `scope?: string`
    :   Optional parameter for the scope (directory path) you wish to start searching in for "name". This should be a path going through your database with keys separated by "/" like a file system!

---