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

#import "MainViewModel.h"
#import "CacheTools.h"

static NSString *_sortArgument=@"date";

@interface MainViewModel ()

@property(nonatomic, strong) RACCommand *sourceCommand;
@property(nonatomic, strong) NSMutableArray *sourceArray;
@property(nonatomic, assign) NSInteger currentPage;
@property(nonatomic, assign) BOOL loadFromDB;
@property(nonatomic, strong) RACTuple *turple;
@property(nonatomic, assign) BOOL isLoadingMore;

@end

@implementation MainViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sourceArray = [NSMutableArray array];
        self.currentPage = 1;
        [self setup];
    }
    return self;
}

- (void)setup {
    @weakify(self)
    self.sourceCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *turple) {
        self.turple=turple;
        id isLoadMore=turple.first;
        NSString *modelArgument=turple.second;
        Class modelClass=turple.third;
        NSString *url=turple.fourth;
        @strongify(self)
        //获得需要加载的是第几页的数据
        NSInteger page = 1;
        if ([isLoadMore boolValue]) {
            page = ++self.currentPage;
        }
        //获取新鲜事的数据
        if ([AFNetWorkUtils sharedAFNetWorkUtils].netType==NONet){
            self.loadFromDB=YES;
            return [self requestFromDBSignalWithPage:page class:modelClass];
        }else{
            self.loadFromDB=NO;
            //执行了两次
            return [self requestFromNetSignal:isLoadMore page:page subClass:modelClass url:url modelArgument:modelArgument];
        }
    }];
}

- (RACSignal *)requestFromNetSignal:(const id)isLoadMore page:(NSInteger)page subClass:(Class)modelClass url:(NSString *)url modelArgument:(NSString*)modelArgument{
    url = [NSString stringWithFormat:@"%@%ld", url, (long)page];
    @weakify(self)
    return [[[AFNetWorkUtils get2racWthURL:url] map:^id(NSDictionary *result) {
        NSArray *dicArray=[result objectForKey:modelArgument];
        NSMutableArray *array=[modelClass objectArrayWithKeyValuesArray:dicArray];
        @strongify(self)
        self.isLoadingMore=NO;
        //1，第一次加载数据 或者先前加载的是缓存的数据 获得切换了数据源
        BOOL isSwitchModel=self.sourceArray.count&&![self.sourceArray[0] isKindOfClass:modelClass];
        if (![self.sourceArray count]||self.loadFromDB ||isSwitchModel) {
            return [self firstLoad:array];
        }
        //2，上拉加载更多
        if ([isLoadMore boolValue]) {
            return [self pullUpLoadMore:array];
        }
        //3，下拉加载更多
        return [self pullDownLoadMore:array];
    }] doError:^(NSError *error) {
        @strongify(self)
        NSLog(@"%@",error);
        if ([isLoadMore boolValue]) {
            self.isLoadingMore = NO;
        }
    }];
}

- (RACSignal *)requestFromDBSignalWithPage:(NSInteger)page class:(Class)clazz{
    @weakify(self)
    return [[[CacheTools sharedCacheTools] read:clazz page:page] map:^id(NSArray *array) {
        @strongify(self)
        self.isLoadingMore = NO;
        if(!array|| ![array count]){
            return self.sourceArray;
        }
        [[ToastHelper sharedToastHelper] toast:@"无网络，当前显示为缓存数据"];
        [self.sourceArray addObjectsFromArray:array];
        return self.sourceArray;
    }];
}

- (NSArray *)firstLoad:(NSMutableArray *)array {
    self.sourceArray=array;
    [[CacheTools sharedCacheTools] save:array sortArgument:_sortArgument];
    return  self.sourceArray;
}

- (NSArray *)pullUpLoadMore:(NSArray *)array {
    [self.sourceArray addObjectsFromArray:array];
    [[CacheTools sharedCacheTools] save:array sortArgument:_sortArgument];
    return self.sourceArray;
}

- (NSArray *)pullDownLoadMore:(NSArray *)array {
    [array enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        if ([object isEqual:self.sourceArray[0]]) {
            *stop = YES;
            NSArray *subArray = [array subarrayWithRange:NSMakeRange(0, idx)];
            if (!subArray || [subArray count]) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [subArray count])];
                [self.sourceArray insertObjects:subArray atIndexes:indexSet];
                [[CacheTools sharedCacheTools] save:subArray sortArgument:_sortArgument];
            }
        }
    }];
    return self.sourceArray;
}

#pragma mark -scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat height = scrollView.frame.size.height;
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat distanceFromBottom = scrollView.contentSize.height - contentOffsetY;
    if (distanceFromBottom < 12 * height && [self.sourceArray count] && !self.isLoadingMore) {
        self.isLoadingMore = YES;
        RACTuple *newTurple=[RACTuple tupleWithObjects:@(YES),self.turple.second,self.turple.third,self.turple.fourth, nil];
        [self.sourceCommand execute:newTurple];
    }
}

@end
