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
#include <math.h>
#include "GLMatrixStack.h"
#include "GLFrame.h"
#include "GLFrustum.h"
#include "GLBatch.h"
#include "GLGeometryTransform.h"
#include "StopWatch.h"

GLShaderManager        shaderManager;
GLMatrixStack        modelViewMatrix;
GLMatrixStack        projectionMatrix;
GLFrame                cameraFrame;//观察者位置
GLFrame             objectFrame;//世界坐标位置
GLFrustum            viewFrustum;//视景体，用来构造投影矩阵

GLTriangleBatch     sphereBatch;//球
GLTriangleBatch     torusBatch;//甜甜圈
GLTriangleBatch     cylinderBatch;//圆柱
GLTriangleBatch     coneBatch;//锥
GLTriangleBatch     diskBatch;//光盘

GLGeometryTransform    transformPipeline;
M3DMatrix44f        shadowMatrix;

GLfloat vGreen[] = { 0.0f, 1.0f, 0.0f, 1.0f };
GLfloat vBlack[] = { 0.0f, 0.0f, 0.0f, 1.0f };

int nStep = 0;
/// 是否是移动物体
int objectMove = 1;
/// 是否是物体旋转
int objectRotate = 1;

void setupRC()
{
    //1.
    glClearColor(0.7f, 0.7f, 0.7f, 1.0f );
    shaderManager.InitializeStockShaders();

    //2.开启深度测试
    glEnable(GL_DEPTH_TEST);

    if (objectMove == 1) {
        //将物体向屏幕外移动15.0
        objectFrame.MoveForward(15.0f);
    }else {
        //将观察者坐标位置Z移动往屏幕里移动15个单位位置
        //表示离屏幕之间的距离 负数，是往屏幕后面移动；正数，往屏幕前面移动
        cameraFrame.MoveForward(-15.0f);
    }


    //4.利用三角形批次类构造图形对象
    // 球
    /*
      gltMakeSphere(GLTriangleBatch& sphereBatch, GLfloat fRadius, GLint iSlices, GLint iStacks);
     参数1：sphereBatch，三角形批次类对象
     参数2：fRadius，球体半径
     参数3：iSlices，从球体底部堆叠到顶部的三角形带的数量；其实球体是一圈一圈三角形带组成
     参数4：iStacks，围绕球体一圈排列的三角形对数

     建议：一个对称性较好的球体的片段数量是堆叠数量的2倍，就是iStacks = 2 * iSlices;
     绘制球体都是围绕Z轴，这样+z就是球体的顶点，-z就是球体的底部。
     */
    gltMakeSphere(sphereBatch, 3.0, 10, 20);

    // 环面
    /*
     gltMakeTorus(GLTriangleBatch& torusBatch, GLfloat majorRadius, GLfloat minorRadius, GLint numMajor, GLint numMinor);
     参数1：torusBatch，三角形批次类对象
     参数2：majorRadius,甜甜圈中心到外边缘的半径
     参数3：minorRadius,甜甜圈中心到内边缘的半径
     参数4：numMajor,沿着主半径的三角形数量
     参数5：numMinor,沿着内部较小半径的三角形数量
     */
    gltMakeTorus(torusBatch, 3.0f, 0.75f, 15, 15);

    // 圆柱
    /*
     void gltMakeCylinder(GLTriangleBatch& cylinderBatch, GLfloat baseRadius, GLfloat topRadius, GLfloat fLength, GLint numSlices, GLint numStacks);
     参数1：cylinderBatch，三角形批次类对象
     参数2：baseRadius,底部半径
     参数3：topRadius,头部半径
     参数4：fLength,圆形长度
     参数5：numSlices,围绕Z轴的三角形对的数量
     参数6：numStacks,圆柱底部堆叠到顶部圆环的三角形数量
     */
    gltMakeCylinder(cylinderBatch, 2.0f, 2.0f, 3.0f, 15, 2);

    //锥
    /*
     void gltMakeCylinder(GLTriangleBatch& cylinderBatch, GLfloat baseRadius, GLfloat topRadius, GLfloat fLength, GLint numSlices, GLint numStacks);
     参数1：cylinderBatch，三角形批次类对象
     参数2：baseRadius,底部半径
     参数3：topRadius,头部半径
     参数4：fLength,圆形长度
     参数5：numSlices,围绕Z轴的三角形对的数量
     参数6：numStacks,圆柱底部堆叠到顶部圆环的三角形数量
     */
    //圆柱体，从0开始向Z轴正方向延伸。
    //圆锥体，是一端的半径为0，另一端半径可指定。
    gltMakeCylinder(coneBatch, 2.0f, 0.0f, 3.0f, 13, 2);

    // 光盘
    /*
    void gltMakeDisk(GLTriangleBatch& diskBatch, GLfloat innerRadius, GLfloat outerRadius, GLint nSlices, GLint nStacks);
     参数1:diskBatch，三角形批次类对象
     参数2:innerRadius,内圆半径
     参数3:outerRadius,外圆半径
     参数4:nSlices,圆盘围绕Z轴的三角形对的数量
     参数5:nStacks,圆盘外网到内围的三角形数量
     */
    gltMakeDisk(diskBatch, 1.5f, 3.0f, 13, 3);
}


