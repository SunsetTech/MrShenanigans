local OOP = require"Moonrise.OOP"
local Frame = require"Frame"

local AnimatedImage = OOP.Declarator.Shortcuts"MrShenanigans.AnimatedImage"

function AnimatedImage:Initialize(Instance, Width, Height)
	Instance.Frames = {}
	Instance.Width = Width
	Instance.Height = Height
end

function AnimatedImage:AddFrame(Data, Timestamp)
	table.insert(self.Frames, Frame(Data, Timestamp))
end

return AnimatedImage
