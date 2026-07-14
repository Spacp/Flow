local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local TweenService    = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Lighting        = game:GetService("Lighting")
local CoreGui         = game:GetService("CoreGui")
local HttpService     = game:GetService("HttpService")
local Debris          = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do task.wait(); LocalPlayer = Players.LocalPlayer end
if not game:IsLoaded() then game.Loaded:Wait() end

-- Evitar que el script se duplique en la misma sesión
if getgenv()._FlowRejoinSessionLoaded then return end
getgenv()._FlowRejoinSessionLoaded = true

local PENDING_FILE = "FlowUI_RejoinPending.json"
local SCRIPT_URL   = "raw"

local function SavePending(pos)
    if not writefile then return end
    pcall(function()
        writefile(PENDING_FILE, HttpService:JSONEncode({
            pending = true,
            X = pos.X,
            Y = pos.Y,
            Z = pos.Z,
        }))
    end)
end

local function LoadPending()
    if not (isfile and isfile(PENDING_FILE)) then return nil end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(PENDING_FILE)) end)
    if ok and data and data.pending == true then return data end
    return nil
end

local function ClearPending()
    pcall(function()
        if writefile then writefile(PENDING_FILE, '{"pending":false}') end
        if delfile and isfile and isfile(PENDING_FILE) then delfile(PENDING_FILE) end
    end)
end

-- ============================================================
--  SISTEMA DE AUTOEXECUTE (Para la Fase 2)
-- ============================================================
local AUTOEXEC_CODE = string.format([[
task.spawn(function()
    task.wait(2)
    local ok = pcall(function() loadstring(game:HttpGet("%s"))() end)
    if not ok then task.wait(3); pcall(function() loadstring(game:HttpGet("%s"))() end) end
end)
]], SCRIPT_URL, SCRIPT_URL)

local function GetAutoexecPath()
    local paths = {"autoexec","AutoExec","autoexecute","auto-execute"}
    for _, folder in ipairs(paths) do
        local ok, exists = pcall(isfolder, folder)
        if ok and exists then return folder end
    end
    if makefolder then pcall(makefolder, "autoexec") end
    return "autoexec"
end

local function CreateAutoExecute()
    -- 1. Intenta usar la cola de teletransporte (Synapse/Fluxus/etc)
    local qot = (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    if not qot and getgenv then qot = getgenv().queue_on_teleport end
    if not qot then pcall(function() qot = queue_on_teleport end) end
    if qot then pcall(qot, AUTOEXEC_CODE) end

    -- 2. Crea un archivo físico en la carpeta autoexec (Seguridad máxima)
    local path = GetAutoexecPath()
    if writefile then pcall(writefile, path.."/FlowUI_RejoinAuto.lua", AUTOEXEC_CODE) end
end

local function DeleteAutoExecute()
    -- Borra el archivo físico para que no se ejecute en otros juegos
    local path = GetAutoexecPath()
    pcall(function()
        local file = path.."/FlowUI_RejoinAuto.lua"
        if delfile and isfile and isfile(file) then delfile(file)
        elseif writefile then writefile(file, "-- limpio") end
    end)
end

-- ============================================================
--  HELPERS DE CINEMÁTICA
-- ============================================================
local function PlayRejoinSound()
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://129837121481687"; s.Volume = 1.5; s.Parent = workspace
        s:Play(); Debris:AddItem(s, 5)
    end)
end

local function CreateCinematicRig()
    local cam = workspace.CurrentCamera
    cam.CameraType = Enum.CameraType.Scriptable
    local blur = Instance.new("BlurEffect", Lighting); blur.Size = 0
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.IgnoreGuiInset = true; gui.DisplayOrder = 9999
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(1,0,1,0); frame.BackgroundColor3 = Color3.new(1,1,1); frame.BackgroundTransparency = 1
    return cam, blur, gui, frame
end

local function DestroyCinematicRig(blur, gui)
    if blur and blur.Parent then blur:Destroy() end
    if gui  and gui.Parent  then gui:Destroy()  end
end

