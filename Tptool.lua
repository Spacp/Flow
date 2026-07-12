  
if _G["Flow_TPPlr"] then return end  
_G["Flow_TPPlr"] = true  
  
local Players = game:GetService("Players")  
local TS = game:GetService("TweenService")  
local UIS = game:GetService("UserInputService")  
local RS = game:GetService("RunService")  
local CoreGui = game:GetService("CoreGui")  
local plr = Players.LocalPlayer  
local Camera = workspace.CurrentCamera  
local targetGui = (pcall(function() return CoreGui.Name end) and CoreGui) or plr:WaitForChild("PlayerGui")  
if targetGui:FindFirstChild("Flow_TPPlr") then targetGui["Flow_TPPlr"]:Destroy() end  
  
local W, H = 340, 320  
local DUR = 0.2  
local vs = Camera.ViewportSize  
local cx = (vs.X/2)-(W/2)  
local cy = (vs.Y/2)-(H/2)  
  
local function Tw(obj,props,dur) if not obj then return end  
    local t=TS:Create(obj,TweenInfo.new(dur or DUR,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props) t:Play() return t end  
  
local Gui = Instance.new("ScreenGui")  
Gui.Name="Flow_TPPlr" Gui.ResetOnSpawn=false Gui.ZIndexBehavior=Enum.ZIndexBehavior.Global  
Gui.IgnoreGuiInset=true Gui.Parent=targetGui  
  
local C = Instance.new("Frame",Gui)  
C.Name="Main" C.Size=UDim2.new(0,W,0,H) C.Position=UDim2.new(0,cx,0,cy) C.BackgroundTransparency=1  
  
local Shd=Instance.new("ImageLabel",C)  
Shd.Size=UDim2.new(1,40,1,40) Shd.Position=UDim2.new(0.5,0,0.5,0) Shd.AnchorPoint=Vector2.new(0.5,0.5)  
Shd.BackgroundTransparency=1 Shd.Image="rbxassetid://5554236805" Shd.ImageColor3=Color3.new(0,0,0)  
Shd.ImageTransparency=1 Shd.ScaleType=Enum.ScaleType.Slice Shd.SliceCenter=Rect.new(23,23,277,277) Shd.ZIndex=0  
  
local Win=Instance.new("Frame",C)  
Win.Size=UDim2.new(1,0,1,0) Win.Position=UDim2.new(0.5,0,0.5,0) Win.AnchorPoint=Vector2.new(0.5,0.5)  
Win.BackgroundColor3=Color3.fromRGB(25,25,30) Win.BackgroundTransparency=1 Win.ClipsDescendants=true  
Win.Active=true Win.ZIndex=1  
Instance.new("UICorner",Win).CornerRadius=UDim.new(0,8)  
local GS=Instance.new("UIStroke",Win) GS.Color=Color3.new(1,1,1) GS.Transparency=1 GS.Thickness=1.2  
  
-- TopBar: fixed 35px height so minimize works correctly  
local TB=Instance.new("Frame",Win)  
TB.Size=UDim2.new(1,0,0,35) TB.BackgroundTransparency=1 TB.ZIndex=2  
  
local Ttl=Instance.new("TextLabel",TB)  
Ttl.Text="TP to Player" Ttl.FontFace=Font.new("rbxasset://fonts/families/BuilderSans.json",Enum.FontWeight.Bold)  
Ttl.TextColor3=Color3.new(1,1,1) Ttl.BackgroundTransparency=1  
Ttl.Size=UDim2.new(0.7,0,1,0) Ttl.Position=UDim2.new(0.04,0,0,0)  
Ttl.TextXAlignment=Enum.TextXAlignment.Left Ttl.TextTransparency=1 Ttl.ZIndex=3  
Ttl.TextScaled=true  
local ttlSC=Instance.new("UITextSizeConstraint",Ttl) ttlSC.MaxTextSize=14  
  
local function MkBtn(icon,posX)  
    local b=Instance.new("TextButton",TB)  
    b.Size=UDim2.new(0.07,0,0.7,0) b.Position=UDim2.new(posX,0,0.15,0)  
    b.BackgroundColor3=Color3.new(1,1,1) b.BackgroundTransparency=1 b.Text=icon  
    b.Font=Enum.Font.Gotham b.TextScaled=true b.TextColor3=Color3.new(1,1,1)  
    b.TextTransparency=1 b.ZIndex=4  
    Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)  
    Instance.new("UITextSizeConstraint",b).MaxTextSize=16  
    return b  
end  
local MinB=MkBtn("-",0.82)  
local ClsB=MkBtn("x",0.91)  
  
local RzB=Instance.new("TextButton",C)  
RzB.Size=UDim2.new(0.05,0,0.05,0) RzB.Position=UDim2.new(1,2,1,2)  
RzB.BackgroundTransparency=1 RzB.Text="" RzB.ZIndex=50  
local RzI=Instance.new("ImageLabel",RzB)  
RzI.Size=UDim2.new(1,0,1,0) RzI.BackgroundTransparency=1  
RzI.Image="rbxthumb://type=Asset&id=131384103443240&w=150&h=150"  
RzI.ImageColor3=Color3.new(1,1,1) RzI.ScaleType=Enum.ScaleType.Fit RzI.ImageTransparency=1 RzI.ZIndex=51  
  
