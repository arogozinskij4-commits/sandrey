-- Delta Hub | Rost Alpha
-- Full Delta Executor compatible build
-- Mobile optimized | ESP + AimLock + Snipelines

pcall(function()
    for _,v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v:IsA("ScreenGui") and v.Name:sub(1,3) == "DH_" then v:Destroy() end
    end
end)

local function decryptKey(input)
    local key = string.char(115,97,110,100,114,101,121)
    return input == key
end

local Http = game:GetService("HttpService")
local Plrs = game:GetService("Players")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Light = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local LP = Plrs.LocalPlayer
local Cam = workspace.CurrentCamera

-- Delta-safe wait/spawn
local swait = task and task.wait or wait
local sspawn = task and task.spawn or spawn
local sdelay = task and task.delay or delay

local HFILE = "delta_hub_history.json"
local hist = {}
local function sH()
    pcall(function()
        if writefile then writefile(HFILE, Http:JSONEncode(hist)) end
    end)
end
local function lH()
    pcall(function()
        if readfile and isfile and isfile(HFILE) then
            hist = Http:JSONDecode(readfile(HFILE)) or {}
        end
    end)
end
lH()

local fdb = {
    {n={"esp","\u0435\u0441\u043f","wallhack"},f="ESP"},
    {n={"sky","\u043d\u0435\u0431\u043e","\u0441\u043a\u0430\u0439","\u0441\u0432\u0438\u043d","\u0441\u0438\u0433\u043c\u0430","\u0441\u0438\u0433\u043c\u0430\u0441\u0432\u0438\u043d"},f="Sky"},
    {n={"aimbot","\u0430\u0438\u043c\u0431\u043e\u0442","aim","\u0430\u0438\u043c","aimlock","\u0430\u0438\u043c\u043b\u043e\u043a"},f="Aimbot"},
    {n={"speed","\u0441\u043a\u043e\u0440\u043e\u0441\u0442\u044c"},f="Speed"},
    {n={"fly","\u0444\u043b\u0430\u0439","\u043f\u043e\u043b\u0435\u0442"},f="Fly"},
    {n={"snipe","\u0441\u043d\u0430\u0439\u043f","snipelines","\u0441\u0442\u0440\u0435\u043b\u043a\u0438","arrows"},f="Snipelines"},
}
local function aSearch(q)
    q = string.lower(q)
    for _,d in ipairs(fdb) do
        for _,n in ipairs(d.n) do
            if string.find(q, n) then return d.f end
        end
    end
end

-- ScreenGui creation — Delta compatible
local gui = Instance.new("ScreenGui")
gui.Name = "DH_" .. tostring(math.random(100000,999999))
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false

pcall(function() gui.IgnoreGuiInset = true end)

-- Delta Executor: direct parent to CoreGui
local guiParented = false
pcall(function()
    if gethui then
        gui.Parent = gethui()
        guiParented = true
    end
end)
if not guiParented then
    pcall(function()
        gui.Parent = game:GetService("CoreGui")
        guiParented = true
    end)
end
if not guiParented then
    pcall(function()
        gui.Parent = LP:WaitForChild("PlayerGui")
    end)
end

local cn = {}
local function ac(c) cn[#cn+1] = c end
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
end

local function drag(f, h)
    local d, ds, sp = false, nil, nil
    h.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            d = true; ds = i.Position; sp = f.Position
            pcall(function()
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then d = false end
                end)
            end)
        end
    end)
    h.InputChanged:Connect(function(i)
        if d and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local dt = i.Position - ds
            f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + dt.X, sp.Y.Scale, sp.Y.Offset + dt.Y)
        end
    end)
end

local function hsv(h, s, v)
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then return v,t,p
    elseif i == 1 then return q,v,p
    elseif i == 2 then return p,v,t
    elseif i == 3 then return p,q,v
    elseif i == 4 then return t,p,v
    else return v,p,q end
end

-- Single render ticker instead of multiple RenderStepped
local renderCallbacks = {}
local function onRender(id, fn)
    renderCallbacks[id] = fn
end
local function offRender(id)
    renderCallbacks[id] = nil
end

ac(RS.Heartbeat:Connect(function()
    for _, fn in pairs(renderCallbacks) do
        pcall(fn)
    end
end))

local function shimmer(parent, sp, br)
    sp = sp or 0.04; br = br or 0.06
    local g = Instance.new("UIGradient"); g.Parent = parent
    local uid = tostring(g) .. tostring(math.random(1,999999))
    onRender("shm_"..uid, function()
        if not g or not g.Parent then offRender("shm_"..uid); return end
        local t = tick() * sp
        local r1,g1,b1 = hsv(t % 1, 0.3, br)
        local r2,g2,b2 = hsv((t + 0.15) % 1, 0.25, br * 1.3)
        local r3,g3,b3 = hsv((t + 0.3) % 1, 0.3, br)
        g.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(r1,g1,b1)),
            ColorSequenceKeypoint.new(0.5, Color3.new(r2,g2,b2)),
            ColorSequenceKeypoint.new(1, Color3.new(r3,g3,b3))
        }
        g.Rotation = math.sin(t * 1.5) * 25 + 45
    end)
end

local function glow(parent, th)
    local s = Instance.new("UIStroke"); s.Thickness = th or 0.8; s.Transparency = 0.4
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = parent
    local g = Instance.new("UIGradient"); g.Parent = s
    local uid = tostring(s) .. tostring(math.random(1,999999))
    onRender("glw_"..uid, function()
        if not g or not g.Parent then offRender("glw_"..uid); return end
        local t = tick()
        local h1 = (t * 0.06) % 1; local h2 = (t * 0.06 + 0.5) % 1
        local r1,g1,b1 = hsv(h1, 0.5, 0.5)
        local r2,g2,b2 = hsv(h2, 0.5, 0.5)
        g.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(r1,g1,b1)),
            ColorSequenceKeypoint.new(1, Color3.new(r2,g2,b2))
        }
        g.Rotation = (t * 25) % 360
    end)
end

local function glowLine(parent, y)
    local l = Instance.new("Frame"); l.Size = UDim2.new(1,0,0,1); l.Position = UDim2.new(0,0,0,y or 0)
    l.BackgroundColor3 = Color3.new(1,1,1); l.BorderSizePixel = 0; l.ZIndex = parent.ZIndex + 5; l.Parent = parent
    local g = Instance.new("UIGradient")
    g.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.85),
        NumberSequenceKeypoint.new(0.4, 0.3),
        NumberSequenceKeypoint.new(0.6, 0.3),
        NumberSequenceKeypoint.new(1, 0.85)
    }
    g.Parent = l
    local uid = tostring(l) .. tostring(math.random(1,999999))
    onRender("gll_"..uid, function()
        if not g or not g.Parent then offRender("gll_"..uid); return end
        local t = tick()
        local h1 = (t * 0.08) % 1; local h2 = (t * 0.08 + 0.5) % 1
        local r1,g1,b1 = hsv(h1, 0.6, 0.55)
        local r2,g2,b2 = hsv(h2, 0.6, 0.55)
        g.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(r1,g1,b1)),
            ColorSequenceKeypoint.new(1, Color3.new(r2,g2,b2))
        }
    end)
end

local function softText(label, text)
    label.Text = text
    local uid = tostring(label) .. tostring(math.random(1,999999))
    onRender("stx_"..uid, function()
        if not label or not label.Parent then offRender("stx_"..uid); return end
        local t = tick(); local h = (t * 0.06) % 1
        local r,g,b = hsv(h, 0.35, 0.85)
        label.TextColor3 = Color3.new(r,g,b)
    end)
end

local c1 = Color3.fromRGB(210,210,230)
local c2 = Color3.fromRGB(100,100,130)
local c3 = Color3.fromRGB(50,50,70)
local bg1 = Color3.fromRGB(10,10,16)
local bg2 = Color3.fromRGB(14,14,22)
local bg3 = Color3.fromRGB(7,7,12)
local red = Color3.fromRGB(220,45,60)
local grn = Color3.fromRGB(0,190,95)
local ylw = Color3.fromRGB(230,175,0)

-- ===== INTRO =====
local intro = Instance.new("Frame")
intro.Size = UDim2.new(1,0,1,0); intro.BackgroundColor3 = Color3.fromRGB(3,3,7)
intro.ZIndex = 100; intro.Parent = gui
shimmer(intro, 0.04, 0.04)

local iT = Instance.new("TextLabel")
iT.Size = UDim2.new(1,0,0,18); iT.Position = UDim2.new(0,0,0.5,-9); iT.BackgroundTransparency = 1
iT.Text = ""; iT.TextSize = 14; iT.Font = Enum.Font.GothamBlack; iT.TextTransparency = 1
iT.ZIndex = 102; iT.Parent = intro

