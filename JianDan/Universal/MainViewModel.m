//
//  FreshNewsViewModel.m
//  JianDan
/**
 * 缓存逻辑
 * 如果没有网络：则从缓存的数据库中分页取出
 * 如果有网络：则取出缓存数据，再从网络获取，并保存到数据库中
 */
//  Created by 刘献亭 on 15/8/29.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "MainViewModel.h"
#import "CacheTools.h"
#import "Picture.h"
#import "BLImageSize.h"
#import "NSString+Additions.h"
#import "PictureFrame.h"

#define SIZE_FONT_CONTENT 17

//数据库取出数据时，按时间排序
static NSString *_sortArgument = @"date";

@interface MainViewModel ()

//执行获取数据的Command
@property(nonatomic, strong) RACCommand *sourceCommand;
//获取的数据
@property(nonatomic, strong) NSMutableArray *sourceArray;
//当前页
@property(nonatomic, assign) int currentPage;
//加载的是否是缓存
@property(nonatomic, assign) BOOL loadFromDB;

@property(nonatomic, assign) BOOL isLoading;
//是否是下拉加载更多(为了通用性，参数多了点)
@property(nonatomic, assign) BOOL isLoadMore;
//表名
@property(nonatomic, strong) NSString *tableName;
//模型
@property(nonatomic, assign) Class modelClass;
//接口地址
@property(strong, nonatomic) NSString *url;
//最终数据对应的key
@property(strong, nonatomic) NSString *modelArgument;

@property(assign,nonatomic) CGFloat lastOffsetY;

@end

@implementation MainViewModel

INITWITHSETUP

- (void)setUp {
    self.currentPage = 1;
    self.sourceArray = [NSMutableArray array];
    @weakify(self)
    self.sourceCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *turple) {
        @strongify(self)
        self.isLoadMore = [turple.first boolValue];
        self.modelArgument = turple.second;
        self.modelClass = turple.third;
        self.url = turple.fourth;
        self.tableName = turple.fifth;

        int page = 1;
        if (self.isLoadMore) {
            page = ++self.currentPage;
        }
        //数据源信号
        RACSignal *dbSignal = [self requestFromDBSignal:page];
        RACSignal *netSignal = [[self requestFromNetSignal:page] map:^id(NSMutableArray *array) {
            return [self handleResult:array];
        }];

        //1、没有网络 ----只加载缓存数据
        BOOL isNoNet = [AFNetWorkUtils sharedAFNetWorkUtils].netType == NONet;
        if (isNoNet) {
            self.loadFromDB = YES;
            return dbSignal;
        }
        //2、有网络时第一次加载 先加载缓存，后加载服务器数据
        BOOL isFirstLoad = page == 1 && !self.isLoadMore && !self.sourceArray.count && !self.loadFromDB;
        if (isFirstLoad) {
            self.loadFromDB = YES;
            return [RACSignal merge:@[dbSignal, netSignal]];
        }
        
        //3、网络获取数据--- 上拉刷新，或者上拉加载更多
        self.loadFromDB = NO;
        return netSignal;
    }];
    
    RAC(self, isLoading)=self.sourceCommand.executing;
}

/**
 *  获取服务器数据
 *
 *  @param page 分页加载的当前页
 *
 *  @return 结果数据
 */
- (RACSignal *)requestFromNetSignal:(int)page {
    RACSignal *signal = [self getObjectArraySignal:page];

    //新鲜事，无需下载图片大小和获取评论数
    if ([self.url isEqualToString:freshNewUrl]) {
        return signal;
    }

    @weakify(self)
//    signal = [signal flattenMap:^RACStream *(NSMutableArray *resultArray) {
//        @strongify(self)
//        return [self getCommentCountsSignal:resultArray];
//    }];

    //段子 无需下载图片大小
    if ([self.url isEqualToString:JokeUrl] || [self.url isEqualToString:littleMovieUrl]) {
        return signal;
    }

    //都需要
    return [signal flattenMap:^RACStream *(NSMutableArray *resultArray) {
        @strongify(self)
        return [self downloadImageSize:resultArray];
    }];


}

/**
 *  转成模型
 */
- (RACSignal *)getObjectArraySignal:(int)page {
    NSString * url = [NSString stringWithFormat:@"%@%d", self.url, page];

    @weakify(self)
    return [[[[[[AFNetWorkUtils racGETWthURL:url] filter:^BOOL(NSDictionary *result) {
        return [result isKindOfClass:[NSDictionary class]] && result;//保证结果不为空
    }] map:^id(NSDictionary *result) {
        return [result objectForKey:self.modelArgument];//获取字典数组
    }] filter:^BOOL(NSMutableArray *dicArray) {
        return [dicArray isKindOfClass:[NSArray class]] && dicArray.count;//保证数组不为空
    }] map:^id(NSMutableArray *dicArray) {
        @strongify(self)
        return [self.modelClass objectArrayWithKeyValuesArray:dicArray];//字典转模型
    }] doError:^(NSError *error) {
        @strongify(self)
        if (self.isLoadMore) {
            self.currentPage--;
        }
    }];
}

/**
 *  异步保存到数据库
 */
