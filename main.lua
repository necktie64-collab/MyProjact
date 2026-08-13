--[[
    =============================================================================
    Anime Defenders - Modern Educational Script & Multi-Selection UI
    =============================================================================
    หัวข้อ: การทำระบบ Dropdown / Multi-Option Selection สำหรับเลือก Banner และเลือกด่าน
    เป้าหมาย: ใช้สำหรับศึกษาวิธีส่ง Argument (ค่าพารามิเตอร์) ไปพร้อมกับ RemoteEvent
]]

-- [1] เรียกใช้งาน Services ที่จำเป็น
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- [2] ตัวแปรจัดการสถานะและตัวเลือก (State & Selection Management)
local SystemState = {
    AutoFarm = false,
    AutoSummon = false,
    AutoReplay = false,
    
    -- ค่าตัวเลือกเริ่มต้นสำหรับ Banner และ ด่าน (Map/Stage)
    SelectedBanner = "Banner 1", -- ตัวเลือก: "Banner 1", "Banner 2", "Wish Banner"
    SelectedStage = "Stage 1",   -- ตัวเลือก: "Stage 1", "Stage 2", "Infinite Mode"
}

-- [3] การกำหนดพาธ RemoteEvent สำหรับเกม Anime Defenders
local Remotes = {
    PlaceUnit = pcall(function() return ReplicatedStorage:WaitForChild("networks", 2):WaitForChild("place_unit", 2) end) and ReplicatedStorage:FindFirstChild("networks") and ReplicatedStorage.networks:FindFirstChild("place_unit"),
    Summon    = pcall(function() return ReplicatedStorage:WaitForChild("networks", 2):WaitForChild("summon", 2) end) and ReplicatedStorage:FindFirstChild("networks") and ReplicatedStorage.networks:FindFirstChild("summon"),
    Replay    = pcall(function() return ReplicatedStorage:WaitForChild("networks", 2):WaitForChild("retry", 2) end) and ReplicatedStorage:FindFirstChild("networks") and ReplicatedStorage.networks:FindFirstChild("retry"),
}

-- [4] ทำความสะอาด UI เก่าก่อนสร้างใหม่ (Prevent Duplicates)
local existingUI = CoreGui:FindFirstChild("AnimeDefenders_PremiumUI") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("AnimeDefenders_PremiumUI")
if existingUI then
    existingUI:Destroy()
end

-- สร้าง ScreenGui สำหรับแสดงผล
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AnimeDefenders_PremiumUI"
ScreenGui.ResetOnSpawn = false

local targetParent = nil
if gethui then
    targetParent = gethui()
else
    local success, _ = pcall(function()
        targetParent = CoreGui
    end)
    if not success or not targetParent then
        targetParent = LocalPlayer:WaitForChild("PlayerGui")
    end
end
ScreenGui.Parent = targetParent

-- =============================================================================
-- [5] การออกแบบโครงสร้างหลักของ UI (Main Window & Scrolling Frame)
-- =============================================================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 370, 0, 480)
MainFrame.Position = UDim2.new(0.5, -185, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 60, 80)
MainStroke.Thickness = 1.5
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

-- แถบหัวข้อด้านบน (Header Bar)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 14)
HeaderCorner.Parent = Header

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 10, 0, 10)
StatusDot.Position = UDim2.new(0, 16, 0.5, -5)
StatusDot.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = Header

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = StatusDot

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -70, 1, 0)
TitleText.Position = UDim2.new(0, 34, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "ANIME DEFENDERS"
TitleText.TextColor3 = Color3.fromRGB(240, 240, 255)
TitleText.TextSize = 15
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = Header

local SubtitleText = Instance.new("TextLabel")
SubtitleText.Size = UDim2.new(1, -70, 0, 14)
SubtitleText.Position = UDim2.new(0, 34, 0.6, -2)
SubtitleText.BackgroundTransparency = 1
SubtitleText.Text = "Multi-Option & Remote System v2.0"
SubtitleText.TextColor3 = Color3.fromRGB(130, 130, 160)
SubtitleText.TextSize = 10
SubtitleText.Font = Enum.Font.GothamMedium
SubtitleText.TextXAlignment = Enum.TextXAlignment.Left
SubtitleText.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- =============================================================================
-- [6] Scrolling Frame สำหรับใส่เมนูจำนวนมาก
-- =============================================================================

local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Name = "ScrollContainer"
ScrollContainer.Size = UDim2.new(1, -24, 1, -65)
ScrollContainer.Position = UDim2.new(0, 12, 0, 58)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.ScrollBarThickness = 4
ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 110)
ScrollContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollContainer
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end)

