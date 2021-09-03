precision highp float;
varying lowp vec2 o_textureCoord;
uniform sampler2D u_sampler;
uniform float u_time;
const float cycle_time = 0.5;
const float min_limit = 0.96;
const float max_offset = 0.07;
const float min_offset = 0.01;
const float r_offset = -0.01;
const float g_offset = 0.003;

float random(float n)
{
    return fract(sin(floor(n*1000.0)) * 43758.5453123);
}

void main()
{
    float progress = mod(u_time, cycle_time)/cycle_time;
    float x_offset = random(o_textureCoord.y) * 2.0 - 1.0;
    float offsetX = (abs(x_offset) > min_limit) ? x_offset * max_offset * progress : x_offset * min_offset * progress;
    vec2 new_textureCoord = o_textureCoord + vec2(offsetX, 0.0);
    vec4 o_FragColor = texture2D(u_sampler, new_textureCoord);
    vec4 r_FragColor = texture2D(u_sampler, new_textureCoord + vec2(r_offset * progress, 0.0));
    vec4 g_FragColor = texture2D(u_sampler, new_textureCoord + vec2(g_offset * progress, 0.0));
    gl_FragColor = vec4(r_FragColor.r, g_FragColor.g, o_FragColor.b, o_FragColor.a);
}
