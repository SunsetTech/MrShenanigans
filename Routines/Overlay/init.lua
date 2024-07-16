local bit = require"bit"
local ffi = require"ffi"

local cqueues = require"cqueues"

local X11 = require"X11"
local Xcomposite = require"Xcomposite"

local libndi = require"libndi"

local Rendering = require"Rendering"
local GL = Rendering.GL
local Utils = require "Utils"

local Capture = require"Routines.Overlay.Capture"
local Assets = require"Routines.Overlay.Assets"
local Context = require"Routines.Overlay.Context"
local NDI = require"Routines.Overlay.NDI"
local Window = require"Routines.Overlay.Window"
local Renderer = require"Routines.Overlay.Renderer"

return function(SharedData)
	return function()
		print"Initializing NDI library"
		NDI.Initialize()
		
		print"Creating NDI finder"
		local Finder = NDI.CreateFinder{
			show_local_sources = 1;
			p_groups = nil;
			p_extra_ips = nil;
		}
		 
		NDI.WaitForSources(Finder)
		local Source = NDI.FindSource(Finder, "SATELLITE2 (Web Overlays)")
		local Receiver = NDI.CreateReceiver{
			source_to_connect_to = Source;
			color_format = libndi.Library.NDIlib_recv_color_format_RGBX_RGBA;
			bandwidth = libndi.Library.NDIlib_recv_bandwidth_highest;
			allow_video_fields = false;
			p_ndi_recv_name = nil;
		}
		
		local Synchronizer = NDI.CreateSynchronizer(Receiver)
		
		local Display = X11.XOpenDisplay(nil)
		assert(Display, "Couldn't open display")
		
		local Screen = X11.XDefaultScreen(Display)
		local Root = X11.XDefaultRootWindow(Display)
		local FBConfig, VisualInfo = Window.FindConfig(Display, Screen)
		local XWindow = Window.Create(Display, Root, VisualInfo)
		X11.XMapWindow(Display, XWindow)

		local GLWindow = GL.Lib.glXCreateWindow(Display, FBConfig, XWindow, nil)

		local GLContext = GL.Lib.glXCreateNewContext(Display, FBConfig, GL.Lib.GLX_RGBA_TYPE, nil, 1)
		assert(GLContext, "Couldn't create OpenGL context")

		GL.Lib.glXMakeContextCurrent(Display, GLWindow, GLWindow, GLContext)
		Context.Setup()

		local GameWindowName = arg[1] or error"Provide game window title"
		

		print"Loading textures"
		local Start = Utils.GetTime()
		local Textures, TotalTextures = Assets.LoadTextures()
		print("Loaded ".. TotalTextures .." textures")
		
		print"Creating dynamic textures"
		local GamePixmapAttributes = ffi.new(
			"const int[5]", {
				GL.Lib.GLX_TEXTURE_TARGET_EXT, GL.Lib.GLX_TEXTURE_2D_EXT,
				GL.Lib.GLX_TEXTURE_FORMAT_EXT, GL.Lib.GLX_TEXTURE_FORMAT_RGB_EXT,
				0
			}
		)
		Textures.Game = Capture.CreateTexture()
		Textures.NDISource = NDI.CreateTexture()
		print("Texture loading/creation took ".. Utils.GetTime() - Start .." seconds")
		SharedData.Textures = Textures.Buddies
		
		local RendererInstance = Renderer()
		local LastUpdate = Utils.GetTime()
		local Event = ffi.new"XEvent[1]"
		local GameWindowMapped = false
		while true do
			local CurrentTime = Utils.GetTime()
			local Delta = CurrentTime - LastUpdate
			LastUpdate = CurrentTime

			local ShouldReobtainGameSurface = false
			while (X11.XPending(Display) > 0) do
				X11.XNextEvent(Display, Event)
				if (Event[0].type == 22) then
					print"Game window resized"
					ShouldReobtainGameSurface = true
				elseif (Event[0].type == 17) then
					print"Game window lost"
					--TODO game window disappeared, clean up related objects and wait for it to reappear
					GameWindowMapped = false
					GameWindow = 0
				elseif (Event[0].type == 19) then
					GameWindowMapped = true
				end
			end
			
			local GameSurface
			if not GameWindowMapped then
				GameWindow = Capture.FindWindowByTitle(GameWindowName)
				if GameWindow > 0 then
					print"Found game window"
					print"Redirecting game window to offscreen storage"
					--X11.XSetWMProtocols(Display, GameWindow, wm_delete_window, 1);
					Xcomposite.XCompositeRedirectWindow(Display, GameWindow, Xcomposite.CompositeRedirectAutomatic)
					X11.XSelectInput(Display, GameWindow, bit.lshift(1,17)) --TODO make constant in X11 library
					GameSurface = Capture.ObtainAndBind(Display, FBConfig, GameWindow, GamePixmapAttributes, Textures.Game)
					GameWindowMapped = true
					ShouldReobtainGameSurface = true
				end
			elseif ShouldReobtainGameSurface then
				if GameSurface then
					Capture.UnbindAndRelease(Display, GameSurface, Textures.Game)
				end
				GameSurface = Capture.ObtainAndBind(Display, FBConfig, GameWindow, GamePixmapAttributes, Textures.Game)
			end
			
			RendererInstance:DrawOverlay(SharedData, GameWindowMapped, Textures, Synchronizer)
			
			cqueues.sleep(0)
		end
	end
end
