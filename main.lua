--[[
    =============================================================================
    Anime Defenders - Modern Educational Script & Premium UI System
    =============================================================================
    หัวข้อ: การออกแบบ Modern UX/UI ใน Roblox, การทำ Toggle Switch และระบบ Event Automation
    เป้าหมาย: ใช้สำหรับการเรียนรู้โครงสร้าง UI ระดับสูง และการวางระบบควบคุมการทำงานในเกม
]]

-- [1] เรียกใช้งาน Services ที่จำเป็น
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- [2] ตัวแปรจัดการสถานะระบบ (State Management)
local SystemState = {
    AutoFarm = false,
    AutoSummon = false,
    AutoReplay = false,
}

-- [3] ทำความสะอาด UI เก่าก่อนสร้างใหม่ (Prevent Duplicates)
local existingUI = CoreGui:FindFirstChild("AnimeDefenders_PremiumUI") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("AnimeDefenders_PremiumUI")
if existingUI then
    existingUI:Destroy()
end

-- สร้าง ScreenGui สำหรับแสดงผล
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AnimeDefenders_PremiumUI"
ScreenGui.ResetOnSpawn = false

-- ตรวจสอบตำแหน่งการวาง GUI (ใช้ gethui() หากมีใน Executor หรือใช้ CoreGui / PlayerGui)
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
-- [4] การออกแบบโครงสร้างหลักของ UI (Main Frame & Glassmorphism Theme)
-- =============================================================================

-- กรอบหลัก (Main Window)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 420)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26) -- Dark Theme Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- มุมมนของกรอบหลัก
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

-- เส้นขอบสะท้อนแสง (UI Stroke / Modern Border Glow)
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

-- โลโก้/ไฟสถานะ (Status Indicator)
local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 10, 0, 10)
StatusDot.Position = UDim2.new(0, 16, 0.5, -5)
StatusDot.BackgroundColor3 = Color3.fromRGB(99, 102, 241) -- Purple Glow
StatusDot.BorderSizePixel = 0
StatusDot.Parent = Header

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = StatusDot

-- ชื่อสคริปต์ (Title Text)
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
SubtitleText.Text = "Educational Auto System v1.0"
SubtitleText.TextColor3 = Color3.fromRGB(130, 130, 160)
SubtitleText.TextSize = 10
SubtitleText.Font = Enum.Font.GothamMedium
SubtitleText.TextXAlignment = Enum.TextXAlignment.Left
SubtitleText.Parent = Header

-- ปุ่มปิดหน้าต่าง (Close Button)
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
-- [5] คอนเทนเนอร์ใส่รายการเมนู (Content Area & Container)
-- =============================================================================

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -32, 1, -70)
ContentArea.Position = UDim2.new(0, 16, 0, 60)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ContentArea
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 12)

-- =============================================================================
-- [6] ฟังก์ชันสร้าง Toggle Card สไตล์ Modern UX
-- =============================================================================

local function createToggleCard(title, subtitle, stateKey, callback)
    local Card = Instance.new("Frame")
    Card.Name = title .. "_Card"
    Card.Size = UDim2.new(1, 0, 0, 64)
    Card.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    Card.BorderSizePixel = 0
    Card.Parent = ContentArea

    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 10)
    CardCorner.Parent = Card

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = Color3.fromRGB(45, 45, 60)
    CardStroke.Thickness = 1
    CardStroke.Parent = Card

    -- ข้อความใน Card
    local CardTitle = Instance.new("TextLabel")
    CardTitle.Size = UDim2.new(0.7, 0, 0, 20)
    CardTitle.Position = UDim2.new(0, 14, 0, 12)
    CardTitle.BackgroundTransparency = 1
    CardTitle.Text = title
    CardTitle.TextColor3 = Color3.fromRGB(230, 230, 245)
    CardTitle.TextSize = 14
    CardTitle.Font = Enum.Font.GothamBold
    CardTitle.TextXAlignment = Enum.TextXAlignment.Left
    CardTitle.Parent = Card

    local CardSub = Instance.new("TextLabel")
    CardSub.Size = UDim2.new(0.7, 0, 0, 16)
    CardSub.Position = UDim2.new(0, 14, 0, 34)
    CardSub.BackgroundTransparency = 1
    CardSub.Text = subtitle
    CardSub.TextColor3 = Color3.fromRGB(130, 130, 155)
    CardSub.TextSize = 11
    CardSub.Font = Enum.Font.Gotham
    CardSub.TextXAlignment = Enum.TextXAlignment.Left
    CardSub.Parent = Card

    -- ปุ่ม Switch (Toggle Pill)
    local SwitchPill = Instance.new("Frame")
    SwitchPill.Size = UDim2.new(0, 44, 0, 24)
    SwitchPill.Position = UDim2.new(1, -58, 0.5, -12)
    SwitchPill.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    SwitchPill.BorderSizePixel = 0
    SwitchPill.Parent = Card

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = SwitchPill

    -- ปุ่มกลมด้านใน Switch (Knob)
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 18, 0, 18)
    Knob.Position = UDim2.new(0, 3, 0.5, -9)
    Knob.BackgroundColor3 = Color3.fromRGB(180, 180, 200)
    Knob.BorderSizePixel = 0
    Knob.Parent = SwitchPill

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    -- ปุ่มคลิกทับเต็มพื้นที่ Card
    local ClickArea = Instance.new("TextButton")
    ClickArea.Size = UDim2.new(1, 0, 1, 0)
    ClickArea.BackgroundTransparency = 1
    ClickArea.Text = ""
    ClickArea.Parent = Card

    -- อีเวนต์คลิกสลับสถานะพร้อมแอนิเมชัน (Smooth Tweening)
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
-- [7] สร้างรายการเมนูสคริปต์จริง (Auto Farm / Auto Buy / Auto Replay)
-- =============================================================================

-- 1. Auto Farm Card
createToggleCard("Auto Farm Units", "ระบบวางยูนิตและต่อสู้ให้อัตโนมัติ", "AutoFarm", function(isOn)
    print("Auto Farm State Changed: ", isOn)
end)

-- 2. Auto Buy / Summon Card
createToggleCard("Auto Summon", "ระบบซื้อ/สุ่มยูนิตให้อัตโนมัติ", "AutoSummon", function(isOn)
    print("Auto Summon State Changed: ", isOn)
end)

-- 3. Auto Replay Card
createToggleCard("Auto Play Again", "ระบบเริ่มเล่นรอบใหม่อัตโนมัติเมื่อจบเกม", "AutoReplay", function(isOn)
    print("Auto Replay State Changed: ", isOn)
end)

-- =============================================================================
-- [8] ลูปประมวลผลเบื้องหลัง (Background Logic Processing Loop)
-- =============================================================================

task.spawn(function()
    while true do
        task.wait(1.5)

        -- 1. ลูปทำงาน Auto Farm
        if SystemState.AutoFarm then
            print("[System]: Auto Farming Active...")
        end

        -- 2. ลูปทำงาน Auto Summon
        if SystemState.AutoSummon then
            print("[System]: Auto Summoning Active...")
        end

        -- 3. ลูปทำงาน Auto Replay
        if SystemState.AutoReplay then
            print("[System]: Auto Replay Active...")
        end
    end
end)

print("Anime Defenders Premium UI Loaded Successfully!")
