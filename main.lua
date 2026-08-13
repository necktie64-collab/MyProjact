--[[
    =============================================================================
    Anime Defenders - Professional UI with Keybind Toggle & Key Configuration
    =============================================================================
    หัวข้อ: การทำระบบซ่อน/แสดงหน้าต่างด้วย Keybind (RightControl) และการตั้งค่าปุ่ม
    เป้าหมาย: ใช้สำหรับศึกษาระบบ UserInputService, Keybind Configuration และการทำ Floating Toggle Button
]]

-- [1] เรียกใช้งาน Services ที่จำเป็น
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- [2] โครงสร้างข้อมูลด่านและตู้สุ่ม
local GameData = {
    Worlds = {"Windmill", "Cursed", "Demon", "Swordsman", "Underwater"},
    Acts = {"Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6", "Infinite"},
    Difficulties = {"Normal", "Hard", "Nightmare"},
    Banners = {"Banner 1", "Banner 2", "Wish"},
    
    -- รายชื่อปุ่มคีย์ลัดที่มีให้เลือกในเมนูตั้งค่า
    KeybindOptions = {
        {Name = "Right Ctrl", Key = Enum.KeyCode.RightControl},
        {Name = "Right Shift", Key = Enum.KeyCode.RightShift},
        {Name = "Right Alt", Key = Enum.KeyCode.RightAlt},
        {Name = "F3 Key", Key = Enum.KeyCode.F3},
    }
}

-- [3] ตัวแปรจัดการสถานะระบบ (System State & User Choices)
local SystemState = {
    AutoFarm = false,
    AutoSummon = false,
    AutoReplay = false,
    AutoLeaveOnDefeat = false,

    SelectedWorld = "Windmill",
    SelectedAct = "Act 1",
    SelectedDifficulty = "Normal",
    SelectedBanner = "Banner 1",
    SummonAmount = 10,
    
    -- ปุ่มคีย์ลัดซ่อน/แสดงเมนู (ค่าเริ่มต้น: RightControl)
    ToggleKey = Enum.KeyCode.RightControl,
    IsUIVisible = true,
}

-- [4] การเชื่อมต่อกับ Remote จริงของเกม Anime Defenders
local ActionRemote = ReplicatedStorage:WaitForChild("Actions", 5) and ReplicatedStorage.Actions:WaitForChild("Action", 5)
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 5)

-- [5] ทำความสะอาด UI เก่าก่อนสร้างใหม่
local existingUI = CoreGui:FindFirstChild("AnimeDefenders_RealUI") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("AnimeDefenders_RealUI")
if existingUI then existingUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AnimeDefenders_RealUI"
ScreenGui.ResetOnSpawn = false

local targetParent = nil
if gethui then pcall(function() targetParent = gethui() end) end
if not targetParent then pcall(function() targetParent = LocalPlayer:WaitForChild("PlayerGui") end) end
ScreenGui.Parent = targetParent

-- =============================================================================
-- [6] โครงสร้าง GUI หลัก และปุ่ม Floating Toggle Button (สำหรับมือถือ)
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

-- ปุ่มลอยซ่อน/แสดงเมนูบนหน้าจอ (สำหรับแตะจอมือถือ)
local MobileToggleBtn = Instance.new("TextButton")
MobileToggleBtn.Name = "MobileToggleBtn"
MobileToggleBtn.Size = UDim2.new(0, 44, 0, 44)
MobileToggleBtn.Position = UDim2.new(0, 15, 0.5, -22)
MobileToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
MobileToggleBtn.Text = "👁️"
MobileToggleBtn.TextSize = 20
MobileToggleBtn.Active = true
MobileToggleBtn.Draggable = true
MobileToggleBtn.Parent = ScreenGui

local MobileCorner = Instance.new("UICorner")
MobileCorner.CornerRadius = UDim.new(1, 0)
MobileCorner.Parent = MobileToggleBtn

local MobileStroke = Instance.new("UIStroke")
MobileStroke.Color = Color3.fromRGB(99, 102, 241)
MobileStroke.Thickness = 1.5
MobileStroke.Parent = MobileToggleBtn

-- ฟังก์ชันซ่อน/แสดงเมนู (Toggle Visibility)
local function toggleUIVisibility()
    SystemState.IsUIVisible = not SystemState.IsUIVisible
    MainFrame.Visible = SystemState.IsUIVisible
end

MobileToggleBtn.MouseButton1Click:Connect(toggleUIVisibility)

-- ตรวจจับการกดปุ่มคีย์บอร์ด (RightControl หรือปุ่มที่ตั้งค่าไว้)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == SystemState.ToggleKey then
            toggleUIVisibility()
        end
    end
end)

-- Sidebar ฝั่งซ้าย
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 12)
SidebarCorner.Parent = Sidebar

local LogoTitle = Instance.new("TextLabel")
LogoTitle.Size = UDim2.new(1, 0, 0, 45)
LogoTitle.BackgroundTransparency = 1
LogoTitle.Text = "ANIME HUB"
LogoTitle.TextColor3 = Color3.fromRGB(99, 102, 241)
LogoTitle.TextSize = 16
LogoTitle.Font = Enum.Font.GothamBold
LogoTitle.Parent = Sidebar

