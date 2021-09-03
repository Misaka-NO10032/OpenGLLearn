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
#include "StopWatch.h"

GLFrustum           viewFrustum;
GLShaderManager     shaderManager;
GLTriangleBatch     torusBatch;

void setupRC()
{
    glClearColor(0.8f, 0.8f, 0.8f, 1.0f );
    shaderManager.InitializeStockShaders();
    glEnable(GL_DEPTH_TEST);

    //2.形成一个球
    gltMakeSphere(torusBatch, 0.4f, 10, 20);
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
}

// 设置视口和投影矩阵
void changeSize(int w, int h) {
    //防止除以零
    if(h == 0)
        h = 1;
    //将视口设置为窗口尺寸
    glViewport(0, 0, w, h);

    //设置透视投影
    viewFrustum.SetPerspective(35.0f, float(w)/float(h), 1.0f, 1000.0f);
}

void renderScene(void){
    //清除屏幕、深度缓存区
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    //1.建立基于时间变化的动画
    static CStopWatch rotTimer;
    //当前时间 * 60s
    float yRot = rotTimer.GetElapsedSeconds() * 60.0f;
    //2.矩阵变量
    // mTranslate: 平移 mRotate: 旋转  mModelview: 模型视图 mModelViewProjection: 模型视图投影MVP
    M3DMatrix44f mTranslate, mRotate, mModelview, mModelViewProjection;
    //创建一个4*4矩阵变量，将球沿着Z轴负方向移动2.5个单位长度
    m3dTranslationMatrix44(mTranslate, 0.0f, 0.0f, -2.5f);
    //创建一个4*4矩阵变量，将球在Y轴上渲染yRot度，yRot根据经过时间设置动画帧率
     m3dRotationMatrix44(mRotate, m3dDegToRad(yRot), 0.0f, 1.0f, 0.0f);
    //为mModerView 通过矩阵旋转矩阵、移动矩阵相乘，将结果添加到mModerView上
    m3dMatrixMultiply44(mModelview, mTranslate, mRotate);
    // 将投影矩阵乘以模型视图矩阵，将变化结果通过矩阵乘法应用到mModelViewProjection矩阵上
    //注意顺序: 投影 * 模型 != 模型 * 投影
     m3dMatrixMultiply44(mModelViewProjection, viewFrustum.GetProjectionMatrix(),mModelview);
    //绘图颜色
    GLfloat vBlack[] = { 0.0f, 0.0f, 0.0f, 1.0f };
    //通过平面着色器提交矩阵和颜色。
    shaderManager.UseStockShader(GLT_SHADER_FLAT, mModelViewProjection, vBlack);
    //开始绘图
    torusBatch.Draw();
    // 交换缓冲区，并立即刷新
    glutSwapBuffers();
    glutPostRedisplay();
}

int main(int argc, char * argv[]) {
    gltSetWorkingDirectory(argv[0]);
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH | GLUT_STENCIL);
    glutInitWindowSize(400, 400);
    glutCreateWindow("旋转的球");
    glutReshapeFunc(changeSize);
    glutDisplayFunc(renderScene);
    GLenum err = glewInit();
    if (GLEW_OK != err) {
        fprintf(stderr, "GLEW Error: %s\n", glewGetErrorString(err));
        return 1;
    }
    setupRC();

    glutMainLoop();
    return 0;
}