local function CinematicFlash(cam, blur, frame, focusPos, fromH, toH, blurSize)
    frame.BackgroundTransparency = 0
    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
    TweenService:Create(blur, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {Size = blurSize}):Play()
    cam.CFrame = CFrame.lookAt(focusPos + Vector3.new(0, fromH, 0), focusPos)
    TweenService:Create(cam, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = CFrame.lookAt(focusPos + Vector3.new(0, toH, 0), focusPos)}):Play()
    task.wait(0.8)
end

-- ============================================================
--  FASE 1: ANIMACIÓN DE SALIDA Y REJOIN
-- ============================================================
local function StartRejoin()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum  = char:WaitForChild("Humanoid", 10)
    local hrp  = char:WaitForChild("HumanoidRootPart", 10)
    if not (hum and hrp) then return end

    -- 1. Guardar posición y poner autoexec
    SavePending(hrp.Position)
    CreateAutoExecute()

    -- 2. Cargar Animación
    local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
    local realID = Config.SelectedEmoteID
    pcall(function()
        for _, obj in pairs(game:GetObjects("rbxassetid://"..Config.SelectedEmoteID)) do
            local a = (obj:IsA("Animation") and obj) or obj:FindFirstChildWhichIsA("Animation", true)
            if a then realID = string.match(a.AnimationId, "%d+") end; obj:Destroy()
        end
    end)

    local anim = Instance.new("Animation"); anim.AnimationId = "rbxassetid://"..tostring(realID)
    local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
    if not (ok and track) then ClearPending(); DeleteAutoExecute(); return end

    local savedSpeed, savedJump = hum.WalkSpeed, hum.JumpPower
    hum.WalkSpeed, hum.JumpPower = 0, 0

    local terrain = workspace.Terrain
    local clouds  = terrain:FindFirstChildOfClass("Clouds")
    local createdClouds = false
    if not clouds then
        clouds = Instance.new("Clouds"); clouds.Cover = 0.65; clouds.Density = 0.75; clouds.Color = Color3.new(1,1,1)
        clouds.Parent = terrain; createdClouds = true
    end

    -- 3. Reproducir Emote
    track.Priority = Enum.AnimationPriority.Action4
    track:Play()
    track:AdjustSpeed(Config.UseSlowMo and Config.AnimSpeed * 0.10 or Config.AnimSpeed)
    task.wait(0.1)

    -- 4. Cinemática de Salida
    local cam, blur, gui, frame = CreateCinematicRig()
    local originalPos = hrp.Position

    TweenService:Create(cam, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        CFrame = CFrame.lookAt(originalPos + Vector3.new(0,8,0), originalPos)
    }):Play()
    task.wait(0.6)

    PlayRejoinSound()
    
    -- Subidas de cámara
    CinematicFlash(cam, blur, frame, originalPos, 8,  20, 8)
    CinematicFlash(cam, blur, frame, originalPos, 20, 45, 15)

    -- TERCER SUBIDÓN: Se mueve hacia un lado mirando a la zona de rejoin
    frame.BackgroundTransparency = 0
    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
    
    local endCamPos = originalPos + Vector3.new(math.random(-120, 120), 200, math.random(-120, 120))
    TweenService:Create(cam, TweenInfo.new(2.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
        CFrame = CFrame.lookAt(endCamPos, originalPos)
    }):Play()
    TweenService:Create(blur, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = 40}):Play()
    task.wait(2.5)

    DestroyCinematicRig(blur, gui)

    -- 5. Rejoin
    local tpOk = pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)

    if not tpOk then
        ClearPending(); DeleteAutoExecute()
        hum.WalkSpeed, hum.JumpPower = savedSpeed, savedJump; cam.CameraType = Enum.CameraType.Custom
        track:Stop()
    end
end

