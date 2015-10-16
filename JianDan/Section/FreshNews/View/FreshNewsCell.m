//
//  FreshNewsCellTableViewCell.m
//  JianDan
//
//  Created by 刘献亭 on 15/8/29.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "FreshNewsCell.h"
#import "FreshNews.h"
#import "UITableViewCell+TableView.h"
#import "ShareToSinaController.h"
#import "UIViewController+MMDrawerController.h"

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
    self.btnTitle.titleLabel.numberOfLines = 0;
     self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)bindViewModel:(FreshNews *)freshNews forIndexPath:(NSIndexPath *)indexPath{
    [self.btnTitle setTitle:freshNews.title forState:UIControlStateNormal];
    self.labelAuthorName.text = [freshNews.author name];
    [self.imageFreshNews sd_setImageWithURL:freshNews.custom_fields.thumb_m placeholderImage:[UIImage imageNamed:@"ic_loading_large"]];
    self.labelViewTimes.text = freshNews.custom_fields.viewsCount;
    @weakify(self)
    self.buttonShare.rac_command=[[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
         @strongify(self)
        NSMutableString *shareText=[NSMutableString stringWithFormat:@"【%@】", freshNews.title];
        [shareText appendFormat:@"%@ (来自 @煎蛋网)", freshNews.url];
        ShareToSinaController *shareToSinaController=[ShareToSinaController new];
        shareToSinaController.sendObject=shareText;
        [[self controller].mm_drawerController.navigationController pushViewController:shareToSinaController animated:YES];
        return [RACSignal empty];
    }];;
}
@end
