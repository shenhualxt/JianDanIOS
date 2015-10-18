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
#import "NSString+Date.h"

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

@property (assign,nonatomic)  BOOL drawed;

@end

@implementation BoredPictursCell

-(void)awakeFromNib{
    self.placeholder=[UIImage imageNamed:@"ic_loading_large"];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Fix the bug in iOS7 - initial constraints warning
    self.contentView.bounds = [UIScreen mainScreen].bounds;
}

-(void)bindViewModel:(BoredPictures *)boredPictures forIndexPath:(NSIndexPath *)indexPath{
    //1、设置出图片以外的数据
    self.labelUserName.text=boredPictures.comment_author;
    self.labelTime.text=boredPictures.deltaToNow;
    self.labelContent.text=boredPictures.text_content;
    [self.buttonChat setTitle:boredPictures.comment_count forState:UIControlStateNormal];
    [self.buttonOO setTitle:[NSString stringWithKey:"OO " value:(int)boredPictures.vote_positive] forState:UIControlStateNormal];
    [self.buttonXX setTitle:[NSString stringWithKey:"XX " value:(int)boredPictures.vote_negative] forState:UIControlStateNormal];
    //2、cell中按钮的点击事件
    [self initClick:boredPictures];
    //3、设置ImageView初始大小
    if (!boredPictures.picUrl) return;//段子（没有图片）
    self.picSize=boredPictures.picSize;
    [self.imagePicture updateIntrinsicContentSize:self.picSize withMaxHeight:YES];
    [self.imagePicture setImageWithURL:[self getImageURL:boredPictures] placeholderImage:self.placeholder options:SDWebImageHighPriority usingProgressViewStyle:UIProgressViewStyleDefault];
}

-(void)clear{
    if (!self.imagePicture.hidden) {
        [self.imagePicture sd_cancelCurrentImageLoad];
    }
}

-(void)initClick:(BoredPictures *)boredPictures{
    //vote
    [[[self.buttonOO rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id x) {
        [VoteViewModel voteWithOption:OO vote:(id<Vote>)boredPictures button:x];
    }];
    [[[self.buttonXX rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id x) {
        [VoteViewModel voteWithOption:XX vote:(id<Vote>)boredPictures button:x];
    }];
    
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
}

-(NSURL *)getImageURL:(BoredPictures *)boredPictures{
    NSString *imageURL=boredPictures.thumnailGiFUrl;
    if (imageURL) {
        self.imageGIF.hidden=NO;
    }else{
        self.imageGIF.hidden=YES;
        imageURL=boredPictures.picUrl;
    }
    return [NSURL URLWithString:imageURL];
}

@end
