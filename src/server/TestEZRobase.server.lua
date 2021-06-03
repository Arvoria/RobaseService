local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local TestEZModule = Shared:WaitForChild("TestEZ")
local TestEZ = require(TestEZModule)

local Tests = Shared:FindFirstChild("RobaseTests"):GetDescendants()
TestEZ.TestBootstrap:run(Tests)