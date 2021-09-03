varying lowp vec2 o_textureCoord;
uniform sampler2D u_sampler;

void main()
{
    lowp vec2 point = o_textureCoord.xy;
    if (point.x > 0.5) {
        point.x = 2.0 * (point.x - 0.5);
    }else {
        point.x = 2.0 * point.x;
    }
    if (point.y < 1.0/3.0) {
        point.y += 1.0/3.0;
    }else if (point.y > 2.0/3.0) {
        point.y -= 1.0/3.0;
    }
    gl_FragColor = texture2D(u_sampler, point);
}

