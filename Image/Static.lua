local OOP = require"Moonrise.OOP"

local Static = OOP.Declarator.Shortcuts"MrShenanigans.Image.Static"

function Static:Initialize(Instance, Data, Width, Height)
	Instance.Data = Data
	Instance.Width = Width
	Instance.Height = Height
end

return Static
