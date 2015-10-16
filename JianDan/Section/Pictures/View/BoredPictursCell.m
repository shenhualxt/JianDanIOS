//
//  BoredPictursCell.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/19.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "BoredPictursCell.h"
#import "BoredPictures.h"
#import "PureLayout.h"
#import "UIImage+Scale.h"
#import "UITableViewCell+TableView.h"
#import "TMCache.h"
#import "UIImage+Scale.h"
#import "ScaleImageView.h"
#import "NJKWebViewProgressView.h"
#import "AFNetWorking.h"
#import "UIImageView+UIProgressForSDWebImage.h"
#import "BLImageSize.h"
#import "VoteViewModel.h"
#import "UIViewController+MMDrawerController.h"
#import "CommentController.h"
#import "ShareToSinaController.h"

@interface BoredPictursCell()<CEReactiveView>

@property (weak, nonatomic) IBOutlet UILabel *labelUserName;
@property (weak, nonatomic) IBOutlet UIImageView *imageGIF;
@property (weak, nonatomic) IBOutlet UILabel *labelContent;
@property (weak, nonatomic) IBOutlet UIButton *buttonOO;
@property (weak, nonatomic) IBOutlet UIButton *buttonXX;
@property (weak, nonatomic) IBOutlet UIButton *buttonMore;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UIButton *buttonChat;

@property(assign,nonatomic) CGSize picSize;
@property(strong,nonatomic) UIImage *placeholder;

@end

@implementation BoredPictursCell

-(void)awakeFromNib{
    self.placeholder=[UIImage imageNamed:@"ic_loading_large"];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(void)bindViewModel:(BoredPictures *)boredPictures forIndexPath:(NSIndexPath *)indexPath{
    //设置出图片以外的数据
    self.labelUserName.text=boredPictures.comment_author;
    self.labelTime.text=boredPictures.deltaToNow;
    self.labelContent.text=boredPictures.text_content;
    [self.buttonChat setTitle:boredPictures.comment_count forState:UIControlStateNormal];
    //vote
    [VoteViewModel setVoteButtonOO:self.buttonOO buttonXX:self.buttonXX cell:self vote:boredPictures];
   
    //评论
    WS(ws)
    [[[self.buttonChat rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id x) {
        CommentController *vc=[CommentController new];
        vc.sendObject=boredPictures.post_id;
        [[ws controller].mm_drawerController.navigationController pushViewController:vc animated:YES];
    }];
   
    //分享
    [[[self.buttonMore rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id x) {
        NSString *content=[boredPictures.text_content stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        RACTuple *turple=[RACTuple tupleWithObjects:boredPictures.picUrl,[NSString stringWithFormat:@"%@（来自 @煎蛋网）",content], nil];
        ShareToSinaController *shareToSinaController=[ShareToSinaController new];
        shareToSinaController.sendObject=turple;
        [[ws controller].mm_drawerController.navigationController pushViewController:shareToSinaController animated:YES];
    }];
    
    //1，设置ImageView初始大小
    if (!boredPictures.picUrl) return;//段子（没有图片）
    self.picSize=boredPictures.picSize;
    
    [self.imagePicture updateIntrinsicContentSize:self.picSize];
 
    [self loadImage:boredPictures forIndexPath:indexPath];
}

-(void)loadImage:(BoredPictures *)boredPictures forIndexPath:(NSIndexPath *)indexPath {
    NSString *imageURL=boredPictures.picUrl;
    BOOL isGIF=[imageURL hasSuffix:@".gif"];
    if (isGIF) {
        self.imageGIF.hidden=NO;
        imageURL=[self thumbGIFURLFromURL:imageURL];
    }else{
        self.imageGIF.hidden=YES;
    }
    WS(ws)
    [self.imagePicture setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:self.placeholder options:SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        //没有获取到图片大小的情况（极少的情况，概率约等于0）
        if (!boredPictures.picSize.height) {
            boredPictures.picSize=image.size;
            dispatch_main_sync_safe(^{
                [ws.tableView reloadData];
            });
        }
    }  usingProgressViewStyle:UIProgressViewStyleDefault];
}

-(NSString *)thumbGIFURLFromURL:(NSString *)imageURL{
    imageURL=[imageURL stringByReplacingOccurrencesOfString:@"mw600" withString:@"small"];
    imageURL=[imageURL stringByReplacingOccurrencesOfString:@"mw1200" withString:@"small"];
    return [imageURL stringByReplacingOccurrencesOfString:@"large" withString:@"small"];
}

@end
