//
//  FastImageCacehHelper.h
//  JianDan
//
//  Created by 刘献亭 on 15/9/26.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FastImageCacehHelperDelegate <NSObject>

@optional
- (void)downloadProgress:(NSUInteger)progress;

@end

@interface FastImageCacehHelper : NSObject

+ (FastImageCacehHelper *)sharedFastImageCacehHelper;

- (void)createImageFormats;

@property(weak, nonatomic) id <FastImageCacehHelperDelegate> delegate;

@end
