//
//  FreshNewsCellTableViewCell.m
//  JianDan
//
//  Created by 刘献亭 on 15/8/29.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "FreshNewsCell.h"
#import "FreshNews.h"

@interface FreshNewsCell ()

@property(weak, nonatomic) IBOutlet UIImageView *imageFreshNews;
@property(weak, nonatomic) IBOutlet UIButton *btnTitle;
@property(weak, nonatomic) IBOutlet UILabel *labelAuthorName;
@property(weak, nonatomic) IBOutlet UILabel *labelViewTimes;
@property(weak, nonatomic) IBOutlet UIButton *buttonShare;
@property(weak, nonatomic) IBOutlet UIView *freshNewsView;

@end

@implementation FreshNewsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageFreshNews.layer.cornerRadius = self.freshNewsView.layer.cornerRadius = 4;
    self.imageFreshNews.layer.masksToBounds = self.freshNewsView.layer.masksToBounds = YES;
    self.btnTitle.titleLabel.numberOfLines = 0;

    //设置阴影
    self.freshNewsView.layer.shadowColor = RGBA(0, 0, 0, 0.5).CGColor;
    self.freshNewsView.layer.shadowOffset = CGSizeMake(0, 1);
    self.freshNewsView.layer.shadowOpacity = 1.0;
    self.freshNewsView.layer.shadowRadius = 3;//阴影半径，默认3
    self.freshNewsView.clipsToBounds = NO;
    
    [self setShadowPath];
    
}

- (void)bindViewModel:(Posts *)posts {
    [self.btnTitle setTitle:posts.title forState:UIControlStateNormal];
    self.labelAuthorName.text = [posts.author name];
    [self.imageFreshNews sd_setImageWithURL:posts.custom_fields.thumb_m];
    self.labelViewTimes.text = posts.custom_fields.viewsCount;
}


- (void)setShadowPath {
    //右下路径阴影
    UIBezierPath *path = [UIBezierPath bezierPath];

    float width = SCREEN_WIDTH-16;
    float height = self.freshNewsView.bounds.size.height;
    float x = self.freshNewsView.bounds.origin.x;
    float y = self.freshNewsView.bounds.origin.y;
    float addWH = 2;

    CGPoint topRight = CGPointMake(x + width, y);
    CGPoint rightMiddle = CGPointMake(x + width + addWH, y + (height / 2));
    CGPoint bottomRight = CGPointMake(x + width, y + height);
    CGPoint bottomMiddle = CGPointMake(x + (width / 2), y + height + addWH);
    CGPoint bottomLeft = CGPointMake(x, y + height);

    [path moveToPoint:topRight];
    [path addQuadCurveToPoint:bottomRight controlPoint:rightMiddle];
    [path addQuadCurveToPoint:bottomLeft controlPoint:bottomMiddle];
    [path closePath];
    //设置阴影路径
    self.freshNewsView.layer.shadowPath = path.CGPath;
}
@end
