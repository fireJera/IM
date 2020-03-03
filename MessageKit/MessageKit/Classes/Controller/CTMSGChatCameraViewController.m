//
//  CTMSGChatCameraViewController.m
//  ChatMessageKit
//
//  Created by Jeremy on 2019/4/9.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "CTMSGChatCameraViewController.h"
#import "UIColor+CTMSG_Hex.h"
#import "NSTimer+CTMSG_Block.h"
#import "UIColor+CTMSG_Hex.h"
#import "UIView+CTMSG_Cat.h"

#import "CTMSGUtilities.h"

#if __has_include (<GPUImage.h>)
#import <GPUImage.h>
#else
#import "GPUImage.h"
#endif

//https://blog.csdn.net/Philm_iOS/article/list/7? GPUImage 源码解读
//http://blog.leichunfeng.com/blog/2015/12/25/reactivecocoa-v2-dot-5-yuan-ma-jie-xi-zhi-jia-gou-zong-lan/ reactivecocoa
//https://juejin.im/post/5ab272e9518825558507720f reactivecocoa

static const int kCameraWidth = 540;
static const int kCameraHeight = 960;
static const int kRoundWidth = 80;
static const int kLittleRoundWidth = 60;
static const int kLeftInterval = 36;

//拍照按钮的中间
#define kRecordCenter CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height - kLeftInterval - (kRoundWidth / 2))

////录像存储路径
//#define kVideoPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"chatReocrd.mov"]
//
//#define kCompressVideoPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"chatReocrdCompress.mov"];

static const CGFloat SLIDER_X_BOUND = 30.0;
static const CGFloat SLIDER_Y_BOUND = 40.0;

@interface CTMSGBeautySlider () {
    CGRect _lastBounds;
}
@end

@implementation CTMSGBeautySlider

