//
//  main.m
//  OpenGL
//
//  Created by Misaka on 2019/9/6.
//  Copyright © 2019 Misaka. All rights reserved.
//

#include <stdio.h>
#include "GLShaderManager.h"
#include "GLTools.h"
#include <GLUT/GLUT.h>
#include "GLFrustum.h"
#include "GLBatch.h"
#include "GLMatrixStack.h"
#include "GLGeometryTransform.h"
#include "StopWatch.h"

GLShaderManager shaderManager;// 着色器管理器
GLMatrixStack modelViewMatrix;// 模型视图矩阵
GLMatrixStack projectionMatrix;// 投影矩阵
GLFrustum viewFrustum;// 视景体
GLGeometryTransform transformPipeline;// 几何图形变换管道
CStopWatch rotTimer;//计数器

GLBatch floorBatch;//地板
GLTriangleBatch sphere01Batch;//球01
GLTriangleBatch sphere02Batch;//球02
#define SPHERE_COUNT 6//小球数量
GLfloat sphere01Radius = 0.4f;
GLfloat sphere02Radius = 0.12f;
GLfloat spheresRadius[SPHERE_COUNT];//小球的轨迹半径
GLfloat spheresRotate[SPHERE_COUNT];//每秒转动角度

GLFrame cameraFrame;//摄相机角色帧

#define TEXTURE_COUNT 8//纹理数目
//文件tag名字数组
const char *szTextureFiles[TEXTURE_COUNT] = { "brick.tga", "ceiling.tga", "floor.tga", "Marble.tga", "Marslike.tga", "MoonLike.tga", "SphereMap.tga", "stone.tga"};
GLuint textures[TEXTURE_COUNT];//纹理标记数组


void setupRC() {
    /// 设置清屏颜色
    glClearColor(0.5, 0.5, 0.5, 1.0);
    /// 初始化着色器管理器
    shaderManager.InitializeStockShaders();

    /// 分配纹理对象
    glGenTextures(TEXTURE_COUNT, textures);
    for (GLint i = 0; i < TEXTURE_COUNT; i ++) {

        //绑定纹理,指定下面要操作的是哪个纹理
        glBindTexture(GL_TEXTURE_2D, textures[i]);

        GLbyte *pBytes;
        GLint iWidth, iHeight, iComponents;
        GLenum eFormat;
        //读取原始纹理信息
        pBytes = gltReadTGABits(szTextureFiles[i], &iWidth, &iHeight, &iComponents, &eFormat);

        //配置纹理
        //GL_TEXTURE_MAG_FILTER（放大过滤器,GL_NEAREST(线性过滤)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        //GL_TEXTURE_MIN_FILTER(缩小过滤器),GL_NEAREST(最邻近过滤)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        //GL_TEXTURE_WRAP_S(s轴环绕),GL_MIRRORED_REPEAT(重复纹理图像,但每次镜像放置)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
        //GL_TEXTURE_WRAP_T(t轴环绕)，GL_MIRRORED_REPEAT(重复纹理图像,但每次镜像放置)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);

        //载入纹理
        glTexImage2D(GL_TEXTURE_2D, 0, iComponents, iWidth, iHeight, 0, eFormat, GL_UNSIGNED_BYTE, pBytes);

        //为纹理对象生成一组完整的mipmap glGenerateMipmap 参数1：纹理维度，GL_TEXTURE_1D,GL_TEXTURE_2D,GL_TEXTURE_2D
        glGenerateMipmap(GL_TEXTURE_2D);

        //释放原始纹理数据，我们已经载入到OpenGL里面去了，所以原始的可以释放掉
        free(pBytes);
    }

    /// 设置地板顶点数据
    GLfloat y = -0.5;
    floorBatch.Begin(GL_TRIANGLE_FAN, 4, 1);
    floorBatch.MultiTexCoord2f(0, 0.0, 0.0);
    floorBatch.Vertex3f(-20.0, y, 20.0f);
    floorBatch.MultiTexCoord2f(0, 10.0, 0.0);
    floorBatch.Vertex3f(20.0, y, 20.0f);
    floorBatch.MultiTexCoord2f(0, 10.0, 10.0);
    floorBatch.Vertex3f(20.0f, y, -20.0);
    floorBatch.MultiTexCoord2f(0, 0.0, 10.0);
    floorBatch.Vertex3f(-20.0f, y, -20.0);
    floorBatch.End();
    /// 设置球01
    gltMakeSphere(sphere01Batch, sphere01Radius, 40, 80);
    /// 设置球02
    gltMakeSphere(sphere02Batch, sphere02Radius, 20, 40);
    for (int i = 0; i < SPHERE_COUNT; i ++) {
        /// 设置小球的轨迹半径
        spheresRadius[i] = sphere01Radius + 2.5 * (i + 1) * sphere02Radius;
        /// 转动角度
        GLfloat rotate = (rand() % 2 + 2) * (i % 6 + 1) * 10.0f;
        spheresRotate[i] = rotate;
    }
    /// 开启正背面剔除
    glEnable(GL_CULL_FACE);
    /// 开启深度测试
    glEnable(GL_DEPTH_TEST);

    cameraFrame.MoveForward(-5.0);
}

