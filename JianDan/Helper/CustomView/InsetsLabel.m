//
//  InsetsLabel.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/17.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "InsetsLabel.h"

@implementation InsetsLabel

-(id)initWithFrame:(CGRect)frame andInsets:(UIEdgeInsets)insets
{
    self=[super initWithFrame:frame];
    if(self){
        self.insets= insets;
    }
    return self;
}

-(id)initWithInsets:(UIEdgeInsets)insets
{
    self = [super init];
    if(self){
        self.insets= insets;
    }
    return self;
}

-(void)drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect,self.insets)];
}

@end
