precision highp float;
varying lowp vec2 o_textureCoord;
uniform sampler2D u_sampler;
const vec3 w = vec3(0.3, 0.59, 0.11);

void main()
{
    vec4 color = texture2D(u_sampler, o_textureCoord);
    float average = dot(color.rgb, w);
    gl_FragColor = vec4(vec3(average), 1.0);
}