void changeSize(int w, int h) {
    if (h == 0) {
        h = 1;
    }
    //1.视口
    glViewport(0, 0, w, h);
    //2.透视投影
    viewFrustum.SetPerspective(35.0f, float(w) / float(h), 1.0f, 500.0f);
    //projectionMatrix 矩阵堆栈 加载透视投影矩阵
    projectionMatrix.LoadMatrix(viewFrustum.GetProjectionMatrix());
    //3.modelViewMatrix 矩阵堆栈 加载单元矩阵
    modelViewMatrix.LoadIdentity();
    //4.通过GLGeometryTransform管理矩阵堆栈
    //使用transformPipeline 管道管理模型视图矩阵堆栈 和 投影矩阵堆栈
    transformPipeline.SetMatrixStacks(modelViewMatrix, projectionMatrix);
}
//点击空格，切换渲染图形
void keyPressFunc(unsigned char key, int x, int y)
{
    if(key == 32)
    {
        nStep++;
        if(nStep > 4)
            nStep = 0;
    }
    switch(nStep)
    {
        case 0:
            glutSetWindowTitle("球");
            break;
        case 1:
            glutSetWindowTitle("甜甜圈");
            break;
        case 2:
            glutSetWindowTitle("圆柱");
            break;
        case 3:
            glutSetWindowTitle("圆锥");
            break;
        case 4:
            glutSetWindowTitle("光盘");
            break;
    }

    glutPostRedisplay();
}

//上下左右，旋转图形
void specialKeys(int key, int x, int y){
    if (objectRotate == 1) {
        /// 物体旋转
        if(key == GLUT_KEY_UP)
            objectFrame.RotateWorld(m3dDegToRad(-5.0f), 1.0f, 0.0f, 0.0f);

        if(key == GLUT_KEY_DOWN)
            objectFrame.RotateWorld(m3dDegToRad(5.0f), 1.0f, 0.0f, 0.0f);

        if(key == GLUT_KEY_LEFT)
            objectFrame.RotateWorld(m3dDegToRad(-5.0f), 0.0f, 1.0f, 0.0f);

        if(key == GLUT_KEY_RIGHT)
            objectFrame.RotateWorld(m3dDegToRad(5.0f), 0.0f, 1.0f, 0.0f);
    }else {
        /// 摄像机旋转
        if(key == GLUT_KEY_UP)
            cameraFrame.RotateWorld(m3dDegToRad(-5.0f), 1.0f, 0.0f, 0.0f);

        if(key == GLUT_KEY_DOWN)
            cameraFrame.RotateWorld(m3dDegToRad(5.0f), 1.0f, 0.0f, 0.0f);

        if(key == GLUT_KEY_LEFT)
            cameraFrame.RotateWorld(m3dDegToRad(-5.0f), 0.0f, 1.0f, 0.0f);

        if(key == GLUT_KEY_RIGHT)
            cameraFrame.RotateWorld(m3dDegToRad(5.0f), 0.0f, 1.0f, 0.0f);
    }

    glutPostRedisplay();
}

