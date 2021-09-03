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


//定义一个，着色管理器
GLShaderManager shaderManager;
//简单的批次容器，是GLTools的一个简单的容器类。
GLBatch triangleBatch;
/// 移动步长
GLfloat step_length = 0.1;
/// 正方形顶点数组
GLfloat vVerts[] = {
    -step_length, step_length, 0.0f,
    step_length, step_length, 0.0f,
    step_length, -step_length, 0.0f,
    -step_length, -step_length, 0.0f,
};
/// 1.渲染设置，顶点数据提交
void setupRC(void)
{
    // 1.着色器设置（没有内容的清屏就不需要设置了）
    shaderManager.InitializeStockShaders();
    // 2.颜色设置
    glClearColor(0, 0, 0, 0);
    // 2.2提交绘制图形顶点数据
    triangleBatch.Begin(GL_TRIANGLE_FAN, 4);
    triangleBatch.CopyVertexData3f(vVerts);
    triangleBatch.End();
}
/// 2.视口大小设置
void changeSize(int w, int h)
{
    printf("changeSize\n");
    // 3.视口设置
    glViewport(0, 0, w, h);
}
/// 3.渲染
void renderScene(void)
{
    printf("renderScene\n");
    // 4.清空缓存区
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);
    // 5.重绘内容（没有内容的清屏就不需要设置了）
    //
    GLfloat vGreen[] = {0.0,1.0,0.0,1.0f};
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY,vGreen);
    triangleBatch.Draw();
    // 6.交换缓冲区，后台缓冲区进行渲染，完成后与前台交换，显示到视口中
    glutSwapBuffers();
}
/// 点击上下左右按键，移动正方形，并添加边界判断
void speacialKeys(int key,int x,int y)
{
    if (key == GLUT_KEY_UP) {//上
        if (vVerts[1] + step_length >= 1) {
            vVerts[1] = 1;
        }else {
            vVerts[1] += step_length;
        }
        vVerts[4] = vVerts[1];
        vVerts[7] = vVerts[4] - 2 * step_length;
        vVerts[10] = vVerts[7];
    }
    if (key == GLUT_KEY_DOWN) {//下
        if (vVerts[1] <= -1 + 2 * step_length) {
            vVerts[1] = -1 + 2 * step_length;
        }else {
            vVerts[1] -= step_length;
        }
        vVerts[4] = vVerts[1];
        vVerts[7] = vVerts[4] - 2 * step_length;
        vVerts[10] = vVerts[7];
    }
    if (key == GLUT_KEY_LEFT) {//左
        if (vVerts[0] <= -1) {
            vVerts[0] = -1;
        }else {
            vVerts[0] -= step_length;
        }
        vVerts[3] = vVerts[0] + 2 * step_length;
        vVerts[6] = vVerts[3];
        vVerts[9] = vVerts[0];
    }
    if (key == GLUT_KEY_RIGHT) {//右
        if (vVerts[0] >= 1 - 2 * step_length) {
            vVerts[0] = 1 - 2 * step_length;
        }else {
            vVerts[0] += step_length;
        }
        vVerts[3] = vVerts[0] + 2 * step_length;
        vVerts[6] = vVerts[3];
        vVerts[9] = vVerts[0];
    }
    /// 重新提交顶点数据
    triangleBatch.CopyVertexData3f(vVerts);
    /// 手动调用重回方法
    glutPostRedisplay();
}
int main(int argc, char * argv[]) {
    gltSetWorkingDirectory(argv[0]);
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE|GLUT_RGBA|GLUT_DEPTH|GLUT_STENCIL);
    glutInitWindowSize(400, 400);
    glutCreateWindow("键盘可控制正方形");
    glutReshapeFunc(changeSize);
    glutDisplayFunc(renderScene);
    glutSpecialFunc(speacialKeys);
    GLenum state = glewInit();
    if (GLEW_OK != state) {
        return 1;
    }
    setupRC();
    glutMainLoop();
    return 0;
}
