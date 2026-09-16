--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                  S A N D R E Y   H U B                      ║
    ║              Premium UI  ·  v3.0  ·  Universal             ║
    ╚══════════════════════════════════════════════════════════════╝
    v3.0 — PREMIUM EDITION
      · Полностью переработанное меню: многослойный фон, свечения,
        анимированный индикатор вкладок, премиальные компоненты
      · Улучшенная пилюля-лаунчер с неоновым кольцом аватара
      · Плавные tween-анимации каждого элемента, hover-эффекты
      · Visuals: третье лицо — скрывает тело, не слетает (RenderStep)
      · Combat: Silent Aim с выбором точки прицела (Курсор/Центр)
      · 5 неоновых тем, автосохранение конфига, часы МСК (live)
]]

-- ═══════════════════ SERVICES ═══════════════════
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local HttpService        = game:GetService("HttpService")
local StatsService       = game:GetService("Stats")
local GuiService         = game:GetService("GuiService")
local Workspace          = game:GetService("Workspace")
local CoreGui            = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if Workspace.CurrentCamera then Camera = Workspace.CurrentCamera end
end)

-- ═══════════════════ EXECUTOR ═══════════════════
local function getExecutorName()
    local name
    pcall(function()
        if identifyexecutor then name = identifyexecutor() end
        if not name and getexecutorname then name = getexecutorname() end
    end)
    return name or "Unknown"
end

local function safeClosure(f)
    if newcclosure then
        local ok, res = pcall(newcclosure, f)
        if ok then return res end
    end
    return f
end

-- ═══════════════════ THEMES ═══════════════════
local Themes = {
    {Name = "Neon",   A = Color3.fromRGB(155,  95, 255), B = Color3.fromRGB(  0, 225, 255)},
    {Name = "Rose",   A = Color3.fromRGB(255,  70, 190), B = Color3.fromRGB(130,  95, 255)},
    {Name = "Sunset", A = Color3.fromRGB(255,  95,  90), B = Color3.fromRGB(255, 190,  60)},
    {Name = "Toxic",  A = Color3.fromRGB( 60, 255, 160), B = Color3.fromRGB(190, 255,  60)},
    {Name = "Ice",    A = Color3.fromRGB( 70, 165, 255), B = Color3.fromRGB(125, 255, 240)},
}

-- ═══════════════════ CONFIG ═══════════════════
local Config = {
    ThemeIndex = 1,
    Accent  = Themes[1].A,
    Accent2 = Themes[1].B,
    UIScale = 0.5,
    ToggleKey = Enum.KeyCode.RightShift,

    TP_Enabled  = false,
    TP_Distance = 8,
    TP_Height   = 1,
    TP_Side     = 0,
    TP_HideBody = true,
    TP_HideTool = false,

    SA_Enabled    = false,
    SA_FOV        = 130,
    SA_Part       = "HumanoidRootPart",
    SA_AimMode    = "Cursor",
    SA_ShowFOV    = true,
    SA_IgnoreTeam = true,
}
local ConfigFile = "Sandrey_Config.json"

local function saveConfig()
    pcall(function()
        if not writefile then return end
        writefile(ConfigFile, HttpService:JSONEncode({
            ThemeIndex = Config.ThemeIndex,
            UIScale    = Config.UIScale,
            ToggleKey  = tostring(Config.ToggleKey):gsub("Enum.KeyCode.", ""),
            TP_Distance = Config.TP_Distance,
            TP_Height   = Config.TP_Height,
            TP_Side     = Config.TP_Side,
            TP_HideBody = Config.TP_HideBody,
            TP_HideTool = Config.TP_HideTool,
            SA_FOV      = Config.SA_FOV,
            SA_Part     = Config.SA_Part,
            SA_AimMode  = Config.SA_AimMode,
            SA_ShowFOV  = Config.SA_ShowFOV,
            SA_IgnoreTeam = Config.SA_IgnoreTeam,
        }))
    end)
end

local function loadConfig()
    pcall(function()
        if not readfile or not isfile then return end
        if not isfile(ConfigFile) then return end
        local d = HttpService:JSONDecode(readfile(ConfigFile))
        for k, v in pairs(d) do
            if k == "ToggleKey" then
                local key = Enum.KeyCode[v]
                if key then Config.ToggleKey = key end
            elseif Config[k] ~= nil then
                Config[k] = v
            end
        end
        local t = Themes[Config.ThemeIndex] or Themes[1]
        Config.Accent, Config.Accent2 = t.A, t.B
        Config.UIScale = math.clamp(Config.UIScale, 0.3, 1.6)
    end)
end
loadConfig()

-- ═══════════════════ UI KIT (PREMIUM) ═══════════════════
local function create(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

local function tween(obj, info, props)
    local t = TweenService:Create(obj,
        info or TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function corner(obj, r)
    return create("UICorner", {CornerRadius = UDim.new(0, r or 10), Parent = obj})
end

local function round(n, d)
    local m = 10 ^ (d or 0)
    return math.floor(n * m + 0.5) / m
end

-- Реестры для мгновенной смены темы
local Gradients   = {}
local AccentParts = {}

local function gradient(obj, rot, transparency)
    local g = create("UIGradient", {
        Color = ColorSequence.new(Config.Accent, Config.Accent2),
        Rotation = rot or 25,
        Parent = obj
    })
    if transparency then g.Transparency = transparency end
    table.insert(Gradients, g)
    return g
end

local function accentize(obj, prop, useSecond)
    obj[prop] = useSecond and Config.Accent2 or Config.Accent
    table.insert(AccentParts, {obj = obj, prop = prop, second = useSecond})
    return obj
end

local function glow(obj, thickness, transparency)
    local s = create("UIStroke", {
        Thickness = thickness or 1.4,
        Transparency = transparency or 0.35,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = obj
    })
    gradient(s, 25)
    return s
end

-- Мягкое внешнее свечение (использует проверенный ассет)
local function halo(obj, padding, transparency)
    local h = create("ImageLabel", {
        Name = "Halo",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, padding * 2, 1, padding * 2),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ImageTransparency = transparency or 0.86,
        ZIndex = 0,
        Parent = obj
    })
    accentize(h, "ImageColor3")
    return h
end

-- ═══════════════════ SAFE PARENT ═══════════════════
local function getSafeParent()
    if gethui then
        local ok, res = pcall(gethui)
        if ok and res then return res end
    end
    local ok = pcall(function()
        local t = Instance.new("ScreenGui")
        t.Parent = CoreGui
        t:Destroy()
    end)
    if ok then return CoreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local ScreenGui = create("ScreenGui", {
    Name = "SandreyHub",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 9999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = getSafeParent()
})
if syn and syn.protect_gui then pcall(syn.protect_gui, ScreenGui) end

-- ═══════════════════ TOASTS ═══════════════════
local ToastHolder = create("Frame", {
    Name = "Toasts",
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -18, 1, -18),
    Size = UDim2.fromOffset(280, 320),
    BackgroundTransparency = 1,
    Parent = ScreenGui
})
create("UIListLayout", {
    Padding = UDim.new(0, 9),
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = ToastHolder
})

