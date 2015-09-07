//
//  MainController.m
//  JianDan
//
//  Created by 刘献亭 on 15/8/28.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "FreshNewsController.h"
#import "UIViewController+MMDrawerController.h"
#import "FreshNewsViewModel.h"
#import "FreshNewsCell.h"
#import "MJRefresh.h"

@implementation FreshNewsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mm_drawerController.title = @"新鲜事";
    [self bindingViewModel];
}

- (void)bindingViewModel {
    FreshNewsViewModel *freshViewModel = [FreshNewsViewModel new];
    //列表绑定数据
    CETableViewBindingHelper *helper = [CETableViewBindingHelper bindingHelperForTableView:self.tableView sourceSignal:[[freshViewModel.freshNewsCommand executionSignals] switchToLatest] selectionCommand:nil customCellClass:[FreshNewsCell class]];
    helper.delegate = freshViewModel;
    //执行完关闭下拉刷新
    [freshViewModel.freshNewsCommand.executing subscribeNext:^(id x) {
        if (self.tableView.header.isRefreshing&&![x boolValue]) {
            [self.tableView.header endRefreshing];
        }
    }];
    //标题栏上的加载指示器
    RAC([UIApplication sharedApplication],networkActivityIndicatorVisible)=freshViewModel.freshNewsCommand.executing;
    
    //设置下拉刷新
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [freshViewModel.freshNewsCommand execute:@(NO)];
    }];
    [self.tableView.header beginRefreshing];
}


@end
