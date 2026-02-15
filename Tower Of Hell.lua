-- Services
local Players = game:GetService('Players')
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- SETTINGS
-- ============================================================
local Settings = {
    GUISize = UDim2.new(0, 280, 0, 320),
    ToggleKey = Enum.KeyCode.RightShift,
    PrimaryColor = Color3.fromRGB(0, 255, 255),
    AccentColor = Color3.fromRGB(0, 200, 255),
    ButtonHeight = 65,
    Debug = true
}
-- ============================================================

local function Debug(Source, ...)
    if Settings.Debug then
        warn("[" .. Source .. " Debug] :", ...)
    end
end

-- ============================================================
-- UTILITY
-- ============================================================
local Utility = {}

function Utility:GS(ClassName)
    return game:GetService(ClassName)
end

function Utility:BetterRound(Number, DecimalPlaces)
    local Multiplied = 10 ^ (DecimalPlaces or 0)
    return math.floor(Number * Multiplied + 0.5) / Multiplied
end

-- ============================================================
-- MAIN LOGIC
-- ============================================================
local Main = {}

function Main:TP(Position)
    if typeof(Position) == "Instance" then
        Position = Position.CFrame
    end
    if typeof(Position) == "Vector3" then
        Position = CFrame.new(Position)
    end
    if typeof(Position) == "CFrame" then
        LocalPlayer.Character:PivotTo(Position)
    else
        warn("[!] Invalid Argument Passed to TP()")
    end
end

function Main:HookAnticheat()
    local Success, _ = pcall(function()
        local AnticheatScriptMain = LocalPlayer.PlayerScripts:WaitForChild("LocalScript", 5)
        local MainKickFunction = getsenv(AnticheatScriptMain).kick
        hookfunction(MainKickFunction, function() task.wait(9e9) end)
        for _, Connection in next, getconnections(AnticheatScriptMain.Changed) do
            hookfunction(Connection.Function, function() task.wait(9e9) end)
        end
    end)
    if Success then
        Debug("Anticheat Hook", "Anticheat has been successfully hooked.")
    else
        Debug("Anticheat Hook", "Anticheat hook has failed! >_<")
    end
end

Main:HookAnticheat()

for _, Connection in next, getconnections(LocalPlayer.Idled) do
    Connection:Disable()
end

-- ============================================================
-- GUI HELPERS
-- ============================================================
local function createFrame(props)
    local frame = Instance.new("Frame")
    for k, v in pairs(props) do
        frame[k] = v
    end
    return frame
end

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(radius, 0)
    corner.Parent = parent
    return corner
end

local function addStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

-- ============================================================
-- GUI CREATION
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local Main_Frame = createFrame({
    Parent = ScreenGui,
    BackgroundColor3 = Color3.fromRGB(10, 15, 25),
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Size = UDim2.new(0, 0, 0, 0),
    Active = true,
    Draggable = true,
    ZIndex = 1,
    Visible = false
})
addCorner(Main_Frame, 0.04)
local MainStroke = addStroke(Main_Frame, Settings.PrimaryColor, 2)

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 20, 35)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 12, 22)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 20, 35))
}
MainGradient.Rotation = 90
MainGradient.Parent = Main_Frame

-- Scan Lines
local ScanLines = createFrame({
    Parent = Main_Frame,
    BackgroundColor3 = Settings.PrimaryColor,
    BackgroundTransparency = 0.9,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 2),
    Position = UDim2.new(0, 0, 0, 0),
    ZIndex = 10
})

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Main_Frame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(0.8, 0, 0, 40)
Title.Position = UDim2.new(0.1, 0, 0.03, 0)
Title.Font = Enum.Font.Code
Title.Text = "⚡Tower Of Hell"
Title.TextColor3 = Settings.PrimaryColor
Title.TextSize = 18
Title.TextStrokeTransparency = 0
Title.ZIndex = 3

-- Subtitle
local Subtitle = Instance.new("TextLabel")
Subtitle.Parent = Main_Frame
Subtitle.BackgroundTransparency = 1
Subtitle.Size = UDim2.new(0.8, 0, 0, 15)
Subtitle.Position = UDim2.new(0.1, 0, 0.16, 0)
Subtitle.Font = Enum.Font.Code
Subtitle.Text = "[ Spectate script | Made by 2vra ]"
Subtitle.TextColor3 = Settings.AccentColor
Subtitle.TextSize = 9
Subtitle.TextTransparency = 0.3
Subtitle.ZIndex = 3