local function notify(text, duration)
    local card = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(24, 25, 44),
        BackgroundTransparency = 0.04,
        Parent = ToastHolder
    })
    corner(card, 13)
    glow(card, 1.3, 0.25)
    create("UIPadding", {
        PaddingTop = UDim.new(0, 11), PaddingBottom = UDim.new(0, 11),
        PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = card
    })
    local bar = create("Frame", {
        Size = UDim2.new(0, 3, 1, -12), Position = UDim2.new(0, 5, 0, 6),
        BorderSizePixel = 0, Parent = card
    })
    corner(bar, 2); gradient(bar, 90)
    create("TextLabel", {
        Text = text, Font = Enum.Font.GothamMedium, TextSize = 12,
        TextColor3 = Color3.fromRGB(238, 239, 252), TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1, Parent = card
    })
    card.BackgroundTransparency = 1
    tween(card, TweenInfo.new(0.22), {BackgroundTransparency = 0.04})
    task.delay(duration or 2.5, function()
        tween(card, TweenInfo.new(0.28), {BackgroundTransparency = 1})
        task.wait(0.3)
        card:Destroy()
    end)
end

-- ═══════════════════ MSK CLOCK + AVATAR ═══════════════════
local function moscowTime()
    local t = os.date("!*t", os.time() + 3 * 3600)
    return string.format("%02d:%02d", t.hour, t.min)
end

local function avatarUrl(userId)
    return "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId) .. "&w=150&h=150"
end

local ClockLabels = {}
task.spawn(function()
    while ScreenGui.Parent do
        local now = moscowTime()
        for _, lbl in ipairs(ClockLabels) do
            if lbl.Parent then lbl.Text = now end
        end
        task.wait(1)
    end
end)

-- ═══════════════════ DRAG HELPER ═══════════════════
local function makeDraggable(frame, handle, onClick, lockFunc)
    handle = handle or frame
    local dragging, moved, startPos, startInput = false, false, nil, nil
    handle.InputBegan:Connect(function(input)
        if lockFunc and lockFunc() then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging, moved = true, false
            startInput = input.Position
            startPos = frame.Position
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    conn:Disconnect()
                    if not moved and onClick then onClick() end
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if lockFunc and lockFunc() then dragging = false return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - startInput
            if delta.Magnitude > 4 then moved = true end
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ═══════════════════ LAUNCHER PILL (PREMIUM) ═══════════════════
local Pill = create("Frame", {
    Name = "Launcher",
    Size = UDim2.fromOffset(224, 56),
    Position = UDim2.new(0, 24, 0, 96),
    BackgroundColor3 = Color3.fromRGB(17, 18, 33),
    BorderSizePixel = 0,
    Parent = ScreenGui
})
corner(Pill, 28)
glow(Pill, 1.7, 0.2)
halo(Pill, 22, 0.9)

-- бегущий блик
local PillShimmer = create("Frame", {
    Size = UDim2.fromOffset(64, 56), Position = UDim2.fromOffset(-64, 0),
    BackgroundTransparency = 0.85, BorderSizePixel = 0, Parent = Pill
})
create("UIGradient", {
    Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.78),
        NumberSequenceKeypoint.new(1, 1),
    }),
    Rotation = 20, Parent = PillShimmer
})
task.spawn(function()
    while PillShimmer.Parent do
        PillShimmer.Position = UDim2.fromOffset(-64, 0)
        tween(PillShimmer, TweenInfo.new(2.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            {Position = UDim2.fromOffset(230, 0)})
        task.wait(4.4)
    end
end)

-- неоновое кольцо аватара
local AvatarRing = create("Frame", {
    Size = UDim2.fromOffset(44, 44), Position = UDim2.new(0, 7, 0.5, -22),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Parent = Pill
})
corner(AvatarRing, 22); gradient(AvatarRing, 45)
task.spawn(function()
    while AvatarRing.Parent do
        local g = AvatarRing:FindFirstChildOfClass("UIGradient")
        if g then
            tween(g, TweenInfo.new(3, Enum.EasingStyle.Linear), {Rotation = 405})
            task.wait(3)
            g.Rotation = 45
        else task.wait(1) end
    end
end)

local AvatarHolder = create("Frame", {
    Size = UDim2.fromOffset(40, 40), Position = UDim2.fromOffset(2, 2),
    BackgroundColor3 = Color3.fromRGB(28, 30, 52), BorderSizePixel = 0, Parent = AvatarRing
})
corner(AvatarHolder, 20)
local Avatar = create("ImageLabel", {
    Size = UDim2.new(1, -4, 1, -4), Position = UDim2.fromOffset(2, 2),
    BackgroundTransparency = 1, Image = avatarUrl(LocalPlayer.UserId), Parent = AvatarHolder
})
corner(Avatar, 18)

-- индикатор онлайна (пульс)
local Dot = create("Frame", {
    Size = UDim2.fromOffset(11, 11), Position = UDim2.new(1, -9, 1, -9),
    BackgroundColor3 = Color3.fromRGB(70, 240, 150), BorderSizePixel = 0, Parent = AvatarRing
})
corner(Dot, 6)
create("UIStroke", {Color = Color3.fromRGB(17, 18, 33), Thickness = 2, Parent = Dot})
task.spawn(function()
    while Dot.Parent do
        tween(Dot, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {Size = UDim2.fromOffset(13, 13), Position = UDim2.new(1, -10, 1, -10)})
        task.wait(1)
        tween(Dot, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {Size = UDim2.fromOffset(11, 11), Position = UDim2.new(1, -9, 1, -9)})
        task.wait(1)
    end
end)

local PillName = create("TextLabel", {
    Text = LocalPlayer.DisplayName,
    Font = Enum.Font.GothamBold, TextSize = 13,
    TextColor3 = Color3.fromRGB(244, 245, 255),
    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    Size = UDim2.new(0, 100, 0, 16), Position = UDim2.new(0, 60, 0, 11),
    BackgroundTransparency = 1, Parent = Pill
})
local PillSub = create("TextLabel", {
    Text = "SANDREY HUB",
    Font = Enum.Font.GothamBold, TextSize = 8.5,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(0, 100, 0, 12), Position = UDim2.new(0, 60, 0, 29),
    BackgroundTransparency = 1, Parent = Pill
})
accentize(PillSub, "TextColor3", true)

local PillClock = create("TextLabel", {
    Text = moscowTime(),
    Font = Enum.Font.GothamBlack, TextSize = 17,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextXAlignment = Enum.TextXAlignment.Right,
    Size = UDim2.fromOffset(52, 18), Position = UDim2.new(1, -64, 0, 10),
    BackgroundTransparency = 1, Parent = Pill
})
table.insert(ClockLabels, PillClock)
create("TextLabel", {
    Text = "МСК", Font = Enum.Font.GothamBold, TextSize = 8,
    TextColor3 = Color3.fromRGB(125, 128, 160),
    TextXAlignment = Enum.TextXAlignment.Right,
    Size = UDim2.fromOffset(52, 10), Position = UDim2.new(1, -64, 0, 30),
    BackgroundTransparency = 1, Parent = Pill
})

local PillChevron = create("TextLabel", {
    Text = "‹", Font = Enum.Font.GothamBold, TextSize = 20,
    TextColor3 = Color3.fromRGB(150, 152, 190),
    Size = UDim2.fromOffset(16, 56), Position = UDim2.new(1, -20, 0, 0),
    BackgroundTransparency = 1, Parent = Pill
})

-- замок пилюли
local pillLocked = false
local PillLock = create("TextButton", {
    Text = "🔓", Font = Enum.Font.GothamBold, TextSize = 11,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Size = UDim2.fromOffset(21, 21),
    AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -7, 1, -7),
    BackgroundColor3 = Color3.fromRGB(30, 32, 54),
    AutoButtonColor = false, BorderSizePixel = 0, Parent = Pill
})
corner(PillLock, 11); glow(PillLock, 1.2, 0.3)
PillLock.MouseButton1Click:Connect(function()
    pillLocked = not pillLocked
    PillLock.Text = pillLocked and "🔒" or "🔓"
    local target = pillLocked and Color3.fromRGB(70, 25, 30) or Color3.fromRGB(30, 32, 54)
    tween(PillLock, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {BackgroundColor3 = target, Size = UDim2.fromOffset(25, 25)})
    task.delay(0.22, function()
        if PillLock.Parent then
            tween(PillLock, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                {Size = UDim2.fromOffset(21, 21)})
        end
    end)
    notify(pillLocked and "🔒  Панель заблокирована" or "🔓  Панель разблокирована", 1.8)
end)

