--[[ ═══════════════════════════════════════════════════════
     VzNamHub : Toạ Độ - Steal an Egg Edition (Full Info + Bypass) - FIXED TABS
     ═══════════════════════════════════════════════════════ ]]

-- ═════════════════ LỚP TƯƠNG THÍCH (Chạy được trên cả Studio lẫn Executor) ═════════════════
if not getrawmetatable then getrawmetatable = function() return {} end end
if not setreadonly then setreadonly = function() end end
if not newcclosure then newcclosure = function(f) return f end end
if not getnamecallmethod then getnamecallmethod = function() return "" end end
if not writefile then writefile = function() end end
if not readfile then readfile = function() return "" end end
if not makefolder then makefolder = function() end end
if not delfile then delfile = function() end end
if not listfiles then listfiles = function() return {} end end
if not setclipboard then setclipboard = function() end end

local CoreGui
pcall(function() CoreGui = game:GetService("CoreGui") end)
local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService  = game:GetService("SoundService")
local HttpService   = game:GetService("HttpService")
local RunService    = game:GetService("RunService")
local localPlayer   = Players.LocalPlayer

if not localPlayer then return end
local PlayerGui     = localPlayer:FindFirstChildOfClass("PlayerGui") or CoreGui

if PlayerGui:FindFirstChild("VzNamHubV4UI") then PlayerGui.VzNamHubV4UI:Destroy() end
if PlayerGui:FindFirstChild("VzNamHubLoading") then PlayerGui.VzNamHubLoading:Destroy() end
if SoundService:FindFirstChild("VzNamHubSound") then SoundService.VzNamHubSound:Destroy() end

local Connections = {}
local function Track(c) if c then table.insert(Connections, c) end return c end

local State = {
    ThemeBase = Color3.fromRGB(15, 16, 22), StrokeMode = "Solid", StrokeColor = Color3.fromRGB(0, 191, 255),
    Volume = 0.5, SoundId = "1837879082", CurrentConfig = "Default", Transparent = 0,
}

local CoordState = { Speed = 100, TeleportMode = false, CurrentTween = nil }

local AntiCheatFlags = { AntiKick = false, AntiAFK = false, AntiVoid = false, AntiFling = false, NetworkOwner = false }
local BypassState = {
    WalkSpeed = 16, JumpPower = 50, Noclip = false, Godmode = false, InfiniteJump = false,
    AntiRagdoll = false, AntiSlow = false, SpeedBypass = false, DamageBlock = false,
}

local AllUIStrokes = {}
local ThemedElements = {}
local Tabs = {}
local acToggleFrames = {}
local _lastSafePos = nil

-- ═════════════════ KHAI BÁO CÁC BIẾN DÙNG CHUNG (GLOBAL LOCAL) ═════════════════
local ScreenGui, MainFrame, LoadingGui, flowerBtn, fStroke
local SidebarPanel, ContentContainer
local SidebarScroll, ActiveTabTitle          -- [FIX] dùng chung cho mọi khối do...end
local ApplyTheme, UpdateAllStrokes           -- [FIX] ApplyConfig cần gọi được 2 hàm này
local speedBarFill, speedValLbl, teleportToggleBtn, teleportToggleDot
local bypassSpeedFill, bypassSpeedLbl, bypassJumpFill, bypassJumpLbl
local volumeBarFill, volumeLabel, transBarFill, transLabel
local startupLabel, ldBtn, svSub, delBtn, delDropFrame, ldDropFrame
local CoordPoints, RefreshPointsDropdown, CreateCoordPoint
local HubSound

-- ═════════════════ CÁC HÀM TIỆN ÍCH CHUNG ═════════════════
local function Corner(p, r) local c = Instance.new("UICorner", p); c.CornerRadius = r or UDim.new(0, 5); return c end
local function Stroke(p, color, thick)
    local s = Instance.new("UIStroke", p)
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = color or State.StrokeColor
    s.Thickness = thick or 1
    table.insert(AllUIStrokes, s)
    return s
end
local function RegTheme(el, t)
    table.insert(ThemedElements, {Element = el, Type = t})
    if el and State.ThemeBase then
        local base = State.ThemeBase
        if t == "Primary" then el.BackgroundColor3 = base:Lerp(Color3.new(1,1,1), 0.08)
        elseif t == "Secondary" then el.BackgroundColor3 = base:Lerp(Color3.new(1,1,1), 0.15)
        elseif t == "DropFrame" then el.BackgroundColor3 = base:Lerp(Color3.new(1,1,1), 0.2)
        elseif t == "DropItem" then el.BackgroundColor3 = base:Lerp(Color3.new(1,1,1), 0.3)
        elseif t == "Input" then el.BackgroundColor3 = base:Lerp(Color3.new(0,0,0), 0.4) end
    end
    return el
end

local function ApplyBypassNow()
    local char = localPlayer.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if BypassState.SpeedBypass or BypassState.WalkSpeed ~= 16 then
        local target = BypassState.WalkSpeed
        if BypassState.AntiSlow and target < 16 then target = 16 end
        pcall(function() hum.WalkSpeed = target end)
    end
    if BypassState.JumpPower ~= 50 then
        pcall(function() hum.UseJumpPower = true; hum.JumpPower = BypassState.JumpPower end)
    end
end

local function HookHumanoid(hum)
    if not hum or hum:GetAttribute("VzNamBypassHooked") then return end
    hum:SetAttribute("VzNamBypassHooked", true)
    Track(hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if not (BypassState.SpeedBypass or BypassState.WalkSpeed ~= 16) then return end
        local target = BypassState.WalkSpeed
        if BypassState.AntiSlow and target < 16 then target = 16 end
        if math.abs(hum.WalkSpeed - target) > 0.1 then pcall(function() hum.WalkSpeed = target end) end
    end))
    Track(hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if BypassState.JumpPower == 50 then return end
        if math.abs((hum.JumpPower or 0) - BypassState.JumpPower) > 0.1 then
            pcall(function() hum.UseJumpPower = true; hum.JumpPower = BypassState.JumpPower end)
        end
    end))
    Track(hum.HealthChanged:Connect(function(newHp)
        if (BypassState.Godmode or BypassState.DamageBlock) and newHp < hum.MaxHealth then
            pcall(function() hum.Health = hum.MaxHealth end)
        end
    end))
end

local function CreateToggle(parent, order, label, getter, setter, onChange)
    local f = Instance.new("Frame", parent)
    f.LayoutOrder, f.Size = order, UDim2.new(1, 0, 0, 30)
    f.BackgroundColor3, f.BackgroundTransparency = Color3.fromRGB(70,15,50), 0
    Corner(f); Stroke(f); RegTheme(f, "Primary")
    local lbl = Instance.new("TextLabel", f)
    lbl.Size, lbl.Position = UDim2.new(1, -50, 1, 0), UDim2.new(0, 6, 0, 0)
    lbl.BackgroundTransparency, lbl.Text = 1, label
    lbl.TextColor3, lbl.TextSize = Color3.fromRGB(255,255,255), 8
    lbl.Font, lbl.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Left
    local btn = Instance.new("TextButton", f)
    btn.Size, btn.Position = UDim2.new(0, 34, 0, 16), UDim2.new(1, -40, 0.5, -8)
    btn.BackgroundColor3, btn.Text = Color3.fromRGB(60,65,75), ""
    Corner(btn, UDim.new(1, 0)); Stroke(btn)
    local dot = Instance.new("Frame", btn)
    dot.Size, dot.Position = UDim2.new(0, 12, 0, 12), UDim2.new(0, 2, 0.5, -6)
    dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Corner(dot, UDim.new(1, 0))
    local function upd(s)
        if s then btn.BackgroundColor3 = Color3.fromRGB(50,200,50); dot.Position = UDim2.new(1, -14, 0.5, -6)
        else btn.BackgroundColor3 = Color3.fromRGB(60,65,75); dot.Position = UDim2.new(0, 2, 0.5, -6) end
    end
    upd(getter())
    Track(btn.MouseButton1Click:Connect(function()
        local n = not getter(); setter(n); upd(n); if onChange then onChange(n) end
    end))
    return f, btn, dot
end

local function CreateSlider(parent, order, label, minV, maxV, getter, setter)
    local f = Instance.new("Frame", parent)
    f.LayoutOrder, f.Size = order, UDim2.new(1, 0, 0, 34)
    f.BackgroundColor3, f.BackgroundTransparency = Color3.fromRGB(70,15,50), 0
    Corner(f); Stroke(f); RegTheme(f, "Primary")
    local lbl = Instance.new("TextLabel", f)
    lbl.Size, lbl.Position = UDim2.new(1, -10, 0, 12), UDim2.new(0, 6, 0, 2)
    lbl.BackgroundTransparency, lbl.Text = 1, label
    lbl.TextColor3, lbl.TextSize = Color3.fromRGB(255,255,255), 8
    lbl.Font, lbl.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Left
    local valLbl = Instance.new("TextLabel", f)
    valLbl.Size, valLbl.Position = UDim2.new(0, 50, 0, 12), UDim2.new(1, -56, 0, 2)
    valLbl.BackgroundTransparency, valLbl.Text = 1, tostring(getter())
    valLbl.TextColor3, valLbl.TextSize = Color3.fromRGB(0,200,255), 8
    valLbl.Font, valLbl.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Right
    local barBg = Instance.new("Frame", f)
    barBg.Size, barBg.Position = UDim2.new(1, -12, 0, 8), UDim2.new(0, 6, 1, -13)
    barBg.BackgroundColor3 = Color3.fromRGB(90,25,65)
    Corner(barBg, UDim.new(1, 0)); Stroke(barBg); RegTheme(barBg, "DropItem")
    local barFill = Instance.new("Frame", barBg)
    barFill.BackgroundColor3 = Color3.fromRGB(0,180,255)
    Corner(barFill, UDim.new(1, 0))
    local pct = (getter() - minV) / (maxV - minV)
    barFill.Size = UDim2.new(math.clamp(pct, 0, 1), 0, 1, 0)
    local drag = Instance.new("TextButton", barBg)
    drag.Size, drag.BackgroundTransparency, drag.Text = UDim2.new(1, 10, 1, 10), 1, ""
    local dragging = false
    Track(drag.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end))
    Track(UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
    Track(UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local ap, as = barBg.AbsolutePosition.X, barBg.AbsoluteSize.X
            local p = math.clamp((i.Position.X - ap) / as, 0, 1)
            local v = math.floor(minV + p * (maxV - minV))
            barFill.Size = UDim2.new(p, 0, 1, 0)
            valLbl.Text = tostring(v)
            setter(v)
        end
    end))
    return f, barFill, valLbl
end

