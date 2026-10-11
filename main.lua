-- Khởi tạo UI Service
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
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
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Để màu trắng làm nền cho Gradient
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -150)
MainFrame.Size = UDim2.new(0, 320, 0, 300)
MainFrame.ClipsDescendants = true

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = MainFrame

-- TẠO HIỆU ỨNG RAINBOW CHO NỀN MENU
local RainbowGradient = Instance.new("UIGradient")
RainbowGradient.Parent = MainFrame

-- Dải màu Cầu Vồng tông Pastel nhẹ nhàng
RainbowGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 180, 180)), -- Hồng
    ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 220, 180)), -- Cam nhạt
    ColorSequenceKeypoint.new(0.40, Color3.fromRGB(255, 255, 180)), -- Vàng nhạt
    ColorSequenceKeypoint.new(0.60, Color3.fromRGB(180, 255, 200)), -- Xanh lá nhạt
    ColorSequenceKeypoint.new(0.80, Color3.fromRGB(180, 220, 255)), -- Xanh dương nhạt
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(220, 180, 255))  -- Tím nhạt
})

-- Tạo hoạt ảnh xoay góc Rainbow liên tục nhẹ nhàng
local tweenInfo = TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false)
local tween = TweenService:Create(RainbowGradient, tweenInfo, {Rotation = 360})
tween:Play()

-- Viền menu
local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(255, 255, 255)
FrameStroke.Thickness = 2
FrameStroke.Parent = MainFrame

-- Tiêu đề Menu
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TitleBar.BackgroundTransparency = 0.6 -- Làm mờ thanh tiêu đề để thấy hiệu ứng phía sau

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- Avatar trên tiêu đề
local HeaderAvatar = Instance.new("ImageLabel")
HeaderAvatar.Name = "HeaderAvatar"
HeaderAvatar.Parent = TitleBar
HeaderAvatar.Position = UDim2.new(0, 10, 0.5, -15)
HeaderAvatar.Size = UDim2.new(0, 30, 0, 30)
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
TitleText.Text = "TỔNG HỢP SAE | 👑VzNam Hub👑|"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 17
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- Khung cuộn chứa script
local Scroll = Instance.new("ScrollingFrame")
Scroll.Parent = MainFrame
Scroll.Position = UDim2.new(0, 10, 0, 52)
Scroll.Size = UDim2.new(1, -20, 1, -60)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 2000)
Scroll.ScrollBarThickness = 4

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Scroll
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- Hàm tạo nút (Nút mờ sang trọng)
local function AddScriptButton(Name, Callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Scroll
    Btn.Size = UDim2.new(1, 0, 0, 38)
    Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Btn.BackgroundTransparency = 0.25 -- Nút hơi trong suốt để hiện hiệu ứng cầu vồng
    Btn.Text = Name
    Btn.TextColor3 = Color3.fromRGB(40, 40, 40)
    Btn.Font = Enum.Font.SourceSansSemibold
    Btn.TextSize = 15
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Btn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(255, 255, 255)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn
    
    Btn.MouseButton1Click:Connect(Callback)
end

-- DANH SÁCH SCRIPT
AddScriptButton("1. Infinite Yield (Admin)", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end)

AddScriptButton("2. Fly Script (Bay)", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source"))()
end)

AddScriptButton("3. FyyCommunity", function()

loadstring(game:HttpGet("https://FyyCommunity.my.id"))()
end)

AddScriptButton("4. Chilli Hub V3", function()
    loadstring(game:HttpGet("https://apexhubeditor.vercel.app/api/raw?name=6bzPiAYUA0ekyyvhOhxpPobkK643_chilli-hub-vit-ho-v3"))()
end)

AddScriptButton("5. Realkid hub",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/realkidhub/realkid/refs/heads/main/main.lua"))()
end)

AddScriptButton("6. Speed hub", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()
end)

AddScriptButton("7. Chữ A(ajjans)", function()
    loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/359e97f8618e9008afe5f496184ebb7c.lua"))()
end)

AddScriptButton("8. Bigfroot", function()

loadstring(game:HttpGet("https://raw.githubusercontent.com/hanniii1/Loader/refs/heads/main/BFLoader.lua"))()    
end)
-- BẤM NÚT TRÒN BẬT/TẮT MENU
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)
