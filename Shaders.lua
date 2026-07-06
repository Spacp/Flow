if _G.FlowLoaded then return end
_G.FlowLoaded = true

-- SERVICIOS Y SETUP
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local Lighting         = game:GetService("Lighting")
local Terrain          = workspace.Terrain

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera
local targetGui   = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

if targetGui:FindFirstChild("FlowUI") then targetGui.FlowUI:Destroy() end

-- Configuración de Dimensiones
local defaultW, defaultH = 440, 250 
local MIN_H = 35 
local ANIM_DURATION = 0.2   
local CORNER_RADIUS = 8

-- Calcular Centro de Pantalla
local viewportSize = Camera.ViewportSize
local centerX = (viewportSize.X / 2) - (defaultW / 2)
local centerY = (viewportSize.Y / 2) - (defaultH / 2)

local function Tween(obj, props, duration)
    if not obj then return end
    local tween = TweenService:Create(obj, TweenInfo.new(duration or ANIM_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

-- SISTEMA DE SHADERS OPTIMIZADOS
local originalLighting = {
	GlobalShadows = Lighting.GlobalShadows, Brightness = Lighting.Brightness,
	Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
	ClockTime = Lighting.ClockTime, FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd,
	FogColor = Lighting.FogColor, ColorShift_Top = Lighting.ColorShift_Top,
	ColorShift_Bottom = Lighting.ColorShift_Bottom
}

local function clearShaders()
	for _, child in ipairs(Lighting:GetChildren()) do
		if string.match(child.Name, "^FX_") then child:Destroy() end
	end
	if Terrain:FindFirstChild("FX_Clouds") then Terrain.FX_Clouds:Destroy() end
	if workspace:FindFirstChild("FX_Fireflies") then workspace.FX_Fireflies:Destroy() end
	
	for k, v in pairs(originalLighting) do Lighting[k] = v end
end

local function makeEffect(class, parent, props)
    local eff = Instance.new(class)
    eff.Name = "FX_" .. class
    for k, v in pairs(props) do eff[k] = v end
    eff.Parent = parent
    return eff
end

local Shaders = {
    ["Realistic"] = function()
		Lighting.GlobalShadows = true; Lighting.ClockTime = 16.5; Lighting.Brightness = 3
        Lighting.Ambient = Color3.fromRGB(120, 120, 120)
        makeEffect("ColorCorrectionEffect", Lighting, {Contrast = 0.2, Saturation = 0.1})
        makeEffect("DepthOfFieldEffect", Lighting, {FocusDistance = 25, InFocusRadius = 45, FarIntensity = 0.2, NearIntensity = 0})
        makeEffect("BloomEffect", Lighting, {Intensity = 0.35, Size = 24})
        makeEffect("SunRaysEffect", Lighting, {Intensity = 0.18, Spread = 0.6})
        makeEffect("Clouds", Terrain, {Cover = 0.65, Density = 0.7, Color = Color3.fromRGB(255, 255, 255)})
	end,

	["Sun Nearby"] = function()
		Lighting.GlobalShadows = true; Lighting.ClockTime = 15.8; Lighting.Brightness = 2.8
        makeEffect("ColorCorrectionEffect", Lighting, {Contrast = 0.15, TintColor = Color3.fromRGB(255, 245, 230)})
        makeEffect("DepthOfFieldEffect", Lighting, {FocusDistance = 25, InFocusRadius = 45, FarIntensity = 0.12, NearIntensity = 0})
        makeEffect("SunRaysEffect", Lighting, {Intensity = 0.3, Spread = 0.9})
        makeEffect("BloomEffect", Lighting, {Intensity = 0.35, Size = 30})
        makeEffect("Clouds", Terrain, {Cover = 0.5, Density = 0.6, Color = Color3.fromRGB(255, 255, 255)})
	end,
	
    ["Sunset"] = function()
		Lighting.GlobalShadows = true; Lighting.ClockTime = 17.6; Lighting.Brightness = 3.5
		Lighting.Ambient = Color3.fromRGB(150, 100, 50); Lighting.OutdoorAmbient = Color3.fromRGB(140, 90, 40)
        makeEffect("ColorCorrectionEffect", Lighting, {Contrast = 0.2, Saturation = 0.2, TintColor = Color3.fromRGB(255, 220, 180)})
        makeEffect("DepthOfFieldEffect", Lighting, {FocusDistance = 25, InFocusRadius = 45, FarIntensity = 0.15, NearIntensity = 0})
        makeEffect("SunRaysEffect", Lighting, {Intensity = 0.2, Spread = 0.75})
        makeEffect("BloomEffect", Lighting, {Intensity = 0.3})
        makeEffect("Clouds", Terrain, {Cover = 0.75, Density = 0.85, Color = Color3.fromRGB(255, 150, 40)})
	end,

	["Mystic Evening"] = function()
		Lighting.GlobalShadows = true; Lighting.ClockTime = 6.4; Lighting.Brightness = 0.2 
		Lighting.OutdoorAmbient = Color3.fromRGB(15, 18, 30); Lighting.Ambient = Color3.fromRGB(10, 12, 20)
        makeEffect("DepthOfFieldEffect", Lighting, {FocusDistance = 25, InFocusRadius = 45, FarIntensity = 0.15, NearIntensity = 0})
        makeEffect("ColorCorrectionEffect", Lighting, {Contrast = 0.25, Saturation = -0.15, TintColor = Color3.fromRGB(160, 175, 220)})
        makeEffect("BloomEffect", Lighting, {Intensity = 0.15})
        makeEffect("Clouds", Terrain, {Cover = 0.85, Density = 0.95, Color = Color3.fromRGB(60, 65, 75)})
	end,

	["Fog"] = function()
		Lighting.GlobalShadows = true; Lighting.FogColor = Color3.fromRGB(70, 90, 110)
		Lighting.FogStart = 40; Lighting.FogEnd = 600
        makeEffect("ColorCorrectionEffect", Lighting, {Contrast = 0.1, Saturation = -0.1})
        makeEffect("Atmosphere", Lighting, {Density = 0.35, Color = Color3.fromRGB(120, 150, 180), Decay = Color3.fromRGB(30, 40, 70)})
        makeEffect("DepthOfFieldEffect", Lighting, {FocusDistance = 25, InFocusRadius = 45, FarIntensity = 0.15, NearIntensity = 0})
	end,

    ["Cloudy Day"] = function()
        Lighting.GlobalShadows = true; Lighting.ClockTime = 14; Lighting.Brightness = 1.8
		Lighting.Ambient = Color3.fromRGB(120, 125, 130)
        makeEffect("ColorCorrectionEffect", Lighting, {Contrast = 0.1, Saturation = -0.35})
        makeEffect("Clouds", Terrain, {Cover = 0.9, Density = 1, Color = Color3.fromRGB(100, 105, 115)})
    end,

	["Frozen Winter"] = function()
        Lighting.GlobalShadows = true; Lighting.ClockTime = 9.5; Lighting.Brightness = 3.2
		Lighting.Ambient = Color3.fromRGB(170, 200, 240)
        makeEffect("ColorCorrectionEffect", Lighting, {Contrast = 0.15, Saturation = -0.2, TintColor = Color3.fromRGB(220, 240, 255)})
        makeEffect("DepthOfFieldEffect", Lighting, {FocusDistance = 25, InFocusRadius = 45, FarIntensity = 0.15, NearIntensity = 0})
    end,

	["Cinematic Cake"] = function()
        Lighting.GlobalShadows = true; Lighting.ClockTime = 17.2; Lighting.Brightness = 3
		Lighting.Ambient = Color3.fromRGB(170, 130, 150)
        makeEffect("ColorCorrectionEffect", Lighting, {Contrast = 0.1, Saturation = 0.25, TintColor = Color3.fromRGB(255, 220, 230)})
        makeEffect("SunRaysEffect", Lighting, {Intensity = 0.15, Spread = 0.8})
        makeEffect("Clouds", Terrain, {Cover = 0.6, Density = 0.7, Color = Color3.fromRGB(255, 230, 235)})
    end
}

-- INTERFAZ PRINCIPAL
local Gui = Instance.new("ScreenGui")
Gui.Name, Gui.ResetOnSpawn, Gui.ZIndexBehavior, Gui.IgnoreGuiInset = "FlowUI", false, Enum.ZIndexBehavior.Global, true
Gui.Parent = targetGui

local Container = Instance.new("Frame")
Container.Name, Container.Size, Container.Position = "MainContainer", UDim2.new(0, defaultW, 0, defaultH), UDim2.new(0, centerX, 0, centerY)
Container.BackgroundTransparency, Container.Parent = 1, Gui

local DropShadow = Instance.new("ImageLabel")
DropShadow.Name, DropShadow.Size, DropShadow.Position, DropShadow.AnchorPoint = "PerfectShadow", UDim2.new(1, 40, 1, 40), UDim2.new(0.5, 0, 0.5, 0), Vector2.new(0.5, 0.5)
DropShadow.BackgroundTransparency, DropShadow.Image, DropShadow.ImageColor3 = 1, "rbxassetid://5554236805", Color3.new(0,0,0)
DropShadow.ImageTransparency, DropShadow.ScaleType, DropShadow.SliceCenter = 0.3, Enum.ScaleType.Slice, Rect.new(23, 23, 277, 277)
DropShadow.ZIndex, DropShadow.Parent = 0, Container

local Win = Instance.new("Frame")
Win.Size, Win.Position, Win.AnchorPoint = UDim2.new(1, 0, 1, 0), UDim2.new(0.5, 0, 0.5, 0), Vector2.new(0.5, 0.5)
Win.BackgroundColor3, Win.BackgroundTransparency, Win.ClipsDescendants, Win.Active = Color3.fromRGB(25, 25, 30), 0.15, true, true
Win.ZIndex, Win.Parent = 1, Container
Instance.new("UICorner", Win).CornerRadius = UDim.new(0, CORNER_RADIUS)
local GlassStroke = Instance.new("UIStroke", Win)
GlassStroke.Color, GlassStroke.Transparency, GlassStroke.Thickness = Color3.new(1,1,1), 0.85, 1.2

local TopBar = Instance.new("Frame")
TopBar.Size, TopBar.BackgroundTransparency, TopBar.ZIndex, TopBar.Parent = UDim2.new(1, 0, 0, MIN_H), 1, 2, Win

local Title = Instance.new("TextLabel")
Title.Text, Title.Font, Title.TextSize, Title.TextColor3 = "Flow • Shaders", Enum.Font.GothamMedium, 13, Color3.new(1,1,1)
Title.BackgroundTransparency, Title.Size, Title.Position = 1, UDim2.new(0, 110, 1, 0), UDim2.new(0, 15, 0, 0)
Title.TextXAlignment, Title.ZIndex, Title.Parent = Enum.TextXAlignment.Left, 3, TopBar

local SearchBar = Instance.new("Frame")
SearchBar.Size, SearchBar.Position, SearchBar.BackgroundColor3 = UDim2.new(1, -210, 0, 24), UDim2.new(0, 125, 0.5, -12), Color3.new(1,1,1)
SearchBar.BackgroundTransparency, SearchBar.ZIndex, SearchBar.Parent = 0.90, 3, TopBar
Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0, 6)
local SearchStroke = Instance.new("UIStroke", SearchBar)
SearchStroke.Color, SearchStroke.Transparency = Color3.new(1,1,1), 0.8

local HintInput = Instance.new("TextLabel")
HintInput.Name, HintInput.Text, HintInput.Font, HintInput.TextSize = "HintInput", "", Enum.Font.Gotham, 12
HintInput.TextColor3, HintInput.TextTransparency, HintInput.BackgroundTransparency = Color3.new(1,1,1), 0.65, 1
HintInput.Size, HintInput.Position, HintInput.TextXAlignment = UDim2.new(1, -16, 1, 0), UDim2.new(0, 8, 0, 0), Enum.TextXAlignment.Left
HintInput.ZIndex, HintInput.Parent = 3, SearchBar

local SearchInput = Instance.new("TextBox")
SearchInput.Size, SearchInput.Position, SearchInput.BackgroundTransparency = UDim2.new(1, -16, 1, 0), UDim2.new(0, 8, 0, 0), 1
SearchInput.Text, SearchInput.PlaceholderText, SearchInput.Font, SearchInput.TextSize = "", "Search shaders...", Enum.Font.Gotham, 12
SearchInput.TextColor3, SearchInput.PlaceholderColor3, SearchInput.TextXAlignment = Color3.new(1,1,1), Color3.fromRGB(180, 180, 185), Enum.TextXAlignment.Left
SearchInput.ZIndex, SearchInput.Parent = 4, SearchBar

local function CreateBtn(icon, posOffset)
    local Btn = Instance.new("TextButton")
    Btn.Size, Btn.Position, Btn.BackgroundColor3 = UDim2.new(0, 24, 0, 24), UDim2.new(1, posOffset, 0.5, -12), Color3.new(1,1,1)
    Btn.BackgroundTransparency, Btn.Text, Btn.Font, Btn.TextSize = 0.85, icon, Enum.Font.Gotham, 16
    Btn.TextColor3, Btn.ZIndex, Btn.Parent = Color3.new(1,1,1), 4, TopBar
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
    return Btn
end

local MinBtn = CreateBtn("−", -65)
local CloseBtn = CreateBtn("×", -35)

local ResizeBtn = Instance.new("TextButton", Container)
ResizeBtn.Size, ResizeBtn.Position, ResizeBtn.BackgroundTransparency = UDim2.new(0, 18, 0, 18), UDim2.new(1, -2, 1, -2), 1
ResizeBtn.Text, ResizeBtn.TextColor3, ResizeBtn.TextTransparency = "◢", Color3.new(1,1,1), 0.40
ResizeBtn.Font, ResizeBtn.TextSize, ResizeBtn.ZIndex = Enum.Font.GothamBold, 14, 10

-- LISTA Y FILAS DE SHADERS (VISIBILIDAD FIJADA)
local Content = Instance.new("ScrollingFrame", Win)
Content.Size, Content.Position, Content.BackgroundTransparency = UDim2.new(1, -20, 1, -(MIN_H + 10)), UDim2.new(0, 10, 0, MIN_H + 5), 1
Content.ScrollBarThickness, Content.BorderSizePixel, Content.ZIndex = 0, 0, 3
Content.AutomaticCanvasSize, Content.CanvasSize = Enum.AutomaticSize.Y, UDim2.new(0, 0, 0, 0)
local ListLayout = Instance.new("UIListLayout", Content)
ListLayout.Padding = UDim.new(0, 6)

local ShaderButtons = {}
local activeToggle = nil

local ShaderOrder = {
    "Realistic", "Nearby Sun", "Golden Sunset",
    "Mystical Dusk", "Fog", "Cloudy",
    "Frozen Winter", "Cinematic Pastel"
}

for i, shaderName in ipairs(ShaderOrder) do
    local Btn = Instance.new("TextButton", Content)
    Btn.Name = "ShaderRow_" .. i
    Btn.Size, Btn.BackgroundColor3, Btn.BackgroundTransparency = UDim2.new(1, 0, 0, 34), Color3.new(1,1,1), 0.94
    Btn.Text, Btn.Font, Btn.TextSize, Btn.TextColor3 = "  " .. shaderName, Enum.Font.GothamMedium, 12, Color3.fromRGB(240,240,245)
    Btn.TextXAlignment, Btn.ZIndex = Enum.TextXAlignment.Left, 4
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)
    
    local ToggleBg = Instance.new("Frame", Btn)
    ToggleBg.Name = "ToggleBg"
    ToggleBg.Size, ToggleBg.Position, ToggleBg.BackgroundColor3 = UDim2.new(0, 34, 0, 18), UDim2.new(1, -45, 0.5, -9), Color3.fromRGB(90, 90, 95)
    ToggleBg.ZIndex = 5; Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(1, 0)
    
    local Circle = Instance.new("Frame", ToggleBg)
    Circle.Name = "ToggleCircle"
    Circle.Size, Circle.Position, Circle.BackgroundColor3 = UDim2.new(0, 14, 0, 14), UDim2.new(0, 2, 0.5, -7), Color3.new(1,1,1)
    Circle.ZIndex = 6; Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
    
    local tData = {Btn = Btn, Bg = ToggleBg, Circle = Circle, Name = shaderName:lower()}
    
    Btn.MouseButton1Click:Connect(function()
        if activeToggle == tData then
            Tween(ToggleBg, {BackgroundColor3 = Color3.fromRGB(90, 90, 95)}, 0.15)
            Tween(Circle, {Position = UDim2.new(0, 2, 0.5, -7)}, 0.15)
            activeToggle = nil; clearShaders()
        else
            if activeToggle then
                Tween(activeToggle.Bg, {BackgroundColor3 = Color3.fromRGB(90, 90, 95)}, 0.15)
                Tween(activeToggle.Circle, {Position = UDim2.new(0, 2, 0.5, -7)}, 0.15)
            end
            activeToggle = tData
            Tween(ToggleBg, {BackgroundColor3 = Color3.fromRGB(52, 199, 89)}, 0.15)
            Tween(Circle, {Position = UDim2.new(1, -16, 0.5, -7)}, 0.15)
            clearShaders(); Shaders[shaderName]()
        end
    end)
    table.insert(ShaderButtons, tData)
