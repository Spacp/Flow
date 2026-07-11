if _G.FlowSpeedLoaded then return end
_G.FlowSpeedLoaded = true

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera
local targetGui   = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

if targetGui:FindFirstChild("FlowUI_Speed") then targetGui.FlowUI_Speed:Destroy() end

local defaultW, defaultH   = 260, 130
local MIN_H                = 35
local ANIM_DURATION        = 0.25
local CORNER_RADIUS        = 8
local MIN_W, MAX_W         = 260, 500
local MIN_WIN_H            = 130

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

-- SISTEMA DE VELOCIDAD
local currentSpeed = 16
local MIN_SPEED, MAX_SPEED = 16, 500

local function applyWalkSpeed()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = currentSpeed
    end
end

local function resetWalkSpeed()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = MIN_SPEED
    end
end

local charConnection
charConnection = LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.1)
    applyWalkSpeed()
end)

-- INTERFAZ PRINCIPAL
local Gui = Instance.new("ScreenGui")
Gui.Name, Gui.ResetOnSpawn, Gui.ZIndexBehavior, Gui.IgnoreGuiInset = "FlowUI_Speed", false, Enum.ZIndexBehavior.Global, true
Gui.Parent = targetGui

local Container = Instance.new("Frame")
Container.Name, Container.Size, Container.Position, Container.BackgroundTransparency = "MainContainer", UDim2.new(0, defaultW, 0, defaultH), UDim2.new(0, centerX, 0, centerY), 1
Container.Parent = Gui

local DropShadow = Instance.new("ImageLabel")
DropShadow.Name, DropShadow.Size, DropShadow.Position, DropShadow.AnchorPoint = "PerfectShadow", UDim2.new(1, 40, 1, 40), UDim2.new(0.5, 0, 0.5, 0), Vector2.new(0.5, 0.5)
DropShadow.BackgroundTransparency, DropShadow.Image, DropShadow.ImageColor3, DropShadow.ImageTransparency = 1, "rbxassetid://5554236805", Color3.new(0,0,0), 1
DropShadow.ScaleType, DropShadow.SliceCenter, DropShadow.ZIndex, DropShadow.Parent = Enum.ScaleType.Slice, Rect.new(23, 23, 277, 277), 0, Container

local Win = Instance.new("Frame")
Win.Size, Win.Position, Win.AnchorPoint = UDim2.new(1, 0, 1, 0), UDim2.new(0.5, 0, 0.5, 0), Vector2.new(0.5, 0.5)
Win.BackgroundColor3, Win.BackgroundTransparency, Win.ClipsDescendants, Win.ZIndex, Win.Parent = Color3.fromRGB(25, 25, 30), 1, true, 1, Container
Instance.new("UICorner", Win).CornerRadius = UDim.new(0, CORNER_RADIUS)

local GlassStroke = Instance.new("UIStroke", Win)
GlassStroke.Color, GlassStroke.Transparency, GlassStroke.Thickness = Color3.new(1,1,1), 1, 1.2

local TopBar = Instance.new("Frame")
TopBar.Size, TopBar.BackgroundTransparency, TopBar.ZIndex, TopBar.Parent = UDim2.new(1, 0, 0, MIN_H), 1, 2, Win

local Title = Instance.new("TextLabel")
Title.Text, Title.FontFace, Title.TextSize, Title.TextColor3, Title.BackgroundTransparency = "Flow • Speed", TitleFont, 13, Color3.new(1,1,1), 1
Title.Size, Title.Position, Title.TextXAlignment, Title.TextTransparency, Title.ZIndex, Title.Parent = UDim2.new(1, -80, 1, 0), UDim2.new(0, 15, 0, 0), Enum.TextXAlignment.Left, 1, 3, TopBar

local function CreateBtn(icon, posOffset)
    local Btn = Instance.new("TextButton")
    Btn.Size, Btn.Position, Btn.BackgroundColor3, Btn.BackgroundTransparency = UDim2.new(0, 24, 0, 24), UDim2.new(1, posOffset, 0.5, -12), Color3.new(1,1,1), 1
    Btn.Text, Btn.Font, Btn.TextSize, Btn.TextColor3, Btn.TextTransparency, Btn.ZIndex, Btn.Parent = icon, Enum.Font.Gotham, 16, Color3.new(1,1,1), 1, 4, TopBar
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
    return Btn
end
local MinBtn, CloseBtn = CreateBtn("−", -65), CreateBtn("×", -35)

local ResizeBtn = Instance.new("TextButton")
ResizeBtn.Name, ResizeBtn.Size, ResizeBtn.Position, ResizeBtn.BackgroundTransparency, ResizeBtn.Text, ResizeBtn.ZIndex, ResizeBtn.Parent = "ResizeBtn", UDim2.new(0, 18, 0, 18), UDim2.new(1, 2, 1, 2), 1, "", 50, Container
local ResizeIcon = Instance.new("ImageLabel")
ResizeIcon.Size, ResizeIcon.BackgroundTransparency, ResizeIcon.Image, ResizeIcon.ImageColor3, ResizeIcon.ScaleType, ResizeIcon.ImageTransparency, ResizeIcon.ZIndex, ResizeIcon.Parent = UDim2.new(1, 0, 1, 0), 1, "rbxthumb://type=Asset&id=131384103443240&w=150&h=150", Color3.new(1,1,1), Enum.ScaleType.Fit, 1, 51, ResizeBtn

