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

GLShaderManager shaderManager;
// 左上角矩形
GLBatch ltBatch;
GLfloat ltColor[] = {1.0, 0.0, 0.0, 1.0};
GLfloat ltVertex[] = {-1.0, 1.0, 0.0,
                      -1.0, 0.4, 0.0,
                      -0.4, 0.4, 0.0,
                      -0.4, 1.0, 0.0,};
// 右上角矩形
GLBatch rtBatch;
GLfloat rtColor[] = {0.0, 1.0, 0.0, 1.0};
GLfloat rtVertex[] = {0.4, 1.0, 0.0,
                      0.4, 0.4, 0.0,
                      1.0, 0.4, 0.0,
                      1.0, 1.0, 0.0,};
// 左下角矩形
GLBatch lbBatch;
GLfloat lbColor[] = {0.0, 0.0, 1.0, 1.0};
GLfloat lbVertex[] = {-1.0, -0.4, 0.0,
                      -1.0, -1.0, 0.0,
                      -0.4, -1.0, 0.0,
                      -0.4, -0.4, 0.0,};
// 右下角矩形
GLBatch rbBatch;
GLfloat rbColor[] = {0.0, 1.0, 0.0, 0.5};
GLfloat rbVertex[] = {0.4, -0.4, 0.0,
                      0.4, -1.0, 0.0,
                      1.0, -1.0, 0.0,
                      1.0, -0.4, 0.0,};
// 移动矩形
GLBatch moveBatch;
GLfloat step = 0.2;// 步长
GLfloat moveColor[] = {0.1, 1.0, 0.8, 0.5};
GLfloat moveVertex[] = {-0.3, -0.3, 0.0,
                         0.3, -0.3, 0.0,
                         0.3,  0.3, 0.0,
                        -0.3,  0.3, 0.0,};

void changeSize(int w, int h)
{
    glViewport(0, 0, w, h);
}
void renderScene(void)
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    //使用 单位着色器绘制矩形区域
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, ltColor);
    ltBatch.Draw();

    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, rtColor);
    rtBatch.Draw();

    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, lbColor);
    lbBatch.Draw();

    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, rbColor);
    rbBatch.Draw();

    // 开启颜色混合
    glEnable(GL_BLEND);
    // 开启组合函数 计算混合颜色因子
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    shaderManager.UseStockShader(GLT_SHADER_IDENTITY, moveColor);
    moveBatch.Draw();

    // 关闭混合功能
    glDisable(GL_BLEND);

    glutSwapBuffers();
}
void specialKeys(int key, int x, int y)
{
    GLfloat lbX = moveVertex[0];
    GLfloat lbY = moveVertex[1];
    if(key == GLUT_KEY_UP)      lbY += step;
    if(key == GLUT_KEY_DOWN)    lbY -= step;
    if(key == GLUT_KEY_LEFT)    lbX -= step;
    if(key == GLUT_KEY_RIGHT)   lbX += step;

    if (lbX < -1.0) lbX = -1.0;
    if (lbX > 0.4)  lbX = 0.4;
    if (lbY < -1.0) lbY = -1.0;
    if (lbY > 0.4)  lbY = 0.4;

    moveVertex[0] = lbX;
    moveVertex[1] = lbY;
    moveVertex[3] = lbX + 0.6;
    moveVertex[4] = lbY;
    moveVertex[6] = lbX + 0.6;
    moveVertex[7] = lbY + 0.6;
    moveVertex[9] = lbX;
    moveVertex[10] = lbY + 0.6;

    moveBatch.CopyVertexData3f(moveVertex);
    glutPostRedisplay();

}
void setupRC() {
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f );
    shaderManager.InitializeStockShaders();

    ltBatch.Begin(GL_TRIANGLE_FAN, 4);
    ltBatch.CopyVertexData3f(ltVertex);
    ltBatch.End();

    rtBatch.Begin(GL_TRIANGLE_FAN, 4);
    rtBatch.CopyVertexData3f(rtVertex);
    rtBatch.End();

    lbBatch.Begin(GL_TRIANGLE_FAN, 4);
    lbBatch.CopyVertexData3f(lbVertex);
    lbBatch.End();

    rbBatch.Begin(GL_TRIANGLE_FAN, 4);
    rbBatch.CopyVertexData3f(rbVertex);
    rbBatch.End();

    moveBatch.Begin(GL_TRIANGLE_FAN, 4);
    moveBatch.CopyVertexData3f(moveVertex);
    moveBatch.End();
}
int main(int argc, char * argv[]) {
    gltSetWorkingDirectory(argv[0]);
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH);
    glutInitWindowSize(400, 400);
    glutCreateWindow("颜色混合");
    GLenum err = glewInit();
    if (GLEW_OK != err) {
        fprintf(stderr, "Error: %s\n", glewGetErrorString(err));
        return 1;
    }
    glutReshapeFunc(changeSize);
    glutDisplayFunc(renderScene);
    glutSpecialFunc(specialKeys);
    setupRC();
    glutMainLoop();
    return 0;
}
