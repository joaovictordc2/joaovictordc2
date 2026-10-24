local Players = game:GetService("Players")
local Profiles = require(script.Parent.ProfileStore)
local Kitchen = {}
local dishes = {"Pizza", "Hamburguer", "Macarrao", "Salada", "Sanduiche"}
local nextOrder = 1
local pending = {}
local busy = {}

local function valid(player)
    local c = player.Character
    local humanoid = c and c:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0 and Profiles.IsLoaded(player.UserId)
end

local function tell(event, player, message)
    event:FireClient(player,"Notice",{message=message})
end

local function createCustomer(parent, pos, index)
    local m = Instance.new("Model")
    m.Name = "ClienteNPC_"..index
    m.Parent = parent
    local torso = Instance.new("Part")
    torso.Name = "Body"
    torso.Anchored = true
    torso.Size = Vector3.new(2,2.5,1.3)
    torso.Position = pos
    torso.Color = Color3.fromRGB(55+index*30,148,176)
    torso.Parent = m
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Shape = Enum.PartType.Ball
    head.Anchored = true
    head.Size = Vector3.new(1.8,1.8,1.8)
    head.Position = pos+Vector3.new(0,2.1,0)
    head.Color = Color3.fromRGB(239,193,155)
    head.Parent = m
    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.fromOffset(250,80)
    gui.StudsOffsetWorldSpace = Vector3.new(0,2.1,0)
    gui.Parent = head
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1,1)
    label.Text = "Pedido: "..dishes[index]
    label.TextColor3 = Color3.fromRGB(255,247,212)
    label.TextStrokeTransparency = .25
    label.BackgroundTransparency = 1
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui
end

function Kitchen.Init(event, world)
    local counter = world:WaitForChild("RecipeStation")
    local serve = world:WaitForChild("ServeStation")
    for i=1,4 do createCustomer(world,Vector3.new(-55+i*7,2.1,-29),i) end
    counter.PrepareOrder.Triggered:Connect(function(player)
        if busy[player.UserId] then return end
        if not valid(player) then tell(event,player,"Perfil ainda indisponivel"); return end
        if pending[player.UserId] then tell(event,player,"Entregue primeiro seu pedido pronto"); return end
        busy[player.UserId] = true
        local index = ((nextOrder-1) % #dishes)+1
        nextOrder += 1
        pending[player.UserId] = dishes[index]
        player:SetAttribute("CarryingOrder",dishes[index])
        tell(event,player,"Voce preparou "..dishes[index].."! Leve ao balcao para ganhar fichas.")
        busy[player.UserId] = nil
    end)
    serve.ServeOrder.Triggered:Connect(function(player)
        if busy[player.UserId] then return end
        if not valid(player) then return end
        local dish = pending[player.UserId]
        if not dish then tell(event,player,"Prepare um prato antes de entregar"); return end
        busy[player.UserId] = true
        local success, profile = Profiles.Mutate(player.UserId,function(data)
            data.laughs += 20
            data.ordersCompleted += 1
            if data.ordersCompleted % 20 == 0 then
                data.inventory.pie = (data.inventory.pie or 0) + 5
            end
            return true
        end)
        busy[player.UserId] = nil
        if success then
            pending[player.UserId] = nil
            player:SetAttribute("CarryingOrder",nil)
            tell(event,player,"Pedido de "..dish.." entregue! +20 Fichas de Risada")
            if profile.ordersCompleted % 20 == 0 then
                tell(event,player,"Missao de 20 pedidos completa: +5 tortas gratuitas!")
            end
            event:FireClient(player,"Snapshot",{profile=Profiles.Snapshot(player.UserId)})
        else
            tell(event,player,"Falha ao salvar recompensa: "..tostring(profile))
        end
    end)
    Players.PlayerRemoving:Connect(function(player)
        pending[player.UserId] = nil
        busy[player.UserId] = nil
    end)
end
return Kitchen
