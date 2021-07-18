return function()

    local RS = script.Parent.Parent
    local RobaseService = require(RS).new(
        "",
        ""
    )

    local PlayerData = RobaseService:GetRobase("PlayerData")

    local function shallow_eq(o1, o2, ignore_mt)
        if o1 == o2 then return true end
        local o1Type = type(o1)
        local o2Type = type(o2)
        if o1Type ~= o2Type then return false end
        if o1Type ~= 'table' then return false end

        if not ignore_mt then
            local mt1 = getmetatable(o1)
            if mt1 and mt1.__eq then
                --compare using built in method
                return o1 == o2
            end
        end

        local keySet = {}

        for key1, value1 in pairs(o1) do
            local value2 = o2[key1]
            if value2 == nil or shallow_eq(value1, value2, ignore_mt) == false then
                return false
            end
            keySet[key1] = true
        end

        for key2, _ in pairs(o2) do
            if not keySet[key2] then return false end
        end
        return true
    end

    beforeAll(function()
        PlayerData:SetAsync(
            "GetDataHere",
            {
                DeleteMe = true,
                IncrementThat = 25,
                JustALevel = 10,
                PutOverThis = 10,
                UpdateWhatever = "Hello",
                BatchUpdateMe = {
                    Players = {
                        ["123"] = {
                            Coins = 10,
                            Level = 5,
                        },
                        ["456"] = {
                            Coins = 10,
                            Level = 2
                        }
                    },
                    Server = {
                        LastUpdated = os.date()
                    }
                }
            },
            "PUT"
        )
    end)

    describe("GetAsync", function()
        it("should successfully retreive data", function()
            local _, Data = PlayerData:GetAsync("GetDataHere")
            expect(Data).to.be.ok()
        end)

        it("should fail to retrieve data from unknown keys", function()
            local Success, Data = PlayerData:GetAsync("DataDoesNotExist")
            expect(Success).to.equal(true)
            expect(Data).to.never.be.ok()
        end)

        it("should be able to perform on global level scope", function()
            local EmptyRobase = RobaseService:GetRobase()
            local _, PlrData = EmptyRobase:GetAsync("PlayerData")
            local _, Data = PlayerData:GetAsync("")

            expect(shallow_eq(PlrData, Data, true)).to.equal(true)
        end)
    end)

    describe("SetAsync", function()
        it("should successfully PUT data into the database if it does not exist", function()
            local key, value = "GetDataHere/IPutThisHereRemotely", true
            local Success, Data = PlayerData:SetAsync(key, value, "PUT")

            expect(Success).to.equal(true)
            expect(Data).to.be.ok()
            expect(Data).to.equal(value)
        end)

        it("should successfully replace data that exists in the database with a PUT request", function()
            local key, value = "GetDataHere/PutOverThis", 100
            local Success, Data = PlayerData:SetAsync(key, value, "PUT")

            expect(Success).to.equal(true)
            expect(Data).to.be.ok()
            expect(Data).to.equal(value)
        end)

        it("should throw an error if no key is specified", function()
            expect(function()
                PlayerData:SetAsync(nil, "hello, world!", "PUT")
            end).to.throw()
        end)

        it("should manage malformed methods and set them to the default request method", function()
            local key, value = "GetDataHere/MalformedPutExample", "PuT"
            local Success, Data = PlayerData:SetAsync(key, value, "PuT")

            expect(Success).to.equal(true)
            expect(Data).to.be.ok()
            expect(Data).to.equal(value)
        end)
    end)

    describe("UpdateAsync", function()
        it("should update a key in the database", function()
            local Success, Data = PlayerData:UpdateAsync(
                "GetDataHere",
                function(old)
                    old.UpdateWhatever ..= ", world!"
                    return old
                end
            )

            expect(Success).to.equal(true)
            expect(Data).to.be.ok()
            expect(Data.UpdateWhatever).to.equal("Hello, world!")
        end)

        it("should throw an error if the callback is not a function", function()
            expect(function()
                PlayerData:UpdateAsync("GetDataHere/UpdateWhatever", "Hello, world!")
            end).to.throw()
        end)
    end)

    describe("DeleteAsync", function()
        it("should delete a key from the database", function()
            local _, before = PlayerData:GetAsync("GetDataHere/DeleteMe")
            local Success, removed = PlayerData:DeleteAsync("GetDataHere/DeleteMe")
            local _, after = PlayerData:GetAsync("GetDataHere/DeleteMe")

            expect(Success).to.equal(true)
            expect(removed).to.be.ok()
            expect(removed).to.equal(before)
            expect(removed).to.never.equal(after)
        end)

        it("should abort request if key is nil", function()
            expect(function()
                PlayerData:DeleteAsync("GetDataHere/ThereIsNoDataHere")
            end).to.throw()
        end)
    end)

    describe("IncrementAsync", function()
        it("should increment integer-typed data - at a given key - by a set integer, delta", function()
            local key = "GetDataHere/IncrementThat"
            local delta = 25
            local Success, Data = PlayerData:IncrementAsync(key, delta)
            
            expect(Success).to.equal(true) -- success check
            expect(Data).to.be.ok() -- non-nil check
            expect(Data).to.be.a("number") -- number check
            expect(Data).to.equal(math.floor(Data)) -- integer check
        end)

        it("should increment integer-typed data - at a given key - by 1 if delta is nil", function()
            local key = "GetDataHere/JustALevel"
            local Success, Data = PlayerData:IncrementAsync(key)
            
            expect(Success).to.equal(true) -- success check
            expect(Data).to.be.ok() -- non-nil check
            expect(Data).to.be.a("number") -- number check
            expect(Data).to.equal(math.floor(Data)) -- integer check
        end)

        it("should throw an error if delta is non-nil and non-integer", function()
            local key = "GetDataHere/IncrementThat"
            local delta = "Cannot increment with a string"
            expect(function()
                PlayerData:IncrementAsync(key, delta)
            end).to.throw()
        end)

        it("should throw an error if the data retrieved at the key is non-integer", function()
            local key = "GetDataHere"
            local delta = 1
            expect(function()
                PlayerData:IncrementAsync(key, delta)
            end).to.throw()
        end)
    end)

    describe("BatchUpdateAsync", function()
        it("should update multiple child nodes from a baseKey with relevant callback functions", function()
            local calledAt = os.date()

            local Callbacks = {
                ["Players"] = function(old)
                    for _, plr in pairs(old) do
                        plr.Level += 10
                        plr.Coins += 100
                    end
                    return old
                end,

                ["Server"] = function(old)
                    old.LastUpdated = calledAt
                    return old
                end
            }

            local Success, data = PlayerData:BatchUpdateAsync("GetDataHere/BatchUpdateMe", Callbacks)

            expect(Success).to.equal(true)
            expect(data).to.be.ok()
            expect(data.Server.LastUpdated).to.equal(calledAt)
        end)

        it("should throw an error if the callbacks are not a table", function()
            expect(function()
                local _, Data = PlayerData:GetAsync("GetDataHere/BatchUpdateMe")
                local Callbacks = "ThisShouldThrow" -- wait a minute this isn't a table of functions

                PlayerData:BatchUpdateAsync("GetDataHere/BatchUpdateMe", Callbacks)
            end).to.throw()
        end)

        it("should throw an error if a key cannot be found for a callback function", function()
            expect(function()
                local calledAt = os.date()

                local Callbacks = {
                    ["Players"] = function(old) -- correct spelling
                        for _, plr in pairs(old) do
                            plr.Level += 10
                            plr.Coins += 100
                        end
                        return old
                    end,

                    ["Serve"] = function(old) -- intentional typo
                        old.LastUpdated = calledAt
                        return old
                    end
                }

                PlayerData:BatchUpdateAsync("GetDataHere/BatchUpdateMe", Callbacks)
            end).to.throw()
        end)

        it("should throw an error if an element of the callbacks table is not a function", function()
            expect(function()
                local calledAt = os.date()

                local Callbacks = {
                    ["Players"] = function(old) -- correct spelling
                        for _, plr in pairs(old) do
                            plr.Level += 10
                            plr.Coins += 100
                        end
                        return old
                    end,

                    ["Server"] = calledAt
                }

                PlayerData:BatchUpdateAsync("GetDataHere/BatchUpdateMe", Callbacks)
            end).to.throw()
        end)
    end)
end