-- ═════════════════ KHỞI TẠO UI CHÍNH ═════════════════
do
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VzNamHubV4UI"
    ScreenGui.DisplayOrder = 99999
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 380, 0, 300)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui
    Corner(MainFrame, UDim.new(0, 8)); Stroke(MainFrame, Color3.fromRGB(0, 191, 255), 2)

    LoadingGui = Instance.new("ScreenGui")
    LoadingGui.Name = "VzNamHubLoading"
    LoadingGui.DisplayOrder = 100000
    LoadingGui.ResetOnSpawn = false
    LoadingGui.Parent = PlayerGui

    local LoadFrame = Instance.new("Frame", LoadingGui)
    LoadFrame.Size = UDim2.new(0, 340, 0, 220)
    LoadFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    LoadFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    LoadFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
    LoadFrame.BorderSizePixel = 0
    Corner(LoadFrame, UDim.new(0, 8)); Stroke(LoadFrame, Color3.fromRGB(0, 191, 255), 2)

    local LoadTitle = Instance.new("TextLabel", LoadFrame)
    LoadTitle.Size = UDim2.new(1, 0, 0, 35)
    LoadTitle.Position = UDim2.new(0, 0, 0, 8)
    LoadTitle.BackgroundTransparency = 1
    LoadTitle.Text = "🌸 VzNamHub : Toạ Độ 🌸"
    LoadTitle.TextColor3 = Color3.fromRGB(0, 191, 255)
    LoadTitle.TextSize = 13
    LoadTitle.Font = Enum.Font.GothamBold

    local LoadInfoHolder = Instance.new("Frame", LoadFrame)
    LoadInfoHolder.Size = UDim2.new(1, -20, 0, 95)
    LoadInfoHolder.Position = UDim2.new(0, 10, 0, 45)
    LoadInfoHolder.BackgroundTransparency = 1
    local LIL = Instance.new("UIListLayout", LoadInfoHolder)
    LIL.SortOrder, LIL.Padding, LIL.HorizontalAlignment = Enum.SortOrder.LayoutOrder, UDim.new(0, 4), Enum.HorizontalAlignment.Center

    local function CreateLoadCard(parent, order, bgColor, titleText, mainText, borderColor, iconSymbol)
        local card = Instance.new("Frame", parent)
        card.LayoutOrder = order; card.Size = UDim2.new(1, 0, 0, 27)
        card.BackgroundColor3 = bgColor; card.BorderSizePixel = 0
        Corner(card); Stroke(card, borderColor, 1)
        local ic = Instance.new("Frame", card)
        ic.Size, ic.Position = UDim2.new(0, 16, 0, 16), UDim2.new(0, 4, 0.5, -8)
        ic.BackgroundColor3, ic.BorderSizePixel = borderColor, 0
        Corner(ic, UDim.new(1, 0)); Stroke(ic, borderColor)
        local il = Instance.new("TextLabel", ic)
        il.Size, il.BackgroundTransparency = UDim2.new(1,0,1,0), 1
        il.Text, il.TextColor3 = iconSymbol, Color3.fromRGB(255,255,255)
        il.TextSize, il.Font = 7, Enum.Font.GothamBold
        local tLbl = Instance.new("TextLabel", card)
        tLbl.Size, tLbl.Position = UDim2.new(1, -30, 0, 10), UDim2.new(0, 24, 0, 1)
        tLbl.BackgroundTransparency, tLbl.Text = 1, titleText
        tLbl.TextColor3, tLbl.TextSize = Color3.fromRGB(255,150,100), 7
        tLbl.Font, tLbl.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Left
        local mLbl = Instance.new("TextLabel", card)
        mLbl.Size, mLbl.Position = UDim2.new(1, -30, 0, 12), UDim2.new(0, 24, 0, 12)
        mLbl.BackgroundTransparency, mLbl.Text = 1, mainText
        mLbl.TextColor3, mLbl.TextSize = Color3.fromRGB(220,220,230), 7
        mLbl.Font, mLbl.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
    end

    CreateLoadCard(LoadInfoHolder, 1, Color3.fromRGB(70,20,45), "ĐƯỢC TẠO BỞI", "VzNam ROBLOX", Color3.fromRGB(180,50,50), "👤")
    CreateLoadCard(LoadInfoHolder, 2, Color3.fromRGB(30,40,70), "DISCORD", "https://discord.gg/6TG7krbsU", Color3.fromRGB(60,100,200), "💬")
    CreateLoadCard(LoadInfoHolder, 3, Color3.fromRGB(45,45,65), "TIKTOK", "https://www.tiktok.com/@uttop1gl.ovo", Color3.fromRGB(100,100,120), "🎵")

    local BarBg = Instance.new("Frame", LoadFrame)
    BarBg.Size, BarBg.Position = UDim2.new(1, -20, 0, 10), UDim2.new(0, 10, 1, -40)
    BarBg.BackgroundColor3 = Color3.fromRGB(25,26,35)
    Corner(BarBg, UDim.new(1, 0)); Stroke(BarBg, Color3.fromRGB(0, 191, 255), 1)
    local BarFill = Instance.new("Frame", BarBg)
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
    Corner(BarFill, UDim.new(1, 0))
    local PercentLbl = Instance.new("TextLabel", LoadFrame)
    PercentLbl.Size, PercentLbl.Position = UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 1, -24)
    PercentLbl.BackgroundTransparency, PercentLbl.Text = 1, "Đang tải: 0/10"
    PercentLbl.TextColor3, PercentLbl.TextSize = Color3.fromRGB(200,205,215), 8
    PercentLbl.Font = Enum.Font.GothamBold

    task.spawn(function()
        for i = 1, 10 do task.wait(0.15); BarFill.Size = UDim2.new(i / 10, 0, 1, 0); PercentLbl.Text = "Đang tải: " .. i .. "/10" end
        task.wait(0.2); LoadingGui:Destroy(); MainFrame.Visible = true; flowerBtn.Visible = true
        if MainFrame.Visible then flowerBtn.Text = "✕"; fStroke.Color = Color3.fromRGB(255, 80, 80) else flowerBtn.Text = "🌸"; fStroke.Color = Color3.fromRGB(255, 105, 180) end
    end)

    flowerBtn = Instance.new("TextButton", ScreenGui)
    flowerBtn.Size, flowerBtn.Position = UDim2.new(0, 50, 0, 50), UDim2.new(0, 20, 0.4, 0)
    flowerBtn.BackgroundColor3, flowerBtn.BackgroundTransparency = Color3.fromRGB(25, 25, 35), 0.1
    flowerBtn.Text, flowerBtn.TextSize, flowerBtn.TextColor3 = "🌸", 26, Color3.fromRGB(255, 255, 255)
    flowerBtn.Font, flowerBtn.Active, flowerBtn.Draggable, flowerBtn.Visible = Enum.Font.GothamBold, true, true, false
    Corner(flowerBtn, UDim.new(1, 0))
    fStroke = Instance.new("UIStroke", flowerBtn)
    fStroke.Thickness, fStroke.Color = 2.5, Color3.fromRGB(255, 105, 180)
    table.insert(AllUIStrokes, fStroke)

    local ResizeBtn = Instance.new("TextButton", MainFrame)
    ResizeBtn.Size, ResizeBtn.Position = UDim2.new(0, 18, 0, 18), UDim2.new(1, -18, 1, -18)
    ResizeBtn.BackgroundTransparency, ResizeBtn.Text = 1, "◢"
    ResizeBtn.TextColor3, ResizeBtn.TextSize, ResizeBtn.ZIndex = Color3.fromRGB(0, 191, 255), 12, 10
    local resizing, resizeStart, startSize = false, nil, nil
    Track(ResizeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true; resizeStart = input.Position; startSize = MainFrame.AbsoluteSize
        end
    end))
    Track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = false end
    end))
    Track(UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - resizeStart
            MainFrame.Size = UDim2.new(0, math.clamp(startSize.X + d.X, 320, 500), 0, math.clamp(startSize.Y + d.Y, 230, 450))
        end
    end))

    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Size, TopBar.BackgroundTransparency = UDim2.new(1, 0, 0, 26), 1
    local Logo = Instance.new("Frame", TopBar)
    Logo.Size, Logo.Position = UDim2.new(0, 18, 0, 18), UDim2.new(0, 6, 0.5, -9)
    Logo.BackgroundColor3, Logo.BorderSizePixel = Color3.fromRGB(0, 191, 255), 0
    Corner(Logo, UDim.new(0, 4)); Stroke(Logo, Color3.fromRGB(0, 191, 255))
    local LogoIcon = Instance.new("TextLabel", Logo)
    LogoIcon.Size, LogoIcon.BackgroundTransparency = UDim2.new(1,0,1,0), 1
    LogoIcon.Text, LogoIcon.TextColor3 = "🌸", Color3.fromRGB(255,255,255)
    LogoIcon.TextSize, LogoIcon.Font = 10, Enum.Font.GothamBold

    local Title = Instance.new("TextLabel", TopBar)
    Title.Size, Title.Position = UDim2.new(1, -60, 1, 0), UDim2.new(0, 28, 0, 0)
    Title.BackgroundTransparency, Title.Text = 1, "🌸 VzNamHub : Toạ Độ 🌸"
    Title.TextColor3, Title.TextSize = Color3.fromRGB(0, 191, 255), 10
    Title.Font, Title.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Center

    local CloseBtn = Instance.new("TextButton", TopBar)
    CloseBtn.Size, CloseBtn.Position = UDim2.new(0, 24, 0, 24), UDim2.new(1, -26, 0.5, -12)
    CloseBtn.BackgroundTransparency, CloseBtn.Text = 1, "✕"
    CloseBtn.TextColor3, CloseBtn.TextSize, CloseBtn.Font = Color3.fromRGB(200, 200, 210), 10, Enum.Font.GothamBold
    Track(CloseBtn.MouseButton1Click:Connect(function()
        if CoordState.CurrentTween then pcall(function() CoordState.CurrentTween:Cancel() end); CoordState.CurrentTween = nil end
        pcall(function() local char = localPlayer.Character; if char then local hrp = char:FindFirstChild("HumanoidRootPart"); if hrp then hrp.Anchored = false end end end)
        pcall(function() if SoundService:FindFirstChild("VzNamHubSound") then SoundService.VzNamHubSound:Stop(); SoundService.VzNamHubSound:Destroy() end end)
        for _, c in ipairs(Connections) do pcall(function() if c and c.Connected then c:Disconnect() end end) end
        Connections = {}
        pcall(function() if ScreenGui then ScreenGui:Destroy() end end)
        pcall(function() if LoadingGui then LoadingGui:Destroy() end end)
        print("[VzNamHub : Toạ Độ] ❌ Đã tắt hoàn toàn")
    end))

    SidebarPanel = Instance.new("Frame", MainFrame)
    SidebarPanel.Size, SidebarPanel.Position = UDim2.new(0.3, -4, 1, -34), UDim2.new(0, 6, 0, 28)
    SidebarPanel.BackgroundColor3, SidebarPanel.BorderSizePixel = Color3.fromRGB(15,16,22), 0
    Corner(SidebarPanel, UDim.new(0, 6)); Stroke(SidebarPanel, Color3.fromRGB(0,191,255), 1)

    -- [FIX] bỏ "local" để gán vào biến dùng chung
    SidebarScroll = Instance.new("ScrollingFrame", SidebarPanel)
    SidebarScroll.Size, SidebarScroll.Position = UDim2.new(1, -4, 1, -8), UDim2.new(0, 2, 0, 4)
    SidebarScroll.BackgroundTransparency, SidebarScroll.BorderSizePixel, SidebarScroll.ScrollBarThickness, SidebarScroll.ClipsDescendants = 1, 0, 2, true
    local SidebarLayout = Instance.new("UIListLayout", SidebarScroll)
    SidebarLayout.SortOrder, SidebarLayout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 3)
    local SidebarPad = Instance.new("UIPadding", SidebarScroll)
    SidebarPad.PaddingLeft, SidebarPad.PaddingRight, SidebarPad.PaddingTop = UDim.new(0, 2), UDim.new(0, 6), UDim.new(0, 3)
    Track(SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 10)
    end))

    ContentContainer = Instance.new("Frame", MainFrame)
    ContentContainer.Size, ContentContainer.Position = UDim2.new(0.68, -4, 1, -34), UDim2.new(0.315, 0, 0, 28)
    ContentContainer.BackgroundColor3, ContentContainer.BorderSizePixel = Color3.fromRGB(15,16,22), 0
    Corner(ContentContainer, UDim.new(0, 6)); Stroke(ContentContainer, Color3.fromRGB(0,191,255), 1)

    local ContentHeader = Instance.new("Frame", ContentContainer)
    ContentHeader.Size, ContentHeader.BackgroundTransparency = UDim2.new(1, 0, 0, 26), 1
    -- [FIX] bỏ "local" để các tab khác đổi được tiêu đề
    ActiveTabTitle = Instance.new("TextLabel", ContentHeader)
    ActiveTabTitle.Size, ActiveTabTitle.Position = UDim2.new(1, -30, 1, 0), UDim2.new(0, 6, 0, 0)
    ActiveTabTitle.BackgroundTransparency, ActiveTabTitle.Text = 1, ""
    ActiveTabTitle.TextColor3, ActiveTabTitle.TextSize = Color3.fromRGB(255,255,255), 10
    ActiveTabTitle.Font, ActiveTabTitle.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Left
    local HeaderDivider = Instance.new("Frame", ContentContainer)
    HeaderDivider.Size, HeaderDivider.Position = UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, 26)
    HeaderDivider.BackgroundColor3, HeaderDivider.BorderSizePixel = Color3.fromRGB(0,191,255), 0

    -- Các nút Tabs
    local function CreateTabBtn(order, text, scroll, ind)
        local btn = Instance.new("TextButton", SidebarScroll)
        btn.LayoutOrder, btn.Size = order, UDim2.new(1, 0, 0, 26)
        btn.BackgroundColor3, btn.BackgroundTransparency, btn.Text = Color3.fromRGB(70,15,50), 0, text
        btn.TextColor3, btn.TextSize = Color3.fromRGB(255,255,255), 8
        btn.Font, btn.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
        Corner(btn); RegTheme(btn, "Primary")
        Track(btn.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do t.Container.Visible = false; if t.Indicator then t.Indicator.Visible = false end end
            scroll.Visible, ind.Visible = true, true
            ActiveTabTitle.Text = text
        end))
        ind = Instance.new("Frame", btn)
        ind.Size, ind.Position = UDim2.new(0, 3, 0, 12), UDim2.new(0, 0, 0.5, -6)
        ind.BackgroundColor3, ind.BorderSizePixel, ind.Visible = Color3.fromRGB(255,105,180), 0, false
        Corner(ind, UDim.new(0, 2))
        table.insert(Tabs, {Container = scroll, Indicator = ind})
        return btn, ind
    end

    -- TAB HOME
    local homeScroll = Instance.new("ScrollingFrame", ContentContainer)
    homeScroll.Size, homeScroll.Position = UDim2.new(1, -12, 1, -29), UDim2.new(0, 6, 0, 28)
    homeScroll.BackgroundTransparency, homeScroll.BorderSizePixel, homeScroll.ScrollBarThickness, homeScroll.Visible, homeScroll.ClipsDescendants = 1, 0, 3, false, true
    local homeLayout = Instance.new("UIListLayout", homeScroll)
    homeLayout.SortOrder, homeLayout.Padding, homeLayout.HorizontalAlignment = Enum.SortOrder.LayoutOrder, UDim.new(0, 5), Enum.HorizontalAlignment.Center
    local homePad = Instance.new("UIPadding", homeScroll)
    homePad.PaddingLeft, homePad.PaddingRight, homePad.PaddingTop, homePad.PaddingBottom = UDim.new(0, 4), UDim.new(0, 10), UDim.new(0, 4), UDim.new(0, 4)
    Track(homeLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        homeScroll.CanvasSize = UDim2.new(0, 0, 0, homeLayout.AbsoluteContentSize.Y + 15)
    end))

    local homeBtn, homeInd = CreateTabBtn(0, " 🏠 Trang Chủ", homeScroll, nil)
    homeScroll.Visible, homeInd.Visible = true, true
    ActiveTabTitle.Text = "🏠 Trang Chủ"

    local infoToggleBtn = Instance.new("TextButton", homeScroll)
    infoToggleBtn.LayoutOrder, infoToggleBtn.Size = 1, UDim2.new(1, 0, 0, 32)
    infoToggleBtn.BackgroundColor3, infoToggleBtn.BackgroundTransparency = Color3.fromRGB(55,12,40), 0
    infoToggleBtn.Text, infoToggleBtn.TextColor3, infoToggleBtn.TextSize = " → thông tin", Color3.fromRGB(255,255,255), 10
    infoToggleBtn.Font, infoToggleBtn.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Center
    Corner(infoToggleBtn); Stroke(infoToggleBtn); RegTheme(infoToggleBtn, "Secondary")

    local infoContainer = Instance.new("Frame", homeScroll)
    infoContainer.LayoutOrder, infoContainer.Size, infoContainer.AutomaticSize = 2, UDim2.new(1, 0, 0, 0), Enum.AutomaticSize.Y
    infoContainer.BackgroundTransparency, infoContainer.Visible = 1, false
    local infoLayout = Instance.new("UIListLayout", infoContainer)
    infoLayout.SortOrder, infoLayout.Padding, infoLayout.HorizontalAlignment = Enum.SortOrder.LayoutOrder, UDim.new(0, 4), Enum.HorizontalAlignment.Center
    Track(infoToggleBtn.MouseButton1Click:Connect(function()
        infoContainer.Visible = not infoContainer.Visible
        infoToggleBtn.Text = infoContainer.Visible and " ↓ thông tin" or " → thông tin"
    end))

    local function CreateHomeCard(parent, order, bgColor, titleText, mainText, copyText, borderColor, iconSymbol)
        local card = Instance.new("Frame", parent)
        card.LayoutOrder, card.Size = order, UDim2.new(1, 0, 0, 26)
        card.BackgroundColor3, card.BorderSizePixel = bgColor, 0
        Corner(card); Stroke(card, borderColor, 1)
        local ic = Instance.new("Frame", card)
        ic.Size, ic.Position = UDim2.new(0, 16, 0, 16), UDim2.new(0, 4, 0.5, -8)
        ic.BackgroundColor3, ic.BorderSizePixel = borderColor, 0
        Corner(ic, UDim.new(1, 0)); Stroke(ic, borderColor)
        local il = Instance.new("TextLabel", ic)
        il.Size, il.BackgroundTransparency = UDim2.new(1,0,1,0), 1
        il.Text, il.TextColor3, il.TextSize, il.Font = iconSymbol, Color3.fromRGB(255,255,255), 7, Enum.Font.GothamBold
        local tLbl = Instance.new("TextLabel", card)
        tLbl.Size, tLbl.Position = UDim2.new(1, -70, 0, 10), UDim2.new(0, 24, 0, 1)
        tLbl.BackgroundTransparency, tLbl.Text, tLbl.TextColor3, tLbl.TextSize = 1, titleText, Color3.fromRGB(255,150,100), 7
        tLbl.Font, tLbl.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Left
        local mLbl = Instance.new("TextLabel", card)
        mLbl.Size, mLbl.Position = UDim2.new(1, -70, 0, 12), UDim2.new(0, 24, 0, 12)
        mLbl.BackgroundTransparency, mLbl.Text, mLbl.TextColor3, mLbl.TextSize = 1, mainText, Color3.fromRGB(220,220,230), 7
        mLbl.Font, mLbl.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
        if copyText ~= "" then
            local cBtn = Instance.new("TextButton", card)
            cBtn.Size, cBtn.Position = UDim2.new(0, 42, 0, 16), UDim2.new(1, -44, 0.5, -8)
            cBtn.BackgroundTransparency, cBtn.Text, cBtn.TextColor3, cBtn.TextSize, cBtn.Font = 1, "📋 COPY", Color3.fromRGB(200,200,210), 7, Enum.Font.GothamBold
            Track(cBtn.MouseButton1Click:Connect(function()
                if typeof(setclipboard) == "function" then pcall(setclipboard, copyText); cBtn.Text = "✓ COPIED"; task.delay(1.5, function() if cBtn.Parent then cBtn.Text = "📋 COPY" end end) end
            end))
        end
    end
    CreateHomeCard(infoContainer, 1, Color3.fromRGB(70,20,45), "ĐƯỢC TẠO BỞI", "VzNam ROBLOX", "", Color3.fromRGB(180,50,50), "👤")
    CreateHomeCard(infoContainer, 2, Color3.fromRGB(30,40,70), "DISCORD", "https://discord.gg/6TG7krbsU", "https://discord.gg/6TG7krbsU", Color3.fromRGB(60,100,200), "💬")
    CreateHomeCard(infoContainer, 3, Color3.fromRGB(45,45,65), "TIKTOK", "https://www.tiktok.com/@uttop1gl.ovo", "https://www.tiktok.com/@uttop1gl.ovo?_r=1&_t=ZS-9AWatTQR08y", Color3.fromRGB(100,100,120), "🎵")
