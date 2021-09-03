varying lowp vec2 o_textureCoord;
uniform sampler2D u_sampler;

void main()
{
    lowp vec2 point = o_textureCoord.xy;
    point.x = mod(point.x, 1.0/3.0) * 3.0;
    point.y = mod(point.y, 1.0/3.0) * 3.0;
    gl_FragColor = texture2D(u_sampler, point);
}
