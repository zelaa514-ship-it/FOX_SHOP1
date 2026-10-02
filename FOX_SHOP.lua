
--========================================================
-- 🦊 FOX_SHOP CONTROL PANEL
-- Mobile + PC | Draggable Interface
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local DEFAULT_SPEED = 16
local DEFAULT_JUMP = 50

local MAX_SPEED = 200
local MAX_JUMP = 300
local MAX_FLY_SPEED = 200

local currentSpeed = DEFAULT_SPEED
local currentJump = DEFAULT_JUMP
local flySpeed = 70

local flying = false
local infiniteJump = false
local flyingUp = false
local flyingDown = false

local flyConnection
local attachment
local linearVelocity
local alignOrientation

--========================================================
-- حذف الواجهة القديمة
--========================================================

local oldGui = playerGui:FindFirstChild("FOX_SHOP")
if oldGui then
    oldGui:Destroy()
end

--========================================================
-- إنشاء الواجهة
--========================================================

local gui = Instance.new("ScreenGui")
gui.Name = "FOX_SHOP"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local function addCorner(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = object
end

local function addStroke(object, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness
    s.Parent = object
    return s
end

local ORANGE = Color3.fromRGB(255, 120, 20)
local DARK_ORANGE = Color3.fromRGB(210, 80, 15)
local DARK = Color3.fromRGB(35, 22, 15)
local BOX_COLOR = Color3.fromRGB(55, 35, 23)
local WHITE = Color3.fromRGB(255, 255, 255)

local function makeButton(parent, name, text, position, size, color)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Text = text
    b.Position = position
    b.Size = size
    b.BackgroundColor3 = color
    b.TextColor3 = WHITE
    b.TextSize = 15
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = true
    b.Parent = parent

    addCorner(b, 10)
    addStroke(b, Color3.fromRGB(255, 190, 80), 1)

    return b
end

local function makeBox(parent, name, placeholder, position)
    local box = Instance.new("TextBox")
    box.Name = name
    box.Text = ""
    box.PlaceholderText = placeholder
    box.Position = position
    box.Size = UDim2.new(0.8, 0, 0, 38)
    box.BackgroundColor3 = BOX_COLOR
    box.TextColor3 = WHITE
    box.PlaceholderColor3 = Color3.fromRGB(180, 140, 110)
    box.TextSize = 14
    box.Font = Enum.Font.Gotham
    box.ClearTextOnFocus = false
    box.Parent = parent

    addCorner(box, 10)
    return box
end

--========================================================
-- زر إظهار الواجهة (قابل للتحريك)
--========================================================

local openButton = makeButton(
    gui,
    "OpenButton",
    "🦊 FOX_SHOP",
    UDim2.new(0, 15, 0.5, -24),
    UDim2.new(0, 145, 0, 48),
    ORANGE
)

openButton.TextSize = 16
addCorner(openButton, 14)
addStroke(openButton, Color3.fromRGB(255, 200, 90), 2)

--========================================================
-- النافذة الرئيسية
--========================================================

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 330, 0, 470)
frame.Position = UDim2.new(0.5, -165, 0.5, -235)
frame.BackgroundColor3 = DARK
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active = true
frame.Parent = gui

addCorner(frame, 18)
addStroke(frame, ORANGE, 3)

-- شريط العنوان: منطقة سحب النافذة
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, -12, 0, 65)
titleBar.Position = UDim2.new(0, 6, 0, 6)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 29, 19)
titleBar.BorderSizePixel = 0
titleBar.Active = true
titleBar.Parent = frame

addCorner(titleBar, 14)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -65, 0, 35)
title.Position = UDim2.new(0, 12, 0, 5)
title.BackgroundTransparency = 1
title.Text = "🦊 FOX_SHOP"
title.TextColor3 = ORANGE
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Active = true
title.Parent = titleBar

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -20, 0, 20)
subtitle.Position = UDim2.new(0, 13, 0, 39)
subtitle.BackgroundTransparency = 1
subtitle.Text = "FOX CONTROL PANEL • DRAG TO MOVE"
subtitle.TextColor3 = Color3.fromRGB(190, 150, 120)
subtitle.TextSize = 10
subtitle.Font = Enum.Font.GothamBold
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Active = true
subtitle.Parent = titleBar

