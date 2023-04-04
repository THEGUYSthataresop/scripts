local TS = game:GetService("TweenService")

local player = game.Players.LocalPlayer
local cameraShaker = require(game.ReplicatedStorage.CameraShaker).new(200, function(ShakeCFrame)
    workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * ShakeCFrame
end)

local blacklist = {"Key", "ElectricalKey", "KeyElectrical", "LibraryHintPaper"}

local tool = game:GetObjects("rbxassetid://12968206761")[1]
local rift = game:GetObjects("rbxassetid://12963352166")[1]
rift.Center.ItemHolder.Item.Texture = "rbxassetid://0"

local riftedTool
if workspace:FindFirstChild("RiftedTool") then
    riftedTool = workspace:FindFirstChild("RiftedTool")
    if riftedTool.Value ~= nil then
        rift.Center.ItemHolder.Item.Texture = riftedTool.Value.TextureId
    end
else
    riftedTool = Instance.new("ObjectValue")
    riftedTool.Name = "RiftedTool"
    riftedTool.Parent = workspace
end

tool.Parent = player.Backpack
rift.Parent = workspace
rift:PivotTo(CFrame.new(0, 5000, 0))

tool.Activated:Connect(function()
    local animTrack = player.Character.Humanoid:LoadAnimation(tool.Animations.open)
    animTrack:Play()
    task.wait(0.6)
    tool.Enabled = false
    local handle = tool.Handle
    handle.Parent = workspace
    handle.CanCollide = true
    tool:Destroy()
    handle:ApplyImpulse(workspace.CurrentCamera.CFrame.LookVector * 150 + Vector3.new(0, 50, 0))
    task.wait(1.5)
    local tween = TS:Create(handle, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Transparency = 1})
    tween:Play()
    tween.Completed:Wait()
    for _, part in pairs(handle:GetChildren()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        end
    end
    handle.Anchored = true
    handle.Core.Orientation = Vector3.new(0,0,0)
    handle.Core.Attachment.Attachment.Explosion:Emit(25)
    task.wait(1.75)
    task.spawn(function()
        cameraShaker:Start()
        cameraShaker:ShakeOnce(10, 10, 0.1, 2)
    end)
    rift:PivotTo(handle.CFrame + Vector3.new(0, 4.5, 0))
    for _, particle in pairs(rift.Center.ParticlesOut:GetChildren()) do
            particle:Emit(1)
        end
    rift.Center.Orientation = Vector3.new(0, 0, 0)
    TS:Create(handle.Core.Bonus, TweenInfo.new(1.25), {Transparency = 1}):Play()
    handle.Core.Attachment.Shiny.Enabled = false
    handle.Core.Attachment.ParticleEmitter.Enabled = false
    task.wait(3.5)
    handle:Destroy()
end)

rift.Center.PromptAttachment.RiftPrompt.Triggered:Connect(function()
    local proceed = true
    
    if _G.ToolBlacklist == true then
        if table.find(blacklist, player.Character:FindFirstChildWhichIsA("Tool").Name) then
            proceed = false
        end
    end
    
    print(proceed)
    if proceed == false then return end
    
    if player.Character:FindFirstChildWhichIsA("Tool") or riftedTool.Value ~= nil then
        for _, particle in pairs(rift.Center.ParticlesOut:GetChildren()) do
            particle:Emit(1)
        end
    end
    
    if riftedTool.Value ~= nil then
        riftedTool.Value.Parent = player.Backpack
        riftedTool.Value = nil
        
        --[[if player.Character:FindFirstChildWhichIsA("Tool") then
            riftedTool.Value = player.Character:FindFirstChildWhichIsA("Tool")
            player.Character.Humanoid:UnequipTools()
            riftedTool.Parent = game.ReplicatedStorage
        end]]
    else
        if player.Character:FindFirstChildWhichIsA("Tool") then
            riftedTool.Value = player.Character:FindFirstChildWhichIsA("Tool")
            player.Character.Humanoid:UnequipTools()
            riftedTool.Value.Parent = game.ReplicatedStorage
        end
    end
end)

riftedTool.Changed:Connect(function()
    if riftedTool.Value ~= nil then
        rift.Center.ItemHolder.Item.Texture = riftedTool.Value.TextureId
    else
        rift.Center.ItemHolder.Item.Texture = "rbxassetid://0"
    end
end)
