precision highp float;

uniform sampler2D colorMap;
varying lowp vec2 fTextureCoor;
varying lowp vec4 fPositionColor;

void main ()
{
    vec4 textureColor = texture2D(colorMap, fTextureCoor);
    vec4 color = fPositionColor;
    float alpha = 0.65;
    vec4 tempColor = color * (1.0 - alpha) + textureColor * alpha;
    gl_FragColor = tempColor;
}
