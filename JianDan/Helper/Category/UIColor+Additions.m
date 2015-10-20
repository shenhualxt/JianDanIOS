//
//  UIColor+Additions.m
//  JianDan
//
//  Created by 刘献亭 on 15/10/20.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "UIColor+Additions.h"

@implementation UIColor (Additions)

- (UIImage*) createImage
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
