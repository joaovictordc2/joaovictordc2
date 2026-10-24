local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.PrankConfig)
local Profiles = require(script.Parent.ProfileStore)
local Effects = require(script.Parent.EffectService)
local World = require(script.Parent.WorldService)
local Corner = require(script.Parent.CornerService)
local Pranks = {}

local nextAction = {}
local inFlight = {}
local immunity = {}
local lastFromTo = {}
local remote
local function rootOf(player)
    local c = player and player.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil end
    return c:FindFirstChild("HumanoidRootPart")
end
local function distance(a,b)
    local aRoot, bRoot = rootOf(a), rootOf(b)
    if not aRoot or not bRoot then return math.huge end
    return (aRoot.Position - bRoot.Position).Magnitude
end
local function notify(player, text)
    remote:FireClient(player,"Notice",{message=text})
end
local function refresh(player)
    if player and player.Parent == Players then
        remote:FireClient(player,"Snapshot",{profile=Profiles.Snapshot(player.UserId)})
    end
end

local function eligible(actor, target, def)
    local a, t = rootOf(actor), rootOf(target)
    if not a or not t then return false,"Personagem indisponivel" end
    if actor == target and def.disrupt then return false,"Escolha outro jogador" end
    if distance(actor,target) > 45 then return false,"Alvo muito distante" end
    local mode = (Profiles.Get(target.UserId) or {}).mode
    if actor ~= target and mode == "Tranquilo" then return false,"Alvo em Modo Tranquilo" end
    if World.IsInKitchen(t.Position) then return false,"Area de trabalho protegida" end
    if def.arena and (not World.InArena(a.Position) or not World.InArena(t.Position)) then
        return false,"Esta pegadinha so funciona na Arena"
    end
    local key = tostring(actor.UserId)..":"..tostring(target.UserId)
    local now = os.clock()
    if (lastFromTo[key] or 0) > now then return false,"Aguarde antes de brincar com o mesmo alvo" end
    if def.disrupt and (immunity[target.UserId] or 0) > now then
        return false,"Alvo protegido por 90 segundos"
    end
    if def.disrupt and (target:GetAttribute("KitchenBusy") == true) then
        return false,"Alvo preparando um pedido"
    end
    return true
end

local function apply(actor, target, def)
    if def.id == "upsideDown" then
        return Effects.Transform("upsideDown",target,remote)
    elseif def.id == "pie" then
        Effects.ThrowPie(actor,target)
        task.delay(.46,function()
            if target.Parent == Players then
                Effects.PlayVisual("pie",target,remote)
                if not (Profiles.Get(target.UserId) or {}).achievements["firstPie"] then
                    Profiles.UnlockAchievement(target.UserId,"firstPie")
                    refresh(target)
                end
            end
        end)
        return true
    else
        return Effects.PlayVisual(def.id,target,remote)
    end
end

local function use(player, prankId, userId)
    local def = Config.byId[prankId]
    if not def or not def.enabled then return false,"Pegadinha ainda nao implementada" end
    if not Profiles.IsLoaded(player.UserId) then return false,"Dados ainda nao carregados" end
    if def.id == "banana" then
        local root = rootOf(player)
        if not root then return false,"Personagem indisponivel" end
        local where = root.Position + root.CFrame.LookVector * 3
        if not World.IsSafeBananaPosition(where) then return false,"Coloque a banana dentro da Arena" end
        local ok, msg = Profiles.Consume(player.UserId,"banana")
        if not ok then return false,msg end
        local placed = Effects.SpawnBanana(where,player,function(target)
            local allowed = eligible(player,target,{disrupt=true,arena=true})
            if not allowed then return false end
            if Effects.Transform("banana",target,remote) then
                immunity[target.UserId] = os.clock()+90
                lastFromTo[tostring(player.UserId)..":"..tostring(target.UserId)] = os.clock()+30
                return true
            end
            return false
        end)
        if not placed then Profiles.Refund(player.UserId,"banana"); return false,"Falha na armadilha" end
        refresh(player)
        return true,"Casca colocada (dura ate 25 segundos)"
    end
    if type(userId) ~= "number" or userId % 1 ~= 0 then return false,"Alvo invalido" end
    local target = Players:GetPlayerByUserId(userId)
    if not target then return false,"Escolha um alvo valido" end
    local ok, msg = eligible(player,target,def)
    if not ok then return false,msg end
    -- Reserve against concurrent per-user requests; debit only after eligibility checks.
    ok, msg = Profiles.Consume(player.UserId,def.id)
    if not ok then return false,msg end
    local success, executed = pcall(function() return apply(player,target,def) end)
    if not success or not executed then
        Profiles.Refund(player.UserId,def.id)
        refresh(player)
        return false,"Efeito indisponivel; devolucao solicitada"
    end
    local now = os.clock()
    lastFromTo[tostring(player.UserId)..":"..tostring(target.UserId)] = now + 30
    if def.disrupt then immunity[target.UserId] = now + 90 end
    refresh(player)
    return true,"Pegadinha ativada!"
