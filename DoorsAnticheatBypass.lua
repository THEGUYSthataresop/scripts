--[[
GREG
HEFFLEY
MADE
THIS
SCRIPT
YEYYY
]]





local player = game.Players.LocalPlayer
local HRP = player.Character:WaitForChild("HumanoidRootPart")

if true then
  state = HRP.Parent.Humanoid:GetState()
end

if state then
  print("Success")
end

for i = 1, 2 do
  game.GuiService:ToggleFullscreen()
end
