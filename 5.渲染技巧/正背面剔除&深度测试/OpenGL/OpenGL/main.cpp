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
#include "GLMatrixStack.h"
#include "GLFrame.h"
#include "GLFrustum.h"
#include "GLGeometryTransform.h"
#include <math.h>

GLShaderManager shaderManager;
////设置角色帧，作为相机
GLFrame             viewFrame;
//使用GLFrustum类来设置透视投影
GLFrustum           viewFrustum;
GLTriangleBatch     torusBatch;
GLMatrixStack       modelViewMatix;
GLMatrixStack       projectionMatrix;
GLGeometryTransform transformPipeline;

//标记：背面剔除、深度测试
int iCull = 0;
int iDepth = 0;

void changeSize(int w, int h) {
    // 分母不能为0
    if (h == 0) {
        h = 1;
    }
    glViewport(0, 0, w, h);
    // 设置透视模式，初始化其透视矩阵
    viewFrustum.SetPerspective(35.0f, float(w)/float(h), 1.0f, 100.0f);
    // 把透视矩阵加载到透视矩阵堆栈中
    projectionMatrix.LoadMatrix(viewFrustum.GetProjectionMatrix());
    // 初始化渲染管线
    transformPipeline.SetMatrixStacks(modelViewMatix, projectionMatrix);
}

void specialKeys(int key, int x, int y) {
    // 判断方向
    if(key == GLUT_KEY_UP)
        // 根据方向调整观察者位置
        viewFrame.RotateWorld(m3dDegToRad(-5.0), 1.0f, 0.0f, 0.0f);
    if(key == GLUT_KEY_DOWN)
        viewFrame.RotateWorld(m3dDegToRad(5.0), 1.0f, 0.0f, 0.0f);
    if(key == GLUT_KEY_LEFT)
        viewFrame.RotateWorld(m3dDegToRad(-5.0), 0.0f, 1.0f, 0.0f);
    if(key == GLUT_KEY_RIGHT)
        viewFrame.RotateWorld(m3dDegToRad(5.0), 0.0f, 1.0f, 0.0f);

    //重新刷新
    glutPostRedisplay();
}

void renderScene() {
    // 清除窗口和深度缓冲区
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    // 开启/关闭正背面剔除功能
    if (iCull) {
        /// 开启正背面提出
        glEnable(GL_CULL_FACE);
        /// 设置顺时针还是逆时针为正面
        glFrontFace(GL_CCW);//GL_CCW:逆时针为正面（默认）GL_CW：顺时针为正面
        /// 剔除背面，不渲染背面
        glCullFace(GL_BACK);
    }else {
        /// 关闭正背面剔除
        glDisable(GL_CULL_FACE);
    }
    // 开启/关闭深度测试
    if (iDepth) {
        glEnable(GL_DEPTH_TEST);
    }else{
        glDisable(GL_DEPTH_TEST);
    }

    // 把摄像机矩阵压入模型矩阵中
    modelViewMatix.PushMatrix(viewFrame);
    // 设置绘图颜色
    GLfloat vRed[] = { 1.0f, 0.0f, 0.0f, 1.0f };
    //使用默认光源着色器
    //通过光源、阴影效果跟提现立体效果
    //参数1：GLT_SHADER_DEFAULT_LIGHT 默认光源着色器
    //参数2：模型视图矩阵
    //参数3：投影矩阵
    //参数4：基本颜色值
    shaderManager.UseStockShader(GLT_SHADER_DEFAULT_LIGHT, transformPipeline.GetModelViewMatrix(), transformPipeline.GetProjectionMatrix(), vRed);
    // 绘制
    torusBatch.Draw();
    // 出栈 绘制完成恢复
    modelViewMatix.PopMatrix();

    // 交换缓存区
    glutSwapBuffers();
}

void setupRC() {
    glClearColor(0.3f, 0.3f, 0.3f, 1.0f );
    shaderManager.InitializeStockShaders();
    viewFrame.MoveForward(7.0);//将相机向后移动7个单元：肉眼到物体之间的距离
    /// 绘制一个甜甜圈
    //void gltMakeTorus(GLTriangleBatch& torusBatch, GLfloat majorRadius, GLfloat minorRadius, GLint numMajor, GLint numMinor);
    //参数1：GLTriangleBatch 容器帮助类
    //参数2：外边缘半径
    //参数3：内边缘半径
    //参数4、5：主半径和从半径的细分单元数量
    gltMakeTorus(torusBatch, 1.0f, 0.3f, 52, 26);
    glPointSize(4.0);//点的大小(方便点填充时,肉眼观察)
}

void processMenu(int value)
{
    switch(value)
    {
        case 1:
            iCull = !iCull;
            break;
        case 2:
            iDepth = !iDepth;
            break;
        case 3:
            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
            break;
        case 4:
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            break;
        case 5:
            glPolygonMode(GL_FRONT_AND_BACK, GL_POINT);
            break;
    }

    glutPostRedisplay();
}

int main(int argc, char * argv[]) {
    gltSetWorkingDirectory(argv[0]);
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH | GLUT_STENCIL);
    glutInitWindowSize(400, 400);
    glutCreateWindow("渲染技巧");
    glutReshapeFunc(changeSize);
    glutSpecialFunc(specialKeys);
    glutDisplayFunc(renderScene);
    //添加右击菜单栏
    // Create the Menu
    glutCreateMenu(processMenu);//注册回调函数
    ///添加菜单选项
    glutAddMenuEntry("正背面剔除开关",1);
    glutAddMenuEntry("深度测试开关",2);
    glutAddMenuEntry("面模式", 3);
    glutAddMenuEntry("线模式", 4);
    glutAddMenuEntry("点模式", 5);
    /// 鼠标右键触发
    glutAttachMenu(GLUT_RIGHT_BUTTON);
    GLenum err = glewInit();
    if (GLEW_OK != err) {
        fprintf(stderr, "GLEW Error: %s\n", glewGetErrorString(err));
        return 1;
    }
    setupRC();
    glutMainLoop();
    return 0;
}
