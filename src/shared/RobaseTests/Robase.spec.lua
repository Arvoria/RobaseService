return function()

    local HttpService = game:GetService("HttpService")
    local Shared = script.Parent.Parent
    local RobaseService = require(Shared.RobaseService)
    RobaseService = RobaseService.new(
        "https://robasestore-test-default-rtdb.europe-west1.firebasedatabase.app/",
        "DOiy9dDWghkdUYJKiFLXV1MGYkPRuddjLTL3bQJi"
    )

    local PlayerData = RobaseService:GetRobase("PlayerData")

    beforeEach(function()
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
                        ["1"] = {
                            Coins = 10,
                            Level = 5,
                        },
                        ["2"] = {
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
        SKIP()
        it("should successfully retreive data", function()
            local Data = PlayerData:GetAsync("GetDataHere")
            expect(Data).to.be.ok()
        end)

        it("should fail to retrieve data from unknown keys", function()
            expect(PlayerData:GetAsync("DataDoesNotExist")).to.never.be.ok()
        end)
    end)

    describe("SetAsync", function()
        SKIP()
        it("should successfully PUT data into the database if it does not exist", function()
            local key, value = "GetDataHere/IPutThisHereRemotely", true
            local success, body = PlayerData:SetAsync(key, value, "PUT")
            expect(success).to.equal(true)
            expect(body).to.be.ok()
            expect(body).to.equal(value)
        end)

        it("should successfully replace data that exists in the database with a PUT request", function()
            local key, value = "GetDataHere/PutOverThis", 100
            local success, body = PlayerData:SetAsync(key, value, "PUT")
            expect(success).to.equal(true)
            expect(body).to.be.ok()
            expect(body).to.equal(value)
        end)

        it("should throw an error if no key is specified", function()
            expect(function()
                PlayerData:SetAsync(nil, "hello, world!", "PUT")
            end).to.throw()
        end)

        it("should manage malformed methods and set them to the default request method", function()
            local key, value = "GetDataHere/MalformedPutExample", "PuT"
            local success, body = PlayerData:SetAsync(key, value, "PuT")
            expect(success).to.equal(true)
            expect(body).to.be.ok()
            expect(HttpService:JSONDecode(body)).to.equal(value)
        end)
    end)

    describe("UpdateAsync", function()
        SKIP()
        it("should update a key in the database", function()
            local success, value = PlayerData:UpdateAsync(
                "GetDataHere",
                function(old)
                    old.UpdateWhatever ..= ", world!"
                    return old
                end
            )

            print(success, value)
        end)

        it("should throw an error if the callback is not a function", function()
            expect(function()
                PlayerData:UpdateAsync("GetDataHere/UpdateWhatever", "Hello, world!")
            end).to.throw()
        end)
    end)

    describe("DeleteAsync", function()
        SKIP()
        it("should delete a key from the database", function()
            local _, before = PlayerData:GetAsync("GetDataHere/DeleteMe")
            local success, removed = PlayerData:DeleteAsync("GetDataHere/DeleteMe")
            local _, after = PlayerData:GetAsync("GetDataHere/DeleteMe")

            expect(success).to.equal(true)
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
        SKIP()
        it("should increment integer-typed data - at a given key - by a set integer, delta", function()
            local key = "GetDataHere/IncrementThat"
            local delta = 25
            local success, value = PlayerData:IncrementAsync(key, delta)
            
            expect(success).to.equal(true) -- success check
            expect(value).to.be.ok() -- non-nil check
            expect(value).to.be.a("number") -- number check
            expect(value).to.equal(math.floor(value)) -- integer check
        end)

        it("should increment integer-typed data - at a given key - by 1 if delta is nil", function()
            local key = "GetDataHere/JustALevel"
            local success, value = PlayerData:IncrementAsync(key)
            
            expect(success).to.equal(true) -- success check
            expect(value).to.be.ok() -- non-nil check
            expect(value).to.be.a("number") -- number check
            expect(value).to.equal(math.floor(value)) -- integer check
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
        --SKIP()
        it("should update multiple child nodes from a baseKey with relevant callback functions", function()
            local _, Data = PlayerData:GetAsync("GetDataHere/BatchUpdateMe")
            local Callbacks = {
                ["Players"] = function(old)
                    for _, plr in pairs(old) do
                        plr.Level += 10
                        plr.Coins += 100
                    end
                    return old
                end,

                ["Server"] = function(old)
                    return os.date()
                end
            }

            local success, data = PlayerData:BatchUpdateAsync("GetDataHere/BatchUpdateMe", Data, Callbacks)
            print(success, data)
        end)

        itSKIP("should throw an error if the keyValues are not a table", function()

        end)

        itSKIP("should throw an error if the callbacks are not a table", function()
            
        end)

        itSKIP("should throw an error if a callback function cannot be found for a key", function()

        end)

        itSKIP("should throw an error if an element of the callbacks table is not a function", function()
            
        end)
    end)
end