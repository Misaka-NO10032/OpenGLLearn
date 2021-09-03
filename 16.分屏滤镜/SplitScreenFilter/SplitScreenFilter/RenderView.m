//
//  RenderView.m
//  SplitScreenFilter
//
//  Created by Misaka on 2020/7/2.
//  Copyright © 2020 Misaka. All rights reserved.
//

#import "RenderView.h"
#import <GLKit/GLKit.h>

@interface RenderView ()

@property (nonatomic, strong) CAEAGLLayer *glLayer;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLuint program;
@property (nonatomic, assign) GLuint buffer;
@property (nonatomic, assign) GLuint renderBuffer;
@property (nonatomic, assign) GLuint frameBuffer;

@end

@implementation RenderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        self.glLayer = [[CAEAGLLayer alloc] init];
        self.glLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.glLayer.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:self.glLayer];

        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        [EAGLContext setCurrentContext:self.context];

        glDeleteBuffers(1, &_renderBuffer);
        glDeleteBuffers(1, &_frameBuffer);

        glGenRenderbuffers(1, &_renderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
        [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.glLayer];
        glGenFramebuffers(1, &_frameBuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);

        glViewport(0, 0, self.bounds.size.width * [[UIScreen mainScreen] scale], self.bounds.size.height * [[UIScreen mainScreen] scale]);
        glClearColor(0.5, 0.5, 0.5, 1);
    }
    return self;
}

- (void)setShader:(NSString *)shader image:(UIImage *)image {
    /// 载入纹理
    if ([self loadTextureWithImage:image]) {
        /// link program
        if ([self linkProgramWithShaderName:shader]) {
            glUseProgram(_program);

            [self render];
        }
    }
}

- (void)render {
    GLfloat vertices[20] = {
        -1.0, 1.0, 0.0,   0.0, 1.0,
        -1.0, -1.0, 0.0,  0.0, 0.0,
        1.0, 1.0, 0.0,    1.0, 1.0,
        1.0, -1.0, 0.0,   1.0, 0.0,
    };
    glGenBuffers(1, &_buffer);
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_DYNAMIC_DRAW);

    GLuint position = glGetAttribLocation(_program, "i_position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL);

    GLuint textureCoord = glGetAttribLocation(_program, "i_textureCoord");
    glEnableVertexAttribArray(textureCoord);
    glVertexAttribPointer(textureCoord, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL + 3);
    glVertexAttribPointer(textureCoord, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL + sizeof(GLfloat)*3);
    glVertexAttribPointer(textureCoord, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (GLfloat*)NULL + 3);

    GLuint sampler = glGetUniformLocation(_program, "u_sampler");
    glUniform1i(sampler, 0);

    glClear(GL_COLOR_BUFFER_BIT);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (BOOL)linkProgramWithShaderName:(NSString *)shaderName {

    NSString *vPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"vsh"];
    NSError *vError;
    NSString *vString = [NSString stringWithContentsOfFile:vPath encoding:NSUTF8StringEncoding error:&vError];
    GLuint vShader = glCreateShader(GL_VERTEX_SHADER);
    const char *vStringUTF8 = [vString UTF8String];
    glShaderSource(vShader, 1, &vStringUTF8, NULL);
    glCompileShader(vShader);

    NSString *fPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"fsh"];
    NSError *fError;
    NSString *fString = [NSString stringWithContentsOfFile:fPath encoding:NSUTF8StringEncoding error:&fError];
    GLuint fShader = glCreateShader(GL_FRAGMENT_SHADER);
    const char *fStringUTF8 = [fString UTF8String];
    glShaderSource(fShader, 1, &fStringUTF8,NULL);
    glCompileShader(fShader);

    _program = glCreateProgram();
    glAttachShader(_program, vShader);
    glAttachShader(_program, fShader);
    glDeleteShader(vShader);
    glDeleteShader(fShader);
    glLinkProgram(_program);

    return YES;
}

- (BOOL)loadTextureWithImage:(UIImage *)image {
    CGImageRef imageRef = image.CGImage;
    if (!imageRef) {
        return NO;
    }
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    GLubyte *imageData = calloc(width * height * 4, sizeof(GLubyte));
    CGContextRef contextRef = CGBitmapContextCreate(imageData, width, height, 8, width*4, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
    /// 上下翻转
    CGContextTranslateCTM(contextRef, 0, height);
    CGContextScaleCTM(contextRef, 1.0f, -1.0f);
    CGRect rect = CGRectMake(0, 0, width, height);
    CGContextDrawImage(contextRef, rect, imageRef);
    CGContextRelease(contextRef);
    glBindTexture(GL_TEXTURE_2D, 0);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    free(imageData);
    return YES;
}

- (void)freeMemory {
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    if (_renderBuffer) {
        glDeleteBuffers(1, &_renderBuffer);
    }
    if (_frameBuffer) {
        glDeleteBuffers(1, &_frameBuffer);
    }
    if (_buffer) {
        glDeleteBuffers(1, &_buffer);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