- (CGRect)trackRectForBounds:(CGRect)bounds
{
    return self.bounds;
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value;
{
    rect.origin.x = rect.origin.x;
    rect.size.width = rect.size.width;
    CGRect result = [super thumbRectForBounds:bounds trackRect:rect value:value];
    _lastBounds = result;
    return result;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView* result = [super hitTest:point withEvent:event];
    if (result != self) {
        if ((point.y >= -15) &&
            (point.y < (_lastBounds.size.height + SLIDER_Y_BOUND)) &&
            (point.x >= 0 && point.x < CGRectGetWidth(self.bounds))) {
            result = self;
        }
    }
    return result;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL result = [super pointInside:point withEvent:event];
    
    if (!result) {
        if ((point.x >= (_lastBounds.origin.x - SLIDER_X_BOUND)) && (point.x <= (_lastBounds.origin.x + _lastBounds.size.width + SLIDER_X_BOUND))
            && (point.y >= -SLIDER_Y_BOUND) && (point.y < (_lastBounds.size.height + SLIDER_Y_BOUND))) {
            result = YES;
        }
    }
    return result;
}
@end



/***********************
 ** CTMSGBeautyFilter **
 ************************/

@interface CTMSGBeautyFilter : GPUImageFilter

/** 美颜程度 */
@property (nonatomic, assign) CGFloat beautyLevel;
/** 美白程度 */
@property (nonatomic, assign) CGFloat brightLevel;
/** 色调强度 */
@property (nonatomic, assign) CGFloat toneLevel;

@end

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
static NSString *const kLFGPUImageBeautyFragmentShaderString = SHADER_STRING                                                (
                                                                                                                             varying highp vec2 textureCoordinate;
                                                                                                                             uniform sampler2D inputImageTexture;
                                                                                                                             uniform highp vec2 singleStepOffset;
                                                                                                                             uniform highp vec4 params;
                                                                                                                             uniform highp float brightness;
                                                                                                                             
                                                                                                                             const highp vec3 W = vec3(0.299, 0.587, 0.114);
                                                                                                                             const highp mat3 saturateMatrix = mat3(
                                                                                                                                                                    1.1102, -0.0598, -0.061,
                                                                                                                                                                    -0.0774, 1.0826, -0.1186,
                                                                                                                                                                    -0.0228, -0.0228, 1.1772);
                                                                                                                             highp vec2 blurCoordinates[24];
                                                                                                                             
                                                                                                                             highp float hardLight(highp float color) {
                                                                                                                                 if (color <= 0.5) color = color * color * 2.0;
                                                                                                                                 else color = 1.0 - ((1.0 - color)*(1.0 - color) * 2.0);
                                                                                                                                 return color;
                                                                                                                             }
                                                                                                                             
                                                                                                                             void main(){
                                                                                                                                 highp vec3 centralColor = texture2D(inputImageTexture, textureCoordinate).rgb;
                                                                                                                                 blurCoordinates[0] = textureCoordinate.xy + singleStepOffset * vec2(0.0, -10.0);
                                                                                                                                 blurCoordinates[1] = textureCoordinate.xy + singleStepOffset * vec2(0.0, 10.0);
                                                                                                                                 blurCoordinates[2] = textureCoordinate.xy + singleStepOffset * vec2(-10.0, 0.0);
                                                                                                                                 blurCoordinates[3] = textureCoordinate.xy + singleStepOffset * vec2(10.0, 0.0);
                                                                                                                                 blurCoordinates[4] = textureCoordinate.xy + singleStepOffset * vec2(5.0, -8.0);
                                                                                                                                 blurCoordinates[5] = textureCoordinate.xy + singleStepOffset * vec2(5.0, 8.0);
                                                                                                                                 blurCoordinates[6] = textureCoordinate.xy + singleStepOffset * vec2(-5.0, 8.0);
                                                                                                                                 blurCoordinates[7] = textureCoordinate.xy + singleStepOffset * vec2(-5.0, -8.0);
                                                                                                                                 blurCoordinates[8] = textureCoordinate.xy + singleStepOffset * vec2(8.0, -5.0);
                                                                                                                                 blurCoordinates[9] = textureCoordinate.xy + singleStepOffset * vec2(8.0, 5.0);
                                                                                                                                 blurCoordinates[10] = textureCoordinate.xy + singleStepOffset * vec2(-8.0, 5.0);
                                                                                                                                 blurCoordinates[11] = textureCoordinate.xy + singleStepOffset * vec2(-8.0, -5.0);
                                                                                                                                 blurCoordinates[12] = textureCoordinate.xy + singleStepOffset * vec2(0.0, -6.0);
                                                                                                                                 blurCoordinates[13] = textureCoordinate.xy + singleStepOffset * vec2(0.0, 6.0);
                                                                                                                                 blurCoordinates[14] = textureCoordinate.xy + singleStepOffset * vec2(6.0, 0.0);
                                                                                                                                 blurCoordinates[15] = textureCoordinate.xy + singleStepOffset * vec2(-6.0, 0.0);
                                                                                                                                 blurCoordinates[16] = textureCoordinate.xy + singleStepOffset * vec2(-4.0, -4.0);
                                                                                                                                 blurCoordinates[17] = textureCoordinate.xy + singleStepOffset * vec2(-4.0, 4.0);
                                                                                                                                 blurCoordinates[18] = textureCoordinate.xy + singleStepOffset * vec2(4.0, -4.0);
                                                                                                                                 blurCoordinates[19] = textureCoordinate.xy + singleStepOffset * vec2(4.0, 4.0);
                                                                                                                                 blurCoordinates[20] = textureCoordinate.xy + singleStepOffset * vec2(-2.0, -2.0);
                                                                                                                                 blurCoordinates[21] = textureCoordinate.xy + singleStepOffset * vec2(-2.0, 2.0);
                                                                                                                                 blurCoordinates[22] = textureCoordinate.xy + singleStepOffset * vec2(2.0, -2.0);
                                                                                                                                 blurCoordinates[23] = textureCoordinate.xy + singleStepOffset * vec2(2.0, 2.0);
                                                                                                                                 
                                                                                                                                 highp float sampleColor = centralColor.g * 22.0;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[0]).g;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[1]).g;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[2]).g;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[3]).g;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[4]).g;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[5]).g;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[6]).g;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[7]).g;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[8]).g;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[9]).g;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[10]).g;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[11]).g;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[12]).g * 2.0;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[13]).g * 2.0;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[14]).g * 2.0;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[15]).g * 2.0;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[16]).g * 2.0;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[17]).g * 2.0;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[18]).g * 2.0;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[19]).g * 2.0;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[20]).g * 3.0;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[21]).g * 3.0;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[22]).g * 3.0;
                                                                                                                                 sampleColor += texture2D(inputImageTexture, blurCoordinates[23]).g * 3.0;
                                                                                                                                 
                                                                                                                                 sampleColor = sampleColor / 62.0;
                                                                                                                                 
                                                                                                                                 highp float highPass = centralColor.g - sampleColor + 0.5;
                                                                                                                                 
                                                                                                                                 for (int i = 0; i < 5; i++) {
                                                                                                                                     highPass = hardLight(highPass);
                                                                                                                                 }
                                                                                                                                 highp float lumance = dot(centralColor, W);
                                                                                                                                 
                                                                                                                                 highp float alpha = pow(lumance, params.r);
                                                                                                                                 
                                                                                                                                 highp vec3 smoothColor = centralColor + (centralColor-vec3(highPass))*alpha*0.1;
                                                                                                                                 
                                                                                                                                 smoothColor.r = clamp(pow(smoothColor.r, params.g), 0.0, 1.0);
                                                                                                                                 smoothColor.g = clamp(pow(smoothColor.g, params.g), 0.0, 1.0);
                                                                                                                                 smoothColor.b = clamp(pow(smoothColor.b, params.g), 0.0, 1.0);
                                                                                                                                 
                                                                                                                                 highp vec3 lvse = vec3(1.0)-(vec3(1.0)-smoothColor)*(vec3(1.0)-centralColor);
                                                                                                                                 highp vec3 bianliang = max(smoothColor, centralColor);
                                                                                                                                 highp vec3 rouguang = 2.0*centralColor*smoothColor + centralColor*centralColor - 2.0*centralColor*centralColor*smoothColor;
                                                                                                                                 
                                                                                                                                 gl_FragColor = vec4(mix(centralColor, lvse, alpha), 1.0);
                                                                                                                                 gl_FragColor.rgb = mix(gl_FragColor.rgb, bianliang, alpha);
                                                                                                                                 gl_FragColor.rgb = mix(gl_FragColor.rgb, rouguang, params.b);
                                                                                                                                 
                                                                                                                                 highp vec3 satcolor = gl_FragColor.rgb * saturateMatrix;
                                                                                                                                 gl_FragColor.rgb = mix(gl_FragColor.rgb, satcolor, params.a);
                                                                                                                                 gl_FragColor.rgb = vec3(gl_FragColor.rgb + vec3(brightness));
                                                                                                                             }
                                                                                                                             
                                                                                                                             );
