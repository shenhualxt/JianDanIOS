//
//  CommentViewModel.h
//  JianDan
//
//  Created by 刘献亭 on 15/9/15.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Comments;

@interface CommentViewModel : NSObject

@property(strong,nonatomic) RACCommand *sourceCommand;

- (void)getParentComment:(NSMutableArray *)comments comment:(Comments *)comment;

@end
