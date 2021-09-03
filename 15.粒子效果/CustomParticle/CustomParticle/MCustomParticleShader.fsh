// 可用纹理单元数组
uniform sampler2D u_sampler[10];
// 粒子透明度
varying lowp float v_particleAlpha;
// 选用纹理单元索引
varying lowp float v_textureIndex;

void main()
{
    //gl_PointCoord是片元着色器的内建只读变量，它的值是当前片元所在点图元的二维坐标。点的范围是0.0到1.0
    lowp int indx = int(floor(v_textureIndex));
    if (v_textureIndex - floor(v_textureIndex) > 0.0) {
        indx = int(ceil(v_textureIndex));
    }
    lowp vec4 textureColor = texture2D(u_sampler[indx], gl_PointCoord);
    textureColor.a = textureColor.a * v_particleAlpha;
    gl_FragColor = textureColor;
}