-- ============================================================
--  FASE 2: ANIMACIÓN DE ENTRADA Y TP
-- ============================================================
local function PlayEntryCinematic(char, targetPos)
    local cam, blur, gui, frame = CreateCinematicRig()
    blur.Size = 20
    task.wait(0.6)

    PlayRejoinSound()
    
    -- Bajadas de cámara
    CinematicFlash(cam, blur, frame, targetPos, 70, 45, 15)
    CinematicFlash(cam, blur, frame, targetPos, 45, 20, 8)
    CinematicFlash(cam, blur, frame, targetPos, 20, 8,  0)
    task.wait(0.2)

    -- Ajuste final: Coloca la cámara justo en la espalda del jugador
    pcall(function()
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hrp and hum then
            local idealPos = hrp.Position - (hrp.CFrame.LookVector * 10) + Vector3.new(0, 3, 0)
            cam.CFrame = CFrame.lookAt(idealPos, hrp.Position + Vector3.new(0, 1.5, 0))
            task.wait(0.1)
            cam.CameraType = Enum.CameraType.Custom
            cam.CameraSubject = hum
        end
    end)

    DestroyCinematicRig(blur, gui)
end

local function CheckAndHandleReturn()
    local pending = LoadPending()
    
    if pending then
        -- ESTAMOS EN LA FASE 2 (Acabamos de volver al servidor)
        
        -- 1. BORRAR INMEDIATAMENTE LOS DATOS Y EL AUTOEXEC
        ClearPending()
        DeleteAutoExecute()

        local targetPos = Vector3.new(pending.X, pending.Y, pending.Z)
        local targetCF  = CFrame.new(targetPos)

        task.spawn(function()
            task.wait(0.8) -- Dejar que el mapa cargue un poco

            -- Desactivar spawns para no romper el TP
            local disabledSpawns = {}
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("SpawnLocation") and obj.Enabled then
                    disabledSpawns[obj] = true
                    pcall(function() obj.Enabled = false end)
                end
            end

            local tempSpawn = Instance.new("SpawnLocation")
            tempSpawn.Anchored, tempSpawn.CanCollide = true, false
            tempSpawn.CanTouch, tempSpawn.CanQuery = false, false
            tempSpawn.Transparency, tempSpawn.Size = 1, Vector3.new(6,1,6)
            tempSpawn.Position = targetPos - Vector3.new(0,3,0)
            tempSpawn.Enabled, tempSpawn.Neutral = true, true
            tempSpawn.Duration = 0; tempSpawn.Parent = workspace

            local function cleanupSpawns()
                for sp in pairs(disabledSpawns) do
                    if sp and sp.Parent then pcall(function() sp.Enabled = true end) end
                end
                if tempSpawn and tempSpawn.Parent then tempSpawn:Destroy() end
            end

            local function lockAndCleanup(char)
                local hrp = char:WaitForChild("HumanoidRootPart", 10)
                if not hrp then return end

                -- 2. TELEPORTAR AL PUNTO EXACTO
                pcall(function() hrp.CFrame = targetCF end)
                task.wait(0.1)
                pcall(function() hrp.CFrame = targetCF end)

                -- 3. REPRODUCIR LA 2ª ANIMACIÓN
                if not char:GetAttribute("CinematicDone") then
                    char:SetAttribute("CinematicDone", true)
                    task.spawn(PlayEntryCinematic, char, targetPos)
                end

                -- Fijar al jugador por 5 segundos
                local startTime = tick()
                local conn
                conn = RunService.Heartbeat:Connect(function()
                    if tick() - startTime >= 5 then
                        conn:Disconnect()
                        cleanupSpawns()
                        return
                    end
                    if char.Parent and hrp.Parent then
                        pcall(function()
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            hrp.AssemblyAngularVelocity = Vector3.zero
                            hrp.CFrame = targetCF
                        end)
                    end
                end)
            end

            if LocalPlayer.Character then lockAndCleanup(LocalPlayer.Character) end
            local charConn
            charConn = LocalPlayer.CharacterAdded:Connect(function(c)
                lockAndCleanup(c); charConn:Disconnect()
            end)
        end)
    else
        -- ESTAMOS EN LA FASE 1 (Ejecución normal)
        task.spawn(function()
            task.wait(1)
            StartRejoin()
        end)
    end
end

-- ============================================================
--  INICIAR LÓGICA
-- ============================================================
CheckAndHandleReturn()