local closeButton = makeButton(
    titleBar,
    "CloseButton",
    "✕",
    UDim2.new(1, -45, 0, 7),
    UDim2.new(0, 36, 0, 36),
    DARK_ORANGE
)
closeButton.TextSize = 20

--========================================================
-- حقول السرعة والقفز والطيران
--========================================================

local speedBox = makeBox(
    frame,
    "SpeedBox",
    "⚡ السرعة: مثال 50",
    UDim2.new(0.1, 0, 0, 82)
)

local speedButton = makeButton(
    frame,
    "SpeedButton",
    "⚡ تطبيق السرعة",
    UDim2.new(0.1, 0, 0, 124),
    UDim2.new(0.8, 0, 0, 35),
    ORANGE
)

local jumpBox = makeBox(
    frame,
    "JumpBox",
    "🦘 قوة القفز: مثال 100",
    UDim2.new(0.1, 0, 0, 167)
)

local jumpButton = makeButton(
    frame,
    "JumpButton",
    "🦘 تطبيق القفز",
    UDim2.new(0.1, 0, 0, 209),
    UDim2.new(0.8, 0, 0, 35),
    ORANGE
)

local flySpeedBox = makeBox(
    frame,
    "FlySpeedBox",
    "✈️ سرعة الطيران: مثال 70",
    UDim2.new(0.1, 0, 0, 252)
)

local flyButton = makeButton(
    frame,
    "FlyButton",
    "✈️ تشغيل الطيران",
    UDim2.new(0.1, 0, 0, 294),
    UDim2.new(0.8, 0, 0, 38),
    DARK_ORANGE
)

local infiniteJumpButton = makeButton(
    frame,
    "InfiniteJumpButton",
    "♾️ القفز اللانهائي: OFF",
    UDim2.new(0.1, 0, 0, 340),
    UDim2.new(0.8, 0, 0, 38),
    DARK_ORANGE
)

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Size = UDim2.new(1, -20, 0, 28)
status.Position = UDim2.new(0, 10, 0, 388)
status.BackgroundTransparency = 1
status.Text = "🦊 FOX_SHOP • READY"
status.TextColor3 = Color3.fromRGB(255, 190, 100)
status.TextSize = 11
status.Font = Enum.Font.GothamBold
status.Parent = frame

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -20, 0, 22)
footer.Position = UDim2.new(0, 10, 0, 425)
footer.BackgroundTransparency = 1
footer.Text = "DRAG TITLE TO MOVE"
footer.TextColor3 = Color3.fromRGB(160, 110, 80)
footer.TextSize = 10
footer.Font = Enum.Font.GothamBold
footer.Parent = frame

--========================================================
-- أزرار الطيران (قابلة للتحريك)
--========================================================

local upButton = makeButton(
    gui,
    "FlyUpButton",
    "⬆️",
    UDim2.new(1, -85, 0.5, -80),
    UDim2.new(0, 65, 0, 65),
    ORANGE
)
upButton.TextSize = 27
upButton.Visible = false

local downButton = makeButton(
    gui,
    "FlyDownButton",
    "⬇️",
    UDim2.new(1, -85, 0.5, 5),
    UDim2.new(0, 65, 0, 65),
    DARK_ORANGE
)
downButton.TextSize = 27
downButton.Visible = false

--========================================================
-- نظام التحريك: الواجهة والأزرار
--========================================================

local draggingObjects = {}
local dragInputConnection