end

-- BUSCADOR
SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
	local query = string.lower(SearchInput.Text)
	local bestMatch = nil
	for _, item in ipairs(ShaderButtons) do
		if string.find(item.Name, query, 1, true) or query == "" then
			item.Btn.Visible = true
			if query ~= "" and not bestMatch then bestMatch = item.Btn.Text:sub(3) end
		else
			item.Btn.Visible = false
		end
	end
	if bestMatch and query ~= "" then
        if string.sub(string.lower(bestMatch), 1, #query) == query then
            HintInput.Text = SearchInput.Text .. string.sub(bestMatch, #query + 1)
        else
            HintInput.Text = bestMatch
        end
	else
		HintInput.Text = ""
	end
end)

-- ARRASTRE Y REDIMENSIÓN
local dragging, resizing = false, false
local dragStart, startPos, startSize = nil, nil, nil

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = Container.Position end
end)
ResizeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = true; dragStart = input.Position; startSize = Container.Size end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false; resizing = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if dragging then
            local delta = input.Position - dragStart
            Container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        elseif resizing then
            local delta = input.Position - dragStart
            Container.Size = UDim2.new(0, math.clamp(startSize.X.Offset + delta.X, 400, 600), 0, math.clamp(startSize.Y.Offset + delta.Y, 230, 450))
        end
    end
