//
//  ViewController.m
//  渲染图片
//
//  Created by Misaka on 2020/1/3.
//  Copyright © 2020 Misaka. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    EAGLContext *context;//上下文
    GLKBaseEffect *cEffect;//渲染效果
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //1.OpenGL ES相关初始化
    [self setUpConfig];
    //2.加载顶点/纹理坐标数据
    [self setUpVertexData];
    //3.加载纹理数据(使用GLBaseEffect)
    [self setUpTexture];

}

-(void)setUpTexture {
    //1.获取纹理图片路径
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"image_01" ofType:@"jpg"];
    //2.设置纹理参数(图片翻转)
    //纹理坐标原点是左下角,但是图片显示原点应该是左上角.所以图片需要翻转一下
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft : @(YES),};//把左下角设为原点(改动的不是原始纹理的坐标，改变的是映射关系)
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    //3.使用苹果GLKit 提供GLKBaseEffect 完成着色器工作(顶点/片元)
    cEffect = [[GLKBaseEffect alloc]init];
    cEffect.texture2d0.enabled = GL_TRUE;
    cEffect.texture2d0.name = textureInfo.name;
}

-(void)setUpVertexData {
    // 1.设置顶点数组{x,y,z, s,t}顶点坐标x,y,z 纹理坐标s,t
    GLfloat vertexData[] = {
        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        0.5, 0.5, -0.0f,    1.0f, 1.0f, //右上
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上

        0.5, -0.5, 0.0f,    1.0f, 0.0f, //右下
        -0.5, 0.5, 0.0f,    0.0f, 1.0f, //左上
        -0.5, -0.5, 0.0f,   0.0f, 0.0f, //左下
    };
    // 2.开辟顶点缓存区
    //2.1.创建顶点缓存区标识符ID
    GLuint bufferID;
    glGenBuffers(1, &bufferID);//参数1表示顶点缓存区数量
    //2.2.绑定顶点缓存区.(明确作用)，存储数组
    glBindBuffer(GL_ARRAY_BUFFER, bufferID);
    //2.3.将顶点数组的数据copy到顶点缓存区中(GPU显存中)
    /*参数1:存储数据类型 GL_ARRAY_BUFFER，存储数组类型数据
     参数2:数据长度
     参数3:数据源
     参数4:作用，GL_STATIC_DRAW：静态绘制
     */
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);
    // 3.打开读取通道
  //在iOS中,默认情况下，出于性能考虑，所有顶点着色器的属性（Attribute）变量都是关闭的.意味着,顶点数据在着色器端(服务端)是不可用的.即使你已经使用glBufferData方法,将顶点数据从内存拷贝到顶点缓存区中(GPU显存中). 所以, 必须由glEnableVertexAttribArray 方法打开通道.指定访问属性.才能让顶点着色器能够访问到从CPU复制到GPU的数据.
    /*
     glVertexAttribPointer (GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr)
     功能: 上传顶点数据到显存的方法（设置合适的方式从buffer里面读取数据）
     参数：
     index,指定要修改的顶点属性的索引值
     size, 每次读取数量。（如position是由3个（x,y,z）组成，而颜色是4个（r,g,b,a）,二维纹理则是2个(s,t).）
     type,指定数组中每个组件的数据类型。可用的符号常量有GL_BYTE, GL_UNSIGNED_BYTE, GL_SHORT,GL_UNSIGNED_SHORT, GL_FIXED, 和 GL_FLOAT，初始值为GL_FLOAT。
     normalized,指定当被访问时，固定点数据值是否应该被归一化（GL_TRUE）或者直接转换为固定点值（GL_FALSE）
     stride,指定连续顶点属性之间的偏移量。如果为0，那么顶点属性会被理解为：它们是紧密排列在一起的。初始值为0
     ptr,首地址, 指定一个指针，指向数组中第一个顶点属性的第一个组件。初始值为0
     */
    //打开顶点属性通道
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //设置读取顶点数据方式
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    //打开纹理属性通道
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    //设置读取纹理数据方式
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
    /*
     定义好的属性通道：
     GLKVertexAttribPosition,//顶点
     GLKVertexAttribNormal,//法线
     GLKVertexAttribColor,//颜色
     GLKVertexAttribTexCoord0,//纹理1
     GLKVertexAttribTexCoord1//纹理2
     */
}

-(void)setUpConfig {
    // 1.初始化上下文
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!context) {
        NSLog(@"error");
        return ;
    }
    // 2.设置上下文
    [EAGLContext setCurrentContext:context];
    // 3.获取GLKView
    GLKView *view = (GLKView *)self.view;
    view.context = context;
    // 设置渲染缓冲区
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    // 设置清屏颜色
    glClearColor(0.7, 0.7, 0.7, 1.0);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    //1.清理颜色缓冲区
    glClear(GL_COLOR_BUFFER_BIT);
    //2.准备绘制
    [cEffect prepareToDraw];
    //3.开始绘制
    glDrawArrays(GL_TRIANGLES, 0, 6);
}


@end
