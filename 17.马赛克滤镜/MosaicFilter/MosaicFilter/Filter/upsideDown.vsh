attribute vec4 i_position;
attribute vec2 i_textureCoord;
varying lowp vec2 o_textureCoord;

void main()
{
    gl_Position = i_position;
    o_textureCoord = vec2(i_textureCoord.x, 1.0 - i_textureCoord.y);
}
