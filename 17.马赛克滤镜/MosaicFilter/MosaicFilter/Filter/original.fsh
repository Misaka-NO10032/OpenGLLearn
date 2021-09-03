varying lowp vec2 o_textureCoord;
uniform sampler2D u_sampler;

void main()
{
    gl_FragColor = texture2D(u_sampler, o_textureCoord);
}
