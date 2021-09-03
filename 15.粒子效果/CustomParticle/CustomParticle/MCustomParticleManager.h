//
//  MCustomParticleManager.h
//  CustomParticle
//
//  Created by Misaka on 2020/6/17.
//  Copyright © 2020 Misaka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MCustomParticleManager : NSObject

/// 发射源位置
@property (nonatomic, assign) GLKVector3 position;
@property (nonatomic, assign) CGFloat positionXRange;
@property (nonatomic, assign) CGFloat positionYRange;
@property (nonatomic, assign) CGFloat positionZRange;
/// 初速度
@property (nonatomic, assign) GLKVector3 initialSpeed;
@property (nonatomic, assign) CGFloat initialSpeedXRange;
@property (nonatomic, assign) CGFloat initialSpeedYRange;
@property (nonatomic, assign) CGFloat initialSpeedZRange;
/// 加速度
@property (nonatomic, assign) GLKVector3 acceleration;
@property (nonatomic, assign) CGFloat accelerationXRange;
@property (nonatomic, assign) CGFloat accelerationYRange;
@property (nonatomic, assign) CGFloat accelerationZRange;
/// 是否作加速度归一化(可用于制作圆形粒子特效，此时上面设置的速度,仅支持x、y方向)
@property (nonatomic, assign) BOOL isNormalized;
/// 归一化后速度倍数
@property (nonatomic, assign) CGFloat normalizedInitialSpeed;
/// 归一化后加速度倍数(当设置本属性时，加速度相关数值无效)
@property (nonatomic, assign) float normalizedAcceleration;
/// 发射时间
@property (nonatomic, assign) GLfloat launchTime;
@property (nonatomic, assign) GLfloat launchTimeRange;
/// 持续时间
@property (nonatomic, assign) GLfloat duration;
@property (nonatomic, assign) GLfloat durationRange;
/// 渐消时间
@property (nonatomic, assign) CGFloat disappearDuration;
@property (nonatomic, assign) CGFloat disappearDurationRange;
/// 粒子大小
@property (nonatomic, assign) CGFloat size;
@property (nonatomic, assign) CGFloat sizeRange;
/// 单次发射粒子数目
@property (nonatomic, assign) NSInteger count;
/// 发射粒子间隔
@property (nonatomic, assign) CGFloat firingInterval;
/// 运行时间
@property (nonatomic, assign) CGFloat runTime;
/// 变换矩阵
@property (strong, nonatomic) GLKEffectPropertyTransform *transform;


/// 预加载纹理
- (void)setTexturesWithPathList:(NSArray <NSString *> *)pathList;
- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
