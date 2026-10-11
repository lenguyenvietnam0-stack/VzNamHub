-- Khởi tạo UI Service
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

-- Xóa GUI cũ nếu đang chạy
if CoreGui:FindFirstChild("VzNamHubGui") then
    CoreGui.VzNamHubGui:Destroy()
end

-- Tạo ScreenGui chính
local VzNamGui = Instance.new("ScreenGui")
VzNamGui.Name = "VzNamHubGui"
VzNamGui.Parent = CoreGui
VzNamGui.ResetOnSpawn = false

-- Lấy link ảnh Avatar nhân vật của bạn
local avatarUrl = "rbxassetid://6031094678"
pcall(function()
    avatarUrl = Players:GetUserThumbnailAsync(localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
end)

-- 1. NÚT TRÒN TOGGLE
local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = VzNamGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Image = avatarUrl

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = ToggleBtn

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Thickness = 2
UIStroke.Parent = ToggleBtn

-- 2. BẢNG MENU CHÍNH
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = VzNamGui
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -150)
MainFrame.Size = UDim2.new(0, 360, 0, 310)
MainFrame.ClipsDescendants = true

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = MainFrame

-- HIỆU ỨNG RAINBOW NỀN MENU
local RainbowGradient = Instance.new("UIGradient")
RainbowGradient.Parent = MainFrame
RainbowGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 180, 180)),
    ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 220, 180)),
    ColorSequenceKeypoint.new(0.40, Color3.fromRGB(255, 255, 180)),
    ColorSequenceKeypoint.new(0.60, Color3.fromRGB(180, 255, 200)),
    ColorSequenceKeypoint.new(0.80, Color3.fromRGB(180, 220, 255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(220, 180, 255))
})

local tweenInfo = TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false)
local tween = TweenService:Create(RainbowGradient, tweenInfo, {Rotation = 360})
tween:Play()

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(255, 255, 255)
FrameStroke.Thickness = 2
FrameStroke.Parent = MainFrame

-- Tiêu đề Menu (Đồng thời là tay cầm để kéo bảng menu)
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TitleBar.BackgroundTransparency = 0.6

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- Xử lý kéo bảng menu (Draggable)
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Avatar trên tiêu đề
local HeaderAvatar = Instance.new("ImageLabel")
HeaderAvatar.Name = "HeaderAvatar"
HeaderAvatar.Parent = TitleBar
HeaderAvatar.Position = UDim2.new(0, 10, 0.5, -14)
HeaderAvatar.Size = UDim2.new(0, 28, 0, 28)
HeaderAvatar.BackgroundTransparency = 1
HeaderAvatar.Image = avatarUrl

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = HeaderAvatar

-- Tiêu đề bảng Hub
local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Parent = TitleBar
TitleText.Position = UDim2.new(0, 45, 0, 0)
TitleText.Size = UDim2.new(1, -50, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "TỔNG HỢP SCRIPT | 👑VzNam Hub👑|"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 13
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- 3. THANH TAB DỌC BÊN TRÁI (VIỀN NGOÀI BÊN TRÁI)
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Parent = MainFrame
TabBar.Position = UDim2.new(0, 8, 0, 48)
TabBar.Size = UDim2.new(0, 100, 1, -56)
TabBar.BackgroundTransparency = 1

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabBar
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 8)

local Tab1Btn = Instance.new("TextButton")
Tab1Btn.Parent = TabBar
Tab1Btn.Size = UDim2.new(1, 0, 0, 38)
Tab1Btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Tab1Btn.BackgroundTransparency = 0.3
Tab1Btn.Text = "steal an egg"
Tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Tab1Btn.Font = Enum.Font.SourceSansBold
Tab1Btn.TextSize = 12
Tab1Btn.TextWrapped = true

local Tab1Corner = Instance.new("UICorner")
Tab1Corner.CornerRadius = UDim.new(0, 8)
Tab1Corner.Parent = Tab1Btn

local Tab2Btn = Instance.new("TextButton")
Tab2Btn.Parent = TabBar
Tab2Btn.Size = UDim2.new(1, 0, 0, 38)
Tab2Btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Tab2Btn.BackgroundTransparency = 0.7
Tab2Btn.Text = "bloxkid"
Tab2Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
Tab2Btn.Font = Enum.Font.SourceSansBold
Tab2Btn.TextSize = 13

local Tab2Corner = Instance.new("UICorner")
Tab2Corner.CornerRadius = UDim.new(0, 8)
Tab2Corner.Parent = Tab2Btn

