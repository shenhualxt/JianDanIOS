//
//  CardView.m
//  JianDan
//
//  Created by 刘献亭 on 15/10/4.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "CardView.h"

@implementation CardView


- (void)layoutSubviews {
    self.layer.cornerRadius = 4;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:4];

    self.layer.masksToBounds=YES;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 4);
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowPath = shadowPath.CGPath;
}

@end