-- ═══════════════════ MAIN WINDOW (PREMIUM) ═══════════════════
local MainFrame = create("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(720, 480),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(12, 13, 25),
    BorderSizePixel = 0, Visible = true, Parent = ScreenGui
})
corner(MainFrame, 20)
glow(MainFrame, 1.8, 0.12)
halo(MainFrame, 40, 0.92)
local UIScaleInst = create("UIScale", {Scale = Config.UIScale, Parent = MainFrame})

-- многослойный фон окна: верхнее свечение + нижнее
local TopGlow = create("ImageLabel", {
    AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, -70),
    Size = UDim2.new(1.15, 0, 0, 260), BackgroundTransparency = 1,
    Image = "rbxassetid://6014261993", ImageTransparency = 0.84,
    ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450),
    ZIndex = 0, Parent = MainFrame
})
accentize(TopGlow, "ImageColor3")

local BottomGlow = create("ImageLabel", {
    AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 60),
    Size = UDim2.new(1.05, 0, 0, 200), BackgroundTransparency = 1,
    Image = "rbxassetid://6014261993", ImageTransparency = 0.9,
    ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450),
    ZIndex = 0, Parent = MainFrame
})
accentize(BottomGlow, "ImageColor3", true)

-- тонкая сетка-узор на фоне
local GridPattern = create("Frame", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
    ZIndex = 0, Parent = MainFrame
})
create("UIGradient", {
    Color = ColorSequence.new(Color3.fromRGB(255,255,255)),
    Transparency = NumberSequence.new(0.985),
    Rotation = 90, Parent = GridPattern
})

-- декоративные звёздочки по углам
local cornerDecoData = {
    {UDim2.fromOffset(12, 66),  "✦", 9},
    {UDim2.new(1, -22, 0, 66),  "✧", 10},
    {UDim2.fromOffset(12, -24), "✧", 10},
    {UDim2.new(1, -22, 1, -24), "✦", 9},
}
local CornerDecos = {}
for _, d in ipairs(cornerDecoData) do
    local deco = create("TextLabel", {
        Text = d[2], Font = Enum.Font.GothamBlack, TextSize = d[3],
        TextTransparency = 0.6, Size = UDim2.fromOffset(14, 14),
        Position = d[1], BackgroundTransparency = 1, ZIndex = 2, Parent = MainFrame
    })
    accentize(deco, "TextColor3")
    table.insert(CornerDecos, deco)
end
task.spawn(function()
    local i = 0
    while MainFrame.Parent do
        i = i + 1
        local deco = CornerDecos[(i % #CornerDecos) + 1]
        if deco and deco.Parent then
            tween(deco, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {TextTransparency = 0.25, TextSize = 12})
            task.wait(0.85)
            tween(deco, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {TextTransparency = 0.6, TextSize = deco.Text == "✦" and 9 or 10})
            task.wait(0.2)
        else task.wait(0.5) end
    end
end)

-- ═══════════════════ TITLE BAR (PREMIUM) ═══════════════════
local TitleBar = create("Frame", {
    Name = "TitleBar", Size = UDim2.new(1, 0, 0, 58),
    BackgroundTransparency = 1, Parent = MainFrame
})
local TitleTint = create("Frame", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0.9,
    BorderSizePixel = 0, Parent = TitleBar
})
corner(TitleTint, 20); gradient(TitleTint, 15)

-- бегущий блик по шапке
local TitleShimmer = create("Frame", {
    Size = UDim2.fromOffset(130, 58), Position = UDim2.fromOffset(-130, 0),
    BackgroundTransparency = 0.92, BorderSizePixel = 0, Parent = TitleBar
})
create("UIGradient", {
    Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.72),
        NumberSequenceKeypoint.new(1, 1),
    }),
    Rotation = 20, Parent = TitleShimmer
})
task.spawn(function()
    while TitleShimmer.Parent do
        TitleShimmer.Position = UDim2.fromOffset(-130, 0)
        tween(TitleShimmer, TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            {Position = UDim2.new(1, 0, 0, 0)})
        task.wait(5.6)
    end
end)

-- логотип с вращающимся кольцом
local LogoRing = create("Frame", {
    Size = UDim2.fromOffset(36, 36), Position = UDim2.new(0, 15, 0.5, -18),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Parent = TitleBar
})
corner(LogoRing, 12); gradient(LogoRing, 45)
local LogoCore = create("Frame", {
    Size = UDim2.new(1, -4, 1, -4), Position = UDim2.fromOffset(2, 2),
    BackgroundColor3 = Color3.fromRGB(16, 17, 31), BorderSizePixel = 0, Parent = LogoRing
})
corner(LogoCore, 10)
local LogoLetter = create("TextLabel", {
    Text = "S", Font = Enum.Font.GothamBlack, TextSize = 18,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = LogoCore
})
gradient(LogoLetter, 30)
task.spawn(function()
    while LogoRing.Parent do
        local g = LogoRing:FindFirstChildOfClass("UIGradient")
        if g then
            tween(g, TweenInfo.new(4, Enum.EasingStyle.Linear), {Rotation = 405})
            task.wait(4)
            g.Rotation = 45
        else task.wait(1) end
    end
end)

local BrandLabel = create("TextLabel", {
    Text = "SANDREY", Font = Enum.Font.GothamBlack, TextSize = 18,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(0, 110, 0, 20), Position = UDim2.new(0, 60, 0, 10),
    BackgroundTransparency = 1, Parent = TitleBar
})
gradient(BrandLabel, 20)
local VerBadge = create("TextLabel", {
    Text = "v3.0", Font = Enum.Font.GothamBold, TextSize = 8.5,
    TextColor3 = Color3.fromRGB(12, 13, 24),
    Size = UDim2.fromOffset(30, 14), Position = UDim2.new(0, 172, 0, 13),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = TitleBar
})
corner(VerBadge, 7); gradient(VerBadge, 20)

