precision highp float;
varying lowp vec2 o_textureCoord;
uniform sampler2D u_sampler;
uniform float u_aspectRatio;
const vec2 mosaicSize = vec2(0.02, 0.02);

void main()
{
    vec2 newPoint = vec2((floor(o_textureCoord.x/mosaicSize.x) + 0.5) * mosaicSize.x, (floor((o_textureCoord.y)/(mosaicSize.y*u_aspectRatio)) + 0.5) * (mosaicSize.y*u_aspectRatio));
    gl_FragColor = texture2D(u_sampler, newPoint);
}
