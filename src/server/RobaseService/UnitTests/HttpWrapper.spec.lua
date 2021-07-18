return function()
    local RobaseService = script.Parent.Parent
    local HttpWrapper = require(RobaseService.HttpWrapper)
    local HttpService = game:GetService("HttpService")

    local testRequests = { }
    testRequests.GetRequest = {
        Url = "https://httpbin.org/get",
        Method = "GET",
    }
    testRequests.PostRequest = {
        Url = "https://httpbin.org/post",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode({
            Hello = "Post"
        })
    }
    testRequests.PutRequest = {
        Url = "https://httpbin.org/put",
        Method = "PUT",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode({
            Hello = "Put"
        })
    }
    testRequests.PatchRequest = {
        Url = "https://httpbin.org/patch",
        Method = "PATCH",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode({
            Hello = "Patch"
        })
    }
    testRequests.DeleteRequest = {
        Url = "https://httpbin.org/delete",
        Method = "DELETE",
    }
    testRequests.FailRequest = {
        Url = nil,
        Method = "GET",
    }
    testRequests.UnsuccessfulRequest = {
        Url = "https://httpbin.org/status/400",
        Method = "GET"
    }

    describe("Request", function()
        it("should perform a simple get request", function()
            local request = HttpWrapper:Request(testRequests.GetRequest)
            request:andThen(function(body)
                expect(body).to.be.ok()
            end):catch(function(response)
                return
            end)
        end)

        it("should perform a simple post request", function()
            local request = HttpWrapper:Request(testRequests.PostRequest)
            request:andThen(function(body)
                expect(body).to.be.ok()
            end):catch(function(response)
                return
            end)
        end)

        it("should perform a simple put request", function()
            local request = HttpWrapper:Request(testRequests.PutRequest)
            request:andThen(function(body)
                expect(body).to.be.ok()
            end):catch(function(response)
                return
            end)
        end)

        it("should perform a simple patch request", function()
            local request = HttpWrapper:Request(testRequests.PatchRequest)
            request:andThen(function(body)
                expect(body).to.be.ok()
            end):catch(function(response)
                return
            end)
        end)

        it("should perform a simple delete request", function()
            local request = HttpWrapper:Request(testRequests.DeleteRequest)
            request:andThen(function(body)
                expect(body).to.be.ok()
            end):catch(function(response)
                return
            end)
        end)

        it("should catch unsuccessful requests", function()
            local request = HttpWrapper:Request(testRequests.UnsuccessfulRequest)
            request:andThen(function(body)
                return
            end):catch(function(response)
                expect(response).to.be.ok()
                expect(response.Body).to.be.ok()
                expect(response.StatusCode).to.be.ok()
                expect(response.StatusMessage).to.be.ok()
            end)
        end)

        it("should catch unspecified Url promise rejection", function()
            local request = HttpWrapper:Request(testRequests.FailRequest)
            request:andThen(nil, function(err)
                expect(err).to.be.ok()
            end)
        end)
    end)
end