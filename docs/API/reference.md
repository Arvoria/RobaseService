# Reference

This page exposes the methods of RobaseService and further pages discuss the semantics of how everything works.

## RobaseService
:   Methods that make up RobaseService
    
    + [RobaseService.new](../RobaseService/#new)
    + [RobaseService::GetRobase](../RobaseService/#getrobase)

## Robase

Methods (categorised by purpose) that make up the core of RobaseService - Robases.

### [Promiselike Methods](../Robase/Promiselikes/)
:   Methods that return promises to be consumed by the provider. Allowing for user-defined error handling among other use cases.

    + [Robase::Get](../Robase/Promiselikes/#get)
    + [Robase::Set](../Robase/Promiselikes/#set)

---

### [Asynchronous Methods](../Robase/AsyncMethods/)
:   Methods that consume a promise and return information. These use the promise-like methods above and consumes them automatically, handling errors appropriately.

    + [Robase::GetAsync](../Robase/AsyncMethods/#getasync)
    + [Robase::SetAsync](../Robase/AsyncMethods/#setasync)
    + [Robase::IncrementAsync](../Robase/AsyncMethods/#incrementasync)
    + [Robase::DeleteAsync](../Robase/AsyncMethods/#deleteasync)
    + [Robase::UpdateAsync](../Robase/AsyncMethods/#updateasync)
    + [Robase::BatchUpdateAsync](../Robase/AsyncMethods/#batchupdateasync)

---

### [Query Methods](../Robase/QueryMethods/)
:   Methods that filter the data retrieved by a request. These utilise the query parameters of the Firebase REST API. 

    + [Robase::setShallow](../Robase/QueryMethods/#setshallow)
    + [Robase::orderBy](../Robase/QueryMethods/#orderby)
    + [Robase::startAt](../Robase/QueryMethods/#startat)
    + [Robase::endAt](../Robase/QueryMethods/#endat)
    + [Robase::equalTo](../Robase/QueryMethods/#equalto)
    + [Robase::limitToFirst](../Robase/QueryMethods/#limittofirst)
    + [Robase::limitToLast](../Robase/QueryMethods/#limittolast)