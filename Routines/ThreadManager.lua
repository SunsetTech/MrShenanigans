local lanes = require"lanes"
local cqueues = require"cqueues"
return function(ThreadsToLaunch)
	local Threads = {}
	for Name, ThreadToLaunch in pairs(ThreadsToLaunch) do
		Threads[Name] = lanes.gen("*", ThreadToLaunch)()
	end
	return function()
		while true do
			for Name, Thread in pairs(Threads) do
				if Thread.status == "error" then
					print("Error in ".. Name .." thread")
					print(Thread[1])
				end
			end
			cqueues.sleep(0)
		end
	end
end