end

function Pranks.Init(network)
    remote = network.Event
    Corner.Init(remote,refresh)
    network.Query.OnServerInvoke = function(player)
        if not Profiles.IsLoaded(player.UserId) then return {error="Dados indisponiveis"} end
        local targets = {}
        for _, other in ipairs(Players:GetPlayers()) do
            if other ~= player then
                table.insert(targets,{name=other.DisplayName,userId=other.UserId,mode=(Profiles.Get(other.UserId) or {}).mode or "Tranquilo"})
            end
        end
        return {profile=Profiles.Snapshot(player.UserId),players=targets}
    end
    network.Action.OnServerEvent:Connect(function(player,action,payload)
        if type(action)~="string" or type(payload)~="table" then return end
        local now = os.clock()
        if (nextAction[player.UserId] or 0) > now or inFlight[player.UserId] then return end
        nextAction[player.UserId] = now + 0.35
        inFlight[player.UserId] = true
        local ok, success, message = pcall(function()
            if not Profiles.IsLoaded(player.UserId) then return false,"Perfil indisponivel" end
            if action == "Use" and type(payload.id)=="string" then
                return use(player,payload.id,payload.targetId)
            elseif action == "BuyFree" and type(payload.id)=="string" then
                local def = Config.byId[payload.id]
                if not def or not def.enabled then return false,"Item indisponivel" end
                local done, why = Profiles.BuyWithLaughs(player.UserId,def.id,def.cost)
                if done then refresh(player) end
                return done,done and ("1 carga: "..def.name) or why
            elseif action == "SetMode" and type(payload.mode)=="string" then
                local done, why = Profiles.SetMode(player.UserId,payload.mode)
                if done then
                    if payload.mode == "Tranquilo" then
                        Corner.StopForModeChange(player)
                        Effects.CancelTransform(player)
                    end
                    refresh(player)
                end
                return done,done and "Configuracao atualizada" or why
            elseif action == "CornerInvite" and type(payload.targetId)=="number" then
                local target = Players:GetPlayerByUserId(payload.targetId)
                return Corner.Invite(player,target)
            elseif action == "CornerReply" and type(payload.accept)=="boolean" then
                return Corner.Reply(player,payload.accept)
            elseif action == "CornerAction" and type(payload.kind)=="string" then
                return Corner.Action(player,payload.kind)
            end
            return false,"Acao nao reconhecida"
        end)
        inFlight[player.UserId] = nil
        if not ok then warn("[PrankService] "..tostring(success)); notify(player,"Falha inesperada")
        else notify(player,message or (success and "OK" or "Nao permitido")) end
    end)
    Players.PlayerRemoving:Connect(function(player)
        nextAction[player.UserId]=nil
        inFlight[player.UserId]=nil
        immunity[player.UserId]=nil
        Effects.CancelTransform(player)
    end)
end
return Pranks
