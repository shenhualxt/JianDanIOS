//
//  PopoverView.h
//  ArrowView
//
//  Created by guojiang on 4/9/14.
//  Copyright (c) 2014年 LINAICAI. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import <UIKit/UIKit.h>
typedef NS_ENUM (int, Position) {
    position_bottom       = 0,//底部
    position_left      = 1,//左边
};

@interface PopoverView : UIView

- (void)show;
- (void)dismiss;
- (void)dismiss:(BOOL)animated;
- (id)initWithBtnFrame:(CGRect)btnFrame titles:(NSArray *)titles images:(NSArray *)images;

@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, copy) void (^selectRowAtIndex)(NSInteger index);
- (id)initWithBtnFrame:(CGRect)btnFrame view:(UIView *)view position:(Position)position;
@end
