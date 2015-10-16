//
//  LittleMovieCollectionCell.m
//  JianDan
//
//  Created by 刘献亭 on 15/9/30.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "LittleMovieCollectionCell.h"
#import "BoredPictures.h"
#import "UIImage+Scale.h"

@interface LittleMovieCollectionCell()<CEReactiveView>

@property (weak, nonatomic) IBOutlet UIImageView *imagePictures;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIButton *buttonOO;
@property (weak, nonatomic) IBOutlet UIButton *buttonXX;
@property (weak, nonatomic) IBOutlet UIButton *buttonMore;
@property (weak, nonatomic) IBOutlet UIButton *buttonChat;

@end

@implementation LittleMovieCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        NSArray *nibs=[[NSBundle mainBundle] loadNibNamed:@"LittleMovieCollectionCell" owner:self options:nil];
        self=(LittleMovieCollectionCell *)[nibs firstObject];
    }
    return self;
}

-(void)bindViewModel:(BoredPictures *)boredPictures forIndexPath:(NSIndexPath *)indexPath{
    [self.buttonOO setTitle:[NSString stringWithFormat:@"OO %d",(int)boredPictures.vote_positive] forState:UIControlStateNormal];
    [self.buttonXX setTitle:[NSString stringWithFormat:@"XX %d",(int)boredPictures.vote_negative] forState:UIControlStateNormal];
    //videos为空的，都被删除了
    NSURL *picUrl=[NSURL URLWithString:[boredPictures.videos[0] thumbnail]];
    [self.imagePictures sd_setImageWithURL:picUrl placeholderImage:[UIImage imageNamed:@"ic_loading_large"]];
    self.labelTitle.text=[boredPictures.videos[0] title];
}

@end
