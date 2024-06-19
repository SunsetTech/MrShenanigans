function HackPack(...) --returns nil if no arguments, otherwise returns packed arguments
	local Packed = {...}
	if (#Packed > 0) then
		return Packed
	end
end

local IRC = {}

function IRC.ParseLine(Line) --this needs to suck less
	local MethodAResults = HackPack(string.match(Line,"^:(%S+)%s?(%S+)%s?([^:]*)%s:?(.*)"))
	local MethodBResults = HackPack(string.match(Line,"(%z?)(%S+)%s?(%S-):(.+)"))
	local From, Event, ArgString, Trailing = unpack(MethodAResults or MethodBResults)
	Trailing = string.gsub(Trailing,"%s+$","") -- strip trailing spaces
	local Args = {}
	for Arg in string.gmatch(ArgString,"(%S+)") do
		table.insert(Args,Arg)
	end
	return {
		From = From,
		Event = Event,
		Args = Args,
		Trailing = Trailing
	}
end

function IRC.ParseHostmask(Hostmask)
	local Nick, Ident, Host = string.match(Hostmask,"([^!]*)!?([^@]*)@?(.*)")
	return {
		Nick = Nick,
		Ident = Ident,
		Host = Host
	}
end

function IRC.BuildCommand(Command,Args,Trailing)
	local CommandString = string.upper(Command)
	if (Args) then
		CommandString = CommandString .." ".. table.concat(Args," ")
	end
	if (Trailing) then
		CommandString = CommandString .." :".. Trailing
	end
	return CommandString
end

function IRC.PRIVMSG(Destination,Message)
	return string.format([[PRIVMSG %s :%s]],Destination,Message)
end

return IRC
