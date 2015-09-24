//
//  LTAlertView.m
//
//  Created by 刘献亭 on 15/9/14.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "LTAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import "PureLayout.h"

#define kAlertWidth 3.0*[UIScreen mainScreen].bounds.size.width/4
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface LTAlertView ()

@property(nonatomic, strong) UIView *maskImageView;

@property(nonatomic, assign) NSInteger alertHeight;

@property(nonatomic, strong) UIView *customView;

@property(nonatomic, strong) NSLayoutConstraint *edgeTopConstraint;

@property(nonatomic, assign) BOOL isHasFocusView;

@property(nonatomic, assign) BOOL customAlertMoveOutSate;

@end

@implementation LTAlertView

#pragma 公共方法
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
    }
    return self;
}


- (void)show {
    if (self.alertHeight) {
        [self showDefaultAlert];
        return;
    }
    [self showCustomAlert];
}

- (void)dismiss {
    //清除蒙版
    [self.maskImageView removeFromSuperview];
    self.maskImageView = nil;
    
    //使用默认的view
    if (self.alertHeight) {
        [self animateDefaultWithY:SCREEN_HEIGHT removeFromSuperView:YES];
        return;
    }
    //使用自定义NIB
    [self animateWithY:SCREEN_HEIGHT removeFromSuperView:YES];
}

- (void)addMaskView {
    if (!self.maskImageView) {
        self.maskImageView = [[UIView alloc] initWithFrame:[self topView].frame];
        self.maskImageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        self.maskImageView.alpha = 0.6f;
        self.maskImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [self.maskImageView addGestureRecognizer:gesture];
    }
    if (self.isHasFocusView) {
        [[self appRootViewController].view insertSubview:self.maskImageView belowSubview:self];
    }else{
        [[self topView] insertSubview:self.maskImageView belowSubview:self];
    }
    
    //设置阴影
    self.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowRadius = 6;//阴影半径，默认3
    self.clipsToBounds = NO;
}


