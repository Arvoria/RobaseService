local Robase = require(script.Robase)
local HttpService = game:GetService("HttpService")

local RobaseService = { }
RobaseService.BaseUrl = nil
RobaseService.AuthKey = nil
RobaseService.__index = RobaseService

local function fixTrailingSlashes(url)

    local foundTrailingSlashes = url:match("/+$")
    url = foundTrailingSlashes and url:sub(1, url:len()-#foundTrailingSlashes) or url

    return url
end

function RobaseService.new(baseUrl, token)
    if baseUrl == nil then
        error("Bad Argument 1 baseUrl expected, got nil")
    elseif token==nil then
        error("Bad Argument 2 token expected, got nil")
    end

    local self = setmetatable({}, RobaseService)
    self.BaseUrl = fixTrailingSlashes(baseUrl)
    self.AuthKey = ".json?auth="..token
    return self
end

function RobaseService:GetRobase(name, scope)
    if self.AuthKey==nil or self.AuthKey=="" then
        error("You must instantiate RobaseService with an AuthKey to use the RobaseService API")
    elseif self.BaseUrl==nil or self.BaseUrl=="" then
        error("You must instantiate RobaseService with a BaseUrl to use the RobaseService API")
    end

    name = name and HttpService:UrlEncode(name) or ""
    scope = scope and HttpService:UrlEncode(scope) or ""

    local formatted = string.format("%s/%s/%s", self.BaseUrl, scope, name)
    --local formattedUrl = self.BaseUrl .. scope .. "/" .. name
    return Robase.new(formatted, self)
end

return RobaseService