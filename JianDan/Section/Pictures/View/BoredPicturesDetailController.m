//
//  BoredPicturesDetailController.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/24.
//  Copyright © 2015年 刘献亭. All rights reserved.
//
#import "BoredPicturesDetailController.h"
#import "BoredPictures.h"
#import "ShareToSinaController.h"
#import "BaseNavigationController.h"
#import "VoteViewModel.h"
#import "CommentController.h"
#import "WidthFixImageView.h"
 #import <AssetsLibrary/AssetsLibrary.h>
#import "VoteViewModel.h"
#import "TMCache.h"
#import "UIImageView+UIProgressForSDWebImage.h"

@interface BoredPicturesDetailController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *buttonBack;
@property (weak, nonatomic) IBOutlet UIButton *buttonShare;
@property (weak, nonatomic) IBOutlet UIButton *buttonOO;
@property (weak, nonatomic) IBOutlet UIButton *buttonXX;
@property (weak, nonatomic) IBOutlet UIButton *buttonDownload;
@property (weak, nonatomic) IBOutlet WidthFixImageView *imageViewDetail;
@property (weak, nonatomic) IBOutlet UIButton *buttonChat;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottom;
@property (nonatomic) CGFloat lastZoomScale;
@end

@implementation BoredPicturesDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBarHidden=YES;
    self.statusBarStyle=UIStatusBarStyleLightContent;
    [self initClick];
    BoredPictures *boredPictures=(BoredPictures *)self.sendObject;
    if (!boredPictures.picUrl)return;
    NSString *imageURL=boredPictures.picUrl;
    [self.imageViewDetail setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"ic_loading_large"] usingProgressViewStyle:UIProgressViewStyleDefault];
}

-(void)initClick{
     BoredPictures *boredPictures=(BoredPictures *)self.sendObject;
    if (!boredPictures.picUrl)return;
    NSString *imageURL=boredPictures.picUrl;
    //分享图片和内容
    WS(ws)
    [[self.buttonShare rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSString *content=[boredPictures.text_content stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        RACTuple *turple=[RACTuple tupleWithObjects:imageURL,[NSString stringWithFormat:@"%@（来自 @煎蛋网）",content], nil];
        [ws presentViewController:[ShareToSinaController class] object:turple];
    }];
    //返回
    [[self.buttonBack rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [ws BackClick];
    }];
    //vote
    [VoteViewModel setVoteButtonOO:self.buttonOO buttonXX:self.buttonXX cell:nil vote:boredPictures];
    //下载图片
    [[self.buttonDownload rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        BOOL isGIF=[imageURL hasSuffix:@".gif"];
        if (isGIF) {
            NSData *data=[[TMCache sharedCache] objectForKey:imageURL];
            ALAssetsLibrary *assetsLib=[ALAssetsLibrary new];
            [assetsLib writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                [self imageSavedToPhotosAlbum:nil didFinishSavingWithError:error contextInfo:nil];
            }];
        }else{
             UIImageWriteToSavedPhotosAlbum(self.imageViewDetail.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
        }
    }];
    //查看评论
    [[self.buttonChat rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [ws pushViewController:[CommentController class] object:boredPictures.post_id];
    }];
    //隐藏显示按钮
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideOrShowTopView)];
    [self.scrollView addGestureRecognizer:gesture];
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"成功保存到相册";
    if (error)
        message = [error description];
    [[ToastHelper sharedToastHelper] toast:message];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self adjustLocation];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self hideOrShowTopView];
    self.scrollView.delegate=self;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    [self updateViewConstraints];
}

-(void)adjustLocation{
    float imageHeight = self.imageViewDetail.image.size.height;
    float imageWidth = self.imageViewDetail.image.size.width;
    CGFloat ratio = SCREEN_WIDTH/imageWidth;
    CGFloat mHeight =imageHeight*ratio;
    float topPadding = (SCREEN_HEIGHT - mHeight) / 2;
     if (topPadding < 0) topPadding = 0;
    self.constraintTop.constant=topPadding;
    self.constraintBottom.constant=topPadding;
    [self.view layoutIfNeeded];
}

-(void)updateConstraints{
    float imageHeight = self.imageViewDetail.image.size.height;
    float vPadding = (SCREEN_HEIGHT - self.scrollView.zoomScale * imageHeight) / 2;
    if (vPadding < 0) vPadding = 0;
    self.constraintTop.constant = vPadding;
    self.constraintBottom.constant = vPadding;
    [self.view layoutIfNeeded];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageViewDetail;
}

-(void)hideOrShowTopView{
    NSInteger alpha=self.topView.alpha?0:1;
    WS(ws)
    [UIView animateWithDuration:0.5f animations:^{
        ws.topView.alpha=alpha;
        ws.bottomView.alpha=alpha;
    }];
}
@end
