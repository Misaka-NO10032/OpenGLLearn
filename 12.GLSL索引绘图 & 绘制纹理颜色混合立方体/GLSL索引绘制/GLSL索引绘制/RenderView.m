//
//  RenderView.m
//  GLSL索引绘制
//
//  Created by Misaka on 2020/3/31.
//  Copyright © 2020 Misaka. All rights reserved.
//

#import "RenderView.h"
#import <OpenGLES/ES3/gl.h>
#import "GLESMath.h"

@interface RenderView (){
    CAEAGLLayer *glLayer;
    EAGLContext *context;
    GLuint renderBufferID;
    GLuint frameBufferID;
    GLuint vertexID;
    GLuint programID;
}

@end

@implementation RenderView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)layoutSubviews {
    [self configAttribute];
    [self render];
}

/// 配置属性变量
- (void)configAttribute {
    /// layer
    glLayer = (CAEAGLLayer *)self.layer;
    glLayer.opaque = YES;
    [self setContentScaleFactor:[UIScreen mainScreen].scale];//让缩放比例同屏幕显示一致
    glLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking : @false,
                                   kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8,
    };

    /// context
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    NSAssert(context, @"context 创建失败");
    BOOL configContext = [EAGLContext setCurrentContext:context];
    if (!configContext) {
        NSLog(@"配置上下文失败");
        return;
    }

    /// buffer
    [self deleteBuffer];
    glGenBuffers(1, &renderBufferID);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBufferID);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:glLayer];
    glGenFramebuffers(1, &frameBufferID);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBufferID);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderBufferID);
}

