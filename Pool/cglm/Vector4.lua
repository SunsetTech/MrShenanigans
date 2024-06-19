local ffi = require"ffi"
local Vector4 = require"Math.cglm.Vector4"
local OOP = require"Moonrise.OOP"

---@class MrShenanigans.Pool.cglm.Vector4Pool
---@overload fun(): MrShenanigans.Pool.cglm.Vector4Pool
---@diagnostic disable-next-line: assign-type-mismatch
local Vector4Pool = OOP.Declarator.Shortcuts(
	"MrShenanigans.Pool.cglm.Vector4", {
		require"Pool.CData"
	}
)

function Vector4Pool:Create()
	return Vector4()
end

function Vector4Pool:Prepare(Instance)
	ffi.fill(Instance.Data, ffi.sizeof"vec4")
end

---@return MrShenanigans.Math.cglm.Vector4
function Vector4Pool:Obtain()
	---@diagnostic disable-next-line:undefined-field
	return Vector4Pool.Parents.CData.Obtain(self)
end

return Vector4Pool