#else
static NSString *const kLFGPUImageBeautyFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform mediump vec2 singleStepOffset;
 uniform mediump vec4 params;
 uniform mediump float brightness;
 const mediump mat3 saturateMatrix = mat3(
                                          1.1102, -0.0598, -0.061,
                                          -0.0774, 1.0826, -0.1186,
                                          -0.0228, -0.0228, 1.1772);
 const mediump vec3 W = vec3(0.299, 0.587, 0.114);
 mediump vec2 blurCoordinates[24];
 
 mediump float hardLight(mediump float color){
     if (color <= 0.5)
         color = color * color * 2.0;
     else
         color = 1.0 - ((1.0 - color)*(1.0 - color) * 2.0);
     return color;
 }
 
 void main(){
     mediump vec3 centralColor = texture2D(inputImageTexture, textureCoordinate).rgb;
     blurCoordinates[0] = textureCoordinate.xy + singleStepOffset * vec2(0.0, -10.0);
     blurCoordinates[1] = textureCoordinate.xy + singleStepOffset * vec2(0.0, 10.0);
     blurCoordinates[2] = textureCoordinate.xy + singleStepOffset * vec2(-10.0, 0.0);
     blurCoordinates[3] = textureCoordinate.xy + singleStepOffset * vec2(10.0, 0.0);
     blurCoordinates[4] = textureCoordinate.xy + singleStepOffset * vec2(5.0, -8.0);
     blurCoordinates[5] = textureCoordinate.xy + singleStepOffset * vec2(5.0, 8.0);
     blurCoordinates[6] = textureCoordinate.xy + singleStepOffset * vec2(-5.0, 8.0);
     blurCoordinates[7] = textureCoordinate.xy + singleStepOffset * vec2(-5.0, -8.0);
     blurCoordinates[8] = textureCoordinate.xy + singleStepOffset * vec2(8.0, -5.0);
     blurCoordinates[9] = textureCoordinate.xy + singleStepOffset * vec2(8.0, 5.0);
     blurCoordinates[10] = textureCoordinate.xy + singleStepOffset * vec2(-8.0, 5.0);
     blurCoordinates[11] = textureCoordinate.xy + singleStepOffset * vec2(-8.0, -5.0);
     blurCoordinates[12] = textureCoordinate.xy + singleStepOffset * vec2(0.0, -6.0);
     blurCoordinates[13] = textureCoordinate.xy + singleStepOffset * vec2(0.0, 6.0);
     blurCoordinates[14] = textureCoordinate.xy + singleStepOffset * vec2(6.0, 0.0);
     blurCoordinates[15] = textureCoordinate.xy + singleStepOffset * vec2(-6.0, 0.0);
     blurCoordinates[16] = textureCoordinate.xy + singleStepOffset * vec2(-4.0, -4.0);
     blurCoordinates[17] = textureCoordinate.xy + singleStepOffset * vec2(-4.0, 4.0);
     blurCoordinates[18] = textureCoordinate.xy + singleStepOffset * vec2(4.0, -4.0);
     blurCoordinates[19] = textureCoordinate.xy + singleStepOffset * vec2(4.0, 4.0);
     blurCoordinates[20] = textureCoordinate.xy + singleStepOffset * vec2(-2.0, -2.0);
     blurCoordinates[21] = textureCoordinate.xy + singleStepOffset * vec2(-2.0, 2.0);
     blurCoordinates[22] = textureCoordinate.xy + singleStepOffset * vec2(2.0, -2.0);
     blurCoordinates[23] = textureCoordinate.xy + singleStepOffset * vec2(2.0, 2.0);
     
     mediump float sampleColor = centralColor.g * 22.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[0]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[1]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[2]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[3]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[4]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[5]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[6]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[7]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[8]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[9]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[10]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[11]).g;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[12]).g * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[13]).g * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[14]).g * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[15]).g * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[16]).g * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[17]).g * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[18]).g * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[19]).g * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[20]).g * 3.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[21]).g * 3.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[22]).g * 3.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[23]).g * 3.0;
     
     sampleColor = sampleColor / 62.0;
     
     mediump float highPass = centralColor.g - sampleColor + 0.5;
     
     for (int i = 0; i < 5; i++) {
         highPass = hardLight(highPass);
     }
     mediump float luminance = dot(centralColor, W);
     
     mediump float alpha = pow(luminance, params);
     
     mediump vec3 smoothColor = centralColor + (centralColor-vec3(highPass))*alpha*0.1;
     
     smoothColor.r = clamp(pow(smoothColor.r, params.g), 0.0, 1.0);
     smoothColor.g = clamp(pow(smoothColor.g, params.g), 0.0, 1.0);
     smoothColor.b = clamp(pow(smoothColor.b, params.g), 0.0, 1.0);
     
     mediump vec3 lvse = vec3(1.0)-(vec3(1.0)-smoothColor)*(vec3(1.0)-centralColor);
     mediump vec3 bianliang = max(smoothColor, centralColor);
     mediump vec3 rouguang = 2.0*centralColor*smoothColor + centralColor*centralColor - 2.0*centralColor*centralColor*smoothColor;
     
     gl_FragColor = vec4(mix(centralColor, lvse, alpha), 1.0);
     gl_FragColor.rgb = mix(gl_FragColor.rgb, bianliang, alpha);
     gl_FragColor.rgb = mix(gl_FragColor.rgb, rouguang, params.b);
     
     mediump vec3 satcolor = gl_FragColor.rgb * saturateMatrix;
     gl_FragColor.rgb = mix(gl_FragColor.rgb, satcolor, params.a);
     gl_FragColor.rgb = vec3(gl_FragColor.rgb + vec3(brightness));
 }
 
 );
#endif

@implementation CTMSGBeautyFilter

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex {
    [super setInputSize:newSize atIndex:textureIndex];
    inputTextureSize = newSize;
    CGPoint offset = CGPointMake(2.0f / inputTextureSize.width, 2.0 / inputTextureSize.height);
    [self setPoint:offset forUniformName:@"singleStepOffset"];
}

- (void)setParams:(CGFloat)beauty tone:(CGFloat)tone {
    GPUVector4 fBeautyParam;
    fBeautyParam.four = 0.1 + 0.3 * tone;
    fBeautyParam.three = 0.1 + 0.3 * tone;
    fBeautyParam.two = 1.0 - 0.3 * beauty;
    fBeautyParam.one = 1.0 - 0.6 * beauty;
    [self setFloatVec4:fBeautyParam forUniform:@"params"];
}

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kLFGPUImageBeautyFragmentShaderString])) {
        return nil;
    }
    _toneLevel = 0.47;
    _brightLevel = 0.34;
    _beautyLevel = 0.42;
    [self setParams:_beautyLevel tone:_toneLevel];
    [self setBrightLevel:_brightLevel];
    return self;
}

- (void)setBeautyLevel:(CGFloat)beautyLevel {
    _beautyLevel = beautyLevel;
    [self setParams:_beautyLevel tone:_toneLevel];
}

- (void)setBrightLevel:(CGFloat)brightLevel {
    _brightLevel = brightLevel;
    [self setFloat:0.6 * (-0.5 + brightLevel) forUniformName:@"brightness"];
}

@end





/**************************
 ** MessageKitCameraView **
 **************************/

@interface MessageKitCameraView () <CAAnimationDelegate> {
    CGFloat _allTime;
    AVPlayerLayer *_avplayer;
    
    struct {
        unsigned int recordTime : 1;
        unsigned int detectFace : 1;
    } _delegateFlags;
}

@property (nonatomic, strong) CADisplayLink * timer;
@property (nonatomic, strong) AVCaptureMetadataOutput * metaDataOutput;
@property (nonatomic, assign, readwrite) BOOL recording;

