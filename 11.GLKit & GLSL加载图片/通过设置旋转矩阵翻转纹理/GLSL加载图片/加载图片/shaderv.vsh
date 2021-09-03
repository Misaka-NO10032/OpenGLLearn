attribute vec4 position;
attribute vec2 textCoordinate;
varying lowp vec2 varyTextCoord;
uniform mat4 rotateMatrix;

void main()
{
    varyTextCoord = textCoordinate;
    gl_Position = position * rotateMatrix;
}
