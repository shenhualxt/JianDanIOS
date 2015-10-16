//
//  CardView.m
//  JianDan
//
//  Created by 刘献亭 on 15/10/4.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "CardView.h"

@implementation CardView


-(void)layoutSubviews{
    self.layer.cornerRadius=2;
    UIBezierPath *shadowPath=[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:2];
    
    self.layer.masksToBounds=NO;
    self.layer.shadowColor=[UIColor blackColor].CGColor;
    self.layer.shadowOffset=CGSizeMake(0, 0.1);
    self.layer.shadowOpacity=0.5;
    self.layer.shadowPath=shadowPath.CGPath;
}

@end
