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

@interface PictureCell()<CEReactiveView>

@property(strong,nonatomic) UIView *bgView;

@property(strong,nonatomic) UIView *netImageView;

@property(strong,nonatomic) UIView *gifImageView;

@property (weak, nonatomic) BoredPictures *picture;

@property (weak,nonatomic) id<SDWebImageOperation> operation;

@property (assign,nonatomic)  NSInteger drawColorFlag;

@property(strong,nonatomic) NSIndexPath *indexPath;

@end


@implementation PictureCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bgView=[UIView new];
        _bgView.opaque = YES;
        [self addSubview:_bgView];
        
        _netImageView=[UIView new];
        _netImageView.opaque = YES;
        [self addSubview:_netImageView];
        
        _gifImageView=[UIView new];
        _gifImageView.opaque = YES;
        _gifImageView.layer.contents=(__bridge id _Nullable)([UIImage imageNamed:@"ic_play_gif"].CGImage);
        [self addSubview:_gifImageView];
    }
    return self;
}


-(void)bindViewModel:(BoredPictures *)viewModel forIndexPath:(NSIndexPath *)indexPath{
    self.indexPath=indexPath;
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
        if (expectedSize<0) return ;
        float pvalue=MAX(0,MIN(1,(float)receivedSize/(float)expectedSize));
        [weakSelf updateProgressView:pvalue rect:viewModel.picFrame.pictureFrame];
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
        //整个内容的背景
        [[UIColor whiteColor] set];
        CGContextFillRect(context,_picture.picFrame.bgViewFrame);
        //Author
        [_picture.comment_author drawInContext:context withPosition:_picture.picFrame.authorFrame.origin andFont:kAuthorFont andTextColor:[UIColor blackColor] andHeight:_picture.picFrame.authorFrame.size.height];
        
        //date
        [_picture.deltaToNow drawInContext:context withPosition:_picture.picFrame.dateFrame.origin andFont:kDateFont andTextColor:[UIColor darkGrayColor] andHeight:_picture.picFrame.dateFrame.size.height];
        
        //content
        if (_picture.text_content.length) {
            [_picture.text_content drawInRect:_picture.picFrame.textContentFrame fromFont:kContentFont];
        }
        
        //OO
        [_picture.vote_positiveStr drawInContext:context withPosition:_picture.picFrame.OOFrame.origin andFont:kDateFont andTextColor:[UIColor blackColor] andHeight:_picture.picFrame.OOFrame.size.height];
        
        //XX
        [_picture.vote_negativeStr drawInContext:context withPosition:_picture.picFrame.XXFrame.origin andFont:kDateFont andTextColor:[UIColor blackColor] andHeight:_picture.picFrame.XXFrame.size.height];
        //吐槽
        [_picture.comment_count drawInContext:context withPosition:_picture.picFrame.commentFrame.origin andFont:kDateFont andTextColor:[UIColor blackColor] andHeight:_picture.picFrame.commentFrame.size.height];
        //share
        [@"•••" drawInContext:context withPosition:_picture.picFrame.shareFrame.origin andFont:kDateFont andTextColor:[UIColor blackColor] andHeight:_picture.picFrame.shareFrame.size.height];
    
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

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch=[touches anyObject];
    
    CGPoint touchPoint=[touch locationInView:self];
    
    BOOL isInOOButton=CGRectContainsPoint(_picture.picFrame.OOFrame, touchPoint);
    if (isInOOButton) {
        //
        return;
    }
    
    BOOL isInXXButton=CGRectContainsPoint(_picture.picFrame.XXFrame, touchPoint);
    
    if (isInXXButton) {
        
        return;
    }
    
    
     BOOL isInCommentButton=CGRectContainsPoint(_picture.picFrame.commentFrame, touchPoint);
    
    if (isInCommentButton) {
        
        return;
    }
    
    BOOL isInShareButton=CGRectContainsPoint(_picture.picFrame.shareFrame, touchPoint);
    if (isInShareButton) {
        return;
    }
}

@end
