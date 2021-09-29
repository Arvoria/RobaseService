local HttpWrapper = require(script.Parent.HttpWrapper)
local HttpService = game:GetService("HttpService")

local ERROR_BAD_ARGUMENT = "Bad argument %d, [%s] expected got [%s]."

local Robase = { }
Robase.__index = Robase

local Enum = {
    HttpMethod = {
        ["Default"] = "PUT",
        ["Put"] = "PUT",
        ["Get"] = "GET",
        ["Delete"] = "DELETE",
        ["Patch"] = "PATCH"
    }
}

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function appendUrlQuery(url, queryName, queryData)
    if url:find("?") then
        return ("%s&%s=%s"):format(url, queryName, queryData)
    else
        return ("%s?%s=%s"):format(url, queryName, queryData)
    end
end

local function findHttpMethod(method)
    if method == nil then
        return Enum.HttpMethod.Default
    end

    for key, value in pairs(Enum.HttpMethod) do
        if method:lower() ~= key:lower() or method:upper() ~= value then
            continue
        else
            return Enum.HttpMethod[key]
        end
    end
    return nil
end

local function appendUrlQueryOptions(url, queryOptions)
    if queryOptions.shallow then
        url = appendUrlQuery(url, "shallow", tostring(queryOptions.shallow))
    else
        -- Shallow is incompatible with Filtering Queries

        if queryOptions.orderBy then
            url = appendUrlQuery(url, "orderBy", ('"%s"'):format(queryOptions.orderBy))

            -- Limiting Queries require an Ordering Query
            if queryOptions.limitToLast then
                url = appendUrlQuery(url, "limitToLast", queryOptions.limitToLast)
            end

            if queryOptions.limitToFirst then
                url = appendUrlQuery(url, "limitToFirst", queryOptions.limitToFirst)
            end

            --Range Queries require an Ordering Query
            if queryOptions.startAt then
                url = appendUrlQuery(url, "startAt", ('"%s"'):format(queryOptions.startAt))
            end

            if queryOptions.endAt then
                url = appendUrlQuery(url, "endAt", ('"%s"'):format(queryOptions.endAt))
            end

            if queryOptions.equalTo then
                url = appendUrlQuery(url, "equalTo", ('"%s"'):format(queryOptions.equalTo))
            end
        end
    end

    return url
end

local function generateRequestOptions(key, data, method, robase)
    assert(typeof(key)=="string", ERROR_BAD_ARGUMENT:format(1, "string", typeof(key)))
    assert(typeof(robase)=="table" and robase.Get and robase.Set, ERROR_BAD_ARGUMENT:format(4, "Robase-like table", typeof(robase)))

    if data ~= nil then
        data = HttpService:JSONEncode(data)
    end
    if typeof(method)~="string" or findHttpMethod(method)==nil then
        method = Enum.HttpMethod.Default
    end

    key = key:sub(1,1)~="/" and "/"..key or key

    local queryOptions = robase._queryOptions
    local url = appendUrlQueryOptions(
        robase._path .. HttpService:UrlEncode(key) .. robase._auth,
        queryOptions
    )

    return {
        Url = url,
        Method = findHttpMethod(method),
        Body = data
    }
end

function Robase.new(path, robaseService)
    assert(path~=nil, "Cannot instantiate Robase without a specific path")
    assert(robaseService~=nil, "Cannot instatiate Robase without a linked RobaseService")

    local self = { }
    self._path = path
    self._queryOptions = {}
    self._auth = robaseService.AuthKey
    self._robaseService = robaseService
    return setmetatable(self, Robase)
end

function Robase:Get(key)
    local options = generateRequestOptions(key, nil, "GET", self)
    return HttpWrapper:Request(options)
end

function Robase:Set(key, data, method)
    local options = generateRequestOptions(key, data, method, self)
    options.Headers = {
        ["Content-Type"] = "application/json"
    }
    return HttpWrapper:Request(options)
end