-- =============================================================================
-- [7] ฟังก์ชันสร้าง Selector / Option Card (ตัวเลือก Banner / ด่าน)
-- =============================================================================

local function createOptionSelector(title, optionsTable, defaultChoice, onSelectCallback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 75)
    Container.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    Container.BorderSizePixel = 0
    Container.Parent = ScrollContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Container

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(45, 45, 60)
    Stroke.Thickness = 1
    Stroke.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 12, 0, 10)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.TextColor3 = Color3.fromRGB(230, 230, 245)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    -- ปุ่มเลือก Option
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, -24, 0, 32)
    ButtonFrame.Position = UDim2.new(0, 12, 0, 35)
    ButtonFrame.BackgroundTransparency = 1
    ButtonFrame.Parent = Container

    local ButtonLayout = Instance.new("UIListLayout")
    ButtonLayout.Parent = ButtonFrame
    ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    ButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ButtonLayout.Padding = UDim.new(0, 8)

    local currentSelection = defaultChoice

    for _, optionName in ipairs(optionsTable) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1 / #optionsTable, -6, 1, 0)
        OptBtn.BackgroundColor3 = (optionName == currentSelection) and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(40, 40, 52)
        OptBtn.Text = optionName
        OptBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
        OptBtn.TextSize = 11
        OptBtn.Font = Enum.Font.GothamMedium
        OptBtn.Parent = ButtonFrame

        local OptCorner = Instance.new("UICorner")
        OptCorner.CornerRadius = UDim.new(0, 6)
        OptCorner.Parent = OptBtn

        OptBtn.MouseButton1Click:Connect(function()
            currentSelection = optionName
            for _, btn in ipairs(ButtonFrame:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = (btn.Text == currentSelection) and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(40, 40, 52)
                end
            end
            if onSelectCallback then
                onSelectCallback(currentSelection)
            end
        end)
    end
end

-- =============================================================================
-- [8] ฟังก์ชันสร้าง Toggle Card (เปิด/ปิด ออโต้)
-- =============================================================================

local function createToggleCard(title, subtitle, stateKey, callback)
    local Card = Instance.new("Frame")
    Card.Name = title .. "_Card"
    Card.Size = UDim2.new(1, 0, 0, 60)
    Card.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    Card.BorderSizePixel = 0
    Card.Parent = ScrollContainer

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 10)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = Color3.fromRGB(45, 45, 60)
    CardStroke.Thickness = 1
    CardStroke.Parent = Card

    local CardTitle = Instance.new("TextLabel")
    CardTitle.Size = UDim2.new(0.7, 0, 0, 18)
    CardTitle.Position = UDim2.new(0, 12, 0, 10)
    CardTitle.BackgroundTransparency = 1
    CardTitle.Text = title
    CardTitle.TextColor3 = Color3.fromRGB(230, 230, 245)
    CardTitle.TextSize = 13
    CardTitle.Font = Enum.Font.GothamBold
    CardTitle.TextXAlignment = Enum.TextXAlignment.Left
    CardTitle.Parent = Card

    local CardSub = Instance.new("TextLabel")
    CardSub.Size = UDim2.new(0.7, 0, 0, 14)
    CardSub.Position = UDim2.new(0, 12, 0, 32)
    CardSub.BackgroundTransparency = 1
    CardSub.Text = subtitle
    CardSub.TextColor3 = Color3.fromRGB(130, 130, 155)
    CardSub.TextSize = 10
    CardSub.Font = Enum.Font.Gotham
    CardSub.TextXAlignment = Enum.TextXAlignment.Left
    CardSub.Parent = Card

    local SwitchPill = Instance.new("Frame")
    SwitchPill.Size = UDim2.new(0, 44, 0, 24)
    SwitchPill.Position = UDim2.new(1, -54, 0.5, -12)
    SwitchPill.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    SwitchPill.BorderSizePixel = 0
    SwitchPill.Parent = Card

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = SwitchPill

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 18, 0, 18)
    Knob.Position = UDim2.new(0, 3, 0.5, -9)
    Knob.BackgroundColor3 = Color3.fromRGB(180, 180, 200)
    Knob.BorderSizePixel = 0
    Knob.Parent = SwitchPill

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local ClickArea = Instance.new("TextButton")
    ClickArea.Size = UDim2.new(1, 0, 1, 0)
    ClickArea.BackgroundTransparency = 1
    ClickArea.Text = ""
    ClickArea.Parent = Card

    ClickArea.MouseButton1Click:Connect(function()
        SystemState[stateKey] = not SystemState[stateKey]
        local isON = SystemState[stateKey]

        local targetPillColor = isON and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(45, 45, 60)
        local targetKnobPos = isON and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        local targetKnobColor = isON and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 200)

        TweenService:Create(SwitchPill, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = targetPillColor}):Play()
        TweenService:Create(Knob, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Position = targetKnobPos, BackgroundColor3 = targetKnobColor}):Play()

        if callback then
            callback(isON)
        end
    end)
