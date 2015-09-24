//
//  InsetsLabel.h
//  JianDan
//
//  Created by 刘献亭 on 15/9/17.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InsetsLabel : UILabel

@property(nonatomic) UIEdgeInsets insets;

-(id)initWithFrame:(CGRect)frame andInsets: (UIEdgeInsets)insets;

-(id)initWithInsets: (UIEdgeInsets)insets;

@end