local UserLabel = create("TextLabel", {
    Text = LocalPlayer.DisplayName .. "  ·  @" .. LocalPlayer.Name,
    Font = Enum.Font.GothamMedium, TextSize = 10,
    TextColor3 = Color3.fromRGB(140, 143, 178),
    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    Size = UDim2.new(0, 200, 0, 12), Position = UDim2.new(0, 60, 0, 32),
    BackgroundTransparency = 1, Parent = TitleBar
})

-- часы в шапке
local ClockBox = create("Frame", {
    Size = UDim2.fromOffset(76, 34), Position = UDim2.new(1, -190, 0.5, -17),
    BackgroundColor3 = Color3.fromRGB(24, 26, 46), BorderSizePixel = 0, Parent = TitleBar
})
corner(ClockBox, 11); glow(ClockBox, 1.2, 0.5)
local TitleClock = create("TextLabel", {
    Text = moscowTime(), Font = Enum.Font.GothamBlack, TextSize = 15,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 3),
    BackgroundTransparency = 1, Parent = ClockBox
})
table.insert(ClockLabels, TitleClock)
create("TextLabel", {
    Text = "МСК", Font = Enum.Font.GothamBold, TextSize = 8,
    TextColor3 = Color3.fromRGB(120, 123, 158),
    Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 0, 20),
    BackgroundTransparency = 1, Parent = ClockBox
})

local function titleButton(txt, xOffset, size)
    local b = create("TextButton", {
        Text = txt, Font = Enum.Font.GothamBold, TextSize = size or 18,
        TextColor3 = Color3.fromRGB(205, 207, 235),
        Size = UDim2.fromOffset(36, 36), Position = UDim2.new(1, xOffset, 0.5, -18),
        BackgroundColor3 = Color3.fromRGB(28, 30, 52), AutoButtonColor = false,
        BorderSizePixel = 0, Parent = TitleBar
    })
    corner(b, 11)
    b.MouseEnter:Connect(function() tween(b, nil, {BackgroundColor3 = Color3.fromRGB(44, 46, 78)}) end)
    b.MouseLeave:Connect(function() tween(b, nil, {BackgroundColor3 = Color3.fromRGB(28, 30, 52)}) end)
    return b
end
local MinimizeBtn = titleButton("–", -100, 20)
local HideBtn     = titleButton("◱", -60, 15)
local CloseBtn    = titleButton("×", -20, 20)

-- разделитель под шапкой
local Divider = create("Frame", {
    Size = UDim2.new(1, -28, 0, 1), Position = UDim2.new(0, 14, 0, 58),
    BackgroundTransparency = 0.7, BorderSizePixel = 0, ZIndex = 2, Parent = MainFrame
})
gradient(Divider, 90)

-- ═══════════════════ SIDEBAR (PREMIUM) ═══════════════════
local Sidebar = create("Frame", {
    Name = "Sidebar", Size = UDim2.new(0, 158, 1, -70), Position = UDim2.new(0, 10, 0, 64),
    BackgroundColor3 = Color3.fromRGB(16, 17, 31), BorderSizePixel = 0, Parent = MainFrame
})
corner(Sidebar, 15)
create("UIListLayout", {
    Padding = UDim.new(0, 7), HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder, Parent = Sidebar
})
create("UIPadding", {PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), Parent = Sidebar})

local Content = create("Frame", {
    Name = "Content", Size = UDim2.new(1, -186, 1, -74), Position = UDim2.new(0, 176, 0, 66),
    BackgroundTransparency = 1, Parent = MainFrame
})
local PageFolder = create("Folder", {Name = "Pages", Parent = Content})

-- вертикальная акцентная полоса
local SideStripe = create("Frame", {
    Size = UDim2.new(0, 2, 1, -84), Position = UDim2.new(0, 168, 0, 68),
    BackgroundTransparency = 0.8, BorderSizePixel = 0, Parent = MainFrame
})
gradient(SideStripe, 90)

makeDraggable(MainFrame, TitleBar)

-- ═══════════════════ TABS (ANIMATED) ═══════════════════
local Tabs, CurrentTab = {}, nil

local function selectTab(tab)
    if CurrentTab == tab then return end
    for _, t in ipairs(Tabs) do
        t.Page.Visible = false
        t.Highlight.BackgroundTransparency = 1
        t.Glow.Enabled = false
        tween(t.Button, nil, {BackgroundColor3 = Color3.fromRGB(22, 24, 42)})
        tween(t.Label, nil, {TextColor3 = Color3.fromRGB(150, 153, 190)})
    end
    tab.Page.Visible = true
    CurrentTab = tab
    tab.Highlight.BackgroundTransparency = 0
    tab.Glow.Enabled = true
    tween(tab.Button, nil, {BackgroundColor3 = Color3.fromRGB(34, 36, 62)})
    tween(tab.Label, nil, {TextColor3 = Color3.fromRGB(255, 255, 255)})
end

local function addTab(name, icon, badge)
    local btn = create("TextButton", {
        Name = name, Text = "", Size = UDim2.new(1, -18, 0, 38),
        BackgroundColor3 = Color3.fromRGB(22, 24, 42), AutoButtonColor = false,
        BorderSizePixel = 0, Parent = Sidebar
    })
    corner(btn, 12)

    local hl = create("Frame", {
        Size = UDim2.fromOffset(3, 20), Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundTransparency = 1, BorderSizePixel = 0, Parent = btn
    })
    corner(hl, 2); gradient(hl, 90)

    local lbl = create("TextLabel", {
        Text = icon .. "   " .. name, Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = Color3.fromRGB(150, 153, 190), TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -18, 1, 0), Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1, Parent = btn
    })

    local g = create("UIStroke", {Thickness = 1.2, Transparency = 0.4, Enabled = false, Parent = btn})
    gradient(g, 25)

    if badge then
        local b = create("TextLabel", {
            Text = badge, Font = Enum.Font.GothamBold, TextSize = 8,
            TextColor3 = Color3.fromRGB(12, 13, 24),
            Size = UDim2.fromOffset(32, 14), Position = UDim2.new(1, -40, 0.5, -7),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = btn
        })
        corner(b, 7); gradient(b, 20)
    end

    local page = create("ScrollingFrame", {
        Name = name .. "Page", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 3, Visible = false,
        AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
        Parent = PageFolder
    })
    accentize(page, "ScrollBarImageColor3")
    create("UIListLayout", {Padding = UDim.new(0, 11), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page})
    create("UIPadding", {
        PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 14),
        PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 10), Parent = page
    })

    local tab = {Button = btn, Label = lbl, Page = page, Highlight = hl, Glow = g}
    table.insert(Tabs, tab)

    btn.MouseButton1Click:Connect(function() selectTab(tab) end)
    btn.MouseEnter:Connect(function()
        if CurrentTab ~= tab then tween(btn, nil, {BackgroundColor3 = Color3.fromRGB(30, 32, 54)}) end
    end)
    btn.MouseLeave:Connect(function()
        if CurrentTab ~= tab then tween(btn, nil, {BackgroundColor3 = Color3.fromRGB(22, 24, 42)}) end
    end)
    return page
