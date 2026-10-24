local Players = game:GetService("Players")
local Profiles = require(script.Parent.ProfileStore)
local World = require(script.Parent.WorldService)
local Corner = {}
local sessions = {} -- indexed by target userId
local invitations = {}
local remote
local refresh

local function notify(player, message)
    if player and player.Parent == Players then remote:FireClient(player,"Notice",{message=message}) end
end

local function bill(session, force)
    if session.paused then return true end
    local now = os.clock()
    local elapsed = math.max(0, math.floor(now - session.lastBilled))
    local record = Profiles.Get(session.owner.UserId)
    local remaining = record and record.cornerSeconds or 0
    if elapsed < 1 or (not force and elapsed < math.min(5, remaining)) then return true end
    session.lastBilled += elapsed
    local ok, result = Profiles.ConsumeCornerTime(session.owner.UserId,elapsed)
    if ok then refresh(session.owner) end
    return ok and result and result.cornerSeconds > 0
end

local function finish(session)
    if sessions[session.target.UserId] ~= session then return end
    bill(session, true)
    sessions[session.target.UserId] = nil
    if session.target and session.target.Parent == Players then
        remote:FireClient(session.target,"CornerUpdate",{active=false})
        notify(session.target,"Encenação encerrada. Você está livre para sair.")
    end
    if session.owner and session.owner.Parent == Players then
        remote:FireClient(session.owner,"CornerUpdate",{active=false})
        refresh(session.owner)
    end
end

function Corner.Init(event, refreshFn)
    remote = event
    refresh = refreshFn
    task.spawn(function()
        while true do
            task.wait(1)
            for _, session in pairs(sessions) do
                local owner, target = session.owner, session.target
                local c = target.Character
                local root = c and c:FindFirstChild("HumanoidRootPart")
                if owner.Parent ~= Players or target.Parent ~= Players or not root then
                    finish(session)
                elseif (root.Position-World.GetCornerCFrame().Position).Magnitude > 16 then
                    finish(session) -- simply walking away ends the session
                elseif not session.paused then
                    if not bill(session) then finish(session) end
                end
            end
        end
    end)
    Players.PlayerRemoving:Connect(function(player)
        invitations[player.UserId] = nil
        for _, session in pairs(sessions) do
            if session.owner == player or session.target == player then finish(session) end
        end
    end)
end

function Corner.Invite(owner, target)
    if owner == target or not target then return false,"Escolha outro jogador" end
    if (Profiles.Get(owner.UserId) or {}).mode ~= "Caos" then return false,"Ative o modo Caos para convidar" end
    if (Profiles.Get(target.UserId) or {}).mode ~= "Caos" then return false,"Seu amigo precisa ativar Caos" end
    if (Profiles.Get(owner.UserId) or {}).cornerSeconds < 1 then return false,"Sem saldo no cantinho" end
    if sessions[target.UserId] then return false,"Jogador ja participa de uma encenacao" end
    for _, active in pairs(sessions) do
        if active.owner == owner then return false,"Termine sua encenacao atual primeiro" end
    end
    local ownerRoot = owner.Character and owner.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not ownerRoot or not targetRoot then return false,"Personagem indisponivel" end
    if (ownerRoot.Position - targetRoot.Position).Magnitude > 60 then return false,"Aproxime-se do seu amigo" end
    if not World.InArena(ownerRoot.Position) or not World.InArena(targetRoot.Position) then
        return false,"Ambos precisam estar na Arena da Zoeira"
    end
    invitations[target.UserId] = {owner=owner,expires=os.clock()+18}
    remote:FireClient(target,"CornerInvite",{from=owner.DisplayName})
    return true,"Convite enviado (participacao voluntaria)"
end

function Corner.Reply(target, accepted)
    local invitation = invitations[target.UserId]
    invitations[target.UserId] = nil
    if not invitation or invitation.expires < os.clock() then return false,"Convite expirou" end
    local owner = invitation.owner
    if not accepted then notify(owner,"Convite recusado"); return true,"Convite recusado" end
    if owner.Parent ~= Players or target.Parent ~= Players then return false,"Jogador saiu" end
    if (Profiles.Get(owner.UserId) or {}).cornerSeconds < 1 then return false,"Saldo esgotado" end
    if (Profiles.Get(target.UserId) or {}).mode ~= "Caos" or (Profiles.Get(owner.UserId) or {}).mode ~= "Caos" then
        return false,"Modo Caos desativado"
    end
    if sessions[target.UserId] then return false,"Voce ja esta participando" end
    local c = target.Character
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if not root then return false,"Personagem indisponivel" end
    root.CFrame = World.GetCornerCFrame()
    local session = {owner=owner,target=target,lastBilled=os.clock(),paused=false}
    sessions[target.UserId] = session
    remote:FireClient(target,"CornerUpdate",{active=true,role="target",paused=false})
    remote:FireClient(owner,"CornerUpdate",{active=true,role="owner",paused=false})
    notify(target,"Você pode usar SAIR ou andar para fora do palco a qualquer momento")
    return true,"Encenacao iniciada"
end

function Corner.Action(player, action)
    local session
    for _, entry in pairs(sessions) do
        if entry.owner == player or entry.target == player then session = entry break end
    end
    if not session then return false,"Nenhuma encenacao ativa" end
    if action == "leave" or action == "stop" then
        finish(session)
        return true,"Encenacao encerrada"
    end
    if player ~= session.owner then return false,"Apenas o organizador pode pausar" end
    if action == "pause" and not session.paused then
        bill(session, true)
        session.paused = true
    elseif action == "resume" and session.paused then
        session.paused = false
        session.lastBilled = os.clock()
    else
        return false,"Acao indisponivel"
    end
    remote:FireClient(session.target,"CornerUpdate",{active=true,role="target",paused=session.paused})
    remote:FireClient(session.owner,"CornerUpdate",{active=true,role="owner",paused=session.paused})
    return true,session.paused and "Pausado: saldo preservado" or "Encenacao retomada"
end

function Corner.StopForModeChange(player)
    for _, session in pairs(sessions) do
        if session.owner == player or session.target == player then finish(session) end
    end
end

return Corner
