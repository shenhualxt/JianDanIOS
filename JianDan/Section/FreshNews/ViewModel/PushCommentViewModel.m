//
//  PushCommentViewModel.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/30.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "PushCommentViewModel.h"
#import "Comments.h"

@interface PushCommentViewModel ()

@property(strong, nonatomic) id sendObject;

@end

@implementation PushCommentViewModel

- (instancetype)initWithSendObject:(id)sendObject {
    self = [super init];
    if (self) {
        self.sendObject = sendObject;
    }
    return self;
}

+ (instancetype)modelWithSendObject:(id)sendObject {
    return [[self alloc] initWithSendObject:sendObject];
}

#pragma mark -lazy initialize

- (RACSignal *)pushCommentSignal {
    if (!_pushCommentSignal) {
        NSString * thread_id = (NSString *) self.sendObject;
        Comments *parentComment = nil;
        if ([self.sendObject isKindOfClass:[RACTuple class]]) {
            parentComment = ((RACTuple *) self.sendObject).first;
            thread_id = ((RACTuple *) self.sendObject).second;
        }

        //多说的评论 post
        if (thread_id.length != 5) {
            NSMutableDictionary *params = [self jointParamsWithThreadId:thread_id parentComment:parentComment];
            _pushCommentSignal = [[[AFNetWorkUtils racPOSTWithURL:duoShuoPushCommentUrl params:params class:[Comments class]] doNext:^(id x) {

            }] doError:^(NSError *error) {

            }];
        } else {//煎蛋的评论 get
            NSString * url = [self jointURLWithThreadId:thread_id parentComment:parentComment];
            _pushCommentSignal = [AFNetWorkUtils racGETWithURL:url class:[Comments class]];
        }
    }
    return _pushCommentSignal;
}


- (NSMutableDictionary *)jointParamsWithThreadId:(NSString *)thread_id parentComment:(Comments *)parentComment {
    //顺序问题
    NSString * author_name = [[NSUserDefaults standardUserDefaults] objectForKey:kName];
    NSString * author_email = [[NSUserDefaults standardUserDefaults] objectForKey:kEmail];
    NSMutableDictionary *params = [@{
            @"thread_id" : thread_id,
            @"author_name" : author_name,
            @"author_email" : author_email,
            @"message" : @"haha"
    } mutableCopy];
    if (parentComment) {
        params[@"parent_id"] = parentComment.post_id;
    }
    return params;
}


- (NSString *)jointURLWithThreadId:(NSString *)thread_id parentComment:(Comments *)parentComment {

    NSString * author_name = [[NSUserDefaults standardUserDefaults] objectForKey:kName];
    NSString * author_email = [[NSUserDefaults standardUserDefaults] objectForKey:kEmail];

    //新鲜事：http:/\/jandan.net/?oxwlxojflwblxbsapi=respond.submit_comment&content=顶煎蛋 &email=1540717369@qq.com&name=shenhualxt&post_id=69106
    NSString * content = @"";
    if (parentComment) {
        Comments *parentComment = ((RACTuple *) self.sendObject).first;
        content = [NSString stringWithFormat:@"<a href=\"#comment-%@\">%@</a>: %@", parentComment.post_id, parentComment.name, content];
        thread_id = ((RACTuple *) self.sendObject).second;
    }
    NSString * url = [NSMutableString stringWithFormat:@"%@&content=%@&email=%@&name=%@&post_id=%@", pushCommentlUrl, content, author_email, author_name, thread_id];
    return [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