void DrawWireFramedBatch(GLTriangleBatch* pBatch)
{
    //----绘制图形----
    //1.默认光源着色器，绘制三角形
    shaderManager.UseStockShader(GLT_SHADER_DEFAULT_LIGHT, transformPipeline.GetModelViewMatrix(), transformPipeline.GetProjectionMatrix(), vGreen);
     //传过来的参数，对应不同的图形Batch
    pBatch->Draw();

    //---画出黑色轮廓---

    //2.开启多边形偏移
    glEnable(GL_POLYGON_OFFSET_LINE);
    //多边形模型(背面、线) 将多边形背面设为线框模式
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    //开启多边形偏移(设置偏移数量)
    glPolygonOffset(-1.0f, -1.0f);
    //线条宽度
    glLineWidth(2.0f);

    //3.开启混合功能(颜色混合&抗锯齿功能)
    glEnable(GL_BLEND);
    //开启处理线段抗锯齿功能
    glEnable(GL_LINE_SMOOTH);
    //设置颜色混合因子
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

   //4.默认光源着色器绘制线条
    shaderManager.UseStockShader(GLT_SHADER_DEFAULT_LIGHT, transformPipeline.GetModelViewMatrix(), transformPipeline.GetProjectionMatrix(), vBlack);

    pBatch->Draw();

    //5.恢复多边形模式和深度测试
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    glDisable(GL_POLYGON_OFFSET_LINE);
    glLineWidth(1.0f);
    glDisable(GL_BLEND);
    glDisable(GL_LINE_SMOOTH);
}

void renderScene(void) {
    //1.用当前清除颜色清除窗口背景
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    //2.模型视图矩阵栈堆，压栈
    if (objectMove == 1) {
        modelViewMatrix.PushMatrix(objectFrame);
    }else {
        //2.模型视图矩阵栈堆，压栈
        modelViewMatrix.PushMatrix();
        //3.获取摄像头矩阵
        M3DMatrix44f mCamera;
        //从camereaFrame中获取矩阵到mCamera
        cameraFrame.GetCameraMatrix(mCamera);
        //模型视图堆栈的 矩阵与mCamera矩阵 相乘之后，存储到modelViewMatrix矩阵堆栈中
        modelViewMatrix.MultMatrix(mCamera);
        //4.创建矩阵mObjectFrame
        M3DMatrix44f mObjectFrame;
        //从ObjectFrame 获取矩阵到mOjectFrame中
        objectFrame.GetMatrix(mObjectFrame);
        //将modelViewMatrix 的堆栈中的矩阵 与 mOjbectFrame 矩阵相乘，存储到modelViewMatrix矩阵堆栈中
        modelViewMatrix.MultMatrix(mObjectFrame);
    }

    //3.判断你目前是绘制第几个图形
    switch(nStep) {
        case 0:
            DrawWireFramedBatch(&sphereBatch);
            break;
        case 1:
            DrawWireFramedBatch(&torusBatch);
            break;
        case 2:
            DrawWireFramedBatch(&cylinderBatch);
            break;
        case 3:
            DrawWireFramedBatch(&coneBatch);
            break;
        case 4:
            DrawWireFramedBatch(&diskBatch);
            break;
    }
    //4. pop
    modelViewMatrix.PopMatrix();

    //5.
    glutSwapBuffers();
}


int main(int argc, char * argv[]) {
    gltSetWorkingDirectory(argv[0]);
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH | GLUT_STENCIL);
    glutInitWindowSize(400, 400);
    glutCreateWindow("球");
    GLenum err = glewInit();
    if (GLEW_OK != err) {
        fprintf(stderr, "GLEW Error: %s\n", glewGetErrorString(err));
        return 1;
    }
    glutReshapeFunc(changeSize);
    glutKeyboardFunc(keyPressFunc);
    glutSpecialFunc(specialKeys);
    glutDisplayFunc(renderScene);
    setupRC();

    glutMainLoop();
    return 0;
}