@end

@implementation MessageKitCameraView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.cameraView.frame = self.bounds;
}

#pragma mark - AnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self performSelector:@selector(focusLayerNormal) withObject:self afterDelay:1.0f];
}

#pragma mark 聚焦
- (void)focusTap:(UITapGestureRecognizer *)tap {
    self.cameraView.userInteractionEnabled = NO;
    CGPoint touchPoint = [tap locationInView:tap.view];
    if (touchPoint.y > CTMSGSCREENHEIGHT) {
        return;
    }
    [self layerAnimationWithPoint:touchPoint];
    touchPoint = CGPointMake(touchPoint.x / tap.view.bounds.size.width, touchPoint.y / tap.view.bounds.size.height);
    if ([self.videoCamera.inputCamera isFocusPointOfInterestSupported] && [self.videoCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([self.videoCamera.inputCamera lockForConfiguration:&error]) {
            [self.videoCamera.inputCamera setFocusPointOfInterest:touchPoint];
            [self.videoCamera.inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
            
            if([self.videoCamera.inputCamera isExposurePointOfInterestSupported] && [self.videoCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            {
                [self.videoCamera.inputCamera setExposurePointOfInterest:touchPoint];
                [self.videoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            [self.videoCamera.inputCamera unlockForConfiguration];
        } else {
            NSLog(@"ERROR = %@", error);
        }
    }
    
}

#pragma mark - Animation
- (void)p_ctmsg_animationCamera {
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = .5f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"oglFlip";
    animation.subtype = kCATransitionFromRight;
    [self.cameraView.layer addAnimation:animation forKey:nil];
}

- (void)focusLayerNormal {
    self.cameraView.userInteractionEnabled = YES;
    _focusLayer.hidden = YES;
}

- (void)layerAnimationWithPoint:(CGPoint)point {
    [_focusLayer removeAllAnimations];
    if (_focusLayer) {
        CALayer *focusLayer = _focusLayer;
        focusLayer.hidden = NO;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [focusLayer setPosition:point];
        focusLayer.transform = CATransform3DMakeScale(2.0f,2.0f,1.0f);
        [CATransaction commit];
        
        CABasicAnimation *animation = [ CABasicAnimation animationWithKeyPath: @"transform" ];
        animation.toValue = [ NSValue valueWithCATransform3D: CATransform3DMakeScale(1.0f,1.0f,1.0f)];
        animation.delegate = self;
        animation.duration = 0.3f;
        animation.repeatCount = 1;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [focusLayer addAnimation: animation forKey:@"animation"];
    }
}

#pragma mark - touch event

- (void)p_ctmsg_beautyValueChanged:(UISlider *)slider {
    _beautyValue = slider.value / 100;
    self.leveBeautyFilter.beautyLevel = _beautyValue;
    if (_beautyValue == 0) {
        [self.videoCamera removeAllTargets];
        [self.videoCamera addTarget:self.normalFilter];
        [self.normalFilter addTarget:self.cameraView];
    } else {
        [self.videoCamera removeAllTargets];
        [self.videoCamera addTarget:self.leveBeautyFilter];
        [self.leveBeautyFilter addTarget:self.cameraView];
    }
}

#pragma mark - notifcation

- (void)p_ctmsg_applicationWillResignActive:(NSNotification *)notification {
    if (_avplayer) {
        [_avplayer.player pause];
    }
}

- (void)p_ctmsg_applicationDidBecomeActive:(NSNotification *)notification {
    if (_avplayer) {
        [_avplayer.player play];
    }
}

//播放结束
- (void)p_ctmsg_moviePlayDidEnd:(NSNotification *)notification {
    [_avplayer.player seekToTime:kCMTimeZero];
    [_avplayer.player play];
}

#pragma mark - public method
- (void)ctmsg_switchCamera {
    [_videoCamera pauseCameraCapture];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.videoCamera rotateCamera];
        [self.videoCamera resumeCameraCapture];
    });
    [self performSelector:@selector(p_ctmsg_animationCamera) withObject:self afterDelay:0.2f];
}

- (void)ctmsg_recapture {
    [_videoCamera removeAllTargets];
    id<GPUImageInput> target = (_addBeautyFilter && _beautyValue > 0) ? self.leveBeautyFilter : self.normalFilter;
    
    [_videoCamera addTarget:target];
    [(GPUImageOutput *)target addTarget:self.cameraView];
    
    [self p_ctmsg_createNewWritter];
    [self ctmsg_showCameraView];
    [_videoCamera resumeCameraCapture];
    _avplayer = nil;
    [[NSFileManager defaultManager] removeItemAtPath:_moviePath error:nil];
}

- (void)ctmsg_startRecordVideo {
    _recording = YES;
    unlink([self.moviePath UTF8String]);
    id<GPUImageInput> target = (_addBeautyFilter && _beautyValue > 0) ? self.leveBeautyFilter : self.normalFilter;
    [(GPUImageOutput *)target addTarget:self.movieWriter];
    [self.movieWriter startRecording];
    
    __weak typeof(self) weakSelf = self;
    _timer = [CADisplayLink displayLinkWithExecuteBlock:^(CADisplayLink *displayLink) {
        [weakSelf p_ctmsg_timerupdating];
    }];
    _timer.frameInterval = 3;
    [_timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _allTime = 0;
}

- (void)ctmsg_endReocrd:(void (^)(id _Nonnull, NSError * _Nullable))block {
    if (!_timer) {
        return;
    }
    
    [_timer invalidate];
    _timer = nil;
    
    if (_allTime < 0.3) {
        [self p_ctmsg_finishTakePhoto:block];
        return;
    }
    
    [self p_ctmsg_hideSlider];
    id<GPUImageInput> target = (_addBeautyFilter && _beautyValue > 0) ? self.leveBeautyFilter : self.normalFilter;
    [(GPUImageOutput *)target removeTarget:self.movieWriter];
    
    if (_allTime < _minReocrdTime) {
//        NSString * msg = [NSString stringWithFormat:@"视频最短为%ld秒", _minReocrdTime];
//        [self showTextHUD:msg];
        [self.movieWriter finishRecording];
        [self p_ctmsg_createNewWritter];
        [self ctmsg_recapture];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.movieWriter finishRecordingWithCompletionHandler:^{
        [weakSelf.videoCamera pauseCameraCapture];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf->_recording = NO;
        if (strongSelf->_allTime > 0.5) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf ctmsg_play:weakSelf.moviePath];
                if (block) {
                    block(weakSelf.moviePath, nil);
                }
            });
        }
    }];
}

