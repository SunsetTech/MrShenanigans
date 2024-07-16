local ffi = require"ffi"
local Vector3 = require"Math.cglm.Vector3"
local OOP = require"Moonrise.OOP"

---@class MrShenanigans.Pool.cglm.Vector3Pool
---@overload fun(): MrShenanigans.Pool.cglm.Vector3Pool
---@diagnostic disable-next-line: assign-type-mismatch
local Vector3Pool = OOP.Declarator.Shortcuts(
	"MrShenanigans.Pool.cglm.Vector3", {
		require"Pool.CData"
	}
)

function Vector3Pool:Create()
	return Vector3()
end

function Vector3Pool:Prepare(Instance)
	ffi.fill(Instance.Data, ffi.sizeof"vec3")
end

---@return MrShenanigans.Math.cglm.Vector3
function Vector3Pool:Obtain()
	---@diagnostic disable-next-line:undefined-field
	return Vector3Pool.Parents.CData.Obtain(self)
end

return Vector3Pool
