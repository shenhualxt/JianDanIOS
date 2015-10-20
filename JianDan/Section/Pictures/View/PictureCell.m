//
//  PictureCell.m
//  JianDan
//
//  Created by 刘献亭 on 15/10/19.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "PictureCell.h"
#import "NSString+Additions.h"
#import "BoredPictures.h"
#import "NSString+Date.h"
#import "PictureFrame.h"
#import "UIColor+Additions.h"
#import "CardView.h"

@interface PictureCell()<CEReactiveView>

@property(strong,nonatomic) CardView *bgView;

@property(strong,nonatomic) UIView *netImageView;

@property(strong,nonatomic) UIView *gifImageView;

@property (weak, nonatomic) BoredPictures *picture;

@property (weak,nonatomic) id<SDWebImageOperation> operation;

@property (assign,nonatomic)  NSInteger drawColorFlag;

@end


@implementation PictureCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //背景
        _bgView=[CardView new];
        [self addSubview:_bgView];

        UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickButton:)];
        oneTap.delegate = self;
        oneTap.numberOfTouchesRequired = 1;
        [_bgView addGestureRecognizer:oneTap];
        
        //网络图片
        _netImageView=[UIView new];
        _netImageView.opaque = YES;
        [self addSubview:_netImageView];
        
        //gif图片
        _gifImageView=[UIView new];
        _gifImageView.opaque = YES;
        _gifImageView.layer.contents=(__bridge id _Nullable)([UIImage imageNamed:@"ic_play_gif"].CGImage);
        [self addSubview:_gifImageView];
        self.backgroundColor=UIColorFromRGB(0xDDDDDD);
    }
    return self;
}


-(void)bindViewModel:(BoredPictures *)viewModel forIndexPath:(NSIndexPath *)indexPath{
    self.picture=viewModel;
    if (!viewModel.picUrl) {
        [self draw];
        return;
    }
    
    NSURL *targetURL=[self getImageURL:viewModel];
    NSString *key=[[SDWebImageManager sharedManager] cacheKeyForURL:targetURL];
    
    //设置默认图片
     self.netImageView.frame=_picture.picFrame.pictureFrame;
     self.netImageView.layer.contents         = (__bridge id)([[UIColor lightGrayColor] createImage].CGImage);
    
    //从内存中取出
    UIImage *image=[[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
    if (image) {
        viewModel.image=image;
        [self draw];
        [self drawImage];
        _operation=nil;
        return;
    }
    
    [self draw];
    __weak typeof(self) weakSelf = self;
   _operation=[[SDWebImageManager sharedManager] downloadImageWithURL:targetURL options:SDWebImageRetryFailed|SDWebImageTransformAnimatedImage progress:^(NSInteger receivedSize, NSInteger expectedSize) {
       [weakSelf updateProgressViewWithReceivedSize:receivedSize expectedSize:expectedSize rect:_picture.picFrame.pictureFrame];
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image&&finished) {
            viewModel.image=image;
            [weakSelf drawImage];
        }
    }];
}

-(void)drawImage{
    self.netImageView.frame=_picture.picFrame.pictureFrame;
    
    CGImageRef imageRef=self.picture.image.CGImage;

    CABasicAnimation *contentsAnimation = [CABasicAnimation animationWithKeyPath:@"contents"];
    contentsAnimation.fromValue         =  self.netImageView.layer.contents;
    contentsAnimation.toValue           =  (__bridge id)imageRef;
    contentsAnimation.duration          = 0.5f;
    
    // 2，设定layer动画结束后的contents值
    self.netImageView.layer.contents         = (__bridge id)imageRef;
    
    //3， 让layer开始执行动画
    [self.netImageView.layer addAnimation:contentsAnimation forKey:nil];
}

-(void)draw{
    NSInteger flag = _drawColorFlag;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!_picture.picFrame) return ;
        UIGraphicsBeginImageContextWithOptions(_picture.picFrame.bgViewFrame.size, YES, [UIScreen mainScreen].scale);
        CGContextRef context=UIGraphicsGetCurrentContext();
        
        //整个内容的背景色
        [[UIColor whiteColor] set];
        CGContextFillRect(context,(CGRect){CGPointZero, _picture.picFrame.bgViewFrame.size});
                          
        //Author
        [_picture.comment_author drawInRect:_picture.picFrame.authorFrame fromFont:kAuthorFont];
        
        //date
        [_picture.deltaToNow drawInRect:_picture.picFrame.dateFrame fromFont:kDateFont];;
        
        //content
        if (_picture.text_content.length) {
            [_picture.text_content drawInRect:_picture.picFrame.textContentFrame fromFont:kContentFont];
        }
    
        //OO
        [_picture.vote_positiveStr drawAtPoint:_picture.picFrame.OOPoint fromFont:kDateFont];
        
        //XX
        [_picture.vote_negativeStr drawAtPoint:_picture.picFrame.XXPoint fromFont:kDateFont];
        
        //吐槽
        [_picture.comment_count drawAtPoint:_picture.picFrame.commentPoint fromFont:kDateFont];
        
        //share
        [@"•••" drawAtPoint:_picture.picFrame.sharePoint fromFont:kDateFont];
    
        UIImage *temp=UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            if (flag==_drawColorFlag) {
                self.bgView.frame=_picture.picFrame.bgViewFrame;
                self.bgView.layer.contents=nil;
                self.bgView.layer.contents=(__bridge id)temp.CGImage;

            }else{
                
            }
        });
    });
}

