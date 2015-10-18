//
//  FreshNewsLittleCell.m
//  JianDan
//
//  Created by 刘献亭 on 15/10/18.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "FreshNewsLittleCell.h"
#import "FreshNews.h"

@interface FreshNewsLittleCell()<CEReactiveView>

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;

@property (weak, nonatomic) IBOutlet UILabel *author;

@property (weak, nonatomic) IBOutlet UIImageView *imagePicture;

@end

@implementation FreshNewsLittleCell

-(void)bindViewModel:(FreshNews *)viewModel forIndexPath:(NSIndexPath *)indexPath{
    self.labelTitle.text=viewModel.title;
    self.author.text=viewModel.authorAndTagsTitle;
    NSString *key=[[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:viewModel.thumb_c]];
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:key done:^(UIImage *image, SDImageCacheType cacheType) {
        self.imagePicture.image=image?:[UIImage imageNamed:@"ic_loading_small"];
    }];
}

-(void)loadImage:(FreshNews *)viewModel forIndexPath:(NSIndexPath *)indexPath helper:(CETableViewBindingHelper *)helper{
    [self.imagePicture sd_setImageWithURL:[NSURL URLWithString:viewModel.thumb_c] placeholderImage:[UIImage imageNamed:@"ic_loading_small"]];
}

@end
