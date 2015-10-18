//
//  ScaleImageView.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/20.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "ScaleImageView.h"
#import "UIImage+Scale.h"
#import "PureLayout.h"

#define kPlaceholderSize [UIImage imageNamed:@"ic_loading_large"].size

@implementation ScaleImageView

-(void)setImage:(UIImage *)image{
     CGImageRef imageRef=image.CGImage;
    // 1，设定基本动画参数
    CABasicAnimation *contentsAnimation = [CABasicAnimation animationWithKeyPath:@"contents"];
    contentsAnimation.fromValue         =  self.layer.contents;
    contentsAnimation.toValue           =  (__bridge id)imageRef;
    contentsAnimation.duration          = 0.2f;
    
    // 2，设定layer动画结束后的contents值
    self.layer.contents         = (__bridge id)imageRef;
    
    //3， 让layer开始执行动画
    [self.layer addAnimation:contentsAnimation forKey:nil];
}

-(CGSize)adjustSize:(CGSize)size{
    if (!size.height) {
        size=kPlaceholderSize;
    }
    CGFloat ratio = self.frame.size.width/ size.width;
    NSInteger mHeight = size.height * ratio;
    return CGSizeMake(self.frame.size.width, mHeight);
}


-(void)updateIntrinsicContentSize:(CGSize)size withMaxHeight:(BOOL)maxHeight{
    CGFloat mHeight =[self adjustSize:size].height;
    if(mHeight>=SCREEN_HEIGHT&&maxHeight){
        mHeight=SCREEN_HEIGHT*2.0/3.0;
        self.layer.masksToBounds=YES;
        [self.layer setContentsScale:[[UIScreen mainScreen] scale]];
        self.layer.contentsGravity=kCAGravityResizeAspectFill;
    }else{
        self.layer.contentsGravity=kCAGravityResize;
    }
     self.mHeight=mHeight;
    [self invalidateIntrinsicContentSize];
}

-(CGSize)intrinsicContentSize{
    if (self.mHeight) {
         return CGSizeMake(self.frame.size.width, (int)self.mHeight);
    }
    return [super intrinsicContentSize];
   
}
@end
