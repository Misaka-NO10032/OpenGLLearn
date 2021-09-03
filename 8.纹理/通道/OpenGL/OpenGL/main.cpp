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

GLShaderManager        shaderManager;            //着色器管理器
GLMatrixStack        modelViewMatrix;        //模型视图矩阵
GLMatrixStack        projectionMatrix;        //投影矩阵
GLFrustum            viewFrustum;            //视景体
GLGeometryTransform    transformPipeline;        //几何变换管线
//4个批次容器类
GLBatch             floorBatch;//地面
GLBatch             ceilingBatch;//天花板
GLBatch             leftWallBatch;//左墙面
GLBatch             rightWallBatch;//右墙面

//深度初始值，-65。
GLfloat             viewZ = -65.0f;
// 纹理标识符号
#define TEXTURE_BRICK   0 //墙面
#define TEXTURE_FLOOR   1 //地板
#define TEXTURE_CEILING 2 //纹理天花板
#define TEXTURE_COUNT   3 //纹理个数

GLuint  textures[TEXTURE_COUNT];//纹理标记数组
//文件tag名字数组
const char *szTextureFiles[TEXTURE_COUNT] = { "brick.tga", "floor.tga", "ceiling.tga"};

char *title[8] = {"GL_NEAREST",
    " GL_LINEAR",
    "GL_NEAREST_MIPMAP_NEAREST",
    "GL_NEAREST_MIPMAP_LINEAR",
    "GL_LINEAR_MIPMAP_NEAREST",
    "GL_LINEAR_MIPMAP_LINEAR",
    "Anisotropic_ON",
    "Anisotropic_OFF"
};

