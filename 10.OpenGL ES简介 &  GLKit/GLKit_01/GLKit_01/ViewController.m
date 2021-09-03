//
//  ViewController.m
//  GLKit_01
//
//  Created by Misaka on 2020/1/3.
//  Copyright © 2020 Misaka. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    EAGLContext *context;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 1.初始化上下文
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    /*
     初始化上下文时用的API，一般用2.0或3.0
     kEAGLRenderingAPIOpenGLES1 = 1,OpenGL 1.0版本
     kEAGLRenderingAPIOpenGLES2 = 2,OpenGL 2.0版本
     kEAGLRenderingAPIOpenGLES3 = 3,OpenGL 3.0版本
     */
    if (!context) {
        NSLog(@"上下文创建失败");
    }
    // 2.设置上下文
    [EAGLContext setCurrentContext:context];
    // 3.获取GLKView
    GLKView *view = (GLKView *)self.view;
    view.context = context;

    // 其他
    glClearColor(0.0, 1.0, 0.0, 1.0);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    // 清理颜色缓存区
    glClear(GL_COLOR_BUFFER_BIT);
}


@end
