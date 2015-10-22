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

- (UIProgressView *)progressView {
    return (UIProgressView *) objc_getAssociatedObject(self, &TAG_PROGRESSVIEW);
}

- (void)setProgressView:(UIProgressView *)progressView {
    objc_setAssociatedObject(self, &TAG_PROGRESSVIEW, progressView, OBJC_ASSOCIATION_RETAIN);
}

- (void)addProgressWithStyle:(UIProgressViewStyle)progressViewStyle {
    if (!self.progressView) {
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:progressViewStyle];
        self.progressView.frame = CGRectMake(0, 0, self.frame.size.width, 2);

        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.progressView.progress = 0;
            self.progressView.hidden = YES;
            [self addSubview:self.progressView];
        });
    }
}

- (void)updateProgressView:(CGFloat)progress {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (self.progressView) {
            self.progressView.hidden = NO;
            self.progressView.progress = progress;
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

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options usingProgressViewStyle:(UIProgressViewStyle)progressViewStyle {
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

- (void)setGIFImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageDownloaderOptions)options completed:(SDWebImageDownloaderCompletedBlock)completedBlock usingProgressViewStyle:(UIProgressViewStyle)progressViewStyle {
    [self setGIFImageWithURL:url placeholderImage:placeholder options:options progress:^(NSInteger receivedSize, NSInteger expectedSize) {

    }              completed:completedBlock usingProgressViewStyle:progressViewStyle];
}

- (void)setGIFImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageDownloaderOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageDownloaderCompletedBlock)completedBlock usingProgressViewStyle:(UIProgressViewStyle)progressViewStyle {

    __weak typeof(self) weakSelf = self;
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:options progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (progressBlock) {
            progressBlock(receivedSize, expectedSize);
        }
        [weakSelf addProgressViewWithReceivedSize:receivedSize expectedSize:expectedSize];
    }                                                   completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        [weakSelf removeProgressView];
        if (image && finished) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                weakSelf.image = image;
            });

        }
        if (completedBlock) {
            completedBlock(image, data, error, finished);
        }
    }];

}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock usingProgressViewStyle:(UIProgressViewStyle)progressViewStyle {

    __weak typeof(self) weakSelf = self;
    [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (progressBlock) {
            progressBlock(receivedSize, expectedSize);
        }
        [weakSelf addProgressViewWithReceivedSize:receivedSize expectedSize:expectedSize];
    }              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [weakSelf removeProgressView];
        if (completedBlock) {
            completedBlock(image, error, cacheType, imageURL);
        }
    }];
}

- (void)addProgressViewWithReceivedSize:(NSInteger)receivedSize expectedSize:(NSInteger)expectedSize {
    if (expectedSize < 0) return;
    [self addProgressWithStyle:UIProgressViewStyleDefault];
    float pvalue = MAX(0, MIN(1, (float) receivedSize / (float) expectedSize));
    [self updateProgressView:pvalue];
    if (pvalue >= 1) {
        [self removeProgressView];
    }
}

@end
