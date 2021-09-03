//
//  ViewController.m
//  旋转正方体
//
//  Created by Misaka on 2020/1/11.
//  Copyright © 2020 Misaka. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 vertexCoord;//顶点坐标
    GLKVector2 textureCoord;//纹理坐标
} VertexData;

// 顶点数 6个面，每个面2个三角形 每个三角形3个顶点
static NSInteger const VertexCount = 36;

@interface ViewController ()<GLKViewDelegate>

// 效果
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
// glkView
@property (nonatomic, strong) GLKView *glkView;
// 开辟的顶点数据区域首地址指针
@property (nonatomic, assign) VertexData *vertices;
// 定时器
@property (nonatomic, strong) CADisplayLink *displayLink;
// 旋转z角度
@property (nonatomic, assign) NSInteger angle;
// 顶点缓存区标识
@property (nonatomic, assign) GLuint vertexBuffer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // OpenGL ES 相关配置
    [self setupOpenGLES];
    // 设置顶点、纹理数据
    [self setupVertexData];
    // 添加CADisplayLink
    [self addCADisplayLink];

}

// OpenGL ES 相关配置
- (void)setupOpenGLES {
    // 创建context
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    // 设置context
    [EAGLContext setCurrentContext:context];
    CGRect rect = CGRectMake(0, (self.view.frame.size.height - self.view.frame.size.width)/2, self.view.frame.size.width, self.view.frame.size.width);
    // 创建GLKView、设置代理
    self.glkView = [[GLKView alloc] initWithFrame:rect context:context];
    self.glkView.delegate = self;//代理
    self.glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;//深底缓存
    glClearColor(0.7, 0.7, 0.7, 1.0);
    // 默认是(0, 1)，这里用于翻转 z 轴，使正方形朝屏幕外
    //glDepthRangef(1, 0);
    [self.view addSubview:self.glkView];
    /// 加载图片纹理
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"kkk" ofType:@"png"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft : @(YES)};
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:options error:nil];
    // 设置baseEffect
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
}

// 设置顶点、纹理数据
- (void)setupVertexData {
    // 分配内存
    self.vertices = malloc(sizeof(VertexData) * VertexCount);
    // 设置数据
    // 前面
    self.vertices[0] = (VertexData){{-0.5, 0.5, 0.5},  {0, 1}};
    self.vertices[1] = (VertexData){{-0.5, -0.5, 0.5}, {0, 0}};
    self.vertices[2] = (VertexData){{0.5, 0.5, 0.5},   {1, 1}};

    self.vertices[3] = (VertexData){{-0.5, -0.5, 0.5}, {0, 0}};
    self.vertices[4] = (VertexData){{0.5, 0.5, 0.5},   {1, 1}};
    self.vertices[5] = (VertexData){{0.5, -0.5, 0.5},  {1, 0}};

    // 上面
    self.vertices[6] = (VertexData){{0.5, 0.5, 0.5},    {1, 1}};
    self.vertices[7] = (VertexData){{-0.5, 0.5, 0.5},   {0, 1}};
    self.vertices[8] = (VertexData){{0.5, 0.5, -0.5},   {1, 0}};
    self.vertices[9] = (VertexData){{-0.5, 0.5, 0.5},   {0, 1}};
    self.vertices[10] = (VertexData){{0.5, 0.5, -0.5},  {1, 0}};
    self.vertices[11] = (VertexData){{-0.5, 0.5, -0.5}, {0, 0}};

    // 下面
    self.vertices[12] = (VertexData){{0.5, -0.5, 0.5},    {1, 1}};
    self.vertices[13] = (VertexData){{-0.5, -0.5, 0.5},   {0, 1}};
    self.vertices[14] = (VertexData){{0.5, -0.5, -0.5},   {1, 0}};
    self.vertices[15] = (VertexData){{-0.5, -0.5, 0.5},   {0, 1}};
    self.vertices[16] = (VertexData){{0.5, -0.5, -0.5},   {1, 0}};
    self.vertices[17] = (VertexData){{-0.5, -0.5, -0.5},  {0, 0}};

    // 左面
    self.vertices[18] = (VertexData){{-0.5, 0.5, 0.5},    {1, 1}};
    self.vertices[19] = (VertexData){{-0.5, -0.5, 0.5},   {0, 1}};
    self.vertices[20] = (VertexData){{-0.5, 0.5, -0.5},   {1, 0}};
    self.vertices[21] = (VertexData){{-0.5, -0.5, 0.5},   {0, 1}};
    self.vertices[22] = (VertexData){{-0.5, 0.5, -0.5},   {1, 0}};
    self.vertices[23] = (VertexData){{-0.5, -0.5, -0.5},  {0, 0}};

    // 右面
    self.vertices[24] = (VertexData){{0.5, 0.5, 0.5},    {1, 1}};
    self.vertices[25] = (VertexData){{0.5, -0.5, 0.5},   {0, 1}};
    self.vertices[26] = (VertexData){{0.5, 0.5, -0.5},   {1, 0}};
    self.vertices[27] = (VertexData){{0.5, -0.5, 0.5},   {0, 1}};
    self.vertices[28] = (VertexData){{0.5, 0.5, -0.5},   {1, 0}};
    self.vertices[29] = (VertexData){{0.5, -0.5, -0.5},  {0, 0}};

    // 后面
    self.vertices[30] = (VertexData){{-0.5, 0.5, -0.5},   {0, 1}};
    self.vertices[31] = (VertexData){{-0.5, -0.5, -0.5},  {0, 0}};
    self.vertices[32] = (VertexData){{0.5, 0.5, -0.5},    {1, 1}};
    self.vertices[33] = (VertexData){{-0.5, -0.5, -0.5},  {0, 0}};
    self.vertices[34] = (VertexData){{0.5, 0.5, -0.5},    {1, 1}};
    self.vertices[35] = (VertexData){{0.5, -0.5, -0.5},   {1, 0}};

    //开辟缓存区 VBO
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    GLsizeiptr bufferSizeBytes = sizeof(VertexData) * VertexCount;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertices, GL_STATIC_DRAW);

    //顶点数据
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(VertexData), NULL + offsetof(VertexData, vertexCoord));
    // offsetof(VertexData, vertexCoord) 获取VertexData结构体中，vertexCoord的偏移量
    //纹理数据
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(VertexData), NULL + offsetof(VertexData, textureCoord));
}

// 添加CADisplayLink
-(void)addCADisplayLink {
    self.angle = 0.0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    self.displayLink.frameInterval = 2;
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)update {
    //计算旋转度数
    self.angle = (self.angle + 1) % 360;
    //修改模型视图矩阵
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(self.angle), 0.2, 0.5, 0.3);
    //重新渲染
    [self.glkView display];
}

#pragma mark - GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // 开启深度测试
    glEnable(GL_DEPTH_TEST);
    // 清除颜色缓存区&深度缓存区
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    // 准备绘制
    [self.baseEffect prepareToDraw];
    // 绘图
    glDrawArrays(GL_TRIANGLES, 0, VertexCount);
}

#pragma mark - dealloc
- (void)dealloc {
    // 关闭定时器
    [self.displayLink invalidate];
    // 清除上下文
    if ([EAGLContext currentContext] == self.glkView.context) {
        [EAGLContext setCurrentContext:nil];
    }
    // 释放申请的内存
    if (_vertices) {
        free(_vertices);
        _vertices = nil;
    }
    // 释放开辟的数据缓存区
    if (_vertexBuffer) {
        glDeleteBuffers(1, &_vertexBuffer);
        _vertexBuffer = 0;
    }
}


@end
