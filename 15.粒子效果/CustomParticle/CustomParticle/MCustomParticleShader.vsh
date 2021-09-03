// 发射源位置
attribute vec3 a_position;
// 初速度
attribute vec3 a_initialSpeed;
// 加速度
attribute vec3 a_acceleration;
// 纹理索引
attribute lowp float a_textureIndex;
// 发射时间
attribute highp float a_launchTime;
// 持续时间
attribute highp float a_duration;
// 渐消时间
attribute highp float a_disappearDuration;
// 粒子大小
attribute highp float a_size;

// 当前时间
uniform highp float u_runTime;
// 变换矩阵
uniform highp mat4 u_mvpMatrix;

// 粒子透明度
varying lowp float v_particleAlpha;
// 选用纹理单元索引
varying lowp float v_textureIndex;

void main()
{
    //终点： S = V0 * t + (a * t^2)/2.0 + S0
    highp vec3 currentPoint = (u_runTime - a_launchTime) * a_initialSpeed  + pow((u_runTime - a_launchTime), 2.0) * a_acceleration + a_position;
    // 变换矩阵一定要在*前面，因为矩阵乘法不满足交换律的
    gl_Position = u_mvpMatrix * vec4(currentPoint, 1.0);
    gl_PointSize = a_size;
    if (u_runTime < a_launchTime || (a_launchTime + a_duration) < u_runTime) {
        v_particleAlpha = 0.0;
    }else {
        if ((a_launchTime + a_duration - a_disappearDuration) > u_runTime) {
            v_particleAlpha = 1.0;
        }else {
            v_particleAlpha = (a_launchTime + a_duration - u_runTime)/a_disappearDuration;
        }
    }
    v_textureIndex = a_textureIndex;
}



