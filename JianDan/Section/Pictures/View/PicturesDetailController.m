//
//  pictureDetailController.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/24.
//  Copyright © 2015年 刘献亭. All rights reserved.
//
#import "PicturesDetailController.h"
#import "Picture.h"
#import "ShareToSinaController.h"
#import "BaseNavigationController.h"
#import "VoteViewModel.h"
#import "CommentController.h"
#import "WidthFixImageView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "VoteViewModel.h"
#import "TMCache.h"
#import "NSString+Date.h"
#import "UIImageView+UIProgressForSDWebImage.h"
#import "UIImage+GIF.h"
#import "PictureFrame.h"
#import "UIColor+Additions.h"

@interface PicturesDetailController () <UIScrollViewDelegate>
@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(weak, nonatomic) IBOutlet UIButton *buttonBack;
@property(weak, nonatomic) IBOutlet UIButton *buttonShare;
@property(weak, nonatomic) IBOutlet UIButton *buttonOO;
@property(weak, nonatomic) IBOutlet UIButton *buttonXX;
@property(weak, nonatomic) IBOutlet UIButton *buttonDownload;
@property(weak, nonatomic) IBOutlet WidthFixImageView *imageViewDetail;
@property(weak, nonatomic) IBOutlet UIButton *buttonChat;

@property(weak, nonatomic) IBOutlet UIView *topView;
@property(weak, nonatomic) IBOutlet UIView *bottomView;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTop;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottom;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *constraintImageHeight;
@property(nonatomic) CGFloat lastZoomScale;
@end

@implementation PicturesDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBarHidden = YES;
    self.statusBarStyle = UIStatusBarStyleLightContent;
    [self initClick];
    Picture *picture = (Picture *) self.sendObject;
    NSString * imageURL = picture.picUrl;
    if (!imageURL)return;

     UIImage *placeHoler=[UIColorFromRGB(0xDDDDDD) createPlaceholderWithSize:picture.picFrame.pictureSize];
    self.imageViewDetail.image = placeHoler;
    self.imageViewDetail.frame = picture.picFrame.pictureFrame;
    [self adjustLocation:YES];

    //gif
    if ([imageURL hasSuffix:@".gif"]) {
        [[TMCache sharedCache] objectForKey:imageURL block:^(TMCache *cache, NSString *key, id object) {
            if (object) {
                UIImage * image =object;
                if ([object isKindOfClass:[NSData class]]) {
                    image = [UIImage sd_animatedGIFWithData:object];
                }
                self.imageViewDetail.image = image;
                [self adjustLocation:NO];
            } else {
                [self.imageViewDetail setGIFImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:placeHoler options:SDWebImageDownloaderLowPriority completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                    if (image && finished) {
                        if ([imageURL hasSuffix:@".gif"]) {
                            [self adjustLocation:NO];
                        }
                    }
                } usingProgressViewStyle:UIProgressViewStyleDefault];
            }
        }];
        return;
    }

    //普通图片
    [self.imageViewDetail setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:placeHoler completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            [self adjustLocation:NO];
        }
    }              usingProgressViewStyle:UIProgressViewStyleDefault];
}

- (void)initClick {
    Picture *picture = (Picture *) self.sendObject;
    if (!picture.picUrl)return;
    NSString * imageURL = picture.picUrl;
    //分享图片和内容
    WS(ws)
    [[self.buttonShare rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSString * content = [picture.text_content stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        RACTuple *turple = [RACTuple tupleWithObjects:imageURL, [NSString stringWithFormat:@"%@（来自 @煎蛋网）", content], nil];
        [ws presentViewController:[ShareToSinaController class] object:turple];
    }];
    //返回
    [[self.buttonBack rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [ws BackClick];
    }];
    //vote
    [self.buttonOO setTitle:[NSString stringWithKey:"OO " value:(int) picture.vote_positive] forState:UIControlStateNormal];
    [self.buttonXX setTitle:[NSString stringWithKey:"XX " value:(int) picture.vote_negative] forState:UIControlStateNormal];
    [[self.buttonOO rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [VoteViewModel voteWithOption:OO vote:(id <Vote>) picture button:x];
    }];
    [[self.buttonXX rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [VoteViewModel voteWithOption:XX vote:(id <Vote>) picture button:x];
    }];
    //下载图片
    [[self.buttonDownload rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        BOOL isGIF = [imageURL hasSuffix:@".gif"];
        if (isGIF) {
            NSData *data = [[TMCache sharedCache] objectForKey:imageURL];
            ALAssetsLibrary *assetsLib = [ALAssetsLibrary new];
            [assetsLib writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                [self imageSavedToPhotosAlbum:nil didFinishSavingWithError:error contextInfo:nil];
            }];
        } else {
            UIImageWriteToSavedPhotosAlbum(self.imageViewDetail.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
        }
    }];
    //查看评论
    [[self.buttonChat rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [ws pushViewController:[CommentController class] object:picture.post_id];
    }];
    //隐藏显示按钮
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideOrShowTopView)];
    [self.scrollView addGestureRecognizer:gesture];
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString * message = @"成功保存到相册";
    if (error.code == -3310) {
        message = @"设置-隐私-照片 中打开应用程序访问权限";
    } else if (error) {
        message = error.userInfo[NSLocalizedDescriptionKey];
    }

    [[ToastHelper sharedToastHelper] toast:message];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self hideOrShowTopView];
    self.scrollView.delegate = self;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self updateConstraints];
}

- (void)adjustLocation:(BOOL)isPlaceHolder {
    dispatch_main_async_safe(^{
        Picture *picture = (Picture *) self.sendObject;
        CGSize oldSize = picture.picSize;
        CGFloat ratio = (SCREEN_WIDTH) / oldSize.width;
        NSInteger mHeight = oldSize.height * ratio;

        if (!isPlaceHolder) {
            ratio = (SCREEN_WIDTH) / self.imageViewDetail.image.size.width;
            mHeight = self.imageViewDetail.image.size.height * ratio;
        }

        float topPadding = (SCREEN_HEIGHT - mHeight) / 2;
        if (topPadding < 0) topPadding = 0;
        self.constraintTop.constant = topPadding;
        self.constraintImageHeight.constant = mHeight;

        [self.view layoutIfNeeded];
    });
}

- (void)updateConstraints {
    Picture *picture = (Picture *) self.sendObject;
    float vPadding = (SCREEN_HEIGHT - self.scrollView.zoomScale * picture.picFrame.pictureSize.height) / 2;
    if (vPadding < 0) vPadding = 0;
    self.constraintTop.constant = vPadding;
    [self.view layoutIfNeeded];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageViewDetail;
}

- (void)hideOrShowTopView {
    NSInteger alpha = self.topView.alpha ? 0 : 1;
    WS(ws)
    [UIView animateWithDuration:0.5f animations:^{
        ws.topView.alpha = alpha;
        ws.bottomView.alpha = alpha;
    }];
}
@end
