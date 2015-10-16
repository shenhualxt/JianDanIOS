//
//  WidthFixImageView.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/29.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "WidthFixImageView.h"

@implementation WidthFixImageView

-(void)setImage:(UIImage *)image{
    CGFloat ratio = self.frame.size.width/ image.size.width;
    CGFloat mHeight = image.size.height * ratio;
    self.mHeight=mHeight;
    [self invalidateIntrinsicContentSize];
    [super setImage:image];
}

-(CGSize)intrinsicContentSize{
    if (self.mHeight) {
        return CGSizeMake(self.frame.size.width, self.mHeight);
    }
    return [super intrinsicContentSize];
    
}

@end