end

-- TAB TOẠ ĐỘ
do
    local coordScroll = Instance.new("ScrollingFrame", ContentContainer)
    coordScroll.Size, coordScroll.Position = UDim2.new(1, -12, 1, -29), UDim2.new(0, 6, 0, 28)
    coordScroll.BackgroundTransparency, coordScroll.BorderSizePixel, coordScroll.ScrollBarThickness, coordScroll.Visible, coordScroll.ClipsDescendants = 1, 0, 3, false, true
    local coordLayout = Instance.new("UIListLayout", coordScroll)
    coordLayout.SortOrder, coordLayout.Padding, coordLayout.HorizontalAlignment = Enum.SortOrder.LayoutOrder, UDim.new(0, 5), Enum.HorizontalAlignment.Center
    local coordPad = Instance.new("UIPadding", coordScroll)
    coordPad.PaddingLeft, coordPad.PaddingRight, coordPad.PaddingTop = UDim.new(0,4), UDim.new(0,10), UDim.new(0,4)
    Track(coordLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        coordScroll.CanvasSize = UDim2.new(0, 0, 0, coordLayout.AbsoluteContentSize.Y + 20)
    end))

    local tabBtn = Instance.new("TextButton", SidebarScroll)
    tabBtn.LayoutOrder, tabBtn.Size, tabBtn.BackgroundColor3 = 1, UDim2.new(1, 0, 0, 26), Color3.fromRGB(70,15,50)
    tabBtn.BackgroundTransparency, tabBtn.Text = 0, " 📍 TOẠ ĐỘ V.V"
    tabBtn.TextColor3, tabBtn.TextSize, tabBtn.Font = Color3.fromRGB(255,255,255), 8, Enum.Font.Gotham
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    Corner(tabBtn); RegTheme(tabBtn, "Primary")
    local ind = Instance.new("Frame", tabBtn)
    ind.Size, ind.Position, ind.BackgroundColor3, ind.BorderSizePixel, ind.Visible = UDim2.new(0, 3, 0, 12), UDim2.new(0, 0, 0.5, -6), Color3.fromRGB(255,105,180), 0, false
    Corner(ind, UDim.new(0, 2))
    Track(tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Container.Visible = false; if t.Indicator then t.Indicator.Visible = false end end
        coordScroll.Visible, ind.Visible = true, true
        ActiveTabTitle.Text = "📍 TOẠ ĐỘ V.V"
    end))
    table.insert(Tabs, {Container = coordScroll, Indicator = ind})

    local toggleBtn = Instance.new("TextButton", coordScroll)
    toggleBtn.LayoutOrder, toggleBtn.Size, toggleBtn.BackgroundColor3 = 1, UDim2.new(1, 0, 0, 34), Color3.fromRGB(55,12,40)
    toggleBtn.BackgroundTransparency, toggleBtn.Text = 0, " → TOẠ ĐỘ"
    toggleBtn.TextColor3, toggleBtn.TextSize, toggleBtn.Font = Color3.fromRGB(255,255,255), 10, Enum.Font.GothamBold
    toggleBtn.TextXAlignment = Enum.TextXAlignment.Center
    Corner(toggleBtn); Stroke(toggleBtn); RegTheme(toggleBtn, "Secondary")
    local content = Instance.new("Frame", coordScroll)
    content.LayoutOrder, content.Size, content.AutomaticSize, content.BackgroundTransparency, content.Visible = 2, UDim2.new(1, 0, 0, 0), Enum.AutomaticSize.Y, 1, false
    local contentL = Instance.new("UIListLayout", content)
    contentL.SortOrder, contentL.Padding, contentL.HorizontalAlignment = Enum.SortOrder.LayoutOrder, UDim.new(0, 5), Enum.HorizontalAlignment.Center
    Track(toggleBtn.MouseButton1Click:Connect(function()
        content.Visible = not content.Visible
        toggleBtn.Text = content.Visible and " ↓ TOẠ ĐỘ" or " → TOẠ ĐỘ"
    end))

    local function MoveToPoint(boxX, boxY, boxZ)
        local char = localPlayer.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local targetPos = Vector3.new(tonumber(boxX.Text) or 0, tonumber(boxY.Text) or 0, tonumber(boxZ.Text) or 0)
        if CoordState.CurrentTween then CoordState.CurrentTween:Cancel(); hrp.Anchored = false; CoordState.CurrentTween = nil end
        if CoordState.TeleportMode then hrp.CFrame = CFrame.new(targetPos)
        else
            hrp.Anchored = true
            local tw = TweenService:Create(hrp, TweenInfo.new(math.clamp((targetPos - hrp.Position).Magnitude / CoordState.Speed, 0.1, 30), Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = CFrame.new(targetPos)})
            CoordState.CurrentTween = tw; tw.Completed:Connect(function() hrp.Anchored = false; CoordState.CurrentTween = nil end); tw:Play()
        end
    end

    local posDisplay = Instance.new("Frame", content)
    posDisplay.LayoutOrder, posDisplay.Size, posDisplay.BackgroundColor3 = 1, UDim2.new(1, 0, 0, 48), Color3.fromRGB(70,15,50)
    posDisplay.BackgroundTransparency = 0
    Corner(posDisplay); Stroke(posDisplay); RegTheme(posDisplay, "Primary")
    local posTitle = Instance.new("TextLabel", posDisplay)
    posTitle.Size, posTitle.Position, posTitle.BackgroundTransparency, posTitle.Text = UDim2.new(1, -12, 0, 14), UDim2.new(0, 6, 0, 2), 1, "📌 Vị trí hiện tại"
    posTitle.TextColor3, posTitle.TextSize, posTitle.Font = Color3.fromRGB(0,200,255), 8, Enum.Font.GothamBold
    posTitle.TextXAlignment = Enum.TextXAlignment.Left
    local posLabel = Instance.new("TextLabel", posDisplay)
    posLabel.Size, posLabel.Position, posLabel.BackgroundTransparency, posLabel.Text = UDim2.new(1, -12, 0, 26), UDim2.new(0, 6, 0, 18), 1, "X: -- | Y: -- | Z: --"
    posLabel.TextColor3, posLabel.TextSize, posLabel.Font = Color3.fromRGB(255,255,255), 10, Enum.Font.Code
    posLabel.TextXAlignment = Enum.TextXAlignment.Left
    Track(RunService.RenderStepped:Connect(function()
        if not coordScroll.Visible or not content.Visible then return end
        local char = localPlayer.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then local pos = hrp.Position; posLabel.Text = string.format("X: %.1f | Y: %.1f | Z: %.1f", pos.X, pos.Y, pos.Z) end
    end))

    CoordPoints = {}
    local selectedPasteTarget = nil
    local pasteDropdownBtn, pasteDropList
    RefreshPointsDropdown = function()
        if not pasteDropList or not pasteDropdownBtn or not pasteDropList.Parent then return end
        for _, c in ipairs(pasteDropList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        local stillExists = false
        for _, p in ipairs(CoordPoints) do if p == selectedPasteTarget then stillExists = true; break end end
        if not stillExists then selectedPasteTarget = CoordPoints[1] end
        if selectedPasteTarget then pasteDropdownBtn.Text = " 📌 Dán vào: " .. selectedPasteTarget.name else pasteDropdownBtn.Text = " 📌 Dán vào: (trống)" end
        for i, p in ipairs(CoordPoints) do
            local btn = Instance.new("TextButton", pasteDropList)
            btn.LayoutOrder, btn.Size, btn.BackgroundColor3 = i, UDim2.new(1, 0, 0, 22), Color3.fromRGB(90,25,65)
            btn.BackgroundTransparency, btn.Text, btn.TextColor3, btn.TextSize = 0, " " .. p.name, Color3.fromRGB(255,255,255), 8
            btn.Font, btn.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
            Corner(btn, UDim.new(0, 4)); Stroke(btn); RegTheme(btn, "DropItem")
            local capturedP = p
            Track(btn.MouseButton1Click:Connect(function()
                selectedPasteTarget = capturedP
                pasteDropdownBtn.Text = " 📌 Dán vào: " .. capturedP.name
                pasteDropList.Visible = false
            end))
        end
        pasteDropList.CanvasSize = UDim2.new(0, 0, 0, #CoordPoints * 25 + 10)
    end

    local pointsContainer = Instance.new("Frame", content)
    pointsContainer.LayoutOrder, pointsContainer.Size, pointsContainer.AutomaticSize = 2, UDim2.new(1, 0, 0, 0), Enum.AutomaticSize.Y
    pointsContainer.BackgroundTransparency = 1
    local pcLayout = Instance.new("UIListLayout", pointsContainer)
    pcLayout.SortOrder, pcLayout.Padding, pcLayout.HorizontalAlignment = Enum.SortOrder.LayoutOrder, UDim.new(0, 5), Enum.HorizontalAlignment.Center

    CreateCoordPoint = function(name, defX, defY, defZ)
        local f = Instance.new("Frame", pointsContainer)
        f.LayoutOrder, f.Size, f.BackgroundColor3 = #CoordPoints + 1, UDim2.new(1, 0, 0, 70), Color3.fromRGB(70,15,50)
        f.BackgroundTransparency = 0
        Corner(f); Stroke(f); RegTheme(f, "Primary")
        local title = Instance.new("TextLabel", f)
        title.Size, title.Position, title.BackgroundTransparency, title.Text = UDim2.new(1, -30, 0, 14), UDim2.new(0, 6, 0, 2), 1, "📍 " .. name
        title.TextColor3, title.TextSize, title.Font = Color3.fromRGB(255,180,100), 8, Enum.Font.GothamBold
        title.TextXAlignment, title.TextTruncate = Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd
        local delPointBtn = Instance.new("TextButton", f)
        delPointBtn.Size, delPointBtn.Position, delPointBtn.BackgroundColor3 = UDim2.new(0, 18, 0, 14), UDim2.new(1, -22, 0, 2), Color3.fromRGB(150, 30, 30)
        delPointBtn.BackgroundTransparency, delPointBtn.Text, delPointBtn.TextColor3, delPointBtn.TextSize, delPointBtn.Font = 0, "✕", Color3.fromRGB(255,255,255), 8, Enum.Font.GothamBold
        Corner(delPointBtn, UDim.new(0, 3)); Stroke(delPointBtn)
        local function CreateInput(scaleX, defVal, axis)
            local box = Instance.new("TextBox", f)
            box.Size, box.Position, box.BackgroundColor3 = UDim2.new(0.3, 0, 0, 20), UDim2.new(scaleX, 0, 0, 18), Color3.fromRGB(12,12,17)
            box.BackgroundTransparency, box.Text, box.TextColor3, box.PlaceholderText = 0, tostring(defVal), Color3.fromRGB(255,255,255), axis
            box.PlaceholderColor3, box.TextSize, box.Font = Color3.fromRGB(150,155,165), 8, Enum.Font.Code
            box.ClearTextOnFocus = false
            Corner(box, UDim.new(0, 4)); Stroke(box); RegTheme(box, "Input")
            return box
        end
        local boxX, boxY, boxZ = CreateInput(0.02, defX, "X"), CreateInput(0.35, defY, "Y"), CreateInput(0.68, defZ, "Z")
        local goBtn = Instance.new("TextButton", f)
        goBtn.Size, goBtn.Position, goBtn.BackgroundColor3 = UDim2.new(0.96, 0, 0, 22), UDim2.new(0.02, 0, 0, 42), Color3.fromRGB(55,12,40)
        goBtn.BackgroundTransparency, goBtn.Text, goBtn.TextColor3, goBtn.TextSize, goBtn.Font = 0, "→ ĐI " .. name, Color3.fromRGB(255,255,255), 8, Enum.Font.GothamBold
        Corner(goBtn); Stroke(goBtn); RegTheme(goBtn, "Secondary")
        local pointData = { name = name, frame = f, boxX = boxX, boxY = boxY, boxZ = boxZ }
        Track(goBtn.MouseButton1Click:Connect(function() MoveToPoint(boxX, boxY, boxZ) end))
        Track(delPointBtn.MouseButton1Click:Connect(function()
            if #CoordPoints <= 1 then return end
            for i, p in ipairs(CoordPoints) do if p == pointData then table.remove(CoordPoints, i); f:Destroy(); break end end
            for i, p in ipairs(CoordPoints) do p.frame.LayoutOrder = i end
            RefreshPointsDropdown()
        end))
        table.insert(CoordPoints, pointData)
        return pointData
    end

    CreateCoordPoint("Điểm 1", 3384.41, 70.27, -350.64)
    CreateCoordPoint("Điểm 2", 523.90, 70.27, -359.41)

    local addPointFrame = Instance.new("Frame", content)
    addPointFrame.LayoutOrder, addPointFrame.Size, addPointFrame.AutomaticSize, addPointFrame.BackgroundColor3 = 3, UDim2.new(1, 0, 0, 0), Enum.AutomaticSize.Y, Color3.fromRGB(70,15,50)
    addPointFrame.BackgroundTransparency = 0
    Corner(addPointFrame); Stroke(addPointFrame); RegTheme(addPointFrame, "Primary")
    local apL = Instance.new("UIListLayout", addPointFrame)
    apL.SortOrder, apL.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 4)
    local apPad = Instance.new("UIPadding", addPointFrame)
    apPad.PaddingLeft, apPad.PaddingRight, apPad.PaddingTop, apPad.PaddingBottom = UDim.new(0, 6), UDim.new(0, 6), UDim.new(0, 4), UDim.new(0, 4)
    local addTitle = Instance.new("TextLabel", addPointFrame)
    addTitle.LayoutOrder, addTitle.Size, addTitle.BackgroundTransparency, addTitle.Text = 1, UDim2.new(1, 0, 0, 14), 1, "➕ Thêm điểm mới"
    addTitle.TextColor3, addTitle.TextSize, addTitle.Font = Color3.fromRGB(0,200,255), 8, Enum.Font.GothamBold
    addTitle.TextXAlignment = Enum.TextXAlignment.Left
    local apRow = Instance.new("Frame", addPointFrame)
    apRow.LayoutOrder, apRow.Size, apRow.BackgroundTransparency = 2, UDim2.new(1, 0, 0, 22), 1
    local addInput = Instance.new("TextBox", apRow)
    addInput.Size, addInput.Position, addInput.BackgroundColor3 = UDim2.new(0.63, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(12,12,17)
    addInput.BackgroundTransparency, addInput.PlaceholderText, addInput.Text = 0, "Tên điểm...", ""
    addInput.PlaceholderColor3, addInput.TextColor3, addInput.TextSize, addInput.Font = Color3.fromRGB(150,155,165), Color3.fromRGB(255,255,255), 8, Enum.Font.Gotham
    addInput.ClearTextOnFocus = false
    Corner(addInput, UDim.new(0, 4)); Stroke(addInput); RegTheme(addInput, "Input")
    local addBtn = Instance.new("TextButton", apRow)
    addBtn.Size, addBtn.Position, addBtn.BackgroundColor3 = UDim2.new(0.32, 0, 1, 0), UDim2.new(0.66, 0, 0, 0), Color3.fromRGB(55,12,40)
    addBtn.BackgroundTransparency, addBtn.Text, addBtn.TextColor3, addBtn.TextSize, addBtn.Font = 0, "➕ Thêm", Color3.fromRGB(255,255,255), 8, Enum.Font.GothamBold
    Corner(addBtn); Stroke(addBtn); RegTheme(addBtn, "Secondary")
    Track(addBtn.MouseButton1Click:Connect(function()
        if #CoordPoints >= 10 then return end
        local rawName = addInput.Text == "" and "Điểm " .. (#CoordPoints + 1) or addInput.Text
        local existing, finalName = {}, rawName
        for _, p in ipairs(CoordPoints) do existing[p.name] = true end
        if existing[finalName] then
            local i = 2
            while existing[rawName .. " (" .. i .. ")"] do i = i + 1 end
            finalName = rawName .. " (" .. i .. ")"
        end
        local cx, cy, cz = 0, 0, 0
        local char = localPlayer.Character
        if char then local hrp = char:FindFirstChild("HumanoidRootPart"); if hrp then cx, cy, cz = hrp.Position.X, hrp.Position.Y, hrp.Position.Z end end
        CreateCoordPoint(finalName, cx, cy, cz); addInput.Text = ""; RefreshPointsDropdown()
    end))

    local pasteFrame = Instance.new("Frame", content)
    pasteFrame.LayoutOrder, pasteFrame.Size, pasteFrame.AutomaticSize, pasteFrame.BackgroundColor3 = 4, UDim2.new(1, 0, 0, 0), Enum.AutomaticSize.Y, Color3.fromRGB(70,15,50)
    pasteFrame.BackgroundTransparency = 0
    Corner(pasteFrame); Stroke(pasteFrame); RegTheme(pasteFrame, "Primary")
    local pfL = Instance.new("UIListLayout", pasteFrame)
    pfL.SortOrder, pfL.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 4)
    local pfPad = Instance.new("UIPadding", pasteFrame)
    pfPad.PaddingLeft, pfPad.PaddingRight, pfPad.PaddingTop, pfPad.PaddingBottom = UDim.new(0, 6), UDim.new(0, 6), UDim.new(0, 4), UDim.new(0, 4)
    local pasteTitle = Instance.new("TextLabel", pasteFrame)
    pasteTitle.LayoutOrder, pasteTitle.Size, pasteTitle.BackgroundTransparency, pasteTitle.Text = 1, UDim2.new(1, 0, 0, 14), 1, "📋 Dán toạ độ hiện tại"
    pasteTitle.TextColor3, pasteTitle.TextSize, pasteTitle.Font = Color3.fromRGB(0,200,255), 8, Enum.Font.GothamBold
    pasteTitle.TextXAlignment = Enum.TextXAlignment.Left
    local pfRow = Instance.new("Frame", pasteFrame)
    pfRow.LayoutOrder, pfRow.Size, pfRow.BackgroundTransparency = 2, UDim2.new(1, 0, 0, 22), 1
    pasteDropdownBtn = Instance.new("TextButton", pfRow)
    pasteDropdownBtn.Size, pasteDropdownBtn.Position, pasteDropdownBtn.BackgroundColor3 = UDim2.new(0.6, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(12,12,17)
    pasteDropdownBtn.BackgroundTransparency, pasteDropdownBtn.Text = 0, " 📌 Dán vào: ..."
    pasteDropdownBtn.TextColor3, pasteDropdownBtn.TextSize, pasteDropdownBtn.Font = Color3.fromRGB(255,255,255), 8, Enum.Font.Gotham
    pasteDropdownBtn.TextXAlignment, pasteDropdownBtn.TextTruncate = Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd
    Corner(pasteDropdownBtn, UDim.new(0, 4)); Stroke(pasteDropdownBtn); RegTheme(pasteDropdownBtn, "Input")
    local pasteBtn = Instance.new("TextButton", pfRow)
    pasteBtn.Size, pasteBtn.Position, pasteBtn.BackgroundColor3 = UDim2.new(0.35, 0, 1, 0), UDim2.new(0.63, 0, 0, 0), Color3.fromRGB(50, 150, 50)
    pasteBtn.BackgroundTransparency, pasteBtn.Text, pasteBtn.TextColor3, pasteBtn.TextSize, pasteBtn.Font = 0, "📋 Dán", Color3.fromRGB(255,255,255), 8, Enum.Font.GothamBold
    Corner(pasteBtn); Stroke(pasteBtn)
    Track(pasteBtn.MouseButton1Click:Connect(function()
        if not selectedPasteTarget then return end
        local char = localPlayer.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local pos = hrp.Position
        selectedPasteTarget.boxX.Text, selectedPasteTarget.boxY.Text, selectedPasteTarget.boxZ.Text = string.format("%.2f", pos.X), string.format("%.2f", pos.Y), string.format("%.2f", pos.Z)
        pasteBtn.Text = " ✅ Đã dán!"; task.delay(1.2, function() if pasteBtn.Parent then pasteBtn.Text = "📋 Dán" end end)
    end))

    pasteDropList = Instance.new("ScrollingFrame", content)
    pasteDropList.LayoutOrder, pasteDropList.Size, pasteDropList.BackgroundColor3 = 5, UDim2.new(1, 0, 0, 95), Color3.fromRGB(80,20,60)
    pasteDropList.BackgroundTransparency, pasteDropList.CanvasSize, pasteDropList.ScrollBarThickness, pasteDropList.Visible = 0, UDim2.new(0,0,0,0), 3, false
    Corner(pasteDropList); Stroke(pasteDropList); RegTheme(pasteDropList, "DropFrame")
    local pdL = Instance.new("UIListLayout", pasteDropList)
    pdL.Padding = UDim.new(0, 3)
    local pdPad = Instance.new("UIPadding", pasteDropList)
    pdPad.PaddingRight, pdPad.PaddingTop, pdPad.PaddingLeft = UDim.new(0, 8), UDim.new(0, 4), UDim.new(0, 4)
    Track(pasteDropdownBtn.MouseButton1Click:Connect(function()
        RefreshPointsDropdown(); pasteDropList.Visible = not pasteDropList.Visible
    end))

    local teleportToggleFrame
    teleportToggleFrame, teleportToggleBtn, teleportToggleDot = CreateToggle(content, 6, "⚡ Chế độ Teleport (Tắt = Bay mượt)",
        function() return CoordState.TeleportMode end, function(v) CoordState.TeleportMode = v end)

    local speedSliderFrame
    speedSliderFrame, speedBarFill, speedValLbl = CreateSlider(content, 7, "🕊️ Tốc độ bay (Studs/s)", 10, 1000,
        function() return CoordState.Speed end, function(v) CoordState.Speed = v end)

    local stopFlyBtn = Instance.new("TextButton", content)
    stopFlyBtn.LayoutOrder, stopFlyBtn.Size, stopFlyBtn.BackgroundColor3 = 8, UDim2.new(1, 0, 0, 34), Color3.fromRGB(180, 30, 30)
    stopFlyBtn.BackgroundTransparency, stopFlyBtn.Text, stopFlyBtn.TextColor3, stopFlyBtn.TextSize, stopFlyBtn.Font = 0, "🛑 DỪNG BAY NGAY", Color3.fromRGB(255,255,255), 10, Enum.Font.GothamBold
    Corner(stopFlyBtn); Stroke(stopFlyBtn, Color3.fromRGB(255, 60, 60))
    Track(stopFlyBtn.MouseButton1Click:Connect(function()
        if CoordState.CurrentTween then CoordState.CurrentTween:Cancel(); CoordState.CurrentTween = nil end
        local char = localPlayer.Character; if char then local hrp = char:FindFirstChild("HumanoidRootPart"); if hrp then hrp.Anchored = false end end
    end))
    RefreshPointsDropdown()
end

-- TAB MISC
do
    local miscScroll = Instance.new("ScrollingFrame", ContentContainer)
    miscScroll.Size, miscScroll.Position = UDim2.new(1, -12, 1, -29), UDim2.new(0, 6, 0, 28)
    miscScroll.BackgroundTransparency, miscScroll.BorderSizePixel, miscScroll.ScrollBarThickness, miscScroll.Visible, miscScroll.ClipsDescendants = 1, 0, 3, false, true
    local miscLayout = Instance.new("UIListLayout", miscScroll)
    miscLayout.SortOrder, miscLayout.Padding, miscLayout.HorizontalAlignment = Enum.SortOrder.LayoutOrder, UDim.new(0, 5), Enum.HorizontalAlignment.Center
    local miscPad = Instance.new("UIPadding", miscScroll)
    miscPad.PaddingLeft, miscPad.PaddingRight, miscPad.PaddingTop = UDim.new(0,4), UDim.new(0,10), UDim.new(0,4)
    Track(miscLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        miscScroll.CanvasSize = UDim2.new(0, 0, 0, miscLayout.AbsoluteContentSize.Y + 15)
    end))

    local tabBtn = Instance.new("TextButton", SidebarScroll)
    tabBtn.LayoutOrder, tabBtn.Size, tabBtn.BackgroundColor3 = 2, UDim2.new(1, 0, 0, 26), Color3.fromRGB(70,15,50)
    tabBtn.BackgroundTransparency, tabBtn.Text = 0, " ⚙️ MISC"
    tabBtn.TextColor3, tabBtn.TextSize, tabBtn.Font = Color3.fromRGB(255,255,255), 8, Enum.Font.Gotham
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    Corner(tabBtn); RegTheme(tabBtn, "Primary")
    local ind = Instance.new("Frame", tabBtn)
    ind.Size, ind.Position, ind.BackgroundColor3, ind.BorderSizePixel, ind.Visible = UDim2.new(0, 3, 0, 12), UDim2.new(0, 0, 0.5, -6), Color3.fromRGB(255,105,180), 0, false
    Corner(ind, UDim.new(0, 2))
    Track(tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Container.Visible = false; if t.Indicator then t.Indicator.Visible = false end end
        miscScroll.Visible, ind.Visible = true, true
        ActiveTabTitle.Text = "⚙️ MISC"
    end))
    table.insert(Tabs, {Container = miscScroll, Indicator = ind})

    local musicToggleBtn = Instance.new("TextButton", miscScroll)
    musicToggleBtn.LayoutOrder, musicToggleBtn.Size, musicToggleBtn.BackgroundColor3 = 1, UDim2.new(1, 0, 0, 34), Color3.fromRGB(55,12,40)
    musicToggleBtn.BackgroundTransparency, musicToggleBtn.Text = 0, " ↓ âm nhạc"
    musicToggleBtn.TextColor3, musicToggleBtn.TextSize, musicToggleBtn.Font = Color3.fromRGB(255,255,255), 10, Enum.Font.GothamBold
    musicToggleBtn.TextXAlignment = Enum.TextXAlignment.Center
    Corner(musicToggleBtn); Stroke(musicToggleBtn); RegTheme(musicToggleBtn, "Secondary")
    local musicContainer = Instance.new("Frame", miscScroll)
    musicContainer.LayoutOrder, musicContainer.Size, musicContainer.AutomaticSize, musicContainer.BackgroundTransparency, musicContainer.Visible = 2, UDim2.new(1, 0, 0, 0), Enum.AutomaticSize.Y, 1, true
    local muLayout = Instance.new("UIListLayout", musicContainer)
    muLayout.SortOrder, muLayout.Padding, muLayout.HorizontalAlignment = Enum.SortOrder.LayoutOrder, UDim.new(0, 4), Enum.HorizontalAlignment.Center
    Track(musicToggleBtn.MouseButton1Click:Connect(function()
        musicContainer.Visible = not musicContainer.Visible
        musicToggleBtn.Text = musicContainer.Visible and " ↓ âm nhạc" or " → âm nhạc"
    end))

    HubSound = Instance.new("Sound", SoundService)
    HubSound.Name, HubSound.Looped, HubSound.Volume = "VzNamHubSound", true, State.Volume
    HubSound.SoundId = "rbxassetid://" .. State.SoundId

    local customIdBox = Instance.new("TextBox", musicContainer)
    customIdBox.LayoutOrder, customIdBox.Size, customIdBox.BackgroundColor3 = 1, UDim2.new(1, 0, 0, 26), Color3.fromRGB(70,15,50)
    customIdBox.BackgroundTransparency, customIdBox.PlaceholderText, customIdBox.Text = 0, "🎶 Nhập Sound ID...", ""
    customIdBox.TextColor3, customIdBox.TextSize, customIdBox.Font = Color3.fromRGB(255,255,255), 9, Enum.Font.Gotham
    Corner(customIdBox); Stroke(customIdBox); RegTheme(customIdBox, "Input")
    local musicDropBtn = Instance.new("TextButton", musicContainer)
    musicDropBtn.LayoutOrder, musicDropBtn.Size, musicDropBtn.BackgroundColor3 = 2, UDim2.new(1, 0, 0, 26), Color3.fromRGB(70,15,50)
    musicDropBtn.BackgroundTransparency, musicDropBtn.Text, musicDropBtn.TextColor3, musicDropBtn.TextSize, musicDropBtn.Font = 0, " 🎵 Chọn Nhạc...", Color3.fromRGB(255,255,255), 9, Enum.Font.Gotham
    musicDropBtn.TextXAlignment = Enum.TextXAlignment.Left
    Corner(musicDropBtn); Stroke(musicDropBtn); RegTheme(musicDropBtn, "Primary")
    local musicDropList = Instance.new("ScrollingFrame", musicContainer)
    musicDropList.LayoutOrder, musicDropList.Size, musicDropList.BackgroundColor3 = 3, UDim2.new(1, 0, 0, 95), Color3.fromRGB(80,20,60)
    musicDropList.BackgroundTransparency, musicDropList.CanvasSize, musicDropList.ScrollBarThickness, musicDropList.Visible = 0, UDim2.new(0,0,0,0), 3, false
    Corner(musicDropList); Stroke(musicDropList); RegTheme(musicDropList, "DropFrame")
    local musicListLayout = Instance.new("UIListLayout", musicDropList)
    musicListLayout.Padding = UDim.new(0, 3)
    Instance.new("UIPadding", musicDropList).PaddingRight = UDim.new(0, 8)
    local presetMusics = {
        {Name = "🎵 Chill Lofi", Id = "1837879082"}, {Name = "🎶 Phonk Beat", Id = "1843404008"},
        {Name = "🎵 Anime Relax", Id = "9043887091"}, {Name = "🎶 EDM Hype", Id = "1837871000"},
        {Name = "🎶 Như Một Người Dưng",Id = "91897652967267"},
    }
    for i, m in ipairs(presetMusics) do
        local btn = Instance.new("TextButton", musicDropList)
        btn.LayoutOrder, btn.Size, btn.BackgroundColor3 = i, UDim2.new(1, 0, 0, 22), Color3.fromRGB(90,25,65)
        btn.BackgroundTransparency, btn.Text, btn.TextColor3, btn.TextSize = 0, " " .. m.Name, Color3.fromRGB(255,255,255), 9
        btn.Font, btn.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
        Corner(btn, UDim.new(0, 4)); Stroke(btn); RegTheme(btn, "DropItem")
        Track(btn.MouseButton1Click:Connect(function()
            State.SoundId = m.Id; musicDropBtn.Text = " 🎵 " .. m.Name; musicDropList.Visible = false
            if HubSound.IsPlaying then HubSound.SoundId = "rbxassetid://" .. State.SoundId; HubSound:Play() end
        end))
    end
    musicDropList.CanvasSize = UDim2.new(0, 0, 0, #presetMusics * 25)
    Track(musicDropBtn.MouseButton1Click:Connect(function() musicDropList.Visible = not musicDropList.Visible end))

    local volumeFrame = Instance.new("Frame", musicContainer)
    volumeFrame.LayoutOrder, volumeFrame.Size, volumeFrame.BackgroundColor3 = 4, UDim2.new(1, 0, 0, 26), Color3.fromRGB(70,15,50)
    volumeFrame.BackgroundTransparency = 0
    Corner(volumeFrame); Stroke(volumeFrame); RegTheme(volumeFrame, "Primary")
    volumeLabel = Instance.new("TextLabel", volumeFrame)
    volumeLabel.Size, volumeLabel.Position, volumeLabel.BackgroundTransparency, volumeLabel.Text = UDim2.new(1, -8, 1, 0), UDim2.new(0, 5, 0, 0), 1, "🔊 Vol: 50%"
    volumeLabel.TextColor3, volumeLabel.TextSize, volumeLabel.Font = Color3.fromRGB(255,255,255), 9, Enum.Font.GothamBold
    volumeLabel.TextXAlignment = Enum.TextXAlignment.Left
    local volumeBarBg = Instance.new("Frame", volumeFrame)
    volumeBarBg.Size, volumeBarBg.Position, volumeBarBg.BackgroundColor3 = UDim2.new(0, 80, 0, 8), UDim2.new(1, -86, 0.5, -4), Color3.fromRGB(90,25,65)
    Corner(volumeBarBg, UDim.new(1, 0)); Stroke(volumeBarBg); RegTheme(volumeBarBg, "DropItem")
    volumeBarFill = Instance.new("Frame", volumeBarBg)
    volumeBarFill.Size, volumeBarFill.BackgroundColor3 = UDim2.new(0.5, 0, 1, 0), Color3.fromRGB(0,180,255)
    Corner(volumeBarFill, UDim.new(1, 0))
    local volumeBtn = Instance.new("TextButton", volumeBarBg)
    volumeBtn.Size, volumeBtn.BackgroundTransparency, volumeBtn.Text = UDim2.new(1, 10, 1, 10), 1, ""
    local adjustingVol = false
    Track(volumeBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then adjustingVol = true end end))
    Track(UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then adjustingVol = false end end))
    Track(UserInputService.InputChanged:Connect(function(input)
        if adjustingVol and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local p = math.clamp((input.Position.X - volumeBarBg.AbsolutePosition.X) / volumeBarBg.AbsoluteSize.X, 0, 1)
            volumeBarFill.Size = UDim2.new(p, 0, 1, 0); State.Volume = p; HubSound.Volume = p
            volumeLabel.Text = "🔊 Vol: " .. math.floor(p * 100) .. "%"
        end
    end))

    local musicPlayFrame = Instance.new("Frame", musicContainer)
    musicPlayFrame.LayoutOrder, musicPlayFrame.Size, musicPlayFrame.BackgroundColor3 = 5, UDim2.new(1, 0, 0, 30), Color3.fromRGB(70,15,50)
    musicPlayFrame.BackgroundTransparency = 0
    Corner(musicPlayFrame); Stroke(musicPlayFrame); RegTheme(musicPlayFrame, "Primary")
    local musicTitleLbl = Instance.new("TextLabel", musicPlayFrame)
    musicTitleLbl.Size, musicTitleLbl.Position, musicTitleLbl.BackgroundTransparency, musicTitleLbl.Text = UDim2.new(1, -40, 1, 0), UDim2.new(0, 5, 0, 0), 1, "Phát Nhạc Nền"
    musicTitleLbl.TextColor3, musicTitleLbl.TextSize, musicTitleLbl.Font = Color3.fromRGB(255,255,255), 9, Enum.Font.GothamBold
    musicTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    local toggleMusicBtn = Instance.new("TextButton", musicPlayFrame)
    toggleMusicBtn.Size, toggleMusicBtn.Position, toggleMusicBtn.BackgroundColor3 = UDim2.new(0, 30, 0, 15), UDim2.new(1, -34, 0.5, -7.5), Color3.fromRGB(60,65,75)
    toggleMusicBtn.Text = ""
    Corner(toggleMusicBtn, UDim.new(1, 0)); Stroke(toggleMusicBtn)
    local musicDot = Instance.new("Frame", toggleMusicBtn)
    musicDot.Size, musicDot.Position, musicDot.BackgroundColor3 = UDim2.new(0, 11, 0, 11), UDim2.new(0, 2, 0.5, -5.5), Color3.fromRGB(255,255,255)
    Corner(musicDot, UDim.new(1, 0))
    local isMusicPlaying = false
    Track(toggleMusicBtn.MouseButton1Click:Connect(function()
        isMusicPlaying = not isMusicPlaying
        if isMusicPlaying then
            toggleMusicBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50); musicDot.Position = UDim2.new(1, -13, 0.5, -5.5)
            HubSound.SoundId = "rbxassetid://" .. (tonumber(customIdBox.Text) and tostring(tonumber(customIdBox.Text)) or State.SoundId); HubSound:Play()
        else
            toggleMusicBtn.BackgroundColor3 = Color3.fromRGB(60, 65, 75); musicDot.Position = UDim2.new(0, 2, 0.5, -5.5); HubSound:Stop()
        end
    end))

    local menuColorToggleBtn = Instance.new("TextButton", miscScroll)
    menuColorToggleBtn.LayoutOrder, menuColorToggleBtn.Size, menuColorToggleBtn.BackgroundColor3 = 3, UDim2.new(1, 0, 0, 34), Color3.fromRGB(55,12,40)
    menuColorToggleBtn.BackgroundTransparency, menuColorToggleBtn.Text = 0, " ↓ màu menu"
    menuColorToggleBtn.TextColor3, menuColorToggleBtn.TextSize, menuColorToggleBtn.Font = Color3.fromRGB(255,255,255), 10, Enum.Font.GothamBold
    menuColorToggleBtn.TextXAlignment = Enum.TextXAlignment.Center
    Corner(menuColorToggleBtn); Stroke(menuColorToggleBtn); RegTheme(menuColorToggleBtn, "Secondary")
    local menuColorContainer = Instance.new("Frame", miscScroll)
    menuColorContainer.LayoutOrder, menuColorContainer.Size, menuColorContainer.AutomaticSize, menuColorContainer.BackgroundTransparency, menuColorContainer.Visible = 4, UDim2.new(1, 0, 0, 0), Enum.AutomaticSize.Y, 1, true
    local mcLayout = Instance.new("UIListLayout", menuColorContainer)
    mcLayout.SortOrder, mcLayout.Padding, mcLayout.HorizontalAlignment = Enum.SortOrder.LayoutOrder, UDim.new(0, 4), Enum.HorizontalAlignment.Center
    Track(menuColorToggleBtn.MouseButton1Click:Connect(function()
        menuColorContainer.Visible = not menuColorContainer.Visible
        menuColorToggleBtn.Text = menuColorContainer.Visible and " ↓ màu menu" or " → màu menu"
    end))

    local themeDropBtn = Instance.new("TextButton", menuColorContainer)
    themeDropBtn.LayoutOrder, themeDropBtn.Size, themeDropBtn.BackgroundColor3 = 1, UDim2.new(1, 0, 0, 26), Color3.fromRGB(70,15,50)
    themeDropBtn.BackgroundTransparency, themeDropBtn.Text, themeDropBtn.TextColor3, themeDropBtn.TextSize = 0, " 🎨 Theme: 🌊 Xanh Đại Dương", Color3.fromRGB(255,255,255), 9
    themeDropBtn.Font, themeDropBtn.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
    Corner(themeDropBtn); Stroke(themeDropBtn); RegTheme(themeDropBtn, "Primary")
    local themeDropList = Instance.new("ScrollingFrame", menuColorContainer)
    themeDropList.LayoutOrder, themeDropList.Size, themeDropList.BackgroundColor3 = 2, UDim2.new(1, 0, 0, 95), Color3.fromRGB(80,20,60)
    themeDropList.BackgroundTransparency, themeDropList.CanvasSize, themeDropList.ScrollBarThickness, themeDropList.Visible = 0, UDim2.new(0,0,0,0), 3, false
    Corner(themeDropList); Stroke(themeDropList); RegTheme(themeDropList, "DropFrame")
    local themeListLayout = Instance.new("UIListLayout", themeDropList)
    themeListLayout.Padding = UDim.new(0, 3)
    Instance.new("UIPadding", themeDropList).PaddingRight = UDim.new(0, 8)
    local menuThemeList = {
        {Name = "🌸 Hồng Pastel", Bg = Color3.fromRGB(70, 15, 50)}, {Name = "🌙 Đêm Đen Sâu", Bg = Color3.fromRGB(15, 16, 22)},
        {Name = "🔥 Đỏ Lửa", Bg = Color3.fromRGB(70, 10, 15)}, {Name = "🌊 Xanh Đại Dương", Bg = Color3.fromRGB(10, 22, 50)},
    }
    -- [FIX] gán vào biến đã khai báo ở ngoài (không dùng "local function")
    ApplyTheme = function(newBaseColor)
        State.ThemeBase = newBaseColor
        local primary, secondary = newBaseColor:Lerp(Color3.new(1,1,1), 0.08), newBaseColor:Lerp(Color3.new(1,1,1), 0.15)
        local dropFrame, dropItem = newBaseColor:Lerp(Color3.new(1,1,1), 0.2), newBaseColor:Lerp(Color3.new(1,1,1), 0.3)
        local input = newBaseColor:Lerp(Color3.new(0,0,0), 0.4)
        SidebarPanel.BackgroundColor3, ContentContainer.BackgroundColor3 = newBaseColor, newBaseColor
        for _, item in ipairs(ThemedElements) do
            local el = item.Element
            if el and el.Parent then
                if item.Type == "Primary" then el.BackgroundColor3 = primary
                elseif item.Type == "Secondary" then el.BackgroundColor3 = secondary
                elseif item.Type == "DropFrame" then el.BackgroundColor3 = dropFrame
                elseif item.Type == "DropItem" then el.BackgroundColor3 = dropItem
                elseif item.Type == "Input" then el.BackgroundColor3 = input end
            end
        end
    end
    for i, th in ipairs(menuThemeList) do
        local btn = Instance.new("TextButton", themeDropList)
        btn.LayoutOrder, btn.Size, btn.BackgroundColor3 = i, UDim2.new(1, 0, 0, 22), Color3.fromRGB(90,25,65)
        btn.BackgroundTransparency, btn.Text, btn.TextColor3, btn.TextSize = 0, " " .. th.Name, Color3.fromRGB(255,255,255), 9
        btn.Font, btn.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
        Corner(btn, UDim.new(0, 4)); Stroke(btn); RegTheme(btn, "DropItem")
        Track(btn.MouseButton1Click:Connect(function()
            themeDropBtn.Text = " 🎨 Theme: " .. th.Name; themeDropList.Visible = false; ApplyTheme(th.Bg)
        end))
    end
    themeDropList.CanvasSize = UDim2.new(0, 0, 0, #menuThemeList * 25)
    Track(themeDropBtn.MouseButton1Click:Connect(function() themeDropList.Visible = not themeDropList.Visible end))

    local transFrame = Instance.new("Frame", menuColorContainer)
    transFrame.LayoutOrder, transFrame.Size, transFrame.BackgroundColor3 = 3, UDim2.new(1, 0, 0, 26), Color3.fromRGB(70,15,50)
    transFrame.BackgroundTransparency = 0
    Corner(transFrame); Stroke(transFrame); RegTheme(transFrame, "Primary")
    transLabel = Instance.new("TextLabel", transFrame)
    transLabel.Size, transLabel.Position, transLabel.BackgroundTransparency, transLabel.Text = UDim2.new(1, -8, 1, 0), UDim2.new(0, 5, 0, 0), 1, "✨ Trong suốt: 0%"
    transLabel.TextColor3, transLabel.TextSize, transLabel.Font = Color3.fromRGB(255,255,255), 9, Enum.Font.GothamBold
    transLabel.TextXAlignment = Enum.TextXAlignment.Left
    local transBarBg = Instance.new("Frame", transFrame)
    transBarBg.Size, transBarBg.Position, transBarBg.BackgroundColor3 = UDim2.new(0, 80, 0, 8), UDim2.new(1, -86, 0.5, -4), Color3.fromRGB(90,25,65)
    Corner(transBarBg, UDim.new(1, 0)); Stroke(transBarBg); RegTheme(transBarBg, "DropItem")
    transBarFill = Instance.new("Frame", transBarBg)
    transBarFill.Size, transBarFill.BackgroundColor3 = UDim2.new(0, 0, 1, 0), Color3.fromRGB(255,105,180)
    Corner(transBarFill, UDim.new(1, 0))
    local transBtn = Instance.new("TextButton", transBarBg)
    transBtn.Size, transBtn.BackgroundTransparency, transBtn.Text = UDim2.new(1, 10, 1, 10), 1, ""
    local adjustingTrans = false
    Track(transBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then adjustingTrans = true end end))
    Track(UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then adjustingTrans = false end end))
    Track(UserInputService.InputChanged:Connect(function(input)
        if adjustingTrans and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local p = math.clamp((input.Position.X - transBarBg.AbsolutePosition.X) / transBarBg.AbsoluteSize.X, 0, 1)
            transBarFill.Size = UDim2.new(p, 0, 1, 0); State.Transparent = p
            MainFrame.BackgroundTransparency = 0.15 + (p * 0.85)
            SidebarPanel.BackgroundTransparency, ContentContainer.BackgroundTransparency = p, p
            transLabel.Text = "✨ Trong suốt: " .. math.floor(p * 100) .. "%"
        end
    end))

    local colorDropBtn = Instance.new("TextButton", menuColorContainer)
    colorDropBtn.LayoutOrder, colorDropBtn.Size, colorDropBtn.BackgroundColor3 = 4, UDim2.new(1, 0, 0, 26), Color3.fromRGB(70,15,50)
    colorDropBtn.BackgroundTransparency, colorDropBtn.Text, colorDropBtn.TextColor3, colorDropBtn.TextSize = 0, " 🎨 Viền: 🔵 Xanh Dương", Color3.fromRGB(255,255,255), 9
    colorDropBtn.Font, colorDropBtn.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
    Corner(colorDropBtn); Stroke(colorDropBtn); RegTheme(colorDropBtn, "Primary")
    local colorDropList = Instance.new("ScrollingFrame", menuColorContainer)
    colorDropList.LayoutOrder, colorDropList.Size, colorDropList.BackgroundColor3 = 5, UDim2.new(1, 0, 0, 95), Color3.fromRGB(80,20,60)
    colorDropList.BackgroundTransparency, colorDropList.CanvasSize, colorDropList.ScrollBarThickness, colorDropList.Visible = 0, UDim2.new(0,0,0,0), 3, false
    Corner(colorDropList); Stroke(colorDropList); RegTheme(colorDropList, "DropFrame")
    local colorListLayout = Instance.new("UIListLayout", colorDropList)
    colorListLayout.Padding = UDim.new(0, 3)
    Instance.new("UIPadding", colorDropList).PaddingRight = UDim.new(0, 8)
    -- [FIX] gán vào biến đã khai báo ở ngoài
    UpdateAllStrokes = function(target)
        if target == "None" then for _, s in ipairs(AllUIStrokes) do if s then s.Transparency = 1 end end
        elseif target == "Rainbow" then for _, s in ipairs(AllUIStrokes) do if s then s.Transparency = 0 end end
        else
            State.StrokeColor = target
            for _, s in ipairs(AllUIStrokes) do if s then s.Transparency = 0; s.Color = target end end
        end
    end
    local colorList = {
        {Name = "🔵 Xanh Dương", Color = Color3.fromRGB(0, 191, 255)}, {Name = "🌈 Cầu Vồng (Rainbow)",Color = "Rainbow"},
        {Name = "🌸 Hồng Kẹo", Color = Color3.fromRGB(255, 105, 180)}, {Name = "🔴 Đỏ Đậm", Color = Color3.fromRGB(220, 20, 60)},
        {Name = "❌ Không Viền", Color = "None"},
    }
    for i, cItem in ipairs(colorList) do
        local btn = Instance.new("TextButton", colorDropList)
        btn.LayoutOrder, btn.Size, btn.BackgroundColor3 = i, UDim2.new(1, 0, 0, 22), Color3.fromRGB(90,25,65)
        btn.BackgroundTransparency, btn.Text, btn.TextColor3, btn.TextSize = 0, " " .. cItem.Name, Color3.fromRGB(255,255,255), 9
        btn.Font, btn.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
        Corner(btn, UDim.new(0, 4)); Stroke(btn); RegTheme(btn, "DropItem")
        Track(btn.MouseButton1Click:Connect(function()
            colorDropBtn.Text = " 🎨 Viền: " .. cItem.Name; colorDropList.Visible = false
            if cItem.Color == "Rainbow" then State.StrokeMode = "Rainbow"; UpdateAllStrokes("Rainbow")
            elseif cItem.Color == "None" then State.StrokeMode = "None"; UpdateAllStrokes("None")
            else State.StrokeMode = "Solid"; UpdateAllStrokes(cItem.Color) end
        end))
    end
    colorDropList.CanvasSize = UDim2.new(0, 0, 0, #colorList * 25)
    Track(colorDropBtn.MouseButton1Click:Connect(function() colorDropList.Visible = not colorDropList.Visible end))
    Track(RunService.RenderStepped:Connect(function()
        if State.StrokeMode ~= "Rainbow" then return end
        local rainbow = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        for _, s in ipairs(AllUIStrokes) do if s then s.Transparency = 0; s.Color = rainbow end end
    end))
end

-- TAB BYPASS
do
    local bypassScroll = Instance.new("ScrollingFrame", ContentContainer)
    bypassScroll.Size, bypassScroll.Position = UDim2.new(1, -12, 1, -29), UDim2.new(0, 6, 0, 28)
    bypassScroll.BackgroundTransparency, bypassScroll.BorderSizePixel, bypassScroll.ScrollBarThickness, bypassScroll.Visible, bypassScroll.ClipsDescendants = 1, 0, 3, false, true
    local bypassLayout = Instance.new("UIListLayout", bypassScroll)
    bypassLayout.SortOrder, bypassLayout.Padding, bypassLayout.HorizontalAlignment = Enum.SortOrder.LayoutOrder, UDim.new(0, 5), Enum.HorizontalAlignment.Center
    local bypassPad = Instance.new("UIPadding", bypassScroll)
    bypassPad.PaddingLeft, bypassPad.PaddingRight, bypassPad.PaddingTop = UDim.new(0,4), UDim.new(0,10), UDim.new(0,4)
    Track(bypassLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        bypassScroll.CanvasSize = UDim2.new(0, 0, 0, bypassLayout.AbsoluteContentSize.Y + 15)
    end))

    local tabBtn = Instance.new("TextButton", SidebarScroll)
    tabBtn.LayoutOrder, tabBtn.Size, tabBtn.BackgroundColor3 = 3, UDim2.new(1, 0, 0, 26), Color3.fromRGB(70,15,50)
    tabBtn.BackgroundTransparency, tabBtn.Text = 0, " 🛡️ BYPASS"
    tabBtn.TextColor3, tabBtn.TextSize, tabBtn.Font = Color3.fromRGB(255,255,255), 8, Enum.Font.Gotham
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    Corner(tabBtn); RegTheme(tabBtn, "Primary")
    local ind = Instance.new("Frame", tabBtn)
    ind.Size, ind.Position, ind.BackgroundColor3, ind.BorderSizePixel, ind.Visible = UDim2.new(0, 3, 0, 12), UDim2.new(0, 0, 0.5, -6), Color3.fromRGB(255,105,180), 0, false
    Corner(ind, UDim.new(0, 2))
    Track(tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Container.Visible = false; if t.Indicator then t.Indicator.Visible = false end end
        bypassScroll.Visible, ind.Visible = true, true
        ActiveTabTitle.Text = "🛡️ BYPASS ANTI-CHEAT"
    end))
    table.insert(Tabs, {Container = bypassScroll, Indicator = ind})

    local infoCard = Instance.new("Frame", bypassScroll)
    infoCard.LayoutOrder, infoCard.Size, infoCard.BackgroundColor3 = 0, UDim2.new(1, 0, 0, 34), Color3.fromRGB(55,12,40)
    infoCard.BackgroundTransparency = 0
    Corner(infoCard); Stroke(infoCard); RegTheme(infoCard, "Secondary")
    local biTitle = Instance.new("TextLabel", infoCard)
    biTitle.Size, biTitle.Position, biTitle.BackgroundTransparency, biTitle.Text = UDim2.new(1, -8, 0, 14), UDim2.new(0, 6, 0, 2), 1, "⚠️ Bypass chạy trên client"
    biTitle.TextColor3, biTitle.TextSize, biTitle.Font = Color3.fromRGB(255,180,100), 8, Enum.Font.GothamBold
    biTitle.TextXAlignment = Enum.TextXAlignment.Left
    local biSub = Instance.new("TextLabel", infoCard)
    biSub.Size, biSub.Position, biSub.BackgroundTransparency, biSub.Text = UDim2.new(1, -8, 0, 14), UDim2.new(0, 6, 0, 17), 1, "Một số game có anti-cheat server-side nên có thể không bypass được"
    biSub.TextColor3, biSub.TextSize, biSub.Font = Color3.fromRGB(180,180,190), 7, Enum.Font.Gotham
    biSub.TextXAlignment, biSub.TextTruncate = Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd

    local bypassSpeedFrame
    bypassSpeedFrame, bypassSpeedFill, bypassSpeedLbl = CreateSlider(bypassScroll, 1, "🏃 WalkSpeed (mặc định 16)", 16, 500,
        function() return BypassState.WalkSpeed end,
        function(v) BypassState.WalkSpeed = v; BypassState.SpeedBypass = (v ~= 16); ApplyBypassNow() end)

    local bypassJumpFrame
    bypassJumpFrame, bypassJumpFill, bypassJumpLbl = CreateSlider(bypassScroll, 2, "🦘 JumpPower (mặc định 50)", 50, 1000,
        function() return BypassState.JumpPower end,
        function(v) BypassState.JumpPower = v; ApplyBypassNow() end)

    CreateToggle(bypassScroll, 3, "🚀 Speed Bypass (duy trì WalkSpeed)", function() return BypassState.SpeedBypass end,
        function(v) BypassState.SpeedBypass = v; if not v then BypassState.WalkSpeed = 16; ApplyBypassNow() end end)
    CreateToggle(bypassScroll, 4, "👻 Noclip (xuyên vật thể)", function() return BypassState.Noclip end, function(v) BypassState.Noclip = v end)
    CreateToggle(bypassScroll, 5, "🛡️ Godmode (bất tử)", function() return BypassState.Godmode end, function(v) BypassState.Godmode = v end)
    CreateToggle(bypassScroll, 6, "🐇 Infinite Jump (nhảy vô hạn)", function() return BypassState.InfiniteJump end, function(v) BypassState.InfiniteJump = v end)
    CreateToggle(bypassScroll, 7, "🦴 Anti-Ragdoll (chống ngã)", function() return BypassState.AntiRagdoll end, function(v) BypassState.AntiRagdoll = v end)
    CreateToggle(bypassScroll, 8, "🐢 Anti-Slow (chống bị làm chậm)", function() return BypassState.AntiSlow end, function(v) BypassState.AntiSlow = v end)
    CreateToggle(bypassScroll, 9, "💥 Damage Block (chặn sát thương)", function() return BypassState.DamageBlock end, function(v) BypassState.DamageBlock = v end)

    local resetBtn = Instance.new("TextButton", bypassScroll)
    resetBtn.LayoutOrder, resetBtn.Size, resetBtn.BackgroundColor3 = 10, UDim2.new(1, 0, 0, 30), Color3.fromRGB(180, 30, 30)
    resetBtn.BackgroundTransparency, resetBtn.Text, resetBtn.TextColor3, resetBtn.TextSize, resetBtn.Font = 0, "🔄 Reset tất cả Bypass", Color3.fromRGB(255,255,255), 9, Enum.Font.GothamBold
    Corner(resetBtn); Stroke(resetBtn, Color3.fromRGB(255, 60, 60))
    Track(resetBtn.MouseButton1Click:Connect(function()
        BypassState.WalkSpeed, BypassState.JumpPower, BypassState.Noclip, BypassState.Godmode = 16, 50, false, false
        BypassState.InfiniteJump, BypassState.AntiRagdoll, BypassState.AntiSlow, BypassState.SpeedBypass, BypassState.DamageBlock = false, false, false, false, false
        local char = localPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
            for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end
        end
    end))
