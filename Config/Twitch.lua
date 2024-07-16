local Utils = require"Utils"

local Config  = {
	Tokens = {
		Access = Utils.ReadSecret"Twitch/Tokens/Access";
		Refresh = Utils.ReadSecret"Twitch/Tokens/Refresh";
		ExpiryTime = Utils.ReadSecret"Twitch/Tokens/ExpiryTime";
	};
	Name = "bigtrashking";
	Channel = "bigtrashking";
	ID = "90908566";
	Secret = Utils.ReadSecret"Twitch/Secret"; 
	ClientID = Utils.ReadSecret"Twitch/ClientID";
}

return Config