- (void)ctmsg_takePhoto:(void (^)(UIImage * _Nonnull, NSError * _Nonnull))block {
    _recording = YES;
    unlink([self.moviePath UTF8String]);
    GPUImageOutput * target = (_addBeautyFilter && _beautyValue > 0) ? self.leveBeautyFilter : self.normalFilter;
    [target addTarget:self.movieWriter];
    
    [self.movieWriter startRecording];
    [self p_ctmsg_finishTakePhoto:block];
}

- (void)ctmsg_endRecordVideo:(void (^)(NSString * _Nonnull))block {
    if (!_timer) {
        return;
    }
    
    [_timer invalidate];
    _timer = nil;
    
    [self p_ctmsg_hideSlider];
    id<GPUImageInput> target = (_addBeautyFilter && _beautyValue > 0) ? self.leveBeautyFilter : self.normalFilter;
    [(GPUImageOutput *)target removeTarget:self.movieWriter];
    
    if (_allTime < _minReocrdTime) {
        NSString * msg = [NSString stringWithFormat:@"视频最短为%d秒", (int)(_minReocrdTime)];
        [self showLoadingHUDText:msg];
        [self.movieWriter finishRecording];
        [self ctmsg_recapture];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.movieWriter finishRecordingWithCompletionHandler:^{
        [weakSelf.videoCamera pauseCameraCapture];
        weakSelf.movieWriter = nil;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf->_recording = NO;
        if (strongSelf->_allTime > 0.5) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf ctmsg_play:self.moviePath];
            });
            if (block) {
                block(weakSelf.moviePath);
            }
        }
    }];
}

- (void)ctmsg_play:(NSString *)path {
    _avplayer = [AVPlayerLayer playerLayerWithPlayer:[AVPlayer playerWithURL:[NSURL fileURLWithPath:path]]];
    _avplayer.frame = self.bounds;
    [self.layer insertSublayer:_avplayer above:self.cameraView.layer];
    [_avplayer.player play];
    _cameraView.hidden = YES;
}

- (void)ctmsg_pausePlay {
    [_avplayer.player pause];
}

- (void)ctmsg_dismiss {
    [_focusLayer removeAllAnimations];
    [self.videoCamera stopCameraCapture];
}

- (void)ctmsg_initCapture {
    [_videoCamera startCameraCapture];
}

#pragma mark - private method

- (void)p_ctmsg_finishTakePhoto:(void (^)(UIImage * _Nonnull, NSError * _Nonnull))block {
    GPUImageOutput * target = (_addBeautyFilter && _beautyValue > 0) ? self.leveBeautyFilter : self.normalFilter;
    [target removeTarget:self.movieWriter];
    
    [self.movieWriter finishRecording];
    _recording = NO;
    __weak typeof(self) weakSelf = self;
    [self.videoCamera capturePhotoAsImageProcessedUpToFilter:self.leveBeautyFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(processedImage, error);
            }
            [weakSelf p_ctmsg_showPhoto:processedImage];
        });
    }];
}

- (void)p_ctmsg_timerupdating {
    _allTime += 0.05;
    //    NSLog(@"_alltime:-------%f", _allTime);
    if (_delegateFlags.recordTime) {
        [_delegate ctmsg_cameraViewRecordTime:(_allTime)];
    }
}

- (void)ctmsg_showCameraView {
    _cameraView.hidden = NO;
    [_imageView removeFromSuperview];
    _beautySlider.hidden = !_showBeautySlider;
    
    [_avplayer.player pause];
    [_avplayer removeFromSuperlayer];
}

- (void)p_ctmsg_showPhoto:(UIImage *)image {
    self.imageView.image = image;
    [self addSubview:_imageView];
}

- (void)p_ctmsg_hideSlider {
    _beautySlider.hidden = YES;
}

- (void)setDelegate:(id<MessageKitCameraViewDelegate>)delegate {
    _delegate = delegate;
    _delegateFlags.recordTime = [_delegate respondsToSelector:@selector(ctmsg_cameraViewRecordTime:)];
    _delegateFlags.detectFace = [_delegate respondsToSelector:@selector(ctmsg_cameraViewDetectFaceResult:)];
}

#pragma mark - getter

