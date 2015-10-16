//
//  FastImage.h
//  FICFast
//
//  Created by 刘献亭 on 15/9/25.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FastImageCache/FICEntity.h"

static NSString  *fastImageFormatFamily = @"FastImageFormatFamily";
static NSString *fastImage32BitBGRAFormatName = @"FastImage32BitBGRAFormatName";
static NSString *fastImage32BitBGRFormatName = @"FastImage32BitBGRFormatName";

static CGSize fastImageSize = {320, 200};

@interface FastImage : NSObject<FICEntity>

@property (nonatomic, copy) NSString *sourceUrl;

- (id)initWithResUrl:(NSString *)resUrl;

- (UIImage *)sourceImage;

- (BOOL)imageExsited;

- (NSString *)path;

@end
