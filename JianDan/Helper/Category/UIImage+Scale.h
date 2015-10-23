//
//  UIImage+Scale.h
//  JianDan
//
//  Created by 刘献亭 on 15/9/21.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Scale)



-(BOOL)isEqual:(UIImage*)image;

- (UIImage *)scaleImageToSize:(CGSize)newSize;

-(UIImage *)getImageFromImageWithRect:(CGRect)rect;

+(UIImage *)resizeImageWithName:(NSString *)name;

+ (UIImage *)resizedImageWithName:(NSString *)name left:(CGFloat)left top:(CGFloat)top;

+ (UIImage *)imageWithColor:(UIColor *)color ;

- (UIImage*)imageCompressWithScale:(float)scale;

+(BOOL)image1IsEqual:(UIImage *)image1 image2:(UIImage *)image2;

@end