-- CONTENIDO INTERNO
local SpeedContent = Instance.new("Frame", Win)
SpeedContent.Size = UDim2.new(1, -20, 1, -(MIN_H + 15))
SpeedContent.Position = UDim2.new(0, 10, 0, MIN_H + 10)
SpeedContent.BackgroundTransparency, SpeedContent.ZIndex, SpeedContent.ClipsDescendants = 1, 3, true

-- SLIDER
local function createSlider(parent, posY, minVal, maxVal, defaultVal, onChange)
    local currentValue = defaultVal
    local isSliding = false

    local Track = Instance.new("TextButton", parent)
    Track.Size = UDim2.new(1, -12, 0, 6)
    Track.Position = UDim2.new(0, 6, 0, posY)
    Track.AutoButtonColor = false
    Track.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
    Track.Text = ""
    Track.ZIndex = 5
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 6
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("TextButton", Track)
    Knob.Size = UDim2.new(0, 12, 0, 12)
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.Text = ""
    Knob.AutoButtonColor = false
    Knob.ZIndex = 7
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local function slide(input)
        local p = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        currentValue = math.clamp(math.round(minVal + (p * (maxVal - minVal))), minVal, maxVal)
        Fill.Size = UDim2.new(p, 0, 1, 0)
        Knob.Position = UDim2.new(p, 0, 0.5, 0)
        onChange(currentValue, false)
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true; slide(input)
        end
    end)

    Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            slide(input)
        end
    end)

    local function updateVisual(value, animate)
        local p = (value - minVal) / (maxVal - minVal)
        if animate then
            Tween(Fill, {Size = UDim2.new(p, 0, 1, 0)}, 0.3)
            Tween(Knob, {Position = UDim2.new(p, 0, 0.5, 0)}, 0.3)
        else
            Fill.Size = UDim2.new(p, 0, 1, 0)
            Knob.Position = UDim2.new(p, 0, 0.5, 0)
        end
    end

    updateVisual(defaultVal, false)
    return {
        updateVisual = updateVisual,
        getCurrent   = function() return currentValue end,
        set          = function(v) currentValue = v end
    }
end

-- TEXTBOX VELOCIDAD
local SpeedBox = Instance.new("TextBox", SpeedContent)
SpeedBox.Size = UDim2.new(1, 0, 0, 28)
SpeedBox.BackgroundColor3, SpeedBox.BackgroundTransparency = Color3.new(1,1,1), 0.94
SpeedBox.Text, SpeedBox.Font, SpeedBox.TextSize, SpeedBox.TextColor3 = tostring(currentSpeed), Enum.Font.GothamMedium, 14, Color3.fromRGB(240,240,245)
SpeedBox.PlaceholderText, SpeedBox.PlaceholderColor3, SpeedBox.ClearTextOnFocus, SpeedBox.ZIndex = "Velocidad al caminar...", Color3.fromRGB(100, 100, 105), false, 4
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 5)

-- SLIDER VELOCIDAD
local WalkSlider = createSlider(SpeedContent, 35, MIN_SPEED, MAX_SPEED, currentSpeed, function(val, animate)
    currentSpeed = val
    SpeedBox.Text = tostring(currentSpeed)
    applyWalkSpeed()
    WalkSlider.updateVisual(val, animate)
end)

-- BOTÓN RESTABLECER
local BtnReset = Instance.new("TextButton", SpeedContent)
BtnReset.Size, BtnReset.Position = UDim2.new(0.7, 0, 0, 24), UDim2.new(0.15, 0, 0, 50)
BtnReset.BackgroundColor3, BtnReset.BackgroundTransparency, BtnReset.Text = Color3.fromRGB(50, 50, 55), 0, "Restablecer"
BtnReset.Font, BtnReset.TextSize, BtnReset.TextColor3, BtnReset.ZIndex = Enum.Font.GothamBold, 11, Color3.new(1, 1, 1), 4
Instance.new("UICorner", BtnReset).CornerRadius = UDim.new(0, 5)

BtnReset.MouseButton1Click:Connect(function()
    currentSpeed = MIN_SPEED
    WalkSlider.set(MIN_SPEED)
    SpeedBox.Text = tostring(MIN_SPEED)
    applyWalkSpeed()
    WalkSlider.updateVisual(MIN_SPEED, true)
end)

SpeedBox.FocusLost:Connect(function()
    local num = tonumber(SpeedBox.Text)
    if num then
        currentSpeed = math.clamp(math.round(num), MIN_SPEED, MAX_SPEED)
        WalkSlider.set(currentSpeed)
        applyWalkSpeed()
        WalkSlider.updateVisual(currentSpeed, true)
    end
    SpeedBox.Text = tostring(currentSpeed)
end)

