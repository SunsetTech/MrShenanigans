local ffi = require"ffi"
ffi.cdef[[
	struct {
		int Width, Height;
		float Data[?];
	}
]]

return ffi.metatype