-- Content area: fills below TopBar (35px fixed top)  
local Content=Instance.new("ScrollingFrame",Win)  
Content.Size=UDim2.new(0.94,0,1,-45) Content.Position=UDim2.new(0.03,0,0,40)  
Content.BackgroundTransparency=1 Content.ScrollBarThickness=0 Content.BorderSizePixel=0 Content.ZIndex=3  
Content.AutomaticCanvasSize=Enum.AutomaticSize.Y Content.CanvasSize=UDim2.new(0,0,0,0)  
local LL=Instance.new("UIListLayout",Content) LL.Padding=UDim.new(0.02,0)  
  
-- Drag & Resize  
local drg,rsz=false,false local ds,sp,ss  
TB.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drg=true ds=i.Position sp=C.Position end end)  
RzB.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then rsz=true ds=i.Position ss=C.Size end end)  
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drg=false rsz=false end end)  
UIS.InputChanged:Connect(function(i)  
    if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end  
    if drg and not rsz then local d=i.Position-ds C.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)  
    elseif rsz and not drg then local d=i.Position-ds  
        C.Size=UDim2.new(0,math.clamp(ss.X.Offset+d.X,260,600),0,math.clamp(ss.Y.Offset+d.Y,160,500))  
    end  
end)  
  
-- Hovers  
ClsB.MouseEnter:Connect(function() Tw(ClsB,{BackgroundColor3=Color3.fromRGB(255,80,80),BackgroundTransparency=0.5},0.15) end)  
ClsB.MouseLeave:Connect(function() Tw(ClsB,{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.85},0.15) end)  
MinB.MouseEnter:Connect(function() Tw(MinB,{BackgroundColor3=Color3.fromRGB(255,210,80),BackgroundTransparency=0.5},0.15) end)  
MinB.MouseLeave:Connect(function() Tw(MinB,{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.85},0.15) end)  
  
-- Minimize  
local closing,minimized=false,false local savedSz=Vector2.new(W,H)  
MinB.MouseButton1Click:Connect(function() if closing then return end minimized=not minimized  
    if minimized then MinB.Text="+" RzB.Visible=false savedSz=Vector2.new(C.AbsoluteSize.X,C.AbsoluteSize.Y)  
        Tw(C,{Size=UDim2.new(0,savedSz.X,0,35)},0.18)  
    else MinB.Text="-" RzB.Visible=true Tw(C,{Size=UDim2.new(0,savedSz.X,0,savedSz.Y)},0.18) end end)  
  
-- Close with full cleanup  
ClsB.MouseButton1Click:Connect(function() if closing then return end closing=true  
    Tw(C,{Size=UDim2.new(0,C.AbsoluteSize.X*0.95,0,C.AbsoluteSize.Y*0.95)},0.15) Tw(GS,{Transparency=1},0.15)  
    for _,ch in pairs(C:GetDescendants()) do pcall(function()  
        if ch:IsA("TextLabel") or ch:IsA("TextBox") then Tw(ch,{TextTransparency=1},0.15)  
        elseif ch:IsA("TextButton") or ch:IsA("Frame") then Tw(ch,{BackgroundTransparency=1},0.15)  
        elseif ch:IsA("ImageLabel") then Tw(ch,{ImageTransparency=1},0.15)  
        elseif ch:IsA("UIStroke") then Tw(ch,{Transparency=1},0.15) end end) end  
    task.wait(0.15)  
    for _,key in pairs({"_flyConn","_noclipConn","_sprintDown","_sprintUp","_clickDelConn","_chatJoin","_flingConn","_speedStopConn"}) do  
        if _G[key] then pcall(function() _G[key]:Disconnect() end) _G[key]=nil end end  
    if _G._chatConns then for _,c2 in pairs(_G._chatConns) do pcall(function() c2:Disconnect() end) end _G._chatConns=nil end  
    _G._platOn=false _G._flingOn=false  
    local chr=plr.Character  
    if chr then  
        local rp=chr:FindFirstChild("HumanoidRootPart")  
        if rp then for _,n in pairs({"FlyBV","FlyBG","AntiGBF","SpinBAV"}) do local o=rp:FindFirstChild(n) if o then o:Destroy() end end  
            rp.Anchored=false pcall(function() rp.AssemblyLinearVelocity=Vector3.new(0,rp.AssemblyLinearVelocity.Y,0) end) end  
        local hum=chr:FindFirstChildOfClass("Humanoid")  
        if hum then hum.PlatformStand=false hum.WalkSpeed=16 hum.JumpPower=50 hum.UseJumpPower=true hum.Sit=false  
            if hum.MaxHealth==math.huge then hum.MaxHealth=100 hum.Health=100 end  
            hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.Viewer  
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true) hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true) hum:SetStateEnabled(Enum.HumanoidStateType.Landed,true) end) end  
        for _,p in pairs(chr:GetDescendants()) do  
            if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Transparency=0 p.Material=Enum.Material.SmoothPlastic  
            elseif p:IsA("Decal") then p.Transparency=0 end end  
        local hl=chr:FindFirstChild("SelfHL") if hl then hl:Destroy() end end  
    workspace.Gravity=196.2  
    pcall(function() workspace.CurrentCamera.FieldOfView=70 workspace.CurrentCamera.CameraType=Enum.CameraType.Custom end)  
    if chr then local h2=chr:FindFirstChildOfClass("Humanoid") if h2 then pcall(function() workspace.CurrentCamera.CameraSubject=h2 end) end end  
    plr.CameraMode=Enum.CameraMode.Classic plr.CameraMaxZoomDistance=128 plr.CameraMinZoomDistance=0.5  
    local L=game:GetService("Lighting")  
    for _,n in pairs({"NightVis","CineCC"}) do local x=L:FindFirstChild(n) if x then x:Destroy() end end  
    if _G._hiddenAtmos then for _,d2 in pairs(_G._hiddenAtmos) do pcall(function() d2[1].Parent=d2[2] end) end _G._hiddenAtmos=nil end  
    for _,p in pairs(workspace:GetChildren()) do if p.Name=="GenPlat" or p.Name=="WaypointMark" then p:Destroy() end end  
    _G["Flow_TPPlr"]=nil Gui:Destroy() end)  
  