- (NSMutableArray *)handleResult:(NSMutableArray *)array {
    if (![self.url isEqualToString:freshNewUrl] && ![self.url isEqualToString:littleMovieUrl]) {
        //计算frame
        [array enumerateObjectsUsingBlock:^(Picture *_Nonnull picture, NSUInteger idx, BOOL *_Nonnull stop) {
            PictureFrame *pictureFrame = [PictureFrame new];
            pictureFrame.pictureSize = picture.picSize;
            //计算cell高度
            pictureFrame.pictures = picture;
            picture.picFrame = pictureFrame;
        }];
    }

    //1，第一次加载数据 或者先前加载的是缓存的数据
    if (![self.sourceArray count] || self.loadFromDB) {
        return [self firstLoad:array];
    }
    //2，上拉加载更多
    if (self.isLoadMore) {
        return [self pullUpLoadMore:array];
    }
    //3，下拉加载更多
    return [self pullDownLoadMore:array];
}

/**
 *  获取评论数量（除了新鲜事）
 */
- (RACSignal *)getCommentCountsSignal:(NSMutableArray *)array {
    NSMutableString *param = [NSMutableString string];
    for (Picture *pictures in array) {
        [param appendFormat:@"comment-%@,", pictures.post_id];
    }
    return [[AFNetWorkUtils racGETWthURL:appendString(commentCountUrl, param)] map:^id(NSDictionary *resultDic) {
        NSDictionary * response = [resultDic objectForKey:@"response"];
        if (![response isKindOfClass:[NSDictionary class]]) {
            LogBlue(@"获取评论数量失败");
            return array;
        }

        [array enumerateObjectsUsingBlock:^(Picture *_Nonnull pictures, NSUInteger idx, BOOL *_Nonnull stop) {
            NSString * key = appendString(@"comment-", pictures.post_id);
            NSDictionary * result = [response objectForKey:key];
            pictures.comment_count = ConvertToString([result objectForKey:@"comments"]);
        }];
        return array;
    }];
}

/**
 *  获取缓存数据
 */
- (RACSignal *)requestFromDBSignal:(int)page {
    @weakify(self)
    return [[[CacheTools sharedCacheTools] racRead:self.modelClass page:page tableName:self.tableName] map:^id(NSArray *array) {
        @strongify(self)
        if (!array || ![array count]) {
            return self.sourceArray;
        }
        [self.sourceArray addObjectsFromArray:array];
        return self.sourceArray;
    }];
}

/**
 *  第一次加载
 */
- (NSMutableArray *)firstLoad:(NSMutableArray *)array {
    self.sourceArray = array;

    [self save:array];
    return self.sourceArray;
}

/**
 *  上拉加载
 */
- (NSMutableArray *)pullUpLoadMore:(NSMutableArray *)array {
    [self.sourceArray addObjectsFromArray:array];
    [self save:array];
    return self.sourceArray;
}

/**
 *  下拉刷新
 */
- (NSMutableArray *)pullDownLoadMore:(NSMutableArray *)array {
    NSInteger prevoiusCount = self.sourceArray.count;
    [array enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        if ([object isEqual:self.sourceArray[0]]) {
            *stop = YES;
            NSArray * subArray = [array subarrayWithRange:NSMakeRange(0, idx)];
            if (!subArray || [subArray count]) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [subArray count])];
                [self.sourceArray insertObjects:subArray atIndexes:indexSet];
                [self save:[subArray mutableCopy]];
            }
        }
    }];
    NSInteger offset = self.sourceArray.count - prevoiusCount;
    [[ToastHelper sharedToastHelper] toast:offset ? [NSString stringWithFormat:@"%d条新数据", (int) offset] : @"没有新数据"];
    return self.sourceArray;
}

/**
 *  下载图片大小（除了新鲜事）并缓存到数据库
 */
- (void)save:(NSMutableArray *)array {
    [[CacheTools sharedCacheTools] save:array sortArgument:_sortArgument tableName:self.tableName];
}

/**
 *  下载图片大小
 */
- (RACSignal *)downloadImageSize:(NSMutableArray *)array {
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:array];
        dispatch_group_t group = dispatch_group_create();
        [tempArray enumerateObjectsUsingBlock:^(Picture *_Nonnull pictures, NSUInteger idx, BOOL *_Nonnull stop) {
            if (!pictures.picUrl) return;
            dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                pictures.picSize = [BLImageSize downloadImageSizeWithURL:pictures.thumnailGiFUrl ?: pictures.picUrl];
                if (pictures.picSize.height==0) {
                    //默认值
                    pictures.picSize=CGSizeMake(200, 200);
                }
            });

        }];
        //等group中所有的任务都执行完了，再执行其他操作
        dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [subscriber sendNext:tempArray];
            [subscriber sendCompleted];
        });
        return nil;
    }];
}

#pragma mark -scrollView delegate

//滑到底部，自动加载新的数据
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y-self.lastOffsetY>2*SCREEN_HEIGHT) {
         [[SDImageCache sharedImageCache] clearMemory];
         self.lastOffsetY=scrollView.contentOffset.y;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat distanceFromBottom = scrollView.contentSize.height - scrollView.contentOffset.y;
    if (distanceFromBottom < 12 * SCREEN_HEIGHT && [self.sourceArray count] && !self.isLoading) {
        [self loadNextPageData];
    }
}

/**
 *  加载下一页的数据
 */
- (void)loadNextPageData {
    RACTuple *newTurple = RACTuplePack(@(YES), self.modelArgument, self.modelClass, self.url, self.tableName);
    [self.sourceCommand execute:newTurple];
}

@end
