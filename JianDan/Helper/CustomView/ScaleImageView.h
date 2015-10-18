//
//  ScaleImageView.h
//  JianDan
//
//  Created by 刘献亭 on 15/9/20.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScaleImageView : UIImageView

@property(assign,nonatomic) NSInteger mHeight;


-(void)updateIntrinsicContentSize:(CGSize)size withMaxHeight:(BOOL)maxHeight;

-(CGSize)adjustSize:(CGSize)size;

@end