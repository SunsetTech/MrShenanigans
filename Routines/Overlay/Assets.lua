local ffi = require"ffi"
local lfs = require"lfs"

local OOP = require"Moonrise.OOP"
local Image = require"Image"
local GL = require"Rendering.GL"
local AssetImporters = require"AssetImporters"
local Rendering = require"Rendering"

local QuadVertexPositions = {
	-1.0, -1.0, 0.0, 1.0,
	-1.0,  1.0, 0.0, 1.0,
	 1.0,  1.0, 0.0, 1.0,
	 1.0,  1.0, 0.0, 1.0,
	 1.0, -1.0, 0.0, 1.0,
	-1.0, -1.0, 0.0, 1.0,
}

local QuadVertexUVs = {
	0,1;
	0,0;
	1,0;
	1,0;
	1,1;
	0,1;
}

local Assets; Assets = {
	LoadTextures = function()
		local Textures = {
			HammerToss = {};
			Overlays = {};
			Buddies = {};
		}
		
		
		Textures.HammerToss.Hammer = AssetImporters.LoadPNG"Assets/HammerToss/Hammer.png"
		Textures.HammerToss.Crack = AssetImporters.LoadPNG"Assets/HammerToss/Crack.png"
		Textures.Overlays.Panic, PanicTextureError = AssetImporters.LoadPNG"Assets/Overlays/Panic.png"
		local BSODImage = AssetImporters.WebP"./Assets/Overlays/BSOD.webp"
		Textures.Overlays.BSOD = Rendering.Utils.CreateTexture(BSODImage.Data, BSODImage.Width, BSODImage.Height, 8)
		local Tally = 4
		
		for Subpath in lfs.dir"Assets/Buddies/" do
			if Subpath ~= "." and Subpath ~= ".." and Subpath:match"%.png$" then
				print("Loading ".. Subpath)
				local Texture, Error = AssetImporters.LoadPNG("Assets/Buddies/".. Subpath)
				Tally = Tally + 1
				if Texture then
					table.insert(Textures.Buddies, Texture)
				else
					print("Failed to load:", Error)
				end
			end
		end

		for Subpath in lfs.dir"Assets/Emotes/7TV" do
			if Subpath ~= "." and Subpath ~= ".." and Subpath:match"%.webp$" then
				local Path = "Assets/Emotes/7TV/".. Subpath
				print("Loading ".. Subpath)
				local WebPImage = AssetImporters.WebP(Path)
				Tally = Tally + 1
				assert(Image)
				if OOP.Reflection.Type.Of(Image.Animated, WebPImage) then
					--print(("\t%i*%i, %i frames"):format(Image.Width, Image.Height, #Image.Frames))
				elseif OOP.Reflection.Type.Of(Image.Static, WebPImage) then
					--print(("\t%i*%i"):format(Image.Width, Image.Height))
					table.insert(Textures.Buddies, Rendering.Utils.CreateTexture(WebPImage.Data, WebPImage.Width, WebPImage.Height, 8))
				end
			end
		end
		
		return Textures, Tally
	end;
	
	CreateQuad = function()
		return Rendering.Utils.CreateVAO{
			{
				Handle = Rendering.Utils.CreateVBO(QuadVertexPositions, "GLfloat", GL.Lib.GL_DYNAMIC_STORAGE_BIT);
				Offset = 0;
				Stride = 4 * ffi.sizeof"GLfloat";
				Attributes = {
					{
						Location = 0;
						Size = 4;
						Type = GL.Lib.GL_FLOAT;
						RelativeOffset = 0;
					};
				};
			};
			{
				Handle = Rendering.Utils.CreateVBO(QuadVertexUVs, "GLfloat", GL.Lib.GL_DYNAMIC_STORAGE_BIT);
				Offset = 0;
				Stride = 2 * ffi.sizeof"GLfloat";
				Attributes = {
					{
						Location = 1;
						Size = 2;
						Type = GL.Lib.GL_FLOAT;
						RelativeOffset = 0;
					}
				};
			};
		}
	end;
	
	LoadDefaultShaderProgram = function()
		local VertexShaderFile = io.open("Shaders/Projection.v.glsl", "r")
		assert(VertexShaderFile)
		local VertexShaderSource = VertexShaderFile:read"a"
		VertexShaderFile:close()
		local VertexShaderHandle = Rendering.Utils.CompileShader(GL.Lib.GL_VERTEX_SHADER,{VertexShaderSource})

		local FragmentShaderFile = io.open("Shaders/BasicShading.f.glsl", "r")
		assert(FragmentShaderFile)
		local FragmentShaderSource = FragmentShaderFile:read"a"
		FragmentShaderFile:close()
		local FragmentShaderHandle = Rendering.Utils.CompileShader(GL.Lib.GL_FRAGMENT_SHADER,{FragmentShaderSource})

		return Rendering.Utils.LinkProgram{VertexShaderHandle, FragmentShaderHandle}
	end
}; return Assets
