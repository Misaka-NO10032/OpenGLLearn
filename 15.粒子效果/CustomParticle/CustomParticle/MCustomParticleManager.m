//
//  MCustomParticleManager.m
//  CustomParticle
//
//  Created by Misaka on 2020/6/17.
//  Copyright © 2020 Misaka. All rights reserved.
//

#import "MCustomParticleManager.h"

typedef NS_ENUM(NSInteger,AttributeKey) {
    positionAttributeKey,///< 发射源位置
    initialSpeedAttributeKey,///< 初速度
    accelerationAttributeKey,///< 加速度
    textureIndexAttributeKey,///< 纹理索引
    launchTimeAttributeKey,///< 发射时间
    durationAttributeKey,///< 持续时间
    disappearDurationAttributeKey,///< 渐消时间
    sizeAttributeKey,///粒子大小
};

typedef NS_ENUM(NSInteger,UniformKey) {
    runTimeUniformKey,///< 运行时间
    mvpMatrixUniformKey,///< 变换矩阵
    samplerUniformKey,///< 纹理数组
};

typedef struct {
    /// 发射源位置
    GLKVector3 position;
    /// 初速度
    GLKVector3 initialSpeed;
    /// 加速度
    GLKVector3 acceleration;
    /// 纹理索引
    GLfloat textureIndex;
    /// 发射时间
    GLfloat launchTime;
    /// 持续时间
    GLfloat duration;
    /// 渐消时间
    GLfloat disappearDuration;
    /// 粒子大小
    GLfloat size;
}MCustomParticle;

@interface MCustomParticleManager ()
{
    ///纹理总数目
    int _textureCount;
    ///全部粒子属性数据
    NSMutableData *_particleAttributesData;
    /// 是否需要更新粒子属性数据
    BOOL _needUpdateParticleAttributesData;
    GLuint program;
    GLint uniforms[3];
    GLuint buffer;
}

@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation MCustomParticleManager

#pragma mark - func

- (instancetype)init {
    if (self = [super init]) {
        buffer = 0;
        _particleAttributesData = [[NSMutableData alloc] init];
        _transform = [[GLKEffectPropertyTransform alloc] init];
        _position = GLKVector3Make(0, 0, 0);
        _initialSpeed = GLKVector3Make(0, 0, 0);
        _acceleration = GLKVector3Make(0, 0, 0);
    }
    return self;
}

/// 预加载纹理
- (void)setTexturesWithPathList:(NSArray <NSString *> *)pathList {
    int index = 0;
    for (int i = 0; i < pathList.count; i ++) {
        NSString *path = pathList[i];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        CGImageRef imageRef = image.CGImage;
        if (!imageRef) {
            continue;
        }
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);
        GLbyte *imageData = calloc(width * height * 4, sizeof(GLbyte));
        /// 因为本次的粒子不区分上下，所以Context可以省略上下翻转的仿射变化
        CGContextRef contextRef = CGBitmapContextCreate(imageData, width, height, 8, width * 4, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
        CGRect rect = CGRectMake(0, 0, width, height);
        CGContextDrawImage(contextRef, rect, imageRef);
        CGContextRelease(contextRef);
        /// 把要配置的纹理设为活跃状态
        glActiveTexture(GL_TEXTURE0 + index);
        glBindTexture(GL_TEXTURE_2D, index);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
        /// 纹理数据载入后，可以释放自己开辟的内存了
        free(imageData);
        index ++;
    }
    _textureCount = index;
}

/// 添加一组粒子
- (void)addAGroupParticleToData {
    for (int i = 0; i < self.count; i ++) {
        [self addParticleToData];
    }
}

/// 添加一个粒子
- (void)addParticleToData {
    MCustomParticle newParticle = [self creatParticle];
    NSUInteger count = _particleAttributesData.length / sizeof(MCustomParticle);
    /// 是否有不用了的粒子可以替换
    BOOL canReplace = NO;
    for (int i = 0; i < count && !canReplace; i ++) {
        MCustomParticle *particleList = (MCustomParticle *)_particleAttributesData.mutableBytes;
        MCustomParticle particle = particleList[i];
        if (particle.launchTime + particle.duration < self.runTime) {
            /// 这个位置的粒子已经不再使用了，可以把新粒子放在这里了。这样复用可以节约存储空间
            particleList[i] = newParticle;
            canReplace = YES;
            break;
        }
    }
    if (!canReplace) {
        /// 需要添加一个新的粒子
        [_particleAttributesData appendBytes:&newParticle length:sizeof(MCustomParticle)];
    }
    _needUpdateParticleAttributesData = YES;
}

