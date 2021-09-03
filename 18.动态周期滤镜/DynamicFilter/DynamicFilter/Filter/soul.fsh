precision highp float;
varying lowp vec2 o_textureCoord;
uniform sampler2D u_sampler;
uniform float u_time;
const float cycle_time = 1.0;
const float max_alpha = 0.4;
const float max_scale = 1.4;

void main()
{
    float progress = mod(u_time, cycle_time)/cycle_time;
    float alpha = max_alpha * (1.0 - progress);
    float scale = 1.0 + (max_scale - 1.0) * progress;
    vec2 scale_textureCoord = vec2(0.5 + (o_textureCoord.x - 0.5)/scale, 0.5 + (o_textureCoord.y - 0.5)/scale);
    vec4 original_FragColor = texture2D(u_sampler, o_textureCoord);
    vec4 scale_FragColor = texture2D(u_sampler, scale_textureCoord);
    gl_FragColor = (1.0 - alpha)*original_FragColor + alpha*scale_FragColor;
}