end

-- TAB CẤU HÌNH
do
    local configScroll = Instance.new("ScrollingFrame", ContentContainer)
    configScroll.Size, configScroll.Position = UDim2.new(1, -12, 1, -29), UDim2.new(0, 6, 0, 28)
    configScroll.BackgroundTransparency, configScroll.BorderSizePixel, configScroll.ScrollBarThickness, configScroll.Visible, configScroll.ClipsDescendants = 1, 0, 3, false, true
    local configLayout = Instance.new("UIListLayout", configScroll)
    configLayout.SortOrder, configLayout.Padding, configLayout.HorizontalAlignment = Enum.SortOrder.LayoutOrder, UDim.new(0, 5), Enum.HorizontalAlignment.Center
    local cfgPad = Instance.new("UIPadding", configScroll)
    cfgPad.PaddingLeft, cfgPad.PaddingRight, cfgPad.PaddingTop = UDim.new(0,4), UDim.new(0,10), UDim.new(0,4)
    Track(configLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        configScroll.CanvasSize = UDim2.new(0, 0, 0, configLayout.AbsoluteContentSize.Y + 15)
    end))

    local tabBtn = Instance.new("TextButton", SidebarScroll)
    tabBtn.LayoutOrder, tabBtn.Size, tabBtn.BackgroundColor3 = 4, UDim2.new(1, 0, 0, 26), Color3.fromRGB(70,15,50)
    tabBtn.BackgroundTransparency, tabBtn.Text = 0, " 📦 CẤU HÌNH"
    tabBtn.TextColor3, tabBtn.TextSize, tabBtn.Font = Color3.fromRGB(255,255,255), 8, Enum.Font.Gotham
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    Corner(tabBtn); RegTheme(tabBtn, "Primary")
    local ind = Instance.new("Frame", tabBtn)
    ind.Size, ind.Position, ind.BackgroundColor3, ind.BorderSizePixel, ind.Visible = UDim2.new(0, 3, 0, 12), UDim2.new(0, 0, 0.5, -6), Color3.fromRGB(255,105,180), 0, false
    Corner(ind, UDim.new(0, 2))
    Track(tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Container.Visible = false; if t.Indicator then t.Indicator.Visible = false end end
        configScroll.Visible, ind.Visible = true, true
        ActiveTabTitle.Text = "📦 CẤU HÌNH"
    end))
    table.insert(Tabs, {Container = configScroll, Indicator = ind})

    local cfgSectionToggle = Instance.new("TextButton", configScroll)
    cfgSectionToggle.LayoutOrder, cfgSectionToggle.Size, cfgSectionToggle.BackgroundColor3 = 0, UDim2.new(1, 0, 0, 34), Color3.fromRGB(55,12,40)
    cfgSectionToggle.BackgroundTransparency, cfgSectionToggle.Text, cfgSectionToggle.TextColor3, cfgSectionToggle.TextSize, cfgSectionToggle.Font = 0, " → CẤU HÌNH", Color3.fromRGB(255,255,255), 10, Enum.Font.GothamBold
    Corner(cfgSectionToggle); Stroke(cfgSectionToggle); RegTheme(cfgSectionToggle, "Secondary")
    local mainConfigContainer = Instance.new("Frame", configScroll)
    mainConfigContainer.LayoutOrder, mainConfigContainer.Size, mainConfigContainer.AutomaticSize, mainConfigContainer.BackgroundTransparency, mainConfigContainer.Visible = 1, UDim2.new(1, 0, 0, 0), Enum.AutomaticSize.Y, 1, false
    local mainCfgLayout = Instance.new("UIListLayout", mainConfigContainer)
    mainCfgLayout.SortOrder, mainCfgLayout.Padding, mainCfgLayout.HorizontalAlignment = Enum.SortOrder.LayoutOrder, UDim.new(0, 4), Enum.HorizontalAlignment.Center
    Track(cfgSectionToggle.MouseButton1Click:Connect(function()
        mainConfigContainer.Visible = not mainConfigContainer.Visible
        cfgSectionToggle.Text = mainConfigContainer.Visible and " ↓ CẤU HÌNH" or " → CẤU HÌNH"
    end))

    local startupFrame = Instance.new("Frame", mainConfigContainer)
    startupFrame.LayoutOrder, startupFrame.Size, startupFrame.BackgroundColor3 = 1, UDim2.new(1, 0, 0, 30), Color3.fromRGB(70,15,50)
    startupFrame.BackgroundTransparency = 0
    Corner(startupFrame); Stroke(startupFrame); RegTheme(startupFrame, "Primary")
    startupLabel = Instance.new("TextLabel", startupFrame)
    startupLabel.Size, startupLabel.Position, startupLabel.BackgroundTransparency = UDim2.new(1, -8, 1, 0), UDim2.new(0, 5, 0, 0), 1
    startupLabel.Text, startupLabel.TextColor3, startupLabel.TextSize = "Startup: " .. State.CurrentConfig, Color3.fromRGB(255,255,255), 9
    startupLabel.Font, startupLabel.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left

    local newConfigFrame = Instance.new("Frame", mainConfigContainer)
    newConfigFrame.LayoutOrder, newConfigFrame.Size, newConfigFrame.BackgroundColor3 = 2, UDim2.new(1, 0, 0, 30), Color3.fromRGB(70,15,50)
    newConfigFrame.BackgroundTransparency = 0
    Corner(newConfigFrame); Stroke(newConfigFrame); RegTheme(newConfigFrame, "Primary")
    local ncLabel = Instance.new("TextLabel", newConfigFrame)
    ncLabel.Size, ncLabel.Position, ncLabel.BackgroundTransparency, ncLabel.Text = UDim2.new(0, 80, 1, 0), UDim2.new(0, 5, 0, 0), 1, "Tên Config"
    ncLabel.TextColor3, ncLabel.TextSize, ncLabel.Font = Color3.fromRGB(255,255,255), 9, Enum.Font.Gotham
    ncLabel.TextXAlignment = Enum.TextXAlignment.Left
    local configNameBox = Instance.new("TextBox", newConfigFrame)
    configNameBox.Size, configNameBox.Position, configNameBox.BackgroundColor3 = UDim2.new(1, -95, 0, 20), UDim2.new(0, 85, 0.5, -10), Color3.fromRGB(50,10,35)
    configNameBox.BackgroundTransparency, configNameBox.PlaceholderText, configNameBox.Text = 0, "Name...", ""
    configNameBox.TextColor3, configNameBox.TextSize, configNameBox.Font = Color3.fromRGB(255,255,255), 9, Enum.Font.Gotham
    Corner(configNameBox, UDim.new(0, 4)); Stroke(configNameBox); RegTheme(configNameBox, "Input")

    local createFrame = Instance.new("Frame", mainConfigContainer)
    createFrame.LayoutOrder, createFrame.Size, createFrame.BackgroundColor3 = 3, UDim2.new(1, 0, 0, 34), Color3.fromRGB(70,15,50)
    createFrame.BackgroundTransparency = 0
    Corner(createFrame); Stroke(createFrame); RegTheme(createFrame, "Primary")
    local crTitle = Instance.new("TextLabel", createFrame)
    crTitle.Size, crTitle.Position, crTitle.BackgroundTransparency, crTitle.Text = UDim2.new(1, -75, 0, 15), UDim2.new(0, 5, 0, 2), 1, "Tạo Mới Cấu Hình"
    crTitle.TextColor3, crTitle.TextSize, crTitle.Font = Color3.fromRGB(255,255,255), 9, Enum.Font.GothamBold
    crTitle.TextXAlignment = Enum.TextXAlignment.Left
    local crSub = Instance.new("TextLabel", createFrame)
    crSub.Size, crSub.Position, crSub.BackgroundTransparency, crSub.Text = UDim2.new(1, -75, 0, 14), UDim2.new(0, 5, 0, 17), 1, "Sao chép toàn bộ cài đặt hiện tại"
    crSub.TextColor3, crSub.TextSize, crSub.Font = Color3.fromRGB(140,140,150), 7, Enum.Font.Gotham
    crSub.TextXAlignment = Enum.TextXAlignment.Left
    local createBtn = Instance.new("TextButton", createFrame)
    createBtn.Size, createBtn.Position, createBtn.BackgroundColor3, createBtn.Text = UDim2.new(0, 65, 0, 22), UDim2.new(1, -70, 0.5, -11), Color3.fromRGB(220,50,50), "Create"
    createBtn.TextColor3, createBtn.TextSize, createBtn.Font = Color3.fromRGB(255,255,255), 9, Enum.Font.GothamBold
    Corner(createBtn, UDim.new(0, 4)); Stroke(createBtn)

    local deleteFrame = Instance.new("Frame", mainConfigContainer)
    deleteFrame.LayoutOrder, deleteFrame.Size, deleteFrame.BackgroundColor3 = 4, UDim2.new(1, 0, 0, 30), Color3.fromRGB(70,15,50)
    deleteFrame.BackgroundTransparency = 0
    Corner(deleteFrame); Stroke(deleteFrame); RegTheme(deleteFrame, "Primary")
    local delLabel = Instance.new("TextLabel", deleteFrame)
    delLabel.Size, delLabel.Position, delLabel.BackgroundTransparency, delLabel.Text = UDim2.new(0, 80, 1, 0), UDim2.new(0, 5, 0, 0), 1, "Xóa Cấu Hình"
    delLabel.TextColor3, delLabel.TextSize, delLabel.Font = Color3.fromRGB(255,255,255), 9, Enum.Font.Gotham
    delLabel.TextXAlignment = Enum.TextXAlignment.Left
    delBtn = Instance.new("TextButton", deleteFrame)
    delBtn.Size, delBtn.Position, delBtn.BackgroundColor3 = UDim2.new(0, 85, 0, 20), UDim2.new(1, -90, 0.5, -10), Color3.fromRGB(50,10,35)
    delBtn.BackgroundTransparency, delBtn.Text, delBtn.TextColor3, delBtn.TextSize = 0, "Không có ∨", Color3.fromRGB(50,200,50), 8
    delBtn.Font, delBtn.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Center
    Corner(delBtn, UDim.new(0, 4)); Stroke(delBtn); RegTheme(delBtn, "Input")
    delDropFrame = Instance.new("ScrollingFrame", mainConfigContainer)
    delDropFrame.LayoutOrder, delDropFrame.Size, delDropFrame.BackgroundColor3 = 5, UDim2.new(1, 0, 0, 80), Color3.fromRGB(80,20,60)
    delDropFrame.BackgroundTransparency, delDropFrame.CanvasSize, delDropFrame.ScrollBarThickness, delDropFrame.Visible = 0, UDim2.new(0,0,0,0), 3, false
    Corner(delDropFrame); Stroke(delDropFrame); RegTheme(delDropFrame, "DropFrame")
    local delDropLayout = Instance.new("UIListLayout", delDropFrame)
    delDropLayout.Padding = UDim.new(0, 3)
    Instance.new("UIPadding", delDropFrame).PaddingRight = UDim.new(0, 8)

    local loadConfigFrame = Instance.new("Frame", mainConfigContainer)
    loadConfigFrame.LayoutOrder, loadConfigFrame.Size, loadConfigFrame.BackgroundColor3 = 6, UDim2.new(1, 0, 0, 30), Color3.fromRGB(70,15,50)
    loadConfigFrame.BackgroundTransparency = 0
    Corner(loadConfigFrame); Stroke(loadConfigFrame); RegTheme(loadConfigFrame, "Primary")
    local ldLabel = Instance.new("TextLabel", loadConfigFrame)
    ldLabel.Size, ldLabel.Position, ldLabel.BackgroundTransparency, ldLabel.Text = UDim2.new(0, 80, 1, 0), UDim2.new(0, 5, 0, 0), 1, "Tải Config"
    ldLabel.TextColor3, ldLabel.TextSize, ldLabel.Font = Color3.fromRGB(255,255,255), 9, Enum.Font.Gotham
    ldLabel.TextXAlignment = Enum.TextXAlignment.Left
    ldBtn = Instance.new("TextButton", loadConfigFrame)
    ldBtn.Size, ldBtn.Position, ldBtn.BackgroundColor3 = UDim2.new(0, 85, 0, 20), UDim2.new(1, -90, 0.5, -10), Color3.fromRGB(50,10,35)
    ldBtn.BackgroundTransparency, ldBtn.Text, ldBtn.TextColor3, ldBtn.TextSize = 0, State.CurrentConfig .. " ∨", Color3.fromRGB(50,200,50), 8
    ldBtn.Font, ldBtn.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Center
    Corner(ldBtn, UDim.new(0, 4)); Stroke(ldBtn); RegTheme(ldBtn, "Input")
    ldDropFrame = Instance.new("ScrollingFrame", mainConfigContainer)
    ldDropFrame.LayoutOrder, ldDropFrame.Size, ldDropFrame.BackgroundColor3 = 7, UDim2.new(1, 0, 0, 80), Color3.fromRGB(80,20,60)
    ldDropFrame.BackgroundTransparency, ldDropFrame.CanvasSize, ldDropFrame.ScrollBarThickness, ldDropFrame.Visible = 0, UDim2.new(0,0,0,0), 3, false
    Corner(ldDropFrame); Stroke(ldDropFrame); RegTheme(ldDropFrame, "DropFrame")
    local ldDropLayout = Instance.new("UIListLayout", ldDropFrame)
    ldDropLayout.Padding = UDim.new(0, 3)
    Instance.new("UIPadding", ldDropFrame).PaddingRight = UDim.new(0, 8)

    local saveFrame = Instance.new("Frame", mainConfigContainer)
    saveFrame.LayoutOrder, saveFrame.Size, saveFrame.BackgroundColor3 = 8, UDim2.new(1, 0, 0, 34), Color3.fromRGB(70,15,50)
    saveFrame.BackgroundTransparency = 0
    Corner(saveFrame); Stroke(saveFrame); RegTheme(saveFrame, "Primary")
    local svTitle = Instance.new("TextLabel", saveFrame)
    svTitle.Size, svTitle.Position, svTitle.BackgroundTransparency, svTitle.Text = UDim2.new(1, -75, 0, 15), UDim2.new(0, 5, 0, 2), 1, "Lưu Cấu Hình"
    svTitle.TextColor3, svTitle.TextSize, svTitle.Font = Color3.fromRGB(255,255,255), 9, Enum.Font.GothamBold
    svTitle.TextXAlignment = Enum.TextXAlignment.Left
    svSub = Instance.new("TextLabel", saveFrame)
    svSub.Size, svSub.Position, svSub.BackgroundTransparency, svSub.Text = UDim2.new(1, -75, 0, 14), UDim2.new(0, 5, 0, 17), 1, "Save: " .. State.CurrentConfig
    svSub.TextColor3, svSub.TextSize, svSub.Font = Color3.fromRGB(140,140,150), 7, Enum.Font.Gotham
    svSub.TextXAlignment = Enum.TextXAlignment.Left
    local saveBtn = Instance.new("TextButton", saveFrame)
    saveBtn.Size, saveBtn.Position, saveBtn.BackgroundColor3, saveBtn.Text = UDim2.new(0, 65, 0, 22), UDim2.new(1, -70, 0.5, -11), Color3.fromRGB(220,50,50), "Save"
    saveBtn.TextColor3, saveBtn.TextSize, saveBtn.Font = Color3.fromRGB(255,255,255), 9, Enum.Font.GothamBold
    Corner(saveBtn, UDim.new(0, 4)); Stroke(saveBtn)

    local acSectionToggle = Instance.new("TextButton", configScroll)
    acSectionToggle.LayoutOrder, acSectionToggle.Size, acSectionToggle.BackgroundColor3 = 2, UDim2.new(1, 0, 0, 34), Color3.fromRGB(55,12,40)
    acSectionToggle.BackgroundTransparency, acSectionToggle.Text, acSectionToggle.TextColor3, acSectionToggle.TextSize, acSectionToggle.Font = 0, " → ANTI-CHEAT (Bảo vệ)", Color3.fromRGB(255,255,255), 10, Enum.Font.GothamBold
    Corner(acSectionToggle); Stroke(acSectionToggle); RegTheme(acSectionToggle, "Secondary")
    local acContainer = Instance.new("Frame", configScroll)
    acContainer.LayoutOrder, acContainer.Size, acContainer.AutomaticSize, acContainer.BackgroundTransparency, acContainer.Visible = 3, UDim2.new(1, 0, 0, 0), Enum.AutomaticSize.Y, 1, false
    local acLayout = Instance.new("UIListLayout", acContainer)
    acLayout.SortOrder, acLayout.Padding, acLayout.HorizontalAlignment = Enum.SortOrder.LayoutOrder, UDim.new(0, 5), Enum.HorizontalAlignment.Center
    Track(acSectionToggle.MouseButton1Click:Connect(function()
        acContainer.Visible = not acContainer.Visible
        acSectionToggle.Text = acContainer.Visible and " ↓ ANTI-CHEAT (Bảo vệ)" or " → ANTI-CHEAT (Bảo vệ)"
    end))

    local function CreateACToggle(order, label, key)
        local f, btn, dot = CreateToggle(acContainer, order, label,
            function() return AntiCheatFlags[key] end,
            function(v)
                AntiCheatFlags[key] = v
                if key == "AntiKick" and v then pcall(SetupAntiKick) end
                if key == "NetworkOwner" and v then pcall(ApplyNetworkOwner) end
            end)
        acToggleFrames[key] = {btn = btn, dot = dot}
        return f
    end
    CreateACToggle(1, "🛡️ Anti-Kick", "AntiKick")
    CreateACToggle(2, "💤 Anti-AFK", "AntiAFK")
    CreateACToggle(3, "🌌 Anti-Void", "AntiVoid")
    CreateACToggle(4, "🌀 Anti-Fling", "AntiFling")
    CreateACToggle(5, "🔗 Network Owner Fix", "NetworkOwner")

    -- Hook các nút Config
    Track(delBtn.MouseButton1Click:Connect(function()
        refreshAllDropdowns(); delDropFrame.Visible = not delDropFrame.Visible; ldDropFrame.Visible = false
    end))
    Track(ldBtn.MouseButton1Click:Connect(function()
        refreshAllDropdowns(); ldDropFrame.Visible = not ldDropFrame.Visible; delDropFrame.Visible = false
    end))
    Track(createBtn.MouseButton1Click:Connect(function()
        local name = configNameBox.Text
        if name == "" or string.find(name, "[\\/:*?\"<>|]") or typeof(writefile) ~= "function" then return end
        if SaveConfig(name) then
            State.CurrentConfig = name
            ldBtn.Text = name .. " ∨"; svSub.Text = "Save: " .. name; configNameBox.Text = ""
            RefreshStartupLabel(); refreshAllDropdowns()
        end
    end))
    Track(saveBtn.MouseButton1Click:Connect(function()
        if SaveConfig(State.CurrentConfig) then svSub.Text = "Save: " .. State.CurrentConfig end
    end))