-- Entry animation  
C.Size=UDim2.new(0,W*0.95,0,H*0.95) C.Position=UDim2.new(0,cx+W*0.025,0,cy+H*0.025)  
task.wait(0.05)  
Tw(C,{Size=UDim2.new(0,W,0,H),Position=UDim2.new(0,cx,0,cy)},DUR) Tw(Win,{BackgroundTransparency=0.15},DUR)  
Tw(GS,{Transparency=0.85},DUR) Tw(Shd,{ImageTransparency=0.30},DUR) Tw(Ttl,{TextTransparency=0},DUR)  
Tw(RzI,{ImageTransparency=0},DUR) Tw(MinB,{BackgroundTransparency=0.85,TextTransparency=0},DUR) Tw(ClsB,{BackgroundTransparency=0.85,TextTransparency=0},DUR)  
  
-- == CONTENT == --  
  
local cntL=Instance.new("TextLabel",Content) cntL.Size=UDim2.new(1,0,0.06,0) cntL.BackgroundTransparency=1  
cntL.Text="0 players" cntL.TextColor3=Color3.fromRGB(100,100,100) cntL.Font=Enum.Font.Gotham cntL.TextScaled=true cntL.ZIndex=4  
Instance.new("UITextSizeConstraint",cntL).MaxTextSize=11  
  
function refresh()  
    for _,c in pairs(Content:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end  
    local count=0  
    for _,target in pairs(Players:GetPlayers()) do if target~=plr then count=count+1  
        local btn=Instance.new("TextButton",Content) btn.Size=UDim2.new(1,0,0.1,0)  
        btn.Text="  "..target.DisplayName btn.TextColor3=Color3.new(1,1,1) btn.BackgroundColor3=Color3.fromRGB(45,45,50)  
        btn.BorderSizePixel=0 btn.Font=Enum.Font.GothamSemibold btn.TextScaled=true btn.ZIndex=4  
        btn.TextXAlignment=Enum.TextXAlignment.Left  
        Instance.new("UICorner",btn).CornerRadius=UDim.new(0.15,0) Instance.new("UITextSizeConstraint",btn).MaxTextSize=13  
        btn.MouseEnter:Connect(function() Tw(btn,{BackgroundColor3=Color3.fromRGB(65,65,70)},0.1) end)  
        btn.MouseLeave:Connect(function() Tw(btn,{BackgroundColor3=Color3.fromRGB(45,45,50)},0.1) end)  
        btn.MouseButton1Click:Connect(function()  
            local myC=plr.Character local thC=target.Character  
            if not myC or not thC then return end  
            local myR=myC:FindFirstChild("HumanoidRootPart") local thR=thC:FindFirstChild("HumanoidRootPart")  
            if not myR or not thR then return end  
            myR.CFrame=thR.CFrame*CFrame.new(0,0,3)  
            Tw(btn,{BackgroundColor3=Color3.fromRGB(52,199,89)},0.1) task.wait(0.3) Tw(btn,{BackgroundColor3=Color3.fromRGB(45,45,50)},0.1)  
        end)  
    end end  
    cntL.Text=count.." player"..(count~=1 and "s" or "")  
end  
refresh()  
Players.PlayerAdded:Connect(function() task.wait(1) refresh() end)  
Players.PlayerRemoving:Connect(function() task.wait(0.5) refresh() end)  
