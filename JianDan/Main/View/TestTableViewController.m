//
//  TestTableViewController.m
//  JianDan
//
//  Created by 刘献亭 on 15/10/19.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "TestTableViewController.h"
#import "MainViewModel.h"
#import "BoredPictures.h"
#import "PictureCell.h"

@interface TestTableViewController ()

@property(strong,nonatomic) NSMutableArray *datas;

@end

@implementation TestTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[PictureCell class] forCellReuseIdentifier:@"PictureCell"];
    
    MainViewModel *viewModel = [MainViewModel new];
    //数据源信号
    RACSignal *sourceSignal=[[viewModel.sourceCommand executionSignals] switchToLatest];
    
    [sourceSignal subscribeNext:^(id x) {
        _datas=x;
        [self.tableView reloadData];
    }];
    
    RACTuple *turple=[RACTuple tupleWithObjects:@(NO),@"comments",[BoredPictures class], SisterPicturesUrl,@"SisterPicturesUrl", nil];
    
    //列表绑定数据
    self.tableView.panGestureRecognizer.delaysTouchesBegan = self.tableView.delaysContentTouches;
    
//    self.helper = [CETableViewBindingHelper bindingHelperForTableView:self.tableView sourceSignal:sourceSignal selectionCommand:self.selectCommand customCellClass:self.cellClass];
    
    [viewModel.sourceCommand execute:turple];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<CEReactiveView> cell = [tableView dequeueReusableCellWithIdentifier:@"PictureCell" forIndexPath:indexPath];
    [cell bindViewModel:self.datas[indexPath.row] forIndexPath:indexPath];
    return (PictureCell *)cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height=[self.datas[indexPath.row] cellHeight];
    NSLog(@"heightForRowAtIndexPath:%f",height);
    return height;
}


@end
