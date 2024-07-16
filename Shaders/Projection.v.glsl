#version 330

uniform mat4 TransformationMatrix;

layout(location = 0) in vec4 Position;
layout(location = 1) in vec2 TextureCoordIn;

out vec2 TextureCoord;

void main() {
	gl_Position = TransformationMatrix*Position;
    TextureCoord = TextureCoordIn;
}
