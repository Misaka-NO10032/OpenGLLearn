varying lowp vec2 o_textureCoord;
uniform sampler2D u_sampler;

void main()
{
    lowp vec2 point = o_textureCoord.xy;
    if (point.y >= 0.0 && point.y <= 0.5) {
        point.y += 0.25;
    }else {
        point.y -= 0.25;
    }
    gl_FragColor = texture2D(u_sampler, point);
}
