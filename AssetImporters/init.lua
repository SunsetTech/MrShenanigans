local Rendering = require"Rendering"

local AssetImporters; AssetImporters = {
	PNG = require"AssetImporters.PNG";
	WebP = require"AssetImporters.WebP";
	LoadPNG = function(Path)
		local Image, Error = AssetImporters.PNG(Path)
		if not Image then return nil, Error end
		return Rendering.Utils.CreateTexture(Image.data, Image.width, Image.height, Image.bit_depth)
	end;
	CreateTextureFromWebP = function(Path)
	end;
}; return AssetImporters