/// 创建一个粒子
- (MCustomParticle)creatParticle {
    MCustomParticle particle;
    particle.position.x = self.position.x + [self randomOffset:self.positionXRange];
    particle.position.y = self.position.y + [self randomOffset:self.positionYRange];
    particle.position.z = self.position.z + [self randomOffset:self.positionZRange];
    particle.initialSpeed.x = self.initialSpeed.x + [self randomOffset:self.initialSpeedXRange];
    particle.initialSpeed.y = self.initialSpeed.y + [self randomOffset:self.initialSpeedYRange];
    particle.initialSpeed.z = self.initialSpeed.z + [self randomOffset:self.initialSpeedZRange];
    particle.acceleration.x = self.acceleration.x + [self randomOffset:self.accelerationXRange];
    particle.acceleration.y = self.acceleration.y + [self randomOffset:self.accelerationYRange];
    particle.acceleration.z = self.acceleration.z + [self randomOffset:self.accelerationZRange];
    particle.textureIndex = arc4random()%_textureCount;
    particle.launchTime = self.launchTime + fabs([self randomOffset:self.launchTimeRange]) + self.runTime;
    particle.duration = self.duration + [self randomOffset:self.durationRange];
    particle.disappearDuration = self.disappearDuration + [self randomOffset:self.disappearDurationRange];
    if (particle.disappearDuration > particle.duration) {
        particle.disappearDuration = particle.duration;
    }
    particle.size = self.size + [self randomOffset:self.sizeRange];
    if (self.isNormalized) {
        float x = (arc4random()%100 - 50.0)/100.0;
        float y = (arc4random()%100 - 50.0)/100.0;
        GLKVector3 velocity = GLKVector3Normalize(GLKVector3Make(x,y,0.0f));
        particle.initialSpeed = GLKVector3MultiplyScalar(velocity, self.normalizedInitialSpeed);
        if (self.normalizedAcceleration != 0) {
            particle.acceleration = GLKVector3MultiplyScalar(velocity, self.normalizedAcceleration);
        }
    }
    return particle;
}

- (CGFloat)randomOffset:(CGFloat)range {
    return (arc4random()%100)/100.0 * range * 2 - range;
}


- (void)draw {
    /// 绘制禁用深度缓冲区写入，可以放置重叠的时候会看到透明的方形的渲染bug
    glDepthMask(GL_FALSE);
    NSUInteger count = _particleAttributesData.length / sizeof(MCustomParticle);
    glDrawArrays(GL_POINTS, 0, (GLsizei)count);
    glDepthMask(GL_TRUE);
}

- (BOOL)prepareDraw {
    if (program == 0) {
        BOOL link = [self linkProgram];
        if (!link) {
            return NO;
        }
    }

    glUseProgram(program);

    GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(self.transform.projectionMatrix,self.transform.modelviewMatrix);
    glUniformMatrix4fv(uniforms[mvpMatrixUniformKey], 1, GL_FALSE, modelViewProjectionMatrix.m);
    GLint sampler[_textureCount];
    for (int i = 0; i < _textureCount; i ++) {
        sampler[i] = i;
    }
    glUniform1iv(uniforms[samplerUniformKey], _textureCount, sampler);
    glUniform1f(uniforms[runTimeUniformKey], _runTime);
    if (_needUpdateParticleAttributesData) {
        if (buffer == 0 && _particleAttributesData.length > 0) {
            /// 创建缓冲区
            [self initArrayBuffer:&buffer dataSize:_particleAttributesData.length data:(GLvoid *)_particleAttributesData.bytes usage:GL_DYNAMIC_DRAW];
        }else {
            /// 更新缓冲区数据
            [self reInitArrayBuffer:&buffer dataSize:_particleAttributesData.length data:(GLvoid *)_particleAttributesData.bytes usage:GL_DYNAMIC_DRAW];
        }
        _needUpdateParticleAttributesData = NO;
    }
    [self setVertexAttribPointerIndx:positionAttributeKey size:3 type:GL_FLOAT normalized:GL_FALSE stride:sizeof(MCustomParticle) ptr:NULL + offsetof(MCustomParticle, position)];
    [self setVertexAttribPointerIndx:initialSpeedAttributeKey size:3 type:GL_FLOAT normalized:GL_FALSE stride:sizeof(MCustomParticle) ptr:NULL + offsetof(MCustomParticle, initialSpeed)];
    [self setVertexAttribPointerIndx:accelerationAttributeKey size:3 type:GL_FLOAT normalized:GL_FALSE stride:sizeof(MCustomParticle) ptr:NULL + offsetof(MCustomParticle, acceleration)];
    [self setVertexAttribPointerIndx:textureIndexAttributeKey size:1 type:GL_FLOAT normalized:GL_FALSE stride:sizeof(MCustomParticle) ptr:NULL + offsetof(MCustomParticle, textureIndex)];
    [self setVertexAttribPointerIndx:launchTimeAttributeKey size:1 type:GL_FLOAT normalized:GL_FALSE stride:sizeof(MCustomParticle) ptr:NULL + offsetof(MCustomParticle, launchTime)];
    [self setVertexAttribPointerIndx:durationAttributeKey size:1 type:GL_FLOAT normalized:GL_FALSE stride:sizeof(MCustomParticle) ptr:NULL + offsetof(MCustomParticle, duration)];
    [self setVertexAttribPointerIndx:disappearDurationAttributeKey size:1 type:GL_FLOAT normalized:GL_FALSE stride:sizeof(MCustomParticle) ptr:NULL + offsetof(MCustomParticle, disappearDuration)];
    [self setVertexAttribPointerIndx:sizeAttributeKey size:1 type:GL_FLOAT normalized:GL_FALSE stride:sizeof(MCustomParticle) ptr:NULL + offsetof(MCustomParticle, size)];
    return YES;
}

