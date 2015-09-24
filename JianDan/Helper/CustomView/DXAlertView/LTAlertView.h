//
//  LTAlertView.m
//
//  Created by 刘献亭 on 15/9/14.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTAlertView : UIView

#pragma mark 自定义View
- (id)initWithNib:(UIView *)view;

#pragma mark 默认的alert
- (id) initWithTitle:(NSString *)title
         contentText:(NSString *)content
     leftButtonTitle:(NSString *)leftTitle
    rightButtonTitle:(NSString *)rigthTitle;

- (void)show;

-(void)dismiss;

@property (nonatomic, copy) dispatch_block_t leftBlock;

@property (nonatomic, copy) dispatch_block_t rightBlock;

@end