local iS = Instance.new("TextLabel")
iS.Size = UDim2.new(1,0,0,10); iS.Position = UDim2.new(0,0,0.5,12); iS.BackgroundTransparency = 1
iS.Text = "loading..."; iS.TextColor3 = c3; iS.TextSize = 8; iS.Font = Enum.Font.Gotham
iS.TextTransparency = 1; iS.ZIndex = 102; iS.Parent = intro

local iL = Instance.new("Frame")
iL.Size = UDim2.new(0,0,0,1); iL.Position = UDim2.new(0.5,0,0.5,26)
iL.AnchorPoint = Vector2.new(0.5,0)
iL.BackgroundColor3 = Color3.new(1,1,1); iL.BorderSizePixel = 0; iL.ZIndex = 102
iL.Parent = intro; corner(iL,1)
local iLG = Instance.new("UIGradient"); iLG.Parent = iL

local iAnId = "intro_bar"
onRender(iAnId, function()
    if not iLG or not iLG.Parent then offRender(iAnId); return end
    local t = tick()
    local h1 = (t * 0.1) % 1; local h2 = (t * 0.1 + 0.5) % 1
    local r1,g1,b1 = hsv(h1, 0.5, 0.7)
    local r2,g2,b2 = hsv(h2, 0.5, 0.7)
    iLG.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(r1,g1,b1)),
        ColorSequenceKeypoint.new(1, Color3.new(r2,g2,b2))
    }
end)

sspawn(function()
    swait(0.1)
    TS:Create(iT, TweenInfo.new(0.2), {TextTransparency=0}):Play()
    TS:Create(iS, TweenInfo.new(0.2), {TextTransparency=0}):Play()
    TS:Create(iL, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size=UDim2.new(0,100,0,1)}):Play()
    local ft = "RostAlphaScripts"
    for i = 1, #ft do iT.Text = string.sub(ft, 1, i); swait(0.03) end
    softText(iT, "RostAlphaScripts")
    swait(0.5)
    TS:Create(iT, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextTransparency=1}):Play()
    TS:Create(iS, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextTransparency=1}):Play()
    TS:Create(iL, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size=UDim2.new(0,0,0,1)}):Play()
    TS:Create(intro, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency=1}):Play()
    swait(0.35)
    offRender(iAnId)
    intro:Destroy()
end)

-- ===== KEY FRAME =====
local kf = Instance.new("Frame")
kf.Size = UDim2.new(0,240,0,310)
kf.Position = UDim2.new(0.5,-120,0.5,-155)
kf.BackgroundColor3 = bg3; kf.BorderSizePixel = 0; kf.ClipsDescendants = true; kf.Parent = gui
corner(kf,10); glow(kf,1); shimmer(kf,0.05,0.06)
glowLine(kf,0)

local kTi = Instance.new("TextLabel")
kTi.Size = UDim2.new(1,0,0,16); kTi.Position = UDim2.new(0,0,0,8); kTi.BackgroundTransparency = 1
kTi.Text = "Delta Hub"; kTi.TextSize = 13; kTi.Font = Enum.Font.GothamBlack; kTi.ZIndex = 2; kTi.Parent = kf
softText(kTi, "Delta Hub")

local kSu = Instance.new("TextLabel")
kSu.Size = UDim2.new(1,0,0,9); kSu.Position = UDim2.new(0,0,0,26); kSu.BackgroundTransparency = 1
kSu.Text = "enter key"; kSu.TextColor3 = c3; kSu.TextSize = 7; kSu.Font = Enum.Font.Gotham; kSu.ZIndex = 2; kSu.Parent = kf

local kBx = Instance.new("Frame")
kBx.Size = UDim2.new(0.86,0,0,26); kBx.Position = UDim2.new(0.07,0,0,40)
kBx.BackgroundColor3 = bg2; kBx.BorderSizePixel = 0; kBx.ZIndex = 2; kBx.Parent = kf; corner(kBx,5); glow(kBx,0.5)

local kIn = Instance.new("TextBox")
kIn.Size = UDim2.new(1,-10,1,0); kIn.Position = UDim2.new(0,5,0,0); kIn.BackgroundTransparency = 1
kIn.TextColor3 = c1; kIn.PlaceholderText = "key..."; kIn.PlaceholderColor3 = c3; kIn.Text = ""
kIn.TextSize = 10; kIn.Font = Enum.Font.GothamSemibold; kIn.ClearTextOnFocus = false; kIn.ZIndex = 3; kIn.Parent = kBx

local kVb = Instance.new("TextButton")
kVb.Size = UDim2.new(0.86,0,0,26); kVb.Position = UDim2.new(0.07,0,0,72)
kVb.BackgroundColor3 = Color3.fromRGB(16,16,28); kVb.BorderSizePixel = 0; kVb.Text = "verify"
kVb.TextColor3 = c1; kVb.TextSize = 10; kVb.Font = Enum.Font.GothamBold
kVb.AutoButtonColor = false; kVb.ZIndex = 3; kVb.Parent = kf; corner(kVb,5); shimmer(kVb,0.08,0.2)

local kLb = Instance.new("TextButton")
kLb.Size = UDim2.new(0.86,0,0,20); kLb.Position = UDim2.new(0.07,0,0,103)
kLb.BackgroundColor3 = bg2; kLb.BorderSizePixel = 0; kLb.Text = "last key"; kLb.TextColor3 = c2
kLb.TextSize = 8; kLb.Font = Enum.Font.GothamBold; kLb.AutoButtonColor = false; kLb.ZIndex = 3; kLb.Parent = kf
corner(kLb,5); glow(kLb,0.4)

local function glk()
    for _,h in ipairs(hist) do if h.ok then return h.key end end
end
if not glk() then kLb.TextColor3 = c3; kLb.Text = "no saved key" end

local kSt = Instance.new("TextLabel")
kSt.Size = UDim2.new(1,0,0,10); kSt.Position = UDim2.new(0,0,0,128); kSt.BackgroundTransparency = 1
kSt.Text = ""; kSt.TextColor3 = red; kSt.TextSize = 8; kSt.Font = Enum.Font.GothamBold; kSt.ZIndex = 2; kSt.Parent = kf

local hLb = Instance.new("TextLabel")
hLb.Size = UDim2.new(0.86,0,0,10); hLb.Position = UDim2.new(0.07,0,0,143); hLb.BackgroundTransparency = 1
hLb.Text = "history"; hLb.TextColor3 = c2; hLb.TextSize = 7; hLb.Font = Enum.Font.GothamBold
hLb.TextXAlignment = Enum.TextXAlignment.Left; hLb.ZIndex = 2; hLb.Parent = kf

local hSc = Instance.new("ScrollingFrame")
hSc.Size = UDim2.new(0.86,0,0,145); hSc.Position = UDim2.new(0.07,0,0,155)
hSc.BackgroundColor3 = bg1; hSc.BackgroundTransparency = 0.4; hSc.BorderSizePixel = 0
hSc.ScrollBarThickness = 1; hSc.ScrollBarImageTransparency = 0.3
hSc.CanvasSize = UDim2.new(0,0,0,0); hSc.ZIndex = 2; hSc.Parent = kf; corner(hSc,5)
pcall(function() hSc.AutomaticCanvasSize = Enum.AutomaticSize.Y end)

onRender("hsc_scroll", function()
    if not hSc or not hSc.Parent then offRender("hsc_scroll"); return end
    local h = (tick() * 0.06) % 1
    local r,g,b = hsv(h, 0.5, 0.6)
    hSc.ScrollBarImageColor3 = Color3.new(r,g,b)
end)

local hScLayout = Instance.new("UIListLayout"); hScLayout.Padding = UDim.new(0,1); hScLayout.Parent = hSc
local hp = Instance.new("UIPadding")
hp.PaddingTop = UDim.new(0,2); hp.PaddingBottom = UDim.new(0,2)
hp.PaddingLeft = UDim.new(0,2); hp.PaddingRight = UDim.new(0,2); hp.Parent = hSc

hScLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    hSc.CanvasSize = UDim2.new(0, 0, 0, hScLayout.AbsoluteContentSize.Y + 6)
end)