- (void)setVertexAttribPointerIndx:(GLuint)indx size:(GLint)size type:(GLenum)type normalized:(GLboolean)normalized stride:(GLsizei)stride ptr:(GLvoid *)ptr {
    glEnableVertexAttribArray(indx);
    glVertexAttribPointer(indx, size, type, normalized, stride, ptr);
}

- (void)initArrayBuffer:(GLuint *)buffer dataSize:(GLsizeiptr)dataSize data:(GLvoid *)data usage:(GLenum)usage {
    glGenBuffers(1, buffer);
    glBindBuffer(GL_ARRAY_BUFFER, *buffer);
    glBufferData(GL_ARRAY_BUFFER, dataSize, data, usage);
}

- (void)reInitArrayBuffer:(GLuint *)buffer dataSize:(GLsizeiptr)dataSize data:(GLvoid *)data usage:(GLenum)usage {
    glBindBuffer(GL_ARRAY_BUFFER, *buffer);
    glBufferData(GL_ARRAY_BUFFER, dataSize, data, usage);
}

- (BOOL)linkProgram {
    program = glCreateProgram();
    GLuint vShader, fShader;
    NSString *vPath = [[NSBundle mainBundle] pathForResource:@"MCustomParticleShader" ofType:@"vsh"];
    NSString *fPath = [[NSBundle mainBundle] pathForResource:@"MCustomParticleShader" ofType:@"fsh"];
    BOOL vCompile = [self compileShader:&vShader type:GL_VERTEX_SHADER file:vPath];
    if (!vCompile) {
        NSLog(@"vertex shader compile error");
        return NO;
    }
    BOOL fCompile = [self compileShader:&fShader type:GL_FRAGMENT_SHADER file:fPath];
    if (!fCompile) {
        NSLog(@"fragment shader compile error");
        return NO;
    }
    glAttachShader(program, vShader);
    glAttachShader(program, fShader);
    //绑定属性位置 这需要在链接之前完成.
    glBindAttribLocation(program, positionAttributeKey, "a_position");
    glBindAttribLocation(program, initialSpeedAttributeKey, "a_initialSpeed");
    glBindAttribLocation(program, accelerationAttributeKey, "a_acceleration");
    glBindAttribLocation(program, textureIndexAttributeKey, "a_textureIndex");
    glBindAttribLocation(program, launchTimeAttributeKey, "a_launchTime");
    glBindAttribLocation(program, durationAttributeKey, "a_duration");
    glBindAttribLocation(program, disappearDurationAttributeKey, "a_disappearDuration");
    glBindAttribLocation(program, sizeAttributeKey, "a_size");

    glLinkProgram(program);
    GLint logLength;
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0){
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        NSLog(@"program link error:\n%s", log);
        free(log);
        glDeleteShader(vShader);
        glDeleteShader(fShader);
        if (program) {
            glDeleteProgram(program);
            program = 0;
        }
        return NO;
    }
    uniforms[runTimeUniformKey] = glGetUniformLocation(program, "u_runTime");
    uniforms[mvpMatrixUniformKey] = glGetUniformLocation(program, "u_mvpMatrix");
    uniforms[samplerUniformKey] = glGetUniformLocation(program, "u_sampler");

    glDetachShader(program, vShader);
    glDeleteShader(vShader);
    glDetachShader(program, fShader);
    glDeleteShader(fShader);
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    GLint status;
    const GLchar *source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source){
        NSLog(@"shader 源码读取失败");
        return NO;
    }
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0){
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile error:\n%s", log);
        free(log);
        return NO;
    }
    return YES;
}



- (void)start {
    if (!self.timer) {
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
        dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, self.firingInterval * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(self.timer, ^{
            [self addAGroupParticleToData];
        });
        dispatch_resume(self.timer);
    }
    BOOL prepare = [self prepareDraw];
    if (prepare) {
        [self draw];
    }
}

- (void)stop {
    _particleAttributesData = [[NSMutableData alloc] init];
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
    if (program) {
        glDeleteProgram(program);
    }
    if (buffer) {
         glDeleteBuffers(1, &buffer);
    }
}

- (void)dealloc {
    [self stop];
}


@end
