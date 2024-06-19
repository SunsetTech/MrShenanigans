local OOP = require"Moonrise.OOP"

local StaticImage = OOP.Declarator.Shortcuts"MrShenanigans.StaticImage"

function StaticImage:Initialize(Instance, Data, Width, Height)
	Instance.Data = Data
	Instance.Width = Width
	Instance.Height = Height
end

return StaticImage
