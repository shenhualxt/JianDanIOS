//
//  PushCommentViewModel.h
//  JianDan
//
//  Created by 刘献亭 on 15/9/30.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kName @"name"
#define kEmail @"email"

@interface PushCommentViewModel : NSObject

- (instancetype)initWithSendObject:(id)sendObject;

+ (instancetype)modelWithSendObject:(id)sendObject;

@property(strong,nonatomic) RACSignal *pushCommentSignal;

@end
