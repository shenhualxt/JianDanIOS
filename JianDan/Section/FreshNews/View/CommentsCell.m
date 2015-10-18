//
//  CommentCell.m
//  LTFloorViewDemo
//
//  Created by 刘献亭 on 15/9/15.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "CommentsCell.h"
#import "VoteViewModel.h"
#import "Comments.h"
#import "LTAlertView.h"
#import "PureLayout.h"
#import "NSString+Date.h"

@implementation CommentsCell


-(void)awakeFromNib{
    self.selectionStyle=UITableViewCellSelectionStyleNone;
    self.imageViewAvatar.layer.masksToBounds=YES;
    self.imageViewAvatar.layer.cornerRadius=17;
}

-(void)bindViewModel:(Comments *)comment forIndexPath:(NSIndexPath *)indexPath{
    //如果名字过长 重置控件优先级
    if (comment.nameWidth>SCREEN_WIDTH/3) {
        self.userNameWidthConstraint.priority=750;
    }
    //公用数据
    self.labelUserName.text=comment.name;
    self.labelContent.text=comment.content;
    self.labelTime.text=comment.date;
    if(comment.parentCommentsArray.count>0){
        self.subCommentArray=comment.parentCommentsArray;
        self.floorView.dataSource=self;
    }else{
        self.subCommentArray=nil;
        self.floorView.dataSource=nil;
    }
    
    //无聊图 有头像，无顶和踩
    if (comment.created_at) {
        [self.imageViewAvatar sd_setImageWithURL:[NSURL URLWithString:comment.avatar_url] placeholderImage:[UIImage imageNamed:@"ic_play_gif"]];
        self.constraintAvatarWidth.constant=34;
        self.buttonOO.hidden=YES;
        self.buttonXX.hidden=YES;
        [self.constraintLineLeading autoRemove];
        [self.viewLine autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:self.labelUserName];
    }else{//新鲜事 无头像 有顶和踩 在其他地方通用
        [self.buttonOO setTitle:[NSString stringWithKey:"OO " value:(int)comment.vote_positive] forState:UIControlStateNormal];
        [self.buttonXX setTitle:[NSString stringWithKey:"XX " value:(int)comment.vote_negative] forState:UIControlStateNormal];
        [[[self.buttonOO rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id x) {
            [VoteViewModel voteWithOption:OO vote:comment button:x];
        }];
        [[[self.buttonXX rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id x) {
            [VoteViewModel voteWithOption:XX vote:comment button:x];
        }];
    }
}

#pragma mark -LTFloorViewDataSource
-(UIView *)floorView:(LTFloorView *)floorView subFloorViewAtIndex:(NSInteger)index{
     Comments *comment=self.subCommentArray[index];
    UIView *view=[[[NSBundle mainBundle] loadNibNamed:@"SubCommentView" owner:self options:nil] firstObject];
    UILabel *labelAuthorName=(UILabel *)[view viewWithTag:3];
    labelAuthorName.text=comment.name;
    UILabel *labContent=(UILabel *)[view viewWithTag:4];
    labContent.text=comment.content;
    return view;
}

//评论的个数，默认最后一个是当前用户的评论
-(NSInteger)numberOfSubFloorsInFloorView:(LTFloorView *)floorView{
    return self.subCommentArray.count;
}
@end
