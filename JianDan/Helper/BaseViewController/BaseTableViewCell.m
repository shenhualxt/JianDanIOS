//
//  BaseTableViewCell.m
//  JianDan
//
//  Created by 刘献亭 on 15/10/19.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "BaseTableViewCell.h"
//@interface CustomCellView : UIView
//
//@end
//
//@implementation CustomCellView
//
//- (void)drawRect:(CGRect)rect
//{
//    [super drawRect:rect];
//    [(BaseTableViewCell *)[self superview] drawContentView:rect];
//}
//@end

@interface BaseTableViewCell()

@property(strong,nonatomic) UIProgressView *progressView;

@end

@implementation BaseTableViewCell



//- (void)setFrame:(CGRect)frame
//{
//    [super setFrame:frame];
//    CGRect b = [self bounds];
//    b.size.height -= 1;
//    contentView.frame = b;
//}
//
//- (void)setNeedsDisplay
//{
//    [super setNeedsDisplay];
//    [contentView setNeedsDisplay];
//}
//
//
//-(UIView *)bgView{
//    return contentView;
//}

//- (void)drawContentView:(CGRect)rect
//{
////    CGContextRef context = UIGraphicsGetCurrentContext();
////    CGRect cellRect = self.frame;
////    if (self.highlighted || self.selected)
////    {
////        CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
////        CGContextFillRect(context, CGRectMake(0, 0, cellRect.size.width, cellRect.size.height));
////    }
////    else
////    {
////        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
////        CGContextFillRect(context, CGRectMake(0, 0, cellRect.size.width, cellRect.size.height));
////    }
//    //子类实现
//}

- (void)addProgressView:(CGRect)rect {
    if (!self.progressView) {
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        rect.size.height=2;
        self.progressView.frame=rect;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.progressView.progress=0;
            self.progressView.hidden=YES;
            [self insertSubview:self.progressView atIndex:self.subviews.count];
        });
    }
}


-(void)updateProgressView:(CGFloat)progress rect:(CGRect)rect{
    [self addProgressView:rect];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (self.progressView) {
            self.progressView.hidden=NO;
            self.progressView.progress=progress;
            if (progress>=1) {
                [self.progressView removeFromSuperview];
                self.progressView = nil;
            }
        }
    });
}




@end