local function rH(d, a)
    local e = Instance.new("Frame"); e.Size = UDim2.new(1,0,0,16)
    e.BackgroundColor3 = d.ok and Color3.fromRGB(0,15,8) or Color3.fromRGB(18,4,6)
    e.BackgroundTransparency = a and 1 or 0.5; e.BorderSizePixel = 0; e.ZIndex = 3
    e.LayoutOrder = -(d.time or 0); e.Parent = hSc; corner(e,3)
    local ic = Instance.new("TextLabel"); ic.Size = UDim2.new(0,12,1,0); ic.Position = UDim2.new(0,2,0,0)
    ic.BackgroundTransparency = 1; ic.Text = d.ok and "+" or "x"
    ic.TextColor3 = d.ok and grn or red; ic.TextSize = 7; ic.Font = Enum.Font.GothamBold; ic.ZIndex = 4; ic.Parent = e
    local mk = string.rep("*", math.max(0, #d.key - 2)) .. string.sub(d.key, math.max(1, #d.key - 1))
    local kl = Instance.new("TextLabel"); kl.Size = UDim2.new(1,-42,1,0); kl.Position = UDim2.new(0,14,0,0)
    kl.BackgroundTransparency = 1; kl.Text = mk; kl.TextColor3 = d.ok and grn or red
    kl.TextSize = 7; kl.Font = Enum.Font.GothamSemibold; kl.TextXAlignment = Enum.TextXAlignment.Left
    kl.ZIndex = 4; kl.Parent = e
    local tl = Instance.new("TextLabel"); tl.Size = UDim2.new(0,24,1,0); tl.Position = UDim2.new(1,-26,0,0)
    tl.BackgroundTransparency = 1; tl.Text = d.timeStr or "??:??"
    tl.TextColor3 = c3; tl.TextSize = 6; tl.Font = Enum.Font.Gotham
    tl.TextXAlignment = Enum.TextXAlignment.Right; tl.ZIndex = 4; tl.Parent = e
    if a then TS:Create(e, TweenInfo.new(0.2), {BackgroundTransparency=0.5}):Play() end
end

if #hist > 0 then
    for _,d in ipairs(hist) do rH(d, false) end
else
    local em = Instance.new("TextLabel"); em.Name = "Empty"; em.Size = UDim2.new(1,0,0,16)
    em.BackgroundTransparency = 1; em.Text = "..."; em.TextColor3 = c3
    em.TextSize = 7; em.Font = Enum.Font.Gotham; em.ZIndex = 3; em.Parent = hSc
end

local function aH(key, ok)
    if hSc:FindFirstChild("Empty") then hSc:FindFirstChild("Empty"):Destroy() end
    local en = {key=key, ok=ok, time=os.time(), timeStr=os.date("%H:%M")}
    table.insert(hist, 1, en)
    if #hist > 50 then table.remove(hist, #hist) end
    sH(); rH(en, true)
    if ok then kLb.Text = "last key"; kLb.TextColor3 = c2 end
end
drag(kf, kf)

-- ===== MAIN HUB =====
local mf = Instance.new("Frame")
mf.Name = "Hub"; mf.Size = UDim2.new(0,270,0,220)
mf.Position = UDim2.new(0.5,-135,0.5,-110)
mf.BackgroundColor3 = bg3; mf.BorderSizePixel = 0; mf.Visible = false; mf.ClipsDescendants = true; mf.Parent = gui
corner(mf,8); glow(mf,0.8); shimmer(mf,0.04,0.05)

local hd = Instance.new("Frame")
hd.Size = UDim2.new(1,0,0,24); hd.Position = UDim2.new(0,0,0,0)
hd.BackgroundColor3 = bg1; hd.BackgroundTransparency = 0.2; hd.BorderSizePixel = 0; hd.ZIndex = 2; hd.Parent = mf
glowLine(hd,23)

local ttl = Instance.new("TextLabel")
ttl.Size = UDim2.new(0,80,0,24); ttl.Position = UDim2.new(0,7,0,0); ttl.BackgroundTransparency = 1
ttl.Text = "Delta Hub"; ttl.TextSize = 10; ttl.Font = Enum.Font.GothamBlack
ttl.TextXAlignment = Enum.TextXAlignment.Left; ttl.ZIndex = 3; ttl.Parent = hd
softText(ttl, "Delta Hub")

local stt = Instance.new("TextLabel")
stt.Size = UDim2.new(0,60,0,24); stt.Position = UDim2.new(0,82,0,0); stt.BackgroundTransparency = 1
stt.Text = ""; stt.TextSize = 7; stt.Font = Enum.Font.GothamBold; stt.TextXAlignment = Enum.TextXAlignment.Left
stt.ZIndex = 3; stt.Parent = hd; stt.RichText = true

onRender("stt_color", function()
    if not stt or not stt.Parent then offRender("stt_color"); return end
    local t = tick(); local h = (t * 0.06 + 0.3) % 1
    local r,g,b = hsv(h, 0.3, 0.5)
    stt.Text = string.format('Rost Alpha', math.floor(r*255), math.floor(g*255), math.floor(b*255))
end)

drag(mf, hd)

local xb = Instance.new("TextButton")
xb.Size = UDim2.new(0,18,0,18); xb.Position = UDim2.new(1,-21,0,3)
xb.BackgroundColor3 = bg2; xb.BackgroundTransparency = 0.5; xb.Text = "X"; xb.TextColor3 = c2
xb.TextSize = 10; xb.Font = Enum.Font.GothamBold; xb.AutoButtonColor = false; xb.ZIndex = 4; xb.Parent = hd; corner(xb,4)

local mmb = Instance.new("TextButton")
mmb.Size = UDim2.new(0,18,0,18); mmb.Position = UDim2.new(1,-42,0,3)
mmb.BackgroundColor3 = bg2; mmb.BackgroundTransparency = 0.5; mmb.Text = "-"; mmb.TextColor3 = c2
mmb.TextSize = 9; mmb.Font = Enum.Font.GothamBold; mmb.AutoButtonColor = false; mmb.ZIndex = 4; mmb.Parent = hd; corner(mmb,4)

for _,b in ipairs({xb, mmb}) do
    b.MouseEnter:Connect(function()
        TS:Create(b, TweenInfo.new(0.08), {BackgroundTransparency=0, BackgroundColor3 = b == xb and red or grn}):Play()
    end)
    b.MouseLeave:Connect(function()
        TS:Create(b, TweenInfo.new(0.08), {BackgroundTransparency=0.5, BackgroundColor3=bg2}):Play()
    end)
end

local sw = Instance.new("Frame")
sw.Size = UDim2.new(1,-6,0,18); sw.Position = UDim2.new(0,3,0,27)
sw.BackgroundColor3 = bg2; sw.BackgroundTransparency = 0.2; sw.BorderSizePixel = 0; sw.ZIndex = 2; sw.Parent = mf
corner(sw,4); glow(sw,0.3)

local sb = Instance.new("TextBox")
sb.Size = UDim2.new(1,-6,1,0); sb.Position = UDim2.new(0,5,0,0); sb.BackgroundTransparency = 1
sb.PlaceholderText = "search..."; sb.PlaceholderColor3 = c3; sb.Text = ""
sb.TextColor3 = c1; sb.TextSize = 8; sb.Font = Enum.Font.Gotham
sb.TextXAlignment = Enum.TextXAlignment.Left; sb.ClearTextOnFocus = false; sb.ZIndex = 3; sb.Parent = sw

local tbar = Instance.new("Frame")
tbar.Size = UDim2.new(1,-6,0,16); tbar.Position = UDim2.new(0,3,0,48)
tbar.BackgroundTransparency = 1; tbar.BorderSizePixel = 0; tbar.ZIndex = 2; tbar.Parent = mf
local tbl = Instance.new("UIListLayout"); tbl.FillDirection = Enum.FillDirection.Horizontal
tbl.Padding = UDim.new(0,2); tbl.HorizontalAlignment = Enum.HorizontalAlignment.Center; tbl.Parent = tbar

local cf = Instance.new("ScrollingFrame")
cf.Size = UDim2.new(1,-6,0,152); cf.Position = UDim2.new(0,3,0,66)
cf.BackgroundColor3 = bg1; cf.BackgroundTransparency = 0.5; cf.BorderSizePixel = 0
cf.ScrollBarThickness = 1; cf.ScrollBarImageTransparency = 0.2
cf.CanvasSize = UDim2.new(0,0,0,0); cf.ZIndex = 2; cf.Parent = mf; corner(cf,6); glow(cf,0.3)
pcall(function() cf.AutomaticCanvasSize = Enum.AutomaticSize.Y end)

onRender("cf_scroll", function()
    if not cf or not cf.Parent then offRender("cf_scroll"); return end
    local h = (tick() * 0.06) % 1
    local r,g,b = hsv(h, 0.5, 0.6)
    cf.ScrollBarImageColor3 = Color3.new(r,g,b)
end)

local cfl = Instance.new("UIListLayout"); cfl.Padding = UDim.new(0,2)
cfl.HorizontalAlignment = Enum.HorizontalAlignment.Center; cfl.Parent = cf
local cfp = Instance.new("UIPadding")
cfp.PaddingTop = UDim.new(0,2); cfp.PaddingBottom = UDim.new(0,2)
cfp.PaddingLeft = UDim.new(0,2); cfp.PaddingRight = UDim.new(0,2); cfp.Parent = cf

cfl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    cf.CanvasSize = UDim2.new(0, 0, 0, cfl.AbsoluteContentSize.Y + 6)
end)

-- ===== SKY =====
local curSky = nil; local cSky = nil
local skyP = {
    {name="Sky 1", id="rbxassetid://6403436082", clk=14, amb=Color3.fromRGB(40,25,55), out=Color3.fromRGB(80,50,110),
     fog=Color3.fromRGB(30,18,45), br=2.5, fe=14000, ac=Color3.fromRGB(180,120,255), desc="furry hero"},
}
local svL = {}; local svS = nil

local function savL()
    svL = {clk=Light.ClockTime, amb=Light.Ambient, out=Light.OutdoorAmbient, fog=Light.FogColor, fe=Light.FogEnd, br=Light.Brightness}
    local es = Light:FindFirstChildOfClass("Sky")
    if es and not cSky then
        svS = {Bk=es.SkyboxBk, Dn=es.SkyboxDn, Ft=es.SkyboxFt, Lf=es.SkyboxLf, Rt=es.SkyboxRt, Up=es.SkyboxUp}
    end
end

local function resL()
    if svL.clk then pcall(function()
        TS:Create(Light, TweenInfo.new(1, Enum.EasingStyle.Sine), {
            ClockTime=svL.clk, Ambient=svL.amb, OutdoorAmbient=svL.out,
            FogColor=svL.fog, FogEnd=svL.fe, Brightness=svL.br
        }):Play()
    end) end
    if cSky then pcall(function() cSky:Destroy() end); cSky = nil end
    if svS then pcall(function()
        local s = Light:FindFirstChildOfClass("Sky")
        if s then
            s.SkyboxBk=svS.Bk; s.SkyboxDn=svS.Dn; s.SkyboxFt=svS.Ft
            s.SkyboxLf=svS.Lf; s.SkyboxRt=svS.Rt; s.SkyboxUp=svS.Up
        end
    end) end
    curSky = nil
end

local function appS(p)
    if not svL.clk then savL() end
    pcall(function()
        TS:Create(Light, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {
            ClockTime=p.clk, Ambient=p.amb, OutdoorAmbient=p.out,
            FogColor=p.fog, FogEnd=p.fe, Brightness=p.br
        }):Play()
    end)
    pcall(function()
        if cSky then cSky:Destroy() end
        local o = Light:FindFirstChildOfClass("Sky"); if o then o:Destroy() end
        local s = Instance.new("Sky")
        s.SkyboxBk=p.id; s.SkyboxDn=p.id; s.SkyboxFt=p.id
        s.SkyboxLf=p.id; s.SkyboxRt=p.id; s.SkyboxUp=p.id
        s.StarCount=0; s.SunAngularSize=0; s.MoonAngularSize=0
        s.Parent = Light; cSky = s
    end)
    curSky = p.name
end

-- ===== ESP =====
local ESP = {On=false, Name=true, HP=true, Dist=true}
local EF = Instance.new("Folder"); EF.Name = "ESP"; EF.Parent = gui
local eC = {}

local function clrE()
    for _,c in ipairs(eC) do pcall(function() c:Disconnect() end) end
    eC = {}; EF:ClearAllChildren()
    offRender("esp_update")
end

local function isVisible(targetChar)
    local ok, result = pcall(function()
        if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then return false end
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return false end
        local origin = Cam.CFrame.Position
        local target = targetChar.HumanoidRootPart.Position
        local dir = (target - origin)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {LP.Character, targetChar}
        local ray = workspace:Raycast(origin, dir, params)
        return ray == nil
    end)
    return ok and result or false
end

local espData = {}

local function bldE()
    clrE()
    if not ESP.On then return end
    espData = {}

    for _,p in ipairs(Plrs:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local ch = p.Character
                local hl = Instance.new("Highlight"); hl.Adornee = ch
                hl.FillTransparency = 0.75; hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = EF
                hl.FillColor = Color3.fromRGB(180,30,30)
                hl.OutlineColor = Color3.fromRGB(220,45,45)

                local bb = Instance.new("BillboardGui"); bb.Adornee = ch.HumanoidRootPart
                bb.Size = UDim2.new(0,80,0,32)
                bb.StudsOffset = Vector3.new(0,2.5,0); bb.AlwaysOnTop = true; bb.Parent = EF
                local yo = 0; local nL, dL, hpF

                if ESP.Name then
                    nL = Instance.new("TextLabel"); nL.Size = UDim2.new(1,0,0,10)
                    nL.Position = UDim2.new(0,0,0,yo); nL.BackgroundTransparency = 1
                    nL.Text = p.DisplayName; nL.TextSize = 9; nL.Font = Enum.Font.GothamBold
                    nL.TextStrokeTransparency = 0.2; nL.TextStrokeColor3 = Color3.new(0,0,0)
                    nL.TextColor3 = red; nL.Parent = bb; yo = yo + 10
                end

                if ESP.Dist then
                    dL = Instance.new("TextLabel"); dL.Size = UDim2.new(1,0,0,8)
                    dL.Position = UDim2.new(0,0,0,yo); dL.BackgroundTransparency = 1
                    dL.TextColor3 = c2; dL.TextSize = 7; dL.Font = Enum.Font.Gotham
                    dL.TextStrokeTransparency = 0.3; dL.TextStrokeColor3 = Color3.new(0,0,0)
                    dL.Parent = bb; yo = yo + 9
                end

                if ESP.HP then
                    local hpB = Instance.new("Frame"); hpB.Size = UDim2.new(0.5,0,0,2)
                    hpB.Position = UDim2.new(0.25,0,0,yo+1)
                    hpB.BackgroundColor3 = Color3.fromRGB(20,20,20); hpB.BorderSizePixel = 0
                    hpB.Parent = bb; corner(hpB,3)
                    hpF = Instance.new("Frame"); hpF.Size = UDim2.new(1,0,1,0)
                    hpF.BackgroundColor3 = grn; hpF.BorderSizePixel = 0; hpF.Parent = hpB; corner(hpF,3)
                end

                espData[#espData+1] = {p=p, hl=hl, nL=nL, dL=dL, hpF=hpF}
            end)
        end
    end

    onRender("esp_update", function()
        if not ESP.On then return end
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
        for _,d in ipairs(espData) do
            pcall(function()
                if not d.p.Character or not d.p.Character:FindFirstChild("HumanoidRootPart") then return end
                local vis = isVisible(d.p.Character)
                if vis then
                    d.hl.FillColor = Color3.fromRGB(0,160,80)
                    d.hl.OutlineColor = Color3.fromRGB(0,210,100)
                    if d.nL then d.nL.TextColor3 = grn end
                else
                    d.hl.FillColor = Color3.fromRGB(180,30,30)
                    d.hl.OutlineColor = Color3.fromRGB(220,45,45)
                    if d.nL then d.nL.TextColor3 = red end
                end
                if d.dL then
                    d.dL.Text = string.format("[%dm]", math.floor(
                        (LP.Character.HumanoidRootPart.Position - d.p.Character.HumanoidRootPart.Position).Magnitude
                    ))
                end
                if d.hpF then
                    local hm = d.p.Character:FindFirstChildOfClass("Humanoid")
                    if hm then
                        local r = math.clamp(hm.Health / hm.MaxHealth, 0, 1)
                        d.hpF.Size = UDim2.new(r, 0, 1, 0)
                        d.hpF.BackgroundColor3 = r > 0.5 and grn or r > 0.25 and ylw or red
                    end
                end
            end)
        end
    end)

    local function onChar()
        if ESP.On then swait(0.5); bldE() end
    end
    table.insert(eC, Plrs.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(onChar) end))
    for _,p in ipairs(Plrs:GetPlayers()) do
        if p ~= LP then table.insert(eC, p.CharacterAdded:Connect(onChar)) end
    end
end

-- ===== AIMLOCK =====
local AimLock = {
    On = false,
    TargetPart = "Head",
    FOV = 200,
    Smoothness = 8,
    ShowFOV = true,
    Locked = nil,
}

local fovFrame = Instance.new("Frame")
fovFrame.Name = "AimFOV"
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.BackgroundTransparency = 1
fovFrame.BorderSizePixel = 0
fovFrame.Size = UDim2.new(0, AimLock.FOV * 2, 0, AimLock.FOV * 2)
fovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
fovFrame.Visible = false; fovFrame.ZIndex = 50; fovFrame.Parent = gui

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(255,255,255)
fovStroke.Thickness = 1; fovStroke.Transparency = 0.6; fovStroke.Parent = fovFrame

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0); fovCorner.Parent = fovFrame

