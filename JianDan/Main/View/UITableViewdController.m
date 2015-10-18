//
//  UITableViewController.m
//  JianDan
//
//  Created by 刘献亭 on 15/10/17.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "UITableViewdController.h"
#import "MainViewModel.h"
#import "BoredPictures.h"
#import "BoredPictursCell.h"
#import "CEReactiveView.h"
#import "UITableView+FDTemplateLayoutCell.h"

@interface UITableViewdController ()

@property(strong,nonatomic) NSArray *data;

@property(strong,nonatomic) CETableViewBindingHelper *helper;

@end

@implementation UITableViewdController

- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *nib=[UINib nibWithNibName:@"BoredPictursCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"BoredPictursCell"];
    
    MainViewModel *viewModel = [MainViewModel new];
    [[[viewModel.sourceCommand executionSignals] switchToLatest] subscribeNext:^(id x) {
        self.data=x;
        [self.tableView reloadData];
    }];
    self.tableView.estimatedRowHeight=200;
    //数据源信号
    RACTuple *turple=[RACTuple tupleWithObjects:@(NO),@"comments",[BoredPictures class], JokeUrl,@"jokes", nil];
    
//   self.helper=[CETableViewBindingHelper bindingHelperForTableView:self.tableView sourceSignal:[ selectionCommand:nil customCellClass:[BoredPictursCell class]];
//    self.helper.isDynamicHeight=YES;
    
    [viewModel.sourceCommand execute:turple];
    

}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<CEReactiveView> cell = [tableView dequeueReusableCellWithIdentifier:@"BoredPictursCell" forIndexPath:indexPath];
    
    [cell bindViewModel:self.data[indexPath.row] forIndexPath:indexPath];
    
    return (UITableViewCell *)cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    TICK
//    BoredPictures *boredComment=self.data[indexPath.row];
//    CGFloat height=[tableView fd_heightForCellWithIdentifier:@"BoredPictursCell" cacheByKey:boredComment.idStr configuration:^(id<CEReactiveView> cell) {
//        [cell bindViewModel:boredComment forIndexPath:indexPath];
//    }];
//    TOCK
    return  UITableViewAutomaticDimension;
}


@end