function Robase:GetAsync(key)
    local err
    local success, value = self:Get(key):catch(function(response)
        err = {response.StatusCode, response.StatusMessage, response.Body}
        error( ("Something went wrong, RobaseService:\n"
                .. "==============================\n"
                .. "Error: %d %s\n"
                .. "Body: %s"
            ):format(err[1], err[2], err[3])
        )
    end):await()

    value = value and HttpService:JSONDecode(value) or nil
    return success, value
end

function Robase:SetAsync(key, data, method)
    local set = self:Set(key, data, method)
    set:catch(function(response)
        local err = {response.StatusCode, response.StatusMessage, tostring(response.Body)}
        error( ("Something went wrong in RobaseService:\n"
                .. "==============================\n"
                .. "Error: %d %s\n"
                .. "Body: %s"
            ):format(err[1], err[2], err[3])
        )
    end)
    local success, value = set:await()

    value = value and HttpService:JSONDecode(value) or nil
    return success,value
end

function Robase:UpdateAsync(key, callback, cache)
    assert(typeof(callback)=="function", ERROR_BAD_ARGUMENT:format(2, "function", typeof(callback)))

    local success, data
    if cache~=nil and cache[key] then
        data = cache[key]
        success = (data~=nil)
    else
        success, data = self:GetAsync(key)
    end

    local updated = callback(data)

    return self:SetAsync(key, updated, "PATCH")
end

function Robase:DeleteAsync(key)
    local _, old = self:GetAsync(key)
    if old == nil then
        error(string.format(
            "No data found at key {%s}",
            key
            ))
    end

    local success, _ = self:SetAsync(key, "", "DELETE")
    return success, old
end

function Robase:IncrementAsync(key, delta)
    local _, data = self:GetAsync(key)

    if typeof(data)~="number" then -- not a number
        error(string.format(
            "IncrementAsync, data found at {%s} is not a number",
            key
            ))
    else -- is a number
        if math.floor(data) ~= data then -- not an integer
            error(string.format(
                "IncrementAsync, data found at {%s} is not an integer",
                key
                ))
        end
    end

    if typeof(delta) ~= "number" then -- not a number
        if typeof(delta) == "nil" then -- is nil
            delta = 1
        else -- not nil
            error(string.format(
                "IncrementAsync, delta is a {%s}, {nil|integer} expected",
                typeof(delta)
                ))
        end
    else -- is a number
        if math.floor(delta) ~= delta then -- not an integer
            error("IncrementAsync, delta is a number but is not an integer")
        end
    end

    data += delta
    return self:SetAsync(key, data, "PUT")
end

function Robase:BatchUpdateAsync(baseKey, callbacks, cache)
    assert(typeof(callbacks)=="table", ERROR_BAD_ARGUMENT:format(2, "table", typeof(callbacks)))
    for _, func in pairs(callbacks) do
        assert(typeof(func)=="function", ERROR_BAD_ARGUMENT:format(2, "function", typeof(func)) 
        .. "Callbacks dictionary must be populated with functions.")
    end

    local updated = { }

    for key, updateFunc in pairs(callbacks) do
        local success, data
        if cache~=nil and cache[key] then
            data = cache[key]
            success = (data~=nil)
        else
            success, data = self:GetAsync(("%s/%s"):format(baseKey, key))
        end
        assert(data ~= nil or not success, "Something went wrong retrieving data, make sure a key exists for a callback function to perform on")

        updated[key] = updateFunc(data)
    end

    return self:SetAsync(baseKey, updated, "PATCH")
end

function Robase:orderBy(orderBy)
    assert(not self._queryOptions.shallow, ('Shallow cannot be used with any of the "filtering data" query parameters.'))

    local newQueryOption = deepcopy(self._queryOptions)
    local deepcopyRobase = Robase.new(
        self._path,
        self._robaseService
    )
    newQueryOption.orderBy = orderBy
    deepcopyRobase._queryOptions = newQueryOption

    return deepcopyRobase
