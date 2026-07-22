local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local env = getgenv() or _G

if env.NombresOcultos == nil then
    env.NombresOcultos = false
end

env.NombresOcultos = not env.NombresOcultos
local estanOcultos = env.NombresOcultos

local function aplicarEstado(character)
    local humanoid = character:WaitForChild("Humanoid")
    if estanOcultos then
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    else
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
    end
end

if localPlayer then
    if estanOcultos then
        localPlayer.NameDisplayDistance = 0
    else
        localPlayer.NameDisplayDistance = 100
    end
end

for _, player in pairs(Players:GetPlayers()) do
    if player.Character then
        aplicarEstado(player.Character)
    end
end

if env.EventoNombres then
    env.EventoNombres:Disconnect()
end

env.EventoNombres = Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(aplicarEstado)
end)
