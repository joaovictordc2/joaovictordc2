local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("Shared")
local Pranks = require(shared:WaitForChild("PrankConfig"))
local Products = require(shared:WaitForChild("ProductConfig"))
local MathUtils = require(shared:WaitForChild("MathUtils"))
local network = ReplicatedStorage:WaitForChild("KitchenNetwork")
local action = network:WaitForChild("Action")
local events = network:WaitForChild("Event")
local query = network:WaitForChild("Query")

local profile
local targets = {}
local targetIndex = 1
local cornerState = {active=false}
local reduceEffects = false
local activeButtons = {}

local function new(class, props, parent)
    local obj = Instance.new(class)
    for key,val in pairs(props or {}) do obj[key] = val end
    obj.Parent = parent
    return obj
end
local COLORS = {
    bg=Color3.fromRGB(29,31,48), panel=Color3.fromRGB(40,45,68),
    accent=Color3.fromRGB(255,186,95), white=Color3.fromRGB(248,247,241),
    gray=Color3.fromRGB(184,192,212), green=Color3.fromRGB(122,215,156)
}
local gui = new("ScreenGui",{Name="KitchenCrewHUD",ResetOnSpawn=false,IgnoreGuiInset=false},localPlayer:WaitForChild("PlayerGui"))
local toggle = new("TextButton",{
    Name="OpenShop",AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,12,1,-14),
    Size=UDim2.fromOffset(165,50),Font=Enum.Font.GothamBold,TextSize=18,
    Text="LOJA DA ZOEIRA",BackgroundColor3=COLORS.accent,TextColor3=COLORS.bg
},gui)
new("UICorner",{CornerRadius=UDim.new(0,12)},toggle)

local panel = new("Frame",{
    Name="ShopPanel",AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,12,.5,0),
    Size=UDim2.new(0.91,0,0.8,0),BackgroundColor3=COLORS.bg,Visible=false
},gui)
new("UISizeConstraint",{MaxSize=Vector2.new(550,770),MinSize=Vector2.new(275,450)},panel)
new("UICorner",{CornerRadius=UDim.new(0,15)},panel)
new("UIStroke",{Color=COLORS.accent,Thickness=1.6,Transparency=.5},panel)
new("UIPadding",{PaddingTop=UDim.new(0,15),PaddingBottom=UDim.new(0,15),PaddingLeft=UDim.new(0,15),PaddingRight=UDim.new(0,15)},panel)
new("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},panel)

local function label(parent, value, height, size, color, layoutOrder)
    return new("TextLabel",{
        Size=UDim2.new(1,0,0,height),BackgroundTransparency=1,
        Text=value,TextColor3=color or COLORS.white,TextWrapped=true,
        Font=Enum.Font.GothamBold,TextSize=size or 15,TextXAlignment=Enum.TextXAlignment.Left,
        LayoutOrder=layoutOrder or 1
    },parent)
end
local function button(parent, text, callback, height, color, layoutOrder)
    local b = new("TextButton",{
        Size=UDim2.new(1,0,0,height or 36),BackgroundColor3=color or COLORS.panel,
        TextColor3=COLORS.white,Font=Enum.Font.GothamBold,TextSize=14,
        TextWrapped=true,Text=text,LayoutOrder=layoutOrder or 2
    },parent)
    new("UICorner",{CornerRadius=UDim.new(0,8)},b)
    b.MouseButton1Click:Connect(callback)
    return b
end

local head = new("Frame",{Size=UDim2.new(1,0,0,42),BackgroundTransparency=1,LayoutOrder=1},panel)
label(head,"LOJA DA ZOEIRA",38,22,COLORS.accent)
local close = new("TextButton",{Text="X",Size=UDim2.fromOffset(42,38),AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Font=Enum.Font.GothamBlack,TextSize=20,TextColor3=COLORS.white,BackgroundColor3=COLORS.panel},head)
new("UICorner",{CornerRadius=UDim.new(0,10)},close)
close.MouseButton1Click:Connect(function() panel.Visible=false end)
toggle.MouseButton1Click:Connect(function() panel.Visible=not panel.Visible end)
local status = label(panel,"Carregando inventário...",38,14,COLORS.green,2)
local targetBtn
targetBtn = button(panel,"ALVO: Escolher jogador",function()
    local ok, result = pcall(function() return query:InvokeServer() end)
    if ok and result and result.players then targets=result.players end
    targetIndex += 1
    if targetIndex > #targets then targetIndex=1 end
    if #targets > 0 then
        local t = targets[targetIndex]
        targetBtn.Text="ALVO: "..t.name.." ("..t.mode..")"
    else targetBtn.Text="ALVO: Nenhum jogador online" end
end,36,COLORS.panel,3)

local modeRow = new("Frame",{Size=UDim2.new(1,0,0,40),BackgroundTransparency=1,LayoutOrder=4},panel)
local modeLayout = new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,6)},modeRow)
for _,mode in ipairs(Pranks.modes) do
    local b = new("TextButton",{
        Size=UDim2.new(1/3,-4,1,0),Text=mode,Font=Enum.Font.GothamBold,
        TextSize=13,BackgroundColor3=COLORS.panel,TextColor3=COLORS.white
    },modeRow)
    new("UICorner",{CornerRadius=UDim.new(0,8)},b)
    b.MouseButton1Click:Connect(function() action:FireServer("SetMode",{mode=mode}) end)
