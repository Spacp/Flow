local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function CloseScript()
    if _G.FlowUILoaded then
        _G.FlowUILoaded = false
        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if PlayerGui then
            local oldGui = PlayerGui:FindFirstChild("FlowIphoneBar")
            if oldGui then oldGui:Destroy() end
        end
        local CoreGui = game:GetService("CoreGui")
        if CoreGui then
            local oldCore = CoreGui:FindFirstChild("FlowIphoneBar")
            if oldCore then oldCore:Destroy() end
        end
        -- Limpiar variables globales si existen
        if _G.iconButtons then _G.iconButtons = nil end
        if _G.FreecamTouchConnections then
            for _, conn in ipairs(_G.FreecamTouchConnections) do pcall(function() conn:Disconnect() end) end
            _G.FreecamTouchConnections = nil
        end
        if _G.FreecamMobileGui then pcall(function() _G.FreecamMobileGui:Destroy() end); _G.FreecamMobileGui = nil end
    end
end

CloseScript()