void setupRC() {
    glClearColor(0.0, 0.0, 0.0, 1.0);
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
        //GL_TEXTURE_WRAP_S(s轴环绕),GL_CLAMP_TO_EDGE(环绕模式强制对范围之外的纹理坐标沿着合法的纹理单元的最后一行或一列进行采样)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        //GL_TEXTURE_WRAP_T(t轴环绕)，GL_CLAMP_TO_EDGE(环绕模式强制对范围之外的纹理坐标沿着合法的纹理单元的最后一行或一列进行采样)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

        //载入纹理
        glTexImage2D(GL_TEXTURE_2D, 0, iComponents, iWidth, iHeight, 0, eFormat, GL_UNSIGNED_BYTE, pBytes);

        //为纹理对象生成一组完整的mipmap glGenerateMipmap 参数1：纹理维度，GL_TEXTURE_1D,GL_TEXTURE_2D,GL_TEXTURE_2D
        glGenerateMipmap(GL_TEXTURE_2D);

        //释放原始纹理数据，我们已经载入到OpenGL里面去了，所以原始的可以释放掉
        free(pBytes);
    }

    GLfloat step = 10.0f;
    /// 顶点
    GLfloat floorLeftX = 10.0f;
    GLfloat floorRightX = -10.0f;
    GLfloat floorY = -10.0f;
    //地面 GL_TRIANGLE_STRIP:三角形带，共用一个条带上的顶点的一组三角形
    floorBatch.Begin(GL_TRIANGLE_STRIP, 28, 1);
    for (GLfloat z = 0.0f; z <= 60.0f; z += step) {
        floorBatch.MultiTexCoord2f(0, 0.0, 0.0);
        floorBatch.Vertex3f(floorLeftX, floorY, z);

        floorBatch.MultiTexCoord2f(0, 1.0, 0.0);
        floorBatch.Vertex3f(floorRightX, floorY, z);

        floorBatch.MultiTexCoord2f(0, 0.0, 1.0);
        floorBatch.Vertex3f(floorLeftX, floorY, z + step);

        floorBatch.MultiTexCoord2f(0, 1.0, 1.0);
        floorBatch.Vertex3f(floorRightX, floorY, z + step);
    }
    floorBatch.End();
    //天花板
    GLfloat ceilingLeftX = 10.0f;
    GLfloat ceilingRightX = -10.0f;
    GLfloat ceilingY = 10.0f;
    ceilingBatch.Begin(GL_TRIANGLE_STRIP, 28, 1);
    for (GLfloat z = 0.0f; z <= 60.0f; z += step) {
        ceilingBatch.MultiTexCoord2f(0, 1.0, 1.0);
        ceilingBatch.Vertex3f(ceilingRightX, ceilingY, z);

        ceilingBatch.MultiTexCoord2f(0, 0.0, 1.0);
        ceilingBatch.Vertex3f(ceilingLeftX, ceilingY, z);

        ceilingBatch.MultiTexCoord2f(0, 1.0, 0.0);
        ceilingBatch.Vertex3f(ceilingRightX, ceilingY, z + step);

        ceilingBatch.MultiTexCoord2f(0, 0.0, 0.0);
        ceilingBatch.Vertex3f(ceilingLeftX, ceilingY, z + step);
    }
    ceilingBatch.End();
    //左面墙壁
    GLfloat leftWallX = -10.0f;
    GLfloat leftWallTopY = 10.0f;
    GLfloat leftWallBottomY = -10.0f;
    leftWallBatch.Begin(GL_TRIANGLE_STRIP, 28, 1);
    for (GLfloat z = 0.0f; z <= 60.0f; z += step) {
        leftWallBatch.MultiTexCoord2f(0, 0.0, 1.0);
        leftWallBatch.Vertex3f(leftWallX, leftWallTopY, z);

        leftWallBatch.MultiTexCoord2f(0, 0.0, 0.0);
        leftWallBatch.Vertex3f(leftWallX, leftWallBottomY, z);

        leftWallBatch.MultiTexCoord2f(0, 1.0, 1.0);
        leftWallBatch.Vertex3f(leftWallX, leftWallTopY, z + step);

        leftWallBatch.MultiTexCoord2f(0, 1.0, 0.0);
        leftWallBatch.Vertex3f(leftWallX, leftWallBottomY, z + step);
    }
    leftWallBatch.End();
    //右面墙壁
    GLfloat rightWallX = 10.0f;
    GLfloat rightWallTopY = 10.0f;
    GLfloat rightWallBottomY = -10.0f;
    rightWallBatch.Begin(GL_TRIANGLE_STRIP, 28, 1);
    for (GLfloat z = 0.0f; z <= 60.0f; z += step) {
        rightWallBatch.MultiTexCoord2f(0, 0.0, 1.0);
        rightWallBatch.Vertex3f(rightWallX, rightWallBottomY, z);

        rightWallBatch.MultiTexCoord2f(0, 0.0, 0.0);
        rightWallBatch.Vertex3f(rightWallX, rightWallTopY, z);

        rightWallBatch.MultiTexCoord2f(0, 1.0, 1.0);
        rightWallBatch.Vertex3f(rightWallX, rightWallBottomY, z + step);

        rightWallBatch.MultiTexCoord2f(0, 1.0, 0.0);
        rightWallBatch.Vertex3f(rightWallX, rightWallTopY, z + step);
    }
    rightWallBatch.End();


}

void shutdownRC() {
    // 删除纹理
    glDeleteTextures(TEXTURE_COUNT, textures);
}

void changeSize(int width, int height) {
    if (height == 0) {
        height = 1;
    }
    glViewport(0, 0, width, height);
    viewFrustum.SetPerspective(60.0f, (GLfloat)width/(GLfloat)height, 1.0f, 100.0f);
    projectionMatrix.LoadMatrix(viewFrustum.GetProjectionMatrix());
    transformPipeline.SetMatrixStacks(modelViewMatrix, projectionMatrix);
}

void specialKeys(int key, int x, int y) {
    if(key == GLUT_KEY_UP)
        //移动的是深度值，Z
        viewZ += 0.5f;
    if(key == GLUT_KEY_DOWN)
        viewZ -= 0.5f;
    //更新窗口
    glutPostRedisplay();
}

