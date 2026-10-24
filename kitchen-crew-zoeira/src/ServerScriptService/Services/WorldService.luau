local WorldService = {}
local MathUtils = require(game:GetService("ReplicatedStorage").Shared.MathUtils)
local world

local function part(parent, name, size, pos, color, anchored)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = pos
    p.Color = color
    p.Anchored = anchored ~= false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function label(p, title, color)
    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.fromOffset(330, 90)
    gui.StudsOffsetWorldSpace = Vector3.new(0, p.Size.Y/2+2.5, 0)
    gui.AlwaysOnTop = true
    gui.Parent = p
    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1,1)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.GothamBlack
    text.TextScaled = true
    text.TextStrokeTransparency = 0.35
    text.Text = title
    text.TextColor3 = color
    text.Parent = gui
end

function WorldService.Build()
    local existing = workspace:FindFirstChild("KitchenCrewZoeira")
    if existing then existing:Destroy() end
    world = Instance.new("Folder")
    world.Name = "KitchenCrewZoeira"
    world.Parent = workspace

    part(world,"Base",Vector3.new(150,2,120),Vector3.new(0,-1,0), Color3.fromRGB(38,47,55))
    local kitchen = part(world,"KitchenZone", Vector3.new(48,1,40), Vector3.new(-40,0.2,0), Color3.fromRGB(70,109,110))
    label(kitchen,"KITCHEN CREW",Color3.fromRGB(255,236,153))
    local arena = part(world,"PrankArena",Vector3.new(55,1,53),Vector3.new(31,0.2,-5),Color3.fromRGB(107,56,142))
    label(arena,"ARENA DA ZOEIRA",Color3.fromRGB(255,224,81))
    local shop = part(world,"Shop",Vector3.new(17,10,13),Vector3.new(43,5,40),Color3.fromRGB(255,153,84))
    label(shop,"LOJA DA ZOEIRA",Color3.fromRGB(255,255,255))

    local stage = part(world,"CornerStage",Vector3.new(12,1.4,10),Vector3.new(48,1,-22),Color3.fromRGB(230,129,158))
    label(stage,"CANTINHO DA CONFUSAO",Color3.fromRGB(255,230,80))
    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "CrewSpawn"
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Size = Vector3.new(9,1,9)
    spawn.Position = Vector3.new(-8,1,24)
    spawn.Color = Color3.fromRGB(180,224,187)
    spawn.Parent = world

    local recipeStation = part(world,"RecipeStation",Vector3.new(9,3,5),Vector3.new(-48,2,0),Color3.fromRGB(203,167,94))
    label(recipeStation,"PREPARAR PEDIDO", Color3.new(1,1,1))
    local serveStation = part(world,"ServeStation",Vector3.new(9,3,5),Vector3.new(-31,2,0),Color3.fromRGB(100,178,133))
    label(serveStation,"ENTREGAR PEDIDO",Color3.new(1,1,1))
    local prepare = Instance.new("ProximityPrompt")
    prepare.Name = "PrepareOrder"
    prepare.ActionText = "Preparar"
    prepare.ObjectText = "Bancada da cozinha"
    prepare.HoldDuration = 1.5
    prepare.MaxActivationDistance = 10
    prepare.Parent = recipeStation
    local serve = Instance.new("ProximityPrompt")
    serve.Name = "ServeOrder"
    serve.ActionText = "Entregar"
    serve.ObjectText = "Balcao do restaurante"
    serve.HoldDuration = 0.7
    serve.MaxActivationDistance = 10
    serve.Parent = serveStation

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "OpenPrankShop"
    prompt.ActionText = "Abrir loja"
    prompt.ObjectText = "Loja da Zoeira"
    prompt.MaxActivationDistance = 14
    prompt.Parent = shop

    return world
end

function WorldService.InArena(position)
    if not world or not position then return false end
    local partRef = world:FindFirstChild("PrankArena")
    return partRef ~= nil and MathUtils.insideBox(partRef, position, 0)
end

function WorldService.IsInKitchen(position)
    if not world or not position then return false end
    local partRef = world:FindFirstChild("KitchenZone")
    return partRef ~= nil and MathUtils.insideBox(partRef, position, 4)
end

function WorldService.IsSafeBananaPosition(position)
    if not WorldService.InArena(position) then return false end
    if (position - Vector3.new(48,0,-22)).Magnitude < 10 then return false end
    return true
end

function WorldService.GetCornerCFrame()
    return CFrame.new(48, 4, -22)
end

function WorldService.GetFolder()
    return world
end

return WorldService
