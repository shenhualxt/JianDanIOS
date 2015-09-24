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

@interface BoredPictursCell()<CEReactiveView>

@property (weak, nonatomic) IBOutlet ScaleImageView *imagePicture;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *labelUserName;
@property (weak, nonatomic) IBOutlet UIImageView *imageGIF;
@property (weak, nonatomic) IBOutlet UILabel *labelContent;
@property (weak, nonatomic) IBOutlet UIButton *buttonOO;
@property (weak, nonatomic) IBOutlet UIButton *buttonXX;
@property (weak, nonatomic) IBOutlet UIButton *buttonMore;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;

@end

@implementation BoredPictursCell

-(void)bindViewModel:(BoredPictures*)boredPictures forIndexPath:(NSIndexPath *)indexPath{
    self.labelUserName.text=boredPictures.comment_author;
    self.labelTime.text=boredPictures.comment_time;
    self.labelContent.text=[boredPictures.text_content stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    [self.buttonOO setTitle:[NSString stringWithFormat:@"OO %@",boredPictures.vote_positive] forState:UIControlStateNormal];
    [self.buttonXX setTitle:[NSString stringWithFormat:@"XX %@",boredPictures.vote_negative] forState:UIControlStateNormal];
    [self.buttonMore setTitle:[NSString stringWithFormat:@"吐槽 %@",boredPictures.vote_negative] forState:UIControlStateNormal];
    
    if (!boredPictures.pics.count) return;
    NSString *thumbImageURL=boredPictures.pics[0];
    self.imagePicture.image=[self getCachedImageOrDownload:thumbImageURL atIndexPath:indexPath];
    
    
}

/**
 *  下载图片的两种情况：1，GIF（下载缩略图和GIF）  2，普通图片
 *
 *  @param thumbImageURL 原始图片地址
 *
 *  @return 缓存的图片或默认图片
 */
-(UIImage *)getCachedImageOrDownload:(NSString *)thumbImageURL atIndexPath:(NSIndexPath *)indexPath{
     [[SDWebImageManager sharedManager] cancelAll];
    //1,下载GIF
    if([thumbImageURL hasSuffix:@".gif"]){
        self.imageGIF.hidden=NO;
        NSString *gifURL=[thumbImageURL copy];
        [self getCacheImage:gifURL atIndexPath:indexPath];
        thumbImageURL=[self thumbGIFURLFromURL:thumbImageURL];
    }else{
        self.imageGIF.hidden=YES;
    }
    
    //2,下载普通图片和缩略图
    UIImage *cachedImage=[self getCacheImage:thumbImageURL atIndexPath:indexPath];
    if (!cachedImage) {
        cachedImage=[UIImage imageNamed:@"ic_loading_large"];
    }
    return cachedImage;
}

-(UIImage *)getCacheImage:(NSString *)imageURL atIndexPath:(NSIndexPath *)indexPath{
    UIImage *gifImage=[[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:imageURL];
    if (!gifImage) {
        gifImage=[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageURL];
        if (!gifImage) {
            [self downloadImage:imageURL atIndexPath:indexPath];
        }
    }
    return gifImage;
}
/**
 * 下载普通图片和gif 并缓存
 *
 *  @param imageURL   网络图片地址
 *  @param indexPath  cell的索引
 *  @param cell      cell为nil 为下载缩略图（！进度条+reload）  cell不为nil 下载普通图片（reload+进度条） GIF(!reload+进度条)
 */
-(void)downloadImage:(NSString *)imageURL atIndexPath:(NSIndexPath *)indexPath{
    if ([self tableView].dragging||[self tableView].decelerating) return;
    
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
                self.progressView.hidden=YES;
            })
            //1，下载图片失败
            if (image) {
                //2，图片如果太长，则截取,并且保存原图
                if(image.size.height>=[UIScreen mainScreen].bounds.size.height*4/3){
                    [[SDImageCache sharedImageCache] storeImage:[image copy] forKey:[NSString stringWithFormat:@"%@%@",imageURL,imageURL] toDisk:YES];
                    CGFloat  mHeight=[UIScreen mainScreen].bounds.size.height*2/3;
                    image=[image getImageFromImageWithRect:CGRectMake(0, 0, image.size.width, mHeight)];
                }
                
                //3，保存cell上显示的图片
                [[SDImageCache sharedImageCache] storeImage:image forKey:imageURL toDisk:YES];
                dispatch_main_sync_safe(^{
                    //1,缩率图，普通图片  2，gif(后缀.gif+有small)
                    if (![imageURL hasSuffix:@".gif"]||[imageURL rangeOfString:@"small"].length) {
                        [[target tableView] reloadData];
//                        [[target tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }
                })
            }else{
                LogBlue(@"下载图片失败,error:%@\r\n%@",error,imageURL);
                return ;
            }
    }];
}

-(NSString *)thumbGIFURLFromURL:(NSString *)imageURL{
    imageURL=[imageURL stringByReplacingOccurrencesOfString:@"mw600" withString:@"small"];
    imageURL=[imageURL stringByReplacingOccurrencesOfString:@"mw1200" withString:@"small"];
    return [imageURL stringByReplacingOccurrencesOfString:@"large" withString:@"small"];
}

@end