onRender("fov_circle", function()
    if not fovFrame or not fovFrame.Parent then offRender("fov_circle"); return end
    if AimLock.On and AimLock.ShowFOV then
        fovFrame.Visible = true
        fovFrame.Size = UDim2.new(0, AimLock.FOV * 2, 0, AimLock.FOV * 2)
        local t = tick(); local h = (t * 0.08) % 1
        local r,g,b = hsv(h, 0.5, 0.7)
        fovStroke.Color = Color3.new(r,g,b)
        fovStroke.Transparency = AimLock.Locked and 0.2 or 0.6
    else
        fovFrame.Visible = false
    end
end)

local function getClosestInFOV()
    local closest = nil
    local closestDist = AimLock.FOV
    local screenCenter = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    for _,p in ipairs(Plrs:GetPlayers()) do
        if p ~= LP and p.Character then
            local ch = p.Character
            local part = ch:FindFirstChild(AimLock.TargetPart) or ch:FindFirstChild("HumanoidRootPart")
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health > 0 then
                local ok, screenPos, onScreen = pcall(function()
                    return Cam:WorldToViewportPoint(part.Position)
                end)
                if ok and onScreen then
                    local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if dist2D < closestDist then
                        closestDist = dist2D; closest = p
                    end
                end
            end
        end
    end
    return closest