end

-- =============================================================================
-- [9] สร้างการตั้งค่าตัวเลือก (Select Banner & Select Stage)
-- =============================================================================

-- ตัวเลือก Banner สุ่มยูนิต
createOptionSelector("🎯 เลือก Banner สำหรับสุ่ม:", {"Banner 1", "Banner 2", "Wish"}, "Banner 1", function(selected)
    SystemState.SelectedBanner = selected
    print("เลือก Banner: ", selected)
end)

-- ตัวเลือก ด่าน / Map
createOptionSelector("🗺️ เลือกด่าน / โหมด:", {"Stage 1", "Stage 2", "Infinite"}, "Stage 1", function(selected)
    SystemState.SelectedStage = selected
    print("เลือกด่าน: ", selected)
end)

-- =============================================================================
-- [10] สร้างรายการเมนูสวิตช์เปิด/ปิด (Auto Farm / Auto Buy / Auto Replay)
-- =============================================================================

createToggleCard("Auto Farm Units", "ระบบวางยูนิตต่อสู้ให้อัตโนมัติ", "AutoFarm", function(isOn)
    print("Auto Farm: ", isOn)
end)

createToggleCard("Auto Summon / Buy", "สุ่มยูนิตตาม Banner ที่เลือกด้านบน", "AutoSummon", function(isOn)
    print("Auto Summon: ", isOn, " | Target Banner: ", SystemState.SelectedBanner)
end)

createToggleCard("Auto Replay / Join Stage", "เริ่มเล่นด่านตาม Stage ที่เลือกด้านบน", "AutoReplay", function(isOn)
    print("Auto Replay: ", isOn, " | Target Stage: ", SystemState.SelectedStage)
end)

-- =============================================================================
-- [11] ลูปประมวลผลพร้อมส่งพารามิเตอร์ (Dynamic Argument Loop)
-- =============================================================================

task.spawn(function()
    while true do
        task.wait(1.5)

        -- 1. Auto Farm
        if SystemState.AutoFarm then
            pcall(function()
                if Remotes.PlaceUnit then
                    Remotes.PlaceUnit:FireServer(SystemState.SelectedStage)
                end
            end)
        end

        -- 2. Auto Summon (ส่งชื่อ Banner ที่เลือกไปด้วย!)
        if SystemState.AutoSummon then
            pcall(function()
                if Remotes.Summon then
                    -- ส่งคำสั่งสุ่มยูนิต พร้อมแนบชื่อ Banner ที่ผู้เล่นเลือกจากเมนู!
                    Remotes.Summon:FireServer(SystemState.SelectedBanner, 10)
                    print("[RemoteEvent]: Summoning from ", SystemState.SelectedBanner)
                end
            end)
        end

        -- 3. Auto Replay (ส่งชื่อ ด่าน/Stage ที่เลือกไปด้วย!)
        if SystemState.AutoReplay then
            pcall(function()
                if Remotes.Replay then
                    -- ส่งคำสั่งเข้าด่าน พร้อมแนบชื่อ ด่าน ที่ผู้เล่นเลือกจากเมนู!
                    Remotes.Replay:FireServer(SystemState.SelectedStage)
                    print("[RemoteEvent]: Joining Stage ", SystemState.SelectedStage)
                end
            end)
        end
    end
end)

print("Anime Defenders Multi-Option UI Loaded Successfully!")
