local ffi = require"ffi"
local Matrix4 = require"Math.cglm.Matrix4"
local OOP = require"Moonrise.OOP"

---@class MrShenanigans.Pool.cglm.Matrix4Pool
---@overload fun(): MrShenanigans.Pool.cglm.Matrix4Pool
---@diagnostic disable-next-line: assign-type-mismatch
local Matrix4Pool = OOP.Declarator.Shortcuts(
	"MrShenanigans.Pool.cglm.Matrix4", {
		require"Pool.CData"
	}
)

function Matrix4Pool:Create()
	return Matrix4()
end

function Matrix4Pool:Prepare(Instance)
	ffi.fill(Instance.Data, ffi.sizeof"mat4")
end

---@return MrShenanigans.Math.cglm.Matrix4
function Matrix4Pool:Obtain()
	---@diagnostic disable-next-line:undefined-field
	return Matrix4Pool.Parents.CData.Obtain(self)
end

return Matrix4Pool
