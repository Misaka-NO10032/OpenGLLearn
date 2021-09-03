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
#include "GLBatch.h"
#include "GLGeometryTransform.h"

GLShaderManager        shaderManager;//存储着色器管理工具
GLMatrixStack          modelViewMatrix;//模型视图矩阵
GLMatrixStack          projectionMatrix;//投影矩阵
GLFrame                cameraFrame;//观察者
GLFrame                objectFrame;//物体
GLFrustum              viewFrustum;//设置图元绘制时的投影方式
//容器类（7种不同的图元对应7种容器对象）
GLBatch                pointBatch;
GLBatch                lineBatch;
GLBatch                lineStripBatch;
GLBatch                lineLoopBatch;
GLBatch                triangleBatch;
GLBatch                triangleStripBatch;
GLBatch                triangleFanBatch;
//几何变换的管道
GLGeometryTransform    transformPipeline;
//颜色
GLfloat vGreen[] = { 0.0f, 1.0f, 0.0f, 1.0f };
GLfloat vBlack[] = { 0.0f, 0.0f, 0.0f, 1.0f };
// 控制渲染哪个图元
int nStep = 0;

// 点
void setupPointBatch() {
    GLfloat vCoast[12] = {
        2,2,0,
        -2,2,0,
        -2,-2,0,
        2,-2,0
    };
    pointBatch.Begin(GL_POINTS, 4);
    pointBatch.CopyVertexData3f(vCoast);
    pointBatch.End();
}
// 线段
void setupLineBatch() {
    GLfloat vCoast[12] = {
        2,2,0,
        -2,2,0,
        -2,-2,0,
        2,-2,0
    };
    lineBatch.Begin(GL_LINES, 4);
    lineBatch.CopyVertexData3f(vCoast);
    lineBatch.End();
}
//线段-连续
void setupLineStripBatch() {
    GLfloat vCoast[12] = {
        2,2,0,
        -2,2,0,
        -2,-2,0,
        2,-2,0
    };
    lineStripBatch.Begin(GL_LINE_STRIP, 4);
    lineStripBatch.CopyVertexData3f(vCoast);
    lineStripBatch.End();
}
//线段-环
void setupLineLoopBatch() {
    GLfloat vCoast[15] = {
        2,2,0,
        -2,2,0,
        -2,-2,0,
        0,0,0,
        2,-2,0
    };
    lineLoopBatch.Begin(GL_LINE_LOOP, 5);
    lineLoopBatch.CopyVertexData3f(vCoast);
    lineLoopBatch.End();
}
//金字塔
void setupTriangleBatch() {
    GLfloat vPyramid[12][3] {
        -2.0f, 0.0f, -2.0f,
        2.0f, 0.0f, -2.0f,
        0.0f, 4.0f, 0.0f,

        2.0f, 0.0f, -2.0f,
        2.0f, 0.0f, 2.0f,
        0.0f, 4.0f, 0.0f,

        2.0f, 0.0f, 2.0f,
        -2.0f, 0.0f, 2.0f,
        0.0f, 4.0f, 0.0f,

        -2.0f, 0.0f, 2.0f,
        -2.0f, 0.0f, -2.0f,
        0.0f, 4.0f, 0.0f
    };
    triangleBatch.Begin(GL_TRIANGLES, 12);
    triangleBatch.CopyVertexData3f(vPyramid);
    triangleBatch.End();
}

// 伞面
void setupTriangleFanBatch() {
    GLfloat vPoints[20][3];
        int nVerts = 0;
        GLfloat r = 3.0;//半径
        //伞顶坐标
        vPoints[nVerts][0] = 0.0;
        vPoints[nVerts][1] = 0.0;
        vPoints[nVerts][2] = -1;
        // 8骨伞
        for (GLfloat angle = 0; angle < M3D_2PI; angle += M3D_2PI / 8.0f) {
            nVerts ++;
            vPoints[nVerts][0] = float(cos(angle)) * r;
            vPoints[nVerts][1] = float(sin(angle)) * r;
            vPoints[nVerts][2] = 0.0;
        }
        // 添加一个重合点来闭合
        nVerts ++;
        vPoints[nVerts][0] = r;
        vPoints[nVerts][1] = 0.0;
        vPoints[nVerts][2] = 0.0;
        //GL_TRIANGLE_FAN 以一个圆心为中心呈扇形排列，共用相邻顶点的一组三角形
        triangleFanBatch.Begin(GL_TRIANGLE_FAN, 10);
        triangleFanBatch.CopyVertexData3f(vPoints);
        triangleFanBatch.End();
}

