//
//  KYCircularView.h
//  KYCircularViewTest
//
//  Created by Y.K on 2014/07/27.
//  Copyright (c) 2014年 Yokoyama Kengo. All rights reserved.
//
@import UIKit;

@interface KYCircularView : UIView

@property (nonatomic, copy) void (^progressChangedBlock)(KYCircularView *circularView, float progress);
@property (nonatomic, assign) float progress;
@property (nonatomic, assign) double startAngle;
@property (nonatomic, assign) double endAngle;
@property (nonatomic, assign) CGFloat lineWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CFTimeInterval animationDuration UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) UIBezierPath *path;
@property (nonatomic, assign) NSArray *colors;

- (void)setProgress:(float)progress animated:(BOOL)animated;

@end
