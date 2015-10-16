//
//  UIImageView+UIActivityIndicatorForSDWebImage.m
//  UIActivityIndicator for SDWebImage
//
//  Created by Giacomo Saccardo.
//  Copyright (c) 2014 Giacomo Saccardo. All rights reserved.
//

#import "UIImageView+UIProgressForSDWebImage.h"
#import <objc/runtime.h>

static char TAG_PROGRESSVIEW;

@interface UIImageView (Private)

- (void)addProgressWithStyle:(UIProgressViewStyle)progressViewStyle;

@end

@implementation UIImageView (UIProgressSDWebImage)

@dynamic progressView;

-(UIProgressView *)progressView{
     return (UIProgressView *)objc_getAssociatedObject(self, &TAG_PROGRESSVIEW);
}

- (void)setProgressView:(UIProgressView *)progressView {
    objc_setAssociatedObject(self, &TAG_PROGRESSVIEW, progressView, OBJC_ASSOCIATION_RETAIN);
}

- (void)addProgressWithStyle:(UIProgressViewStyle)progressViewStyle {
    if (!self.progressView) {
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.progressView.frame = CGRectMake(0, 0, self.frame.size.width, 2);
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.progressView.progress=0;
            self.progressView.hidden=YES;
            [self addSubview:self.progressView];
        });
    }
}

-(void)updateProgressView:(CGFloat)progress {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (self.progressView) {
            self.progressView.hidden=NO;
            self.progressView.progress=progress;
        }
    });
}

- (void)removeProgressView {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (self.progressView) {
            [self.progressView removeFromSuperview];
            self.progressView = nil;
        }
    });
}

#pragma mark - Methods

- (void)setImageWithURL:(NSURL *)url usingProgressViewStyle:(UIProgressViewStyle)progressViewStyle {
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil usingProgressViewStyle:progressViewStyle];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder usingProgressViewStyle:(UIProgressViewStyle)progressViewStyle {
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil usingProgressViewStyle:progressViewStyle];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options usingProgressViewStyle:(UIProgressViewStyle)progressViewStyle{
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil usingProgressViewStyle:progressViewStyle];
}

- (void)setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock usingProgressViewStyle:(UIProgressViewStyle)progressViewStyle {
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock usingProgressViewStyle:progressViewStyle];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock usingProgressViewStyle:(UIProgressViewStyle)progressViewStyle {
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock usingProgressViewStyle:progressViewStyle];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock usingProgressViewStyle:(UIProgressViewStyle)progressViewStyle {
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock usingProgressViewStyle:progressViewStyle];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock usingProgressViewStyle:(UIProgressViewStyle)progressViewStyle{
    
    __weak typeof(self) weakSelf = self;
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (progressBlock) {
            progressBlock(receivedSize,expectedSize);
        }
        if (expectedSize<0) return ;
        [self addProgressWithStyle:progressViewStyle];
        float pvalue=MAX(0,MIN(1,(float)receivedSize/(float)expectedSize));
        [weakSelf updateProgressView:pvalue];
        if (pvalue>=1) {
            [weakSelf removeProgressView];
        }
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
         [weakSelf removeProgressView];
        if (completedBlock) {
            completedBlock(image, error, cacheType, imageURL);
        }
       
    }];
}

@end
