--[[
    =============================================================================
    Anime Defenders - Professional Multi-Tab & Hierarchical Stage UI
    =============================================================================
    หัวข้อ: การออกแบบ UI แบบ Tab Navigation และระบบคัดเลือกด่านแบบลำดับชั้น (World -> Act -> Difficulty)
    เป้าหมาย: ใช้สำหรับศึกษาระบบ UI ซับซ้อนระดับโปรและการจัดหมวดหมู่ข้อมูลในเกม Tower Defense
]]

-- [1] เรียกใช้งาน Services ที่จำเป็น
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- [2] โครงสร้างข้อมูลด่านและตัวเลือกทั้งหมด (Hierarchical Data Structure)
local GameData = {
    Worlds = {
        "Windmill Village",
        "Cursed Academy",
        "Demon City",
        "Swordsman City",
        "Underwater City"
    },
    Acts = {
        "Act 1", "Act 2", "Act 3",
        "Act 4", "Act 5", "Act 6", "Infinite"
    },
    Difficulties = {
        "Normal", "Hard", "Nightmare"
    },
    Banners = {
        "Banner 1 (Limited)",
        "Banner 2 (Standard)",
        "Wish Banner"
    }
}

-- [3] ตัวแปรจัดการสถานะระบบ (System State & Selection)
local SystemState = {
    -- สวิตช์การทำงาน
    AutoFarm = false,
    AutoSummon = false,
    AutoReplay = false,
    AutoLeaveOnDefeat = false,

    -- ค่าที่เลือกเจาะจง (Selected Options)
    SelectedWorld = "Windmill Village",
    SelectedAct = "Act 1",
    SelectedDifficulty = "Normal",
    SelectedBanner = "Banner 1 (Limited)",
    SummonAmount = 10,
}

-- [4] การกำหนดพาธ RemoteEvent สำหรับเกม Anime Defenders
local Remotes = {
    JoinStage = pcall(function() return ReplicatedStorage:WaitForChild("networks", 2):WaitForChild("join_stage", 2) end) and ReplicatedStorage:FindFirstChild("networks") and ReplicatedStorage.networks:FindFirstChild("join_stage"),
    PlaceUnit  = pcall(function() return ReplicatedStorage:WaitForChild("networks", 2):WaitForChild("place_unit", 2) end) and ReplicatedStorage:FindFirstChild("networks") and ReplicatedStorage.networks:FindFirstChild("place_unit"),
    Summon     = pcall(function() return ReplicatedStorage:WaitForChild("networks", 2):WaitForChild("summon", 2) end) and ReplicatedStorage:FindFirstChild("networks") and ReplicatedStorage.networks:FindFirstChild("summon"),
    Replay     = pcall(function() return ReplicatedStorage:WaitForChild("networks", 2):WaitForChild("retry", 2) end) and ReplicatedStorage:FindFirstChild("networks") and ReplicatedStorage.networks:FindFirstChild("retry"),
}

-- [5] ทำความสะอาด UI เก่าก่อนสร้างใหม่
local existingUI = CoreGui:FindFirstChild("AnimeDefenders_ProUI") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("AnimeDefenders_ProUI")
if existingUI then
    existingUI:Destroy()
end

-- สร้าง ScreenGui หลัก
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AnimeDefenders_ProUI"
ScreenGui.ResetOnSpawn = false

local targetParent = nil
if gethui then
    targetParent = gethui()
else
    local success, _ = pcall(function() targetParent = CoreGui end)
    if not success or not targetParent then
        targetParent = LocalPlayer:WaitForChild("PlayerGui")
    end
end
ScreenGui.Parent = targetParent

-- =============================================================================
-- [6] การออกแบบกรอบหลักแบบ มี Sidebar Navigation Tabs
-- =============================================================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 360)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(50, 50, 70)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Sidebar ฝั่งซ้ายสำหรับเลือก Tab
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 12)
SidebarCorner.Parent = Sidebar

-- ชื่อสคริปต์ใน Sidebar
local LogoTitle = Instance.new("TextLabel")
LogoTitle.Size = UDim2.new(1, 0, 0, 45)
LogoTitle.BackgroundTransparency = 1
LogoTitle.Text = "ANIME HUB"
LogoTitle.TextColor3 = Color3.fromRGB(99, 102, 241)
LogoTitle.TextSize = 16
LogoTitle.Font = Enum.Font.GothamBold
LogoTitle.Parent = Sidebar

-- คอนเทนเนอร์ใส่ปุ่ม Tab
local TabButtonContainer = Instance.new("Frame")
TabButtonContainer.Size = UDim2.new(1, -16, 1, -55)
TabButtonContainer.Position = UDim2.new(0, 8, 0, 45)
TabButtonContainer.BackgroundTransparency = 1
TabButtonContainer.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabButtonContainer
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 6)