-- Button Helper
local function createButton(props)
    local container = createFrame({
        Parent = Main_Frame,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Position = props.Position,
        Size = props.Size,
        ZIndex = 2,
        BackgroundColor3 = props.Color
    })
    addCorner(container, 0.15)
    local stroke = addStroke(container, props.StrokeColor, 2, 0.5)

    local gradient = Instance.new("UIGradient")
    gradient.Color = props.Gradient
    gradient.Rotation = 45
    gradient.Parent = container

    local button = Instance.new("TextButton")
    button.Parent = container
    button.BackgroundTransparency = 1
    button.Size = UDim2.new(1, 0, 1, 0)
    button.Font = Enum.Font.Code
    button.Text = props.Text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = props.TextSize or 13
    button.TextStrokeTransparency = 0.5
    button.ZIndex = 3

    return container, button, stroke, gradient
end

-- Teleport To Finish Button
local TpContainer, TpButton, TpStroke, TpGradient = createButton({
    Position = UDim2.new(0.06, 0, 0.27, 0),
    Size = UDim2.new(0.88, 0, 0, Settings.ButtonHeight),
    Color = Color3.fromRGB(0, 100, 180),
    StrokeColor = Color3.fromRGB(0, 200, 255),
    Text = "🏁 TELEPORT TO\nFINISH",
    TextSize = 13,
    Gradient = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 120, 200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 80, 160))
    }
})

local TpIndicator = createFrame({
    Parent = TpContainer,
    BackgroundColor3 = Settings.PrimaryColor,
    BorderSizePixel = 0,
    Position = UDim2.new(0.08, 0, 0.15, 0),
    Size = UDim2.new(0, 10, 0, 10),
    ZIndex = 4
})
addCorner(TpIndicator, 1)

-- Status Panel
local StatusPanel = createFrame({
    Parent = Main_Frame,
    BackgroundColor3 = Color3.fromRGB(0, 50, 80),
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    Position = UDim2.new(0.06, 0, 0.77, 0),
    Size = UDim2.new(0.88, 0, 0, 28),
    ZIndex = 2
})
addCorner(StatusPanel, 0.15)
addStroke(StatusPanel, Settings.PrimaryColor, 1, 0.6)

local StatusText = Instance.new("TextLabel")
StatusText.Parent = StatusPanel
StatusText.BackgroundTransparency = 1
StatusText.Size = UDim2.new(1, 0, 1, 0)
StatusText.Font = Enum.Font.Code
StatusText.Text = "[ READY ]"
StatusText.TextColor3 = Color3.fromRGB(0, 255, 150)
StatusText.TextSize = 11
StatusText.ZIndex = 3

-- Credit
local Credit = Instance.new("TextLabel")
Credit.Parent = Main_Frame
Credit.BackgroundTransparency = 1
Credit.Position = UDim2.new(0.5, 0, 0.97, 0)
Credit.AnchorPoint = Vector2.new(0.5, 0.5)
Credit.Size = UDim2.new(0, 200, 0, 18)
Credit.Font = Enum.Font.Code
Credit.Text = ">> Made BY 2vra <<"
Credit.TextColor3 = Color3.fromRGB(0, 150, 200)
Credit.TextSize = 9
Credit.TextTransparency = 0.4
Credit.ZIndex = 3

-- Quit Button
local Quit = Instance.new("TextButton")
Quit.Parent = Main_Frame
Quit.BackgroundColor3 = Color3.fromRGB(200, 0, 50)
Quit.BackgroundTransparency = 0.3
Quit.BorderSizePixel = 0
Quit.Position = UDim2.new(0.88, 0, 0.025, 0)
Quit.Size = UDim2.new(0, 28, 0, 28)
Quit.Font = Enum.Font.Code
Quit.Text = "✕"
Quit.TextColor3 = Color3.fromRGB(255, 255, 255)
Quit.TextSize = 18
Quit.ZIndex = 3
addCorner(Quit, 0.2)
local QuitStroke = addStroke(Quit, Color3.fromRGB(255, 0, 100), 2)

-- Info Text
local InfoText = Instance.new("TextLabel")
InfoText.Parent = ScreenGui
InfoText.BackgroundColor3 = Color3.fromRGB(5, 10, 20)
InfoText.BackgroundTransparency = 0.15
InfoText.BorderSizePixel = 0
InfoText.Position = UDim2.new(0.5, 0, 0.9, 0)
InfoText.AnchorPoint = Vector2.new(0.5, 0.5)
InfoText.Size = UDim2.new(0, 300, 0, 55)
InfoText.Font = Enum.Font.Code
InfoText.Text = ">> PRESS [RIGHT SHIFT] <<"
InfoText.TextColor3 = Settings.PrimaryColor
InfoText.TextSize = 12
InfoText.TextStrokeTransparency = 0.5
InfoText.ZIndex = 100
addCorner(InfoText, 0.15)
addStroke(InfoText, Settings.PrimaryColor, 2, 0.3)

