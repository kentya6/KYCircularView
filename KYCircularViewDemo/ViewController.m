//
//  ViewController.m
//  KYCircularViewDemo
//
//  Created by Y.K on 2014/07/28.
//  Copyright (c) 2014年 Yokoyama Kengo. All rights reserved.
//

#import "ViewController.h"
#import "KYCircularView.h"

#define ColorHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:0.55]

@interface ViewController ()
{
    KYCircularView *_circularView1;
    KYCircularView *_circularView2;
    KYCircularView *_circularView3;
}
@property (nonatomic, assign) float localProgress;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupKYCircularView1];
    [self setupKYCircularView2];
    [self setupKYCircularView3];
    
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
}

- (void)setupKYCircularView1
{
    _circularView1 = [[KYCircularView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2)];
    _circularView1.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(160, 200)
                                                         radius:_circularView1.frame.size.width/3
                                                     startAngle:M_PI
                                                       endAngle:0
                                                      clockwise:YES];
    _circularView1.lineWidth = 8.0;
    
    __block UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 30.0, 170.0, 60.0, 32.0)];
    textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:32];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.textColor = ColorHex(0xA6E39D);
    textLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:textLabel];
    
    _circularView1.progressChangedBlock = ^(KYCircularView *circularView, float progress) {
        [textLabel setText:[NSString stringWithFormat:@"%2.0f%%", progress * 100]];
    };
    
    [self.view addSubview:_circularView1];
}

- (void)setupKYCircularView2
{
    _circularView2 = [[KYCircularView alloc] initWithFrame:CGRectMake(0, _circularView1.frame.size.height, self.view.frame.size.width/2, self.view.frame.size.height/3)];
    _circularView2.colors = @[(__bridge id)ColorHex(0xA6E39D).CGColor, (__bridge id)ColorHex(0xAEC1E3).CGColor, (__bridge id)ColorHex(0xE1A5CB).CGColor, (__bridge id)ColorHex(0xF3C0AB).CGColor];
    
    [self.view addSubview:_circularView2];
}

- (void)setupKYCircularView3
{
    _circularView3 = [[KYCircularView alloc] initWithFrame:CGRectMake(_circularView2.frame.size.width*1.25, _circularView1.frame.size.height*1.15, self.view.frame.size.width/2, self.view.frame.size.height/2)];
    _circularView3.colors = @[(__bridge id)ColorHex(0xFFF7AA).CGColor, (__bridge id)ColorHex(0xF3C0AB).CGColor];
    _circularView3.lineWidth = 3.0;
    
    CGFloat pathWidth = 100.0f;
    CGFloat pathHeight = 100.0f;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(pathWidth * 0.5, pathHeight * 0.02)];
    [path addLineToPoint:CGPointMake(pathWidth * 0.84, pathHeight * 0.86)];
    [path addLineToPoint:CGPointMake(pathWidth * 0.06, pathHeight * 0.33)];
    [path addLineToPoint:CGPointMake(pathWidth * 0.96, pathHeight * 0.33)];
    [path addLineToPoint:CGPointMake(pathWidth * 0.17, pathHeight * 0.86)];
    [path closePath];
    
    _circularView3.path = path;
    
    [self.view addSubview:_circularView3];
}

- (void)updateProgress:(NSTimer *)timer {
    _localProgress = ((int)((_localProgress * 100.0f) + 1.01) % 100) / 100.0f;
    
    [_circularView1 setProgress:_localProgress];
    [_circularView2 setProgress:_localProgress];
    [_circularView3 setProgress:_localProgress];
}

@end
