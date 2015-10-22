//
//  ToastHelper.h
//  JianDan
//
//  Created by 刘献亭 on 15/9/11.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KSimleProgressVisiable @"simleProgressVisiable"

@interface ToastHelper : NSObject

@property(nonatomic, assign) BOOL simleProgressVisiable;

+ (ToastHelper *)sharedToastHelper;

- (void)toast:(NSString *)textString;

@end
