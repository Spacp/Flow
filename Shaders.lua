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

-- Configuración de Dimensiones y UI
local defaultW, defaultH   = 340, 250 
local MIN_H                = 35 
local ANIM_DURATION        = 0.2   
local CORNER_RADIUS        = 8
local MIN_W, MAX_W         = 280, 500
local MIN_WIN_H            = 180

-- Fuente nativa estilo San Francisco (Apple)
local TitleFont = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold)

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

	["Nearby Sun"] = function()
		Lighting.GlobalShadows = true; Lighting.ClockTime = 15.8; Lighting.Brightness = 2.8
        makeEffect("ColorCorrectionEffect", Lighting, {Contrast = 0.15, TintColor = Color3.fromRGB(255, 245, 230)})
        makeEffect("DepthOfFieldEffect", Lighting, {FocusDistance = 25, InFocusRadius = 45, FarIntensity = 0.12, NearIntensity = 0})
        makeEffect("SunRaysEffect", Lighting, {Intensity = 0.3, Spread = 0.9})
        makeEffect("BloomEffect", Lighting, {Intensity = 0.35, Size = 30})
        makeEffect("Clouds", Terrain, {Cover = 0.5, Density = 0.6, Color = Color3.fromRGB(255, 255, 255)})
	end,
	
    ["Golden Sunset"] = function()
		Lighting.GlobalShadows = true; Lighting.ClockTime = 17.6; Lighting.Brightness = 3.5
		Lighting.Ambient = Color3.fromRGB(150, 100, 50); Lighting.OutdoorAmbient = Color3.fromRGB(140, 90, 40)
        makeEffect("ColorCorrectionEffect", Lighting, {Contrast = 0.2, Saturation = 0.2, TintColor = Color3.fromRGB(255, 220, 180)})
        makeEffect("DepthOfFieldEffect", Lighting, {FocusDistance = 25, InFocusRadius = 45, FarIntensity = 0.15, NearIntensity = 0})
        makeEffect("SunRaysEffect", Lighting, {Intensity = 0.2, Spread = 0.75})
        makeEffect("BloomEffect", Lighting, {Intensity = 0.3})
        makeEffect("Clouds", Terrain, {Cover = 0.75, Density = 0.85, Color = Color3.fromRGB(255, 150, 40)})
	end,

	["Mystical Dusk"] = function()
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

    ["Cloudy"] = function()
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

	["Cinematic Pastel"] = function()
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
Container.Name                   = "MainContainer"
Container.Size                   = UDim2.new(0, defaultW, 0, defaultH)
Container.Position               = UDim2.new(0, centerX, 0, centerY)
Container.BackgroundTransparency = 1
Container.Parent                 = Gui

local DropShadow = Instance.new("ImageLabel")
DropShadow.Name                   = "PerfectShadow"
DropShadow.Size                   = UDim2.new(1, 40, 1, 40)
DropShadow.Position               = UDim2.new(0.5, 0, 0.5, 0)
DropShadow.AnchorPoint            = Vector2.new(0.5, 0.5)
DropShadow.BackgroundTransparency = 1
DropShadow.Image                  = "rbxassetid://5554236805"
DropShadow.ImageColor3            = Color3.new(0,0,0)
DropShadow.ImageTransparency      = 1 
DropShadow.ScaleType              = Enum.ScaleType.Slice
DropShadow.SliceCenter            = Rect.new(23, 23, 277, 277)
DropShadow.ZIndex                 = 0
DropShadow.Parent                 = Container

local Win = Instance.new("Frame")
Win.Size                   = UDim2.new(1, 0, 1, 0)
Win.Position               = UDim2.new(0.5, 0, 0.5, 0)
Win.AnchorPoint            = Vector2.new(0.5, 0.5)
Win.BackgroundColor3       = Color3.fromRGB(25, 25, 30)
Win.BackgroundTransparency = 1 
Win.ClipsDescendants       = true
Win.Active                 = true
Win.ZIndex                 = 1
Win.Parent                 = Container
Instance.new("UICorner", Win).CornerRadius = UDim.new(0, CORNER_RADIUS)

local GlassStroke = Instance.new("UIStroke", Win)
GlassStroke.Color        = Color3.new(1,1,1)
GlassStroke.Transparency = 1 
GlassStroke.Thickness    = 1.2

local TopBar = Instance.new("Frame")
TopBar.Size                   = UDim2.new(1, 0, 0, MIN_H)
TopBar.BackgroundTransparency = 1
TopBar.ZIndex                 = 2
TopBar.Parent                 = Win