local function makeDraggable(object, handle)
    handle = handle or object
    handle.Active = true

    local dragState = {
        object = object,
        handle = handle,
        dragging = false,
        input = nil,
        startInput = nil,
        startPosition = nil,
    }

    table.insert(draggingObjects, dragState)

    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch
            and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        -- لا تسمح ببدء سحب جديد أثناء سحب آخر
        for _, state in ipairs(draggingObjects) do
            if state.dragging then
                return
            end
        end

        dragState.dragging = true
        dragState.input = input
        dragState.startInput = input.Position
        dragState.startPosition = object.Position

        if input.UserInputType == Enum.UserInputType.Touch then
            dragState.touchInput = input
        else
            dragState.touchInput = nil
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input == dragState.input then
            dragState.dragging = false
            dragState.input = nil
        end
    end)
end

local function updateDragging(input)
    for _, state in ipairs(draggingObjects) do
        if state.dragging then
            local isMouseMove =
                input.UserInputType == Enum.UserInputType.MouseMovement
                and state.input
                and state.input.UserInputType
                    == Enum.UserInputType.MouseButton1

            local isTouchMove =
                state.input
                and state.input.UserInputType == Enum.UserInputType.Touch
                and input == state.input

            if isMouseMove or isTouchMove then
                local delta = input.Position - state.startInput
                local start = state.startPosition

                state.object.Position = UDim2.new(
                    start.X.Scale,
                    start.X.Offset + delta.X,
                    start.Y.Scale,
                    start.Y.Offset + delta.Y
                )
            end
        end
    end
end

dragInputConnection = UserInputService.InputChanged:Connect(updateDragging)

UserInputService.InputEnded:Connect(function(input)
    for _, state in ipairs(draggingObjects) do
        if state.input == input then
            state.dragging = false
            state.input = nil
        end
    end
end)

UserInputService.WindowFocusReleased:Connect(function()
    for _, state in ipairs(draggingObjects) do
        state.dragging = false
        state.input = nil
    end
end)

-- زر الإظهار نفسه قابل للسحب
makeDraggable(openButton)

-- اسحب النافذة من شريط العنوان
makeDraggable(frame, titleBar)

-- اسحب زري الطيران بشكل مستقل
makeDraggable(upButton)
makeDraggable(downButton)

--========================================================
-- فتح وإغلاق الواجهة
--========================================================

openButton.Activated:Connect(function()
    frame.Visible = not frame.Visible
end)

closeButton.Activated:Connect(function()
    frame.Visible = false
end)

--========================================================
-- الشخصية
--========================================================

local function getCharacter()
    local character = player.Character

    if not character then
        return nil, nil, nil
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    return character, humanoid, root
end

local function setStatus(message)
    status.Text = message
end

--========================================================
-- السرعة
--========================================================

local function applySpeed(value)
    local _, humanoid = getCharacter()

    if not humanoid or humanoid.Health <= 0 then
        return false
    end

    currentSpeed = math.clamp(value, 0, MAX_SPEED)
    humanoid.WalkSpeed = currentSpeed

    return true
end

speedButton.Activated:Connect(function()
    local value = tonumber(speedBox.Text)

    if not value then
        setStatus("❌ أدخل رقمًا صحيحًا للسرعة")
        return
    end

    if applySpeed(value) then
        setStatus("✅ السرعة: " .. currentSpeed)
    else
        setStatus("❌ الشخصية غير جاهزة")
    end
end)

--========================================================
-- القفز
--========================================================

local function applyJump(value)
    local _, humanoid = getCharacter()

    if not humanoid or humanoid.Health <= 0 then
        return false
    end

    currentJump = math.clamp(value, 0, MAX_JUMP)
    humanoid.UseJumpPower = true
    humanoid.JumpPower = currentJump

    return true
end

jumpButton.Activated:Connect(function()
    local value = tonumber(jumpBox.Text)

    if not value then
        setStatus("❌ أدخل رقمًا صحيحًا للقفز")
        return
    end

    if applyJump(value) then
        setStatus("✅ قوة القفز: " .. currentJump)
    else
        setStatus("❌ الشخصية غير جاهزة")
    end
end)

