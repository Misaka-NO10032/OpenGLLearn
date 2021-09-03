//
//  ViewController.m
//  光照计算
//
//  Created by Misaka on 2020/5/22.
//  Copyright © 2020 Misaka. All rights reserved.
//

#import "ViewController.h"
#import "RenderView.h"

@interface ViewController ()

@end

@implementation ViewController


- (UIView *)view {
    return [[RenderView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


@end