end

function Robase:setShallow(shallow)
    assert(typeof(shallow) == "boolean", ERROR_BAD_ARGUMENT:format(1, "boolean", typeof(shallow)))
    assert(
        not self._queryOptions.orderBy,
        ('shallow cannot be used with any of the "filtering data" query parameters.')
    )

    local newQueryOption = deepcopy(self._queryOptions)
    local deepcopyRobase = Robase.new(
        self._path,
        self._robaseService
    )
    newQueryOption.shallow = not not shallow
    deepcopyRobase._queryOptions = newQueryOption

    return deepcopyRobase
end


function Robase:limitToLast(limit)
    assert(
        not self._queryOptions.shallow,
        "Shallow cannot be used with any of the \"filtering data\" query parameters."
    )
    assert(self._queryOptions.orderBy, "Limit Queries require orderBy")
    assert(
        typeof(limit) == "number" and (math.floor(limit)==limit),
        ERROR_BAD_ARGUMENT:format(1, "number", typeof(limit))
    )

    local newQueryOption = deepcopy(self._queryOptions)
    local deepcopyRobase = Robase.new(
        self._path,
        self._robaseService
    )

    newQueryOption.limitToLast = tostring(limit)
    deepcopyRobase._queryOptions = newQueryOption

    return deepcopyRobase
end

function Robase:limitToFirst(limit)
    assert(
        not self._queryOptions.shallow,
        ('Shallow cannot be used with any of the "filtering data" query parameters.')
    )
    assert(self._queryOptions.orderBy, ('Limit Queries require orderBy'))
    assert(
        typeof(limit) == "number" and (math.floor(limit)==limit),
        ERROR_BAD_ARGUMENT:format(1, "number", typeof(limit))
    )

    local newQueryOption = deepcopy(self._queryOptions)
    local deepcopyRobase = Robase.new(
        self._path,
        self._robaseService
    )

    newQueryOption.limitToFirst = tostring(limit)
    deepcopyRobase._queryOptions = newQueryOption

    return deepcopyRobase
end

function Robase:startAt(value)
    assert(
        not self._queryOptions.shallow,
        ('Shallow cannot be used with any of the "filtering data" query parameters.')
    )
    assert(self._queryOptions.orderBy, ('Range Queries require orderBy'))
    assert(typeof(value) == "string", ERROR_BAD_ARGUMENT:format(1, "string", typeof(value)))

    local newQueryOption = deepcopy(self._queryOptions)
    local deepcopyRobase = Robase.new(
        self._path,
        self._robaseService
    )
    newQueryOption.startAt = value
    deepcopyRobase._queryOptions = newQueryOption

    return deepcopyRobase
end

function Robase:endAt(value)
    assert(
        not self._queryOptions.shallow,
        ('Shallow cannot be used with any of the "filtering data" query parameters.')
    )
    assert(self._queryOptions.orderBy, ('Range Queries require orderBy'))
    assert(typeof(value) == "string", ERROR_BAD_ARGUMENT:format(1, "string", typeof(value)))

    local newQueryOption = deepcopy(self._queryOptions)
    local deepcopyRobase = Robase.new(
        self._path,
        self._robaseService
    )

    newQueryOption.endAt = value
    deepcopyRobase._queryOptions = newQueryOption

    return deepcopyRobase
end

function Robase:equalTo(value)
    assert(
        not self._queryOptions.shallow,
        ('Shallow cannot be used with any of the "filtering data" query parameters.')
    )
    assert(self._queryOptions.orderBy, ('Range Queries require orderBy'))
    assert(typeof(value) == "string", ERROR_BAD_ARGUMENT:format(1, "string", typeof(value)))

    local newQueryOption = deepcopy(self._queryOptions)
    local deepcopyRobase = Robase.new(
        self._path,
        self._robaseService
    )
    newQueryOption.equalTo = value
    deepcopyRobase._queryOptions = newQueryOption

    return deepcopyRobase
end

return Robase