// 圆柱
void setupTriangleStripBatch() {
    GLfloat vPoints[100][3];
    //顶点下标
    int index = 0;
    //半径
    GLfloat radius = 3.0f;
    for (GLfloat angle = 0; angle < M3D_2PI; angle += M3D_2PI / 30.0f) {
        vPoints[index][0] = float(cos(angle)) * radius;
        vPoints[index][1] = float(sin(angle)) * radius;
        vPoints[index][2] = 2;
        index ++;
        vPoints[index][0] = float(cos(angle)) * radius;
        vPoints[index][1] = float(sin(angle)) * radius;
        vPoints[index][2] = -2;
        index ++;
    }
    // 添加一个重合点来闭合
       vPoints[index][0] = vPoints[0][0];
       vPoints[index][1] = vPoints[0][1];
       vPoints[index][2] = vPoints[0][2];
       index ++;

    // GL_TRIANGLE_STRIP 共用一个条带（strip）上的顶点的一组三角形
    triangleStripBatch.Begin(GL_TRIANGLE_STRIP, index);
    triangleStripBatch.CopyVertexData3f(vPoints);
    triangleStripBatch.End();

}


// 设置渲染环境
void setupRC() {
    glClearColor(0.7, 0.7, 0.7, 1.0);//设置清屏颜色
    shaderManager.InitializeStockShaders();//初始化着色器管理
    glEnable(GL_DEPTH_TEST);//开启深度测试
    transformPipeline.SetMatrixStacks(modelViewMatrix, projectionMatrix);//设置矩阵堆栈
    cameraFrame.MoveForward(-15.0f);//观察者向后移动15(世界坐标改变)
    //图元容器配置
    setupPointBatch();
    setupLineBatch();
    setupLineStripBatch();
    setupLineLoopBatch();
    setupTriangleBatch();
    setupTriangleFanBatch();
    setupTriangleStripBatch();
}


// 窗口尺寸变化
void changeSize(int w, int h) {
    glViewport(0, 0, w, h);
    // 设置透视投影, 因为透视投影要设置纵横比所以放在这里来设置
    viewFrustum.SetPerspective(50, float(w)/float(h), 1.0f, 500.0f);
    // 给投影矩阵堆栈载入，当前透视投影得到的透视投影矩阵
    projectionMatrix.LoadMatrix(viewFrustum.GetProjectionMatrix());
    // 给模型堆栈载入一个单位矩阵(其实默认就有单位矩阵，所以可以不设置的)
    modelViewMatrix.LoadIdentity();
}

