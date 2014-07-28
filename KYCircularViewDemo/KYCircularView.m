//
//  KYCircularView.m
//  KYCircularViewTest
//
//  Created by Y.K on 2014/07/27.
//  Copyright (c) 2014年 Yokoyama Kengo. All rights reserved.
//

#import "KYCircularView.h"

#define ColorHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:0.55]

NSString *const kShapeViewAnimation = @"kShapeViewAnimation";

@interface KYCircularShapeView : UIView

@property (nonatomic, assign) double startAngle;
@property (nonatomic, assign) double endAngle;

- (void)updateProgress:(float)progress;
- (CAShapeLayer *)shapeLayer;

@end

@interface KYCircularView ()
{
    CAGradientLayer *_gradientLayer;
}

@property (strong) KYCircularShapeView *progressView;
@property (assign) int progressDifference;
@property (strong) NSTimer *progressUpdateTimer;

@end

@implementation KYCircularView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedSetup];
    }
    return self;
}

- (void)sharedSetup {
    self.progressView = [[KYCircularShapeView alloc] initWithFrame:self.bounds];
    self.progressView.shapeLayer.fillColor = [UIColor clearColor].CGColor;
    self.progressView.shapeLayer.path = self.path.CGPath;
    
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.frame = self.progressView.frame;
    if (self.colors == nil) {
        _gradientLayer.colors = @[(__bridge id)ColorHex(0x9ACDE7).CGColor, (__bridge id)ColorHex(0xE7A5C9).CGColor];
    } else {
        _gradientLayer.colors = self.colors;
    }
    _gradientLayer.startPoint = CGPointMake(0, 0.5);
    _gradientLayer.endPoint = CGPointMake(1, 0.5);
    _gradientLayer.mask = self.progressView.shapeLayer;
    [self.layer addSublayer:_gradientLayer];
    
    [self resetDefaults];
}

- (void)resetDefaults {
    self.progressChangedBlock = nil;
    _animationDuration = 1.0f;
    
    [self tintColorDidChange];
}

#pragma mark - Public Accessors

- (void)setPath:(UIBezierPath *)path {
    _path = path;
    self.progressView.shapeLayer.path = path.CGPath;
}

- (void)setColors:(NSArray *)colors {
    _colors = colors;
    _gradientLayer.colors = colors;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    self.progressView.shapeLayer.lineWidth = lineWidth;
}

- (void)setStartAngle:(double)startAngle {
    _startAngle = startAngle;
    self.progressView.startAngle = startAngle;
}

- (void)setEndAngle:(double)endAngle {
    _endAngle = endAngle;
    self.progressView.endAngle = endAngle;
}

#pragma mark - Color

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    UIColor *tintColor = self.tintColor;
    
    self.progressView.shapeLayer.strokeColor = tintColor.CGColor;
    self.progressView.shapeLayer.borderColor = tintColor.CGColor;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.progressView.frame = self.bounds;
}

#pragma mark - Progress Control

- (void)setProgress:(float)progress animated:(BOOL)animated {
    // keep it between 0 and 1
    progress = MAX( MIN(progress, 1.0), 0.0);
    
    if (_progress == progress) {
        return;
    }
    
    if (animated) {
        [self animateToProgress:progress];
    } else {
        [self stopAnimation];
        _progress = progress;
        [self.progressView updateProgress:_progress];
    }
    
    if (self.progressChangedBlock) {
        self.progressChangedBlock(self, _progress);
    }
}

- (void)setProgress:(float)progress {
    [self setProgress:progress animated:NO];
}

- (void)setAnimationDuration:(CFTimeInterval)animationDuration {
    if (_animationDuration < 0) {
        return;
    }
    
    _animationDuration = animationDuration;
}

- (void)animateToProgress:(float)progress {
    [self stopAnimation];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = self.animationDuration;
    animation.fromValue = @(self.progress);
    animation.toValue = @(progress);
    animation.delegate = self;
    [self.progressView.layer addAnimation:animation forKey:kShapeViewAnimation];
    
    _progressDifference = (progress - self.progress) * 100;
    CFTimeInterval timerInterval =  self.animationDuration / ABS(_progressDifference);
    self.progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:timerInterval
                                                                  target:self
                                                                selector:@selector(onValueLabelUpdateTimer:)
                                                                userInfo:nil
                                                                 repeats:YES];
    _progress = progress;
}

- (void)stopAnimation {
    [self.progressView.layer removeAnimationForKey:kShapeViewAnimation];
    
    [self.progressUpdateTimer invalidate];
    self.progressUpdateTimer = nil;
}

- (void)onValueLabelUpdateTimer:(NSTimer *)timer {
    if (_progressDifference > 0) {
        _progressDifference--;
    } else {
        _progressDifference++;
    }
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.progressView updateProgress:_progress];
    [self.progressUpdateTimer invalidate];
    self.progressUpdateTimer = nil;
}

@end

#pragma mark - KYCircularShapeView

@implementation KYCircularShapeView

+ (Class)layerClass {
    return CAShapeLayer.class;
}

- (CAShapeLayer *)shapeLayer {
    return (CAShapeLayer *)self.layer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self updateProgress:0];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.startAngle == self.endAngle) {
        self.endAngle = self.startAngle + M_PI * 2;
    }
    if (self.shapeLayer.path == nil) {
        self.shapeLayer.path = [self layoutPath].CGPath;
    }
}

- (UIBezierPath *)layoutPath {
    CGFloat width = self.frame.size.width;
    
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2.0f, width/2.0f)
                                          radius:width/2.0f - self.shapeLayer.lineWidth - 0.5
                                      startAngle:self.startAngle
                                        endAngle:self.endAngle
                                       clockwise:YES];
}

- (void)updateProgress:(float)progress {
    [self updatePath:progress];
}

- (void)updatePath:(float)progress {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.shapeLayer.strokeEnd = progress;
    [CATransaction commit];
}

@end
