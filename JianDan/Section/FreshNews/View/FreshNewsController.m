//
//  MainController.m
//  JianDan
//
//  Created by 刘献亭 on 15/8/28.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "FreshNewsController.h"
#import "UIViewController+MMDrawerController.h"
#import "MainViewModel.h"
#import "FreshNewsCell.h"
#import "MJRefresh.h"
#import "FreshNews.h"
#import "FreshNewsDetailController.h"
@interface FreshNewsController()<UITableViewDelegate>

@property(strong,nonatomic) MainViewModel *viewModel;
@property(strong,nonatomic) RACTuple *turple;
@property(strong,nonatomic) CETableViewBindingHelper *helper;

@end

@implementation FreshNewsController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindingViewModel];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.mm_drawerController.title = @"新鲜事";
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

- (void)bindingViewModel {
    self.turple=[RACTuple tupleWithObjects:@(NO),@"posts",[FreshNews class],freshNewUrl, nil];
    self.viewModel = [MainViewModel new];
    //数据源信号
    RACSignal *sourceSignal=[[self.viewModel.sourceCommand executionSignals] switchToLatest];
    
    RACCommand *selectionCommand=[[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *turple) {
        RACTuple *sendTurple=[RACTuple tupleWithObjects:self.helper.data,@([(NSIndexPath *)turple.second row]), nil];
        FreshNewsDetailController *detailController=[FreshNewsDetailController new];
        detailController.sendObject=sendTurple;
        [self.mm_drawerController.navigationController pushViewController:detailController animated:YES];
        return [RACSignal empty];
    }];
    //列表绑定数据
    self.helper = [CETableViewBindingHelper bindingHelperForTableView:self.tableView sourceSignal:sourceSignal selectionCommand:selectionCommand customCellClass:[FreshNewsCell class]];
    self.helper.scrollViewDelegate=self.viewModel;
    
    //执行完关闭下拉刷新
    @weakify(self)
    [self.viewModel.sourceCommand.executing subscribeNext:^(id x) {
        @strongify(self)
         [UIApplication sharedApplication].networkActivityIndicatorVisible=[x boolValue];
        if (self.tableView.header.isRefreshing&&![x boolValue]) {
            [self.tableView.header endRefreshing];
        }
    }];
    
    [self.viewModel.sourceCommand.errors subscribeNext:^(id x) {
        [[ToastHelper sharedToastHelper] toast:[AFNetWorkUtils handleErrorMessage:x]];
    }];
    
    //设置下拉刷新
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self.viewModel.sourceCommand execute:self.turple];
    }];
    [self.tableView.header beginRefreshing];
}

@end
