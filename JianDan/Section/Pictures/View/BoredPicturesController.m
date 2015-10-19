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
#import "PictureFrame.h"

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

    self.helper = [CETableViewBindingHelper bindingHelperForTableView:self.tableView sourceSignal:sourceSignal selectionCommand:nil templateCellClass:[PictureCell class]];
    self.helper.delegate=self;
    self.tableView.backgroundColor=[UIColor lightGrayColor];
    
    RACTuple *turple=[RACTuple tupleWithObjects:@(NO),@"comments",[BoredPictures class], self.url,self.tableName, nil];
    
    [self.viewModel.sourceCommand execute:turple];
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
    CGFloat ratio = kWidth/ image.size.width;
    NSInteger mHeight = image.size.height * ratio;
    CGSize itemSize = CGSizeMake(kWidth, mHeight);
    
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, [UIScreen mainScreen].scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [image drawInRect:imageRect];
    UIImage  *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