end

onRender("aimlock_main", function()
    if not AimLock.On then AimLock.Locked = nil; return end
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then AimLock.Locked = nil; return end

    local target = getClosestInFOV()
    AimLock.Locked = target

    if target and target.Character then
        local part = target.Character:FindFirstChild(AimLock.TargetPart)
            or target.Character:FindFirstChild("HumanoidRootPart")
        local hum = target.Character:FindFirstChildOfClass("Humanoid")
        if part and hum and hum.Health > 0 then
            local targetPos = part.Position
            local camPos = Cam.CFrame.Position
            local dir = (targetPos - camPos).Unit
            local goalCF = CFrame.lookAt(camPos, camPos + dir)
            local alpha = math.clamp(1 / math.max(AimLock.Smoothness, 1), 0.05, 1)
            Cam.CFrame = Cam.CFrame:Lerp(goalCF, alpha)
        end
    end
end)

onRender("aimlock_death", function()
    if AimLock.Locked then
        local p = AimLock.Locked
        if not p.Character or not p.Character:FindFirstChildOfClass("Humanoid")
            or p.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
            AimLock.Locked = nil
        end
    end
end)

-- ===== SNIPELINES =====
local Snipelines = {On = false}

local SNIPE_RADIUS = 48
local SNIPE_MAX_ARROWS = 30
local snipeArrows = {}
local snipeConns = {}

local function mkArrow()
    local af = Instance.new("Frame")
    af.Size = UDim2.new(0, 30, 0, 30)
    af.BackgroundTransparency = 1; af.BorderSizePixel = 0
    af.AnchorPoint = Vector2.new(0.5, 0.5); af.Visible = false; af.ZIndex = 40; af.Parent = gui

    local ring = Instance.new("Frame"); ring.Name = "R"
    ring.Size = UDim2.new(0, 14, 0, 14)
    ring.Position = UDim2.new(0.5, 0, 0.5, 0); ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.BackgroundColor3 = Color3.fromRGB(0,0,0); ring.BackgroundTransparency = 0.35
    ring.BorderSizePixel = 0; ring.ZIndex = 41; ring.Parent = af; corner(ring, 7)
    local rs = Instance.new("UIStroke"); rs.Thickness = 1.5; rs.Transparency = 0.1
    rs.Color = Color3.new(1,1,1); rs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; rs.Parent = ring

    -- inner glow dot
    local innerGlow = Instance.new("Frame"); innerGlow.Name = "IG"
    innerGlow.Size = UDim2.new(0, 4, 0, 4)
    innerGlow.Position = UDim2.new(0.5, 0, 0.5, 0); innerGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    innerGlow.BackgroundColor3 = Color3.new(1,1,1); innerGlow.BackgroundTransparency = 0.3
    innerGlow.BorderSizePixel = 0; innerGlow.ZIndex = 42; innerGlow.Parent = ring; corner(innerGlow, 2)

    local ico = Instance.new("TextLabel"); ico.Name = "I"
    ico.Size = UDim2.new(0, 14, 0, 14)
    ico.Position = UDim2.new(0.5, 0, 0.5, 0); ico.AnchorPoint = Vector2.new(0.5, 0.5)
    ico.BackgroundTransparency = 1; ico.Text = "◆"; ico.TextSize = 8
    ico.Font = Enum.Font.GothamBlack; ico.TextColor3 = Color3.new(1,1,1)
    ico.TextStrokeTransparency = 0.1; ico.TextStrokeColor3 = Color3.new(0,0,0)
    ico.ZIndex = 43; ico.Parent = af

    local nm = Instance.new("TextLabel"); nm.Name = "N"
    nm.Size = UDim2.new(0, 50, 0, 7); nm.Position = UDim2.new(0.5, 0, 0, 2)
    nm.AnchorPoint = Vector2.new(0.5, 1); nm.BackgroundTransparency = 1
    nm.Text = ""; nm.TextSize = 5; nm.Font = Enum.Font.GothamBold
    nm.TextColor3 = Color3.new(1,1,1); nm.TextStrokeTransparency = 0.1
    nm.TextStrokeColor3 = Color3.new(0,0,0); nm.ZIndex = 43; nm.Rotation = 0; nm.Parent = af

    local dl = Instance.new("TextLabel"); dl.Name = "D"
    dl.Size = UDim2.new(0, 30, 0, 7); dl.Position = UDim2.new(0.5, 0, 1, -2)
    dl.AnchorPoint = Vector2.new(0.5, 0); dl.BackgroundTransparency = 1
    dl.Text = ""; dl.TextSize = 5; dl.Font = Enum.Font.GothamBold
    dl.TextColor3 = Color3.new(1,1,1); dl.TextStrokeTransparency = 0.1
    dl.TextStrokeColor3 = Color3.new(0,0,0); dl.ZIndex = 43; dl.Rotation = 0; dl.Parent = af

    return {frame=af, arrow=ico, distLabel=dl, nameLabel=nm, ring=ring, ringStroke=rs, innerGlow=innerGlow}
end

for i = 1, SNIPE_MAX_ARROWS do snipeArrows[i] = mkArrow() end

local snipeBlinkPhase = 0

local function bindSnipePlayer(p)
    if p == LP then return end
    table.insert(snipeConns, p.CharacterAdded:Connect(function() end))
    table.insert(snipeConns, p.CharacterRemoving:Connect(function() end))
end
table.insert(snipeConns, Plrs.PlayerAdded:Connect(function(p) bindSnipePlayer(p) end))
table.insert(snipeConns, Plrs.PlayerRemoving:Connect(function() end))
for _, p in ipairs(Plrs:GetPlayers()) do bindSnipePlayer(p) end

