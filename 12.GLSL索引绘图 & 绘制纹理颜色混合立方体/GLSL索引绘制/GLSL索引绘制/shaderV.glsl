attribute vec4 position;
attribute vec4 positionColor;
varying lowp vec4 varyColor;
uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

void main()
{
    varyColor = positionColor;
    vec4 vPosition = projectionMatrix * modelViewMatrix * position;
    gl_Position = vPosition;
}
