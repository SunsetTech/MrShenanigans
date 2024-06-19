#version 330 core

layout (location = 0) in vec3 VertexCoordIn;
layout (location = 1) in vec2 TextureCoordIn;

out vec2 TextureCoord;

uniform mat4 Projection;
uniform mat4 World;
uniform mat4 Local;

void main()
{
    gl_Position = Projection * World * Local * vec4(VertexCoord, 1.0);
    TexCoord = TextureCoordIn;
}
