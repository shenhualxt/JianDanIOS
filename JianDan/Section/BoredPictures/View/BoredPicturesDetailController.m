//
//  BoredPicturesDetailController.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/24.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "BoredPicturesDetailController.h"
#import "BoredPictures.h"

@interface BoredPicturesDetailController ()
@property (weak, nonatomic) IBOutlet UIButton *buttonBack;
@property (weak, nonatomic) IBOutlet UIButton *buttonShare;
@property (weak, nonatomic) IBOutlet UIButton *buttonOO;
@property (weak, nonatomic) IBOutlet UIButton *buttonXX;
@property (weak, nonatomic) IBOutlet UIButton *buttonDownload;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewDetail;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation BoredPicturesDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    BoredPictures *boredPictures=(BoredPictures *)self.sendObject;
    
    //加载图片
    if (!boredPictures.pics.count)return;
    NSString *imageURL=boredPictures.pics[0];
    //三种图片 普通图片，长图，GIF
    
    //1、是否有缓存的长图片
    NSString *bigImageURL=[NSString stringWithFormat:@"%@%@",imageURL,imageURL];
    UIImage *bigImage=[self getCacheImage:bigImageURL];
    
    if (bigImage) {
        self.imageViewDetail.image=bigImage;
        return;
    }
    
    //2、是否有普通图片和GIF
    UIImage *image=[self getCacheImage:imageURL];
    if (image) {
        self.imageViewDetail.image=image;
        return;
    }
    
    //3、都没有
    [self downloadImage:imageURL];
}

-(UIImage *)getCacheImage:(NSString *)imageURL{
    UIImage *gifImage=[[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:imageURL];
    if (!gifImage) {
        gifImage=[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageURL];
    }
    return gifImage;
}

-(void)downloadImage:(NSString *)imageURL{
    WS(target);
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imageURL] options:SDWebImageDownloaderLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if(expectedSize <= 0) return ;
        float pvalue=MAX(0,MIN(1,receivedSize/(float)expectedSize));
        dispatch_main_sync_safe(^{
            target.progressView.hidden=NO;
            if(pvalue>target.progressView.progress){
                target.progressView.progress=pvalue;
            }
            if (pvalue==1) {
                target.progressView.hidden=YES;
            }
        })
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            dispatch_main_sync_safe(^{
                target.progressView.hidden=YES;
                target.imageViewDetail.image=image;
            })
             //1，下载图片失败
            if(image.size.height>=[UIScreen mainScreen].bounds.size.height*4/3)
                [[SDImageCache sharedImageCache] storeImage:[image copy] forKey:[NSString stringWithFormat:@"%@%@",imageURL,imageURL] toDisk:YES];
            //3，保存cell上显示的图片
        [[SDImageCache sharedImageCache] storeImage:image forKey:imageURL toDisk:YES];
    }];
}

@end
