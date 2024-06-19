local Twitch = require"Twitch"
local cqueues = require"cqueues"
return function(SharedData)
	return function()
		while true do
			cqueues.sleep(60*60)
			local TokenState = Twitch.API.ValidateAccessToken()
			if TokenState == Twitch.API.TokenStatus.Cancelled then
				os.exit()
			elseif TokenState == Twitch.API.TokenStatus.Expired then
				Twitch.API.RefreshTokens()
			end
		end
	end
end
