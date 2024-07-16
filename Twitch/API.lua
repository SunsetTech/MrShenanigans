local dkjson = require"dkjson"
local http = {
	request = require"http.request";
	util = require"http.util";
}
local TwitchConfig = require"Config.Twitch"
local Utils = require"Utils"

local API; API = {
	TokenStatus = {
		Valid = 1;
		Expired = 2;
		Cancelled = 3;
	};

	ValidateAccessToken = function()
		print"Validating access token"
		local ValidateRequest = http.request.new_from_uri"https://id.twitch.tv/oauth2/validate"
		local AuthHeaderValue = ("OAuth %s"):format(TwitchConfig.Tokens.Access):gsub("\n","")
		ValidateRequest.headers:upsert( "authorization", AuthHeaderValue)
		ValidateRequest.tls = true
		local ValidateResponseHeaders, ValidateResponseStream = ValidateRequest:go(10)
		local ValidateResponseBody = ValidateResponseStream:get_body_as_string()
		local ValidateResponseObject = dkjson.decode(ValidateResponseBody)
		assert(ValidateResponseObject)
		if tonumber(ValidateResponseObject.status) == 401 then
			if tonumber(TwitchConfig.Tokens.ExpiryTime) > os.time() then
				return API.TokenStatus.Cancelled
			else
				return API.TokenStatus.Expired
			end
		else
			return API.TokenStatus.Valid
		end
	end;

	RefreshTokens = function()
		print"Refreshing access token"
		local RefreshRequest = http.request.new_from_uri("https://id.twitch.tv/oauth2/token")
		
		RefreshRequest.headers:upsert(":method","POST")
		RefreshRequest.tls = true
		RefreshRequest:set_body(
			http.util.dict_to_query{
				client_id = TwitchConfig.ClientID;
				client_secret = TwitchConfig.Secret;
				grant_type = "refresh_token";
				refresh_token = TwitchConfig.Tokens.Refresh;
			}
		)
		
		local RefreshResponseHeaders, RefreshResponseStream = RefreshRequest:go()
		local RefreshResponseBody = RefreshResponseStream:get_body_as_string()
		local RefreshResponseObject = dkjson.decode(RefreshResponseBody)
		assert(RefreshResponseObject and RefreshResponseObject.error == nil, "Failed refresh")
		
		TwitchConfig.Tokens.Access = RefreshResponseObject.access_token
		TwitchConfig.Tokens.Refresh = RefreshResponseObject.refresh_token
		TwitchConfig.Tokens.ExpiryTime = os.time()+RefreshResponseObject.expires_in
		
		--[[local AccessTokenFile = io.open("Config/Twitch/Tokens/Access", "w+")
		local RefreshTokenFile = io.open("Config/Twitch/Tokens/Refresh", "w+")
		local ExpiryTimeFile = io.open("Config/Twitch/Tokens/ExpiryTime", "w+")
		assert(AccessTokenFile and RefreshTokenFile and ExpiryTimeFile)
		
		AccessTokenFile:write(TwitchConfig.Tokens.Access)
		RefreshTokenFile:write(TwitchConfig.Tokens.Refresh)
		ExpiryTimeFile:write(TwitchConfig.Tokens.ExpiryTime)]]
		Utils.WriteSecret("Twitch/Tokens/Access", TwitchConfig.Tokens.Access)
		Utils.WriteSecret("Twitch/Tokens/Refresh", TwitchConfig.Tokens.Refresh)
		Utils.WriteSecret("Twitch/Tokens/ExpiryTime", TwitchConfig.Tokens.ExpiryTime)
		end;
}; return API;
