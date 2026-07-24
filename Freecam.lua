local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local freecamEnabled = false
local freecamConn = nil
local freecamSavedCFrame = nil
local isMobileDevice = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local FONT = Enum.Font.BuilderSansBold

StartFreecam = function()
    if _G.FlowFreecamEnabled then return end
    _G.FlowFreecamEnabled = true
    local cam = workspace.CurrentCamera
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = true end
    freecamSavedCFrame = cam.CFrame
    cam.CameraType = Enum.CameraType.Scriptable
    local targetPos = cam.CFrame.Position
    local look = cam.CFrame.LookVector
    local yaw = math.atan2(-look.X, -look.Z)
    local pitch = math.asin(math.clamp(look.Y, -1, 1))
    local rot = Vector2.new(pitch, yaw)
    local currentPos = targetPos
    local touchConnections = {}
    local touchRotActive = false
    local touchRotLastPos = nil
    local touchMoveActive = false
    local touchMoveId = nil
    local touchRotId = nil
    local touchMovePos = Vector2.new(0, 0)
    local freecamGui = nil
    local joystickBg, joystickKnob, joystickCenter
    local rotZone = nil

    if isMobileDevice then
        freecamGui = Instance.new("ScreenGui", CoreGui)
        freecamGui.Name = "FreecamMobileUI"
        freecamGui.IgnoreGuiInset = true
        freecamGui.DisplayOrder = 9998
        freecamGui.ResetOnSpawn = false
        local instrLabel = Instance.new("TextLabel", freecamGui)
        instrLabel.Size = UDim2.new(1, 0, 0, 30)
        instrLabel.Position = UDim2.new(0, 0, 0, 50)
        instrLabel.BackgroundTransparency = 1
        instrLabel.Text = "Joystick: Mover  |  Derecha: Rotar camara"
        instrLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        instrLabel.Font = FONT
        instrLabel.TextSize = 13
        instrLabel.TextStrokeTransparency = 0
        instrLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        local btnUp = Instance.new("TextButton", freecamGui)
        btnUp.Size = UDim2.new(0, 60, 0, 60)
        btnUp.Position = UDim2.new(0, 150, 1, -180)
        btnUp.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        btnUp.BackgroundTransparency = 0.3
        btnUp.Text = "Subir"
        btnUp.Font = FONT
        btnUp.TextSize = 12
        btnUp.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnUp.AutoButtonColor = false
        Instance.new("UICorner", btnUp).CornerRadius = UDim.new(0, 8)
        local btnDown = Instance.new("TextButton", freecamGui)
        btnDown.Size = UDim2.new(0, 60, 0, 60)
        btnDown.Position = UDim2.new(0, 150, 1, -110)
        btnDown.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        btnDown.BackgroundTransparency = 0.3
        btnDown.Text = "Bajar"
        btnDown.Font = FONT
        btnDown.TextSize = 12
        btnDown.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnDown.AutoButtonColor = false
        Instance.new("UICorner", btnDown).CornerRadius = UDim.new(0, 8)
        local btnExit = Instance.new("TextButton", freecamGui)
        btnExit.Size = UDim2.new(0, 90, 0, 40)
        btnExit.Position = UDim2.new(0.5, -45, 0, 85)
        btnExit.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        btnExit.BackgroundTransparency = 0.2
        btnExit.Text = "Salir Freecam"
        btnExit.Font = FONT
        btnExit.TextSize = 11
        btnExit.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnExit.AutoButtonColor = false
        Instance.new("UICorner", btnExit).CornerRadius = UDim.new(0, 8)
        btnExit.MouseButton1Click:Connect(function() _G.FlowStopFreecam() end)
        joystickBg = Instance.new("Frame", freecamGui)
        joystickBg.Size = UDim2.new(0, 120, 0, 120)
        joystickBg.Position = UDim2.new(0, 20, 1, -160)
        joystickBg.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        joystickBg.BackgroundTransparency = 0.4
        joystickBg.BorderSizePixel = 0
        Instance.new("UICorner", joystickBg).CornerRadius = UDim.new(1, 0)
        joystickKnob = Instance.new("Frame", joystickBg)
        joystickKnob.Size = UDim2.new(0, 50, 0, 50)
        joystickKnob.Position = UDim2.new(0.5, -25, 0.5, -25)
        joystickKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
        joystickKnob.BackgroundTransparency = 0.2
        joystickKnob.BorderSizePixel = 0
        Instance.new("UICorner", joystickKnob).CornerRadius = UDim.new(1, 0)
        joystickCenter = joystickBg.AbsolutePosition + joystickBg.AbsoluteSize / 2
        rotZone = Instance.new("TextButton", freecamGui)
        rotZone.Size = UDim2.new(0.5, -10, 1, -120)
        rotZone.Position = UDim2.new(0.5, 5, 0, 120)
        rotZone.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
        rotZone.BackgroundTransparency = 0.92
        rotZone.Text = "Desliza aqui para rotar"
        rotZone.Font = FONT
        rotZone.TextSize = 12
        rotZone.TextColor3 = Color3.fromRGB(180, 180, 255)
        rotZone.TextTransparency = 0.4
        rotZone.AutoButtonColor = false
        Instance.new("UICorner", rotZone).CornerRadius = UDim.new(0, 12)
        local btnBoost = Instance.new("TextButton", freecamGui)
        btnBoost.Size = UDim2.new(0, 80, 0, 40)
        btnBoost.Position = UDim2.new(0, 20, 1, -185)
        btnBoost.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        btnBoost.BackgroundTransparency = 0.3
        btnBoost.Text = "Boost"
        btnBoost.Font = FONT
        btnBoost.TextSize = 12
        btnBoost.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnBoost.AutoButtonColor = false
        Instance.new("UICorner", btnBoost).CornerRadius = UDim.new(0, 8)
        local isBoosting = false; local isGoingUp = false; local isGoingDown = false
        local joystickDelta = Vector2.new(0, 0)
        table.insert(touchConnections, btnBoost.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch then isBoosting = true end end))
        table.insert(touchConnections, btnBoost.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch then isBoosting = false end end))
        table.insert(touchConnections, btnUp.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch then isGoingUp = true end end))
        table.insert(touchConnections, btnUp.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch then isGoingUp = false end end))
        table.insert(touchConnections, btnDown.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch then isGoingDown = true end end))
        table.insert(touchConnections, btnDown.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch then isGoingDown = false end end))
        table.insert(touchConnections, UserInputService.TouchStarted:Connect(function(touch, gp)
            if not _G.FlowFreecamEnabled then return end
            local pos = touch.Position
            local bgPos = joystickBg.AbsolutePosition; local bgSize = joystickBg.AbsoluteSize
            joystickCenter = bgPos + bgSize / 2
            local distToJoy = (Vector2.new(pos.X, pos.Y) - joystickCenter).Magnitude
            if distToJoy < bgSize.X / 2 + 20 then touchMoveActive = true; touchMoveId = touch; return end
            if rotZone then
                local rp = rotZone.AbsolutePosition; local rs = rotZone.AbsoluteSize
                if pos.X >= rp.X and pos.X <= rp.X + rs.X and pos.Y >= rp.Y and pos.Y <= rp.Y + rs.Y then
                    touchRotActive = true; touchRotId = touch; touchRotLastPos = Vector2.new(pos.X, pos.Y)
                end
            end
        end))
        table.insert(touchConnections, UserInputService.TouchMoved:Connect(function(touch, gp)
            if not _G.FlowFreecamEnabled then return end
            local pos = touch.Position
            if touchMoveActive and touch == touchMoveId then
                joystickCenter = joystickBg.AbsolutePosition + joystickBg.AbsoluteSize / 2
                local delta = Vector2.new(pos.X, pos.Y) - joystickCenter
                local maxRadius = joystickBg.AbsoluteSize.X / 2 - 10
                if delta.Magnitude > maxRadius then delta = delta.Unit * maxRadius end
                joystickKnob.Position = UDim2.new(0.5, delta.X - 25, 0.5, delta.Y - 25)
                joystickDelta = Vector2.new(delta.X / maxRadius, -delta.Y / maxRadius)
                touchMovePos = joystickDelta
            end
            if touchRotActive and touch == touchRotId and touchRotLastPos then
                local curPos = Vector2.new(pos.X, pos.Y)
                local delta = curPos - touchRotLastPos
                rot = rot + Vector2.new(-delta.Y * 0.006, -delta.X * 0.006)
                rot = Vector2.new(math.clamp(rot.X, -math.rad(80), math.rad(80)), rot.Y)
                touchRotLastPos = curPos
            end
        end))
        table.insert(touchConnections, UserInputService.TouchEnded:Connect(function(touch, gp)
            if not _G.FlowFreecamEnabled then return end
            if touch == touchMoveId then
                touchMoveActive = false; touchMoveId = nil
                touchMovePos = Vector2.new(0, 0); joystickDelta = Vector2.new(0, 0)
                joystickKnob.Position = UDim2.new(0.5, -25, 0.5, -25)
            end
            if touch == touchRotId then touchRotActive = false; touchRotId = nil; touchRotLastPos = nil end
        end))
        freecamConn = RunService.RenderStepped:Connect(function(dt)
            local moveVec = Vector3.zero
            local speed = isBoosting and 150 or 50
            if touchMovePos.Magnitude > 0.05 then moveVec = moveVec + Vector3.new(touchMovePos.X, 0, -touchMovePos.Y) end
            if isGoingUp then moveVec = moveVec + Vector3.new(0, 1, 0) end
            if isGoingDown then moveVec = moveVec + Vector3.new(0, -1, 0) end
            local rotCFrame = CFrame.fromOrientation(rot.X, rot.Y, 0)
            if moveVec.Magnitude > 0 then
                local horizontal = Vector3.new(moveVec.X, 0, moveVec.Z)
                local rotated = (rotCFrame * CFrame.new(horizontal)).Position
                moveVec = Vector3.new(rotated.X, moveVec.Y, rotated.Z)
            end
            targetPos = targetPos + moveVec * speed * dt
            local lerpAlpha = 1 - math.exp(-15 * dt)
            currentPos = currentPos:Lerp(targetPos, lerpAlpha)
            cam.CFrame = CFrame.new(currentPos) * rotCFrame
            cam.Focus = CFrame.new(currentPos)
        end)
    else
        freecamConn = RunService.RenderStepped:Connect(function(dt)
            local moveVec = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + Vector3.new(0,0,-1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec + Vector3.new(0,0,1) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec + Vector3.new(-1,0,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + Vector3.new(1,0,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveVec = moveVec + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveVec = moveVec + Vector3.new(0,-1,0) end
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
                local delta = UserInputService:GetMouseDelta()
                rot = rot + Vector2.new(-delta.Y * 0.005, -delta.X * 0.005)
                rot = Vector2.new(math.clamp(rot.X, -math.rad(80), math.rad(80)), rot.Y)
            else
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            end
            local rotCFrame = CFrame.fromOrientation(rot.X, rot.Y, 0)
            moveVec = (rotCFrame * CFrame.new(moveVec)).Position
            local speed = 50
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then speed = 150 end
            targetPos = targetPos + moveVec * speed * dt
            local lerpAlpha = 1 - math.exp(-15 * dt)
            currentPos = currentPos:Lerp(targetPos, lerpAlpha)
            cam.CFrame = CFrame.new(currentPos) * rotCFrame
            cam.Focus = CFrame.new(currentPos)
        end)
    end
    _G.FreecamTouchConnections = touchConnections
    _G.FreecamMobileGui = freecamGui
end

_G.FlowStopFreecam = function()
    if not _G.FlowFreecamEnabled then return end
    _G.FlowFreecamEnabled = false
    if freecamConn then freecamConn:Disconnect(); freecamConn = nil end
    if _G.FreecamTouchConnections then
        for _, conn in ipairs(_G.FreecamTouchConnections) do pcall(function() conn:Disconnect() end) end
        _G.FreecamTouchConnections = nil
    end
    if _G.FreecamMobileGui then pcall(function() _G.FreecamMobileGui:Destroy() end); _G.FreecamMobileGui = nil end
    local cam = workspace.CurrentCamera
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    if freecamSavedCFrame then
        local tween = game:GetService("TweenService"):Create(cam, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {CFrame = freecamSavedCFrame})
        tween:Play()
        tween.Completed:Connect(function(state)
            if state == Enum.PlaybackState.Completed and not _G.FlowFreecamEnabled then
                cam.CameraType = Enum.CameraType.Custom
                if hrp then hrp.Anchored = false end
            end
        end)
    else
        cam.CameraType = Enum.CameraType.Custom
        if hrp then hrp.Anchored = false end
    end
end

StartFreecam()
