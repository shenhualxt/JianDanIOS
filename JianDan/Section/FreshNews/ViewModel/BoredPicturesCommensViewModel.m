//
//  BoredPicturesCommensViewModel.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/29.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "BoredPicturesCommensViewModel.h"
#import "Comments.h"

@implementation BoredPicturesCommensViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[self getBoredPicturesCommentArray:nil] subscribeNext:^(id x) {
            
        }];
    }
    return self;
}

-(RACSignal *)getBoredPicturesCommentArray:(id)input{
    NSString *url=[NSString stringWithFormat:@"%@comment-%@",duoShuoCommentListlUrl,@"2945543"];
   return [[AFNetWorkUtils get2racWthURL:url]map:^id(NSDictionary *resultDic) {
        //获得热门评论
        NSArray *hotCommentsPost_Id=[resultDic objectForKey:@"hotPosts"];
        NSMutableArray *hotCommentsArray=[NSMutableArray array];
        //获得所有评论
        NSDictionary *parentPosts=[resultDic objectForKey:@"parentPosts"];
        NSMutableArray *newestCommentsArray=[NSMutableArray array];
        for (NSString *key in parentPosts) {
            Comments *comment=[Comments objectWithKeyValues:parentPosts[key]];
            [newestCommentsArray addObject:comment];
            //是否是热门评论
            if ([hotCommentsPost_Id containsObject:comment.post_id]) {
                [hotCommentsArray addObject:comment];
            }
            
            //寻找父评论
            if (!comment.parents.count) continue;
            NSMutableArray *parentCommentArray=[NSMutableArray array];
            for (NSString *parentId in comment.parents) {
                for(Comments *parentComment in newestCommentsArray){
                    if ([parentId isEqualToString:parentComment.post_id]) {
                        [parentCommentArray addObject:parentComment];
                        break;
                    }
                }
            }
            comment.parentCommentsArray=parentCommentArray;
        }
        
        NSMutableArray *commentsArray=[NSMutableArray array];
        if (hotCommentsArray.count) {
            [commentsArray addObject:hotCommentsArray];
        }
        if (newestCommentsArray.count) {
            [commentsArray addObject:newestCommentsArray];
        }
        return commentsArray;
    }];
}

@end
