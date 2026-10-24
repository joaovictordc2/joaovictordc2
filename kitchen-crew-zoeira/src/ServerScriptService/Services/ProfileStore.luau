-- All durable mutations use UpdateAsync; no stale whole-profile autosave is performed.
-- This keeps receipt grants, inventory debits, and rewards atomic per player key.
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Store = DataStoreService:GetDataStore("KitchenCrewZoeira_Profile_v1")
local ProfileStore = {}
local cache = {}
local available = {}

local function defaultProfile()
    return {
        schema = 1,
        laughs = 65,
        inventory = {pie=3, banana=2, upsideDown=1, confetti=3},
        cornerSeconds = 0,
        mode = "Tranquilo", -- Opt-in mandatory for directed pranks.
        purchases = {},
        achievements = {},
        ordersCompleted = 0,
    }
end

local function normalize(data)
    if type(data) ~= "table" then return defaultProfile() end
    data.schema = 1
    data.laughs = math.max(0, tonumber(data.laughs) or 0)
    data.inventory = type(data.inventory) == "table" and data.inventory or {}
    data.purchases = type(data.purchases) == "table" and data.purchases or {}
    data.achievements = type(data.achievements) == "table" and data.achievements or {}
    data.cornerSeconds = math.max(0, tonumber(data.cornerSeconds) or 0)
    data.ordersCompleted = math.max(0, tonumber(data.ordersCompleted) or 0)
    if data.mode ~= "Tranquilo" and data.mode ~= "Leve" and data.mode ~= "Caos" then
        data.mode = "Tranquilo"
    end
    return data
end

function ProfileStore.Mutate(userId, fn)
    local key = "u_" .. tostring(userId)
    local applied, why
    local ok, result = pcall(function()
        return Store:UpdateAsync(key, function(old)
            local data = normalize(old)
            -- UpdateAsync may re-run this callback, therefore do not emit events here.
            local allow, reason = fn(data)
            applied, why = allow, reason
            if allow == false then return nil end
            return data
        end)
    end)
    if not ok then
        warn("[ProfileStore] DataStore indisponivel: " .. tostring(result))
        return false, "Dados indisponiveis. Tente novamente."
    end
    if applied == false or result == nil then return false, why or "Operacao recusada" end
    cache[userId] = result
    available[userId] = true
    return true, result
end

function ProfileStore.Load(player)
    return ProfileStore.Mutate(player.UserId, function(_data) return true end)
end

function ProfileStore.Get(userId)
    return cache[userId]
end

function ProfileStore.IsLoaded(userId)
    return available[userId] == true
end

function ProfileStore.Snapshot(userId)
    local d = cache[userId]
    if not d then return nil end
    return {
        laughs = d.laughs,
        inventory = table.clone(d.inventory),
        cornerSeconds = d.cornerSeconds,
        mode = d.mode,
        ordersCompleted = d.ordersCompleted,
        achievements = table.clone(d.achievements)
    }
end

function ProfileStore.GrantReward(userId, amount, orderIncrement)
    return ProfileStore.Mutate(userId, function(data)
        data.laughs += math.clamp(math.floor(amount), 0, 100)
        data.ordersCompleted += (orderIncrement and 1 or 0)
        return true
    end)
end

function ProfileStore.UnlockAchievement(userId, key)
    return ProfileStore.Mutate(userId, function(data)
        if data.achievements[key] then return false, "Ja desbloqueada" end
        data.achievements[key] = true
        data.laughs += 5
        return true
    end)
end

function ProfileStore.SetMode(userId, newMode)
    if newMode ~= "Tranquilo" and newMode ~= "Leve" and newMode ~= "Caos" then
        return false, "Modo invalido"
    end
    return ProfileStore.Mutate(userId, function(data)
        data.mode = newMode
        return true
    end)
end

function ProfileStore.BuyWithLaughs(userId, prankId, cost)
    return ProfileStore.Mutate(userId, function(data)
        if data.laughs < cost then return false, "Fichas de Risada insuficientes" end
        data.laughs -= cost
        data.inventory[prankId] = (data.inventory[prankId] or 0) + 1
        return true
    end)
end

function ProfileStore.Consume(userId, prankId)
    return ProfileStore.Mutate(userId, function(data)
        if (data.inventory[prankId] or 0) < 1 then return false, "Sem cargas desta pegadinha" end
        data.inventory[prankId] -= 1
        return true
    end)
end

function ProfileStore.Refund(userId, prankId)
    return ProfileStore.Mutate(userId, function(data)
        data.inventory[prankId] = (data.inventory[prankId] or 0) + 1
        return true
    end)
end

function ProfileStore.ConsumeCornerTime(userId, seconds)
    seconds = math.max(0, math.floor(seconds))
    if seconds == 0 then return true, ProfileStore.Get(userId) end
    return ProfileStore.Mutate(userId, function(data)
        data.cornerSeconds = math.max(0, data.cornerSeconds - seconds)
        return true
    end)
end

function ProfileStore.GrantReceipt(receipt, product)
    if not Players:GetPlayerByUserId(receipt.PlayerId) then
        return false, "Jogador ausente"
    end
    return ProfileStore.Mutate(receipt.PlayerId, function(data)
        if data.purchases[receipt.PurchaseId] then return true end
        for itemId, count in pairs(product.grants) do
            if itemId == "cornerSeconds" then
                data.cornerSeconds += count
            else
                data.inventory[itemId] = (data.inventory[itemId] or 0) + count
            end
        end
        -- One atomic write: receipt marker and reward cannot diverge.
        data.purchases[receipt.PurchaseId] = true
        return true
    end)
end

Players.PlayerRemoving:Connect(function(player)
    cache[player.UserId] = nil
    available[player.UserId] = nil
end)

return ProfileStore