-(void)clear{
    self.bgView.frame=CGRectZero;
    self.bgView.layer.contents = nil;
    self.netImageView.frame=CGRectZero;
    self.netImageView.layer.contents=nil;
      _drawColorFlag = arc4random();;
    if (_operation) {
        [_operation cancel];
    }
}

-(void)removeFromSuperview{
    [super removeFromSuperview];
    [self clear];
}


-(NSURL *)getImageURL:(BoredPictures *)boredPictures{
    NSString *imageURL=boredPictures.thumnailGiFUrl;
    if (!imageURL) {
        _gifImageView.frame=CGRectZero;
        _gifImageView.hidden=YES;
        imageURL=boredPictures.picUrl;
    }else{
        _gifImageView.frame=_picture.picFrame.gifFrame;
        _gifImageView.hidden=NO;
    }
    return [NSURL URLWithString:imageURL];
}
-(void)clickButton:(UIGestureRecognizer *)getsture{
        CGPoint touchPoint=[getsture locationInView:_bgView];
    
        CGRect OOFrame=[PictureFrame getButtonFrameFromPoint:_picture.picFrame.OOPoint pictureFrame:_picture.picFrame.pictureFrame];
        BOOL isInOOButton=CGRectContainsPoint(OOFrame, touchPoint);
        if (isInOOButton) {
            NSLog(@"OOO");
            return;
        }
    
        CGRect XXFrame=[PictureFrame getButtonFrameFromPoint:_picture.picFrame.XXPoint pictureFrame:_picture.picFrame.pictureFrame];
        BOOL isInXXButton=CGRectContainsPoint(XXFrame, touchPoint);
        if (isInXXButton) {
            NSLog(@"XXFrame");
            return;
        }
    
        CGRect commentFrame=[PictureFrame getButtonFrameFromPoint:_picture.picFrame.commentPoint pictureFrame:_picture.picFrame.pictureFrame];
        BOOL isIncommentButton=CGRectContainsPoint(commentFrame, touchPoint);
        if (isIncommentButton) {
            NSLog(@"comment");
            return;
        }
    
        CGRect shareFrame=[PictureFrame getButtonFrameFromPoint:_picture.picFrame.sharePoint pictureFrame:_picture.picFrame.pictureFrame];
        BOOL isInShareButton=CGRectContainsPoint(shareFrame, touchPoint);
        if (isInShareButton) {
            NSLog(@"shareFrame");
            return;
        }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}

@end
