//
//  CommentViewModel.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/15.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "CommentViewModel.h"
#import "FreshNewsComment.h"

@implementation CommentViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

-(void)setUp{
    self.sourceCommand=[[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [[[[AFNetWorkUtils racGETWithURL:[NSString stringWithFormat:@"%@%@",freshNewCommentlUrl,input] class:[FreshNewsComment class]] map:^id(FreshNewsComment *comment) {
            //取出数组
            return comment.post.comments;
        }] map:^id(NSMutableArray *comments) {
            //整理内容 去掉不用的符号 找出所有父评论
            [comments enumerateObjectsUsingBlock:^(Comments *comment, NSUInteger idx, BOOL *stop) {
                [self getParentComment:comments comment:comment];
            }];
            return comments;
        }] map:^id(NSMutableArray *comments) {
            //筛选出热门评论 条件 <=6 赞数大于1 注意：返回结果 默认按时间排序
            NSMutableArray *newCommentsArray =[NSMutableArray arrayWithArray:[[[comments copy] reverseObjectEnumerator] allObjects]];
            NSArray *sortedArray=[comments sortedArrayUsingComparator:^NSComparisonResult(Comments *comment1,Comments *comment2) {
                return (NSComparisonResult)(comment1.vote_positive<comment2.vote_positive?NSOrderedDescending:NSOrderedAscending);
            }];
            
            __block NSUInteger count=0;
            [sortedArray enumerateObjectsUsingBlock:^(Comments *comment, NSUInteger idx, BOOL *stop) {
                if (idx<6&&comment.vote_positive>=1) {
                    [newCommentsArray insertObject:comment atIndex:idx];
                }else{
                    count=idx;
                    *stop=YES;
                }
            }];
            
            RACTuple *turple=[RACTuple tupleWithObjects:newCommentsArray,@(count), nil];
            return turple;
        }];
    }];

}

- (void)getParentComment:(NSMutableArray *)comments comment:(Comments *)comment {
    BOOL isHas7Num=[CommonUtils isMatch:comment.content regex: @"((?=.*[0-9]).{7,1000})"];
    BOOL isHasCommentString=[comment.content rangeOfString:@"#comment-"].length>0;
    BOOL isHandled=comment.parentId;
    if ((isHas7Num&&isHasCommentString)||isHandled) {
                    NSMutableArray *tempCommentsArray=[NSMutableArray array];
                    //获得父评价的id
                    NSInteger parentId=[self getParentIdFromContent:comment.content];
                    comment.parentId=parentId;
                    [self getParentComments:tempCommentsArray allComments:comments parentId:parentId];
                    //逆序
                    comment.parentCommentsArray=[[tempCommentsArray reverseObjectEnumerator] allObjects];
                    comment.content=[self getContentWithParent:comment.content];
                }else{
                    comment.content=[self getContentOnlySelf:comment.content];
                }
}

-(void)getParentComments:(NSMutableArray *)tempCommentsArray allComments:(NSArray*)allCommentsArray parentId:(NSInteger)parentId{
    [allCommentsArray enumerateObjectsUsingBlock:^(Comments *comment, NSUInteger idx, BOOL *stop) {
        if (comment.id!=parentId) {
            return;
        }
        if (![tempCommentsArray containsObject:comment]) {
            //找到了父评论
            [tempCommentsArray addObject:comment];
        }
        
        //父评论又有父评论
        if(comment.parentId&&comment.parentCommentsArray){
            comment.content=[self getContentWithParent:comment.content];
            [tempCommentsArray addObjectsFromArray:comment.parentCommentsArray];
            *stop=YES;
        }
        //父评论没有父评论了
        comment.content=[self getContentOnlySelf:comment.content];
    }];
}

-(NSString *)getContentWithParent:(NSString*)originContent{
    if ([originContent rangeOfString:@"</a>:"].length>0) {
        NSArray *array=[[self getContentOnlySelf:originContent] componentsSeparatedByString:@"</a>:"];
        if (array.count>1) {
            return  array[1];
        }
        return originContent;
    }
    return originContent;
}

-(NSString *)getContentOnlySelf:(NSString *)originContent{
    originContent=[originContent stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    originContent=[originContent stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
     return [originContent stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
}



-(NSInteger)getParentIdFromContent:(NSString*)content{
    @try {
       NSString *text=@"comment-";
        NSInteger index= [content rangeOfString:text].location+text.length;
        NSInteger parentId=[[content substringWithRange:NSMakeRange(index, index+7)] integerValue];
        return parentId;
    }
    @catch (NSException *exception) {
         return 0;
    }
   
}

@end
