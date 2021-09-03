//
//  RenderView.m
//  TextureColorCube
//
//  Created by Misaka on 2020/4/7.
//  Copyright © 2020 Misaka. All rights reserved.
//

#import "RenderView.h"
#import <OpenGLES/ES3/gl.h>
#import "GLESMath.h"

@interface RenderView ()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) CAEAGLLayer *glLayer;
@property (nonatomic, assign) GLuint renderBuffer;
@property (nonatomic, assign) GLuint frameBuffer;
@property (nonatomic, assign) GLuint program;
@property (nonatomic, assign) GLuint vertices;

@end

@implementation RenderView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)layoutSubviews {

    /* Context */
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!self.context) {
        NSLog(@"context create error");
        return;
    }
    [EAGLContext setCurrentContext:self.context];

    /* Layer */
    self.glLayer = (CAEAGLLayer *)self.layer;
    [self setContentScaleFactor:[UIScreen mainScreen].scale];
    self.glLayer.opaque = YES;
    self.glLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking : @(NO),
                                        kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8
    };

    /* render buffer & frame buffer */
    [self deleteBuffer];
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, self.renderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.glLayer];
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, self.frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.renderBuffer);

    [self render];
}

- (void)deleteBuffer {
    glDeleteRenderbuffers(1, &_renderBuffer);
    self.renderBuffer = 0;
    glDeleteFramebuffers(1, &_frameBuffer);
    self.frameBuffer = 0;
}

