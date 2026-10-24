local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local AssetConfig = require(game:GetService("ReplicatedStorage").Shared.AssetConfig)

local Effects = {}
local random = Random.new()
local PALETTE = {
    Color3.fromRGB(255, 222, 95), Color3.fromRGB(255, 112, 159),
    Color3.fromRGB(109, 223, 237), Color3.fromRGB(176, 123, 255)
}

local function rootOf(player)
    local c = player and player.Character
    local humanoid = c and c:FindFirstChildOfClass("Humanoid")
    local root = c and c:FindFirstChild("HumanoidRootPart")
    if not root or not humanoid or humanoid.Health <= 0 then return nil end
    return root, humanoid, c
end

local function sound(parent, key)
    local id = AssetConfig[key]
    if not id or id == 0 then return end
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://" .. tostring(id)
    s.Volume = 0.35
    s.RollOffMaxDistance = 45
    s.Parent = parent
    s:Play()
    Debris:AddItem(s, 4)
end

local function popup(root, text, color, duration)
    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.fromOffset(240, 80)
    gui.StudsOffsetWorldSpace = Vector3.new(0, 4.2, 0)
    gui.AlwaysOnTop = true
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.2
    label.TextScaled = true
    label.Font = Enum.Font.GothamBlack
    label.Parent = gui
    gui.Parent = root
    TweenService:Create(gui, TweenInfo.new(math.min(duration, 1.4)), {
        StudsOffsetWorldSpace = Vector3.new(0, 6.3, 0)
    }):Play()
    Debris:AddItem(gui, duration)
end

local function floatingPart(root, shape, size, color, initialOffset, lifetime, material)
    local p = Instance.new("Part")
    p.Shape = shape
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.Material = material or Enum.Material.Neon
    p.Color = color
    p.Size = size
    p.CFrame = CFrame.new(root.Position + initialOffset)
    p.Parent = workspace
    local finalPos = p.Position + Vector3.new(random:NextNumber(-3,3),random:NextNumber(2,6),random:NextNumber(-3,3))
    TweenService:Create(p, TweenInfo.new(lifetime,Enum.EasingStyle.Sine), {
        Position = finalPos, Transparency = 1
    }):Play()
    Debris:AddItem(p, lifetime + 0.1)
    return p
end

