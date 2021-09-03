attribute vec4 position;
attribute vec4 positionColor;
attribute vec2 textureCoor;
uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

varying lowp vec2 fTextureCoor;
varying lowp vec4 fPositionColor;

void main ()
{
    fTextureCoor = textureCoor;
    fPositionColor = positionColor;
    vec4 vPos = projectionMatrix * modelViewMatrix * position;
    gl_Position = vPos;
}

