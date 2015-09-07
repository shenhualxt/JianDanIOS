//
//  FreshNewsViewModel.m
//  JianDan
/**
 * 缓存逻辑
 * 如果没有网络：则从缓存的数据库中分页取出
 * 如果有网络：则从网络获取（只加载新获取的第一页数据），并保存到数据库中
 */
//  Created by 刘献亭 on 15/8/29.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "FreshNewsViewModel.h"
#import "FreshNews.h"
#import "CacheTools.h"
#import "NetTypeUtils.h"

static  NSString *const sortArgument=@"date";

@interface FreshNewsViewModel ()

@property(nonatomic, strong) RACCommand *freshNewsCommand;
@property(nonatomic, strong) NSMutableArray *posts;
@property(nonatomic, assign) NSInteger currentPage;
@property(nonatomic, assign) BOOL isLoadingMore;
@property(nonatomic, assign) BOOL loadFromDB;
@end

@implementation FreshNewsViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.posts = [NSMutableArray array];
        self.currentPage = 1;
        [self setup];
    }
    return self;
}

- (void)setup {
    @weakify(self)
    _freshNewsCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id isLoadMore) {
        @strongify(self)
        //获得需要加载的是第几页的数据
        NSInteger page = 1;
        if ([isLoadMore boolValue]) {
            page = ++self.currentPage;
        }
        //获取新鲜事的数据
        if ([NetTypeUtils sharedNetTypeUtils].netType==NONet){
            self.loadFromDB=YES;
            return [self requestFromDBSignalWithPage:page];
        }else{
            self.loadFromDB=NO;
            return [self requestFromNetSignal:isLoadMore page:page];
        }

    }];
}

- (RACSignal *)requestFromDBSignalWithPage:(NSInteger)page {
    @weakify(self)
    return [[[CacheTools sharedCacheTools] read:[Posts class] page:page] map:^id(NSArray *posts) {
        @strongify(self)
        self.isLoadingMore = NO;
        if(!posts|| ![posts count]){
            return self.posts;
        }
        [self.posts addObjectsFromArray:posts];
        return self.posts;
    }];
}

- (RACSignal *)requestFromNetSignal:(const id)isLoadMore page:(NSInteger)page {
    NSString *newFreshNewUrl = [NSString stringWithFormat:@"%@%ld", freshNewUrl, (long)page];
    @weakify(self)
    return [[[AFNetWorkUtils racGETWithURL:newFreshNewUrl class:[FreshNews class]] map:^id(FreshNews *freshNews) {
        _isLoadingMore=NO;
        @strongify(self)
        //1，第一次加载数据 或者先前加载的是缓存的数据
        if (![self.posts count]||self.loadFromDB) {
            return [self firstLoad:freshNews];
        }
        //2，上拉加载更多
        if ([isLoadMore boolValue]) {
            return [self pullUpLoadMore:freshNews];
        }
        //3，下拉加载更多
        return [self pullDownLoadMore:freshNews];
    }] doError:^(NSError *error) {
        if ([isLoadMore boolValue]) {
            _isLoadingMore = NO;
        }
    }];
}


- (NSArray *)firstLoad:(const FreshNews *)freshNews {
    self.posts=freshNews.posts;
    [[CacheTools sharedCacheTools] save:freshNews.posts sortArgument:sortArgument];
    return freshNews.posts;
}

- (NSArray *)pullUpLoadMore:(const FreshNews *)freshNews {
    [self.posts addObjectsFromArray:freshNews.posts];
    [[CacheTools sharedCacheTools] save:freshNews.posts sortArgument:sortArgument];
    return self.posts;
}

- (NSArray *)pullDownLoadMore:(const FreshNews *)freshNews {
    [freshNews.posts enumerateObjectsUsingBlock:^(Posts *post, NSUInteger idx, BOOL *stop) {
        if (post.id == [self.posts[0] id]) {
            *stop = YES;
            NSArray *subArray = [freshNews.posts subarrayWithRange:NSMakeRange(0, idx)];
            if (!subArray || [subArray count]) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [subArray count])];
                [self.posts insertObjects:subArray atIndexes:indexSet];
                [[CacheTools sharedCacheTools] save:subArray sortArgument:sortArgument];
            }
        }
    }];
    return self.posts;
}

#pragma mark -scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat height = scrollView.frame.size.height;
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat distanceFromBottom = scrollView.contentSize.height - contentOffsetY;
    if (distanceFromBottom < 12 * height && [self.posts count] && !_isLoadingMore) {
        LogBlue(@"test");
        _isLoadingMore = YES;
        [_freshNewsCommand execute:@(YES)];
    }
}

@end