void renderScene() {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

    modelViewMatrix.PushMatrix();
    ///移动
    modelViewMatrix.Translate(0.0f, 0.0f, viewZ);
    //纹理替换矩阵着色器 参数1：GLT_SHADER_TEXTURE_REPLACE（着色器标签）参数2：模型视图投影矩阵  参数3：纹理层
    shaderManager.UseStockShader(GLT_SHADER_TEXTURE_REPLACE, transformPipeline.GetModelViewProjectionMatrix(), 0);
    //绑定纹理
    glBindTexture(GL_TEXTURE_2D, textures[TEXTURE_FLOOR]);
    floorBatch.Draw();
    //绑定纹理
    glBindTexture(GL_TEXTURE_2D, textures[TEXTURE_CEILING]);
    ceilingBatch.Draw();
    //绑定纹理
    glBindTexture(GL_TEXTURE_2D, textures[TEXTURE_BRICK]);
    leftWallBatch.Draw();
    //绑定纹理
    glBindTexture(GL_TEXTURE_2D, textures[TEXTURE_BRICK]);
    rightWallBatch.Draw();

    modelViewMatrix.PopMatrix();

    glutSwapBuffers();
}

void processMenu(int value) {
    static GLint parameter1 = 0;
    static GLint parameter2 = 0;
    for (GLint i = 0; i < TEXTURE_COUNT; i ++) {
        //绑定纹理
        glBindTexture(GL_TEXTURE_2D, textures[i]);
        //配置纹理参数（缩小过滤）
        switch(value)
            {
                case 0:
                    parameter1 = 1;
                    //GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER(缩小过滤器)，GL_NEAREST（最邻近过滤）
                    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
                    break;
                case 1:
                    parameter1 = 2;
                    //GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER(缩小过滤器)，GL_LINEAR（线性过滤）
                    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                    break;
                case 2:
                    parameter1 = 3;
                    //GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER(缩小过滤器)，GL_NEAREST_MIPMAP_NEAREST（选择最邻近的Mip层，并执行最邻近过滤）
                    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST);
                    break;
                case 3:
                   parameter1 = 4; //GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER(缩小过滤器)，GL_NEAREST_MIPMAP_LINEAR（在Mip层之间执行线性插补，并执行最邻近过滤）
                    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_LINEAR);
                    break;
                case 4:
                   parameter1 = 5; //GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER(缩小过滤器)，GL_NEAREST_MIPMAP_LINEAR（选择最邻近Mip层，并执行线性过滤）
                    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
                    break;
                case 5:
                   parameter1 = 6; //GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER(缩小过滤器)，GL_LINEAR_MIPMAP_LINEAR（在Mip层之间执行线性插补，并执行线性过滤，又称为三线性过滤）
                    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
                    break;
                case 6:
                    parameter2 = 2;
                    //设置各向异性过滤
                    GLfloat fLargest;
                    //获取各向异性过滤的最大数量
                    glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &fLargest);
                    //设置纹理参数(各向异性采样)
                    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, fLargest);
                    break;
                case 7:
                    parameter2 = 1;
                    //设置各向同性过滤，数量为1.0表示(各向同性采样)
                    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 1.0f);
                    break;
            }
    }
    //触发重绘
    glutPostRedisplay();
}


int main(int argc, char * argv[]) {

    gltSetWorkingDirectory(argv[0]);

    // 标准初始化
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB);
    glutInitWindowSize(200, 200);
    glutCreateWindow("缩小过滤对比");
    glutReshapeFunc(changeSize);
    glutSpecialFunc(specialKeys);
    glutDisplayFunc(renderScene);

    // 添加菜单入口，改变过滤器
    glutCreateMenu(processMenu);
    for (GLint i = 0; i < 8; i ++) {
        glutAddMenuEntry(title[i],i);
    }
    glutAttachMenu(GLUT_RIGHT_BUTTON);

    GLenum err = glewInit();
    if (GLEW_OK != err) {
        fprintf(stderr, "GLEW Error: %s\n", glewGetErrorString(err));
        return 1;
    }


    // 启动循环，关闭纹理
    setupRC();
    glutMainLoop();
    shutdownRC();
    return 0;
}
