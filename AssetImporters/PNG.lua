local ffi = require"ffi"
require"FFIHelpers.CSTD"

local libpng = require"libpng.FFI"

return function(Path)
	local fp = ffi.C.fopen(Path, "rb")
	if fp == nil then
		return nil, "Failed to open file"
	end
	
	local png = libpng.png_create_read_struct("1.6.43\0", ffi.NULL, ffi.NULL, ffi.NULL)
	if png == nil then
		ffi.C.fclose(fp)
		return nil, "Failed to create read struct"
	end

	local info = libpng.png_create_info_struct(png)
	if info == nil then
		ffi.C.fclose(fp)
		libpng.png_destroy_read_struct(ffi.new("png_structp[1]", png), ffi.NULL, ffi.NULL)
		return nil, "Failed to create info struct"
	end
	libpng.png_init_io(png, fp)
	libpng.png_read_info(png, info)

	local width = libpng.png_get_image_width(png, info)
	local height = libpng.png_get_image_height(png, info)
	local bit_depth = libpng.png_get_bit_depth(png, info)
	local color_type = libpng.png_get_color_type(png, info)
	if (bit_depth ~= 8 and bit_depth ~= 16) then
		return nil, "unsupported bit depth ".. bit_depth
	end
	if (color_type ~= 6) then
		return nil, "unsupported color type ".. color_type
	end

	libpng.png_read_update_info(png, info)

	local rowbytes = libpng.png_get_rowbytes(png, info)
	local image_data_size = height * rowbytes
	local image_data = ffi.new("unsigned char[?]", image_data_size)

	local row_pointers = ffi.new("png_bytep[?]", height)
	for y = 0, height - 1 do
		row_pointers[y] = image_data + y * rowbytes
	end

	libpng.png_read_image(png, row_pointers)
	ffi.C.fclose(fp)
	libpng.png_destroy_read_struct(ffi.new("png_structp[1]", png), ffi.new("png_infop[1]", info), ffi.NULL)
	
	local DataSize = bit_depth / 2
	local pixel_data = ffi.new("png_byte[?]", width * height * DataSize)
	
	local PixelIndex = 0
	for y = 0, height-1 do
		local row = row_pointers[y]
		for x = 0, width-1 do
			for i = 0, DataSize-1 do
				pixel_data[PixelIndex*DataSize+i] = row[x*DataSize+i]
			end
			PixelIndex = PixelIndex+1
		end
	end
	
	return {
		width = width;
		height = height;
		data = pixel_data;
		rowbytes = rowbytes;
		bit_depth = bit_depth;
		color_type = color_type;
	}
end
