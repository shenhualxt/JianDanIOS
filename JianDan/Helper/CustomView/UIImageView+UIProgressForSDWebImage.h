//
//  UIImageView+UIActivityIndicatorForSDWebImage.h
//  UIActivityIndicator for SDWebIImage
//
//  Created by Giacomo Saccardo.
//  Copyright (c) 2014 Giacomo Saccardo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"

@interface UIImageView (UIProgressSDWebImage)

@property(nonatomic, strong) UIProgressView *progressView;

- (void)setImageWithURL:(NSURL *)url usingProgressViewStyle:(UIProgressViewStyle)progressViewStyle;

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder usingProgressViewStyle:(UIProgressViewStyle)progressViewStyle;

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options usingProgressViewStyle:(UIProgressViewStyle)progressViewStyle;

- (void)setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock usingProgressViewStyle:(UIProgressViewStyle)progressViewStyle;

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock usingProgressViewStyle:(UIProgressViewStyle)progressViewStyle;

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock usingProgressViewStyle:(UIProgressViewStyle)progressViewStyle;

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock usingProgressViewStyle:(UIProgressViewStyle)progressViewStyle;

- (void)setGIFImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageDownloaderOptions)options completed:(SDWebImageDownloaderCompletedBlock)completedBlock usingProgressViewStyle:(UIProgressViewStyle)progressViewStyle;

- (void)setGIFImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageDownloaderOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageDownloaderCompletedBlock)completedBlock usingProgressViewStyle:(UIProgressViewStyle)progressViewStyle;

- (void)removeProgressView;

- (void)addProgressViewWithReceivedSize:(NSInteger)receivedSize expectedSize:(NSInteger)expectedSize;

-(void)onlyDownloadGIFImageWithURL:(NSURL *)url options:(SDWebImageOptions)options usingProgressViewStyle:(UIProgressViewStyle)progressViewStyle;

@end
