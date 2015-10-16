//
//  BoredPicturesController.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/21.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "BoredPicturesController.h"
#import "BoredPictures.h"
#import "BoredPictursCell.h"
#import "UIViewController+MMDrawerController.h"
#import "BoredPicturesDetailController.h"
#import "MJRefresh.h"
#import "MainViewModel.h"

@interface BoredPicturesController()

@property(strong,nonatomic) MainViewModel *viewModel;

@property(strong,nonatomic) CETableViewBindingHelper *helper;

@property(strong,nonatomic) RACTuple *turple;

@property(strong,nonatomic) NSString *tableName;

@property(strong,nonatomic) NSString *currentTitle;

@property(strong,nonatomic) NSString *url;

@property (strong,nonatomic) RACCommand *selectCommand;

@property (assign,nonatomic) Class cellClass;

@end

@implementation BoredPicturesController

- (instancetype)initWithControllerType:(ControllerType)controllerType
{
    self = [super init];
    if (self) {
        self.currentTitle=@"无聊图";
        self.tableName=@"BoredPicture";
        self.url=BoredPicturesUrl;
        if (controllerType==controllerTypeSisterPictures) {
            self.currentTitle=@"妹子图";
            self.tableName=@"SisterPicture";
             self.url=SisterPicturesUrl;
        }else if(controllerType==controllerTypeJoke){
            self.currentTitle=@"段子";
            self.tableName=@"Joke";
             self.url=JokeUrl;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    父类会进行self.helper viewModel初始化等操作，
//    [self bindingViewModel];
    
    self.tableView.estimatedRowHeight=300;
    //一句代码解决动态高度问题（前提cell 设置好约束）
    self.helper.isDynamicHeight=YES;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.mm_drawerController.title=self.currentTitle;
}

-(Class)cellClass{
    if (!_cellClass) {
        _cellClass=[BoredPictursCell class];
    }
    return _cellClass;
}

-(RACTuple *)turple{
    if (!_turple) {
        _turple=[RACTuple tupleWithObjects:@(NO),@"comments",[BoredPictures class], self.url,self.tableName, nil];
    }
    return _turple;
}

-(RACCommand *)selectCommand{
    if (!_selectCommand) {
        if(![self.url isEqualToString:JokeUrl]){
            _selectCommand=[[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *turple) {
                BoredPicturesDetailController *vc=[BoredPicturesDetailController controllerWithSendObject:(BoredPictures *)turple.first];
                [self.mm_drawerController.navigationController pushViewController:vc animated:YES];
                return [RACSignal empty];
            }];
        }
    }
    return _selectCommand;
}


@end