// 空格
void keyboardKey(unsigned char key, int x, int y) {
    // 控制渲染哪个图元容器，和窗口名
    if (key == 32) {
        nStep ++;
        if (nStep > 6) {
            nStep = 0;
        }
    }
    switch (nStep) {
        case 0:
            glutSetWindowTitle("点");
            break;
        case 1:
            glutSetWindowTitle("线段");
            break;
        case 2:
            glutSetWindowTitle("线段-连续");
            break;
        case 3:
            glutSetWindowTitle("线段-环");
            break;
        case 4:
            glutSetWindowTitle("金字塔");
            break;
        case 5:
            glutSetWindowTitle("伞面");
            break;
        case 6:
            glutSetWindowTitle("圆柱");
            break;

        default:
            break;
    }
    //重绘
    glutPostRedisplay();
}
// 特殊键位
void specialKey(int key, int x, int y) {
    //根据上下左右，修改物体参考帧
    if (key == GLUT_KEY_UP) {
        objectFrame.RotateWorld(m3dDegToRad(-10.0f), 1.0, 0.0, 0.0);
    }
    if (key == GLUT_KEY_DOWN) {
        objectFrame.RotateWorld(m3dDegToRad(10.0f), 1.0, 0.0, 0.0);
    }
    if (key == GLUT_KEY_LEFT) {
        objectFrame.RotateWorld(m3dDegToRad(-10.0f), 0.0, 1.0, 0.0);
    }
    if (key == GLUT_KEY_RIGHT) {
        objectFrame.RotateWorld(m3dDegToRad(10.0f), 0.0, 1.0, 0.0);
    }
    //重新绘制
    glutPostRedisplay();
}
// 具体绘制
void render() {
    switch(nStep) {
        case 0://点
            //采用平面着色器
            shaderManager.UseStockShader(GLT_SHADER_FLAT, transformPipeline.GetModelViewProjectionMatrix(),vBlack);
            //设置点的大小
            glPointSize(10.0f);
            pointBatch.Draw();
            glPointSize(1.0f);//用完了记得设置还原回去
            break;
        case 1://线段
            //采用平面着色器
            shaderManager.UseStockShader(GLT_SHADER_FLAT, transformPipeline.GetModelViewProjectionMatrix(),vBlack);
            //设置线宽
            glLineWidth(4.0);
            lineBatch.Draw();
            glLineWidth(1.0);//复原线宽
            break;
        case 2://线段-连续
            //采用平面着色器
            shaderManager.UseStockShader(GLT_SHADER_FLAT, transformPipeline.GetModelViewProjectionMatrix(),vBlack);
            glLineWidth(4.0);
            lineStripBatch.Draw();
            glLineWidth(1.0);//复原线宽
            break;
        case 3://线段-环
            //采用平面着色器
            shaderManager.UseStockShader(GLT_SHADER_FLAT, transformPipeline.GetModelViewProjectionMatrix(),vBlack);
            glLineWidth(4.0);
            lineLoopBatch.Draw();
            glLineWidth(1.0);//复原线宽
            break;
        case 4://金字塔
            // 画三角形面
            //采用平面着色器
            shaderManager.UseStockShader(GLT_SHADER_FLAT, transformPipeline.GetModelViewProjectionMatrix(),vGreen);
            triangleBatch.Draw();
            // 画边框
            glPolygonOffset(-1, -1);//偏移深度，在同一位置要绘制填充和边线，会产生z冲突，所以要偏移
            glEnable(GL_POLYGON_OFFSET_LINE);
            // 画反锯齿，让黑边好看些
            glEnable(GL_LINE_SMOOTH);//线条流畅，防锯齿
            glEnable(GL_BLEND);//开启颜色混合
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);//设置颜色混合模式
            //绘制线框几何黑色版 三种模式，实心，边框，点，可以作用在正面，背面，或者两面
            //通过调用glPolygonMode将多边形正面或者背面设为线框模式，实现线框渲染
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);//设置颜色填充模式
            //设置线条宽度
            glLineWidth(2.5f);
            shaderManager.UseStockShader(GLT_SHADER_FLAT, transformPipeline.GetModelViewProjectionMatrix(), vBlack);
            triangleBatch.Draw();
            //复原设置
            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);//通过调用glPolygonMode将多边形正面或者背面设为全部填充模式
            glDisable(GL_POLYGON_OFFSET_LINE);
            glLineWidth(1.0f);
            glDisable(GL_BLEND);
            glDisable(GL_LINE_SMOOTH);
            break;
        case 5://伞面
            shaderManager.UseStockShader(GLT_SHADER_FLAT, transformPipeline.GetModelViewProjectionMatrix(),vGreen);
            triangleFanBatch.Draw();
            // 画边框
            glPolygonOffset(-1, -1);//偏移深度，在同一位置要绘制填充和边线，会产生z冲突，所以要偏移
            glEnable(GL_POLYGON_OFFSET_LINE);
            // 画反锯齿，让黑边好看些
            glEnable(GL_LINE_SMOOTH);
            glEnable(GL_BLEND);
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            //绘制线框几何黑色版 三种模式，实心，边框，点，可以作用在正面，背面，或者两面
            //通过调用glPolygonMode将多边形正面或者背面设为线框模式，实现线框渲染
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            //设置线条宽度
            glLineWidth(2.5f);
            shaderManager.UseStockShader(GLT_SHADER_FLAT, transformPipeline.GetModelViewProjectionMatrix(), vBlack);
            triangleFanBatch.Draw();
            //复原设置
            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);//通过调用glPolygonMode将多边形正面或者背面设为全部填充模式
            glDisable(GL_POLYGON_OFFSET_LINE);
            glLineWidth(1.0f);
            glDisable(GL_BLEND);
            glDisable(GL_LINE_SMOOTH);
            break;
        case 6://圆柱
            shaderManager.UseStockShader(GLT_SHADER_FLAT, transformPipeline.GetModelViewProjectionMatrix(),vGreen);
            triangleStripBatch.Draw();
            // 画边框
            glPolygonOffset(-1, -1);//偏移深度，在同一位置要绘制填充和边线，会产生z冲突，所以要偏移
            glEnable(GL_POLYGON_OFFSET_LINE);
            // 画反锯齿，让黑边好看些
            glEnable(GL_LINE_SMOOTH);
            glEnable(GL_BLEND);
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            //绘制线框几何黑色版 三种模式，实心，边框，点，可以作用在正面，背面，或者两面
            //通过调用glPolygonMode将多边形正面或者背面设为线框模式，实现线框渲染
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            //设置线条宽度
            glLineWidth(2.5f);
            shaderManager.UseStockShader(GLT_SHADER_FLAT, transformPipeline.GetModelViewProjectionMatrix(), vBlack);
            triangleStripBatch.Draw();
            //复原设置
            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);//通过调用glPolygonMode将多边形正面或者背面设为全部填充模式
            glDisable(GL_POLYGON_OFFSET_LINE);
            glLineWidth(1.0f);
            glDisable(GL_BLEND);
            glDisable(GL_LINE_SMOOTH);
            break;
        default:
            break;
    }
}
/* 压栈出栈是为了使每次渲染相互独立，避免本次的设置影响后续设置，因为OpenGL是个状态机，每次操作都会记录的，所以要压栈出当前状态的复制，用这次复制来进行操作，操作完后把副本出栈，现在状态机里就的就还是本次操作之前的状态了
*/
// 渲染
void renderScene() {
    // 清理缓存区
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

    //压栈
    modelViewMatrix.PushMatrix();
    M3DMatrix44f mCamera;//声明观察者矩阵
    cameraFrame.GetCameraMatrix(mCamera);//获得观察者矩阵,用mCamera存储
    //栈顶矩阵乘以mCamera，这一步控制显示位置
    modelViewMatrix.MultMatrix(mCamera);
    M3DMatrix44f mObjectFrame;//声明物体坐标矩阵
    objectFrame.GetMatrix(mObjectFrame);//获得物体坐标矩阵,用mObjectFrame存储
    //栈顶矩阵乘以mObjectFrame，这一步控制物体相对自身物体坐标系位置(移动、旋转等)
    modelViewMatrix.MultMatrix(mObjectFrame);
    // 具体绘制内容设置
    render();

    //出栈
    modelViewMatrix.PopMatrix();
    //交换缓冲区
    glutSwapBuffers();
}

int main(int argc, char * argv[]) {
    gltSetWorkingDirectory(argv[0]);
    glutInit(&argc, argv);
    //申请一个双缓存区、颜色缓存区、深度缓存区、模板缓存区
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH | GLUT_STENCIL);
    //设置window 的尺寸
    glutInitWindowSize(600, 600);
    //window名字
    glutCreateWindow("点");
    // 重塑(窗口尺寸变化)回调
    glutReshapeFunc(changeSize);
    // 点击键盘(空格 == 32)回调
    glutKeyboardFunc(keyboardKey);
    // 点击特殊键位(上下左右)回调
    glutSpecialFunc(specialKey);
    // 显示(渲染)回调
    glutDisplayFunc(renderScene);
    // 初始化GLEW库
    GLenum state = glewInit();
    if (state != GLEW_OK) {
        fprintf(stderr, "GLEW Error: %s\n", glewGetErrorString(state));
        return 1;
    }
    // 设置渲染环境
    setupRC();
    // 开启loop
    glutMainLoop();
    return 0;
}
