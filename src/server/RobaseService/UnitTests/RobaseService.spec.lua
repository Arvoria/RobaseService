return function()
    local RS = script.Parent.Parent
    local RobaseService = require(RS)
    local TestUrl = ""
    local TestAuth = ""
    local TestName = "PlayerData"

    describe("new", function()
        it("should instantiate a new RobaseService with a BaseUrl and AuthToken", function()
            local ExampleService = RobaseService.new(TestUrl, TestAuth)

            expect(ExampleService).to.be.ok()
            expect(ExampleService.BaseUrl).to.be.ok()
            expect(ExampleService.AuthKey).to.be.ok()
        end)

        it("should throw an error when no BaseUrl is given", function()
            expect(function()
                RobaseService.new(nil, TestAuth)
            end).to.throw()
        end)

        it("should throw an error when no AuthKey is given", function()
            expect(function()
                RobaseService.new(TestUrl, nil)
            end).to.throw()
        end)
    end)

    describe("GetRobase", function()
        it("should fetch a new Robase with associated path and authentication", function()
            local ExampleService = RobaseService.new(TestUrl, TestAuth)
            local ExampleRobase = ExampleService:GetRobase(TestName)

            expect(ExampleRobase).to.be.ok()
            expect(ExampleRobase._path).to.be.ok()
            expect(ExampleRobase._auth).to.be.ok()
        end)

        it("should throw an error if called before instantiation", function()
            expect(function()
                RobaseService:GetRobase(nil, nil)
            end).to.throw()
        end)
    end)
end