//
//  PictureCell.m
//  JianDan
//
//  Created by 刘献亭 on 15/10/19.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "PictureCell.h"
#import "NSString+Additions.h"
#import "Picture.h"
#import "NSString+Date.h"
#import "PictureFrame.h"
#import "UIColor+Additions.h"
#import "ScaleImageView.h"
#import "VoteViewModel.h"
#import "CommentController.h"
#import "ShareToSinaController.h"
#import "UITableViewCell+TableView.h"
#import "UIImageView+UIProgressForSDWebImage.h"
#import "UIViewController+MMDrawerController.h"
#import "TMCache.h"
#import "UIImage+GIF.h"
#import "OLImageView.h"
#import "OLImage.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "OLImageResponseSerializer.h"
#import "OLImageStrictResponseSerializer.h"

#import "OLImageViewDelegate.h"

@interface PictureCell () <CEReactiveView>

@property(strong, nonatomic) UIView *bgView;

@property(strong, nonatomic) UIImageView *netImageView;

@property(strong, nonatomic) UIView *gifImageView;

@property(weak, nonatomic) Picture *picture;

@property(assign, nonatomic) NSInteger drawColorFlag;


@end


@implementation PictureCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //1、背景
        _bgView = [UIView new];
        _bgView.layer.cornerRadius=4;
        _bgView.layer.masksToBounds=YES;
        [self addSubview:_bgView];

        //为其中的按钮添加点击事件
        UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickButton:)];
        oneTap.delegate = self;
        oneTap.numberOfTouchesRequired = 1;
        [_bgView addGestureRecognizer:oneTap];

        //2、网络图片
        _netImageView = [OLImageView new];
        _netImageView.userInteractionEnabled = YES;
        [self addSubview:_netImageView];

        //3、gif图片
        _gifImageView = [UIView new];
        _gifImageView.layer.contents =(__bridge id _Nullable)([UIImage imageNamed:@"ic_play_gif"].CGImage);
        [self addSubview:_gifImageView];
        self.backgroundColor = UIColorFromRGB(0xDDDDDD);
    }
    return self;
}

- (void)bindViewModel:(Picture *)viewModel forIndexPath:(NSIndexPath *)indexPath {
    self.picture = viewModel;
    if (!viewModel.picUrl) {//段子
        [self draw];
        return;
    }

    [self draw];
    BOOL isGIF=viewModel.thumnailGiFUrl;
    _gifImageView.frame = isGIF?_picture.picFrame.gifFrame: CGRectZero;
    _gifImageView.hidden = !isGIF; 
    BOOL autoLoadImage=[[NSUserDefaults standardUserDefaults] boolForKey:kAutoLoadGIFKey]&&[AFNetWorkUtils sharedAFNetWorkUtils].netType==WiFiNet&&isGIF;
     UIImage *placeHoler=[self.backgroundColor createPlaceholderWithSize:viewModel.picFrame.pictureSize];
    
    self.netImageView.frame=viewModel.picFrame.pictureFrame;

    if (autoLoadImage) {
        //下载GIF，显示下载GIF的进度，显示缩略图
        [self.netImageView onlyDownloadImagWithURL:[NSURL URLWithString:viewModel.picUrl] usingProgressViewStyle:UIProgressViewStyleDefault];
        //显示缩略图
        [self.netImageView sd_setImageWithURL:[NSURL URLWithString:viewModel.thumnailGiFUrl] placeholderImage:placeHoler options:SDWebImageHighPriority|SDWebImageTransformAnimatedImage];
    }else{
        //下载普通图片
        [self.netImageView setImageWithURL:[NSURL URLWithString:viewModel.thumnailGiFUrl?:viewModel.picUrl] placeholderImage:placeHoler options:SDWebImageHighPriority usingProgressViewStyle:UIProgressViewStyleDefault];
    }
}