- (NSString *)moviePath {
    if (!_moviePath) {
        float nowTime = [[NSDate date] timeIntervalSince1970] * 1000;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString * directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString * parentPath = [directory stringByAppendingPathComponent:@"MessageKit"];
        parentPath = [parentPath stringByAppendingPathComponent:@"sendMessageCache"];
        NSString * filePath = [NSString stringWithFormat:@"%@/%.0f_video.mov", parentPath, nowTime];
        BOOL isDir;
        if (![fileManager fileExistsAtPath:parentPath isDirectory:&isDir]) {
            NSLog(@"%@",parentPath);
            [fileManager createDirectoryAtPath:parentPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _moviePath = filePath;
    }
    return _moviePath;
}

//- (NSString *)compressdMoviePath {
//    if (!_compressdMoviePath) {
//        _compressdMoviePath = kCompressVideoPath;
//    }
//    return _compressdMoviePath;
//}

- (float)recordDuration {
    return _allTime;
}

#pragma mark - Lazy Property

- (GPUImageFilterGroup *)normalFilter {
    if (!_normalFilter) {
        GPUImageFilter *filter = [[GPUImageFilter alloc] init];
        _normalFilter = [[GPUImageFilterGroup alloc] init];
        [(GPUImageFilterGroup *) _normalFilter setInitialFilters:[NSArray arrayWithObject:filter]];
        [(GPUImageFilterGroup *) _normalFilter setTerminalFilter:filter];
    }
    return _normalFilter;
}

- (CTMSGBeautyFilter *)leveBeautyFilter {
    if (!_leveBeautyFilter) {
        _leveBeautyFilter = [[CTMSGBeautyFilter alloc] init];
        _leveBeautyFilter.beautyLevel = _beautyValue;
    }
    return _leveBeautyFilter;
}

- (NSDictionary *)videoSettings {
    if (!_videoSettings) {
        _videoSettings = @{
                           AVVideoCodecKey: AVVideoCodecH264,
                           AVVideoWidthKey: @(kCameraWidth),
                           AVVideoHeightKey: @(kCameraHeight),
                           };
    }
    return _videoSettings;
}

#pragma mark - lazy uiview property

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}

- (CTMSGBeautySlider *)beautySlider {
    if (!_beautySlider) {
        _beautySlider = ({
            CTMSGBeautySlider * slider = [[CTMSGBeautySlider alloc] init];
            slider.minimumValue = 0;
            slider.maximumValue = 100;
            [slider setThumbImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_aremac_3"] forState:UIControlStateNormal];
            [slider addTarget:self action:@selector(p_ctmsg_beautyValueChanged:) forControlEvents:UIControlEventValueChanged];
            slider.frame = CGRectMake(2 , CTMSGSCREENHEIGHT / 2, CTMSGSCREENWIDTH - 6, 8);
            [slider setMinimumTrackImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_aremac_1"] forState:UIControlStateNormal];
            [slider setMaximumTrackImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_aremac_2"] forState:UIControlStateNormal];
            slider.value = 50;
            slider.frame = CGRectMake(CTMSGSCREENWIDTH / 2 - 25 , CTMSGSCREENHEIGHT / 2, CTMSGSCREENWIDTH, 8);
            slider.transform = CGAffineTransformMakeRotation(-M_PI_2);
            [self addSubview:slider];
            slider;
        });
    }
    return _beautySlider;
}

- (CALayer *)focusLayer {
    if (!_focusLayer) {
        UIImage *focusImage = [CTMSGUtilities imageForNameInBundle:@"ctmsg_aremac_7"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, focusImage.size.width, focusImage.size.height)];
        imageView.image = focusImage;
        _focusLayer = imageView.layer;
        _focusLayer.hidden = YES;
    }
    return _focusLayer;
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (void)p_commonInit {
    self.backgroundColor = [UIColor blackColor];
    _addBeautyFilter = YES;
    _showBeautySlider = NO;
    _cameraPosition = AVCaptureDevicePositionFront;
    _outputImageOrientation = UIInterfaceOrientationPortrait;
    _beautyValue = 0.6;
    _allTime = 0;
    //    _maxReocrdTime = 10;
    //    _minReocrdTime = 3;
    [self p_ctmsg_setupUI];
}

- (void)p_ctmsg_setupUI {
    _cameraView = ({
        GPUImageView * g = [[GPUImageView alloc] init];
        [g.layer addSublayer:self.focusLayer];
        [g addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusTap:)]];
        [g setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
        [self addSubview:g];
        g;
    });
    
    _videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:_cameraPosition];
    _videoCamera.outputImageOrientation = _outputImageOrientation;
    _videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    [self ctmsg_recapture];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        [_videoCamera startCameraCapture];
    });
}

- (void)p_ctmsg_setupNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(p_ctmsg_moviePlayDidEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(p_ctmsg_applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(p_ctmsg_applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)p_ctmsg_createNewWritter {
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:[NSURL fileURLWithPath:self.moviePath]
                                                            size:CGSizeMake(kCameraWidth, kCameraHeight)
                                                        fileType:AVFileTypeQuickTimeMovie
                                                  outputSettings:self.videoSettings];
    _movieWriter.hasAudioTrack = YES;
    _movieWriter.shouldPassthroughAudio = YES;
    /// 如果不加上这一句，会出现第一帧闪现黑屏
    [_videoCamera addAudioInputsAndOutputs];
    _videoCamera.audioEncodingTarget = _movieWriter;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    NSLog(@"🤩🤩🤩CTMSGCameraView deallc🤩🤩🤩");
}

@end




@interface CTMSGChatCameraViewController () <CAAnimationDelegate, MessageKitCameraViewDelegate> {
    UIImage *_tempImg;
}

//******** UIKit Property *************
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *cameraSwitch;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *recaptureButton;
@property (nonatomic, strong) UIButton *commitButton;

//******** Animation Property **********
@property (nonatomic, strong) CAShapeLayer * progressLayer;
@property (nonatomic, strong) UIView * roundFace;
@property (nonatomic, strong) UIView * littleRoundFace;

@property (nonatomic, copy) NSString * videoPath;

@end

@implementation CTMSGChatCameraViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    _maxTime = 10;
    _minTime = 3;
    [self p_ctmsg_setupUI];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.cameraView.frame = self.view.bounds;
    
    self.recordButton.bounds = CGRectMake(0, 0, kRoundWidth, kRoundWidth);
    self.recordButton.center = kRecordCenter;
    
    const CGFloat width = 48;
    self.backButton.frame = CGRectMake(0, 0, width, width);
    self.backButton.center = CGPointMake(kLeftInterval + width / 2, kRecordCenter.y);
    
    _cameraSwitch.frame = CGRectMake(0, 0, width, width);
    _cameraSwitch.center = CGPointMake(self.view.frame.size.width - width / 2 - kLeftInterval, kRecordCenter.y);
}

#pragma mark - Private Method

- (void)p_ctmsg_setupUI {
    self.cameraView = ({
        MessageKitCameraView * cameraView = [[MessageKitCameraView alloc] init];
        cameraView.delegate = self;
        [self.view addSubview:cameraView];
        cameraView;
    });
    
    self.backButton = ({
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        [b setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_camera_2"] forState:UIControlStateNormal];
        [b addTarget:self action:@selector(p_ctmsg_cancelRecord:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:b];
        b;
    });
    
    _roundFace = ({
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(kRecordCenter.x - (kRoundWidth / 2), kRecordCenter.y - (kRoundWidth / 2), kRoundWidth, kRoundWidth)];
        view.backgroundColor = [UIColor ctmsg_colorD9D9D9];
        view.layer.cornerRadius = kRoundWidth / 2;
        [self.view addSubview:view];
        view;
    });
    
    _littleRoundFace = ({
            UIView * view = [[UIView alloc] initWithFrame:CGRectMake(kRecordCenter.x - (kLittleRoundWidth / 2), kRecordCenter.y - (kLittleRoundWidth / 2), kLittleRoundWidth, kLittleRoundWidth)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = kLittleRoundWidth / 2;
        [self.view addSubview:view];
        view;
    });
    
    _cameraSwitch = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_camera_1"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(p_ctmsg_turnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        button;
    });
    
    self.recordButton = ({
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:b];
        b;
    });
    [_recordButton addTarget:self action:@selector(p_ctmsg_beginAllTypeRecord:) forControlEvents:UIControlEventTouchDown];
