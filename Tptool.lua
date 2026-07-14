local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

if getgenv().TpConnection then getgenv().TpConnection:Disconnect() end
if getgenv().DeleteConnection then getgenv().DeleteConnection:Disconnect() end

for _, v in pairs(LocalPlayer:WaitForChild("Backpack"):GetChildren()) do
    if v.Name == "TP" then v:Destroy() end
end
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("TP") then
    LocalPlayer.Character:FindFirstChild("TP"):Destroy()
end

local Tool = Instance.new("Tool")
Tool.Name = "TP"
Tool.RequiresHandle = false
Tool.Parent = LocalPlayer.Backpack

mouse.TargetFilter = LocalPlayer.Character

getgenv().TpConnection = Tool.Activated:Connect(function()
    if not mouse.Target then return end 

    local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0, 3, 0))
    end
end)

getgenv().DeleteConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end 

    if input.KeyCode == Enum.KeyCode.Delete or input.KeyCode == Enum.KeyCode.Backspace then
        if Tool then Tool:Destroy() end
        if getgenv().TpConnection then getgenv().TpConnection:Disconnect() end
        if getgenv().DeleteConnection then getgenv().DeleteConnection:Disconnect() end
    end
end)
