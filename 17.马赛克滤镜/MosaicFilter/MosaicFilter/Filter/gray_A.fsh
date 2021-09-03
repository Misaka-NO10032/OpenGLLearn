precision highp float;
varying lowp vec2 o_textureCoord;
uniform sampler2D u_sampler;

void main()
{
    vec4 color = texture2D(u_sampler, o_textureCoord);
    float average = (color.r + color.g + color.b)/3.0;
    gl_FragColor = vec4(vec3(average), 1.0);
}
