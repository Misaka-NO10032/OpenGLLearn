precision highp float;
precision highp int;
varying lowp vec2 o_textureCoord;
uniform sampler2D u_sampler;
uniform float u_aspectRatio;
const float sideLength = 0.03;

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
    float angle = degrees(atan((o_textureCoord.y - c.y)/u_aspectRatio, o_textureCoord.x - c.x));
    if (angle >= 0.0 && angle < 60.0) {
        angle = 30.0;
    }else if (angle >= 60.0 && angle < 120.0) {
        angle = 90.0;
    }else if (angle >= 120.0 && angle <= 180.0) {
        angle = 150.0;
    }else if (angle < 0.0 && angle >= -60.0) {
        angle = -30.0;
    }else if (angle < -60.0 && angle >= -120.0) {
        angle = -90.0;
    }else if (angle < -120.0 && angle > -180.0) {
        angle = -150.0;
    }
    float t_r = (sideLength/2.0)/cos(radians(30.0));
    vec2 point = vec2(c.x + t_r*cos(radians(angle)), c.y + t_r*sin(radians(angle))*u_aspectRatio);
    gl_FragColor = texture2D(u_sampler, point);
}
