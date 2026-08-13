--[[
    =============================================================================
    Anime Defenders - Modern Educational Script & Explicit Target Selection System
    =============================================================================
    หัวข้อ: การทำระบบเลือกจุดหมาย (Explicit Selection) และการระบุเป้าหมายเจาะจงในเกม
    เป้าหมาย: ใช้สำหรับการเรียนรู้การรับค่า Input/Dropdown เพื่อระบุการวาร์ปและการสุ่มยูนิต
]]

-- [1] เรียกใช้งาน Services ที่จำเป็น
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- [2] ตัวแปรระบุเป้าหมายอย่างชัดเจน (Explicit User Choices)
local SystemState = {
    AutoFarm = false,
    AutoSummon = false,
    AutoReplay = false,
    
    -- ผู้เล่นกำหนดเจาะจงว่าจะไปด่านไหน และสุ่มตู้ไหน
    SelectedWorld = "Windmill Village", -- ด่าน/แมพ ที่เลือก
    SelectedBanner = "Limited Banner",  -- ตู้สุ่มที่เลือก
    SummonAmount = 10,                 -- จำนวนสุ่ม (1 หรือ 10)
}

-- รายชื่อด่านและตู้สุ่มที่มีให้เลือกในระบบ
local AvailableWorlds = {"Windmill Village", "Demon City", "Planet Namek", "Infinite Arena"}
local AvailableBanners = {"Limited Banner", "Standard Banner", "Wish Banner"}

-- [3] การกำหนดพาธ RemoteEvent สำหรับเกม Anime Defenders
local Remotes = {
    PlaceUnit = pcall(function() return ReplicatedStorage:WaitForChild("networks", 2):WaitForChild("place_unit", 2) end) and ReplicatedStorage:FindFirstChild("networks") and ReplicatedStorage.networks:FindFirstChild("place_unit"),
    Summon    = pcall(function() return ReplicatedStorage:WaitForChild("networks", 2):WaitForChild("summon", 2) end) and ReplicatedStorage:FindFirstChild("networks") and ReplicatedStorage.networks:FindFirstChild("summon"),
    Replay    = pcall(function() return ReplicatedStorage:WaitForChild("networks", 2):WaitForChild("retry", 2) end) and ReplicatedStorage:FindFirstChild("networks") and ReplicatedStorage.networks:FindFirstChild("retry"),
    Teleport  = pcall(function() return ReplicatedStorage:WaitForChild("networks", 2):WaitForChild("teleport_world", 2) end) and ReplicatedStorage:FindFirstChild("networks") and ReplicatedStorage.networks:FindFirstChild("teleport_world"),
}

-- [4] ทำความสะอาด UI เก่าก่อนสร้างใหม่
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
MainFrame.Size = UDim2.new(0, 380, 0, 520)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
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
SubtitleText.Text = "Explicit Target & Map Selection v3.0"
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
-- [6] Scrolling Frame สำหรับใส่หมวดหมู่การตั้งค่า
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

-- ฟังก์ชันสร้าง Section Header (หัวข้อแบ่งหมวดหมู่)
local function createSectionHeader(titleText)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 24)
    Label.BackgroundTransparency = 1
    Label.Text = titleText
    Label.TextColor3 = Color3.fromRGB(160, 160, 200)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ScrollContainer
end

-- =============================================================================
-- [7] ฟังก์ชันสร้าง Option Selector (ระบุตู้สุ่ม / ระบุแมพที่จะไป)
-- =============================================================================