#pragma mark -自定义view
- (id)initWithNib:(UIView *)view {
    if (self = [self init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
        self.customView = view;
        if ([self findAssignView:@[[UITextField class],[UITextView class]] inView:view]) {
            [self handleKeyboard];
            self.isHasFocusView=YES;
        }
    }
    return self;
}

- (void)handleKeyboard {
    //对键盘的弹出的处理
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)showCustomAlert {
    //避免再次点击是，移除动画还没有执行完
    if (self.edgeTopConstraint) {
        return;
    }

    //添加蒙版
    [self addMaskView];
    [self.maskImageView autoPinEdgesToSuperviewEdges];

    //设置初始约束
    [self.customView autoPinEdgesToSuperviewEdges];

    if (self.isHasFocusView) {
        [[self appRootViewController].view addSubview:self];
    }else{
        [[self topView] addSubview:self];
    }
    CGSize size = [self.customView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    self.edgeTopConstraint = [self autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:-size.height];
    [self autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:([UIScreen mainScreen].bounds.size.width - kAlertWidth) * 0.5];
    [self autoSetDimension:ALDimensionWidth toSize:kAlertWidth];
    [self autoSetDimension:ALDimensionHeight toSize:size.height];

    //动画 从顶部移动到中间
    [self animateWithY:([UIScreen mainScreen].bounds.size.height - size.height) * 0.5 removeFromSuperView:NO];
}


- (void)keyboardWillShow:(NSNotification *)notification {
    if (self.customAlertMoveOutSate) {
        return;
    }
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    NSInteger centerYInScreen = ([UIScreen mainScreen].bounds.size.height - kbSize.height) * 0.5;
    CGSize sizeOfCustomView = [self.customView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    NSInteger y = centerYInScreen - sizeOfCustomView.height * 0.5;
    [self animateWithY:y removeFromSuperView:NO];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (self.customAlertMoveOutSate) {
        return;
    }
    CGSize size = [self.customView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    NSInteger y = (SCREEN_HEIGHT - size.height) * 0.5;
    [self animateWithY:y removeFromSuperView:NO];
}

- (void)animateWithY:(NSInteger)y removeFromSuperView:(BOOL)isRemove {
    if (isRemove) {
        self.customAlertMoveOutSate=YES;
    }
    [self layoutIfNeeded];
    [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:0 animations:^{
                self.edgeTopConstraint.constant = y;
                [self layoutIfNeeded];
            }
                     completion:^(BOOL finished) {
                         if (isRemove) {
                             [[NSNotificationCenter defaultCenter] removeObserver:self];
                             [self removeFromSuperview];
                             self.edgeTopConstraint = nil;
                             self.customAlertMoveOutSate=NO;
                         }
                     }];
}


#pragma mark -默认布局
- (id)initWithTitle:(NSString *)title
        contentText:(NSString *)content
    leftButtonTitle:(NSString *)leftTitle
   rightButtonTitle:(NSString *)rigthTitle {
    if (self = [self init]) {
        //设置内边距
        UIView *contentView = [UIView new];
        int contentW = kAlertWidth - 28 * 2;
        [self addSubview:contentView];

        //设置标题
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:18], NSFontAttributeName, nil];
        CGSize size = [title boundingRectWithSize:CGSizeMake(contentW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
        UILabel *alertTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, contentW, size.height)];
        alertTitleLabel.font = [UIFont systemFontOfSize:18.0f];
        alertTitleLabel.textColor = [UIColor blackColor];
        alertTitleLabel.textAlignment = NSTextAlignmentCenter;
        alertTitleLabel.text = title;
        [contentView addSubview:alertTitleLabel];

        //设置内容
        UILabel *alertContentLabel = [UILabel new];
        if (content) {
            CGFloat contentLabelWidth = kAlertWidth - 16;
            size = [content boundingRectWithSize:CGSizeMake(contentLabelWidth - 8, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
            alertContentLabel.frame = CGRectMake(4, CGRectGetMaxY(alertTitleLabel.frame) + 9, contentW - 8, size.height);
            alertContentLabel.numberOfLines = 0;
            alertContentLabel.textColor = [UIColor blackColor];
            alertContentLabel.font = [UIFont systemFontOfSize:14.0f];
            alertContentLabel.text = content;
            [contentView addSubview:alertContentLabel];
        }

        //设置左侧button
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (leftTitle) {
            leftBtn.frame = CGRectMake(4, CGRectGetMaxY(content.length ? alertContentLabel.frame : alertTitleLabel.frame) + 20, (contentW - 18) / 2, 32);
            [leftBtn setTitle:leftTitle forState:UIControlStateNormal];
            leftBtn.titleLabel.font = [UIFont systemFontOfSize:18.0f];
            [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [leftBtn setBackgroundColor:[UIColor colorWithRed:85 / 255.0 green:85 / 255.0 blue:85 / 255.0 alpha:1.0]];
            [leftBtn addTarget:self action:@selector(leftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:leftBtn];
        }

        //设置右侧button
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(leftTitle.length ? CGRectGetMaxX(leftBtn.frame) + 10 : 4, CGRectGetMaxY(alertContentLabel ? alertContentLabel.frame : alertTitleLabel.frame) + 20, leftTitle.length ? (contentW - 18) / 2 : (contentW - 8), 32);
        [rightBtn setTitle:rigthTitle forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightBtn setBackgroundColor:[UIColor colorWithRed:85 / 255.0 green:85 / 255.0 blue:85 / 255.0 alpha:1.0]];
        [rightBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:rightBtn];

        contentView.frame = CGRectMake(28, 23, contentW, CGRectGetMaxY(rightBtn.frame));
        _alertHeight = CGRectGetMaxY(contentView.frame) + 30;
      
    }
    return self;
}

- (void)showDefaultAlert {
    [self addMaskView];
    self.frame = CGRectMake((SCREEN_WIDTH - kAlertWidth) * 0.5,_alertHeight - 30, kAlertWidth, _alertHeight);
    [[self topView] addSubview:self];
    [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:0
                     animations:^{
                         CGRect frame = self.frame;
                         frame.origin.y = (SCREEN_HEIGHT - _alertHeight) * 0.5;
                         self.frame = frame;
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)animateDefaultWithY:(NSInteger)y removeFromSuperView:(BOOL)isRemove {
    if (isRemove) {
        self.alertHeight=0;
    }
    [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:0
                     animations:^{
                         CGRect frame=self.frame;
                         frame.origin.y=y;
                         self.frame=frame;
                     }
                     completion:^(BOOL finished) {
                         if (isRemove) {
                             [self removeFromSuperview];
                             
                         }
                     }];
}

- (void)leftBtnClicked:(id)sender {
    [self dismiss];
    if (self.leftBlock) {
        self.leftBlock();
    }
}

- (void)rightBtnClicked:(id)sender {
    [self dismiss];
    if (self.rightBlock) {
        self.rightBlock();
    }
}

#pragma mark -工具方法

- (UIView *)topView{
    return  [[UIApplication sharedApplication].windows objectAtIndex:1];
}

- (UIViewController*)appRootViewController
{
    UIViewController* appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController* topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

- (BOOL)findAssignView:(NSArray *)classArray inView:(UIView*)view
{
    for (UIView* childView in view.subviews) {
        for (Class clazz in classArray) {
            if ([childView isKindOfClass:clazz]){
                return YES;
            }
            BOOL result = [self findAssignView:classArray inView:childView];
            if (result)
                return YES;
        }
    }
    return NO;
}

@end
