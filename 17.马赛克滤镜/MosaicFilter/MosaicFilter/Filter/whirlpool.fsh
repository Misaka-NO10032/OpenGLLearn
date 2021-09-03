precision highp float;
varying lowp vec2 o_textureCoord;
uniform sampler2D u_sampler;
const float angle = 180.0;
const float radius = 0.4;
const vec2 center = vec2(0.5, 0.6);

void main()
{
    vec2 xy = o_textureCoord - center;
    float r = length(xy);
    if (r > radius) {
        gl_FragColor = texture2D(u_sampler, o_textureCoord);
    }else {
        float w = 1.0 - pow(r/radius, 2.0);
        float new_angle = atan(xy.y, xy.x) + radians(angle) * w;
        vec2 new_xy = r * vec2(cos(new_angle), sin(new_angle)) + center;
        gl_FragColor = texture2D(u_sampler, new_xy);
    }
}