end)

-- MINIMIZAR ULTRA COMPACTO COMPLETO
local isClosing, isMinimized, savedSize = false, false, Vector2.new(defaultW, defaultH)

MinBtn.MouseButton1Click:Connect(function()
    if isClosing then return end; isMinimized = not isMinimized
    if isMinimized then
        MinBtn.Text, SearchInput.TextEditable, SearchInput.Active, ResizeBtn.Visible = "+", false, false, false
		savedSize = Vector2.new(Container.AbsoluteSize.X, Container.AbsoluteSize.Y)
        Tween(Container, {Size = UDim2.new(0, savedSize.X, 0, MIN_H)}, 0.18)
		Tween(SearchBar, {BackgroundTransparency = 1}, 0.18)
		Tween(SearchStroke, {Transparency = 1}, 0.18)
		Tween(SearchInput, {TextTransparency = 1}, 0.18); Tween(HintInput, {TextTransparency = 1}, 0.18)
		task.delay(0.18, function() if isMinimized then SearchBar.Visible = false end end)
        
        for _, c in pairs(Content:GetDescendants()) do
            if c:IsA("TextButton") then
                Tween(c, {BackgroundTransparency = 1, TextTransparency = 1}, 0.18)
            elseif c:IsA("Frame") then
                Tween(c, {BackgroundTransparency = 1}, 0.18)
            end
        end
    else
        MinBtn.Text, SearchBar.Visible, SearchInput.TextEditable, SearchInput.Active, ResizeBtn.Visible = "−", true, true, true, true
        Tween(Container, {Size = UDim2.new(0, savedSize.X, 0, savedSize.Y)}, 0.18)
		Tween(SearchBar, {BackgroundTransparency = 0.90}, 0.18)
		Tween(SearchStroke, {Transparency = 0.8}, 0.18)
		Tween(SearchInput, {TextTransparency = 0}, 0.18)
		if HintInput.Text ~= "" then Tween(HintInput, {TextTransparency = 0.65}, 0.18) end
        
        for _, c in pairs(Content:GetDescendants()) do
            if c:IsA("TextButton") and c.Name:match("ShaderRow") then
                Tween(c, {BackgroundTransparency = 0.94, TextTransparency = 0}, 0.18)
            elseif c.Name == "ToggleBg" then
                Tween(c, {BackgroundTransparency = 0}, 0.18)
            elseif c.Name == "ToggleCircle" then
                Tween(c, {BackgroundTransparency = 0}, 0.18)
            end
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    if isClosing then return end; isClosing = true
    Tween(Container, {Size = UDim2.new(0, Container.AbsoluteSize.X * 0.95, 0, Container.AbsoluteSize.Y * 0.95)}, 0.15)
    Tween(GlassStroke, {Transparency = 1}, 0.15)
    for _, c in pairs(Container:GetDescendants()) do
        pcall(function()
            if c:IsA("TextLabel") or c:IsA("TextBox") then Tween(c, {TextTransparency = 1}, 0.15)
            elseif c:IsA("TextButton") or c:IsA("Frame") then Tween(c, {BackgroundTransparency = 1}, 0.15)
            elseif c:IsA("ImageLabel") then Tween(c, {ImageTransparency = 1}, 0.15)
            elseif c:IsA("UIStroke") then Tween(c, {Transparency = 1}, 0.15) end
        end)
    end
    task.wait(0.15); pcall(clearShaders); _G.FlowLoaded = nil; Gui:Destroy()
end)
