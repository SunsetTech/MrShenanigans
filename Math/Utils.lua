local Utils; Utils = {
	Calculate3DVelocity = function(horizontalAngle, verticalAngle, force)
		-- Convert angles from degrees to radians
		horizontalAngle = math.rad(horizontalAngle)
		verticalAngle = math.rad(verticalAngle)

		-- Calculate X, Y, and Z components of velocity
		local vx = force * math.cos(verticalAngle) * math.cos(horizontalAngle)
		local vy = force * math.cos(verticalAngle) * math.sin(horizontalAngle)
		local vz = force * math.sin(verticalAngle)

		return vx, vy, vz
	end
}; return Utils;
