//
//  ViewController.m
//  CustomParticle
//
//  Created by Misaka on 2020/6/17.
//  Copyright © 2020 Misaka. All rights reserved.
//

#import "ViewController.h"
#import "MCustomParticleManager.h"

@interface ViewController ()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) MCustomParticleManager *manager;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, strong) UIButton *nextBtn;

@end

@implementation ViewController

- (void)setIndex:(NSInteger)index {
    _index = (index >= 15) ? 0 : index;
}

- (void)customParticleWithIndex:(NSInteger)index {
    if (self.manager) {
        [self.manager stop];
    }
    self.indexLabel.text = [NSString stringWithFormat:@"%ld", (long)self.index];
    self.manager = [[MCustomParticleManager alloc] init];
    NSMutableArray *pathList = [[NSMutableArray alloc] init];
    NSArray *imageNameList = @[@"01", @"02", @"03", @"04"];
    if (self.btn.selected) {
        imageNameList = @[@"02"];
    }
    for (int i = 0; i < imageNameList.count; i ++) {
        NSString *path = [[NSBundle mainBundle] pathForResource:imageNameList[i] ofType:@"png"];
        [pathList addObject:path];
    }
    [self.manager setTexturesWithPathList:pathList];

    if (self.index == 0) {

        self.manager.position = GLKVector3Make(-0.5, -1.0, 0);
        self.manager.initialSpeed = GLKVector3Make(0.4, 2.0, -1.0);
        self.manager.initialSpeedXRange = 0.3;
        self.manager.initialSpeedYRange = 0.2;
        self.manager.initialSpeedZRange = 0.2;
        self.manager.acceleration = GLKVector3Make(0.001, -0.3, 0);
        self.manager.accelerationXRange = 0.0;
        self.manager.accelerationYRange = 0.0;
        self.manager.accelerationZRange = 0.001;
        self.manager.launchTime = 0;
        self.manager.duration = 12.0;
        self.manager.durationRange = 3.0;
        self.manager.disappearDuration = 12.0;
        self.manager.disappearDurationRange = 3.0;
        self.manager.size = 15.0;
        self.manager.sizeRange = 6.0;
        self.manager.count = 10;
        self.manager.firingInterval = 0.1;
    }else if (self.index == 1) {

        self.manager.position = GLKVector3Make(0, 0, 0);
        self.manager.initialSpeed = GLKVector3Make(0, 0, 0);
        self.manager.initialSpeedXRange = 0;
        self.manager.initialSpeedYRange = 0;
        self.manager.initialSpeedZRange = 0;
        self.manager.acceleration = GLKVector3Make(0.0, 0.0, 0);
        self.manager.accelerationXRange = 0.1;
        self.manager.accelerationYRange = 0.1;
        self.manager.accelerationZRange = 0.001;
        self.manager.launchTime = 0;
        self.manager.duration = 5.0;
        self.manager.durationRange = 3.0;
        self.manager.disappearDuration = 5.0;
        self.manager.disappearDurationRange = 3.0;
        self.manager.size = 16.0;
        self.manager.sizeRange = 8.0;
        self.manager.count = 30;
        self.manager.firingInterval = 0.5;
    }else if (self.index == 2) {

        self.manager.position = GLKVector3Make(0, 0, 0);
        self.manager.positionXRange = 0.1;
        self.manager.positionYRange = 0.1;
        self.manager.initialSpeed = GLKVector3Make(0, 0, 0);
        self.manager.initialSpeedXRange = 0;
        self.manager.initialSpeedYRange = 0;
        self.manager.initialSpeedZRange = 0;
        self.manager.acceleration = GLKVector3Make(0.0, 0.0, 0);
        self.manager.accelerationXRange = 0.1;
        self.manager.accelerationYRange = 0.1;
        self.manager.accelerationZRange = 0.001;
        self.manager.launchTime = 0;
        self.manager.duration = 5.0;
        self.manager.durationRange = 3.0;
        self.manager.disappearDuration = 5.0;
        self.manager.disappearDurationRange = 3.0;
        self.manager.size = 10.0;
        self.manager.sizeRange = 8.0;
        self.manager.count = 100;
        self.manager.firingInterval = 0.5;
    }else if (self.index == 3) {

        self.manager.position = GLKVector3Make(0, 0, 0);
        self.manager.positionXRange = 0.5;
        self.manager.positionYRange = 1.0;
        self.manager.initialSpeed = GLKVector3Make(0, 0, 0);
        self.manager.initialSpeedXRange = 0;
        self.manager.initialSpeedYRange = 0;
        self.manager.initialSpeedZRange = 0;
        self.manager.acceleration = GLKVector3Make(0.0, 0.0, 0);
        self.manager.accelerationXRange = 0.1;
        self.manager.accelerationYRange = 0.1;
        self.manager.accelerationZRange = 0.001;
        self.manager.launchTime = 0;
        self.manager.duration = 5.0;
        self.manager.durationRange = 3.0;
        self.manager.disappearDuration = 5.0;
        self.manager.disappearDurationRange = 3.0;
        self.manager.size = 16.0;
        self.manager.sizeRange = 8.0;
        self.manager.count = 30;
        self.manager.firingInterval = 0.5;
    }else if (self.index == 4) {

        self.manager.position = GLKVector3Make(0, 0, 0);
        self.manager.positionXRange = 0.5;
        self.manager.positionYRange = 1.0;
        self.manager.initialSpeed = GLKVector3Make(0, 0, 0);
        self.manager.initialSpeedXRange = 0;
        self.manager.initialSpeedYRange = 0;
        self.manager.initialSpeedZRange = 0;
        self.manager.acceleration = GLKVector3Make(0.0, 0.0, 0);
        self.manager.accelerationXRange = 0;
        self.manager.accelerationYRange = 0;
        self.manager.accelerationZRange = 0;
        self.manager.launchTime = 0.5;
        self.manager.launchTimeRange = 0.2;
        self.manager.duration = 8.0;
        self.manager.durationRange = 7.0;
        self.manager.disappearDuration = 5.0;
        self.manager.disappearDurationRange = 3.0;
        self.manager.size = 30.0;
        self.manager.sizeRange = 20.0;
        self.manager.count = 3;
        self.manager.firingInterval = 0.3;
    }else if (self.index == 5) {

        self.manager.position = GLKVector3Make(-0.5, 0, 0);
        self.manager.positionYRange = 1.0;
        self.manager.initialSpeed = GLKVector3Make(0.4, 0, 0);
        self.manager.initialSpeedXRange = 0.1;
        self.manager.acceleration = GLKVector3Make(0.0, 0.0, 0);
        self.manager.accelerationXRange = 0.01;
        self.manager.launchTime = 0;
        self.manager.duration = 5.0;
        self.manager.durationRange = 3.0;
        self.manager.disappearDuration = 5.0;
        self.manager.disappearDurationRange = 3.0;
        self.manager.size = 10.0;
        self.manager.sizeRange = 5.0;
        self.manager.count = 100;
        self.manager.firingInterval = 0.3;
    }else if (self.index == 6) {

        self.manager.position = GLKVector3Make(0, -1.0, 0);
        self.manager.positionXRange = 0.5;
        self.manager.initialSpeed = GLKVector3Make(0, 0.2, 0);
        self.manager.acceleration = GLKVector3Make(0.0, 0.0, 0);
        self.manager.launchTime = 0;
        self.manager.duration = 8.0;
        self.manager.durationRange = 4.0;
        self.manager.disappearDuration = 5.0;
        self.manager.disappearDurationRange = 2.0;
        self.manager.size = 15.0;
        self.manager.sizeRange = 5.0;
        self.manager.count = 30;
        self.manager.firingInterval = 0.5;
    }else if (self.index == 7) {

        self.manager.position = GLKVector3Make(0.0, -1.0, 0);
        self.manager.initialSpeed = GLKVector3Make(0.0, 0.2, 0);
        self.manager.initialSpeedXRange = 0.04;
        self.manager.acceleration = GLKVector3Make(0.0, 0.0, 0);
        self.manager.accelerationYRange = 0.01;
        self.manager.launchTime = 0;
        self.manager.launchTimeRange = 0.1;
        self.manager.duration = 7.0;
        self.manager.durationRange = 2.0;
        self.manager.disappearDuration = 5.0;
        self.manager.disappearDurationRange = 3.0;
        self.manager.size = 20.0;
        self.manager.sizeRange = 6.0;
        self.manager.count = 30;
        self.manager.firingInterval = 0.2;
    }else if (self.index == 8) {

        self.manager.position = GLKVector3Make(0.0, 0.0, 0);
        self.manager.isNormalized = YES;
        self.manager.normalizedInitialSpeed = 0.2;
        self.manager.normalizedAcceleration = 0.0;
        self.manager.launchTime = 0;
        self.manager.launchTimeRange = 0;
        self.manager.duration = 6.0;
        self.manager.durationRange = 0.0;
        self.manager.disappearDuration = 5.0;
        self.manager.disappearDurationRange = 0.0;
        self.manager.size = 25.0;
        self.manager.sizeRange = 0.0;
        self.manager.count = 100;
        self.manager.firingInterval = 0.4;
    }else if (self.index == 9) {

        self.manager.position = GLKVector3Make(0.0, 0.0, 0);
        self.manager.isNormalized = YES;
        self.manager.normalizedInitialSpeed = 0.2;
        self.manager.normalizedAcceleration = 0.0;
        self.manager.launchTime = 0;
        self.manager.launchTimeRange = 0.2;
        self.manager.duration = 6.0;
        self.manager.durationRange = 0.0;
        self.manager.disappearDuration = 5.0;
        self.manager.disappearDurationRange = 0.0;
        self.manager.size = 25.0;
        self.manager.sizeRange = 0.0;
        self.manager.count = 100;
        self.manager.firingInterval = 0.4;
    }else if (self.index == 10) {

        self.manager.position = GLKVector3Make(0.0, 0.0, 0);
        self.manager.isNormalized = YES;
        self.manager.normalizedInitialSpeed = 0.5;
        self.manager.normalizedAcceleration = -0.2;
        self.manager.launchTime = 0;
        self.manager.launchTimeRange = 0.0;
        self.manager.duration = 4.0;
        self.manager.durationRange = 0.0;
        self.manager.disappearDuration = 1.0;
        self.manager.disappearDurationRange = 0.0;
        self.manager.size = 25.0;
        self.manager.sizeRange = 0.0;
        self.manager.count = 40;
        self.manager.firingInterval = 4.0;
    }else if (self.index == 11) {

        self.manager.position = GLKVector3Make(0.0, 0.0, 0);
        self.manager.isNormalized = YES;
        self.manager.normalizedInitialSpeed = 0.5;
        self.manager.normalizedAcceleration = -0.2;
        self.manager.launchTime = 0;
        self.manager.launchTimeRange = 0.0;
        self.manager.duration = 4.0;
        self.manager.durationRange = 0.0;
        self.manager.disappearDuration = 1.0;
        self.manager.disappearDurationRange = 0.0;
        self.manager.size = 25.0;
        self.manager.sizeRange = 0.0;
        self.manager.count = 100;
        self.manager.firingInterval = 3.0;
    }else if (self.index == 12) {

        self.manager.position = GLKVector3Make(0.0, 0.0, 0);
        self.manager.isNormalized = YES;
        self.manager.normalizedInitialSpeed = 0.5;
        self.manager.normalizedAcceleration = -0.2;
        self.manager.launchTime = 0;
        self.manager.launchTimeRange = 0.2;
        self.manager.duration = 4.0;
        self.manager.durationRange = 0.0;
        self.manager.disappearDuration = 1.0;
        self.manager.disappearDurationRange = 0.0;
        self.manager.size = 25.0;
        self.manager.sizeRange = 0.0;
        self.manager.count = 100;
        self.manager.firingInterval = 4.0;
    }else if (self.index == 13) {

        self.manager.position = GLKVector3Make(0.0, 0.0, 0);
        self.manager.isNormalized = YES;
        self.manager.normalizedInitialSpeed = 0.25;
        self.manager.normalizedAcceleration = 0.0;
        self.manager.launchTime = 0;
        self.manager.launchTimeRange = 1.0;
        self.manager.duration = 2.5;
        self.manager.durationRange = 0.5;
        self.manager.disappearDuration = 1.0;
        self.manager.disappearDurationRange = 0.3;
        self.manager.size = 5.0;
        self.manager.sizeRange = 2.0;
        self.manager.count = 2000;
        self.manager.firingInterval = 3.0;
    }else if (self.index == 14) {

        self.manager.position = GLKVector3Make(0.0, 0.0, 0);
        self.manager.isNormalized = YES;
        self.manager.normalizedInitialSpeed = 0.25;
        self.manager.acceleration = GLKVector3Make(0.0, -0.03, 0.0);
        self.manager.launchTime = 0;
        self.manager.launchTimeRange = 1.0;
        self.manager.duration = 1.5;
        self.manager.durationRange = 0.3;
        self.manager.disappearDuration = 1.4;
        self.manager.disappearDurationRange = 0.1;
        self.manager.size = 5.0;
        self.manager.sizeRange = 2.0;
        self.manager.count = 2000;
        self.manager.firingInterval = 3.0;
    }

    float aspect = CGRectGetWidth(self.view.bounds) / CGRectGetHeight(self.view.bounds);
    self.manager.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0f), aspect, 0.1f,  20.0f);
    self.manager.transform.modelviewMatrix = GLKMatrix4MakeLookAt( 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
    /*
     GLKMatrix4 GLKMatrix4MakeLookAt(float eyeX, float eyeY, float eyeZ,
     float centerX, float centerY, float centerZ,
     float upX, float upY, float upZ)
     等价于 OpenGL 中
     void gluLookAt(GLdouble eyex,GLdouble eyey,GLdouble eyez,GLdouble centerx,GLdouble centery,GLdouble centerz,GLdouble upx,GLdouble upy,GLdouble upz);

     目的:根据你的设置返回一个4x4矩阵变换的世界坐标系坐标。
     参数1:眼睛位置的x坐标
     参数2:眼睛位置的y坐标
     参数3:眼睛位置的z坐标
     第一组:就是脑袋的位置

     参数4:正在观察的点的X坐标
     参数5:正在观察的点的Y坐标
     参数6:正在观察的点的Z坐标
     第二组:就是眼睛所看物体的位置

     参数7:摄像机上向量的x坐标
     参数8:摄像机上向量的y坐标
     参数9:摄像机上向量的z坐标
     第三组:就是头顶朝向的方向(因为你可以头歪着的状态看物体)
     */
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.btn];
    [self.view addSubview:self.indexLabel];
    [self.view addSubview:self.nextBtn];

    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:self.context];

    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;

    [self customParticleWithIndex:self.index];
}