local TabButtonContainer = Instance.new("Frame")
TabButtonContainer.Size = UDim2.new(1, -16, 1, -55)
TabButtonContainer.Position = UDim2.new(0, 8, 0, 45)
TabButtonContainer.BackgroundTransparency = 1
TabButtonContainer.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabButtonContainer
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 6)

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -145, 1, -16)
ContentArea.Position = UDim2.new(0, 138, 0, 8)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- =============================================================================
-- [7] ระบบจัดการหน้า Tab
-- =============================================================================

local Tabs = {}
local TabButtons = {}

local function createTab(tabName, tabIcon)
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
        for name, page in pairs(Tabs) do page.Visible = (name == tabName) end
        for name, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = (name == tabName) and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(30, 30, 42)
            btn.TextColor3 = (name == tabName) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 190)
        end
    end)

    return Page
end

local StageTab    = createTab("Farm & Stage", "⚔️")
local SummonTab   = createTab("Summon", "🎯")
local SettingsTab = createTab("Settings", "⚙️")

Tabs["Farm & Stage"].Visible = true
TabButtons["Farm & Stage"].BackgroundColor3 = Color3.fromRGB(99, 102, 241)
TabButtons["Farm & Stage"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- =============================================================================
-- [8] Components (Option Selectors & Toggles)
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
-- [9] เติมเนื้อหาในแต่ละ Tab
-- =============================================================================

addSectionTitle(StageTab, "🗺️ SELECT WORLD & MAP")
addOptionSelector(StageTab, "เลือกแมพ (World):", {"Windmill", "Cursed", "Demon", "Swordsman"}, "Windmill", function(val)
    SystemState.SelectedWorld = val
end)

addSectionTitle(StageTab, "📜 SELECT ACT & DIFFICULTY")
addOptionSelector(StageTab, "เลือก Act:", {"Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6"}, "Act 1", function(val)
    SystemState.SelectedAct = val
end)

addOptionSelector(StageTab, "เลือกระดับความยาก:", GameData.Difficulties, "Normal", function(val)
    SystemState.SelectedDifficulty = val
end)

addSectionTitle(StageTab, "⚡ AUTO CONTROLS")
addToggleCard(StageTab, "Auto Join Selected Stage", "ยิง ActionRemote สั่งเข้าเล่นด่านตามที่เลือก", "AutoReplay")
addToggleCard(StageTab, "Auto Farm Units", "ยิง ActionRemote สั่งวางยูนิตและสู้ในด่าน", "AutoFarm")

addSectionTitle(SummonTab, "🎯 SUMMON BANNER SELECTION")
addOptionSelector(SummonTab, "เลือกตู้สุ่ม (Banner):", {"Banner 1", "Banner 2", "Wish"}, "Banner 1", function(val)
    SystemState.SelectedBanner = val
end)

addSectionTitle(SummonTab, "⚡ SUMMON CONTROLS")
addToggleCard(SummonTab, "Auto Summon Units", "ยิง ActionRemote สั่งสุ่มยูนิตตามตู้ที่เลือก", "AutoSummon")

-- --- Settings Tab: ตั้งค่า Keybind ซ่อน/แสดง UI ---
addSectionTitle(SettingsTab, "⌨️ KEYBIND CONFIGURATION")

local keyNames = {}
for _, opt in ipairs(GameData.KeybindOptions) do table.insert(keyNames, opt.Name) end

addOptionSelector(SettingsTab, "เลือกปุ่มคีย์ลัด ซ่อน/แสดง เมนู:", keyNames, "Right Ctrl", function(val)
    for _, opt in ipairs(GameData.KeybindOptions) do
        if opt.Name == val then
            SystemState.ToggleKey = opt.Key
            print("เปลี่ยนปุ่มคีย์ลัดเป็น: ", val)
        end
    end
end)

addSectionTitle(SettingsTab, "⚙️ SYSTEM SETTINGS")
addToggleCard(SettingsTab, "Auto Leave on Defeat", "ออกจากด่านเมื่อแพ้", "AutoLeaveOnDefeat")

-- =============================================================================
-- [10] ลูปประมวลผลยิง ActionRemote (Action Dispatcher Loop)
-- =============================================================================

task.spawn(function()
    while true do
        task.wait(1.5)

        if SystemState.AutoReplay then
            pcall(function()
                if ActionRemote then
                    ActionRemote:FireServer("JoinStage", {
                        World = SystemState.SelectedWorld,
                        Act = SystemState.SelectedAct,
                        Difficulty = SystemState.SelectedDifficulty
                    })
                end
            end)
        end

        if SystemState.AutoSummon then
            pcall(function()
                if ActionRemote then
                    ActionRemote:FireServer("Summon", {
                        Banner = SystemState.SelectedBanner,
                        Amount = SystemState.SummonAmount
                    })
                end
            end)
        end

        if SystemState.AutoFarm then
            pcall(function()
                if ActionRemote then
                    ActionRemote:FireServer("PlaceUnit", {})
                end
            end)
        end
    end
end)

print("Anime Defenders Script with RightControl Keybind Loaded!")