//    [_recordButton addTarget:self action:@selector(p_ctmsg_endAllTypeRecord:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];

    _cameraView.addBeautyFilter = YES;
}

- (void)p_ctmsg_showCameraView {
    [self p_ctmsg_showInitView];
    
    CGFloat width = kRoundWidth;
    _roundFace.frame = CGRectMake(kRecordCenter.x - (width / 2), kRecordCenter.y - (width / 2), width, width);
    _roundFace.layer.cornerRadius = width / 2;
    width = kLittleRoundWidth;
    _littleRoundFace.frame = CGRectMake(kRecordCenter.x - (width / 2), kRecordCenter.y - (width / 2), width, width);
    _littleRoundFace.layer.cornerRadius = width / 2;
}

- (void)p_ctmsg_showPhoto {
    [self p_ctmsg_hideInitView];
    
    [self.recaptureButton removeFromSuperview];
    [self.commitButton removeFromSuperview];
    [self.view addSubview:_recaptureButton];
    [self.view addSubview:_commitButton];
}

- (void)p_ctmsg_showPlayer {
    [self p_ctmsg_hideInitView];
    
    [self.recaptureButton removeFromSuperview];
    [self.commitButton removeFromSuperview];
    [self.view addSubview:_recaptureButton];
    [self.view addSubview:_commitButton];
}

- (void)p_ctmsg_hideInitView {
    _recordButton.enabled = NO;
    _recordButton.hidden = YES;
    _roundFace.hidden = YES;
    _littleRoundFace.hidden = YES;
    _backButton.hidden = YES;
    _cameraSwitch.hidden = YES;
    [_progressLayer removeFromSuperlayer];
    _progressLayer.path = nil;
}

- (void)p_ctmsg_showInitView {
    _recordButton.enabled = YES;
    _recordButton.hidden = NO;
    _roundFace.hidden = NO;
    _littleRoundFace.hidden = NO;
    _backButton.hidden = NO;
    _cameraSwitch.hidden = NO;
    [self.recaptureButton removeFromSuperview];
    [self.commitButton removeFromSuperview];
}

#pragma mark - Logic Method

- (void)p_ctmsg_beginAllTypeRecord:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [_cameraView ctmsg_takePhoto:^(UIImage * _Nonnull image, NSError * _Nonnull error) {
        [weakSelf p_ctmsg_finishTakePhotoWithImage:image];
    }];
//    [self p_ctmsg_beginRecord:sender];
}

//- (void)p_ctmsg_endAllTypeRecord:(UIButton *)sender {
//    [_cameraView ctmsg_endReocrd:^(id  _Nonnull result, NSError * _Nullable error) {
//        if ([result isKindOfClass:UIImage.class]) {
//            [self p_ctmsg_finishTakePhotoWithImage:(UIImage *)result];
//        } else if ([result isKindOfClass:NSString.class]) {
//            [self p_ctmsg_showPlayer];
//        }
//    }];
//}

- (void)p_ctmsg_takePhoto:(UIButton *)sender {
    sender.enabled = NO;
//    [UIView animateWithDuration:0.4 animations:^{
//        CGFloat width = kRoundWidth + 20;
//        _roundFace.frame = CGRectMake(kRecordCenter.x - (width / 2), kRecordCenter.y - (width / 2), width, width);
//        _roundFace.layer.cornerRadius = width / 2;
//        width = kLittleRoundWidth - 20;
//        _littleRoundFace.frame = CGRectMake(kRecordCenter.x - (width / 2), kRecordCenter.y - (width / 2), width, width);
//        _littleRoundFace.layer.cornerRadius = width / 2;
//    }];
    
    sender.selected = YES;
    __weak typeof(self) weakSelf = self;
    [_cameraView ctmsg_takePhoto:^(UIImage * _Nonnull image, NSError * _Nonnull error) {
        [weakSelf p_ctmsg_finishTakePhotoWithImage:image];
    }];
}

- (void)p_ctmsg_finishTakePhotoWithImage:(UIImage *)image {
    _tempImg = image;
//    if (_dataSource.userEdit) {
//        [_cameraView ctmsg_recapture];
//        [self p_ctmsg_pushEdit:image];
//    } else {
        [self p_ctmsg_showPhoto];
//    }
}

- (void)p_ctmsg_beginRecord:(UIButton *)sender {
    [UIView animateWithDuration:0.4 animations:^{
        CGFloat width = kRoundWidth + 20;
        _roundFace.frame = CGRectMake(kRecordCenter.x - (width / 2), kRecordCenter.y - (width / 2), width, width);
        _roundFace.layer.cornerRadius = width / 2;
        width = kLittleRoundWidth - 20;
        _littleRoundFace.frame = CGRectMake(kRecordCenter.x - (width / 2), kRecordCenter.y - (width / 2), width, width);
        _littleRoundFace.layer.cornerRadius = width / 2;
    }];
    
    [self.view.layer addSublayer:self.progressLayer];
    sender.selected = YES;
    [_cameraView ctmsg_startRecordVideo];
}

