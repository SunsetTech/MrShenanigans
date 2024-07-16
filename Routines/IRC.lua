local cqueues = require"cqueues"
cqueues.errno = require"cqueues.errno"
cqueues.socket = require"cqueues.socket"
local lpeg = require"lpeg"
local IRCGrammar = require"Grammars.IRC":Decompose():Decompose()
local IRC = require"IRC"
local Twitch = require"Twitch"

return function(SharedData)
	local CompiledCommandsGrammar = require"Commands"(SharedData)
	return function()
		local Stop = false
		local Tries = 0
		repeat
			Tries = Tries + 1
			print"Checking twitch tokens validity"
			local TokenCurrentStatus = Twitch.API.ValidateAccessToken()
			if TokenCurrentStatus ~= Twitch.API.TokenStatus.Valid then
				print"Refreshing twitch tokens"
				Twitch.API.RefreshTokens()
			end
			
			print"Connecting to twitch IRC"
			local Connection = cqueues.socket.connect("irc.chat.twitch.tv", 6697)
			Connection:starttls()
			Connection:connect()
			Connection:write("CAP REQ :twitch.tv/membership twitch.tv/commands twitch.tv/tags\r\n")
			Connection:write(("PASS oauth:%s\r\n"):format(SharedData.Config.Twitch.Tokens.Access))
			Connection:write(("NICK %s\r\n"):format(SharedData.Config.Twitch.Name))
			Connection:write(("JOIN #%s\r\n"):format(SharedData.Config.Twitch.Channel))
			
			local Output
			repeat
				Output, Error = Connection:read"*l"
				if (not Output) then
					local r,w = Connection:error()
					print(r, cqueues.errno[r], w, cqueues.errno[w])
					r,w = Connection:eof()
					print(r, cqueues.errno[r], w, cqueues.errno[w])
				else
					print(Output)
					local Event = lpeg.match(IRCGrammar, Output)
					if (Event) then
						local Tags = {}
						
						if Event.Tags and type(Event.Tags) == "table" then
							for _, Tag in pairs(Event.Tags) do
								Tags[Tag.Key] = Tag.Value
							end
							Event.Tags = Tags
						end
						
						if Event.Prefix and Event.Prefix.Nick then
							SharedData.UserIDMap[Event.Prefix.Nick:lower()] = Tags["user-id"]
						end
						
						if (Tags["user-id"] ~= nil and Tags.bits ~= nil) then
							local UserID, Bits = tonumber(Tags["user-id"]), tonumber(Tags.bits)
							local CommandPointsToCredit = Bits*69
							local NewTotal = SharedData.Database:AddPoints(UserID, CommandPointsToCredit)
							local Response = IRC.PRIVMSG("#".. SharedData.Config.Twitch.Channel, "Thanks for the ".. tostring(Bits) .." bit(s)! You have been credited ".. CommandPointsToCredit .." Shenanigans Points! Your total is now ".. NewTotal)
							Connection:write(Response)
						end
						
						if (Tags["custom-reward-id"] == "452d889c-42b2-4167-b7d5-fb374c0d9cad") then
							local UserID = tonumber(Tags["user-id"])
							local CommandPointsToCredit = 1000
							local NewTotal = SharedData.Database:AddPoints(UserID, CommandPointsToCredit)
							local Response = IRC.PRIVMSG("#".. SharedData.Config.Twitch.Channel, "Thanks for the redeem! You have been credited ".. CommandPointsToCredit .." Shenanigans Points! Your total is now ".. NewTotal)
							Connection:write(Response)
						end
						
						if (Event.Command == "PING") then
							Connection:write(("PONG :%s\r\n"):format(Event.Trailing))
						elseif (Event.Command == "PRIVMSG") then
							local CommandString = Event.Trailing
							local Execute, Parameters, CostFunction = lpeg.match(CompiledCommandsGrammar, CommandString)
							if Execute then
								if CostFunction then
									local RequiredPoints = CostFunction(Parameters)
									local Total = SharedData.Database:GetPoints(Tags["user-id"])
									if Event.Prefix.Host[1] == "bigtrashking" or Tags["user-type"] == "mod" then
										print"Free execution"
										Execute(Connection, Event, Parameters)
									elseif RequiredPoints > Total then
										Connection:write(IRC.PRIVMSG(Event.Params[1], "You dont have enough Shenanigans Points to do that") )
									else
										SharedData.Database:AddPoints(Tags["user-id"], -RequiredPoints)
										Execute(Connection, Event, Parameters)
									end
								else
									Execute(Connection, Event, Parameters)
								end
							end
						end
					end
				end
			until not Output
		until Stop or Tries == 5
	end
end