local Title = Instance.new("TextLabel")
Title.Text                   = "Flow • Shaders"
Title.FontFace               = TitleFont 
Title.TextSize               = 13
Title.TextColor3             = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Size                   = UDim2.new(1, -80, 1, 0)
Title.Position               = UDim2.new(0, 15, 0, 0)
Title.TextXAlignment         = Enum.TextXAlignment.Left
Title.TextTransparency       = 1
Title.ZIndex                 = 3
Title.Parent                 = TopBar

local function CreateBtn(icon, posOffset)
    local Btn = Instance.new("TextButton")
    Btn.Size                   = UDim2.new(0, 24, 0, 24)
    Btn.Position               = UDim2.new(1, posOffset, 0.5, -12)
    Btn.BackgroundColor3       = Color3.new(1,1,1)
    Btn.BackgroundTransparency = 1
    Btn.Text                   = icon
    Btn.Font                   = Enum.Font.Gotham
    Btn.TextSize               = 16
    Btn.TextColor3             = Color3.new(1,1,1)
    Btn.TextTransparency       = 1
    Btn.ZIndex                 = 4
    Btn.Parent                 = TopBar
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
    return Btn
end

local MinBtn   = CreateBtn("−", -65)
local CloseBtn = CreateBtn("×", -35)

-- BOTÓN RESIZE CON ADHESIVO (Pequeño y ajustado)
local ResizeBtn = Instance.new("TextButton")
ResizeBtn.Name                   = "ResizeBtn"
ResizeBtn.Size                   = UDim2.new(0, 18, 0, 18)
ResizeBtn.Position               = UDim2.new(1, 2, 1, 2)
ResizeBtn.BackgroundTransparency = 1
ResizeBtn.Text                   = ""
ResizeBtn.ZIndex                 = 50
ResizeBtn.Parent                 = Container

local ResizeIcon = Instance.new("ImageLabel")
ResizeIcon.Size                   = UDim2.new(1, 0, 1, 0)
ResizeIcon.BackgroundTransparency = 1
ResizeIcon.Image                  = "rbxthumb://type=Asset&id=131384103443240&w=150&h=150"
ResizeIcon.ImageColor3            = Color3.new(1,1,1)
ResizeIcon.ScaleType              = Enum.ScaleType.Fit
ResizeIcon.ImageTransparency      = 1 
ResizeIcon.ZIndex                 = 51
ResizeIcon.Parent                 = ResizeBtn

-- LISTA Y FILAS DE SHADERS
local Content = Instance.new("ScrollingFrame", Win)
Content.Size                   = UDim2.new(1, -20, 1, -(MIN_H + 10))
Content.Position               = UDim2.new(0, 10, 0, MIN_H + 5)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness     = 0
Content.BorderSizePixel        = 0
Content.ZIndex                 = 3
Content.AutomaticCanvasSize    = Enum.AutomaticSize.Y
Content.CanvasSize             = UDim2.new(0, 0, 0, 0)
local ListLayout = Instance.new("UIListLayout", Content)
ListLayout.Padding = UDim.new(0, 6)

local activeToggle = nil
local ShaderOrder = {
    "Realistic", "Nearby Sun", "Golden Sunset",
    "Mystical Dusk", "Fog", "Cloudy",
    "Frozen Winter", "Cinematic Pastel"
}

for i, shaderName in ipairs(ShaderOrder) do
    local Btn = Instance.new("TextButton", Content)
    Btn.Name                   = "ShaderRow_" .. i
    Btn.Size                   = UDim2.new(1, 0, 0, 34)
    Btn.BackgroundColor3       = Color3.new(1,1,1)
    Btn.BackgroundTransparency = 0.94
    Btn.Text                   = "  " .. shaderName
    Btn.Font                   = Enum.Font.GothamMedium
    Btn.TextSize               = 12
    Btn.TextColor3             = Color3.fromRGB(240,240,245)
    Btn.TextXAlignment         = Enum.TextXAlignment.Left
    Btn.ZIndex                 = 4
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)
    
    local ToggleBg = Instance.new("Frame", Btn)
    ToggleBg.Name                   = "ToggleBg"
    ToggleBg.Size                   = UDim2.new(0, 34, 0, 18)
    ToggleBg.Position               = UDim2.new(1, -45, 0.5, -9)
    ToggleBg.BackgroundColor3       = Color3.fromRGB(90, 90, 95)
    ToggleBg.ZIndex                 = 5
    Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(1, 0)
    
    local Circle = Instance.new("Frame", ToggleBg)
    Circle.Name                   = "ToggleCircle"
    Circle.Size                   = UDim2.new(0, 14, 0, 14)
    Circle.Position               = UDim2.new(0, 2, 0.5, -7)
    Circle.BackgroundColor3       = Color3.new(1,1,1)
    Circle.ZIndex                 = 6
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
    
    local tData = {Btn = Btn, Bg = ToggleBg, Circle = Circle, Name = shaderName}
    
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
end

