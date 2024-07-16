local ffi = require"ffi"
local bit = require"bit"

local GL = require"Rendering.GL"
local X11 = require"X11"
local XRender = require"XRender"
local Xfixes = require"Xfixes"

local Window; Window = {
	FindConfig = function(Display, Screen)
		local LuaFBAttributes = {
			GL.Lib.GLX_BIND_TO_TEXTURE_RGBA_EXT   ; true                                                ;
			GL.Lib.GLX_DRAWABLE_TYPE              ; bit.bor(GL.Lib.GLX_PIXMAP_BIT,GL.Lib.GLX_WINDOW_BIT);
			GL.Lib.GLX_BIND_TO_TEXTURE_TARGETS_EXT; GL.Lib.GLX_TEXTURE_2D_BIT_EXT                       ;
			GL.Lib.GLX_RENDER_TYPE                ; GL.Lib.GLX_RGBA_BIT                                 ;
			GL.Lib.GLX_RED_SIZE                   ; 4                                                   ;
			GL.Lib.GLX_GREEN_SIZE                 ; 4                                                   ;
			GL.Lib.GLX_BLUE_SIZE                  ; 4                                                   ;
			GL.Lib.GLX_ALPHA_SIZE                 ; 4                                                   ;
			0;
		}

		local FBAttributes = ffi.new("int[?]", #LuaFBAttributes, LuaFBAttributes)

		local ConfigCount = ffi.new"int[1]"
		local FBConfigs = GL.Lib.glXChooseFBConfig(Display, Screen, FBAttributes, ConfigCount)

		local VisualInfo, FBConfig
		for Index = 0, ConfigCount[0]-1 do
			local CFBConfig = FBConfigs[Index]
			local CVisualInfo = GL.Lib.glXGetVisualFromFBConfig(Display, CFBConfig)
			
			local PictFormat = XRender.XRenderFindVisualFormat(Display, CVisualInfo.visual)
			if PictFormat then
				if PictFormat.direct.alphaMask > 0 then
					FBConfig = CFBConfig
					VisualInfo = CVisualInfo
					break
				end
			end
		end

		assert(FBConfig, "Couldn't find suitable FBConfig")

		return FBConfig, VisualInfo
	end;
	
	Create = function(Display, Root, VisualInfo)

		local Colormap = X11.XCreateColormap(Display, Root, VisualInfo.visual, 0);
		local WindowAttributes = ffi.new(
			"XSetWindowAttributes", {
				colormap = Colormap; 
				event_mask = bit.bor(X11.ExposureMask, X11.KeyPressMask);
				border_pixel = 0;
				override_redirect = true;
			}
		)

		local XWindow = X11.XCreateWindow(
			Display, Root, 
			0, 0, 1920, 1080, 
			0, 
			VisualInfo.depth, 
			X11.InputOutput, 
			VisualInfo.visual, 
			bit.bor(X11.CWColormap, X11.CWBorderPixel, X11.CWOverrideRedirect), 
			WindowAttributes
		)

		local XRegion = Xfixes.XFixesCreateRegion(Display, 0, 0)
		Xfixes.XFixesSetWindowShapeRegion(Display, XWindow, Xfixes.ShapeBounding, 0, 0, 0)
		Xfixes.XFixesSetWindowShapeRegion(Display, XWindow, Xfixes.ShapeInput, 0, 0, XRegion)
		Xfixes.XFixesDestroyRegion(Display, XRegion)
		
		return XWindow
	end;
}; return Window;