local function createGridSelector(title, optionsList, defaultSelection, onSelect)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 80)
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
    Label.Position = UDim2.new(0, 12, 0, 8)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.TextColor3 = Color3.fromRGB(230, 230, 245)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, -24, 0, 36)
    ButtonFrame.Position = UDim2.new(0, 12, 0, 34)
    ButtonFrame.BackgroundTransparency = 1
    ButtonFrame.Parent = Container

    local GridLayout = Instance.new("UIGridLayout")
    GridLayout.Parent = ButtonFrame
    GridLayout.CellSize = UDim2.new(1 / #optionsList, -6, 1, 0)
    GridLayout.CellPadding = UDim2.new(0, 6, 0, 0)

    local activeChoice = defaultSelection

    for _, optionName in ipairs(optionsList) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.BackgroundColor3 = (optionName == activeChoice) and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(40, 40, 52)
        OptBtn.Text = optionName
        OptBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
        OptBtn.TextSize = 10
        OptBtn.Font = Enum.Font.GothamMedium
        OptBtn.Parent = ButtonFrame

        local OptCorner = Instance.new("UICorner")
        OptCorner.CornerRadius = UDim.new(0, 6)
        OptCorner.Parent = OptBtn

        OptBtn.MouseButton1Click:Connect(function()
            activeChoice = optionName
            for _, btn in ipairs(ButtonFrame:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = (btn.Text == activeChoice) and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(40, 40, 52)
                end
            end
            if onSelect then
                onSelect(activeChoice)
            end
        end)
    end
end

-- =============================================================================
-- [8] ฟังก์ชันสร้าง Toggle Card (เปิด/ปิด ระบบออโต้)
-- =============================================================================

local function createToggleCard(title, subtitle, stateKey)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 56)
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
    CardTitle.Position = UDim2.new(0, 12, 0, 8)
    CardTitle.BackgroundTransparency = 1
    CardTitle.Text = title
    CardTitle.TextColor3 = Color3.fromRGB(230, 230, 245)
    CardTitle.TextSize = 13
    CardTitle.Font = Enum.Font.GothamBold
    CardTitle.TextXAlignment = Enum.TextXAlignment.Left
    CardTitle.Parent = Card

    local CardSub = Instance.new("TextLabel")
    CardSub.Size = UDim2.new(0.7, 0, 0, 14)
    CardSub.Position = UDim2.new(0, 12, 0, 28)
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
    end)
end

-- =============================================================================
-- [9] สร้างหน้าต่างเมนูแยกตามหมวดหมู่ (Sections)
-- =============================================================================

-- หมวดหมู่ที่ 1: เลือกแมพ/ด่าน
createSectionHeader("🗺️ MAP & WORLD SELECTION")
createGridSelector("ระบุแมพที่ต้องการจะไป / เล่น:", AvailableWorlds, SystemState.SelectedWorld, function(selected)
    SystemState.SelectedWorld = selected
    print("[User Choice]: เลือกแมพ -> ", selected)
end)

-- หมวดหมู่ที่ 2: เลือกตู้สุ่ม
createSectionHeader("🎯 SUMMON & BANNER SELECTION")
createGridSelector("ระบุตู้สุ่มที่ต้องการสุ่ม:", AvailableBanners, SystemState.SelectedBanner, function(selected)
    SystemState.SelectedBanner = selected
    print("[User Choice]: เลือกตู้สุ่ม -> ", selected)
end)

-- หมวดหมู่ที่ 3: สวิตช์การทำงานอัตโนมัติ
createSectionHeader("⚡ AUTOMATION CONTROLS")
createToggleCard("Auto Teleport / Join", "วาร์ปเข้าแมพตามที่ระบุไว้ด้านบน", "AutoReplay")
createToggleCard("Auto Summon Units", "สุ่มยูนิตตามตู้ที่ระบุไว้ด้านบน", "AutoSummon")
createToggleCard("Auto Farm Stage", "วางยูนิตและต่อสู้ในด่านให้อัตโนมัติ", "AutoFarm")

-- =============================================================================
-- [10] ลูปส่งสัญญาณตามค่าที่ผู้เล่นเลือกเจาะจง (Explicit Argument Loop)
-- =============================================================================

task.spawn(function()
    while true do
        task.wait(1.5)

        -- 1. สั่งวาร์ปเข้าแมพตามที่ผู้เล่นเลือกบนเมนู
        if SystemState.AutoReplay then
            pcall(function()
                if Remotes.Teleport then
                    Remotes.Teleport:FireServer(SystemState.SelectedWorld)
                    print("[RemoteEvent]: Teleporting player to -> ", SystemState.SelectedWorld)
                end
            end)
        end

        -- 2. สั่งสุ่มยูนิตตามตู้ที่ผู้เล่นเลือกบนเมนู
        if SystemState.AutoSummon then
            pcall(function()
                if Remotes.Summon then
                    Remotes.Summon:FireServer(SystemState.SelectedBanner, SystemState.SummonAmount)
                    print("[RemoteEvent]: Summoning 10x from -> ", SystemState.SelectedBanner)
                end
            end)
        end

        -- 3. ออโต้ฟาร์ม
        if SystemState.AutoFarm then
            pcall(function()
                if Remotes.PlaceUnit then
                    Remotes.PlaceUnit:FireServer(SystemState.SelectedWorld)
                end
            end)
        end
    end
end)

print("Anime Defenders Explicit Selection UI Loaded!")