-- ARRASTRE Y REDIMENSIÓN CON LÍMITES DINÁMICOS
local dragging, resizing = false, false
local dragStart, startPos, startSize = nil, nil, nil

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true; dragStart = input.Position; startPos = Container.Position
	end
end)
ResizeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
		resizing = true; dragStart = input.Position; startSize = Container.Size
	end
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
            
            -- Calculamos el ancho dentro del mínimo y máximo permitido
            local newW = math.clamp(startSize.X.Offset + delta.X, MIN_W, MAX_W)
            
            -- Calculamos dinámicamente el alto máximo basándonos en los botones creados
            local contentHeight = ListLayout.AbsoluteContentSize.Y
            local dynamicMaxH = MIN_H + 15 + contentHeight -- TopBar(35) + Margen(15) + Total altura de contenido
            
            -- Limitamos el alto de la ventana al alto dinámico
            local newH = math.clamp(startSize.Y.Offset + delta.Y, MIN_WIN_H, dynamicMaxH)
            
            Container.Size = UDim2.new(0, newW, 0, newH)
        end
    end
end)

-- HOVERS
CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(255, 80, 80), BackgroundTransparency = 0.5}, 0.15) end)
CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.85}, 0.15) end)
MinBtn.MouseEnter:Connect(function() Tween(MinBtn, {BackgroundColor3 = Color3.fromRGB(255, 210, 80), BackgroundTransparency = 0.5}, 0.15) end)
MinBtn.MouseLeave:Connect(function() Tween(MinBtn, {BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.85}, 0.15) end)

-- MINIMIZAR Y CERRAR
local isClosing, isMinimized = false, false
local savedSize = Vector2.new(defaultW, defaultH)

MinBtn.MouseButton1Click:Connect(function()
    if isClosing then return end; isMinimized = not isMinimized
    if isMinimized then
        MinBtn.Text, ResizeBtn.Visible = "+", false
		savedSize = Vector2.new(Container.AbsoluteSize.X, Container.AbsoluteSize.Y)
        Tween(Container, {Size = UDim2.new(0, savedSize.X, 0, MIN_H)}, 0.18)
        
        for _, c in pairs(Content:GetDescendants()) do
            if c:IsA("TextButton") then
                Tween(c, {BackgroundTransparency = 1, TextTransparency = 1}, 0.18)
            elseif c:IsA("Frame") then
                Tween(c, {BackgroundTransparency = 1}, 0.18)
            end
        end
    else
        MinBtn.Text, ResizeBtn.Visible = "−", true
        Tween(Container, {Size = UDim2.new(0, savedSize.X, 0, savedSize.Y)}, 0.18)
        
        for _, c in pairs(Content:GetDescendants()) do
            if c:IsA("TextButton") and c.Name:match("ShaderRow") then
                Tween(c, {BackgroundTransparency = 0.94, TextTransparency = 0}, 0.18)
            elseif c.Name == "ToggleBg" or c.Name == "ToggleCircle" then
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

-- ANIMACIÓN DE ENTRADA
Container.Size = UDim2.new(0, defaultW * 0.95, 0, defaultH * 0.95)
Container.Position = UDim2.new(0, centerX + defaultW * 0.025, 0, centerY + defaultH * 0.025)

task.wait(0.05)

Tween(Container,   {Size = UDim2.new(0, defaultW, 0, defaultH), Position = UDim2.new(0, centerX, 0, centerY)}, ANIM_DURATION)
Tween(Win,         {BackgroundTransparency = 0.15}, ANIM_DURATION)
Tween(GlassStroke, {Transparency = 0.85}, ANIM_DURATION)
Tween(DropShadow,  {ImageTransparency = 0.30}, ANIM_DURATION)
Tween(Title,       {TextTransparency = 0}, ANIM_DURATION)
Tween(ResizeIcon,  {ImageTransparency = 0}, ANIM_DURATION)
Tween(MinBtn,      {BackgroundTransparency = 0.85, TextTransparency = 0}, ANIM_DURATION)
Tween(CloseBtn,    {BackgroundTransparency = 0.85, TextTransparency = 0}, ANIM_DURATION)