- (void)draw {
    NSInteger flag = _drawColorFlag;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!_picture.picFrame) return;
        UIGraphicsBeginImageContextWithOptions(_picture.picFrame.bgViewFrame.size, YES, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        //整个内容的背景色
        [[UIColor whiteColor] set];
        CGContextFillRect(context, (CGRect) {CGPointZero, _picture.picFrame.bgViewFrame.size});
        //Author
        [_picture.comment_author drawInRect:_picture.picFrame.authorFrame fromFont:kAuthorFont];
        //date
        [_picture.deltaToNow drawInRect:_picture.picFrame.dateFrame fromFont:kDateFont color:[UIColor grayColor]];;
        //content
        if (_picture.text_content.length) {
            [_picture.text_content drawInRect:_picture.picFrame.textContentFrame fromFont:kContentFont];
        }
        //OO
        [_picture.vote_positiveStr drawAtPoint:_picture.picFrame.OOPoint fromFont:kDateFont color:[UIColor grayColor]];
        //XX
        [_picture.vote_negativeStr drawAtPoint:_picture.picFrame.XXPoint fromFont:kDateFont color:[UIColor grayColor]];
        //吐槽
        [_picture.comment_count drawAtPoint:_picture.picFrame.commentPoint fromFont:kDateFont color:[UIColor grayColor]];
        //share
        [@"•••" drawAtPoint:_picture.picFrame.sharePoint fromFont:kDateFont color:[UIColor grayColor]];
        //获得组合的图片
        UIImage * temp = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
       
        dispatch_async(dispatch_get_main_queue(), ^{
            if (flag == _drawColorFlag) {
                self.bgView.frame = _picture.picFrame.bgViewFrame;
                self.bgView.layer.contents = nil;
                self.bgView.layer.contents = (__bridge id) temp.CGImage;
            }
        });
    });
}

- (void)clear {
    self.bgView.frame = CGRectZero;
    self.bgView.layer.contents = nil;
    self.netImageView.frame = CGRectZero;
    self.netImageView.layer.contents = nil;
    _drawColorFlag = arc4random();
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self clear];
}

- (void)clickButton:(UIGestureRecognizer *)getsture {
    CGPoint touchPoint = [getsture locationInView:_bgView];
    //OO
    CGRect OOFrame = [PictureFrame getButtonFrameFromPoint:_picture.picFrame.OOPoint pictureFrame:_picture.picFrame.pictureFrame];
    BOOL isInOOButton = CGRectContainsPoint(OOFrame, touchPoint);
    if (isInOOButton) {
        [VoteViewModel voteWithOption:OO vote:(id <Vote>) _picture button:nil];
        return;
    }
    //XX
    CGRect XXFrame = [PictureFrame getButtonFrameFromPoint:_picture.picFrame.XXPoint pictureFrame:_picture.picFrame.pictureFrame];
    BOOL isInXXButton = CGRectContainsPoint(XXFrame, touchPoint);
    if (isInXXButton) {
        [VoteViewModel voteWithOption:XX vote:(id <Vote>) _picture button:nil];
        return;
    }
    //comment
    CGRect commentFrame = [PictureFrame getButtonFrameFromPoint:_picture.picFrame.commentPoint pictureFrame:_picture.picFrame.pictureFrame];
    BOOL isIncommentButton = CGRectContainsPoint(commentFrame, touchPoint);
    if (isIncommentButton) {
        CommentController *vc = [CommentController new];
        vc.sendObject = _picture.post_id;
        [[self controller].mm_drawerController.navigationController pushViewController:vc animated:YES];
        return;
    }
    //share
    CGRect shareFrame = [PictureFrame getButtonFrameFromPoint:_picture.picFrame.sharePoint pictureFrame:_picture.picFrame.pictureFrame];
    BOOL isInShareButton = CGRectContainsPoint(shareFrame, touchPoint);
    if (isInShareButton) {
        NSString * content = [_picture.text_content stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        ShareToSinaController *vc = [ShareToSinaController new];
        vc.sendObject=[NSString stringWithFormat:@"%@（来自 @煎蛋网）", content];
        if (_picture.picUrl) {
            vc.sendObject= [RACTuple tupleWithObjects:_picture.picUrl, vc.sendObject, nil];
        }
        [[self controller].mm_drawerController.navigationController pushViewController:vc animated:YES];
        return;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return ![NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"];
}

@end
