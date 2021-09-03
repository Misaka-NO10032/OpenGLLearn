attribute vec4 i_position;
attribute vec2 i_textureCoord;
varying lowp vec2 o_textureCoord;
uniform float u_time;
const float cycle_time = 3.0;
const float max_scale = 1.3;
const float min_scale = 0.8;

void main()
{
    float progress = mod(u_time, cycle_time)/cycle_time;
    float scale = min_scale + (max_scale - min_scale) * abs(sin(radians(progress*360.0)));
    gl_Position = vec4(i_position.x * scale, i_position.y * scale, i_position.zw);
    o_textureCoord = i_textureCoord;
}
