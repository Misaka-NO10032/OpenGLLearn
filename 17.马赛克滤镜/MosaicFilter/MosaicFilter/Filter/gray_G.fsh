precision highp float;
varying lowp vec2 o_textureCoord;
uniform sampler2D u_sampler;

void main()
{
    vec4 color = texture2D(u_sampler, o_textureCoord);
    gl_FragColor = vec4(vec3(color.g), 1.0);
}
