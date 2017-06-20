//
//  BLImageSize.h
//  JianDan
//
//  Created by 刘献亭 on 15/10/9.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLImageSize : NSObject

/**
 获取网络图片的Size, 先通过文件头来获取图片大小
 如果失败 会下载完整的图片Data 来计算大小 所以最好别放在主线程
 如果你有使用SDWebImage就会先看下 SDWebImage有缓存过改图片没有
 支持文件头大小的格式 png、gif、jpg
 */
+ (CGSize)downloadImageSizeWithURL:(id)imageURL;

@end
