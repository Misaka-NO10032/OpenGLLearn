//
//  main.m
//  OpenGL
//
//  Created by Misaka on 2019/9/6.
//  Copyright © 2019 Misaka. All rights reserved.
//

#include <iostream>
#include <GLUT/GLUT.h>
#include "math3d.h"

void renderScene() {
    glClearColor(0.0, 0.0, 0.0, 1.0);///设置清屏色
    glClear(GL_COLOR_BUFFER_BIT);///清缓存
    glColor3f(1.0, 0.0, 0.0);///设置颜色
    glOrtho(0.0, 1.0, 0.0, 1.0, -1.0, 1.0);///设置绘制坐标系
    glBegin(GL_POLYGON);/// 开始渲染，设定顶点连接方式
    /// 添加顶点
    glVertex3f(0.25, 0.25, 0.0);
    glVertex3f(0.75, 0.25, 0.0);
    glVertex3f(0.75, 0.75, 0.0);
    glVertex3f(0.25, 0.75, 0.0);
    glEnd();//结束渲染
    glFlush();//强制刷新缓存区，保证绘制命令执行

}

int main(int argc, char * argv[]) {
    glutInit(&argc, argv);
    glutInitWindowSize(400, 400);
    glutCreateWindow("绘制正方形");
    glutDisplayFunc(renderScene);
    glutMainLoop();

    return 0;
}