- (void)p_ctmsg_endRecord:(UIButton *)sender {
    sender.selected = NO;
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1.5 options:UIViewAnimationOptionTransitionCurlUp animations:^{
        self.recaptureButton.alpha = 1.0;
        self.commitButton.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    if (_cameraView.recordDuration < _minTime) {
//        NSString * msg = [NSString stringWithFormat:@"视频最短为%d秒", (int)_minTime];
//        [self.view showTextHUD:msg];
        [_cameraView ctmsg_recapture];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [_cameraView ctmsg_endRecordVideo:^(NSString * _Nonnull videoPath) {
        [weakSelf p_ctmsg_showPlayer];
    }];
}

- (void)p_ctmsg_cancelRecord:(UIButton *)sender {
//    [_focusLayer removeAllAnimations];
    //    [self.videoCamera stopCameraCapture];
    [self dismissViewControllerAnimated:true completion:nil];
    if ([_delegate respondsToSelector:@selector(ctmsg_cancelCamera:)]) {
        [_delegate ctmsg_cancelCamera:self];
    }
}

#pragma mark - MessageKitCameraViewDelegate

- (void)ctmsg_cameraViewRecordTime:(float)time {
    [self updateProgress:time / _maxTime playing:NO];
}

- (void)back:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - AnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self performSelector:@selector(focusLayerNormal) withObject:self afterDelay:1.0f];
}

#pragma mark - User Action

- (void)p_ctmsg_commitAction:(UIButton *)sender {
    if (_tempImg) {
        sender.enabled = NO;
        if ([_delegate respondsToSelector:@selector(ctmsg_cameraPhotoTaked:image:)]) {
            [_delegate ctmsg_cameraPhotoTaked:self image:_tempImg];
        }
    } else {
        [_cameraView ctmsg_pausePlay];
        NSString * videoPath = _cameraView.moviePath;
        if ([_delegate respondsToSelector:@selector(ctmsg_cameraVideoTaked:videoPath:)]) {
            [_delegate ctmsg_cameraVideoTaked:self videoPath:videoPath];
        }
    }
}

- (void)p_ctmsg_turnAction:(id)sender {
    [_cameraView ctmsg_switchCamera];
}

//- (void)p_ctmsg_pushEdit:(UIImage *)image {
//    INTCTClipImageViewController * clip = [[INTCTClipImageViewController alloc] init];
//    INTCTClipImageViewmodel * viewmodel = [[INTCTClipImageViewmodel alloc] initWithNSDictionary:_viewmodel.aliDic];
//    clip.viewmodel = viewmodel;
//    clip.delegate = self;
//    clip.image = image;
//    [self presentViewController:clip animated:YES completion:nil];
//}

- (void)p_ctmsg_recaptureAction {
    [self p_ctmsg_showCameraView];
    [_cameraView ctmsg_recapture];
    _tempImg = nil;
    [[NSFileManager defaultManager] removeItemAtPath:_videoPath error:nil];
}

/**
 更新进度条
 
 @param value 进度
 @param playing 是否是播放
 */
- (void)updateProgress:(CGFloat)value playing:(BOOL)playing {
    if (value > 1.0) {
        [self p_ctmsg_endRecord:self.recordButton];
    } else {
        NSLog(@"%f", value);
        UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:kRecordCenter radius:(kRoundWidth - 10) / 2 + 16 startAngle:- M_PI_2 endAngle:2 * M_PI * (value) - M_PI_2 clockwise:YES];
        self.progressLayer.path = path.CGPath;
    }
}

#pragma mark - Lazy Property

- (UIButton *)commitButton {
    if (!_commitButton) {
        _commitButton = ({
            UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
            [b addTarget:self action:@selector(p_ctmsg_commitAction:) forControlEvents:UIControlEventTouchUpInside];
            [b setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_camera_3"] forState:UIControlStateNormal];
            CGFloat left = self.view.frame.size.width - kLeftInterval - kRoundWidth;
            CGFloat top = self.view.frame.size.height - kLeftInterval - kRoundWidth;
            b.frame = CGRectMake(left, top, kRoundWidth, kRoundWidth);
            b;
        });
    }
    return _commitButton;
}

- (UIButton *)recaptureButton {
    if (!_recaptureButton) {
        _recaptureButton = ({
            UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
            [b setImage:[CTMSGUtilities imageForNameInBundle:@"ctmsg_camera_2"] forState:UIControlStateNormal];
            [b addTarget:self action:@selector(p_ctmsg_recaptureAction) forControlEvents:UIControlEventTouchUpInside];
            CGFloat top = self.view.frame.size.height - kLeftInterval - kRoundWidth;
            b.frame = CGRectMake(kLeftInterval, top, kRoundWidth, kRoundWidth);
            b;
        });
    }
    return _recaptureButton;
}

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = ({
            CAShapeLayer *l = [CAShapeLayer layer];
            l.lineWidth = 5.0f;
            l.fillColor = nil;
            l.strokeColor = [UIColor whiteColor].CGColor;
            l.lineCap = kCALineCapRound;
            l;
        });
    }
    return _progressLayer;
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - getter

- (NSString *)videoPath {
    if (!_videoPath) {
        float nowTime = [[NSDate date] timeIntervalSince1970] * 1000;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString * directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString * parentPath = [directory stringByAppendingPathComponent:@"MessageKit"];
        parentPath = [parentPath stringByAppendingPathComponent:@"sendMessageCache"];
        NSString * filePath = [NSString stringWithFormat:@"%@/%.0f_video.mov", parentPath, nowTime];
        BOOL isDir;
        if (![fileManager fileExistsAtPath:parentPath isDirectory:&isDir]) {
            NSLog(@"%@",parentPath);
            [fileManager createDirectoryAtPath:parentPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _videoPath = filePath;
    }
    return _videoPath;
}

//- (NSString *)compresedVideoPath {
//    if (!_compresedVideoPath) {
//        float nowTime = [[NSDate date] timeIntervalSince1970] * 1000;
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        NSString * directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
//        NSString * parentPath = [directory stringByAppendingPathComponent:@"MessageKit"];
//        parentPath = [parentPath stringByAppendingPathComponent:@"sendMessageCache"];
//        NSString * filePath = [NSString stringWithFormat:@"%@/%.0f_video.mov", parentPath, nowTime];
//        BOOL isDir;
//        if (![fileManager fileExistsAtPath:parentPath isDirectory:&isDir]) {
//            NSLog(@"%@",parentPath);
//            [fileManager createDirectoryAtPath:parentPath withIntermediateDirectories:YES attributes:nil error:nil];
//        }
//        _compresedVideoPath = filePath;
//    }
//    return _compresedVideoPath;
//}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    NSLog(@"🤩🤩🤩CTMSGCameraViewController deallc🤩🤩🤩");
}

@end