-- พื้นที่แสดงผลเนื้อหาฝั่งขวา (Content Area)
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -145, 1, -16)
ContentArea.Position = UDim2.new(0, 138, 0, 8)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- =============================================================================
-- [7] ระบบสลับหน้า Tab (Tab Switching Logic)
-- =============================================================================

local Tabs = {}
local TabButtons = {}

local function createTab(tabName, tabIcon)
    -- สร้างหน้า Content ของ Tab
    local Page = Instance.new("ScrollingFrame")
    Page.Name = tabName .. "_Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 110)
    Page.Visible = false
    Page.Parent = ContentArea

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Parent = Page
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 8)

    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 15)
    end)

    -- สร้างปุ่ม Tab บน Sidebar
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 36)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    TabBtn.Text = tabIcon .. " " .. tabName
    TabBtn.TextColor3 = Color3.fromRGB(160, 160, 190)
    TabBtn.TextSize = 12
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = TabButtonContainer

    local BtnPadding = Instance.new("UIPadding")
    BtnPadding.PaddingLeft = UDim.new(0, 10)
    BtnPadding.Parent = TabBtn

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = TabBtn

    Tabs[tabName] = Page
    TabButtons[tabName] = TabBtn

    TabBtn.MouseButton1Click:Connect(function()
        for name, page in pairs(Tabs) do
            page.Visible = (name == tabName)
        end
        for name, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = (name == tabName) and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(30, 30, 42)
            btn.TextColor3 = (name == tabName) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 190)
        end
    end)

    return Page
end

-- สร้าง 3 Tab หลัก
local StageTab  = createTab("Farm & Stage", "⚔️")
local SummonTab = createTab("Summon", "🎯")
local SettingsTab = createTab("Settings", "⚙️")

-- เปิด Tab แรกเป็นค่าเริ่มต้น
Tabs["Farm & Stage"].Visible = true
TabButtons["Farm & Stage"].BackgroundColor3 = Color3.fromRGB(99, 102, 241)
TabButtons["Farm & Stage"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- =============================================================================
-- [8] ฟังก์ชันสร้าง Component ตัวเลือก (Dropdown & Buttons Grid)
-- =============================================================================

local function addSectionTitle(parentPage, text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(140, 140, 180)
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parentPage
end

local function addOptionSelector(parentPage, title, optionsList, currentChoice, onSelect)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 58)
    Frame.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    Frame.BorderSizePixel = 0
    Frame.Parent = parentPage

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -16, 0, 18)
    Label.Position = UDim2.new(0, 8, 0, 6)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.TextColor3 = Color3.fromRGB(220, 220, 240)
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Grid = Instance.new("Frame")
    Grid.Size = UDim2.new(1, -16, 0, 26)
    Grid.Position = UDim2.new(0, 8, 0, 26)
    Grid.BackgroundTransparency = 1
    Grid.Parent = Frame

    local GridLayout = Instance.new("UIGridLayout")
    GridLayout.Parent = Grid
    GridLayout.CellSize = UDim2.new(1 / #optionsList, -4, 1, 0)
    GridLayout.CellPadding = UDim2.new(0, 4, 0, 0)

    local selected = currentChoice

    for _, name in ipairs(optionsList) do
        local Btn = Instance.new("TextButton")
        Btn.BackgroundColor3 = (name == selected) and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(36, 36, 50)
        Btn.Text = name
        Btn.TextColor3 = Color3.fromRGB(240, 240, 255)
        Btn.TextSize = 10
        Btn.Font = Enum.Font.GothamMedium
        Btn.Parent = Grid

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = Btn

        Btn.MouseButton1Click:Connect(function()
            selected = name
            for _, child in ipairs(Grid:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = (child.Text == selected) and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(36, 36, 50)
                end
            end
            onSelect(selected)
        end)
    end
end

local function addToggleCard(parentPage, title, subtitle, stateKey)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 52)
    Card.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    Card.BorderSizePixel = 0
    Card.Parent = parentPage

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 8)
    CardCorner.Parent = Card

    local CardTitle = Instance.new("TextLabel")
    CardTitle.Size = UDim2.new(0.7, 0, 0, 16)
    CardTitle.Position = UDim2.new(0, 10, 0, 8)
    CardTitle.BackgroundTransparency = 1
    CardTitle.Text = title
    CardTitle.TextColor3 = Color3.fromRGB(230, 230, 245)
    CardTitle.TextSize = 12
    CardTitle.Font = Enum.Font.GothamBold
    CardTitle.TextXAlignment = Enum.TextXAlignment.Left
    CardTitle.Parent = Card

    local CardSub = Instance.new("TextLabel")
    CardSub.Size = UDim2.new(0.7, 0, 0, 14)
    CardSub.Position = UDim2.new(0, 10, 0, 26)
    CardSub.BackgroundTransparency = 1
    CardSub.Text = subtitle
    CardSub.TextColor3 = Color3.fromRGB(130, 130, 155)
    CardSub.TextSize = 10
    CardSub.Font = Enum.Font.Gotham
    CardSub.TextXAlignment = Enum.TextXAlignment.Left
    CardSub.Parent = Card

    local SwitchPill = Instance.new("Frame")
    SwitchPill.Size = UDim2.new(0, 40, 0, 22)
    SwitchPill.Position = UDim2.new(1, -48, 0.5, -11)
    SwitchPill.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    SwitchPill.BorderSizePixel = 0
    SwitchPill.Parent = Card

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = SwitchPill

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = UDim2.new(0, 3, 0.5, -8)
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
        local targetKnobPos = isON and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)

        TweenService:Create(SwitchPill, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetPillColor}):Play()
        TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = targetKnobPos}):Play()
    end)
