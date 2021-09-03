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
    //glOrtho(0.0, 1.0, 0.0, 1.0, -1.0, 1.0);
    glBegin(GL_LINE_LOOP);
    const int count = 100;//顶点个数
    const GLfloat r = 0.4;//半径
    const GLfloat PI = 3.14159265;
    for (int i = 0; i < count; i ++) {
        glVertex2f(r * cos(2 * PI / count * i),r * sin(2 * PI / count * i));
    }
    glEnd();
    glFlush();
}

int main(int argc, char * argv[]) {
    glutInit(&argc, argv);
    glutInitWindowSize(400, 400);
    glutCreateWindow("绘制圆形");
    glutDisplayFunc(draw);
    glutMainLoop();
    return 0;
}
