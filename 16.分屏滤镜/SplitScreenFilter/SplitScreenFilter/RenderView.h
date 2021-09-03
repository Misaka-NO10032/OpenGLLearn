//
//  RenderView.h
//  SplitScreenFilter
//
//  Created by Misaka on 2020/7/2.
//  Copyright © 2020 Misaka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RenderView : UIView

- (void)setShader:(NSString *)shader image:(UIImage *)image;

- (void)freeMemory;


@end

NS_ASSUME_NONNULL_END
