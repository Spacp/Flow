local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

LocalPlayer.Idled:Connect(function()

    VirtualUser:CaptureController()

    VirtualUser:ClickButton2(Vector2.new())
end)
