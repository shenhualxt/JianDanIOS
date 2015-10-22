//
//  LittleMovieCollectionCell.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/30.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "VideoCollectionCell.h"
#import "Picture.h"
#import "UIImage+Scale.h"

@interface VideoCollectionCell () <CEReactiveView>

@property(weak, nonatomic) IBOutlet UIImageView *imagePictures;
@property(weak, nonatomic) IBOutlet UILabel *labelTitle;
@property(weak, nonatomic) IBOutlet UIButton *buttonOO;
@property(weak, nonatomic) IBOutlet UIButton *buttonXX;
@property(weak, nonatomic) IBOutlet UIButton *buttonMore;
@property(weak, nonatomic) IBOutlet UIButton *buttonChat;

@end

@implementation VideoCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSArray * nibs = [[NSBundle mainBundle] loadNibNamed:@"VideoCollectionCell" owner:self options:nil];
        self = (VideoCollectionCell *) [nibs firstObject];
    }
    return self;
}

- (void)bindViewModel:(Picture *)picture forIndexPath:(NSIndexPath *)indexPath {
    [self.buttonOO setTitle:[NSString stringWithFormat:@"OO %d", (int) picture.vote_positive] forState:UIControlStateNormal];
    [self.buttonXX setTitle:[NSString stringWithFormat:@"XX %d", (int) picture.vote_negative] forState:UIControlStateNormal];
    //videos为空的，都被删除了
    NSURL * picUrl = [NSURL URLWithString:[picture.videos[0] thumbnail]];
    [self.imagePictures sd_setImageWithURL:picUrl placeholderImage:[UIImage imageNamed:@"ic_loading_large"]];
    self.labelTitle.text = [picture.videos[0] title];
}

@end