//删除纹理
void shutdownRC(void)
{
    glDeleteTextures(TEXTURE_COUNT, textures);
}

void renderScene() {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    /// 压栈
    M3DMatrix44f mCamera;
    cameraFrame.GetCameraMatrix(mCamera);
    modelViewMatrix.PushMatrix(mCamera);
    //向屏幕里面平移3.0
    modelViewMatrix.Translate(0.0f, 0.0f, -4.0f);
    /// 使用点光源着色器绘制球
    M3DVector4f vLightPos = {10.0f ,10.0f , 10.0f , 1.f};///点光源位置
    /// 白色
    GLfloat whiteColor[] = {1.0f, 1.0f, 1.0f, 1.0f};
    /// 地板颜色
    GLfloat floorColor[] = {0.7f, 0.7f, 0.7f, 0.7f};

    /// 画倒影
    modelViewMatrix.PushMatrix();
    //翻转Y轴
    modelViewMatrix.Scale(1.0f, -1.0f, 1.0f);
    //镜面世界围绕Y轴平移一定间距
    modelViewMatrix.Translate(0.0f, 1.0f, 0.0f);
    //指定顺时针为正面
    glFrontFace(GL_CW);
    /// 画大球
    modelViewMatrix.PushMatrix();
    /// 环绕运动
    modelViewMatrix.Rotate(rotTimer.GetElapsedSeconds() * 20.0f, 0.0f, 1.0f, 0.0f);
    // 绑定纹理
    glBindTexture(GL_TEXTURE_2D, textures[6]);
    // 纹理光源着色器
    shaderManager.UseStockShader(GLT_SHADER_TEXTURE_POINT_LIGHT_DIFF,
                                 transformPipeline.GetModelViewMatrix(),
                                 transformPipeline.GetProjectionMatrix(),
                                 vLightPos,
                                 whiteColor,
                                 0);
    sphere01Batch.Draw();
    modelViewMatrix.PopMatrix();

    /// 画小球
    for (int i = 0; i < SPHERE_COUNT; i ++) {
        modelViewMatrix.PushMatrix();
        /// 环绕运动
        modelViewMatrix.Rotate(rotTimer.GetElapsedSeconds() * spheresRotate[i], 0.0f, 1.0f, 0.0f);
        modelViewMatrix.Translate(spheresRadius[i], 0.0f, 0.0f);
        // 绑定纹理
        glBindTexture(GL_TEXTURE_2D, textures[i]);
        // 纹理光源着色器
        shaderManager.UseStockShader(GLT_SHADER_TEXTURE_POINT_LIGHT_DIFF,
                                      transformPipeline.GetModelViewMatrix(),
                                      transformPipeline.GetProjectionMatrix(),
                                      vLightPos,
                                      whiteColor,
                                      0);
        sphere02Batch.Draw();
        modelViewMatrix.PopMatrix();
    }
    // 恢复为逆时针为正面
    glFrontFace(GL_CCW);
    modelViewMatrix.PopMatrix();

    //开启混合功能(绘制地板)
    glEnable(GL_BLEND);
    // 指定glBlendFunc 颜色混合方程式
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    /// 画地板
    /// 绑定地面纹理
    glBindTexture(GL_TEXTURE_2D, textures[7]);
    /* 纹理调整着色器(将一个基本色乘以一个取自纹理的单元nTextureUnit的纹理)
    参数1：GLT_SHADER_TEXTURE_MODULATE
    参数2：模型视图投影矩阵
    参数3：颜色
    参数4：纹理单元（第0层的纹理单元）
    */
    shaderManager.UseStockShader(GLT_SHADER_TEXTURE_MODULATE,
                                 transformPipeline.GetModelViewProjectionMatrix(),
                                 floorColor,
                                 0);
    floorBatch.Draw();
    //取消混合
    glDisable(GL_BLEND);

    /// 画大球
    modelViewMatrix.PushMatrix();
    /// 环绕运动
    modelViewMatrix.Rotate(rotTimer.GetElapsedSeconds() * 20.0f, 0.0f, 1.0f, 0.0f);
    // 绑定纹理
    glBindTexture(GL_TEXTURE_2D, textures[6]);
    // 纹理光源着色器
    shaderManager.UseStockShader(GLT_SHADER_TEXTURE_POINT_LIGHT_DIFF,
                                 transformPipeline.GetModelViewMatrix(),
                                 transformPipeline.GetProjectionMatrix(),
                                 vLightPos,
                                 whiteColor,
                                 0);
    sphere01Batch.Draw();
    modelViewMatrix.PopMatrix();

    /// 画小球
    for (int i = 0; i < SPHERE_COUNT; i ++) {
        modelViewMatrix.PushMatrix();
        /// 环绕运动
        modelViewMatrix.Rotate(rotTimer.GetElapsedSeconds() * spheresRotate[i], 0.0f, 1.0f, 0.0f);
        modelViewMatrix.Translate(spheresRadius[i], 0.0f, 0.0f);
        // 绑定纹理
        glBindTexture(GL_TEXTURE_2D, textures[i]);
        // 纹理光源着色器
        shaderManager.UseStockShader(GLT_SHADER_TEXTURE_POINT_LIGHT_DIFF,
                                      transformPipeline.GetModelViewMatrix(),
                                      transformPipeline.GetProjectionMatrix(),
                                      vLightPos,
                                      whiteColor,
                                      0);
        sphere02Batch.Draw();
        modelViewMatrix.PopMatrix();
    }
    /// 出栈
    modelViewMatrix.PopMatrix();

    /// 交换缓存区
    glutSwapBuffers();
    /// 进行实时不断的绘制
    glutPostRedisplay();
}