onRender("snipelines_update", function()
    if not Snipelines.On then
        for i = 1, SNIPE_MAX_ARROWS do snipeArrows[i].frame.Visible = false end
        return
    end
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then
        for i = 1, SNIPE_MAX_ARROWS do snipeArrows[i].frame.Visible = false end
        return
    end

    local vpX = Cam.ViewportSize.X
    local vpY = Cam.ViewportSize.Y
    local centerX = vpX * 0.5
    local centerY = vpY - SNIPE_RADIUS - 18

    local myPos = LP.Character.HumanoidRootPart.Position
    local camCF = Cam.CFrame
    local lookFlat = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
    if lookFlat.Magnitude < 0.01 then lookFlat = Vector3.new(0, 0, -1) end
    lookFlat = lookFlat.Unit
    local rightFlat = Vector3.new(-lookFlat.Z, 0, lookFlat.X)

    snipeBlinkPhase = snipeBlinkPhase + 1
    local blinkOn = (snipeBlinkPhase % 12) < 7

    local arrowIdx = 0

    for _, p in ipairs(Plrs:GetPlayers()) do
        if p ~= LP then
            local hasChar = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            local hum = hasChar and p.Character:FindFirstChildOfClass("Humanoid")
            local alive = hum and hum.Health > 0

            if hasChar and alive then
                local theirPos = p.Character.HumanoidRootPart.Position
                local dist = (theirPos - myPos).Magnitude

                arrowIdx = arrowIdx + 1
                if arrowIdx > SNIPE_MAX_ARROWS then break end

                local data = snipeArrows[arrowIdx]
                data.frame.Visible = true

                local dirToTarget = Vector3.new(theirPos.X - myPos.X, 0, theirPos.Z - myPos.Z)
                if dirToTarget.Magnitude > 0.01 then dirToTarget = dirToTarget.Unit end

                local fDot = lookFlat:Dot(dirToTarget)
                local rDot = rightFlat:Dot(dirToTarget)
                local angle = math.atan2(rDot, fDot)

                local px = centerX + math.sin(angle) * SNIPE_RADIUS
                local py = centerY - math.cos(angle) * SNIPE_RADIUS
                data.frame.Position = UDim2.new(0, px, 0, py)

                data.arrow.Rotation = math.deg(angle) + 180
                data.nameLabel.Rotation = 0
                data.distLabel.Rotation = 0
                data.arrow.Text = "◆"

                data.distLabel.Text = math.floor(dist) .. "m"
                data.nameLabel.Text = p.DisplayName

                local arrowColor
                local arrowVisible = true
                if dist >= 680 and dist <= 1000 then
                    arrowColor = Color3.fromRGB(0, 230, 100)
                elseif dist >= 400 and dist < 680 then
                    arrowColor = Color3.fromRGB(255, 175, 20)
                elseif dist >= 300 and dist < 400 then
                    arrowColor = Color3.fromRGB(230, 50, 60)
                elseif dist >= 1 and dist < 300 then
                    arrowColor = Color3.fromRGB(255, 25, 25)
                    arrowVisible = blinkOn
                else
                    arrowColor = Color3.fromRGB(140, 140, 160)
                end

                data.arrow.TextColor3 = arrowColor
                data.arrow.TextTransparency = arrowVisible and 0 or 0.75
                data.ringStroke.Color = arrowColor
                data.ringStroke.Thickness = math.clamp(1.5 * sc, 0.8, 2)
                data.ringStroke.Transparency = arrowVisible and 0.05 or 0.7
                data.ring.BackgroundTransparency = arrowVisible and 0.3 or 0.8
                data.nameLabel.TextColor3 = arrowColor
                data.nameLabel.TextTransparency = arrowVisible and 0 or 0.75
                data.distLabel.TextColor3 = arrowColor
                data.distLabel.TextTransparency = arrowVisible and 0 or 0.75

                local sc = math.clamp(1.3 - (dist / 1200), 0.65, 1.3)
                data.arrow.TextSize = math.floor(8 * sc)
                local rs = math.floor(14 * sc)
                data.ring.Size = UDim2.new(0, rs, 0, rs)
                corner(data.ring, math.floor(rs / 2))
                -- inner glow pulse
                if data.innerGlow then
                    local igA = math.sin(tick() * 4 + arrowIdx) * 0.2 + 0.35
                    data.innerGlow.BackgroundTransparency = arrowVisible and igA or 0.85
                    data.innerGlow.BackgroundColor3 = arrowColor
                    local igs = math.floor(4 * sc)
                    data.innerGlow.Size = UDim2.new(0, igs, 0, igs)
                    corner(data.innerGlow, math.floor(igs / 2))
                end
            end
        end
    end

    for i = arrowIdx + 1, SNIPE_MAX_ARROWS do
        snipeArrows[i].frame.Visible = false
    end
end)

local function clrSnipe()
    Snipelines.On = false
    for i = 1, SNIPE_MAX_ARROWS do snipeArrows[i].frame.Visible = false end
end

-- ===== UI BUILDERS =====
local tBs = {}; local cTab = nil
local function clC()
    for _,ch in ipairs(cf:GetChildren()) do
        if not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then ch:Destroy() end
    end
end

local function mkT(name, par, state, cb)
    local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,18)
    f.BackgroundColor3 = Color3.fromRGB(11,11,20); f.BorderSizePixel = 0; f.ZIndex = 4; f.Parent = par
    corner(f,4); glow(f,0.25)
    local lb = Instance.new("TextLabel"); lb.Size = UDim2.new(1,-34,1,0); lb.Position = UDim2.new(0,5,0,0)
    lb.BackgroundTransparency = 1; lb.Text = name; lb.TextColor3 = c1; lb.TextSize = 8
    lb.Font = Enum.Font.GothamSemibold; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.ZIndex = 5; lb.Parent = f
    local tbg = Instance.new("Frame"); tbg.Size = UDim2.new(0,24,0,12); tbg.Position = UDim2.new(1,-29,0.5,-6)
    tbg.BackgroundColor3 = state and Color3.new(1,1,1) or Color3.fromRGB(8,8,14)
    tbg.BorderSizePixel = 0; tbg.ZIndex = 5; tbg.Parent = f; corner(tbg,6)
    local tbgStroke = Instance.new("UIStroke")
    tbgStroke.Thickness = 1.2; tbgStroke.Color = Color3.new(1,1,1)
    tbgStroke.Transparency = state and 0 or 0.55
    tbgStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; tbgStroke.Parent = tbg
    local dot = Instance.new("Frame"); dot.Size = UDim2.new(0,8,0,8)
    dot.Position = state and UDim2.new(0,14,0.5,-4) or UDim2.new(0,2,0.5,-4)
    dot.BackgroundColor3 = state and Color3.fromRGB(8,8,14) or Color3.fromRGB(60,60,80)
    dot.BorderSizePixel = 0; dot.ZIndex = 6; dot.Parent = tbg; corner(dot,4)
    local en = state
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 7; btn.Parent = f
    btn.MouseButton1Click:Connect(function()
        en = not en; local r = cb(en); if r ~= nil then en = r end
        if en then
            TS:Create(tbg, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundColor3=Color3.new(1,1,1)}):Play()
            TS:Create(tbgStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Transparency=0}):Play()
            TS:Create(dot, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Position=UDim2.new(0,14,0.5,-4), BackgroundColor3=Color3.fromRGB(8,8,14)}):Play()
        else
            TS:Create(tbg, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundColor3=Color3.fromRGB(8,8,14)}):Play()
            TS:Create(tbgStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Transparency=0.55}):Play()
            TS:Create(dot, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {Position=UDim2.new(0,2,0.5,-4), BackgroundColor3=Color3.fromRGB(60,60,80)}):Play()
        end
    end)
end

local function mkSlider(name, par, min, max, default, cb)
    local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,28)
    f.BackgroundColor3 = Color3.fromRGB(11,11,20); f.BorderSizePixel = 0; f.ZIndex = 4; f.Parent = par
    corner(f,4); glow(f,0.25)
    local lb = Instance.new("TextLabel"); lb.Size = UDim2.new(1,-50,0,12); lb.Position = UDim2.new(0,5,0,1)
    lb.BackgroundTransparency = 1; lb.Text = name; lb.TextColor3 = c1; lb.TextSize = 7
    lb.Font = Enum.Font.GothamSemibold; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.ZIndex = 5; lb.Parent = f
    local vl = Instance.new("TextLabel"); vl.Size = UDim2.new(0,40,0,12); vl.Position = UDim2.new(1,-45,0,1)
    vl.BackgroundTransparency = 1; vl.Text = tostring(default); vl.TextColor3 = c2; vl.TextSize = 7
    vl.Font = Enum.Font.GothamBold; vl.TextXAlignment = Enum.TextXAlignment.Right; vl.ZIndex = 5; vl.Parent = f
    local track = Instance.new("Frame"); track.Size = UDim2.new(1,-12,0,4); track.Position = UDim2.new(0,6,0,17)
    track.BackgroundColor3 = Color3.fromRGB(20,20,35); track.BorderSizePixel = 0; track.ZIndex = 5; track.Parent = f; corner(track,2)
    local fill = Instance.new("Frame"); fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(80,80,180); fill.BorderSizePixel = 0; fill.ZIndex = 6; fill.Parent = track; corner(fill,2)
    shimmer(fill, 0.08, 0.35)
    local knob = Instance.new("Frame"); knob.Size = UDim2.new(0,8,0,8)
    knob.AnchorPoint = Vector2.new(0.5,0.5); knob.Position = UDim2.new((default-min)/(max-min),0,0.5,0)
    knob.BackgroundColor3 = Color3.new(1,1,1); knob.BorderSizePixel = 0; knob.ZIndex = 7; knob.Parent = track; corner(knob,4)
    local dragging = false
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1,0,0,16); btn.Position = UDim2.new(0,0,0,14)
    btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 8; btn.Parent = f
    local function update(input)
        local absX = track.AbsolutePosition.X
        local absW = track.AbsoluteSize.X
        if absW <= 0 then return end
        local rel = math.clamp((input.Position.X - absX) / absW, 0, 1)
        local val = math.floor(min + (max - min) * rel)
        vl.Text = tostring(val); fill.Size = UDim2.new(rel,0,1,0)
        knob.Position = UDim2.new(rel,0,0.5,0); cb(val)
    end
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; update(i)
        end
    end)
    btn.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            update(i)
        end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local function mkPartSwitch(par)
    local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,18)
    f.BackgroundColor3 = Color3.fromRGB(11,11,20); f.BorderSizePixel = 0; f.ZIndex = 4; f.Parent = par
    corner(f,4); glow(f,0.25)
    local lb = Instance.new("TextLabel"); lb.Size = UDim2.new(0.5,0,1,0); lb.Position = UDim2.new(0,5,0,0)
    lb.BackgroundTransparency = 1; lb.Text = "target part"; lb.TextColor3 = c1; lb.TextSize = 8
    lb.Font = Enum.Font.GothamSemibold; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.ZIndex = 5; lb.Parent = f
    local pLbl = Instance.new("TextLabel"); pLbl.Size = UDim2.new(0,60,0,12); pLbl.Position = UDim2.new(1,-65,0.5,-6)
    pLbl.BackgroundColor3 = Color3.fromRGB(20,20,40); pLbl.BorderSizePixel = 0
    pLbl.Text = AimLock.TargetPart; pLbl.TextColor3 = c1; pLbl.TextSize = 7
    pLbl.Font = Enum.Font.GothamBold; pLbl.ZIndex = 6; pLbl.Parent = f; corner(pLbl,3)
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 7; btn.Parent = f
    btn.MouseButton1Click:Connect(function()
        AimLock.TargetPart = AimLock.TargetPart == "Head" and "HumanoidRootPart" or "Head"
        pLbl.Text = AimLock.TargetPart
    end)
