local OOPEG = require"OOPEG"
local P = OOPEG.Nested.PEG

local Range, UTF8Range, Sequence, Optional, Pattern, Jump, Select, Dematch, Set, Atleast, All, Atmost, Debug, Not, Behind, Table, Group, Capture = P.Range, P.UTF8Range, P.Sequence, P.Optional, P.Pattern, P.Variable.Canonical, P.Select, P.Dematch, P.Set, P.Atleast, P.All, P.Atmost, P.Debug, P.Not, P.Behind, P.Table, P.Group, P.Capture;

return OOPEG.Nested.Grammar{
	[1] = Jump"Message";
	Letter = Range("az","AZ");
	Number = Range"09";
	Domain = OOPEG.Nested.Grammar{
		Table(Jump"Domain.HName");
		Name = Capture(Sequence{
			Jump"Letter",
			Optional(
				Sequence{
					All(
						Select{
							Jump"Letter";
							Jump"Number";
							Jump"Special";
						}
					),
					Not(
						Behind(
							Select{
								Jump"Letter";
								Jump"Number";
							}
						)
					)
				}
			);
		});
		HName = Sequence{
			Jump"Domain.Name";
			Atleast(
				1, Sequence{
					Pattern".";
					Jump"Domain.Name";
				}
			)
		};
	};
	Host = Select{Jump"Address", Jump"Domain"};
	ServerName = Jump"Host";
	Prefix = Select{
		Jump"ServerName";
		Table(Sequence{
			Group(Jump"Nick", "Nick");
			Group(Sequence{Pattern"!", Jump"Ident"}, "Ident");
			Group(Sequence{Pattern"@", Jump"Host"}, "Host");
		});
	};
	Command = Select{
		Atleast(1, Jump"Letter");
		Sequence{Jump"Number", Jump"Number", Jump"Number"};
	};
	Space = Atleast(1, Pattern" ");
	Middle = Dematch(
		Atleast(
			1, Dematch(
				Pattern(1),
				Set" \0\r\n"
			)
		),
		Pattern":"
	);
	Params = Table(Sequence{
		Jump"Space";
		Capture(Jump"Middle");
		All(
			Sequence{
				Jump"Space";
				Jump"Middle";
			}
		);
	});
	Trailing = Capture(All(Dematch(Pattern(1), Set"\0\r\n")));
	CRLF = Pattern"\r\n";
	Special = Set[[-_[]\`^{}]];
	Nick = Dematch(
		Atleast(
			1, Select{
				Jump"Letter", 
				Jump"Number", 
				Jump"Special"
			}
		),
		Select{
			Jump"Number",
			Jump"Special"
		}
	);
	NonBlank = Set" \0\r\n";
	Ident = Capture(Atleast(1, Dematch(Pattern(1), Select{Pattern"@", Jump"NonBlank"})));
	Octet = Sequence{Jump"Number", Atmost(2, Jump"Number")};
	IPv4 = Sequence{Jump"Octet", Pattern".", Jump"Octet", Pattern".", Jump"Octet", Pattern".", Jump"Octet"};
	Address = Jump"IPv4";
	UTF8Char = UTF8Range(0,0x10FFFF);
	EscapeSequence = Sequence{
		Pattern[[\]];
		Select{
			Set[[:s\rn]];
			Jump"UTF8Char";
		};
	};
	EscapedValue = All(
		Dematch(
			Select{
				Jump"EscapeSequence";
				Jump"UTF8Char";
			},
			Set"\0\r\n; "
		)
	);
	ClientPrefix = Pattern"+";
	Vendor = Jump"Host";
	KeyName = Atleast(1, Select{Jump"Letter", Jump"Number", Pattern"-"});
	Key = Sequence{
		Optional(Jump"ClientPrefix"),
		Optional(Sequence{Jump"Vendor", Pattern"/"}),
		Jump"KeyName";
	};
	Tag = Table(Sequence{
		Group(Jump"Key", "Key");
		Group(Optional(
			Sequence{
				Pattern"=";
				Capture(Jump"EscapedValue");
			}
		), "Value")
	});
	Tags = Table(Sequence{
		Jump"Tag";
		All(
			Sequence{
				Pattern";";
				Jump"Tag"
			}
		)
	});
	Message = Table(Sequence{
		Group(Optional(
			Sequence{
				Pattern"@";
				(Jump"Tags");
				(Jump"Space");
			}
		),"Tags");
		Group(Optional(
			Sequence{Pattern":", Jump"Prefix", Jump"Space"}
		), "Prefix");
		Group(Jump"Command", "Command");
		Group(Optional(Jump"Params"), "Params");
		Group(Optional(Sequence{Jump"Space", Pattern":", (Jump"Trailing")}), "Trailing");
	});
}
