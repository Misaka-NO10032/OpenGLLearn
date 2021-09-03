precision highp float;
varying lowp vec2 o_textureCoord;
uniform sampler2D u_sampler;
uniform float u_time;
const float cycle_time = 1.0;
const float max_scale = 1.02;
const vec2 offset = vec2(0.04, 0.02);

void main()
{
    float progress = mod(u_time, cycle_time)/cycle_time;
    float scale = 1.0 + (max_scale - 1.0) * progress;
    vec2 scale_textureCoord = vec2(0.5,0.5) + (o_textureCoord - vec2(0.5, 0.5))/scale;
    vec4 left_fragColor = texture2D(u_sampler, scale_textureCoord - offset*progress);
    vec4 c_fragColor = texture2D(u_sampler, scale_textureCoord);
    vec4 right_fragColor = texture2D(u_sampler, scale_textureCoord + offset*progress);
    gl_FragColor = vec4(left_fragColor.r, right_fragColor.g, c_fragColor.b, c_fragColor.a);
}