end

-- ═══════════════════ COMPONENTS (PREMIUM) ═══════════════════
local function addSection(parent, title, subtitle)
    local s = create("Frame", {
        Name = title, Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(19, 20, 37), BorderSizePixel = 0, Parent = parent
    })
    corner(s, 15)
    create("UIStroke", {Color = Color3.fromRGB(38, 40, 66), Thickness = 1, Parent = s})
    create("UIPadding", {
        PaddingTop = UDim.new(0, 13), PaddingBottom = UDim.new(0, 15),
        PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), Parent = s
    })
    create("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = s})

    -- акцентная полоска слева от заголовка
    local headRow = create("Frame", {
        Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Parent = s
    })
    local accentBar = create("Frame", {
        Size = UDim2.fromOffset(3, 14), Position = UDim2.new(0, 0, 0.5, -7),
        BorderSizePixel = 0, Parent = headRow
    })
    corner(accentBar, 2); gradient(accentBar, 90)
    local head = create("TextLabel", {
        Text = title, Font = Enum.Font.GothamBlack, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Parent = headRow
    })
    gradient(head, 20)

    if subtitle then
        create("TextLabel", {
            Text = subtitle, Font = Enum.Font.Gotham, TextSize = 10.5,
            TextColor3 = Color3.fromRGB(125, 128, 165), TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, Parent = s
        })
    end
    return s
end

local function addLabel(parent, text, color)
    return create("TextLabel", {
        Text = text, Font = Enum.Font.GothamMedium, TextSize = 11.5,
        TextColor3 = color or Color3.fromRGB(186, 189, 220), TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, Parent = parent
    })
end

local function addButton(parent, text, callback)
    local btn = create("TextButton", {
        Text = "", Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false,
        BorderSizePixel = 0, Parent = parent
    })
    corner(btn, 11)
    local g = gradient(btn, 20)
    create("TextLabel", {
        Text = text, Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = Color3.fromRGB(12, 13, 24), Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, Parent = btn
    })
    btn.MouseButton1Click:Connect(function()
        tween(btn, TweenInfo.new(0.08), {Size = UDim2.new(1, -6, 0, 33)})
        task.delay(0.09, function() tween(btn, TweenInfo.new(0.12), {Size = UDim2.new(1, 0, 0, 36)}) end)
        callback()
    end)
    btn.MouseEnter:Connect(function() tween(g, TweenInfo.new(0.25), {Rotation = 200}) end)
    btn.MouseLeave:Connect(function() tween(g, TweenInfo.new(0.25), {Rotation = 20}) end)
    return btn
end

local function addToggle(parent, labelText, default, callback)
    local c = create("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = parent})
    create("TextLabel", {
        Text = labelText, Font = Enum.Font.GothamSemibold, TextSize = 11.5,
        TextColor3 = Color3.fromRGB(212, 215, 240), TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -56, 1, 0), BackgroundTransparency = 1, Parent = c
    })
    local track = create("TextButton", {
        Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(42, 23),
        Position = UDim2.new(1, -44, 0.5, -11),
        BackgroundColor3 = Color3.fromRGB(44, 46, 74), BorderSizePixel = 0, Parent = c
    })
    corner(track, 12)
    local fillG = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = default and 0 or 1,
        BorderSizePixel = 0, Parent = track
    })
    corner(fillG, 12); gradient(fillG, 20)
    local knob = create("Frame", {
        Size = UDim2.fromOffset(17, 17), ZIndex = 2,
        Position = default and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Parent = track
    })
    corner(knob, 9)
    glow(knob, 1.4, 0.25)

    local state = default
    local function render(anim)
        local info = anim and TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out) or TweenInfo.new(0)
        tween(knob, info, {Position = state and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)})
        tween(fillG, TweenInfo.new(0.16), {BackgroundTransparency = state and 0 or 1})
    end
    track.MouseButton1Click:Connect(function()
        state = not state
        render(true)
        callback(state)
    end)
    return function(v) state = v render(false) end
end

local function addSlider(parent, labelText, min, max, default, callback, isInt, suffix)
    local c = create("Frame", {Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1, Parent = parent})
    create("TextLabel", {
        Text = labelText, Font = Enum.Font.GothamSemibold, TextSize = 11.5,
        TextColor3 = Color3.fromRGB(212, 215, 240), TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -64, 0, 16), BackgroundTransparency = 1, Parent = c
    })
    local val = create("TextLabel", {
        Text = tostring(default), Font = Enum.Font.GothamBlack, TextSize = 11.5,
        TextXAlignment = Enum.TextXAlignment.Right, Size = UDim2.new(0, 64, 0, 16),
        Position = UDim2.new(1, -64, 0, 0), BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255), Parent = c
    })
    accentize(val, "TextColor3", true)

    local track = create("Frame", {
        Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 27),
        BackgroundColor3 = Color3.fromRGB(40, 42, 68), BorderSizePixel = 0, Parent = c
    })
    corner(track, 3)
    local a0 = math.clamp((default - min) / (max - min), 0, 1)
    local fill = create("Frame", {Size = UDim2.new(a0, 0, 1, 0), BorderSizePixel = 0, Parent = track})
    corner(fill, 3); gradient(fill, 0)
    local knob = create("Frame", {
        Size = UDim2.fromOffset(15, 15), Position = UDim2.new(a0, -7, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255), ZIndex = 2,
        BorderSizePixel = 0, Parent = track
    })
    corner(knob, 8)
    glow(knob, 1.6, 0.2)

    local function setValue(raw, fire)
        local alpha = math.clamp((raw - min) / (max - min), 0, 1)
        local v = min + alpha * (max - min)
        if isInt then v = math.floor(v + 0.5) end
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, -7, 0.5, -7)
        val.Text = tostring(isInt and math.floor(v) or round(v, 2)) .. (suffix or "")
        if fire ~= false then callback(v) end
    end

    local active = false
    local function upd(input)
        local alpha = math.clamp((input.Position.X - track.AbsolutePosition.X)
            / math.max(track.AbsoluteSize.X, 1), 0, 1)
        setValue(min + alpha * (max - min))
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            active = true upd(i)
        end
    end)
    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            active = true
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if active and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            active = false
        end
    end)
    setValue(default, false)
    return setValue
end

