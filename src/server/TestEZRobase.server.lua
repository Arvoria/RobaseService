local RobaseService = script.Parent.RobaseService
local UnitTests = RobaseService.UnitTests
local Tests = UnitTests:GetDescendants()
local Shared = game:GetService("ReplicatedStorage").Shared

local TestEZ = require(Shared.TestEZ)
TestEZ.TestBootstrap:run(Tests)