--========================================================
-- إيقاف الطيران
--========================================================

local function stopFly()
    flying = false
    flyingUp = false
    flyingDown = false

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    if linearVelocity then
        linearVelocity:Destroy()
        linearVelocity = nil
    end

    if alignOrientation then
        alignOrientation:Destroy()
        alignOrientation = nil
    end

    if attachment then
        attachment:Destroy()
        attachment = nil
    end

    local _, humanoid = getCharacter()

    if humanoid then
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true
    end

    upButton.Visible = false
    downButton.Visible = false

    flyButton.Text = "✈️ تشغيل الطيران"
    flyButton.BackgroundColor3 = DARK_ORANGE
end

--========================================================
-- تشغيل الطيران
--========================================================

local function startFly()
    stopFly()

    local character, humanoid, root = getCharacter()

    if not character or not humanoid or not root
        or humanoid.Health <= 0 then
        setStatus("❌ الشخصية غير جاهزة")
        return
    end

    local value = tonumber(flySpeedBox.Text)

    if value then
        flySpeed = math.clamp(value, 1, MAX_FLY_SPEED)
    end

    flying = true
    humanoid.PlatformStand = true
    humanoid.AutoRotate = false

    attachment = Instance.new("Attachment")
    attachment.Name = "FOX_FlyAttachment"
    attachment.Parent = root

    linearVelocity = Instance.new("LinearVelocity")
    linearVelocity.Name = "FOX_FlyVelocity"
    linearVelocity.Attachment0 = attachment
    linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    linearVelocity.VelocityConstraintMode =
        Enum.VelocityConstraintMode.Vector
    linearVelocity.MaxForce =
        root.AssemblyMass * workspace.Gravity * 4
    linearVelocity.VectorVelocity = Vector3.zero
    linearVelocity.Parent = root

    alignOrientation = Instance.new("AlignOrientation")
    alignOrientation.Name = "FOX_FlyOrientation"
    alignOrientation.Attachment0 = attachment
    alignOrientation.Mode =
        Enum.OrientationAlignmentMode.OneAttachment
    alignOrientation.MaxTorque =
        root.AssemblyMass * workspace.Gravity * 10
    alignOrientation.Responsiveness = 20
    alignOrientation.Parent = root

    upButton.Visible = true
    downButton.Visible = true

    flyButton.Text = "🛑 إيقاف الطيران"
    flyButton.BackgroundColor3 = Color3.fromRGB(150, 45, 10)

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flying then
            return
        end

        if not root.Parent or not humanoid.Parent
            or humanoid.Health <= 0 then
            stopFly()
            return
        end

        local camera = workspace.CurrentCamera

        if not camera then
            return
        end

        local velocity = humanoid.MoveDirection * flySpeed

        if flyingUp then
            velocity += Vector3.new(0, flySpeed, 0)
        end

        if flyingDown then
            velocity -= Vector3.new(0, flySpeed, 0)
        end

        linearVelocity.VectorVelocity = velocity

        local look = camera.CFrame.LookVector
        local horizontal = Vector3.new(look.X, 0, look.Z)

        if horizontal.Magnitude > 0.01 then
            alignOrientation.CFrame =
                CFrame.lookAt(Vector3.zero, horizontal.Unit)
        end
    end)

    setStatus("✈️ الطيران يعمل")
end

flyButton.Activated:Connect(function()
    if flying then
        stopFly()
        setStatus("🛑 تم إيقاف الطيران")
    else
        startFly()
    end
end)

--========================================================
-- أزرار الصعود والنزول
--========================================================

local function bindHold(button, onBegin, onEnd)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            onBegin()
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            onEnd()
        end
    end)
end

bindHold(
    upButton,
    function()
        if flying then
            flyingUp = true
        end
    end,
    function()
        flyingUp = false
    end
)

bindHold(
    downButton,
    function()
        if flying then
            flyingDown = true
        end
    end,
    function()
        flyingDown = false
    end
)