local function addDropdown(parent, labelText, options, defaultIndex, callback)
    local c = create("Frame", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, ZIndex = 4, Parent = parent})
    create("TextLabel", {
        Text = labelText, Font = Enum.Font.GothamSemibold, TextSize = 11.5,
        TextColor3 = Color3.fromRGB(212, 215, 240), TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -152, 1, 0), BackgroundTransparency = 1, ZIndex = 4, Parent = c
    })
    local btn = create("TextButton", {
        Text = options[defaultIndex] .. "   ▾", Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.fromOffset(148, 28),
        Position = UDim2.new(1, -148, 0.5, -14), BackgroundColor3 = Color3.fromRGB(30, 32, 54),
        AutoButtonColor = false, ZIndex = 4, BorderSizePixel = 0, Parent = c
    })
    corner(btn, 10); glow(btn, 1.2, 0.5)

    local open, list = false, nil
    local function close()
        if list then list:Destroy() list = nil end
        open = false
        c.Size = UDim2.new(1, 0, 0, 34)
    end
    btn.MouseButton1Click:Connect(function()
        if open then close() return end
        open = true
        local h = #options * 26 + 6
        c.Size = UDim2.new(1, 0, 0, 34 + h + 4)
        list = create("Frame", {
            Size = UDim2.fromOffset(148, h), Position = UDim2.new(1, -148, 0, 34),
            BackgroundColor3 = Color3.fromRGB(24, 26, 46), ZIndex = 20, BorderSizePixel = 0, Parent = c
        })
        corner(list, 10); glow(list, 1.2, 0.4)
        create("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list})
        create("UIPadding", {
            PaddingTop = UDim.new(0, 3), PaddingLeft = UDim.new(0, 3),
            PaddingRight = UDim.new(0, 3), Parent = list
        })
        for i, opt in ipairs(options) do
            local item = create("TextButton", {
                Text = "  " .. opt, Font = Enum.Font.GothamMedium, TextSize = 11,
                TextColor3 = Color3.fromRGB(205, 208, 240), TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1, 0, 0, 24), BackgroundColor3 = Color3.fromRGB(24, 26, 46),
                BackgroundTransparency = 1, AutoButtonColor = false, ZIndex = 21,
                BorderSizePixel = 0, Parent = list
            })
            corner(item, 7)
            item.MouseEnter:Connect(function() item.BackgroundTransparency = 0.4 end)
            item.MouseLeave:Connect(function() item.BackgroundTransparency = 1 end)
            item.MouseButton1Click:Connect(function()
                btn.Text = opt .. "   ▾"
                close()
                callback(i, opt)
            end)
        end
    end)
    return btn
end

-- ═══════════════════ THEME APPLY ═══════════════════
local function applyTheme(index)
    local t = Themes[index] or Themes[1]
    Config.ThemeIndex = index
    Config.Accent, Config.Accent2 = t.A, t.B
    for _, g in ipairs(Gradients) do
        if g.Parent then g.Color = ColorSequence.new(t.A, t.B) end
    end
    for _, e in ipairs(AccentParts) do
        if e.obj.Parent then e.obj[e.prop] = e.second and t.B or t.A end
    end
    saveConfig()
end

-- ═══════════════════ PAGES ═══════════════════
local pageInfo     = addTab("Info",     "◈")
local pageVisuals  = addTab("Visuals",  "◉", "NEW")
local pageCombat   = addTab("Combat",   "✦", "NEW")
local pagePlayer   = addTab("Player",   "◍")
local pageServer   = addTab("Server",   "◎")
local pageSettings = addTab("Settings", "❖")

-- ─────────── INFO ───────────
local sWelcome = addSection(pageInfo, "Sandrey Hub v3.0", "Премиальный универсальный интерфейс для UNC-совместимых инжекторов.")
addLabel(sWelcome, "• Visuals — третье лицо без потери управления камерой")
addLabel(sWelcome, "• Combat — Silent Aim с выбором точки прицела")
addLabel(sWelcome, "• Тема, масштаб и все настройки сохраняются автоматически")

local sInfo = addSection(pageInfo, "Сессия")
addLabel(sInfo, "Executor:  " .. getExecutorName())
addLabel(sInfo, "Аккаунт:   " .. LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")")
addLabel(sInfo, "PlaceId:   " .. tostring(game.PlaceId))
local lblFps  = addLabel(sInfo, "FPS:  --")
local lblPing = addLabel(sInfo, "Ping: --")
local lblTime = addLabel(sInfo, "Время МСК: " .. moscowTime())

local frameAcc, frameCount, lastSample = 0, 0, os.clock()
RunService.Heartbeat:Connect(function(dt)
    frameAcc = frameAcc + dt
    frameCount = frameCount + 1
    if os.clock() - lastSample >= 0.5 then
        lastSample = os.clock()
        local fps = frameCount / math.max(frameAcc, 0.0001)
        lblFps.Text = "FPS:  " .. tostring(math.floor(fps + 0.5))
        frameAcc, frameCount = 0, 0
        local ping = "--"
        pcall(function()
            ping = tostring(math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())) .. " ms"
        end)
        lblPing.Text = "Ping: " .. ping
        lblTime.Text = "Время МСК: " .. moscowTime()
    end
end)

-- ═══════════════════ VISUALS · THIRD PERSON ═══════════════════
local sCam = addSection(pageVisuals, "Третье лицо",
    "Камера отводится назад, тело полностью скрывается. Значения применяются каждый кадр — вид не слетает во время анимаций и перезарядки.")

local TP = { active = false, touched = {} }

local function forEachCharPart(char, fn)
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") then
            local inTool = v:FindFirstAncestorWhichIsA("Tool") ~= nil
            fn(v, inTool)
        end
    end
end

local function hideBody(char)
    forEachCharPart(char, function(v, inTool)
        if inTool and not Config.TP_HideTool then return end
        if v.LocalTransparencyModifier ~= 1 then
            v.LocalTransparencyModifier = 1
        end
        TP.touched[v] = true
    end)
end

local function restoreBody()
    for v in pairs(TP.touched) do
        if v and v.Parent then
            pcall(function() v.LocalTransparencyModifier = 0 end)
        end
    end
    TP.touched = {}
end

local function restoreCamera()
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.CameraOffset = Vector3.new(0, 0, 0) end
        end
        Camera.CameraType = Enum.CameraType.Custom
    end)
end

RunService:BindToRenderStep("Sandrey_ThirdPerson", Enum.RenderPriority.Camera.Value + 1, function()
    if not TP.active then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if LocalPlayer.CameraMode ~= Enum.CameraMode.Classic then
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
    end
    if Camera.CameraType ~= Enum.CameraType.Custom then
        Camera.CameraType = Enum.CameraType.Custom
    end
    if LocalPlayer.CameraMaxZoomDistance < Config.TP_Distance + 4 then
        LocalPlayer.CameraMaxZoomDistance = Config.TP_Distance + 4
    end

    local goal = Vector3.new(Config.TP_Side, Config.TP_Height, Config.TP_Distance)
    if (hum.CameraOffset - goal).Magnitude > 0.005 then
        hum.CameraOffset = goal
    end

    if Config.TP_HideBody then hideBody(char) end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    TP.touched = {}
    if not TP.active then return end
    char:WaitForChild("Humanoid", 5)
    task.wait(0.15)
end)

local setTPToggle = addToggle(sCam, "Включить третье лицо", Config.TP_Enabled, function(state)
    TP.active = state
    Config.TP_Enabled = state
    if not state then
        restoreBody()
        restoreCamera()
    end
    notify(state and "Третье лицо: ВКЛ" or "Третье лицо: ВЫКЛ")
    saveConfig()
end)

addSlider(sCam, "Дистанция", 2, 25, Config.TP_Distance, function(v)
    Config.TP_Distance = v saveConfig()
end, true)

