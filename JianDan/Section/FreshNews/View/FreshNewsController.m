//
//  MainController.m
//  JianDan
//
//  Created by 刘献亭 on 15/8/28.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "FreshNewsController.h"
#import "UIViewController+MMDrawerController.h"
#import "FreshNewsCell.h"
#import "FreshNews.h"
#import "FreshNewsDetailController.h"
#import "MJRefresh.h"
#import "MainViewModel.h"
#import "FreshNewsLittleCell.h"

@interface FreshNewsController()

//逻辑类
@property(strong,nonatomic) MainViewModel *viewModel;
//简化tableView加载帮助类
@property(strong,nonatomic) CETableViewBindingHelper *helper;
//获取数据需要的信息的包装对象
@property(strong,nonatomic) RACTuple *turple;
//cell的点击事件
@property (strong,nonatomic) RACCommand *selectCommand;
//cell class
@property (assign,nonatomic) Class cellClass;

@end

@implementation FreshNewsController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindingViewModel];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.mm_drawerController.title=@"新鲜事";
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
    //取消事件绑定
    UIButton *btn= (UIButton*)self.mm_drawerController.navigationItem.rightBarButtonItem.customView;
    btn.rac_command=nil;
}

/**
 *  视图绑定数据
 */
- (void)bindingViewModel {
    self.viewModel = [MainViewModel new];
    //数据源信号
     RACSignal *sourceSignal=[[self.viewModel.sourceCommand executionSignals] switchToLatest];
    
    //列表绑定数据
     self.tableView.panGestureRecognizer.delaysTouchesBegan = self.tableView.delaysContentTouches;
    self.helper = [CETableViewBindingHelper bindingHelperForTableView:self.tableView sourceSignal:sourceSignal selectionCommand:self.selectCommand customCellClass:self.cellClass];
    
    //滑动到底部时，自动加载新的数据
    self.helper.scrollViewDelegate=self.viewModel;
    
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

/**
 *  调用接口需要的信息（和MainViewModel约定好）
 * first :是否是加载更多
 * second:接口返回数据中，想要的数据对应的key
 * third: 模型
 * forth: 接口URL
 * fifith: 数据库表名
 *  @return 包装对象
 */
-(RACTuple *)turple{
    if (!_turple) {
        _turple=[RACTuple tupleWithObjects:@(NO),@"posts",[FreshNews class],freshNewUrl,@"FreshNews", nil];
    }
    return _turple;
}

/**
 *  @return UITableView cell 类
 */
-(Class)cellClass{
    if (!_cellClass) {
        _cellClass=[FreshNewsLittleCell class];
    }
    return _cellClass;
}

/**
 *  @return cell 的点击事件
 */
-(RACCommand *)selectCommand{
    if (!_selectCommand) {
        _selectCommand=[[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *turple) {
            RACTuple *sendTurple=[RACTuple tupleWithObjects:self.helper.data,@([(NSIndexPath *)turple.second row]), nil];
            FreshNewsDetailController *detailController=[FreshNewsDetailController new];
            detailController.sendObject=sendTurple;
            [self.mm_drawerController.navigationController pushViewController:detailController animated:YES];
            return [RACSignal empty];
        }];
    }
    
    return _selectCommand;
}


@end
