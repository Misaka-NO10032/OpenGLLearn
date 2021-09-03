//
//  main.m
//  OpenGL
//
//  Created by Misaka on 2019/9/6.
//  Copyright © 2019 Misaka. All rights reserved.
//

#include <stdio.h>
#include "GLTools.h"
#include <GLUT/GLUT.h>
#include "GLShaderManager.h"
#include "GLFrustum.h"
#include "GLBatch.h"
#include "GLFrame.h"
#include "GLMatrixStack.h"
#include "GLGeometryTransform.h"

GLShaderManager shaderManager;//着色器管理器
GLMatrixStack modelViewMatrix;//模型视图矩阵堆栈
GLMatrixStack projectionMatrix;//投影矩阵堆栈
GLFrame cameraFrame;//摄像机角色帧
GLFrame objectFrame;//物体角色帧
GLFrustum viewFrustum;//视景体
GLBatch pyramidBatch;//批次类
GLGeometryTransform transformPipeline;//变换管道
GLuint textureID;//纹理变量，一般使用无符号整型

void changeSize(int w, int h) {
    glViewport(0, 0, w, h);//设置视口
    viewFrustum.SetPerspective(35.0f, float(w)/float(h), 1.0f, 500.0f);//创建投影矩阵
    projectionMatrix.LoadMatrix(viewFrustum.GetProjectionMatrix());//加载到投影矩阵堆栈上
    transformPipeline.SetMatrixStacks(modelViewMatrix, projectionMatrix);//设置变换管道以使用两个矩阵堆栈
}

void renderScene() {
    static GLfloat vLightPos [] = { 2.0f, 2.0f, 0.0f };//光源位置
    static GLfloat vWhite [] = { 1.0f, 1.0f, 1.0f, 1.0f };//基本漫反射颜色
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

    // 压栈
    modelViewMatrix.PushMatrix();
    // 模型变换(平移/旋转)
    M3DMatrix44f mCamera;
    cameraFrame.GetCameraMatrix(mCamera);
    modelViewMatrix.MultMatrix(mCamera);
    M3DMatrix44f mObject;
    objectFrame.GetMatrix(mObject);
    modelViewMatrix.MultMatrix(mObject);
    

    //绑定纹理
    glBindTexture(GL_TEXTURE_2D, textureID);
    //使用点光源着色器
    shaderManager.UseStockShader(GLT_SHADER_TEXTURE_POINT_LIGHT_DIFF,//点光源着色器标记
                                 transformPipeline.GetModelViewMatrix(),//模型视图矩阵
                                 transformPipeline.GetProjectionMatrix(),//投影矩阵
                                 vLightPos,//视点坐标系中的光源位置
                                 vWhite,//基本漫反射颜色
                                 0);//图形颜色（用纹理就不需要设置颜色。设置为0）
    // 绘制
    pyramidBatch.Draw();
    //出栈
    modelViewMatrix.PopMatrix();
    //交换缓存区
    glutSwapBuffers();
}

void specialKey(int key , int x, int y) {
    if (key == GLUT_KEY_UP) {
        //m3dDegToRad： 角度转弧度
        objectFrame.RotateWorld(m3dDegToRad(-5.0f), 1.0, 0.0, 0.0);
    }
    if (key == GLUT_KEY_DOWN) {
        objectFrame.RotateWorld(m3dDegToRad(5.0f), 1.0, 0.0, 0.0);
    }
    if (key == GLUT_KEY_LEFT) {
        objectFrame.RotateWorld(m3dDegToRad(-5.0f), 0.0, 1.0, 0.0);
    }
    if (key == GLUT_KEY_RIGHT) {
        objectFrame.RotateWorld(m3dDegToRad(5.0f), 0.0, 1.0, 0.0);
    }
    glutPostRedisplay();
}

