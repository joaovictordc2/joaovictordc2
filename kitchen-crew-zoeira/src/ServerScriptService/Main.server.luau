-- Server is authoritative for granting purchased inventory and activating pranks.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Profiles = require(script.Parent.Services.ProfileStore)
local Products = require(ReplicatedStorage.Shared.ProductConfig)
local WorldService = require(script.Parent.Services.WorldService)
local KitchenService = require(script.Parent.Services.KitchenService)
local PrankService = require(script.Parent.Services.PrankService)

local networkFolder = Instance.new("Folder")
networkFolder.Name = "KitchenNetwork"
networkFolder.Parent = ReplicatedStorage
local function make(class, name)
    local x = Instance.new(class)
    x.Name = name
    x.Parent = networkFolder
    return x
end
local network = {
    Action = make("RemoteEvent","Action"),
    Event = make("RemoteEvent","Event"),
    Query = make("RemoteFunction","Query")
}

local world = WorldService.Build()
KitchenService.Init(network.Event,world)
PrankService.Init(network)

Players.PlayerAdded:Connect(function(player)
    local ok, data = Profiles.Load(player)
    if ok then
        network.Event:FireClient(player,"Snapshot",{profile=Profiles.Snapshot(player.UserId)})
    else
        network.Event:FireClient(player,"Notice",{message="Erro ao carregar dados. Compras e consumos bloqueados."})
        warn("Nao foi possivel carregar o perfil de "..player.Name..": "..tostring(data))
    end
end)

-- Use ONE ProcessReceipt implementation for this game; reconcile with an existing handler.
MarketplaceService.ProcessReceipt = function(receipt)
    local product = Products.byId[receipt.ProductId]
    if not product then
        warn("Produto Roblox sem configuracao: ",receipt.ProductId)
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
    local ok = Profiles.GrantReceipt(receipt,product)
    if not ok then return Enum.ProductPurchaseDecision.NotProcessedYet end
    local player = Players:GetPlayerByUserId(receipt.PlayerId)
    if player then
        network.Event:FireClient(player,"Snapshot",{profile=Profiles.Snapshot(receipt.PlayerId)})
        network.Event:FireClient(player,"Notice",{message="Compra concluida: "..product.name})
    end
    return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Emergency cleanup is handled by individual effect and corner services.
