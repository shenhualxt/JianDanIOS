//
//  FastImageCacehHelper.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/26.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "FastImageCacehHelper.h"
#import "FastImageCache/FICImageCache.h"
#import "FastImageCache/FICImageFormat.h"
#import "FastImage.h"

@interface FastImageCacehHelper()<FICImageCacheDelegate>

@end

@implementation FastImageCacehHelper

SYNTHESIZE_SINGLETON_FOR_CLASS(FastImageCacehHelper)

-(void)createImageFormats{
    NSMutableArray *formats=[NSMutableArray array];
    FICImageFormatDevices formatDevice=FICImageFormatDevicePhone;
    int maxImageCount=400;
    FICImageFormat *imageFormat32BitBGRA = [FICImageFormat formatWithName:fastImage32BitBGRAFormatName family:fastImageFormatFamily imageSize:fastImageSize style:FICImageFormatStyle32BitBGRA maximumCount:maxImageCount devices:formatDevice protectionMode:FICImageFormatProtectionModeComplete];
    [formats addObject:imageFormat32BitBGRA];
    
    FICImageFormat *imageFormat32BitBGR = [FICImageFormat formatWithName:fastImage32BitBGRAFormatName family:fastImageFormatFamily imageSize:fastImageSize style:FICImageFormatStyle16BitBGR maximumCount:maxImageCount devices:formatDevice protectionMode:FICImageFormatProtectionModeComplete];
    
    [formats addObject:imageFormat32BitBGR];
    FICImageCache *sharedImageCache = [FICImageCache sharedImageCache];
    [sharedImageCache setFormats:formats];
    sharedImageCache.delegate = self;
}


-(void)imageCache:(FICImageCache *)imageCache wantsSourceImageForEntity:(id<FICEntity>)entity withFormatName:(NSString *)formatName completionBlock:(FICImageRequestCompletionBlock)completionBlock{
    FastImage *fastImg=(FastImage *)entity;
    UIImage *sourceImage=[fastImg sourceImage];
    if ([fastImg imageExsited]) {
        completionBlock([fastImg sourceImage]);
        return;
    }
    //缓存中没有
    WS(ws)
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:fastImg.sourceUrl] options:SDWebImageRetryFailed|SDWebImageLowPriority  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if ([ws.delegate respondsToSelector:@selector(downloadProgress:)]) {
            [ws.delegate downloadProgress:receivedSize/expectedSize];
        }
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [data writeToFile:[fastImg path] atomically:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(sourceImage);
            });
        });
    }];
    
                       
}

@end
