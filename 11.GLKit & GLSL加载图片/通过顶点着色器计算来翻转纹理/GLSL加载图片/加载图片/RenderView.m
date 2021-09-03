//
//  RenderView.m
//  加载图片
//
//  Created by Misaka on 2020/3/3.
//  Copyright © 2020 Misaka. All rights reserved.
//

#import "RenderView.h"
#import <OpenGLES/ES2/gl.h>

@interface RenderView ()

@property (nonatomic, strong) CAEAGLLayer *glLayer;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLuint renderBuffer;
@property (nonatomic, assign) GLuint frameBuffer;
@property (nonatomic, assign) GLuint program;
@property (nonatomic, assign) GLuint texture;

@end

@implementation RenderView

- (void)layoutSubviews {
    self.texture = 1;
    /* 渲染一张图片到图层上需要的步骤 */
    // 1.设置图层
    [self setupLayer];
    // 2.设置图形上下文
    [self setupContext];
    // 3.清空缓存区
    [self clearBuffer];
    // 4.设置RenderBuffer渲染缓冲区
    [self setupRenderBuffer];
    // 5.设置FrameBuffer帧缓冲区
    [self setupFrameBuffer];
    // 6.开始绘制
    [self renderLayer];
}
- (void)dealloc {
    [self clearBuffer];
}
#pragma mark - 开始绘制
- (void)renderLayer {
    // 设置清屏颜色
    glClearColor(0.5, 0.5, 0.5, 1.0);
    // 清空颜色缓存区
    glClear(GL_COLOR_BUFFER_BIT);
    // 设置视口大小
    CGFloat scale = [UIScreen mainScreen].scale;
    glViewport(0, 0, self.bounds.size.width * scale, self.bounds.size.height * scale);
    // 获取顶点着色器程序、片元着色器程序路径
    NSString *vertexFilePath = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fragmentFilePath = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
    // 把顶点着色器程序、片元着色器程序经过编译后附加到program上
    self.program = [self creatprogramWithVertexShaderPath:vertexFilePath fragmentShaderPath:fragmentFilePath];
    // 链接program
    glLinkProgram(self.program);
    // 判断是否链接成功
    GLint linkStatus;
    glGetProgramiv(self.program, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        // 链接失败打印信息
        GLchar message[512];
        glGetProgramInfoLog(self.program, sizeof(message), 0, &message[0]);
        NSString *messageString = [NSString stringWithUTF8String:message];
        NSLog(@"Program Link Error:%@",messageString);
        return;
    }
    NSLog(@"Program Link Success!");
    // 链接成功后使用program
    glUseProgram(self.program);
    // 设置顶点、纹理坐标
    GLfloat pointArray[] = {

        -0.5f, 0.5f, 0.0f, 0.0f, 1.0f,
        -0.5f, -0.5f, 0.0f, 0.0f, 0.0f,
        0.5f, -0.5f, 0.0f, 1.0f, 0.0f,

        -0.5f, 0.5f, 0.0f, 0.0f, 1.0f,
        0.5f, -0.5f, 0.0f, 1.0f, 0.0f,
        0.5f, 0.5f, 0.0f, 1.0f, 1.0f,
    };
    // 申请一块缓存区(位于GPU上)，把顶点、纹理数据存储进去
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);//申请缓存
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);//绑定数据格式
    glBufferData(GL_ARRAY_BUFFER, sizeof(pointArray), pointArray, GL_DYNAMIC_DRAW);//存储数据
    // 把顶点数据和纹理数据正确的传入到顶点着色器里
    GLuint position = glGetAttribLocation(self.program, "position");//获取属性变量位置
    glEnableVertexAttribArray(position);//打开对应属性变量通道(因为出于性能考虑，数据读取通道默认关闭)
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);//设置数据读取格式
    GLuint textCoordinate = glGetAttribLocation(self.program, "textCoordinate");
    glEnableVertexAttribArray(textCoordinate);
    glVertexAttribPointer(textCoordinate, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat*)NULL + 3);
    // 从资源里加载纹理
    [self setupTexture];
    // 设置纹理采样器,把上面载入了的纹理，传递给片元着色器，因为本次只使用一个纹理，所以对应传入位置为0
    glUniform1i(glGetUniformLocation(self.program, "colorMap"), 0);
    // 绘图
    glDrawArrays(GL_TRIANGLES, 0, 6);
    // 从渲染缓存区显示到屏幕上
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setupTexture {
    UIImage *image = [UIImage imageNamed:@"test"];
    CGImageRef imageRef = image.CGImage;
    if (!imageRef) {
        NSLog(@"加载图片失败");
        return ;
    }
    // 获取图片宽高
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    // 申请图片字节数(宽*高*4)大小的内存
    GLbyte *imageData = calloc(width * height * 4, sizeof(GLubyte));
    // 创建上下文
    /*
     参数1：data,指向要渲染的绘制图像的内存地址
     参数2：width,bitmap的宽度，单位为像素
     参数3：height,bitmap的高度，单位为像素
     参数4：bitPerComponent,内存中像素的每个组件的位数，比如32位RGBA，就设置为8
     参数5：bytesPerRow,bitmap的没一行的内存所占的比特数
     参数6：colorSpace,bitmap上使用的颜色空间
     参数7：bitmapInfo，kCGImageAlphaPremultipliedLast：RGBA，rgbag格式
     */
    CGContextRef contextRef = CGBitmapContextCreate(imageData, width, height, 8, width*4, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
    // 设置绘制区域
    CGRect rect = CGRectMake(0, 0, width, height);
    // 用默认方式绘制图片到上下文指定的内存中
    CGContextDrawImage(contextRef, rect, imageRef);
    // 绘制完成后就可以释放上下文了
    CGContextRelease(contextRef);
    // 绑定到纹理单元和纹理名字
    glBindTexture(GL_TEXTURE_2D, GL_TEXTURE0);
    // 设置绑定的纹理单元的纹理属性
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    // 向绑定的纹理单元载入纹理数据
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    // 载入纹理后，申请的图片内存也就可以释放了
    free(imageData);
}



- (GLuint)creatprogramWithVertexShaderPath:(NSString *)vertexFilePath fragmentShaderPath:(NSString *)fragmentFilePath {
    // 创建program
    GLuint program = glCreateProgram();

    // 编译着色器
    GLuint vertexShader, fragmentShader;
    [self compileShader:&vertexShader shaderType:GL_VERTEX_SHADER shaderFilePath:vertexFilePath];
    [self compileShader:&fragmentShader shaderType:GL_FRAGMENT_SHADER shaderFilePath:fragmentFilePath];
    // 附加着色器到program
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    // 释放不再需要的着色器
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    return program;
}
- (void)compileShader:(GLuint *)shader shaderType:(GLenum)shaderType shaderFilePath:(NSString *)shaderFilePath {
    /// 把着色器源码读成字符串
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderFilePath encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[shaderString UTF8String];
    // 创建着色器
    *shader = glCreateShader(shaderType);
    // 把着色器源码加到着色器上
    /*
     glShaderSource (GLuint shader, GLsizei count, const GLchar* const *string, const GLint* length)
     shader:要编译的着色器对象
     numOfStrings:传递的源码字符串数量
     strings:着色器程序的源码（真正的着色器程序源码）
     lenOfStrings:长度，具有每个字符串长度的数组，或NULL，这意味着字符串是NULL终止的
     */
    glShaderSource(*shader, 1, &source, NULL);
    // 把着色器源代码编译成目标代码
    glCompileShader(*shader);
    GLint compileStatus;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &compileStatus);
    if (compileStatus == GL_FALSE) {
        // 链接失败打印信息
        GLchar message[512];
        glGetShaderInfoLog(*shader, sizeof(message), 0, &message[0]);
        NSString *messageString = [NSString stringWithUTF8String:message];
        NSLog(@"Compile Error:%@",messageString);
        return;
    }
    NSLog(@"Compile Success");
}