end

-- ═════════════════ CÁC HÀM XỬ LÝ LOGIC ═════════════════
local CONFIG_FOLDER = "VzNamHub_Configs"
if typeof(makefolder) == "function" then pcall(makefolder, CONFIG_FOLDER) end

local function SerializeState()
    local PointsData = {}
    for _, p in ipairs(CoordPoints) do
        table.insert(PointsData, {Name = p.name, X = tonumber(p.boxX.Text) or 0, Y = tonumber(p.boxY.Text) or 0, Z = tonumber(p.boxZ.Text) or 0})
    end
    return {
        Version = 5, SavedTime = os.time(), ThemeBase = {State.ThemeBase.R, State.ThemeBase.G, State.ThemeBase.B},
        StrokeMode = State.StrokeMode, StrokeColor = {State.StrokeColor.R, State.StrokeColor.G, State.StrokeColor.B},
        Volume = State.Volume, SoundId = State.SoundId, Transparent = State.Transparent,
        Coord = { Speed = CoordState.Speed, TeleportMode = CoordState.TeleportMode, Points = PointsData },
        AntiCheat = { AntiKick = AntiCheatFlags.AntiKick, AntiAFK = AntiCheatFlags.AntiAFK, AntiVoid = AntiCheatFlags.AntiVoid, AntiFling = AntiCheatFlags.AntiFling, NetworkOwner = AntiCheatFlags.NetworkOwner },
        Bypass = { WalkSpeed = BypassState.WalkSpeed, JumpPower = BypassState.JumpPower, Noclip = BypassState.Noclip, Godmode = BypassState.Godmode, InfiniteJump = BypassState.InfiniteJump, AntiRagdoll = BypassState.AntiRagdoll, AntiSlow = BypassState.AntiSlow, SpeedBypass = BypassState.SpeedBypass, DamageBlock = BypassState.DamageBlock },
    }
