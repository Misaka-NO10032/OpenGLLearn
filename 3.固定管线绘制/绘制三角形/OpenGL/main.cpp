//
//  main.m
//  OpenGL
//
//  Created by Misaka on 2019/9/6.
//  Copyright © 2019 Misaka. All rights reserved.
//

#include <stdio.h>
#include "GLShaderManager.h"
/*
 `#include<GLShaderManager.h>` 移入了GLTool 着色器管理器（shader Mananger）类。没有着色器，我们就不能在OpenGL（核心框架）进行着色。着色器管理器不仅允许我们创建并管理着色器，还提供一组“存储着色器”，他们能够进行一些初步䄦基本的渲染操作。
 */

#include "GLTools.h"
/*
 `#include<GLTools.h>`  GLTool.h头文件包含了大部分GLTool中类似C语言的独立函数
 */

#include <GLUT/GLUT.h>
/*
 在Mac 系统下，`#include<glut/glut.h>`
 在Windows 和 Linux上，我们使用freeglut的静态库版本并且需要添加一个宏
 */


//定义一个，着色管理器
GLShaderManager shaderManager;
//简单的批次容器，是GLTools的一个简单的容器类。
GLBatch triangleBatch;

/// 在窗口大小改变时，接收新的宽度&高度。
void changeSize(int w,int h)
{
    printf("changeSize\n");
    /*x,y 参数代表窗口中视图的左下角坐标，而宽度、高度是像素为表示，通常x,y 都是为0*/
    glViewport(0, 0, w, h);

}
/// 显示处理，每次窗口改变(changeSize调用)后都会执行
void renderScene(void)
{
    printf("renderScene\n");
    //1.清除一个或者一组特定的缓存区
    /*
     缓冲区是一块存在图像信息的储存空间，红色、绿色、蓝色和alpha分量通常一起作为颜色缓存区或像素缓存区引用。
     OpenGL 中不止一种缓冲区（颜色缓存区、深度缓存区和模板缓存区）
     清除缓存区对数值进行预置
     参数：指定将要清除的缓存的
     GL_COLOR_BUFFER_BIT :指示当前激活的用来进行颜色写入缓冲区
     GL_DEPTH_BUFFER_BIT :指示深度缓存区
     GL_STENCIL_BUFFER_BIT:指示模板缓冲区
     */
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);
    //2.设置一组浮点数来表示红色
    GLfloat vRed[] = {1.0,0.0,0.0,1.0f};
    //传递到存储着色器，即GLT_SHADER_IDENTITY着色器，这个着色器只是使用指定颜色以默认笛卡尔坐标第在屏幕上渲染几何图形
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY,vRed);
    //提交着色器
    triangleBatch.Draw();
    //在开始的设置openGL 窗口的时候，我们指定要一个双缓冲区的渲染环境。这就意味着将在后台缓冲区进行渲染，渲染结束后交换给前台。这种方式可以防止观察者看到可能伴随着动画帧与动画帧之间的闪烁的渲染过程。缓冲区交换平台将以平台特定的方式进行。
    //将后台缓冲区进行渲染，然后结束后交换给前台
    glutSwapBuffers();
}

//设置渲染环境
void setupRC()
{
    printf("setupRC\n");
    //设置清屏颜色（背景颜色）
    glClearColor(0.98f, 0.40f, 0.7f, 1);
    //没有着色器，在OpenGL 核心框架中是无法进行任何渲染的。初始化一个渲染管理器。
    //初始化固管线着色器
    shaderManager.InitializeStockShaders();
    //指定顶点（3个顶底点，x,y,z）
    //在OpenGL中，三角形是一种基本的3D图元绘图原素。
    GLfloat vVerts[] = {
        -0.5f,0.0f,0.0f,
        0.5f,0.0f,0.0f,
        0.0f,0.5f,0.0f
    };
    /// 设置顶点链接方式，顶点数目，开启批次容器
    triangleBatch.Begin(GL_TRIANGLES, 3);
    /// 提交顶点数据到批次容器
    triangleBatch.CopyVertexData3f(vVerts);
    /// 关闭批次容器
    triangleBatch.End();
}

void speacialKeys(int key,int x,int y)
{

}

int main(int argc, char * argv[]) {
/*设置当前工作目录`GLTools`函数`glSetWorkingDrectory`用来设置当前工作目录。实际上在Windows中是不必要的，因为工作目录默认就是与程序可执行执行程序相同的目录。但是在Mac OS X中，这个程序将当前工作文件夹改为应用程序捆绑包中的`/Resource`文件夹。`GLUT`的优先设定自动进行了这个中设置，但是这样中方法更加安全。
     */
    gltSetWorkingDirectory(argv[0]);
    //初始化GLUT库,这个函数只是传输命令参数并且初始化glut库
    glutInit(&argc, argv);
    /*初始化双缓冲窗口，其中标志GLUT_DOUBLE、GLUT_RGBA、GLUT_DEPTH、GLUT_STENCIL分别指:双缓冲窗口、RGBA颜色模式、深度测试、模板缓冲区
     GLUT_DOUBLE：双缓存窗口，是指绘图命令实际上是离屏缓存区执行的，然后迅速转换成窗口视图，这种方式，经常用来生成动画效果；
     GLUT_RGBA: RGBA颜色模式
     GLUT_DEPTH：标志将一个深度缓存区分配为显示的一部分，因此我们能够执行深度测试；
     GLUT_STENCIL：确保我们也会有一个可用的模板缓存区。*/
    glutInitDisplayMode(GLUT_DOUBLE|GLUT_RGBA|GLUT_DEPTH|GLUT_STENCIL);
    //GLUT窗口大小、窗口标题
    glutInitWindowSize(800, 600);
    glutCreateWindow("OpenGL Window");
    /*GLUT 内部运行一个本地消息循环，拦截适当的消息。然后调用我们不同时间注册的回调函数。我们一共注册3个回调函数：
     1）为窗口改变大小而设置的一个回调函数   2）包含OpenGL 渲染的回调函  3) 特殊键位输入监听 */
    //注册重塑函数
    glutReshapeFunc(changeSize);
    //注册显示函数
    glutDisplayFunc(renderScene);
    //注册键盘点击
    glutSpecialFunc(speacialKeys);
    /* 初始化一个GLEW库,确保OpenGL API对程序完全可用。
     在试图做任何渲染之前，要检查确定驱动程序的初始化过程中没有任何问题 */
    GLenum status = glewInit();
    if (GLEW_OK != status) {
        /// 初始化失败
        printf("GLEW Error:%s\n",glewGetErrorString(status));
        return 1;
    }

    //设置渲染环境
    setupRC();

    glutMainLoop();

    return 0;
}
