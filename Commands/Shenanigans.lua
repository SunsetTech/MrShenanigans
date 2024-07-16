local Utils = require"Utils"
local P = require"OOPEG.Nested.PEG"

local OBS = require"OBS"

return function(SharedData)
	local Shenanigans; Shenanigans = {
		video = {
			---@param Parameters {Name: string}
			Execute = function(_,_,Parameters)
				local Connection = OBS.Connection(
					"192.168.1.69", 
					SharedData.Config.OBS.Password, 
					SharedData.Config.OBS.Port
				)
				Connection:Request(
					"TriggerMediaInputAction", {
						inputName = Parameters.Name:lower();
						mediaAction = "OBS_WEBSOCKET_MEDIA_INPUT_ACTION_RESTART";
					}
				)
			end;
			Help = "Play a video. see !videolist";
			CostFunction = function(Parameters)
				return 100
			end;
			Grammar = P.Group(P.Variable.Canonical"Trailing", "Name");
			Defaults = {
				Name = "Nice";
			};
		};
		randombuddy = {
			Execute = function(_,_,Parameters)
				for i = 1, Parameters.Amount do
					table.insert(
						SharedData.Buddies, {
							X = math.random(0,1920);
							Y = math.random(0,1080);
							Scale = math.random(50,100)/100;
							DieAt = Utils.GetTime() + math.random(3,7);
							Texture = SharedData.Textures[math.random(1, #SharedData.Textures)];
						}
					)
				end
			end;
			Help = "Adds random buddies somewhere to the screen I game on for 3~7 seconds";
			CostFunction = function(Parameters)
				return Parameters.Amount * 1
			end;
			Grammar = P.Group(
				P.Variable.Canonical"Integer",
				"Amount"
			);
			Defaults = {
				Amount = 1;
			};
		};
		cheapspeak = {
			Execute = function(Connection, Event, Parameters)
				local espeak = io.popen("espeak", "w")
				assert(espeak)
				espeak:write(Parameters.Message)
				espeak:close()
			end;
			Help = "cheap espeak tts. no delay. no cooldown.";
			CostFunction = function(Parameters)
				return 1 * #Parameters.Message;
			end;
			Defaults = {
				Message = "I forgot my message";
			};
			Grammar = P.Group(P.Variable.Canonical"Trailing", "Message");
		};
		--[[hammertoss = {
			Execute = function(Connection, Event, Parameters)
				local VelX, VelY, VelZ = Utils.Calculate3DVelocity(Parameters.AngleTwo, Parameters.AngleOne/10, 500)
				table.insert(
					SharedData.Hammers, {
						Position = {1920/2, 1080, 0};
						Velocity = {-VelX, -VelY, -VelZ};
					}
				)
			end;
			CostFunction = function(Parameters)
				return 100;
			end;
			Help = "Throw a hammer at the screen.";
			Grammar = P.Sequence{
				P.Group(P.Variable.Canonical"Integer", "AngleOne");
				P.Atleast(1,P.Pattern" ");
				P.Group(P.Variable.Canonical"Integer", "AngleTwo");
			};
			Defaults = {
				AngleOne = 90;
				AngleTwo = 90;
			};
		};]]
		flashbang = {
			Execute = function(Connection, Event, Parameters)
				SharedData.FlashbangEnd = Utils.GetTime()+Parameters.Length
			end;
			CostFunction = function(Parameters)
				return Parameters.Length * 100
			end;
			Grammar = P.Group(
				P.Variable.Canonical"Integer",
				"Length"
			);
			Defaults = {
				Length = 1;
			};
			Help = "Flashbang the streamer and viewers.";
		};
		bsod = {
			Execute = function(Connection, Event, Parameters)
				SharedData.BSODEnd = Utils.GetTime()+Parameters.Length
			end;
			CostFunction = function(Parameters)
				return Parameters.Length * 100
			end;
			Grammar = P.Group(
				P.Variable.Canonical"Integer",
				"Length"
			);
			Defaults = {
				Length = 1;
			};
			Help = "Displays Windows BSOD, on a Linux machine??";
		};
		panic = {
			Execute = function(Connection, Event, Parameters)
				SharedData.PanicEnd = Utils.GetTime()+Parameters.Length
			end;
			CostFunction = function(Parameters)
				return Parameters.Length * 100
			end;
			Grammar = P.Group(
				P.Variable.Canonical"Integer",
				"Length"
			);
			Defaults = {
				Length = 1;
			};
			Help = "Displays a kernel panic D:";
		};
		xflip = {
			Execute = function(Connection, Event, Parameters)
				SharedData.XFlipEnd = Utils.GetTime()+Parameters.Length
			end;
			CostFunction = function(Parameters)
				return Parameters.Length * 100
			end;
			Grammar = P.Group(
				P.Variable.Canonical"Integer",
				"Length"
			);
			Defaults = {
				Length = 1;
			};
			Help = "Flips the X axis of the game";
		};
		yflip = {
			Execute = function(Connection, Event, Parameters)
				SharedData.YFlipEnd = Utils.GetTime()+Parameters.Length
			end;
			CostFunction = function(Parameters)
				return Parameters.Length * 100
			end;
			Grammar = P.Group(
				P.Variable.Canonical"Integer",
				"Length"
			);
			Defaults = {
				Length = 1;
			};
			Help = "Displays a kernel panic D:";
		};
		
	}; SharedData.Shenanigans = Shenanigans; return Shenanigans
end