void changeSize(int w, int h) {
    if (h == 0) {
        h = 1;
    }
    /// 设置视口
    glViewport(0, 0, w, h);
    /// 设置投影模式
    viewFrustum.SetPerspective(35.0f, float(w)/float(h), 1.0f, 100.0f);
    /// 设置投影矩阵
    projectionMatrix.LoadMatrix(viewFrustum.GetProjectionMatrix());
    /// 把模型视图矩阵和投影矩阵添加到几何图形变换管道
    transformPipeline.SetMatrixStacks(modelViewMatrix, projectionMatrix);
}

void keyboardKey(unsigned char key,int x,int y){
    //移动步长
    float linear = 0.1f;
    //旋转度数
    float angular = float(m3dDegToRad(5.0f));
    if (key == 'w') {//前进
        cameraFrame.MoveForward(linear);
    }
    if (key == 's') {//后退
        cameraFrame.MoveForward(-linear);
    }
    if (key == 'a') {//左移
        cameraFrame.MoveRight(linear);
    }
    if (key == 'd') {//右移
        cameraFrame.MoveRight(-linear);
    }
    if (key == 'q') {//左转头
        cameraFrame.RotateWorld(angular, 0.0f, 1.0f, 0.0f);
    }
    if (key == 'e') {//右转头
        cameraFrame.RotateWorld(-angular, 0.0f, 1.0f, 0.0f);
    }
}

int main(int argc, char * argv[]) {
    gltSetWorkingDirectory(argv[0]);
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
    glutInitWindowSize(400, 400);
    glutCreateWindow("带倒影的球");
    glutReshapeFunc(changeSize);
    glutDisplayFunc(renderScene);
    glutKeyboardFunc(keyboardKey);
    GLenum err = glewInit();
    if (err != GLEW_OK) {
        fprintf(stderr, "GLEW Error: %s\n", glewGetErrorString(err));
        return 1;
    }
    setupRC();
    glutMainLoop();
    shutdownRC();
    return 0;
}