-- 4. KHUNG CUỘN CHO TAB "steal an egg" (BÊN PHẢI)
local Scroll1 = Instance.new("ScrollingFrame")
Scroll1.Name = "Scroll1"
Scroll1.Parent = MainFrame
Scroll1.Position = UDim2.new(0, 114, 0, 48)
Scroll1.Size = UDim2.new(1, -122, 1, -56)
Scroll1.BackgroundTransparency = 1
Scroll1.CanvasSize = UDim2.new(0, 0, 0, 2000)
Scroll1.ScrollBarThickness = 4
Scroll1.Visible = true

local ListLayout1 = Instance.new("UIListLayout")
ListLayout1.Parent = Scroll1
ListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout1.Padding = UDim.new(0, 8)

-- 5. KHUNG CUỘN CHO TAB "bloxkid" (BÊN PHẢI)
local Scroll2 = Instance.new("ScrollingFrame")
Scroll2.Name = "Scroll2"
Scroll2.Parent = MainFrame
Scroll2.Position = UDim2.new(0, 114, 0, 48)
Scroll2.Size = UDim2.new(1, -122, 1, -56)
Scroll2.BackgroundTransparency = 1
Scroll2.CanvasSize = UDim2.new(0, 0, 0, 2000)
Scroll2.ScrollBarThickness = 4
Scroll2.Visible = false

local ListLayout2 = Instance.new("UIListLayout")
ListLayout2.Parent = Scroll2
ListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout2.Padding = UDim.new(0, 8)

-- Hàm tạo nút cho Tab "steal an egg"
local function AddScriptButtonTab1(Name, Callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Scroll1
    Btn.Size = UDim2.new(1, 0, 0, 38)
    Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Btn.BackgroundTransparency = 0.25
    Btn.Text = Name
    Btn.TextColor3 = Color3.fromRGB(40, 40, 40)
    Btn.Font = Enum.Font.SourceSansSemibold
    Btn.TextSize = 14
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Btn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(255, 255, 255)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn
    
    Btn.MouseButton1Click:Connect(Callback)
end

-- Hàm tạo nút cho Tab "bloxkid"
local function AddScriptButtonTab2(Name, Callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Scroll2
    Btn.Size = UDim2.new(1, 0, 0, 38)
    Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Btn.BackgroundTransparency = 0.25
    Btn.Text = Name
    Btn.TextColor3 = Color3.fromRGB(40, 40, 40)
    Btn.Font = Enum.Font.SourceSansSemibold
    Btn.TextSize = 14
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Btn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(255, 255, 255)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn
    
    Btn.MouseButton1Click:Connect(Callback)
end

-- Xử lý chuyển đổi giữa 2 Tab dọc bên trái
Tab1Btn.MouseButton1Click:Connect(function()
    Scroll1.Visible = true
    Scroll2.Visible = false
    Tab1Btn.BackgroundTransparency = 0.3
    Tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tab2Btn.BackgroundTransparency = 0.7
    Tab2Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

Tab2Btn.MouseButton1Click:Connect(function()
    Scroll1.Visible = false
    Scroll2.Visible = true
    Tab2Btn.BackgroundTransparency = 0.3
    Tab2Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tab1Btn.BackgroundTransparency = 0.7
    Tab1Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

-- ================= DANH SÁCH SCRIPT TAB "steal an egg" =================
AddScriptButtonTab1("1. Infinite Yield (Admin)", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end)

AddScriptButtonTab1("2. Fly Script (Bay)", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source"))()
end)

AddScriptButtonTab1("3. FyyCommunity", function()
    loadstring(game:HttpGet("https://FyyCommunity.my.id"))()
end)

AddScriptButtonTab1("4. Chilli Hub V3", function()
    loadstring(game:HttpGet("https://apexhubeditor.vercel.app/api/raw?name=6bzPiAYUA0ekyyvhOhxpPobkK643_chilli-hub-vit-ho-v3"))()
end)

AddScriptButtonTab1("5. Realkid hub", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/realkidhub/realkid/refs/heads/main/main.lua"))()
end)

AddScriptButtonTab1("6. Speed hub", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
end)

AddScriptButtonTab1("7. Chữ A(ajjans)", function()
    loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/359e97f8618e9008afe5f496184ebb7c.lua"))()
end)

AddScriptButtonTab1("8. Bigfroot", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hanniii1/Loader/refs/heads/main/BFLoader.lua"))()    
end)

-- ================= DANH SÁCH SCRIPT TAB "bloxkid" =================
AddScriptButtonTab2("1. Realkid hub", function()

loadstring(game:HttpGet("https://raw.githubusercontent.com/realkidhub/realkid/refs/heads/main/main.lua"))()
end)

AddScriptButtonTab2("2. Chưa update", function()
    -- Dán link script của bloxkid vào đây
end)

-- BẤM NÚT TRÒN BẬT/TẮT MENU
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)
