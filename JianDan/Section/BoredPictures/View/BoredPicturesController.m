//
//  BoredPicturesController.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/21.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "BoredPicturesController.h"
#import "MainViewModel.h"
#import "BoredPictures.h"
#import "BoredPictursCell.h"
#import "MJRefresh.h"
#import "UIViewController+MMDrawerController.h"

@interface BoredPicturesController ()<UIScrollViewDelegate>

@property(strong,nonatomic) CETableViewBindingHelper *helper;

@property(strong,nonatomic) MainViewModel *viewModel;

@property(strong,nonatomic) RACTuple *turple;

@end

@implementation BoredPicturesController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindingViewModel];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.mm_drawerController.title = @"无聊图";
    //导航栏的刷新按钮
    UIButton *btn= (UIButton*)self.mm_drawerController.navigationItem.rightBarButtonItem.customView;
    btn.rac_command=[[RACCommand alloc] initWithEnabled:[self.viewModel.sourceCommand.executing map:^id(id value) {
        return @(![value boolValue]);
    }] signalBlock:^RACSignal *(id input) {
        return [self.viewModel.sourceCommand execute:self.turple];
    }];
    
    //显示加载中
    [btn.rac_command.executing subscribeNext:^(id x) {
        [[ToastHelper sharedToastHelper] setSimleProgressVisiable:[x boolValue]];
    }];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
     UIButton *btn= (UIButton*)self.mm_drawerController.navigationItem.rightBarButtonItem.customView;
     btn.rac_command=nil;
}

-(void)bindingViewModel{
    self.viewModel=[MainViewModel new];
    RACCommand *selectCommand=[[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal empty];
    }];
    self.helper=[CETableViewBindingHelper bindingHelperForTableView:self.tableView sourceSignal:[self.viewModel.sourceCommand.executionSignals switchToLatest] selectionCommand:selectCommand customCellClass:[BoredPictursCell class]];
    self.helper.isDynamicHeight=YES;
    self.helper.scrollViewDelegate=self;
    
    
    //执行完关闭下拉刷新
    @weakify(self)
    [self.viewModel.sourceCommand.executing subscribeNext:^(id x) {
        @strongify(self)
        if (self.tableView.header.isRefreshing&&![x boolValue]) {
            [self.tableView.header endRefreshing];
        }
    }];
    //标题栏上的加载指示器
    [self.viewModel.sourceCommand.executing subscribeNext:^(id x) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible=[x boolValue];
    }];
    
    //设置下拉刷新
    self.turple=[RACTuple tupleWithObjects:@(NO),@"comments",[BoredPictures class],BoredPicturesUrl, nil];
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self.viewModel.sourceCommand execute:self.turple];
    }];
    [self.tableView.header beginRefreshing];

}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[SDWebImageDownloader sharedDownloader] setSuspended:YES];
}

// table view 停止拖动了
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [[SDWebImageDownloader sharedDownloader] setSuspended:NO];
    if (!decelerate) {
        [self loadImageForOnScreenRows];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.viewModel scrollViewDidScroll:scrollView];
}

// table view 停止滚动了
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImageForOnScreenRows];
}

-(void)loadImageForOnScreenRows{
    NSArray *visiableIndexPathes = [self.tableView indexPathsForVisibleRows];
    for(NSInteger i = 0; i < [visiableIndexPathes count]; i++)
    {
        NSIndexPath *indexPath=visiableIndexPathes[i];
        BoredPictures *boredPictures=self.helper.data[indexPath.row];
        if (!boredPictures.pics.count) return;
        NSString *imageURL =boredPictures.pics[0];
        BoredPictursCell *cell=(BoredPictursCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell getCachedImageOrDownload:imageURL atIndexPath:indexPath];
    }
    
}
@end
