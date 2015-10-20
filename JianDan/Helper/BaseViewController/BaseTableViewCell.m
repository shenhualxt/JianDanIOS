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
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.progressView.frame=rect;
            self.progressView.progress=0;
            self.progressView.hidden=YES;
            [self insertSubview:self.progressView atIndex:self.subviews.count];
        });
    }
}


-(void)updateProgressViewWithReceivedSize:(NSInteger)receivedSize expectedSize:(NSInteger)expectedSize rect:(CGRect)rect{
    if (expectedSize<0) return ;
    float pvalue=MAX(0,MIN(1,(float)receivedSize/(float)expectedSize));
    [self addProgressView:rect];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (self.progressView) {
            self.progressView.hidden=NO;
            self.progressView.progress=pvalue;
            if (pvalue>=1) {
                [self.progressView removeFromSuperview];
                self.progressView = nil;
            }
        }
    });
}




@end