-- HOVERS BOTONES CONTENIDO
BtnReset.MouseEnter:Connect(function() Tween(BtnReset, {BackgroundColor3 = Color3.fromRGB(65, 65, 70)}, 0.15) end)
BtnReset.MouseLeave:Connect(function() Tween(BtnReset, {BackgroundColor3 = Color3.fromRGB(50, 50, 55)}, 0.15) end)

-- ─────────────────────────────────────────────────────────────────────
-- ARRASTRE Y REDIMENSIÓN (PC + MÓVIL)
-- ─────────────────────────────────────────────────────────────────────
local dragging, resizing = false, false
local dragStart, startPos, startSize = nil, nil, nil

local function isTouchOrMouse(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
end

local function isMovement(input)
    return input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
end

-- Arrastre desde TopBar
TopBar.InputBegan:Connect(function(input)
    if isTouchOrMouse(input) then
        dragging  = true
        dragStart = input.Position
        startPos  = Container.Position
    end
end)

TopBar.InputEnded:Connect(function(input)
    if isTouchOrMouse(input) then
        dragging = false
    end
end)

-- Redimensión desde ResizeBtn
ResizeBtn.InputBegan:Connect(function(input)
    if isTouchOrMouse(input) then
        resizing  = true
        dragStart = input.Position
        startSize = Container.Size
    end
end)

ResizeBtn.InputEnded:Connect(function(input)
    if isTouchOrMouse(input) then
        resizing = false
    end
end)

-- Soltar en cualquier lugar
UserInputService.InputEnded:Connect(function(input)
    if isTouchOrMouse(input) then
        dragging = false
        resizing = false
    end
end)

-- Movimiento (mouse y dedo)
UserInputService.InputChanged:Connect(function(input)
    if not isMovement(input) then return end

    if dragging and dragStart then
        local delta = input.Position - dragStart
        Container.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    elseif resizing and dragStart then
        local delta = input.Position - dragStart
        Container.Size = UDim2.new(
            0, math.clamp(startSize.X.Offset + delta.X, MIN_W, MAX_W),
            0, math.clamp(startSize.Y.Offset + delta.Y, MIN_WIN_H, 500)
        )
    end
end)

-- ─────────────────────────────────────────────────────────────────────
-- HOVERS VENTANA
-- ─────────────────────────────────────────────────────────────────────
CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(255, 80, 80), BackgroundTransparency = 0.5}, 0.15) end)
CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.85}, 0.15) end)
MinBtn.MouseEnter:Connect(function() Tween(MinBtn, {BackgroundColor3 = Color3.fromRGB(255, 210, 80), BackgroundTransparency = 0.5}, 0.15) end)
MinBtn.MouseLeave:Connect(function() Tween(MinBtn, {BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0.85}, 0.15) end)

-- ─────────────────────────────────────────────────────────────────────
-- MINIMIZAR Y CERRAR
-- ─────────────────────────────────────────────────────────────────────
local isClosing, isMinimized = false, false
local savedSize = Vector2.new(defaultW, defaultH)

MinBtn.MouseButton1Click:Connect(function()
    if isClosing then return end
    isMinimized = not isMinimized
    if isMinimized then
        MinBtn.Text = "+"
        ResizeBtn.Visible = false
        savedSize = Vector2.new(Container.AbsoluteSize.X, Container.AbsoluteSize.Y)
        Tween(Container, {Size = UDim2.new(0, savedSize.X, 0, MIN_H)}, 0.18)
        SpeedContent.Visible = false
    else
        MinBtn.Text = "−"
        ResizeBtn.Visible = true
        Tween(Container, {Size = UDim2.new(0, savedSize.X, 0, savedSize.Y)}, 0.18)
        SpeedContent.Visible = true
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    if isClosing then return end
    isClosing = true

    currentSpeed = MIN_SPEED
    resetWalkSpeed()
    if charConnection then
        charConnection:Disconnect()
        charConnection = nil
    end

    Tween(Container, {Size = UDim2.new(0, Container.AbsoluteSize.X * 0.95, 0, Container.AbsoluteSize.Y * 0.95)}, 0.15)
    Tween(GlassStroke, {Transparency = 1}, 0.15)
    for _, c in pairs(Container:GetDescendants()) do
        pcall(function()
            if c:IsA("TextLabel") or c:IsA("TextBox") then
                Tween(c, {TextTransparency = 1}, 0.15)
            elseif c:IsA("TextButton") or c:IsA("Frame") then
                Tween(c, {BackgroundTransparency = 1}, 0.15)
            elseif c:IsA("ImageLabel") then
                Tween(c, {ImageTransparency = 1}, 0.15)
            elseif c:IsA("UIStroke") then
                Tween(c, {Transparency = 1}, 0.15)
            end
        end)
    end
    task.wait(0.15)
    _G.FlowSpeedLoaded = nil
    Gui:Destroy()
end)

-- ─────────────────────────────────────────────────────────────────────
-- ANIMACIÓN DE ENTRADA
-- ─────────────────────────────────────────────────────────────────────
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