void setupRC () {
    glClearColor(0.7, 0.7, 0.7, 1.0);//设置清屏颜色
    shaderManager.InitializeStockShaders();
    glEnable(GL_DEPTH_TEST);
    cameraFrame.MoveForward(-10);

    //分配纹理对象
    glGenTextures(1, &textureID);//参数1:纹理对象个数，参数2:纹理对象指针
    //绑定纹理状态
    glBindTexture(GL_TEXTURE_2D, textureID);//参数1：纹理状态(2D) 参数2：纹理对象
    // 从tga文件加载纹理
    GLbyte *pBits;
    int nWidth, nHeight, nComponents;
    GLenum eFormat;
    //读纹理位，读取像素 参数1：纹理文件名称;参数2：文件宽度地址;参数3：文件高度地址;参数4：文件组件地址;参数5：文件格式地址;返回值：pBits,指向图像数据的指针
    pBits = gltReadTGABits("stone.tga", &nWidth, &nHeight, &nComponents, &eFormat);
    if(pBits == NULL)
    return ;
    // 载入纹理
    glTexImage2D(GL_TEXTURE_2D, 0, nComponents, nWidth, nHeight, 0,
    eFormat, GL_UNSIGNED_BYTE, pBits);
    //使用完毕释放pBits
    free(pBits);
    //设置纹理
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);


    // 通过pyramidBatch组建三角形批次  参数1：类型  参数2：顶点数 参数3：这个批次中将会应用1个纹理(如果不写这个参数，默认为0)
    pyramidBatch.Begin(GL_TRIANGLES, 18, 1);
    //各个顶点向量
    M3DVector3f vTop = {0.0, 1.0, 0.0};
    M3DVector3f vLeftFront = {-1.0, -1.0, -1.0};
    M3DVector3f vRightFront = {1.0, -1.0, -1.0};
    M3DVector3f vLeftBack = {-1.0, -1.0, 1.0};
    M3DVector3f vRightBack = {1.0, -1.0, 1.0};
    //法线向量
    M3DVector3f vNormal;

    /*
     要正确使用光照，需要设置法线
     要正确的把纹理设置到物体上，需要设置纹理坐标
     */
    /*设置纹理坐标
    oid MultiTexCoord2f(GLuint texture, GLclampf s, GLclampf t);
    参数1：texture，纹理层次，对于使用存储着色器来进行渲染，设置为0
    参数2：s：对应顶点坐标中的x坐标
    参数3：t:对应顶点坐标中的y
    (s,t,r,q对应顶点坐标的x,y,z,w)
    */
    //前面三角形(观察者方向正面绘制纹理)
    m3dFindNormal(vNormal, vTop, vRightFront, vLeftFront);//获取法线

    pyramidBatch.Normal3fv(vNormal);//设置法线
    pyramidBatch.MultiTexCoord2f(0, 0.5, 1.0);//设置纹理坐标
    pyramidBatch.Vertex3fv(vTop);//设置顶点

    pyramidBatch.Normal3fv(vNormal);
    pyramidBatch.MultiTexCoord2f(0, 0.0, 0.0);
    pyramidBatch.Vertex3fv(vRightFront);

    pyramidBatch.Normal3fv(vNormal);
    pyramidBatch.MultiTexCoord2f(0, 1.0, 0.0);
    pyramidBatch.Vertex3fv(vLeftFront);

    //后面三角形(观察者方向背面绘制纹理)
    m3dFindNormal(vNormal, vTop, vLeftBack, vRightBack);

    pyramidBatch.Normal3fv(vNormal);
    pyramidBatch.MultiTexCoord2f(0, 0.5, 3.0);
    pyramidBatch.Vertex3fv(vTop);

    pyramidBatch.Normal3fv(vNormal);
    pyramidBatch.MultiTexCoord2f(0, 1.0, 0.0);
    pyramidBatch.Vertex3fv(vLeftBack);

    pyramidBatch.Normal3fv(vNormal);
    pyramidBatch.MultiTexCoord2f(0, 0.0, 0.0);
    pyramidBatch.Vertex3fv(vRightBack);

    //左面三角形 观察者方向背面绘制纹理
    m3dFindNormal(vNormal, vTop, vRightBack, vRightFront);

    pyramidBatch.Normal3fv(vNormal);
    pyramidBatch.MultiTexCoord2f(0, 0.5, 2.0);
    pyramidBatch.Vertex3fv(vTop);

    pyramidBatch.Normal3fv(vNormal);
    pyramidBatch.MultiTexCoord2f(0, 0.0, 0.0);
    pyramidBatch.Vertex3fv(vRightBack);

    pyramidBatch.Normal3fv(vNormal);
    pyramidBatch.MultiTexCoord2f(0, 1.0, 0.0);
    pyramidBatch.Vertex3fv(vRightFront);
    //右面三角形 观察者方向背面绘制纹理
    m3dFindNormal(vNormal, vTop, vLeftFront, vLeftBack);

    pyramidBatch.Normal3fv(vNormal);
    pyramidBatch.MultiTexCoord2f(0, 0.5, 4.0);
    pyramidBatch.Vertex3fv(vTop);

    pyramidBatch.Normal3fv(vNormal);
    pyramidBatch.MultiTexCoord2f(0, 0.0, 0.0);
    pyramidBatch.Vertex3fv(vLeftFront);

    pyramidBatch.Normal3fv(vNormal);
    pyramidBatch.MultiTexCoord2f(0, 1.0, 0.0);
    pyramidBatch.Vertex3fv(vLeftBack);
    //底部正方形（2个三角形）观察者方向背面绘制纹理
    m3dFindNormal(vNormal, vLeftBack, vLeftFront, vRightFront);

    pyramidBatch.Normal3fv(vNormal);
    pyramidBatch.MultiTexCoord2f(0, 0.0, 1.0);
    pyramidBatch.Vertex3fv(vLeftBack);

    pyramidBatch.Normal3fv(vNormal);
    pyramidBatch.MultiTexCoord2f(0, 0.0, 0.0);
    pyramidBatch.Vertex3fv(vLeftFront);

    pyramidBatch.Normal3fv(vNormal);
    pyramidBatch.MultiTexCoord2f(0, 1.0, 0.0);
    pyramidBatch.Vertex3fv(vRightFront);

    m3dFindNormal(vNormal, vRightFront, vRightBack, vLeftBack);

    pyramidBatch.Normal3fv(vNormal);
    pyramidBatch.MultiTexCoord2f(0, 1.0, 0.0);
    pyramidBatch.Vertex3fv(vRightFront);

    pyramidBatch.Normal3fv(vNormal);
    pyramidBatch.MultiTexCoord2f(0, 1.0, 1.0);
    pyramidBatch.Vertex3fv(vRightBack);

    pyramidBatch.Normal3fv(vNormal);
    pyramidBatch.MultiTexCoord2f(0, 0.0, 1.0);
    pyramidBatch.Vertex3fv(vLeftBack);

    pyramidBatch.End();
}

void shutdownRC () {
    glDeleteTextures(1, &textureID);
}

int main(int argc, char * argv[]) {
    gltSetWorkingDirectory(argv[0]);
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH | GLUT_STENCIL);
    glutInitWindowSize(400, 400);
    glutCreateWindow("金字塔状物体");
    GLenum error = glewInit();
    if (error != GLEW_OK) {
        fprintf(stderr, "GLEW Error: %s\n", glewGetErrorString(error));
        return 1;
    }
    glutReshapeFunc(changeSize);
    glutDisplayFunc(renderScene);
    glutSpecialFunc(specialKey);
    setupRC();
    glutMainLoop();
    shutdownRC();//结束时清理（例如删除纹理对象）
    return 0;
}
