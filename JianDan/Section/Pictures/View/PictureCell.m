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

@interface PictureCell()<CEReactiveView>

@property (assign,nonatomic) BOOL drawed;

//@property (weak, nonatomic) NSString *author;
//@property (weak, nonatomic) NSString *date;
//@property (weak, nonatomic) NSString *imageName;
//@property (weak, nonatomic) NSString *OO;
//@property (weak, nonatomic) NSString *XX;
//@property (weak, nonatomic) NSString *comment;

@property (strong, nonatomic) UIImage *image;

@property (strong,nonatomic)  UIImageView *postBGView;

//@property (assign, nonatomic) CGSize picSize;

@property (weak, nonatomic) BoredPictures *picture;

@end


@implementation PictureCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        _postBGView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView insertSubview:_postBGView atIndex:0];
    }
    return self;
}

-(void)bindViewModel:(BoredPictures *)viewModel forIndexPath:(NSIndexPath *)indexPath{
//    _drawed=NO;
//    _author=viewModel.comment_author;
//    _date=viewModel.deltaToNow;
//    _image=[UIImage imageNamed:@"ic_loading_large"];
//    _picSize=viewModel.picSize;
    self.picture=viewModel;
    _image=[UIImage imageNamed:@"ic_loading_large"];
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:viewModel.picUrl] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        _image=image;
        self.drawed=NO;
        [self draw];
    }];
    
    [self draw];
}


-(void)draw{
    if (_drawed) {
        return;
    }
    _drawed=YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, _picture.cellHeight);
        NSLog(@"draw:%f",_picture.cellHeight);
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
        CGContextRef context=UIGraphicsGetCurrentContext();
        //整个内容的背景
        [[UIColor whiteColor] set];
        CGContextFillRect(context, rect);
        //Author
        CGSize size=[_picture.comment_author sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:FontWithSize(17) lineSpace:0];
        [_picture.comment_author drawInContext:context withPosition:CGPointMake(16, 16) andFont:FontWithSize(17) andTextColor:[UIColor blackColor] andHeight:size.height];
        
        //date
        CGSize dateSize=[_picture.deltaToNow sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:FontWithSize(15) lineSpace:0];
        [_picture.deltaToNow drawInContext:context withPosition:CGPointMake(size.width+16+6, 16) andFont:FontWithSize(15) andTextColor:[UIColor darkGrayColor] andHeight:dateSize.height];
        
        //image
        if (_image) {
            CGFloat ratio = (SCREEN_WIDTH-32)/_picture.picSize.width;
            NSInteger mHeight = _picture.picSize.height * ratio;
            [_image drawInRect:CGRectMake(16,16+size.height+dateSize.height+8,(SCREEN_WIDTH-32),mHeight)];
            //进度条
            
        }
            
        UIImage *temp=UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            _postBGView.frame=rect;
            _postBGView.image=nil;
            _postBGView.image=temp;
        });
        
        //OO
        
        //XX
        
        //comment
        
        //share
    });
}


@end
