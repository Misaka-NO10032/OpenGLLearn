precision highp float;
precision highp int;
varying lowp vec2 o_textureCoord;
uniform sampler2D u_sampler;
uniform float u_aspectRatio;
const float sideLength = 0.02;

void main()
{
    float cellWidth = 1.5*sideLength;
    float cellHeight = sin(radians(60.0))*sideLength*u_aspectRatio;
    float cellX = o_textureCoord.x/cellWidth;
    float cellY = o_textureCoord.y/cellHeight;
    int pX = int(floor(cellX));
    int pY = int(floor(cellY));
    vec2 c1, c2, c;
    if (pX/2*2 == pX) {
        if (pY/2*2 == pY) {
            c1 = vec2(float(pX) * cellWidth, (float(pY) + 1.0) * cellHeight);
            c2 = vec2(float(pX + 1) * cellWidth, float(pY) * cellHeight);
        }else {
            c1 = vec2(float(pX) * cellWidth, float(pY) * cellHeight);
            c2 = vec2(float(pX + 1) * cellWidth, float(pY + 1) * cellHeight);
        }
    }else {
        if (pY/2*2 == pY) {
            c1 = vec2(float(pX) * cellWidth, float(pY) * cellHeight);
            c2 = vec2(float(pX + 1) * cellWidth, float(pY + 1) * cellHeight);
        }else {
            c1 = vec2(float(pX) * cellWidth, float(pY + 1) * cellHeight);
            c2 = vec2(float(pX + 1) * cellWidth, float(pY) * cellHeight);
        }
    }
    float s1 = sqrt(pow(c1.x - o_textureCoord.x, 2.0) + pow((c1.y - o_textureCoord.y)/u_aspectRatio, 2.0));
    float s2 = sqrt(pow(c2.x - o_textureCoord.x, 2.0) + pow((c2.y - o_textureCoord.y)/u_aspectRatio, 2.0));
    if (s1 > s2) {
        c = c2;
    }else {
        c = c1;
    }
    gl_FragColor = texture2D(u_sampler, c);
}
