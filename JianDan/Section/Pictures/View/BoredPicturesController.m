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
#import "PictureCell.h"
#import "TMCache.h"
#import "PictureFrame.h"
#import "UIImage+Scale.h"

@interface BoredPicturesController()<SDWebImageManagerDelegate>

@property(strong,nonatomic) MainViewModel *viewModel;

@property(strong,nonatomic) CETableViewBindingHelper *helper;

@property(strong,nonatomic) NSString *tableName;

@property(strong,nonatomic) NSString *currentTitle;

@property(strong,nonatomic) NSString *url;

@property (strong,nonatomic) RACCommand *selectCommand;

@property (assign,nonatomic) Class cellClass;

@property (assign,nonatomic) NSInteger estimatedRowHeight;

@end

@implementation BoredPicturesController

- (instancetype)initWithControllerType:(ControllerType)controllerType
{
    self = [super init];
    if (self) {
        self.currentTitle=@"无聊图";
        self.tableName=@"BoredPicture";
        self.url=BoredPicturesUrl;
        self.estimatedRowHeight=350;
        if (controllerType==controllerTypeSisterPictures) {
            self.currentTitle=@"妹子图";
            self.tableName=@"SisterPicture";
             self.url=SisterPicturesUrl;
            self.estimatedRowHeight=500;
        }else if(controllerType==controllerTypeJoke){
            self.currentTitle=@"段子";
            self.tableName=@"Joke";
             self.url=JokeUrl;
            self.estimatedRowHeight=150;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewModel = [MainViewModel new];
    
    RACSignal *sourceSignal=[[self.viewModel.sourceCommand executionSignals] switchToLatest];

    self.helper = [CETableViewBindingHelper bindingHelperForTableView:self.tableView sourceSignal:sourceSignal selectionCommand:self.selectCommand templateCellClass:[PictureCell class]];
    self.helper.delegate=self;
    self.tableView.backgroundColor=[UIColor lightGrayColor];
    
    RACTuple *turple=[RACTuple tupleWithObjects:@(NO),@"comments",[BoredPictures class], self.url,self.tableName, nil];
    
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
        [self.viewModel.sourceCommand execute:turple];
    }];
    
    //设置上拉加载更多
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self.viewModel loadNextPageData];
    }];
    
    //开始获取数据
    [self.tableView.header beginRefreshing];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return [[self.helper.data[indexPath.row] picFrame] cellHeight];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.mm_drawerController.title=self.currentTitle;
    [SDWebImageManager sharedManager].delegate=self;
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

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SDWebImageManager sharedManager].delegate=nil;
}

- (UIImage *)imageManager:(SDWebImageManager *)imageManager transformDownloadedImage:(UIImage *)image withURL:(NSURL *)imageURL{
     CGSize itemSize = [PictureFrame scaleSizeWithMaxHeight:image.size];
     image=[image scaleImageToSize:itemSize];
    if (itemSize.height>SCREEN_HEIGHT) {
        [[TMCache sharedCache] setObject:[image copy] forKey:imageURL.absoluteString];//存储长图片
        image=[image getImageFromImageWithRect:CGRectMake(0, 0, kContentWidth, SCREEN_HEIGHT)];
    }
    return image;
}



@end
