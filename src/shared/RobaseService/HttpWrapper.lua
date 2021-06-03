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
        local response = HttpService:RequestAsync(requestOptions)

        if response.Success then
            resolve(response.Body)
        else
            reject(response)
        end
    end)
end

return HttpWrapper