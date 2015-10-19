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

@interface PictureCell()<CEReactiveView>

@property (assign,nonatomic) BOOL drawed;

@property (weak, nonatomic) BoredPictures *picture;

@property (assign,nonatomic) NSInteger drawColorFlag;

@property (weak,nonatomic) id<SDWebImageOperation> operation;

@end


@implementation PictureCell

-(void)bindViewModel:(BoredPictures *)viewModel forIndexPath:(NSIndexPath *)indexPath{
    self.picture=viewModel;
    NSURL *targetURL=[self getImageURL:viewModel];
    NSString *key=[[SDWebImageManager sharedManager] cacheKeyForURL:targetURL];
    
    UIImage *image=[[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
    if (image) {
        viewModel.image=image;
        [self draw];
        _operation=nil;
        return;
    }
    
    [self draw];
    __weak typeof(self) weakSelf = self;
   _operation=[[SDWebImageManager sharedManager] downloadImageWithURL:targetURL options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (expectedSize<0) return ;
        float pvalue=MAX(0,MIN(1,(float)receivedSize/(float)expectedSize));
        [weakSelf updateProgressView:pvalue rect:viewModel.picFrame.pictureFrame];
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image&&finished) {
            _drawed=NO;
            viewModel.image=image;
            [weakSelf draw];
        }
    }];
}

-(void)draw{
    if (_drawed) {
        return;
    }
     _drawed = YES;
    NSInteger flag = _drawColorFlag;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PictureFrame *pictureFrame=_picture.picFrame;

        UIGraphicsBeginImageContextWithOptions(pictureFrame.bgViewFrame.size, YES, [UIScreen mainScreen].scale);
        CGContextRef context=UIGraphicsGetCurrentContext();
        //整个内容的背景
        [[UIColor whiteColor] set];
        CGContextFillRect(context,pictureFrame.bgViewFrame);
        //Author
        [_picture.comment_author drawInContext:context withPosition:pictureFrame.authorFrame.origin andFont:kAuthorFont andTextColor:[UIColor blackColor] andHeight:pictureFrame.authorFrame.size.height];
        
        //date
        [_picture.deltaToNow drawInContext:context withPosition:pictureFrame.dateFrame.origin andFont:kDateFont andTextColor:[UIColor darkGrayColor] andHeight:pictureFrame.dateFrame.size.height];
        
        //content
        if (_picture.text_content) {
            [_picture.text_content drawInContext:context withPosition:pictureFrame.textContentFrame.origin andFont:kDateFont andTextColor:[UIColor blackColor] andHeight:pictureFrame.textContentFrame.size.height andWidth:pictureFrame.textContentFrame.size.width];
        }
        
        //image
        UIImage *image=_picture.image?:[UIImage imageNamed:@"ic_loading_large"];
        [image drawInRect:pictureFrame.pictureFrame];

        //gif
        if (_picture.thumnailGiFUrl) {
            [[UIImage imageNamed:@"ic_play_gif"] drawInRect:pictureFrame.gifFrame];
        }

        //OO
        NSString *OOText=[NSString stringWithKey:"OO " value:(int)_picture.vote_positive];
        [OOText drawInContext:context withPosition:pictureFrame.OOFrame.origin andFont:kDateFont andTextColor:[UIColor blackColor] andHeight:pictureFrame.OOFrame.size.height];
        
        //XX
        NSString *XXText=[NSString stringWithKey:"XX " value:(int)_picture.vote_negative];
        [XXText drawInContext:context withPosition:pictureFrame.XXFrame.origin andFont:kDateFont andTextColor:[UIColor blackColor] andHeight:pictureFrame.XXFrame.size.height];
        //吐槽
        NSString *commentText=[NSString stringWithKey:"吐槽 " value:(int)_picture.vote_negative];
        [commentText drawInContext:context withPosition:pictureFrame.commentFrame.origin andFont:kDateFont andTextColor:[UIColor blackColor] andHeight:pictureFrame.commentFrame.size.height];
        //share
        NSString *shareText=@"•••";
        [shareText drawInContext:context withPosition:pictureFrame.shareFrame.origin andFont:kDateFont andTextColor:[UIColor blackColor] andHeight:pictureFrame.shareFrame.size.height];
    
        UIImage *temp=UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            if (flag==_drawColorFlag) {
                [super bgView].frame=pictureFrame.bgViewFrame;
                [super bgView].image=nil;
                [super bgView].image=temp;
            }
        });
    });
}

-(void)clear{
    if (!_drawed) {
        return;
    }
    [super bgView].frame = CGRectZero;
    [super bgView].image = nil;
     _drawed = NO;
    if (_operation) {
        [_operation cancel];
    }
    _drawColorFlag = arc4random();
}

-(void)removeFromSuperview{
    [super removeFromSuperview];
    [self clear];
}


-(NSURL *)getImageURL:(BoredPictures *)boredPictures{
    NSString *imageURL=boredPictures.thumnailGiFUrl;
    if (!imageURL) {
        imageURL=boredPictures.picUrl;
    }
    return [NSURL URLWithString:imageURL];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch=[touches anyObject];
    
    CGPoint touchPoint=[touch locationInView:[super bgView]];
    
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