#pragma mark - 设置FrameBuffer帧缓冲区
- (void)setupFrameBuffer {
    // 申请缓存区标志
    glGenFramebuffers(1, &_frameBuffer);
    // 通过缓存区标志把缓存区绑定到GL_RENDERBUFFER
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    // 把渲染缓冲区挂载到帧缓冲区的颜色挂载点上
    // 颜色挂载点有多个,从GL_COLOR_ATTACHMENT0到GL_COLOR_ATTACHMENT0+i
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
}
#pragma mark - 设置RenderBuffer渲染缓冲区
- (void)setupRenderBuffer {
    // 申请缓存区标志
    // glGenRenderbuffers (GLsizei n, GLuint* renderbuffers) n:申请缓冲区数目 renderbuffers：存储生成的renderbuffer对象名的数组
    glGenRenderbuffers(1, &_renderBuffer);
    // 通过缓存区标志把缓存区绑定到GL_RENDERBUFFER
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    // 将可绘制对象(当前layer)的存储绑定到OpenGL ES的renderbuffer对象
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.glLayer];
}
#pragma mark - 清空缓存区
- (void)clearBuffer {
    // 释放开辟的渲染缓冲区
    glDeleteBuffers(1, &_renderBuffer);
    self.renderBuffer = 0;
    // 释放开辟的帧缓冲区
    glDeleteBuffers(1, &_frameBuffer);
    self.frameBuffer = 0;
}
#pragma mark - 设置图形上下文
- (void)setupContext {
    // 指定使用的OpenGL ES版本
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES3;
    // 创建图形上下文
    self.context = [[EAGLContext alloc] initWithAPI:api];
    if (!self.context) {
        NSLog(@"图形上下文创建失败");
        return ;
    }
    // 设置为当前上下文
    BOOL ok = [EAGLContext setCurrentContext:self.context];
    if (!ok) {
        NSLog(@"设置当前上下文失败");
        return ;
    }
}
#pragma mark - 设置图层
// 先通过重写+layerClass把view的layer替换成CAEAGLLayer，
+ (Class)layerClass {
    return [CAEAGLLayer class];
}
- (void)setupLayer {
    // 然后这里用self.glLayer引用一下，方便后面使用不需要每次使用写类型转换
    self.glLayer = (CAEAGLLayer *)self.layer;
    // 设置scale跟屏幕的一致
    self.contentScaleFactor = [[UIScreen mainScreen]scale];
    // 设置一些绘制属性
    /*
     drawableProperties字典指定该对象在附加到OpenGL ES renderbuffer时使用的属性。
     在将这个对象传递给EAGLContext方法renderbufferStorage:fromDrawable:之前，您的应用程序应该设置这些属性。
     如果更改了drawableProperties字典，必须再次在上下文中调用renderbufferStorage:fromDrawable:以使新值生效。
     kEAGLDrawablePropertyRetainedBacking:指定可绘制表面显示后是否保留其内容的键.
     只有在需要内容保持不变的情况下，才建议将值设置为YES，因为使用它会导致性能下降和额外的内存使用。
     默认值是NO。
     kEAGLDrawablePropertyColorFormat:指定可绘制表面的内部颜色缓冲区格式的键.
     它指定了一个特定的颜色缓冲区格式,EAGLContext对象使用这种颜色缓冲区格式来创建renderbuffer的存储。
     默认值是kEAGLColorFormatRGBA8。
     kEAGLDrawablePropertyColorFormat支持颜色格式：
     kEAGLColorFormatRGBA8：指定与OpenGL ES GL_RGBA8888格式相对应的32位RGBA格式
     kEAGLColorFormatRGB565：指定与OpenGL ES GL_RGB565格式相对应的16位RGB格式
     kEAGLColorFormatSRGBA8：sRGB代表了标准的红、绿、蓝，即CRT显示器、LCD显示器、投影机、打印机以及其他设备中色彩再现所使用的三个基本色素。
     sRGB的色彩空间基于独立的色彩坐标，可以使色彩在不同的设备使用传输中对应于同一个色彩坐标体系，而不受这些设备各自具有的不同色彩坐标的影响。
     */
    self.glLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking : @false,
                                        kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8,
    };
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