-- ============================================================
-- ANIMATIONS
-- ============================================================
local function animateButton(button, container, stroke)
    button.MouseEnter:Connect(function()
        TweenService:Create(container, TweenInfo.new(0.2), {BackgroundTransparency = 0.4}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Thickness = 3, Transparency = 0}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(container, TweenInfo.new(0.2), {BackgroundTransparency = 0.7}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Thickness = 2, Transparency = 0.5}):Play()
    end)
end

animateButton(TpButton, TpContainer, TpStroke)

Quit.MouseEnter:Connect(function()
    TweenService:Create(Quit, TweenInfo.new(0.2), {BackgroundTransparency = 0, Rotation = 90}):Play()
end)
Quit.MouseLeave:Connect(function()
    TweenService:Create(Quit, TweenInfo.new(0.2), {BackgroundTransparency = 0.3, Rotation = 0}):Play()
end)

-- Scan line loop
spawn(function()
    while wait() do
        local tween = TweenService:Create(ScanLines, TweenInfo.new(3, Enum.EasingStyle.Linear), {Position = UDim2.new(0, 0, 1, 0)})
        tween:Play()
        tween.Completed:Wait()
        ScanLines.Position = UDim2.new(0, 0, 0, 0)
    end
end)

-- Gradient rotation loop
spawn(function()
    while wait(0.03) do
        TpGradient.Rotation = TpGradient.Rotation + 0.6
    end
end)

-- ============================================================
-- BUTTON LOGIC
-- ============================================================
local function showNotif(msg, color)
    StatusText.Text = msg
    StatusText.TextColor3 = color
end

TpButton.MouseButton1Click:Connect(function()
    local success, err = pcall(function()
        local FinishCF = workspace.tower.sections.finish.FinishGlow.CFrame
        LocalPlayer.Character:PivotTo(FinishCF + FinishCF.LookVector:Cross(Vector3.new(0, -1, 0)).Unit * 3)
    end)

    if success then
        -- Flash indicator
        TpIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        TweenService:Create(TpContainer, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 160, 240)}):Play()
        showNotif("[ TELEPORTED! ]", Color3.fromRGB(0, 255, 150))
        task.wait(0.4)
        TweenService:Create(TpContainer, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 100, 180)}):Play()
        TpIndicator.BackgroundColor3 = Settings.PrimaryColor
        showNotif("[ READY ]", Color3.fromRGB(0, 255, 150))
    else
        TpIndicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        showNotif("[ FAILED: " .. tostring(err):sub(1, 22) .. " ]", Color3.fromRGB(255, 100, 100))
        task.wait(2)
        TpIndicator.BackgroundColor3 = Settings.PrimaryColor
        showNotif("[ READY ]", Color3.fromRGB(0, 255, 150))
    end
end)

Quit.MouseButton1Click:Connect(function()
    showNotif("[ SHUTDOWN ]", Color3.fromRGB(255, 100, 100))
    task.wait(0.3)
    local closeTween = TweenService:Create(Main_Frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0), Rotation = 180
    })
    closeTween:Play()
    closeTween.Completed:Wait()
    Main_Frame.Visible = false
    Main_Frame.Rotation = 0  -- Reset so re-open is never flipped
    InfoText.Visible = true
end)

-- ============================================================
-- TOGGLE GUI
-- ============================================================
local isAnimating = false

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Settings.ToggleKey and not isAnimating then
        isAnimating = true
        if Main_Frame.Visible then
            local closeTween = TweenService:Create(Main_Frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0), Rotation = -180
            })
            closeTween:Play()
            closeTween.Completed:Wait()
            Main_Frame.Visible = false
            Main_Frame.Rotation = 0  -- Reset so re-open is never flipped
        else
            Main_Frame.Rotation = 0  -- Ensure clean state before opening
            Main_Frame.Visible = true
            TweenService:Create(InfoText, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, 1.1, 0)
            }):Play()
            local openTween = TweenService:Create(Main_Frame, TweenInfo.new(0.6, Enum.EasingStyle.Elastic), {
                Size = Settings.GUISize
            })
            openTween:Play()
            task.wait(0.3)
            InfoText.Visible = false
            showNotif("[ READY ]", Color3.fromRGB(0, 255, 150))
            openTween.Completed:Wait()
        end
        isAnimating = false
    end
end)