end

-- =============================================================================
-- [9] ใส่เนื้อหาในแต่ละ Tab (Populating Tab Contents)
-- =============================================================================

-- --- TAB 1: Farm & Stage ---
addSectionTitle(StageTab, "🗺️ SELECT WORLD & MAP")
addOptionSelector(StageTab, "เลือกแมพ (World):", {"Windmill", "Cursed", "Demon", "Swordsman"}, "Windmill", function(val)
    SystemState.SelectedWorld = val
    print("Selected World: ", val)
end)

addSectionTitle(StageTab, "📜 SELECT ACT & DIFFICULTY")
addOptionSelector(StageTab, "เลือก Act:", {"Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6"}, "Act 1", function(val)
    SystemState.SelectedAct = val
    print("Selected Act: ", val)
end)

addOptionSelector(StageTab, "เลือกระดับความยาก (Difficulty):", GameData.Difficulties, "Normal", function(val)
    SystemState.SelectedDifficulty = val
    print("Selected Difficulty: ", val)
end)

addSectionTitle(StageTab, "⚡ AUTO CONTROLS")
addToggleCard(StageTab, "Auto Join Selected Stage", "วาร์ปเข้าด่านตาม World + Act + Difficulty ที่เลือก", "AutoReplay")
addToggleCard(StageTab, "Auto Farm Units", "สั่งวางยูนิตและต่อสู้อัตโนมัติ", "AutoFarm")

-- --- TAB 2: Summon ---
addSectionTitle(SummonTab, "🎯 SUMMON BANNER SELECTION")
addOptionSelector(SummonTab, "เลือกตู้สุ่ม (Banner):", {"Banner 1", "Banner 2", "Wish"}, "Banner 1", function(val)
    SystemState.SelectedBanner = val
    print("Selected Banner: ", val)
end)

addSectionTitle(SummonTab, "⚡ SUMMON CONTROLS")
addToggleCard(SummonTab, "Auto Summon Units", "สุ่มยูนิตตามตู้ที่เลือกไว้อัตโนมัติ", "AutoSummon")

-- --- TAB 3: Settings ---
addSectionTitle(SettingsTab, "⚙️ SYSTEM SETTINGS")
addToggleCard(SettingsTab, "Auto Leave on Defeat", "ออกจากด่านให้อัตโนมัติเมื่อแพ้", "AutoLeaveOnDefeat")

-- =============================================================================
-- [10] ลูปส่งสัญญาณ RemoteEvent แบบสมบูรณ์ (World + Act + Difficulty)
-- =============================================================================

task.spawn(function()
    while true do
        task.wait(1.5)

        -- ยิงคำสั่งเข้าเล่นด่าน พร้อมส่ง World + Act + Difficulty ไปพร้อมกัน!
        if SystemState.AutoReplay then
            pcall(function()
                if Remotes.JoinStage then
                    Remotes.JoinStage:FireServer(SystemState.SelectedWorld, SystemState.SelectedAct, SystemState.SelectedDifficulty)
                    print(string.format("[RemoteEvent]: Joining -> %s | %s | %s", SystemState.SelectedWorld, SystemState.SelectedAct, SystemState.SelectedDifficulty))
                end
            end)
        end

        -- ยิงคำสั่งสุ่มยูนิต
        if SystemState.AutoSummon then
            pcall(function()
                if Remotes.Summon then
                    Remotes.Summon:FireServer(SystemState.SelectedBanner, SystemState.SummonAmount)
                    print(string.format("[RemoteEvent]: Summoning 10x from -> %s", SystemState.SelectedBanner))
                end
            end)
        end
    end
end)

print("Anime Defenders Multi-Tab Hierarchical UI Loaded!")
