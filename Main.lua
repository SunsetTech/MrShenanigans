table.unpack = unpack or table.unpack
package.path = package.path ..";./?/init.lua"
local cqueues = require"cqueues"
cqueues.errno = require"cqueues.errno"
cqueues.socket = require"cqueues.socket"
local posix = require"posix"

local DataManager = require"DataManager"
local Routines = require"Routines"
local Utils = require "Utils"

local Config = require"Config"
local RoutinePool = cqueues.new();

---@class MrShenanigans.SharedData
local SharedData = {
	Database = DataManager"Data/Bot.db";
	Config = Config;
	RoutinePool = RoutinePool;
	UserIDMap = {};
	Buddies = {};
	Hammers = {};
	Textures = {};
	TTSCooledDown = true;
	ScamTTS = false;
	FlashbangEnd = 0;
	BSODEnd = 0;
	PanicEnd = 0;
	XFlipEnd = 0;
	YFlipEnd = 0;
	RenderOverlay = false;
}

RoutinePool:wrap(Routines.IRC(SharedData))
RoutinePool:wrap(Routines.TokenManager(SharedData))
RoutinePool:wrap(Routines.Overlay(SharedData))

local function MainLoop()
	print"Stopping automatic GC"
	collectgarbage"stop"
	while true do
		local Start = Utils.GetTime()
		assert(RoutinePool:step(0))
		collectgarbage"collect"
		local Elapsed = Utils.GetTime() - Start
		--[[if 1/Elapsed < 60 then
			print("Slow internal FPS detected", 1/Elapsed)
		end]]
		posix.nanosleep(0, math.max((1/60-Elapsed)*1e9, 0))
	end
end

print(pcall(MainLoop))

io.popen("vlc -I dummy ./Assets/Fail.opus --play-and-exit", "r")