- (void)update {
    self.manager.runTime = self.timeSinceFirstResume;
//    NSLog(@"update %lf", self.manager.runTime);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.5, 0.5, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    //开启混合
    glEnable(GL_BLEND);
    //设置混合因子
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [self.manager start];
//    NSLog(@"glkView drawInRect", self.manager.runTime);
}

- (void)btnClick {
    if (self.manager) {
        [self.manager stop];
    }
    self.btn.selected = !self.btn.selected;
    [self customParticleWithIndex:self.index];
}

- (void)nextBtnClick {
    if (self.manager) {
        [self.manager stop];
    }
    self.index = self.index + 1;
    [self customParticleWithIndex:self.index];
}

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 108, 60, 44)];
        _nextBtn.backgroundColor = [UIColor orangeColor];
        [_nextBtn setTitle:@"NEXT" forState:UIControlStateNormal];
        [_nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

- (UIButton *)btn {
    if (!_btn) {
        _btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 60, 44)];
        _btn.backgroundColor = [UIColor orangeColor];
        [_btn setTitle:@"彩色" forState:UIControlStateNormal];
        [_btn setTitle:@"单色" forState:UIControlStateSelected];
        [_btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn;
}

- (UILabel *)indexLabel {
    if (!_indexLabel) {
        _indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, 60, 44)];
        _indexLabel.backgroundColor = [UIColor whiteColor];
        _indexLabel.textColor = [UIColor redColor];
        _indexLabel.font = [UIFont boldSystemFontOfSize:18];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _indexLabel;
}


@end