- (void)render {
    glClearColor(0.5, 0.5, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    glViewport(self.frame.origin.x*[UIScreen mainScreen].scale, self.frame.origin.y*[UIScreen mainScreen].scale, self.frame.size.width*[UIScreen mainScreen].scale, self.frame.size.height*[UIScreen mainScreen].scale);
    /* vertice shader*/
    GLuint vShader = glCreateShader(GL_VERTEX_SHADER);
    NSString *vFile = [[NSBundle mainBundle] pathForResource:@"shaderV" ofType:@"glsl"];
    NSString *vContent = [NSString stringWithContentsOfFile:vFile encoding:NSUTF8StringEncoding error:nil];
    const GLchar *vSource = (GLchar *)vContent.UTF8String;
    glShaderSource(vShader, 1, &vSource, NULL);
    glCompileShader(vShader);
    GLint vLink;
    glGetShaderiv(vShader, GL_COMPILE_STATUS, &vLink);
    if (vLink == GL_FALSE) {
        GLchar vMessages[256];
        glGetShaderInfoLog(vShader, sizeof(vMessages), 0, &vMessages[0]);
        NSString *error = [NSString stringWithUTF8String:vMessages];
        NSLog(@"vertice shader Compile error: %@", error);
        return;
    }
    /* fragment shader*/
    GLuint fShader = glCreateShader(GL_FRAGMENT_SHADER);
    NSString *fFile = [[NSBundle mainBundle] pathForResource:@"shaderF" ofType:@"glsl"];
    NSString *fContent = [NSString stringWithContentsOfFile:fFile encoding:NSUTF8StringEncoding error:nil];
    const GLchar *fSource = (GLchar *)fContent.UTF8String;
    glShaderSource(fShader, 1, &fSource, NULL);
    glCompileShader(fShader);
    GLint fLink;
    glGetShaderiv(fShader, GL_COMPILE_STATUS, &fLink);
    if (fLink == GL_FALSE) {
        GLchar fMessages[256];
        glGetShaderInfoLog(fShader, sizeof(fMessages), 0, &fMessages[0]);
        NSString *error = [NSString stringWithUTF8String:fMessages];
        NSLog(@"fragment shader Compile error: %@", error);
        return;
    }
    /* program */
    self.program = glCreateProgram();
    glAttachShader(self.program, vShader);
    glAttachShader(self.program, fShader);
    glDeleteShader(vShader);
    glDeleteShader(fShader);
    glLinkProgram(self.program);
    GLint pLink;
    glGetProgramiv(self.program, GL_LINK_STATUS, &pLink);
    if (pLink == GL_FALSE) {
        GLchar pMessages[256];
        glGetProgramInfoLog(self.program, sizeof(pMessages), 0, &pMessages[0]);
        NSString *error = [NSString stringWithUTF8String:pMessages];
        NSLog(@"program link error: %@", error);
        return;
    }
    glUseProgram(self.program);
    /* 顶点 x,y,z, r,g,b, s,t*/
    GLfloat vertices[] = {
        -0.5, 0.5, 0.0,     1.0, 0.0, 0.0,    0.0, 1.0,
        0.5, 0.5, 0.0,      0.0, 1.0, 0.0,    1.0, 1.0,
        -0.5, -0.5, 0.0,    0.0, 0.0, 1.0,    0.0, 0.0,
        0.5, -0.5, 0.0,     1.0, 1.0, 0.0,    1.0, 0.0,
        0.0, 0.0, 1.0,      0.0, 1.0, 1.0,    0.5, 0.5,
    };
    /* 索引 */
    GLint index[] = {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
    if (self.vertices == 0) {
        glGenBuffers(1, &_vertices);
    }
    glBindBuffer(GL_ARRAY_BUFFER, self.vertices);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_DYNAMIC_DRAW);
    /* texture */
    CGImageRef image = [UIImage imageNamed:@"kkk.png"].CGImage;
    if (!image) {
        NSLog(@"纹理图片不存在");
        return;
    }
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    GLubyte *imageData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
    CGContextRef imageContext = CGBitmapContextCreate(imageData, width, height, 8, width * 4, CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextDrawImage(imageContext, rect, image);
    CGContextRelease(imageContext);

    glBindTexture(GL_TEXTURE_2D, 0);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (float)width, (float)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    free(imageData);
    /* shader data input */
    GLuint position = glGetAttribLocation(self.program, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL);
    GLuint positionColor = glGetAttribLocation(self.program, "positionColor");
    glEnableVertexAttribArray(positionColor);
    glVertexAttribPointer(positionColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL + 3);
    GLuint textureCoor = glGetAttribLocation(self.program, "textureCoor");
    glEnableVertexAttribArray(textureCoor);
    glVertexAttribPointer(textureCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL + 6);
    GLuint colorMap = glGetUniformLocation(self.program, "colorMap");
    glUniform1i(colorMap, 0);
    GLuint projectionMatrix = glGetUniformLocation(self.program, "projectionMatrix");
    KSMatrix4 _projectionMatrix;
    ksMatrixLoadIdentity(&_projectionMatrix);
    ksPerspective(&_projectionMatrix, 30.0, self.frame.size.width/self.frame.size.height, 5.0f, 20.0f);
    glUniformMatrix4fv(projectionMatrix, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);
    GLuint modelViewMatrix = glGetUniformLocation(self.program, "modelViewMatrix");
    KSMatrix4 _modelViewMatrix;
    ksMatrixLoadIdentity(&_modelViewMatrix);
    ksTranslate(&_modelViewMatrix, 0.0, 0.0, -7.0);
    KSMatrix4 _rotationMatrix;
    ksMatrixLoadIdentity(&_rotationMatrix);
    ksRotate(&_rotationMatrix, self.xDegree, 1.0, 0.0, 0.0); //绕X轴
    ksRotate(&_rotationMatrix, self.yDegree, 0.0, 1.0, 0.0); //绕Y轴
    ksRotate(&_rotationMatrix, self.zDegree, 0.0, 0.0, 1.0); //绕Z轴
    ksMatrixMultiply(&_modelViewMatrix, &_rotationMatrix, &_modelViewMatrix);
    glUniformMatrix4fv(modelViewMatrix, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
    /* render */
    glDrawElements(GL_TRIANGLES, sizeof(index)/sizeof(index[0]), GL_UNSIGNED_INT, index);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];

}


@end
