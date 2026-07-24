local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local isRejoining = false

local function RejoinCinematic()
    if isRejoining then return end
    isRejoining = true
    local char = LocalPlayer.Character
    if not char then isRejoining = false; return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then isRejoining = false; return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then isRejoining = false; return end

    local savedSpeed = hum.WalkSpeed
    local savedJump = hum.JumpPower
    hum.WalkSpeed = 0
    hum.JumpPower = 0

    local cam = workspace.CurrentCamera
    cam.CameraType = Enum.CameraType.Scriptable
    local blurEffect = Instance.new("BlurEffect", game:GetService("Lighting"))
    blurEffect.Size = 0
    local flashGui = Instance.new("ScreenGui", CoreGui)
    flashGui.IgnoreGuiInset = true
    flashGui.DisplayOrder = 9999
    local flashFrame = Instance.new("Frame", flashGui)
    flashFrame.Size = UDim2.new(1, 0, 1, 0)
    flashFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    flashFrame.BackgroundTransparency = 1

    local function PlayFlashAndMoveUp(startHeight, endHeight, blurTarget)
        flashFrame.BackgroundTransparency = 0
        TweenService:Create(flashFrame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
        TweenService:Create(blurEffect, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {Size = blurTarget}):Play()
        cam.CFrame = CFrame.lookAt(hrp.Position + Vector3.new(0, startHeight, 0), hrp.Position)
        local targetCF = CFrame.lookAt(hrp.Position + Vector3.new(0, endHeight, 0), hrp.Position)
        TweenService:Create(cam, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = targetCF}):Play()
        task.wait(0.8)
    end

    local overheadCF = CFrame.lookAt(hrp.Position + Vector3.new(0, 8, 0), hrp.Position)
    TweenService:Create(cam, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = overheadCF}):Play()
    task.wait(0.6)

    pcall(function()
        local rjAudio = Instance.new("Sound")
        rjAudio.SoundId = "rbxassetid://129837121481687"
        rjAudio.Volume = 1.5
        rjAudio.Parent = workspace
        rjAudio:Play()
    end)

    PlayFlashAndMoveUp(8, 25, 10)
    PlayFlashAndMoveUp(25, 80, 20)
    PlayFlashAndMoveUp(80, 200, 30)

    local currentPos = hrp.Position
  
    if _G.FlowUI_SaveCfg and _G.FlowUI_Cfg then
        _G.FlowUI_Cfg.SavedPosition = {X = currentPos.X, Y = currentPos.Y, Z = currentPos.Z}
        _G.FlowUI_Cfg.PendingTeleport = true
        _G.FlowUI_SaveCfg()
    end

    task.wait(0.5)
    local tpSuccess = pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
    if not tpSuccess then
        hum.WalkSpeed = savedSpeed
        hum.JumpPower = savedJump
        cam.CameraType = Enum.CameraType.Custom
        if blurEffect then blurEffect:Destroy() end
        if flashGui then flashGui:Destroy() end
        isRejoining = false
    end
end

RejoinCinematic()
