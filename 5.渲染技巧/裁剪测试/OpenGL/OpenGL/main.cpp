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

void changeSize(int w, int h) {
    glViewport(0, 0, w, h);
}

void renderScene () {
    // 清屏颜色 红色
    glClearColor(1.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);

    // 开启裁剪测试
    glEnable(GL_SCISSOR_TEST);

    // 裁剪区域 绿色
    glClearColor(0.0, 1.0, 0.0, 1.0);
    glScissor(100, 100, 200, 200);
    glClear(GL_COLOR_BUFFER_BIT);

    // 裁剪区域 蓝色
    glClearColor(0.0, 0.0, 1.0, 1.0);
    glScissor(150, 150, 100, 100);
    glClear(GL_COLOR_BUFFER_BIT);

    // 关闭裁剪测试
    glDisable(GL_SCISSOR_TEST);

    //强制执行缓存区交换
    glutSwapBuffers();


}

int main(int argc, char * argv[]) {
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB);
    glutInitWindowSize(400, 400);
    glutCreateWindow("裁剪测试");
    glutReshapeFunc(changeSize);
    glutDisplayFunc(renderScene);
    glutMainLoop();
    return 0;
}