- (void)render {
    glClearColor(0.3, 0.5, 0.7, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    CGFloat scale = [[UIScreen mainScreen] scale];
    //2.设置视口
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);

    /// vertexArray x,y,z,  r,g,b,
    GLfloat vertexArray[] = {
        -0.5, -0.5, -0.5,    1.0, 1.0, 0.0,
        0.5, -0.5, -0.5,     1.0, 0.0, 0.0,
        0.5, 0.5, -0.5,     0.0, 1.0, 0.0,
        -0.5, 0.5, -0.5,     0.0, 0.0, 1.0,
        0.0, 0.0, 0.5,      0.0, 1.0, 1.0,
    };
    /// indexArray
    GLuint indexArray[] = {
        0, 3, 1,
        3, 2, 1,
        0, 4, 3,
        1, 4, 0,
        2, 4, 1,
        3, 4, 2,
    };
    /// vertex buffer
    if (vertexID == 0) {
        glGenBuffers(1, &vertexID);
    }
    glBindBuffer(GL_ARRAY_BUFFER, vertexID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexArray), vertexArray, GL_DYNAMIC_DRAW);
    /// vertex shader
    GLuint vShaderID = glCreateShader(GL_VERTEX_SHADER);
    NSString *vShaderFilePath = [[NSBundle mainBundle] pathForResource:@"shaderV" ofType:@"glsl"];
    const GLchar *vShaderSource = (GLchar *)[NSString stringWithContentsOfFile:vShaderFilePath encoding:NSUTF8StringEncoding error:nil].UTF8String;
    glShaderSource(vShaderID, 1, &vShaderSource, NULL);//着色器源码附加到着色器对象上
    glCompileShader(vShaderID);//编译
    /// fragment shader
    GLuint fShaderID = glCreateShader(GL_FRAGMENT_SHADER);
    NSString *fShaderFilePath = [[NSBundle mainBundle] pathForResource:@"shaderF" ofType:@"glsl"];
    const GLchar *fShaderSource = (GLchar *)[NSString stringWithContentsOfFile:fShaderFilePath encoding:NSUTF8StringEncoding error:nil].UTF8String;
    glShaderSource(fShaderID, 1, &fShaderSource, NULL);
    glCompileShader(fShaderID);
    /// program
    if (programID) {
        glDeleteProgram(programID);
        programID = 0;
    }
    programID = glCreateProgram();
    glAttachShader(programID, vShaderID);// 附加着色器
    glAttachShader(programID, fShaderID);
    glDeleteShader(vShaderID); // 释放已经附加到program上去，不再需要的着色器
    glDeleteShader(fShaderID);
    glLinkProgram(programID);
    GLint linkSuccess;
    glGetProgramiv(programID, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programID, sizeof(messages), 0, &messages[0]);
        NSLog(@"program link error： %@", [NSString stringWithUTF8String:messages]);
        return;
    }
    glUseProgram(programID);
    /// shader attribute
    GLuint position = glGetAttribLocation(programID, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, (GLfloat *)NULL);
    GLuint positionColor = glGetAttribLocation(programID, "positionColor");
    glEnableVertexAttribArray(positionColor);
    glVertexAttribPointer(positionColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, (GLfloat *)NULL + 3);
    /// shader uniform
    GLuint projectionMatrixID = glGetUniformLocation(programID, "projectionMatrix");
    KSMatrix4 projectionMatrix;
    ksMatrixLoadIdentity(&projectionMatrix);//获取单元矩阵
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    float aspect = width / height;
    ksPerspective(&projectionMatrix, 30.0, aspect, 5.0f, 20.0f); //获取透视矩阵
    /*
    void glUniformMatrix4fv(GLint location,  GLsizei count,  GLboolean transpose,  const GLfloat *value);
    参数列表：
    location:指要更改的uniform变量的位置
    count:更改矩阵的个数
    transpose:是否要转置矩阵，并将它作为uniform变量的值。必须为GL_FALSE
    value:执行count个元素的指针，用来更新指定uniform变量
    */
    glUniformMatrix4fv(projectionMatrixID, 1, GL_FALSE, (GLfloat*)&projectionMatrix.m[0][0]);
    GLuint modelViewMatrixID = glGetUniformLocation(programID, "modelViewMatrix");
    KSMatrix4 modelViewMatrix;
    ksMatrixLoadIdentity(&modelViewMatrix);
    ksTranslate(&modelViewMatrix, 0.0, 0.0, -10.0);//平移
    KSMatrix4 rotationMatrix;
    ksMatrixLoadIdentity(&rotationMatrix);
    ksRotate(&rotationMatrix, self.xDegree, 1.0, 0.0, 0.0); //绕X轴
    ksRotate(&rotationMatrix, self.yDegree, 0.0, 1.0, 0.0); //绕Y轴
    ksRotate(&rotationMatrix, self.zDegree, 0.0, 0.0, 1.0); //绕Z轴
    ksMatrixMultiply(&modelViewMatrix, &rotationMatrix, &modelViewMatrix);
    glUniformMatrix4fv(modelViewMatrixID, 1, GL_FALSE, (GLfloat *)&modelViewMatrix.m[0][0]);
    /*
    void glDrawElements(GLenum mode,GLsizei count,GLenum type,const GLvoid * indices);
    参数列表：
    mode:要呈现的画图的模型
               GL_POINTS
               GL_LINES
               GL_LINE_LOOP
               GL_LINE_STRIP
               GL_TRIANGLES
               GL_TRIANGLE_STRIP
               GL_TRIANGLE_FAN
    count:绘图个数
    type:类型
            GL_BYTE
            GL_UNSIGNED_BYTE
            GL_SHORT
            GL_UNSIGNED_SHORT
            GL_INT
            GL_UNSIGNED_INT
    indices：绘制索引数组
    */
    glDrawElements(GL_TRIANGLES, sizeof(indexArray)/sizeof(indexArray[0]), GL_UNSIGNED_INT, indexArray);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)deleteBuffer {
    glDeleteBuffers(1, &renderBufferID);
    renderBufferID = 0;
    glDeleteBuffers(1, &frameBufferID);
    frameBufferID = 0;

}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