end
local controls = new("Frame",{Size=UDim2.new(1,0,0,37),BackgroundTransparency=1,LayoutOrder=5},panel)
new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,6)},controls)
local invite = new("TextButton",{Size=UDim2.new(.65,-3,1,0),Text="CONVIDAR AO CANTINHO",TextSize=12,TextWrapped=true,TextColor3=COLORS.bg,Font=Enum.Font.GothamBold,BackgroundColor3=COLORS.accent},controls)
local leave = new("TextButton",{Size=UDim2.new(.35,-3,1,0),Text="SAIR / PARAR",TextSize=12,TextWrapped=true,TextColor3=COLORS.white,Font=Enum.Font.GothamBold,BackgroundColor3=COLORS.panel},controls)
new("UICorner",{CornerRadius=UDim.new(0,8)},invite)
new("UICorner",{CornerRadius=UDim.new(0,8)},leave)
invite.MouseButton1Click:Connect(function()
    local target = targets[targetIndex]
    if target then action:FireServer("CornerInvite",{targetId=target.userId}) end
end)
leave.MouseButton1Click:Connect(function() action:FireServer("CornerAction",{kind="leave"}) end)

local scroll = new("ScrollingFrame",{
    Size=UDim2.new(1,0,1,-320),AutomaticCanvasSize=Enum.AutomaticSize.Y,
    CanvasSize=UDim2.fromOffset(0,0),ScrollBarThickness=5,
    BackgroundTransparency=1,LayoutOrder=7
},panel)
new("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},scroll)
local footer = label(panel,"Dicas: trabalhe na cozinha para ganhar fichas. Use o modo Caos apenas se quiser participar.",35,12,COLORS.gray,8)

local function selectedTargetId()
    local t = targets[targetIndex]
    return t and t.userId or nil
end
local function refreshCards()
    for _, b in ipairs(activeButtons) do
        if b.frame and b.frame.Parent then b.frame:Destroy() end
    end
    table.clear(activeButtons)
    for _, def in ipairs(Pranks.list) do
        local card = new("Frame",{Size=UDim2.new(1,-6,0,def.enabled and 90 or 42),BackgroundColor3=COLORS.panel,LayoutOrder=#activeButtons+1},scroll)
        new("UICorner",{CornerRadius=UDim.new(0,8)},card)
        local detail = label(card,def.name..(def.enabled and ("  |  Cargas: "..tostring((profile and profile.inventory[def.id]) or 0)) or "  |  EM BREVE"),28,14,def.enabled and COLORS.white or COLORS.gray)
        detail.Position=UDim2.fromOffset(8,0)
        detail.Size=UDim2.new(1,-16,0,27)
        if def.enabled then
            local description = label(card,def.description or "",22,12,COLORS.gray)
            description.Position=UDim2.fromOffset(8,25)
            description.Size=UDim2.new(1,-16,0,22)
            local useBtn = new("TextButton",{
                Text="USAR",Size=UDim2.new(.46,-10,0,31),Position=UDim2.new(0,8,0,53),
                BackgroundColor3=COLORS.accent,TextColor3=COLORS.bg,Font=Enum.Font.GothamBold,TextSize=13
            },card)
            new("UICorner",{CornerRadius=UDim.new(0,7)},useBtn)
            useBtn.MouseButton1Click:Connect(function()
                action:FireServer("Use",{id=def.id,targetId=selectedTargetId()})
            end)
            local buyBtn = new("TextButton",{
                Text="+1  "..def.cost.." FICHAS",Size=UDim2.new(.54,-10,0,31),Position=UDim2.new(.46,2,0,53),
                BackgroundColor3=COLORS.bg,TextColor3=COLORS.green,Font=Enum.Font.GothamBold,TextSize=12
            },card)
            new("UICorner",{CornerRadius=UDim.new(0,7)},buyBtn)
            buyBtn.MouseButton1Click:Connect(function() action:FireServer("BuyFree",{id=def.id}) end)
        end
        table.insert(activeButtons,{frame=card})
    end
    local productsHeading = label(scroll,"PACOTES ROBUX (IDs oficiais necessários)",34,15,COLORS.accent,#activeButtons+1)
    table.insert(activeButtons,{frame=productsHeading})
    for _, product in ipairs(Products.list) do
        local b = button(scroll,product.name.." — "..product.price.." Robux"..(product.productId == 0 and " [desativado]" or ""),function()
            if product.productId ~= 0 then
                MarketplaceService:PromptProductPurchase(localPlayer,product.productId)
            end
        end,36,product.productId == 0 and COLORS.panel or COLORS.accent,#activeButtons+2)
        b.Active = product.productId ~= 0
        b.AutoButtonColor = product.productId ~= 0
        table.insert(activeButtons,{frame=b})
    end
end

local messageBox = new("TextLabel",{
    Name="Toast",AnchorPoint=Vector2.new(.5,0),Position=UDim2.fromScale(.5,.04),
    Size=UDim2.new(.92,0,0,62),BackgroundColor3=COLORS.bg,TextColor3=COLORS.white,
    Text="",TextWrapped=true,TextSize=16,Font=Enum.Font.GothamBold,Visible=false,ZIndex=25
},gui)
new("UISizeConstraint",{MaxSize=Vector2.new(550,80)},messageBox)
new("UICorner",{CornerRadius=UDim.new(0,12)},messageBox)
local noticeSequence = 0
local function toast(text)
    noticeSequence += 1
    local seq=noticeSequence
    messageBox.Text=text
    messageBox.Visible=true
    task.delay(3.5,function() if noticeSequence==seq then messageBox.Visible=false end end)
end

local inviteDialog = new("Frame",{
    AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.new(.85,0,0,170),
    BackgroundColor3=COLORS.bg,Visible=false,ZIndex=30
},gui)
new("UISizeConstraint",{MaxSize=Vector2.new(420,210)},inviteDialog)
new("UICorner",{CornerRadius=UDim.new(0,12)},inviteDialog)
local inviteText = label(inviteDialog,"Convite para o Cantinho da Confusao",75,17,COLORS.white)
inviteText.Position=UDim2.fromOffset(15,10)
inviteText.Size=UDim2.new(1,-30,0,80)
inviteText.ZIndex=31
local accept = new("TextButton",{Text="ACEITAR",Size=UDim2.new(.45,0,0,40),Position=UDim2.new(.035,0,0,107),ZIndex=31,BackgroundColor3=COLORS.green,Font=Enum.Font.GothamBold,TextColor3=COLORS.bg},inviteDialog)
local reject = new("TextButton",{Text="RECUSAR",Size=UDim2.new(.45,0,0,40),Position=UDim2.new(.52,0,0,107),ZIndex=31,BackgroundColor3=COLORS.panel,Font=Enum.Font.GothamBold,TextColor3=COLORS.white},inviteDialog)
accept.MouseButton1Click:Connect(function() inviteDialog.Visible=false; action:FireServer("CornerReply",{accept=true}) end)
reject.MouseButton1Click:Connect(function() inviteDialog.Visible=false; action:FireServer("CornerReply",{accept=false}) end)

local cornerButton = new("TextButton",{
    AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-12,1,-15),Size=UDim2.fromOffset(180,50),
    Text="SAIR DO CANTINHO",Font=Enum.Font.GothamBold,TextSize=14,
    BackgroundColor3=COLORS.accent,TextColor3=COLORS.bg,Visible=false,ZIndex=15
},gui)
new("UICorner",{CornerRadius=UDim.new(0,10)},cornerButton)
cornerButton.MouseButton1Click:Connect(function()
    action:FireServer("CornerAction",{kind=cornerState.role=="owner" and "stop" or "leave"})
end)
local reduce = new("TextButton",{
    AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,8),Size=UDim2.fromOffset(170,32),
    Text="Efeitos visuais: ON",TextColor3=COLORS.white,BackgroundColor3=COLORS.panel,
    Font=Enum.Font.GothamBold,TextSize=12
},gui)
new("UICorner",{CornerRadius=UDim.new(0,7)},reduce)
reduce.MouseButton1Click:Connect(function()
    reduceEffects = not reduceEffects
    reduce.Text=reduceEffects and "Efeitos visuais: REDUZIDOS" or "Efeitos visuais: ON"
end)

local overlay = new("Frame",{
    Name="PieOverlay",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
    Visible=false,ZIndex=10
},gui)
for _, properties in ipairs({
    {pos=UDim2.fromScale(-.05,-.04),size=UDim2.fromScale(.38,.22)},
    {pos=UDim2.fromScale(.78,-.06),size=UDim2.fromScale(.38,.25)},
    {pos=UDim2.fromScale(-.06,.84),size=UDim2.fromScale(.36,.25)},
    {pos=UDim2.fromScale(.81,.83),size=UDim2.fromScale(.38,.25)},
}) do
    local blob = new("Frame",{Position=properties.pos,Size=properties.size,
        BackgroundColor3=Color3.fromRGB(255,237,206),BackgroundTransparency=.32,ZIndex=10},overlay)
    new("UICorner",{CornerRadius=UDim.new(1,0)},blob)
end
local blur = new("BlurEffect",{Name="ZoeiraBriefBlur",Size=0,Enabled=false},Lighting)
local pieToken=0
local function pieImpact(seconds)
    if reduceEffects then toast("PLOFT! Voce levou uma tortada!"); return end
    pieToken += 1
    local token=pieToken
    overlay.Visible=true
    blur.Enabled=true
    blur.Size=6
    task.delay(.35,function() if token==pieToken then blur.Size=0;blur.Enabled=false end end)
    task.delay(math.min(seconds or 10,10),function() if token==pieToken then overlay.Visible=false end end)
end

local function updateProfile(p)
    if not p then return end
    profile=p
    status.Text="Fichas: "..p.laughs.."   |   Modo: "..p.mode.."   |   Cantinho: "..MathUtils.formatTime(p.cornerSeconds).."   |   Pedidos: "..p.ordersCompleted
    refreshCards()
end

events.OnClientEvent:Connect(function(kind, payload)
    if kind=="Snapshot" then updateProfile(payload.profile)
    elseif kind=="Notice" then toast(payload.message or "")
    elseif kind=="PieImpact" then pieImpact(payload.duration)
    elseif kind=="CornerInvite" then
        inviteText.Text=(payload.from or "Um jogador").." convida para encenar no Cantinho da Confusao. Voce pode sair quando quiser."
        inviteDialog.Visible=true
    elseif kind=="CornerUpdate" then
        cornerState=payload
        cornerButton.Visible=payload.active
        cornerButton.Text=payload.role == "owner" and "PARAR CANTINHO" or "SAIR DO CANTINHO"
        if payload.active and payload.paused then toast("Cantinho pausado") end
    elseif kind=="Shake" then
        if not reduceEffects then toast("Oooopa! Que confusao!") end
    end
end)

local openPrompt = workspace:WaitForChild("KitchenCrewZoeira"):WaitForChild("Shop"):WaitForChild("OpenPrankShop")
openPrompt.Triggered:Connect(function(_player) panel.Visible=true end)

local ok,result = pcall(function() return query:InvokeServer() end)
if ok and result then
    updateProfile(result.profile)
    targets=result.players or {}
    if #targets > 0 then
        targetBtn.Text="ALVO: "..targets[1].name.." ("..targets[1].mode..")"
    end
end

Players.PlayerAdded:Connect(function()
    local successful,data=pcall(function() return query:InvokeServer() end)
    if successful and data then targets=data.players or targets end
end)
Players.PlayerRemoving:Connect(function()
    local successful,data=pcall(function() return query:InvokeServer() end)
    if successful and data then targets=data.players or targets; targetIndex=1 end
end)
