//
//  ViewController.m
//  SimpleLightingDemo
//
//  Created by Misaka on 2020/5/18.
//  Copyright © 2020 Misaka. All rights reserved.
//

#import "ViewController.h"
#import "RenderMathTool.h"
#import "AGLKVertexAttribArrayBuffer.h"

@interface ViewController ()

/// 上下文
@property (nonatomic, strong) EAGLContext *context;
/// 物体Effect
@property (nonatomic, strong) GLKBaseEffect *objectEffect;
/// 光线/法线Effect
@property (nonatomic, strong) GLKBaseEffect *normalEffect;
/// 物体buffer
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *objectBuffer;
/// 光线/法线buffer
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *normalBuffer;
/// 是否绘制法线
@property (nonatomic, assign) BOOL isRenderNormal;
/// 顶点高度
@property (nonatomic, assign) GLfloat height;


@end

@implementation ViewController {
    /// 顶点数据
    TriangleStructure triangles[TriangleCount];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupOpenGLES];
    [self setupEffect];
    [self setupBuffer];
}

- (void)setupBuffer {
    triangles[0] = createTriangle(vertex0, vertex1, vertex3);
    triangles[1] = createTriangle(vertex1, vertex2, vertex5);
    triangles[2] = createTriangle(vertex3, vertex1, vertex4);
    triangles[3] = createTriangle(vertex1, vertex5, vertex4);
    triangles[4] = createTriangle(vertex3, vertex7, vertex6);
    triangles[5] = createTriangle(vertex3, vertex4, vertex7);
    triangles[6] = createTriangle(vertex4, vertex5, vertex7);
    triangles[7] = createTriangle(vertex5, vertex8, vertex7);

    self.objectBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(VertexStructure) numberOfVertices:sizeof(triangles)/sizeof(VertexStructure) bytes:triangles usage:GL_DYNAMIC_DRAW];
    self.normalBuffer = [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(GLKVector3) numberOfVertices:0 bytes:NULL usage:GL_DYNAMIC_DRAW];
    self.height = -0.5f;

}

- (void)setupEffect {
    self.objectEffect = [[GLKBaseEffect alloc] init];
    self.objectEffect.light0.enabled = GL_TRUE;//使用光源0
    self.objectEffect.light0.diffuseColor = GLKVector4Make(0.7, 0.7, 0.7, 1.0);//光源的漫反射颜色
    self.objectEffect.light0.position = GLKVector4Make(1.0f, 1.0f, 0.5f, 0.0f);//世界坐标中的光的位置
    self.normalEffect = [[GLKBaseEffect alloc] init];
    self.normalEffect.useConstantColor = GL_TRUE;

    /// 方便观察
    //围绕x轴旋转-60度
    //返回一个4x4矩阵进行绕任意矢量旋转
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-60.0f), 1.0f, 0.0f, 0.0f);
    //围绕z轴，旋转-30度
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix,GLKMathDegreesToRadians(-30.0f), 0.0f, 0.0f, 1.0f);
    //围绕Z方向，移动0.25f
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0f, 0.0f, 0.25f);
    //设置baseEffect,extraEffect 模型矩阵
    self.objectEffect.transform.modelviewMatrix = modelViewMatrix;
    self.normalEffect.transform.modelviewMatrix = modelViewMatrix;

}

- (void)setupOpenGLES {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;

    [EAGLContext setCurrentContext:self.context];
}

- (void)drawNormal {
    GLKVector3 normalLines[LineVertexCount];
    /// 准备顶点数据
    getLinePoints(triangles, GLKVector3MakeWithArray(self.objectEffect.light0.position.v), normalLines);
    [self.normalBuffer reinitWithAttribStride:sizeof(GLKVector3) numberOfVertices:sizeof(normalLines)/sizeof(GLKVector3) bytes:normalLines];
    [self.normalBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    /// 绘制法线
    self.normalEffect.useConstantColor = GL_TRUE;
    self.normalEffect.constantColor = GLKVector4Make(1.0, 1.0, 0.0, 1.0);
    [self.normalEffect prepareToDraw];
    [self.normalBuffer drawArrayWithMode:GL_LINES startVertexIndex:0 numberOfVertices:NormalVertexCount];
    /// 绘制光线
    self.normalEffect.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    [self.normalEffect prepareToDraw];
    [self.normalBuffer drawArrayWithMode:GL_LINES startVertexIndex:NormalVertexCount numberOfVertices:2];
}

- (void)drawObject {
    [self.objectEffect prepareToDraw];
    [self.objectBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(VertexStructure, position) shouldEnable:YES];
    [self.objectBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:offsetof(VertexStructure, normal) shouldEnable:YES];
    [self.objectBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sizeof(triangles)/sizeof(VertexStructure)];
}

-(void)updateNormals {
    //更新每个点的平面法向量
    updateNormal(triangles);
    [self.objectBuffer reinitWithAttribStride:sizeof(VertexStructure) numberOfVertices:sizeof(triangles)/sizeof(VertexStructure) bytes:triangles];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {

    glClearColor(0.3, 0.3, 0.3, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    [self drawObject];
    if (self.isRenderNormal) {
        [self drawNormal];
    }
}

- (void)setHeight:(GLfloat)height {
    _height = height;
    VertexStructure newVertex4 = vertex4;
    newVertex4.position.z = height;
    triangles[2] = createTriangle(vertex3, vertex1, newVertex4);
    triangles[3] = createTriangle(vertex1, vertex5, newVertex4);
    triangles[5] = createTriangle(vertex3, newVertex4, vertex7);
    triangles[6] = createTriangle(newVertex4, vertex5, vertex7);
    [self updateNormals];
}

- (IBAction)sliderChange:(UISlider *)sender {
    self.height = sender.value;
}

- (IBAction)switchChange:(UISwitch *)sender {
    self.isRenderNormal = sender.on;
}

@end
