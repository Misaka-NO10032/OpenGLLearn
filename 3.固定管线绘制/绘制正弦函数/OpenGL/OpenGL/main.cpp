//
//  main.m
//  OpenGL
//
//  Created by Misaka on 2019/9/6.
//  Copyright © 2019 Misaka. All rights reserved.
//

#include "iostream"
#include <GLUT/GLUT.h>
#include "math3d.h"

void draw() {
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    /// 坐标轴
    glColor3f(1.0, 1.0, 1.0);
    glBegin(GL_LINES);
    glVertex2f(-1.0, 0.0);
    glVertex2f(1.0, 0.0);
    glVertex2f(0.0, -1.0);
    glVertex2f(0.0, 1.0);
    glEnd();
    /// 正弦函数
    glColor3f(0.0, 1.0, 0.0);
    GLfloat x;
    GLfloat scale = 0.1;//缩放比例
    glBegin(GL_LINE_STRIP);
    for (x = -1/scale; x < 1/scale; x += 0.01) {
        glVertex2f(x * scale, sin(x) * scale);
    }
    glEnd();
    /// 余弦函数
    glColor3f(1.0, 1.0, 0.0);
    glBegin(GL_LINE_STRIP);
    for (x = -1/scale; x < 1/scale; x += 0.01) {
        glVertex2f(x * scale, cos(x) * scale);
    }
    glEnd();

    glFlush();
}

int main(int argc, char * argv[]) {
    glutInit(&argc, argv);
    glutInitWindowSize(400, 400);
    glutCreateWindow("正弦函数");
    glutDisplayFunc(draw);
    glutMainLoop();
    return 0;
}