addSlider(sCam, "Высота", -5, 8, Config.TP_Height, function(v)
    Config.TP_Height = v saveConfig()
end, false)

addSlider(sCam, "Смещение вбок", -6, 6, Config.TP_Side, function(v)
    Config.TP_Side = v saveConfig()
end, false)

addToggle(sCam, "Полностью скрыть тело", Config.TP_HideBody, function(state)
    Config.TP_HideBody = state
    if not state then restoreBody() end
    saveConfig()
end)

addToggle(sCam, "Скрывать оружие в руках", Config.TP_HideTool, function(state)
    Config.TP_HideTool = state
    if not state then restoreBody() end
    saveConfig()
end)

addButton(sCam, "Сбросить камеру", function()
    TP.active = false
    Config.TP_Enabled = false
    setTPToggle(false)
    restoreBody()
    restoreCamera()
    notify("Камера сброшена")
end)

if Config.TP_Enabled then TP.active = true end

-- ═══════════════════ COMBAT · SILENT AIM ═══════════════════
local sAim = addSection(pageCombat, "Silent Aim",
    "Перехватывает Raycast / FindPartOnRay и подменяет направление луча на цель. Точка прицела — курсор/палец либо центр экрана.")

local FOVCircle
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 72
    FOVCircle.Filled = false
    FOVCircle.Transparency = 0.9
    FOVCircle.Color = Config.Accent
    FOVCircle.Visible = false
end)

local lastTouchPos = nil
UserInputService.TouchStarted:Connect(function(t)
    lastTouchPos = Vector2.new(t.Position.X, t.Position.Y)
end)
UserInputService.TouchMoved:Connect(function(t)
    lastTouchPos = Vector2.new(t.Position.X, t.Position.Y)
end)

local function getAimPoint()
    if Config.SA_AimMode == "Center" then
        local vp = Camera.ViewportSize
        return Vector2.new(vp.X / 2, vp.Y / 2)
    end
    if UserInputService.TouchEnabled and lastTouchPos then
        return lastTouchPos
    end
    local inset = GuiService:GetGuiInset()
    local m = UserInputService:GetMouseLocation()
    return Vector2.new(m.X + inset.X, m.Y + inset.Y)
end

local function isEnemy(plr)
    if plr == LocalPlayer then return false end
    if not Config.SA_IgnoreTeam then return true end
    local ok, same = pcall(function()
        return plr.Team ~= nil and LocalPlayer.Team ~= nil and plr.Team == LocalPlayer.Team
    end)
    return not (ok and same)
end

local function getTarget()
    local aim = getAimPoint()
    local best, bestDist = nil, Config.SA_FOV

    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) and plr.Character then
            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local wanted = Config.SA_Part
                if wanted == "Random" then
                    wanted = (math.random() < 0.5) and "Head" or "HumanoidRootPart"
                end
                local part = char:FindFirstChild(wanted)
                    or char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
                if part then
                    local v, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local d = (Vector2.new(v.X, v.Y) - aim).Magnitude
                        if d < bestDist then
                            bestDist, best = d, part
                        end
                    end
                end
            end
        end
    end
    return best
end

local hooked = false
local function installHook()
    if hooked then return true end
    if not hookmetamethod or not getnamecallmethod then
        notify("Executor не поддерживает hookmetamethod", 4)
        return false
    end
    local ok = pcall(function()
        local old
        old = hookmetamethod(game, "__namecall", safeClosure(function(self, ...)
            local method = getnamecallmethod()
            if Config.SA_Enabled and (not checkcaller or not checkcaller()) then
                if method == "Raycast" or method == "FindPartOnRay"
                or method == "FindPartOnRayWithIgnoreList"
                or method == "FindPartOnRayWithWhitelist" then
                    local target = getTarget()
                    if target then
                        local args = {...}
                        if method == "Raycast" then
                            local origin = args[1]
                            if typeof(origin) == "Vector3" then
                                local dir = args[2]
                                local len = (typeof(dir) == "Vector3") and dir.Magnitude or 1000
                                local newDir = (target.Position - origin).Unit * len
                                return old(self, origin, newDir, args[3])
                            end
                        else
                            local ray = args[1]
                            if typeof(ray) == "Ray" then
                                local len = ray.Direction.Magnitude
                                local newRay = Ray.new(ray.Origin, (target.Position - ray.Origin).Unit * len)
                                return old(self, newRay, table.unpack(args, 2))
                            end
                        end
                    end
                end
            end
            return old(self, ...)
        end))
    end)
    if ok then hooked = true else notify("Не удалось установить хук", 4) end
    return ok
end

RunService.RenderStepped:Connect(function()
    if not FOVCircle then return end
    if Config.SA_Enabled and Config.SA_ShowFOV then
        local p = getAimPoint()
        FOVCircle.Position = p
        FOVCircle.Radius = Config.SA_FOV
        FOVCircle.Color = Config.Accent2
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)

addToggle(sAim, "Включить Silent Aim", false, function(state)
    if state and not installHook() then return end
    Config.SA_Enabled = state
    notify(state and "Silent Aim: ВКЛ" or "Silent Aim: ВЫКЛ")
    saveConfig()
end)

local aimModes = {"Курсор / Касание", "Центр экрана"}
addDropdown(sAim, "Точка прицела", aimModes, Config.SA_AimMode == "Center" and 2 or 1, function(i)
    Config.SA_AimMode = (i == 2) and "Center" or "Cursor"
    notify("Точка прицела: " .. aimModes[i])
    saveConfig()
end)

addSlider(sAim, "Радиус FOV", 20, 600, Config.SA_FOV, function(v)
    Config.SA_FOV = v saveConfig()
end, true, " px")

local partOptions = {"HumanoidRootPart", "Head", "Random"}
local partIndex = 1
for i, v in ipairs(partOptions) do if v == Config.SA_Part then partIndex = i end end
addDropdown(sAim, "Часть тела", partOptions, partIndex, function(_, opt)
    Config.SA_Part = opt saveConfig()
end)

addToggle(sAim, "Показывать круг FOV", Config.SA_ShowFOV, function(state)
    Config.SA_ShowFOV = state saveConfig()
end)

addToggle(sAim, "Игнорировать союзников", Config.SA_IgnoreTeam, function(state)
    Config.SA_IgnoreTeam = state saveConfig()
end)

local sAimInfo = addSection(pageCombat, "Статус")
local lblTarget = addLabel(sAimInfo, "Цель: нет")
task.spawn(function()
    while ScreenGui.Parent do
        if Config.SA_Enabled then
            local t = getTarget()
            if t and t.Parent then
                local plr = Players:GetPlayerFromCharacter(t.Parent)
                lblTarget.Text = "Цель: " .. (plr and plr.DisplayName or t.Parent.Name) .. "  ·  " .. t.Name
            else
                lblTarget.Text = "Цель: нет"
            end
        else
            lblTarget.Text = "Цель: — (выключено)"
        end
        task.wait(0.2)
    end
end)

