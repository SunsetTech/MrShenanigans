local IRC; IRC = {
	PRIVMSG = function(Destination,Message)
		return string.format("PRIVMSG %s :%s\n",Destination,Message)
	end
} return IRC