end

local function ValidateConfig(data)
    if type(data) ~= "table" or (data.Version ~= 4 and data.Version ~= 5) then return false end
    if data.ThemeBase and (type(data.ThemeBase) ~= "table" or type(data.ThemeBase[1]) ~= "number") then return false end
    if data.StrokeColor and (type(data.StrokeColor) ~= "table" or type(data.StrokeColor[1]) ~= "number") then return false end
    return true
end

function SaveConfig(name)
    if typeof(writefile) ~= "function" then return false end
    return pcall(writefile, CONFIG_FOLDER .. "/" .. name .. ".json", HttpService:JSONEncode(SerializeState()))
end

local function LoadConfigRaw(name)
    if typeof(readfile) ~= "function" then return false, "no readfile" end
    local ok, contents = pcall(readfile, CONFIG_FOLDER .. "/" .. name .. ".json")
    if not ok or not contents then return false, "read fail" end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, contents)
    if not ok2 or not ValidateConfig(data) then return false, "invalid JSON/schema" end
    return true, data
end

function RefreshStartupLabel() if startupLabel then startupLabel.Text = "Startup: " .. State.CurrentConfig end end

local function ApplyConfig(data)
    if data.ThemeBase and type(data.ThemeBase) == "table" then
        pcall(function() local c = Color3.new(data.ThemeBase[1], data.ThemeBase[2], data.ThemeBase[3]); ApplyTheme(c) end)
    end
    if data.StrokeMode == "Rainbow" then State.StrokeMode = "Rainbow"; pcall(UpdateAllStrokes, "Rainbow")
    elseif data.StrokeMode == "None" then State.StrokeMode = "None"; pcall(UpdateAllStrokes, "None")
    elseif data.StrokeColor and type(data.StrokeColor) == "table" then
        pcall(function() local c = Color3.new(data.StrokeColor[1], data.StrokeColor[2], data.StrokeColor[3]); State.StrokeMode = "Solid"; UpdateAllStrokes(c) end)
    end
    if type(data.Volume) == "number" then
        State.Volume = math.clamp(data.Volume, 0, 1); HubSound.Volume = State.Volume
        volumeBarFill.Size = UDim2.new(State.Volume, 0, 1, 0); volumeLabel.Text = "🔊 Vol: " .. math.floor(State.Volume * 100) .. "%"
    end
    if type(data.SoundId) == "string" then State.SoundId = data.SoundId; HubSound.SoundId = "rbxassetid://" .. State.SoundId end
    if type(data.Transparent) == "number" then
        State.Transparent = math.clamp(data.Transparent, 0, 1); transBarFill.Size = UDim2.new(State.Transparent, 0, 1, 0)
        MainFrame.BackgroundTransparency = 0.15 + (State.Transparent * 0.85)
        SidebarPanel.BackgroundTransparency = State.Transparent; ContentContainer.BackgroundTransparency = State.Transparent
        transLabel.Text = "✨ Trong suốt: " .. math.floor(State.Transparent * 100) .. "%"
    end
    if data.Coord and type(data.Coord) == "table" then
        local C = data.Coord
        if type(C.Speed) == "number" then
            CoordState.Speed = C.Speed
            if speedBarFill and speedValLbl then
                speedBarFill.Size = UDim2.new(math.clamp((CoordState.Speed - 10) / 990, 0, 1), 0, 1, 0); speedValLbl.Text = tostring(math.floor(CoordState.Speed))
            end
        end
        if C.TeleportMode ~= nil then
            CoordState.TeleportMode = C.TeleportMode == true
            if teleportToggleBtn and teleportToggleDot then
                if CoordState.TeleportMode then
                    teleportToggleBtn.BackgroundColor3 = Color3.fromRGB(50,200,50); teleportToggleDot.Position = UDim2.new(1, -14, 0.5, -6)
                else
                    teleportToggleBtn.BackgroundColor3 = Color3.fromRGB(60,65,75); teleportToggleDot.Position = UDim2.new(0, 2, 0.5, -6)
                end
            end
        end
        if C.Points and type(C.Points) == "table" and #C.Points > 0 then
            for _, p in ipairs(CoordPoints) do if p.frame then p.frame:Destroy() end end
            CoordPoints = {}
            for _, pd in ipairs(C.Points) do
                if type(pd) == "table" and type(pd.Name) == "string" then CreateCoordPoint(pd.Name, tonumber(pd.X) or 0, tonumber(pd.Y) or 0, tonumber(pd.Z) or 0) end
            end
            if #CoordPoints == 0 then CreateCoordPoint("Điểm 1", 0, 0, 0) end
            pcall(RefreshPointsDropdown)
        end
    end
    if type(data.AntiCheat) == "table" then
        for key, val in pairs(data.AntiCheat) do
            if AntiCheatFlags[key] ~= nil then
                AntiCheatFlags[key] = (val == true)
                local t = acToggleFrames[key]
                if t then
                    if AntiCheatFlags[key] then t.btn.BackgroundColor3 = Color3.fromRGB(50,200,50); t.dot.Position = UDim2.new(1, -14, 0.5, -6)
                    else t.btn.BackgroundColor3 = Color3.fromRGB(60,65,75); t.dot.Position = UDim2.new(0, 2, 0.5, -6) end
                end
            end
        end
        if AntiCheatFlags.AntiKick then pcall(SetupAntiKick) end
        if AntiCheatFlags.NetworkOwner then pcall(ApplyNetworkOwner) end
    end
    if type(data.Bypass) == "table" then
        local B = data.Bypass
        if type(B.WalkSpeed) == "number" then
            BypassState.WalkSpeed = B.WalkSpeed
            if bypassSpeedFill and bypassSpeedLbl then
                bypassSpeedFill.Size = UDim2.new(math.clamp((B.WalkSpeed - 16) / 484, 0, 1), 0, 1, 0); bypassSpeedLbl.Text = tostring(math.floor(B.WalkSpeed))
            end
        end
        if type(B.JumpPower) == "number" then
            BypassState.JumpPower = B.JumpPower
            if bypassJumpFill and bypassJumpLbl then
                bypassJumpFill.Size = UDim2.new(math.clamp((B.JumpPower - 50) / 950, 0, 1), 0, 1, 0); bypassJumpLbl.Text = tostring(math.floor(B.JumpPower))
            end
        end
        BypassState.Noclip, BypassState.Godmode, BypassState.InfiniteJump = B.Noclip == true, B.Godmode == true, B.InfiniteJump == true
        BypassState.AntiRagdoll, BypassState.AntiSlow, BypassState.SpeedBypass, BypassState.DamageBlock = B.AntiRagdoll == true, B.AntiSlow == true, B.SpeedBypass == true, B.DamageBlock == true
        ApplyBypassNow()
    end