-- ─────────── PLAYER ───────────
local sHp = addSection(pagePlayer, "Состояние")
local hpBg = create("Frame", {
    Size = UDim2.new(1, 0, 0, 10), BackgroundColor3 = Color3.fromRGB(40, 42, 68),
    BorderSizePixel = 0, Parent = sHp
})
corner(hpBg, 5)
local hpFill = create("Frame", {Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, Parent = hpBg})
corner(hpFill, 5); gradient(hpFill, 0)
local hpText = addLabel(sHp, "Health: -- / --")

local function updateHealth()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.MaxHealth > 0 then
        hpFill.Size = UDim2.new(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0, 1, 0)
        hpText.Text = string.format("Health: %.0f / %.0f", hum.Health, hum.MaxHealth)
    else
        hpText.Text = "Health: -- / --"
    end
end

local function bindHumanoid()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    updateHealth()
    hum.HealthChanged:Connect(updateHealth)
    hum:GetPropertyChangedSignal("MaxHealth"):Connect(updateHealth)
end
bindHumanoid()
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.3) bindHumanoid() end)

local sPos = addSection(pagePlayer, "Позиция")
local posLabel = addLabel(sPos, "Position: --")
task.spawn(function()
    while ScreenGui.Parent do
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local p = hrp.Position
            posLabel.Text = string.format("Position: %.1f, %.1f, %.1f", p.X, p.Y, p.Z)
        else
            posLabel.Text = "Position: --"
        end
        task.wait(0.2)
    end
end)
addButton(sPos, "Скопировать координаты", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and setclipboard then
        local p = hrp.Position
        setclipboard(string.format("%.2f, %.2f, %.2f", p.X, p.Y, p.Z))
        notify("Координаты скопированы")
    end
end)

-- ─────────── SERVER ───────────
local sSrv = addSection(pageServer, "Сервер")
local lblPlayers = addLabel(sSrv, "Игроки: --")
addLabel(sSrv, "JobId: " .. tostring(game.JobId))
local function updSrv()
    lblPlayers.Text = "Игроки: " .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers
end
updSrv()
Players.PlayerAdded:Connect(updSrv)
Players.PlayerRemoving:Connect(updSrv)

local sUtil = addSection(pageServer, "Утилиты")
addButton(sUtil, "Скопировать JobId", function()
    if setclipboard then setclipboard(tostring(game.JobId)) notify("JobId скопирован") end
end)
addButton(sUtil, "Перезайти на сервер", function()
    pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end)
end)

-- ─────────── SETTINGS ───────────
local sTheme = addSection(pageSettings, "Оформление", "Выбери палитру — она применится сразу ко всему интерфейсу.")
local themeRow = create("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Parent = sTheme})
create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 9),
    SortOrder = Enum.SortOrder.LayoutOrder, Parent = themeRow
})
for i, t in ipairs(Themes) do
    local swatch = create("TextButton", {
        Text = "", Size = UDim2.fromOffset(40, 40),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255), AutoButtonColor = false,
        BorderSizePixel = 0, Parent = themeRow
    })
    corner(swatch, 13)
    create("UIGradient", {Color = ColorSequence.new(t.A, t.B), Rotation = 25, Parent = swatch})
    create("UIStroke", {Color = Color3.fromRGB(255, 255, 255), Thickness = 2, Transparency = 0.8, Parent = swatch})
    swatch.MouseEnter:Connect(function()
        tween(swatch, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.fromOffset(44, 44)})
    end)
    swatch.MouseLeave:Connect(function()
        tween(swatch, TweenInfo.new(0.15), {Size = UDim2.fromOffset(40, 40)})
    end)
    swatch.MouseButton1Click:Connect(function()
        applyTheme(i)
        notify("Тема: " .. t.Name)
    end)
end

local sUI = addSection(pageSettings, "Интерфейс")
addSlider(sUI, "Масштаб", 0.3, 1.6, Config.UIScale, function(v)
    Config.UIScale = v
    UIScaleInst.Scale = v
    saveConfig()
end)

local listeningKey = false
local keyRow = create("Frame", {Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Parent = sUI})
create("TextLabel", {
    Text = "Клавиша скрытия", Font = Enum.Font.GothamSemibold, TextSize = 11.5,
    TextColor3 = Color3.fromRGB(212, 215, 240), TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(1, -110, 1, 0), BackgroundTransparency = 1, Parent = keyRow
})
local keyBtnLabel = create("TextButton", {
    Text = tostring(Config.ToggleKey):gsub("Enum.KeyCode.", ""),
    Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255),
    Size = UDim2.fromOffset(104, 28), Position = UDim2.new(1, -104, 0.5, -14),
    BackgroundColor3 = Color3.fromRGB(30, 32, 54), AutoButtonColor = false,
    BorderSizePixel = 0, Parent = keyRow
})
corner(keyBtnLabel, 10); glow(keyBtnLabel, 1.2, 0.5)
keyBtnLabel.MouseButton1Click:Connect(function()
    listeningKey = true
    keyBtnLabel.Text = "Нажми клавишу..."
end)

addButton(sUI, "Свернуть в пилюлю", function() MainFrame.Visible = false end)
addButton(sUI, "Выгрузить Sandrey", function()
    pcall(function() RunService:UnbindFromRenderStep("Sandrey_ThirdPerson") end)
    restoreBody() restoreCamera()
    if FOVCircle then pcall(function() FOVCircle:Remove() end) end
    ScreenGui:Destroy()
end)

-- ═══════════════════ WINDOW CONTROLS ═══════════════════
local function toggleWindow()
    MainFrame.Visible = not MainFrame.Visible
    PillChevron.Text = MainFrame.Visible and "‹" or "›"
end

makeDraggable(Pill, Pill, toggleWindow, function() return pillLocked end)

CloseBtn.MouseButton1Click:Connect(function()
    pcall(function() RunService:UnbindFromRenderStep("Sandrey_ThirdPerson") end)
    restoreBody() restoreCamera()
    if FOVCircle then pcall(function() FOVCircle:Remove() end) end
    ScreenGui:Destroy()
end)

HideBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Sidebar.Visible = not minimized
    Content.Visible = not minimized
    tween(MainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = minimized and UDim2.fromOffset(380, 58) or UDim2.fromOffset(720, 480)
    })
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if listeningKey then
        listeningKey = false
        Config.ToggleKey = input.KeyCode
        keyBtnLabel.Text = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
        saveConfig()
        return
    end
    if gpe then return end
    if input.KeyCode == Config.ToggleKey then toggleWindow() end
end)

-- ═══════════════════ INIT (PREMIUM INTRO) ═══════════════════
applyTheme(Config.ThemeIndex)
selectTab(Tabs[1])

-- плавное появление окна
MainFrame.Size = UDim2.fromOffset(640, 420)
MainFrame.BackgroundTransparency = 1
tween(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {Size = UDim2.fromOffset(720, 480), BackgroundTransparency = 0})

-- пилюля выезжает слева
Pill.Position = UDim2.new(0, -240, 0, 96)
tween(Pill, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    {Position = UDim2.new(0, 24, 0, 96)})

notify("Sandrey Hub v3.0 загружен · " .. getExecutorName(), 3)
print("[Sandrey] v3.0 PREMIUM loaded | Executor: " .. getExecutorName() .. " | MSK " .. moscowTime())
