//
//  ViewController.m
//  加载图片
//
//  Created by Misaka on 2020/3/3.
//  Copyright © 2020 Misaka. All rights reserved.
//

#import "ViewController.h"
#import "RenderView.h"

@interface ViewController ()

@end

@implementation ViewController

/// 把self.view转为RenderView类型
- (void)loadView {
    self.view = [[RenderView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


@end