end

local skRefs = {}

local function mkSk(p, par)
    local c = Instance.new("Frame"); c.Size = UDim2.new(1,0,0,28)
    c.BackgroundColor3 = Color3.fromRGB(11,11,20); c.BorderSizePixel = 0; c.ZIndex = 4; c.Parent = par
    corner(c,5); glow(c,0.25)
    local bar = Instance.new("Frame"); bar.Size = UDim2.new(0,2,0,18); bar.Position = UDim2.new(0,2,0.5,-9)
    bar.BackgroundColor3 = p.ac; bar.BorderSizePixel = 0; bar.ZIndex = 6; bar.Parent = c; corner(bar,1)
    local ib = Instance.new("Frame"); ib.Size = UDim2.new(0,20,0,20); ib.Position = UDim2.new(0,6,0.5,-10)
    ib.BackgroundColor3 = bg1; ib.BorderSizePixel = 0; ib.ZIndex = 5; ib.Parent = c; corner(ib,5)
    local pv = Instance.new("ImageLabel"); pv.Size = UDim2.new(1,0,1,0); pv.BackgroundTransparency = 1
    pv.Image = p.id; pv.ScaleType = Enum.ScaleType.Crop; pv.ZIndex = 6; pv.Parent = ib; corner(pv,5)
    local nm = Instance.new("TextLabel"); nm.Size = UDim2.new(1,-56,0,10); nm.Position = UDim2.new(0,30,0,3)
    nm.BackgroundTransparency = 1; nm.Text = p.name; nm.TextColor3 = c1; nm.TextSize = 8
    nm.Font = Enum.Font.GothamBold; nm.TextXAlignment = Enum.TextXAlignment.Left; nm.ZIndex = 5; nm.Parent = c
    local dc = Instance.new("TextLabel"); dc.Size = UDim2.new(1,-56,0,8); dc.Position = UDim2.new(0,30,0,14)
    dc.BackgroundTransparency = 1; dc.TextColor3 = c3; dc.TextSize = 6; dc.Font = Enum.Font.Gotham
    dc.TextXAlignment = Enum.TextXAlignment.Left; dc.ZIndex = 5; dc.Parent = c; dc.Text = p.desc
    local sl = Instance.new("TextLabel"); sl.Name = "S"; sl.Size = UDim2.new(0,20,0,10)
    sl.Position = UDim2.new(1,-24,0.5,-5); sl.BackgroundColor3 = bg1; sl.BorderSizePixel = 0
    sl.ZIndex = 6; sl.Parent = c; corner(sl,3)
    sl.Text = "off"; sl.TextColor3 = c3; sl.TextSize = 6; sl.Font = Enum.Font.GothamBold
    table.insert(skRefs, {c=c, s=sl, p=p})
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 7; btn.Parent = c
    btn.MouseButton1Click:Connect(function()
        if curSky == p.name then
            resL(); sl.Text = "off"; sl.TextColor3 = c3
            for _,ch in ipairs(c:GetChildren()) do if ch:IsA("UIGradient") then ch:Destroy() end end
            c.BackgroundColor3 = Color3.fromRGB(11,11,20)
        else
            appS(p); sl.Text = "on"; sl.TextColor3 = grn
            for _,ch in ipairs(c:GetChildren()) do if ch:IsA("UIGradient") then ch:Destroy() end end
            shimmer(c, 0.06, 0.12)
            for _,ref in ipairs(skRefs) do
                if ref.c ~= c then
                    ref.s.Text = "off"; ref.s.TextColor3 = c3
                    for _,g in ipairs(ref.c:GetChildren()) do if g:IsA("UIGradient") then g:Destroy() end end
                    ref.c.BackgroundColor3 = Color3.fromRGB(11,11,20)
                end
            end
        end
    end)
end

local function mkG(title, par)
    local c = Instance.new("Frame"); c.Size = UDim2.new(1,0,0,10)
    c.BackgroundColor3 = Color3.fromRGB(8,8,14); c.BackgroundTransparency = 0.25
    c.BorderSizePixel = 0; c.ZIndex = 3; c.Parent = par; corner(c,6)
    c.AutomaticSize = Enum.AutomaticSize.Y; c.ClipsDescendants = false; glow(c,0.2)
    local ip = Instance.new("UIPadding"); ip.PaddingTop = UDim.new(0,2); ip.PaddingBottom = UDim.new(0,3)
    ip.PaddingLeft = UDim.new(0,2); ip.PaddingRight = UDim.new(0,2); ip.Parent = c
    local il = Instance.new("UIListLayout"); il.Padding = UDim.new(0,2)
    il.HorizontalAlignment = Enum.HorizontalAlignment.Center; il.Parent = c
    local hdr = Instance.new("TextLabel"); hdr.Size = UDim2.new(1,0,0,11); hdr.BackgroundTransparency = 1
    hdr.Text = title; hdr.TextColor3 = c2; hdr.TextSize = 8; hdr.Font = Enum.Font.GothamBlack
    hdr.TextXAlignment = Enum.TextXAlignment.Left; hdr.ZIndex = 4; hdr.Parent = c
    local sep = Instance.new("Frame"); sep.Size = UDim2.new(0.94,0,0,1); sep.BackgroundColor3 = c3
    sep.BackgroundTransparency = 0.6; sep.BorderSizePixel = 0; sep.ZIndex = 4; sep.Parent = c
    return c
end

local function mkI(t, p)
    local l = Instance.new("TextLabel"); l.Size = UDim2.new(1,0,0,11); l.BackgroundTransparency = 1
    l.Text = " " .. t; l.TextColor3 = c3; l.TextSize = 7; l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 4; l.Parent = p
end