end

local function LoadConfig(name)
    local ok, dataOrErr = LoadConfigRaw(name)
    if not ok then return false, dataOrErr end
    local ok2, err2 = pcall(ApplyConfig, dataOrErr)
    if not ok2 then return false, tostring(err2) end
    return true
end

function refreshAllDropdowns()
    for _, drop in ipairs({delDropFrame, ldDropFrame}) do
        for _, child in ipairs(drop:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    end
    local filesList = {}
    if typeof(listfiles) == "function" then
        local ok, files = pcall(listfiles, CONFIG_FOLDER)
        if ok and type(files) == "table" then
            for _, file in ipairs(files) do
                if type(file) == "string" and string.sub(file, -5) == ".json" then
                    table.insert(filesList, string.sub(string.match(file, "[^/\\]+$") or file, 1, -6))
                end
            end
        end
    end
    if #filesList == 0 then delBtn.Text = "Không có ∨" end
    for _, name in ipairs(filesList) do
        local f1 = Instance.new("TextButton", delDropFrame)
        f1.Size, f1.BackgroundColor3, f1.BackgroundTransparency = UDim2.new(1, 0, 0, 22), Color3.fromRGB(90,25,65), 0
        f1.Text, f1.TextColor3, f1.TextSize = " 🗑️ " .. name, Color3.fromRGB(255,100,100), 9
        f1.Font, f1.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
        Corner(f1, UDim.new(0, 4)); Stroke(f1); RegTheme(f1, "DropItem")
        Track(f1.MouseButton1Click:Connect(function()
            if typeof(delfile) == "function" then pcall(delfile, CONFIG_FOLDER .. "/" .. name .. ".json") end
            delBtn.Text = name .. " ∨"; delDropFrame.Visible = false; refreshAllDropdowns()
        end))
        local f3 = Instance.new("TextButton", ldDropFrame)
        f3.Size, f3.BackgroundColor3, f3.BackgroundTransparency = UDim2.new(1, 0, 0, 22), Color3.fromRGB(90,25,65), 0
        f3.Text, f3.TextColor3, f3.TextSize = " 📂 " .. name, Color3.fromRGB(255,255,255), 9
        f3.Font, f3.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
        Corner(f3, UDim.new(0, 4)); Stroke(f3); RegTheme(f3, "DropItem")
        Track(f3.MouseButton1Click:Connect(function()
            State.CurrentConfig = name; ldBtn.Text = name .. " ∨"; svSub.Text = "Save: " .. name
            ldDropFrame.Visible = false; RefreshStartupLabel()
            local ok, err = LoadConfig(name)
            if not ok then warn("[VzNam] Load config fail: " .. tostring(err)) end
        end))
    end
    delDropFrame.CanvasSize, ldDropFrame.CanvasSize = UDim2.new(0, 0, 0, #filesList * 25), UDim2.new(0, 0, 0, #filesList * 25)
end

-- ═════════════════ KHỞI CHẠY CÁC HOOK ═════════════════
local _antiKickHooked = false
function SetupAntiKick()
    if _antiKickHooked then return true end
    local ok = pcall(function()
        if typeof(getrawmetatable) ~= "function" then error("no mt") end
        if typeof(setreadonly) ~= "function" then error("no setro") end
        if typeof(newcclosure) ~= "function" then error("no cclosure") end
        if typeof(getnamecallmethod) ~= "function" then error("no namecall") end
        local mt = getrawmetatable(game); local oldNamecall = mt.__namecall
        if not oldNamecall then error("no __namecall") end
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            if AntiCheatFlags.AntiKick and getnamecallmethod() == "Kick" and self == localPlayer then return end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end)
    _antiKickHooked = ok
    return ok
end

function ApplyNetworkOwner()
    pcall(function()
        if not AntiCheatFlags.NetworkOwner then return end
        local char = localPlayer.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if hrp then hrp:SetNetworkOwner(localPlayer) end
    end)
end

Track(localPlayer.CharacterAdded:Connect(function() task.wait(1); pcall(ApplyNetworkOwner) end))
Track(localPlayer.Idled:Connect(function()
    if not AntiCheatFlags.AntiAFK then return end
    pcall(function() local vu = game:GetService("VirtualUser"); vu:CaptureController(); vu:ClickButton2(Vector2.new()) end)
end))
Track(RunService.Heartbeat:Connect(function()
    pcall(function()
        if not AntiCheatFlags.AntiVoid and not AntiCheatFlags.AntiFling then return end
        local char = localPlayer.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        if AntiCheatFlags.AntiVoid then
            if hrp.Position.Y > -50 then _lastSafePos = hrp.Position
            elseif _lastSafePos then hrp.CFrame = CFrame.new(_lastSafePos + Vector3.new(0, 5, 0)) end
        end
        if AntiCheatFlags.AntiFling then
            local vel, ang = hrp.AssemblyLinearVelocity, hrp.AssemblyAngularVelocity
            if vel and vel.Magnitude > 500 then hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
            if ang and ang.Magnitude > 100 then hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0) end
        end
    end)
end))

Track(RunService.RenderStepped:Connect(function()
    local char = localPlayer.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if BypassState.SpeedBypass or BypassState.WalkSpeed ~= 16 then
        local target = BypassState.WalkSpeed
        if BypassState.AntiSlow and target < 16 then target = 16 end
        if math.abs(hum.WalkSpeed - target) > 0.05 then pcall(function() hum.WalkSpeed = target end) end
    end
    if BypassState.JumpPower ~= 50 and math.abs((hum.JumpPower or 0) - BypassState.JumpPower) > 0.05 then
        pcall(function() hum.UseJumpPower = true; hum.JumpPower = BypassState.JumpPower end)
    end
    if BypassState.Godmode and hum.Health < hum.MaxHealth then pcall(function() hum.Health = hum.MaxHealth end) end
    if BypassState.AntiRagdoll then pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end) end
end))

