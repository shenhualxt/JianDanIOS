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
#import "PictureFrame.h"

@interface TestTableViewController ()<SDWebImageManagerDelegate>

@property(strong,nonatomic) NSMutableArray *datas;

@property (strong,nonatomic) CETableViewBindingHelper *helper;

@end

@implementation TestTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SDWebImageManager sharedManager].delegate=self;
    
    MainViewModel *viewModel = [MainViewModel new];
    //数据源信号
    RACSignal *sourceSignal=[[viewModel.sourceCommand executionSignals] switchToLatest];
    
    RACTuple *turple=[RACTuple tupleWithObjects:@(NO),@"comments",[BoredPictures class], SisterPicturesUrl,@"SisterPicturesUrl", nil];
    
    //列表绑定数据
    self.tableView.panGestureRecognizer.delaysTouchesBegan = self.tableView.delaysContentTouches;
    
    self.helper = [CETableViewBindingHelper bindingHelperForTableView:self.tableView sourceSignal:sourceSignal selectionCommand:nil templateCellClass:[PictureCell class]];
    self.helper.delegate=self;
    
    [viewModel.sourceCommand execute:turple];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return [[self.helper.data[indexPath.row] picFrame] cellHeight];
}


- (UIImage *)imageManager:(SDWebImageManager *)imageManager transformDownloadedImage:(UIImage *)image withURL:(NSURL *)imageURL{
    CGFloat ratio = (SCREEN_WIDTH-32)/ image.size.width;
    NSInteger mHeight = image.size.height * ratio;
    CGSize itemSize = CGSizeMake((SCREEN_WIDTH-32), mHeight);
    
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, [UIScreen mainScreen].scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [image drawInRect:imageRect];
    UIImage  *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



@end
