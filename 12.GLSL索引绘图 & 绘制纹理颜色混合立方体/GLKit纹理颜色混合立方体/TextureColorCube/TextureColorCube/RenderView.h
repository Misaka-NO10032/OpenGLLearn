//
//  RenderView.h
//  TextureColorCube
//
//  Created by Misaka on 2020/4/7.
//  Copyright © 2020 Misaka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RenderView : UIView

@property (nonatomic, assign) float xDegree;

@property (nonatomic, assign) float yDegree;

@property (nonatomic, assign) float zDegree;

- (void)render;

@end

NS_ASSUME_NONNULL_END