--========================================================
-- القفز اللانهائي
--========================================================

infiniteJumpButton.Activated:Connect(function()
    infiniteJump = not infiniteJump

    if infiniteJump then
        infiniteJumpButton.Text = "♾️ القفز اللانهائي: ON"
        infiniteJumpButton.BackgroundColor3 =
            Color3.fromRGB(40, 150, 70)
        setStatus("♾️ القفز اللانهائي يعمل")
    else
        infiniteJumpButton.Text = "♾️ القفز اللانهائي: OFF"
        infiniteJumpButton.BackgroundColor3 = DARK_ORANGE
        setStatus("القفز اللانهائي متوقف")
    end
end)

UserInputService.JumpRequest:Connect(function()
    if not infiniteJump or flying then
        return
    end

    local _, humanoid = getCharacter()

    if humanoid and humanoid.Health > 0 then
        humanoid:ChangeState(
            Enum.HumanoidStateType.Jumping
        )
    end
end)

--========================================================
-- إعادة تطبيق الإعدادات عند ظهور الشخصية
--========================================================

player.CharacterAdded:Connect(function(character)
    stopFly()

    local humanoid = character:WaitForChild("Humanoid", 10)

    if not humanoid then
        return
    end

    humanoid.WalkSpeed = currentSpeed
    humanoid.UseJumpPower = true
    humanoid.JumpPower = currentJump

    setStatus("🦊 FOX_SHOP • READY")
end)

--========================================================
-- بدء التشغيل
--========================================================

local _, humanoid = getCharacter()

if humanoid then
    humanoid.WalkSpeed = currentSpeed
    humanoid.UseJumpPower = true
    humanoid.JumpPower = currentJump
end

setStatus("🦊 FOX_SHOP • READY")
--========================================================
-- 👑 FOX_SHOP PLAYER TAGS
-- تظهر محليًا لمن يشغّل هذا السكربت فقط
--========================================================

local TAGS = {
    ["MAX_2VS1"] = {
        Text = "👑 صاحب سكربت FOX_SHOP",
        Color = Color3.fromRGB(255, 190, 40),
    },

    ["mimi_kl79"] = {
        Text = "🌚 اخت صاحب سكربت FOX_SHOP 🌚",
        Color = Color3.fromRGB(255, 170, 210),
    },
}

local function addFoxTag(targetPlayer, character)
    local tagInfo = TAGS[targetPlayer.Name]
    if not tagInfo or not character then
        return
    end

    local head = character:WaitForChild("Head", 10)
    if not head then
        return
    end

    -- تجنب إنشاء اللقب مرتين
    local oldTag = head:FindFirstChild("FOX_SHOP_PlayerTag")
    if oldTag then
        oldTag:Destroy()
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "FOX_SHOP_PlayerTag"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 260, 0, 48)
    billboard.StudsOffset = Vector3.new(0, 2.8, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 500
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.Name = "TagText"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = tagInfo.Text
    label.TextColor3 = tagInfo.Color
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.2
    label.TextStrokeColor3 = Color3.fromRGB(25, 15, 10)
    label.Parent = billboard

    local limit = Instance.new("UITextSizeConstraint")
    limit.MinTextSize = 10
    limit.MaxTextSize = 22
    limit.Parent = label
end

local function setupFoxTag(targetPlayer)
    if not TAGS[targetPlayer.Name] then
        return
    end

    targetPlayer.CharacterAdded:Connect(function(character)
        addFoxTag(targetPlayer, character)
    end)

    if targetPlayer.Character then
        task.spawn(function()
            addFoxTag(targetPlayer, targetPlayer.Character)
        end)
    end
end

-- اللاعبون الموجودون حاليًا
for _, targetPlayer in ipairs(Players:GetPlayers()) do
    setupFoxTag(targetPlayer)
end

-- اللاعبون الذين يدخلون لاحقًا
Players.PlayerAdded:Connect(setupFoxTag)
