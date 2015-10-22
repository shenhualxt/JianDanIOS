//
//  FreshNewsDetail.h
//  JianDan
//
//  Created by 刘献亭 on 15/9/9.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject

@property(nonatomic, assign) NSInteger id;

@property(nonatomic, copy) NSString *content;

@end

@interface FreshNewsDetail : NSObject


@property(nonatomic, copy) NSString *status;

@property(nonatomic, strong) Post *post;

@property(nonatomic, copy) NSString *previous_url;

@property(nonatomic, copy) NSString *next_url;


@end


