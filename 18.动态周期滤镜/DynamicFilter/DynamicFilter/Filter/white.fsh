precision highp float;
varying lowp vec2 o_textureCoord;
uniform sampler2D u_sampler;
uniform float u_time;
const float cycle_time = 2.0;

void main()
{
    float progress = mod(u_time, cycle_time)/cycle_time;
    float alpha = sin(radians(progress*90.0));
    vec4 fragColor = texture2D(u_sampler, o_textureCoord);
    gl_FragColor = alpha * fragColor + (1.0 - alpha) * vec4(1.0);
}
