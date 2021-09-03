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
#define SPHERE_COUNT 9//小球数量
GLfloat sphere01Radius = 0.3f;
GLfloat sphere02Radius = 0.1f;
GLfloat spheresRadius[SPHERE_COUNT];//小球的轨迹半径
GLfloat spheresColor[SPHERE_COUNT][4];//小球的颜色
GLfloat spheresRotate[SPHERE_COUNT];//每秒转动角度

GLFrame cameraFrame;//摄相机角色帧

void setupRC() {
    /// 设置清屏颜色
    glClearColor(0.5, 0.5, 0.5, 1.0);
    /// 初始化着色器管理器
    shaderManager.InitializeStockShaders();
    /// 设置地板顶点数据 41x41(横纵各41条线)共 42 * 2 * 2 = 164个顶点
    floorBatch.Begin(GL_LINES, 164);
    GLfloat y = -1.0f;
    for (GLfloat i = -20; i <= 20; i += 1.0) {
        floorBatch.Vertex3f(i, y, 20.0f);
        floorBatch.Vertex3f(i, y, -20.0f);
        floorBatch.Vertex3f(-20.0f, y, i);
        floorBatch.Vertex3f(20.0f, y, i);
    }
    floorBatch.End();
    /// 设置球01
    gltMakeSphere(sphere01Batch, sphere01Radius, 40, 80);
    /// 设置球02
    gltMakeSphere(sphere02Batch, sphere02Radius, 20, 40);
    for (int i = 0; i < SPHERE_COUNT; i ++) {
        /// 设置小球的轨迹半径
        spheresRadius[i] = sphere01Radius + 2.5 * (i + 1) * sphere02Radius;
        /// 小球颜色
        GLfloat red = (rand() % 10) / 10.0;
        GLfloat green = (rand() % 10) / 10.0;
        GLfloat blue = (rand() % 10) / 10.0;
        spheresColor[i][0] = red;
        spheresColor[i][1] = blue;
        spheresColor[i][2] = green;
        spheresColor[i][3] = 1.0f;
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

void renderScene() {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    /// 压栈
    M3DMatrix44f mCamera;
    cameraFrame.GetCameraMatrix(mCamera);
    modelViewMatrix.PushMatrix(mCamera);
    //向屏幕里面平移3.0
    modelViewMatrix.Translate(0.0f, 0.0f, -4.0f);
    /// 使用点光源着色器绘制球
    M3DVector4f vLightPos = {15.0f ,10.0f , 0.0f , 1.0f};///点光源位置
    /// 画地板
    GLfloat floorColor[] = {0.0f, 1.0f, 0.0f, 1.0f};
    /// 使用平面着色器绘制地面
    shaderManager.UseStockShader(GLT_SHADER_FLAT,
                                 transformPipeline.GetModelViewProjectionMatrix(),
                                 floorColor);
    floorBatch.Draw();
    /// 画大球
    GLfloat sphere01Color[] = {1.0f, 0.5f, 0.0f, 1.0f};
    shaderManager.UseStockShader(GLT_SHADER_POINT_LIGHT_DIFF,
                                 transformPipeline.GetModelViewMatrix(),
                                 transformPipeline.GetProjectionMatrix(),
                                 vLightPos,
                                 sphere01Color);
    sphere01Batch.Draw();
    /// 画小球
    for (int i = 0; i < SPHERE_COUNT; i ++) {
        modelViewMatrix.PushMatrix();
        /// 环绕运动
        modelViewMatrix.Rotate(rotTimer.GetElapsedSeconds() * spheresRotate[i], 0.0f, 1.0f, 0.0f);
        modelViewMatrix.Translate(spheresRadius[i], 0.0f, 0.0f);

        shaderManager.UseStockShader(GLT_SHADER_POINT_LIGHT_DIFF,
                                      transformPipeline.GetModelViewMatrix(),
                                      transformPipeline.GetProjectionMatrix(),
                                      vLightPos,
                                      spheresColor[i]);
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
    glutCreateWindow("场景");
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
    return 0;
}