function Effects.PlayVisual(id, target, remote)
    local root, humanoid, character = rootOf(target)
    if not root then return false end
    local colors = PALETTE
    local name = id
    if id == "pie" then
        name = "PLOFT!"
        sound(root,"pie")
        popup(root, name, Color3.fromRGB(255,233,170), 2.5)
        for i=1,13 do
            floatingPart(root, Enum.PartType.Ball, Vector3.new(.3,.3,.3), Color3.fromRGB(255,243,213), Vector3.new(random:NextNumber(-1,1),3,random:NextNumber(-1,1)),1.8)
        end
        remote:FireClient(target,"PieImpact",{duration=10})
    elseif id == "confetti" then
        sound(root,"confetti")
        popup(root,"PÁ! CONFETE!", colors[2], 2)
        for i=1,24 do
            floatingPart(root, Enum.PartType.Block, Vector3.new(.18,.28,.06), colors[(i%4)+1], Vector3.new(0,2,0),2.2)
        end
    elseif id == "bigHead" then
        popup(root,"CABEÇÃO!",colors[4],3)
        local scale = humanoid:FindFirstChild("HeadScale")
        if scale and scale:IsA("NumberValue") then
            local original = scale.Value
            scale.Value = math.min(original * 1.75, 2.5)
            task.delay(6, function()
                if scale.Parent then scale.Value = original end
            end)
        else
            local head = character:FindFirstChild("Head")
            if head then
                local balloon = Instance.new("SphereHandleAdornment")
                balloon.Name = "BigHeadEffect"
                balloon.Adornee = head
                balloon.Radius = 1.75
                balloon.Color3 = head.Color
                balloon.Transparency = 0.25
                balloon.Parent = head
                Debris:AddItem(balloon,6)
            end
        end
    elseif id == "spaghettiRain" or id == "cheeseRain" then
        popup(root,id == "spaghettiRain" and "CHUVA DE MASSA!" or "QUEIJO!",colors[1],2)
        for i=1,18 do
            local isPasta = id == "spaghettiRain"
            floatingPart(root,Enum.PartType.Block, isPasta and Vector3.new(.12,2,.12) or Vector3.new(.55,.55,.55),
                isPasta and Color3.fromRGB(248,221,114) or Color3.fromRGB(255,188,58),
                Vector3.new(random:NextNumber(-2.5,2.5),random:NextNumber(5,8),random:NextNumber(-2,2)),2.3)
        end
    elseif id == "musicalPot" then
        popup(root,"♫ PIM PAM POM ♫",colors[3],3)
        for i=1,10 do
            floatingPart(root,Enum.PartType.Ball,Vector3.new(.22,.22,.22),colors[(i%4)+1],Vector3.new(0,2,0),1.3)
        end
    elseif id == "flour" then
        popup(root,"POOF! FARINHA!", Color3.new(1,1,1),2)
        for i=1,20 do
            floatingPart(root,Enum.PartType.Ball,Vector3.new(.55,.55,.55),Color3.fromRGB(244,241,226),Vector3.new(0,2.5,0),2.5,Enum.Material.SmoothPlastic)
        end
    elseif id == "ketchup" then
        popup(root,"BIGODE DE KETCHUP",colors[2],3)
        local head = character:FindFirstChild("Head")
        if head then
            local gui = Instance.new("BillboardGui")
            gui.Name = "KetchupMustache"
            gui.Adornee = head
            gui.Size = UDim2.fromOffset(90,45)
            gui.StudsOffsetWorldSpace = Vector3.new(0,-.18,.55)
            gui.AlwaysOnTop = false
            local label = Instance.new("TextLabel")
            label.Size = UDim2.fromScale(1,1)
            label.BackgroundTransparency = 1
            label.Text = "〰"
            label.TextScaled = true
            label.TextColor3 = Color3.fromRGB(198,42,50)
            label.Font = Enum.Font.GothamBlack
            label.Parent = gui
            gui.Parent = head
            Debris:AddItem(gui,8)
        end
    elseif id == "duck" then
        popup(root,"QUACK QUACK!",colors[1],2)
        sound(root,"duck")
        for i=1,8 do
            floatingPart(root,Enum.PartType.Ball,Vector3.new(.45,.45,.45),colors[1],Vector3.new(math.sin(i)*2,1,math.cos(i)*2),1.9)
        end
    elseif id == "floatingPizza" then
        popup(root,"PIZZA VOADORA!",colors[2],2.5)
        local pizza = floatingPart(root,Enum.PartType.Cylinder,Vector3.new(.4,3.4,3.4),Color3.fromRGB(244,165,49),Vector3.new(0,5,0),6,Enum.Material.SmoothPlastic)
        pizza.CFrame *= CFrame.Angles(0,0,math.pi/2)
    elseif id == "sadTrombone" then
        sound(root,"sadTrombone")
        popup(root,"WAA WAA WAA...",colors[4],3)
        for i=1,7 do
            floatingPart(root,Enum.PartType.Ball,Vector3.new(.25,.25,.25),colors[i%4+1],Vector3.new(random:NextNumber(-2,2),2,0),2)
        end
    elseif id == "bubbles" then
        popup(root,"BLUP BLUP!",colors[3],2.5)
        for i=1,25 do
            floatingPart(root,Enum.PartType.Ball,Vector3.new(.3,.3,.3),colors[3],Vector3.new(random:NextNumber(-2,2),random:NextNumber(0,3),random:NextNumber(-2,2)),2.4)
        end
    else
        return false
    end
    return true
end

local activeTransforms = {}
function Effects.CancelTransform(player)
    local previous = activeTransforms[player.UserId]
    if not previous then return end
    activeTransforms[player.UserId] = nil
    local root = previous.root
    local humanoid = previous.humanoid
    if root and root.Parent then
        root.CFrame = CFrame.new(previous.position) * previous.orientation
        root.Anchored = previous.anchored
    end
    if humanoid and humanoid.Parent then humanoid.AutoRotate = previous.autoRotate end
