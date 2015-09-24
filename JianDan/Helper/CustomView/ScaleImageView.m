//
//  ScaleImageView.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/20.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "ScaleImageView.h"
#import "UIImage+Scale.h"

@implementation ScaleImageView

-(void)setImage:(UIImage *)image{
    CGFloat ratio = self.frame.size.width/ image.size.width;
    CGFloat mHeight = image.size.height * ratio;
    
//    if(mHeight>=[UIScreen mainScreen].bounds.size.height*4/3){
//        mHeight=[UIScreen mainScreen].bounds.size.height*2/3;
//        image=[image getImageFromImageWithRect:CGRectMake(0, 0, image.size.width, mHeight)];
//        image=[image scaleImageToSize:CGSizeMake(self.frame.size.width, mHeight)];
//    }else{
        image=[image scaleImageToSize:CGSizeMake(self.frame.size.width, mHeight)];
//    }

    [super setImage:image];
}

@end
