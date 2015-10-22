//
//  BoredPictursCell.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/19.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "PictureXibCell.h"
#import "Picture.h"
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
#import "PictureFrame.h"

@interface PictureXibCell () <CEReactiveView, SDWebImageManagerDelegate>

@property(weak, nonatomic) IBOutlet UILabel *labelUserName;
@property(weak, nonatomic) IBOutlet UIImageView *imageGIF;
@property(weak, nonatomic) IBOutlet UILabel *labelContent;
@property(weak, nonatomic) IBOutlet UIButton *buttonOO;
@property(weak, nonatomic) IBOutlet UIButton *buttonXX;
@property(weak, nonatomic) IBOutlet UIButton *buttonMore;
@property(weak, nonatomic) IBOutlet UILabel *labelTime;
@property(weak, nonatomic) IBOutlet UIButton *buttonChat;

@property(assign, nonatomic) CGSize picSize;
@property(strong, nonatomic) UIImage *placeholder;

@property(assign, nonatomic) BOOL drawed;

@end

@implementation PictureXibCell

- (void)awakeFromNib {
    self.placeholder = [UIImage imageNamed:@"ic_loading_large"];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Fix the bug in iOS7 - initial constraints warning
    self.contentView.bounds = [UIScreen mainScreen].bounds;

}

- (void)bindViewModel:(Picture *)picture forIndexPath:(NSIndexPath *)indexPath {
    //1、设置出图片以外的数据
    self.labelUserName.text = picture.comment_author;
    self.labelTime.text = picture.deltaToNow;
    self.labelContent.text = picture.text_content;
    [self.buttonChat setTitle:picture.comment_count forState:UIControlStateNormal];
    [self.buttonOO setTitle:[NSString stringWithKey:"OO " value:(int) picture.vote_positive] forState:UIControlStateNormal];
    [self.buttonXX setTitle:[NSString stringWithKey:"XX " value:(int) picture.vote_negative] forState:UIControlStateNormal];
    //2、cell中按钮的点击事件
    [self initClick:picture];
    //3、设置ImageView初始大小
    if (!picture.picUrl) return;//段子（没有图片）
    self.picSize = picture.picFrame.pictureSize;
    [self.imagePicture updateIntrinsicContentSize:self.picSize withMaxHeight:YES];
    NSString * key = [[SDWebImageManager sharedManager] cacheKeyForURL:[self getImageURL:picture]];
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:key done:^(UIImage *image, SDImageCacheType cacheType) {
        self.imagePicture.image = image ?: self.placeholder;
    }];
}

- (void)loadImage:(Picture *)picture forIndexPath:(NSIndexPath *)indexPath helper:(CETableViewBindingHelper *)helper {
    [self.imagePicture setImageWithURL:[self getImageURL:picture] placeholderImage:self.placeholder options:SDWebImageHighPriority | SDWebImageTransformAnimatedImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }           usingProgressViewStyle:UIProgressViewStyleDefault];
}

- (void)clear {
    if (!self.imagePicture.hidden) {
        [self.imagePicture sd_cancelCurrentImageLoad];
    }
}

- (void)initClick:(Picture *)picture {
    //vote
    [[[self.buttonOO rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id x) {
        [VoteViewModel voteWithOption:OO vote:(id <Vote>) picture button:x];
    }];
    [[[self.buttonXX rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id x) {
        [VoteViewModel voteWithOption:XX vote:(id <Vote>) picture button:x];
    }];

    //评论
    WS(ws)
    [[[self.buttonChat rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id x) {
        CommentController *vc = [CommentController new];
        vc.sendObject = picture.post_id;
        [[ws controller].mm_drawerController.navigationController pushViewController:vc animated:YES];
    }];

    //分享
    [[[self.buttonMore rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id x) {
        NSString * content = [picture.text_content stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        RACTuple *turple = [RACTuple tupleWithObjects:picture.picUrl, [NSString stringWithFormat:@"%@（来自 @煎蛋网）", content], nil];
        ShareToSinaController *shareToSinaController = [ShareToSinaController new];
        shareToSinaController.sendObject = turple;
        [[ws controller].mm_drawerController.navigationController pushViewController:shareToSinaController animated:YES];
    }];
}

- (NSURL *)getImageURL:(Picture *)picture {
    NSString * imageURL = picture.thumnailGiFUrl;
    if (imageURL) {
        self.imageGIF.hidden = NO;
    } else {
        self.imageGIF.hidden = YES;
        imageURL = picture.picUrl;
    }
    return [NSURL URLWithString:imageURL];
}

@end