Track(RunService.Heartbeat:Connect(function()
    local char = localPlayer.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if BypassState.SpeedBypass or BypassState.WalkSpeed ~= 16 then
        if math.abs(hum.WalkSpeed - BypassState.WalkSpeed) > 0.1 then pcall(function() hum.WalkSpeed = BypassState.WalkSpeed end) end
    end
end))

local charNow = localPlayer.Character
if charNow then local humNow = charNow:FindFirstChildOfClass("Humanoid"); if humNow then HookHumanoid(humNow) end end
Track(localPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5); local hum = char:WaitForChild("Humanoid", 5)
    if hum then HookHumanoid(hum); task.wait(0.2); ApplyBypassNow() end
end))

local function DoNoclip()
    if not BypassState.Noclip then return end
    local char = localPlayer.Character; if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
    end
end
Track(RunService.Stepped:Connect(DoNoclip))
Track(RunService.Heartbeat:Connect(DoNoclip))

Track(UserInputService.JumpRequest:Connect(function()
    if not BypassState.InfiniteJump then return end
    local char = localPlayer.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
end))

local function ForceNetworkOwner()
    pcall(function()
        local char = localPlayer.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if hrp then hrp:SetNetworkOwner(localPlayer) end
    end)
end
Track(localPlayer.CharacterAdded:Connect(function() task.wait(1); ForceNetworkOwner() end))
task.spawn(function() task.wait(2); ForceNetworkOwner() end)

-- ═════════════════ INIT ═════════════════
pcall(function()
    ApplyTheme(Color3.fromRGB(15, 16, 22))
end)
pcall(function()
    State.StrokeColor = Color3.fromRGB(0, 191, 255)
    for _, s in ipairs(AllUIStrokes) do if s then s.Transparency = 0; s.Color = State.StrokeColor end end
end)
RefreshStartupLabel()
Track(flowerBtn.MouseButton1Click:Connect(function()
    if not flowerBtn.Parent then return end
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then flowerBtn.Text = "✕"; fStroke.Color = Color3.fromRGB(255, 80, 80) else flowerBtn.Text = "🌸"; fStroke.Color = Color3.fromRGB(255, 105, 180) end
end))
print("[VzNamHub : Toạ Độ + Bypass] ✅ Loaded - Full Info + Bypass FIXED Edition")