local tabs = {
    {ico="~", nm="Combat", ld=function()
        clC(); skRefs = {}
        local ag = mkG("AIMLOCK", cf)
        mkT("enabled", ag, AimLock.On, function(v) AimLock.On = v; return v end)
        mkT("show FOV circle", ag, AimLock.ShowFOV, function(v) AimLock.ShowFOV = v; return v end)
        mkPartSwitch(ag)
        mkSlider("FOV radius", ag, 50, 600, AimLock.FOV, function(v) AimLock.FOV = v end)
        mkSlider("smoothness", ag, 1, 20, AimLock.Smoothness, function(v) AimLock.Smoothness = v end)
    end},
    {ico="o", nm="Visual", ld=function()
        clC(); skRefs = {}
        local eg = mkG("ESP", cf)
        mkT("enabled", eg, ESP.On, function(v) ESP.On = v; bldE(); return v end)
        mkT("names", eg, ESP.Name, function(v) ESP.Name = v; if ESP.On then bldE() end; return v end)
        mkT("health", eg, ESP.HP, function(v) ESP.HP = v; if ESP.On then bldE() end; return v end)
        mkT("distance", eg, ESP.Dist, function(v) ESP.Dist = v; if ESP.On then bldE() end; return v end)

        local slg = mkG("SNIPELINES", cf)
        mkT("enabled", slg, Snipelines.On, function(v) Snipelines.On = v; if not v then clrSnipe() end; return v end)
        mkI("680-1000m = green", slg)
        mkI("400-680m = orange", slg)
        mkI("300-400m = red", slg)
        mkI("1-300m = red blink", slg)

        local sg = mkG("SKY", cf)
        for _,p in ipairs(skyP) do mkSk(p, sg) end
        local rc = Instance.new("Frame"); rc.Size = UDim2.new(1,0,0,18)
        rc.BackgroundColor3 = Color3.fromRGB(11,11,20); rc.BorderSizePixel = 0; rc.ZIndex = 5; rc.Parent = sg
        corner(rc,4); glow(rc,0.25)
        local rl = Instance.new("TextLabel"); rl.Size = UDim2.new(1,0,1,0); rl.BackgroundTransparency = 1
        rl.Text = "reset"; rl.TextColor3 = c1; rl.TextSize = 7; rl.Font = Enum.Font.GothamBold; rl.ZIndex = 6; rl.Parent = rc
        local rb = Instance.new("TextButton"); rb.Size = UDim2.new(1,0,1,0)
        rb.BackgroundTransparency = 1; rb.Text = ""; rb.ZIndex = 7; rb.Parent = rc
        rb.MouseButton1Click:Connect(function()
            resL()
            for _,ref in ipairs(skRefs) do
                ref.s.Text = "off"; ref.s.TextColor3 = c3
                for _,g in ipairs(ref.c:GetChildren()) do if g:IsA("UIGradient") then g:Destroy() end end
                ref.c.BackgroundColor3 = Color3.fromRGB(11,11,20)
            end
        end)
    end},
    {ico="!", nm="Move", ld=function() clC(); local g = mkG("MOVEMENT", cf); mkI("coming soon...", g) end},
    {ico="*", nm="Misc", ld=function() clC(); local g = mkG("MISC", cf); mkI("coming soon...", g) end},
}

local function sT(i)
    if cTab == i then return end; cTab = i
    for j,b in ipairs(tBs) do
        if j == i then
            for _,ch in ipairs(b:GetChildren()) do if ch:IsA("UIGradient") then ch:Destroy() end end
            shimmer(b, 0.08, 0.2); b.TextColor3 = c1
        else
            for _,ch in ipairs(b:GetChildren()) do if ch:IsA("UIGradient") then ch:Destroy() end end
            b.BackgroundColor3 = bg2; b.BackgroundTransparency = 0; b.TextColor3 = c2
        end
    end
    tabs[i].ld()
end

for i,td in ipairs(tabs) do
    local tb = Instance.new("TextButton"); tb.Size = UDim2.new(0,62,0,14)
    tb.BackgroundColor3 = bg2; tb.BorderSizePixel = 0
    tb.Text = td.ico .. " " .. td.nm; tb.TextColor3 = c2; tb.TextSize = 7; tb.Font = Enum.Font.GothamBold
    tb.AutoButtonColor = false; tb.ZIndex = 3; tb.Parent = tbar; corner(tb,4)
    tb.MouseEnter:Connect(function()
        if cTab ~= i then TS:Create(tb, TweenInfo.new(0.06), {BackgroundColor3=Color3.fromRGB(20,20,35)}):Play() end
    end)
    tb.MouseLeave:Connect(function()
        if cTab ~= i then TS:Create(tb, TweenInfo.new(0.06), {BackgroundColor3=bg2}):Play() end
    end)
    tb.MouseButton1Click:Connect(function() sT(i) end)
    table.insert(tBs, tb)
end

sb.FocusLost:Connect(function(e)
    if e and sb.Text ~= "" then
        local r = aSearch(sb.Text)
        if r == "ESP" or r == "Sky" or r == "Snipelines" then sT(2); sb.Text = ""
        elseif r == "Aimbot" then sT(1); sb.Text = ""
        else
            sb.Text = ""; sb.PlaceholderText = "not found"; sb.PlaceholderColor3 = red
            sdelay(1, function() sb.PlaceholderText = "search..."; sb.PlaceholderColor3 = c3 end)
        end
    end
end)

local function openH()
    TS:Create(kf, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency=1}):Play()
    for _,d in ipairs(kf:GetDescendants()) do pcall(function()
        if d:IsA("GuiObject") then TS:Create(d, TweenInfo.new(0.2), {BackgroundTransparency=1}):Play() end
        if d:IsA("TextLabel") or d:IsA("TextBox") or d:IsA("TextButton") then
            TS:Create(d, TweenInfo.new(0.2), {TextTransparency=1}):Play()
        end
        if d:IsA("UIStroke") then TS:Create(d, TweenInfo.new(0.2), {Transparency=1}):Play() end
        if d:IsA("ImageLabel") then TS:Create(d, TweenInfo.new(0.2), {ImageTransparency=1}):Play() end
    end) end
    swait(0.3); kf.Visible = false; mf.Visible = true; mf.BackgroundTransparency = 1
    TS:Create(mf, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency=0}):Play()
    for _,d in ipairs(mf:GetDescendants()) do pcall(function()
        if d:IsA("Frame") and d.BackgroundTransparency < 1 then
            local tg = d.BackgroundTransparency; d.BackgroundTransparency = 1
            TS:Create(d, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundTransparency=tg}):Play()
        end
    end) end
    sT(1)
end

local function vfy()
    local k = kIn.Text
    if k == "" then
        kSt.Text = "enter key"; kSt.TextColor3 = red
        sdelay(1.5, function() kSt.Text = "" end); return
    end
    local ok = decryptKey(k); aH(k, ok)
    if ok then
        kSt.Text = "granted"; kSt.TextColor3 = grn
        for _,ch in ipairs(kVb:GetChildren()) do if ch:IsA("UIGradient") then ch:Destroy() end end
        TS:Create(kVb, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.new(1,1,1)}):Play()
        TS:Create(kVb, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {TextColor3 = Color3.fromRGB(5,5,10)}):Play()
        local vGlow = Instance.new("UIStroke"); vGlow.Thickness = 2; vGlow.Transparency = 0
        vGlow.Color = Color3.new(1,1,1); vGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; vGlow.Parent = kVb
        swait(0.15)
        openH()
    else
        kSt.Text = "invalid"; kSt.TextColor3 = red; kIn.Text = ""
        local o = kf.Position
        for i = 1, 3 do
            TS:Create(kf, TweenInfo.new(0.02), {Position=UDim2.new(o.X.Scale, o.X.Offset + (i%2==0 and 4 or -4), o.Y.Scale, o.Y.Offset)}):Play()
            swait(0.02)
        end
        TS:Create(kf, TweenInfo.new(0.025), {Position=o}):Play()
        sdelay(1.5, function() kSt.Text = "" end)
    end
end

kVb.MouseButton1Click:Connect(vfy)
kVb.TouchTap:Connect(vfy)
kIn.FocusLost:Connect(function(e) if e then vfy() end end)
kLb.MouseButton1Click:Connect(function() local l = glk(); if l then kIn.Text = l; vfy() end end)
kLb.TouchTap:Connect(function() local l = glk(); if l then kIn.Text = l; vfy() end end)

local isM = false
xb.MouseButton1Click:Connect(function()
    AimLock.On = false; AimLock.Locked = nil
    Snipelines.On = false; clrSnipe()
    TS:Create(mf, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundTransparency=1, Size=UDim2.new(0,270,0,0)}):Play()
    for _,d in ipairs(mf:GetDescendants()) do pcall(function()
        if d:IsA("GuiObject") then TS:Create(d, TweenInfo.new(0.12), {BackgroundTransparency=1}):Play() end
        if d:IsA("TextLabel") or d:IsA("TextBox") or d:IsA("TextButton") then
            TS:Create(d, TweenInfo.new(0.12), {TextTransparency=1}):Play()
        end
        if d:IsA("ImageLabel") then TS:Create(d, TweenInfo.new(0.12), {ImageTransparency=1}):Play() end
    end) end
    swait(0.2)
    clrE(); ESP.On = false; resL(); clrSnipe()
    pcall(function() fovFrame:Destroy() end)
    pcall(function()
        for i = 1, SNIPE_MAX_ARROWS do
            if snipeArrows[i] and snipeArrows[i].frame then
                snipeArrows[i].frame:Destroy()
            end
        end
        for _,c in ipairs(snipeConns) do pcall(function() c:Disconnect() end) end
        snipeConns = {}
    end)
    renderCallbacks = {}
    for _,c in ipairs(cn) do pcall(function() c:Disconnect() end) end
    gui:Destroy()
end)

mmb.MouseButton1Click:Connect(function()
    isM = not isM
    TS:Create(mf, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
        Size = isM and UDim2.new(0,270,0,26) or UDim2.new(0,270,0,220)
    }):Play()
end)
