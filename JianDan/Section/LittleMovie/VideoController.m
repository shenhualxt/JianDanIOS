//
//  LittleMoveController.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/30.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "VideoController.h"
#import "UIViewController+MMDrawerController.h"
#import "MJRefresh.h"
#import "Picture.h"
#import "MainViewModel.h"
#import "BaseViewController.h"
#import "VideoDetailController.h"
#import "VideoCollectionCell.h"

@interface VideoController () <UICollectionViewDelegateFlowLayout>

@property(strong, nonatomic) MainViewModel *viewModel;

@property(strong, nonatomic) HRCollectionViewBindingHelper *helper;

@property(strong, nonatomic) RACTuple *turple;

@end

@implementation VideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.backgroundColor = UIColorFromRGB(0xEEEEEE);
    [self bindingViewModel];
}


- (instancetype)init {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.sectionInset = UIEdgeInsetsMake(4, 6, 4, 6);
    return [self initWithCollectionViewLayout:layout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.mm_drawerController.title = @"小视频";
    //导航栏的刷新按钮
    UIButton *btn = (UIButton *) self.mm_drawerController.navigationItem.rightBarButtonItem.customView;
    btn.rac_command = [[RACCommand alloc] initWithEnabled:[self.viewModel.sourceCommand.executing map:^id(id value) {
        return @(![value boolValue]);
    }] signalBlock:^RACSignal *(id input) {
        return [self.viewModel.sourceCommand execute:self.turple];
    }];

    //显示加载中
    [btn.rac_command.executing subscribeNext:^(id x) {
        [[ToastHelper sharedToastHelper] setSimleProgressVisiable:[x boolValue]];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UIButton *btn = (UIButton *) self.mm_drawerController.navigationItem.rightBarButtonItem.customView;
    btn.rac_command = nil;
}

- (void)bindingViewModel {
    self.viewModel = [MainViewModel new];
    self.turple = [RACTuple tupleWithObjects:@(NO), @"comments", [Picture class], littleMovieUrl, @"Video", nil];
    //数据源信号
    RACSignal *sourceSignal = [[[self.viewModel.sourceCommand executionSignals] switchToLatest] map:^id(NSMutableArray *resultArray) {
        NSArray * tempArray = [NSArray arrayWithArray:resultArray];
        for (Picture *picture in tempArray) {
            if (!picture.videos.count) {
                [resultArray removeObject:picture];
            }
        }
        return resultArray;
    }];
    self.collectionView.panGestureRecognizer.delaysTouchesBegan = self.collectionView.delaysContentTouches;
    RACCommand *selectionCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(Picture *picture) {
        VideoDetailController *vc = [VideoDetailController new];
        vc.sendObject = picture.text_content;
        [self.mm_drawerController.navigationController pushViewController:vc animated:YES];
        return [RACSignal empty];
    }];

    //列表绑定数据
    self.helper = [HRCollectionViewBindingHelper bindWithCollectionView:self.collectionView dataSource:sourceSignal selectionCommand:selectionCommand templateCellClass:[VideoCollectionCell class]];
    self.helper.delegate = self;

    //执行完关闭下拉刷新
    @weakify(self)
    [self.viewModel.sourceCommand.executing subscribeNext:^(id x) {
        @strongify(self)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = [x boolValue];
        if (self.collectionView.header.isRefreshing && ![x boolValue]) {
            [self.collectionView.header endRefreshing];
            [self.collectionView.footer endRefreshing];
        }
    }];

    //错误处理
    [self.viewModel.sourceCommand.errors subscribeNext:^(id x) {
        [[ToastHelper sharedToastHelper] toast:[NSErrorHelper handleErrorMessage:x]];
    }];

    //设置下拉刷新
    self.collectionView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self.viewModel.sourceCommand execute:self.turple];
    }];
    
    [self.collectionView.header beginRefreshing];
    
    //设置上拉加载更多
    self.collectionView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self.viewModel loadNextPageData];
    }];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((SCREEN_WIDTH - 24) / 2, 170);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.helper.disposable dispose];
}


@end
