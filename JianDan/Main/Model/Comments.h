//
//  Comments.h
//  JianDan
//
//  Created by 刘献亭 on 15/9/29.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vote.h"

@interface Comments : NSObject<Vote>

@property (nonatomic, assign) NSInteger vote_positive;

@property (nonatomic, strong) NSString *post_id;

@property (nonatomic, assign) NSInteger vote_negative;

//新鲜事
@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *date;

@property (nonatomic, copy) NSString *name;

//新添加
@property (nonatomic, assign) NSInteger parentId;

@property(nonatomic,copy) NSArray *parentCommentsArray;

@property (nonatomic, assign) CGFloat nameWidth;

//无聊图
@property (nonatomic, strong) NSString *thread_id;

@property (nonatomic, strong) NSString *message;

@property (nonatomic, strong) NSString *authorName;

@property (nonatomic, strong) NSString *created_at;

@property (nonatomic, strong) NSString *avatar_url;

@property (nonatomic, strong) NSArray *parents;

@end
