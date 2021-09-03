//
//  ViewController.m
//  GLSL索引绘制
//
//  Created by Misaka on 2020/3/31.
//  Copyright © 2020 Misaka. All rights reserved.
//

#import "ViewController.h"
#import "RenderView.h"

@interface ViewController ()

@property (nonatomic, strong) RenderView *renderView;

@property (nonatomic, strong) UIButton *xBtn;
@property (nonatomic, strong) UIButton *yBtn;
@property (nonatomic, strong) UIButton *zBtn;
@property (nonatomic, assign) BOOL bX;
@property (nonatomic, assign) BOOL bY;
@property (nonatomic, assign) BOOL bZ;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController

- (void)loadView {
    self.view = [[RenderView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.renderView = (RenderView *)self.view;

    CGFloat height = 550;
    self.xBtn = [self btnWithTitle:@"X"];
    self.xBtn.center = CGPointMake(50, height);
    [self.view addSubview:self.xBtn];
    self.yBtn = [self btnWithTitle:@"Y"];
    self.yBtn.center = CGPointMake(170, height);
    [self.view addSubview:self.yBtn];
    self.zBtn = [self btnWithTitle:@"Z"];
    self.zBtn.center = CGPointMake(290, height);
    [self.view addSubview:self.zBtn];



}

- (UIButton *)btnWithTitle:(NSString *)title {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    btn.backgroundColor = [UIColor yellowColor];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(void)reDegree {
    if (self.bX) {
        self.renderView.xDegree += 3;
    }
    if (self.bY) {
        self.renderView.yDegree += 3;
    }
    if (self.bZ) {
        self.renderView.zDegree += 3;
    }
    //重新渲染
    [self.renderView render];

}


- (void)btnClick:(UIButton *)btn {
    NSString *string = [btn titleForState:UIControlStateNormal];
    if ([string isEqualToString:@"X"]) {
        self.bX = !self.bX;
    }else if ([string isEqualToString:@"Y"]) {
        self.bY = !self.bY;
    }else if ([string isEqualToString:@"Z"]) {
        self.bZ = !self.bZ;
    }
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reDegree) userInfo:nil repeats:YES];
    }
}



@end
