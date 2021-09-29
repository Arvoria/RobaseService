local HttpService = game:GetService("HttpService")
local Promise = require(script.Parent:FindFirstChild("Promise"))

local HttpWrapper = { }

function HttpWrapper:Request(requestOptions)
    if requestOptions == nil then
        return Promise.reject("Argument 1 missing or nil")
    elseif requestOptions.Url == nil then
        return Promise.reject("Argument 1 missing Url field")
    end

    return Promise.new(function(resolve, reject)
        local response

        local ok, value = pcall(function()
            return HttpService:RequestAsync(requestOptions)
        end)

        if not ok then
            response.Success = false
            response.Body = "HttpWrapper could not make the request:\n" .. tostring(value)
            response.StatusCode = 408
            response.StatusMessage = "HTTP Request Timed Out (Probably)"
            reject(response)
        else
            response = value
            resolve(response.Body)
        end
    end)
end

return HttpWrapper