//
//  FreshNewsComment.h
//  JianDan
//
//  Created by 刘献亭 on 15/9/15.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FreshNewsCommentPost,Comments;

@interface FreshNewsComment : NSObject

@property (nonatomic, copy) NSString *status;

@property (nonatomic, strong) FreshNewsCommentPost *post;

@property (nonatomic, copy) NSString *previous_url;

@end
@interface FreshNewsCommentPost : NSObject

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, strong) NSMutableArray *comments;

@end

@interface Comments : NSObject

@property (nonatomic, copy) NSString *status;

@property (nonatomic, assign) NSInteger parent;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, assign) NSInteger vote_negative;

@property (nonatomic, copy) NSString *date;

@property (nonatomic, assign) NSInteger vote_positive;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) CGFloat nameWidth;

@property (nonatomic, copy) NSString *url;

//新添加
@property (nonatomic, assign) NSInteger parentId;

@property(nonatomic,copy) NSArray *parentCommentsArray;

@end

