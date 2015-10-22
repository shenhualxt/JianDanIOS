//
//  CommentViewModel.h
//  JianDan
//
//  Created by 刘献亭 on 15/9/15.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Comments;

typedef NS_ENUM(NSInteger, CommentsType) {
    CommentsTypeFreshNews,
    CommentsTypeBoredPicture,
};

@interface CommentViewModel : NSObject

@property(strong, nonatomic) RACCommand *sourceCommand;

- (instancetype)initWithType:(CommentsType)commentsType;

- (void)getParentComment:(NSMutableArray *)comments comment:(Comments *)comment;

@end
