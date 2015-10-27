//
//  PicturesController.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/21.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "PicturesController.h"
#import "Picture.h"
#import "PicturesDetailController.h"
#import "UIViewController+MMDrawerController.h"
#import "PicturesDetailController.h"
#import "MJRefresh.h"
#import "MainViewModel.h"
#import "PictureCell.h"
#import "TMCache.h"
#import "PictureFrame.h"
#import "UIImage+Scale.h"

@interface PicturesController () <SDWebImageManagerDelegate>

@property(strong, nonatomic) MainViewModel *viewModel;

@property(strong, nonatomic) CETableViewBindingHelper *helper;

@property(strong, nonatomic) NSString *currentTitle;

@property(strong, nonatomic) RACTuple *turple;

@end

@implementation PicturesController

- (instancetype)initWithControllerType:(ControllerType)controllerType {
    self = [super init];
    if (self) {
        self.currentTitle = @"无聊图";
         NSString *tableName = @"BoredPicture";
         NSString *url = BoredPicturesUrl;
        if (controllerType == controllerTypeSisterPictures) {
            self.currentTitle = @"妹子图";
            tableName = @"SisterPicture";
            url = SisterPicturesUrl;
        } else if (controllerType == controllerTypeJoke) {
            self.currentTitle = @"段子";
            tableName = @"Joke";
            url = JokeUrl;
        }
        _turple = [RACTuple tupleWithObjects:@(NO), @"comments", [Picture class], url, tableName, nil];
    }
    return self;
}

#pragma mark 父类调用
- (void)bindingViewModel{
    self.viewModel = [MainViewModel new];
    
    RACSignal *sourceSignal = [[self.viewModel.sourceCommand executionSignals] switchToLatest];
    
    RACCommand *selectCommand=nil;
    if (![self.turple.fourth isEqualToString:JokeUrl]) {
        selectCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *turple) {
            PicturesDetailController *vc = [PicturesDetailController controllerWithSendObject:(Picture *) turple.first];
            [self.mm_drawerController.navigationController pushViewController:vc animated:YES];
            return [RACSignal empty];
        }];
    }

    self.tableView.panGestureRecognizer.delaysTouchesBegan = self.tableView.delaysContentTouches=NO;
    self.helper = [CETableViewBindingHelper bindingHelperForTableView:self.tableView sourceSignal:sourceSignal selectionCommand:selectCommand templateCellClass:[PictureCell class]];
    self.helper.delegate = self;
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    

    //滑动到底部时，自动加载新的数据
    self.helper.scrollViewDelegate = self.viewModel;
    
    //执行完关闭下拉刷新
    @weakify(self)
    [self.viewModel.sourceCommand.executing subscribeNext:^(id isExcuting) {
        @strongify(self)
        if (![isExcuting boolValue]) {
            [self.tableView.header endRefreshing];
            [self.tableView.footer endRefreshing];
        }
    }];
    //错误处理
    [self.viewModel.sourceCommand.errors subscribeNext:^(id x) {
        [[ToastHelper sharedToastHelper] toast:[NSErrorHelper handleErrorMessage:x]];
    }];
    //设置下拉刷新
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        [self.viewModel.sourceCommand execute:self.turple];
    }];
    
    //设置上拉加载更多
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self.viewModel loadNextPageData];
    }];
    
    //开始获取数据
    [self.tableView.header beginRefreshing];
}

#pragma mark UITableView dataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[self.helper.data[indexPath.row] picFrame] cellHeight];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.mm_drawerController.title = self.currentTitle;
    [SDWebImageManager sharedManager].delegate = self;
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SDWebImageManager sharedManager].delegate = nil;
}

- (UIImage *)imageManager:(SDWebImageManager *)imageManager transformDownloadedImage:(UIImage *)image withURL:(NSURL *)imageURL {
    //调整图片大小和控件大小一致
    CGSize itemSize = [PictureFrame scaleSizeWithoutMaxHeight:image.size];
    return [image scaleImageToSize:itemSize];
}
@end