end

function Effects.Transform(id, target, remote)
    local root, humanoid = rootOf(target)
    if not root or activeTransforms[target.UserId] then return false end
    local previous = {
        root=root, humanoid=humanoid, anchored=root.Anchored,
        autoRotate=humanoid.AutoRotate, position=root.Position, orientation=root.CFrame.Rotation
    }
    activeTransforms[target.UserId] = previous
    root.Anchored = true
    humanoid.AutoRotate = false
    local seconds = id == "banana" and 2 or 5
    sound(root,id)
    popup(root,id == "banana" and "ESCORREGOU!" or "DE CABEÇA PRA BAIXO!",Color3.fromRGB(255,216,91),1.9)
    remote:FireClient(target,"Shake",{duration=0.4})
    task.spawn(function()
        local start = os.clock()
        while activeTransforms[target.UserId] == previous and os.clock() - start < seconds do
            if not root.Parent or not humanoid.Parent or humanoid.Health <= 0 then break end
            local t = math.clamp((os.clock()-start)/seconds,0,1)
            if id == "banana" then
                root.CFrame = CFrame.new(previous.position) * previous.orientation * CFrame.Angles(0,t*math.pi*4,0)
            else
                local elevation = math.sin(t * math.pi) * 4
                local angle = math.sin(t*math.pi) * math.pi
                root.CFrame = CFrame.new(previous.position+Vector3.new(0,elevation,0)) * previous.orientation * CFrame.Angles(angle,0,0)
            end
            RunService.Heartbeat:Wait()
        end
        if activeTransforms[target.UserId] == previous then Effects.CancelTransform(target) end
    end)
    return true
end

function Effects.ThrowPie(source, target)
    local origin = rootOf(source)
    local dest = rootOf(target)
    if not origin or not dest then return false end
    local pie = Instance.new("Part")
    pie.Name = "CartoonPieProjectile"
    pie.Shape = Enum.PartType.Cylinder
    pie.Size = Vector3.new(.5,1.6,1.6)
    pie.Color = Color3.fromRGB(229,166,102)
    pie.Material = Enum.Material.SmoothPlastic
    pie.Anchored = true
    pie.CanCollide = false
    pie.CanTouch = false
    pie.CFrame = CFrame.new(origin.Position + Vector3.new(0,2,0)) * CFrame.Angles(0,0,math.pi/2)
    pie.Parent = workspace
    local start = pie.Position
    task.spawn(function()
        local beginning = os.clock()
        while pie.Parent and os.clock() - beginning < 0.45 do
            if not dest.Parent then break end
            local t = math.clamp((os.clock()-beginning)/0.45,0,1)
            local finish = dest.Position + Vector3.new(0,1.5,0)
            local curve = Vector3.new(0, math.sin(t*math.pi)*3.0, 0)
            pie.Position = start:Lerp(finish,t) + curve
            RunService.Heartbeat:Wait()
        end
        pie:Destroy()
    end)
    return true
end

function Effects.SpawnBanana(position, source, onTouch)
    local banana = Instance.new("Part")
    banana.Name = "BananaTrap_"..tostring(source.UserId)
    banana.Size = Vector3.new(1.8,.25,1.3)
    banana.Color = Color3.fromRGB(255,232,62)
    banana.Material = Enum.Material.SmoothPlastic
    banana.Anchored = true
    banana.CanCollide = false
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {source.Character}
    local hit = workspace:Raycast(position+Vector3.new(0,4,0),Vector3.new(0,-18,0),rayParams)
    if not hit then return false end
    banana.Position = hit.Position + Vector3.new(0,.18,0)
    banana.Parent = workspace
    local used = false
    banana.Touched:Connect(function(hit)
        if used then return end
        local player = game:GetService("Players"):GetPlayerFromCharacter(hit.Parent)
        if not player or player == source then return end
        if onTouch(player) then
            used = true
            banana:Destroy()
        end
    end)
    Debris:AddItem(banana,25)
    return true
end

return Effects
