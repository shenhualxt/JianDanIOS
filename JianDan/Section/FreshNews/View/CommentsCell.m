//
//  CommentCell.m
//  LTFloorViewDemo
//
//  Created by 刘献亭 on 15/9/15.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import "CommentsCell.h"
#import "FreshNewsComment.h"
#import "UITableView+FDTemplateLayoutCell.h"
static NSString *reuseIdentifier=@"CommentsCell";
@implementation CommentsCell

-(void)awakeFromNib{
    self.selectionStyle=UITableViewCellSelectionStyleNone;
}

-(void)bindViewModel:(Comments *)comment forIndexPath:(NSIndexPath *)indexPath{
    //如果名字过长 重置控件优先级
    if (comment.nameWidth>[UIScreen mainScreen].bounds.size.width/3) {
        self.userNameWidthConstraint.priority=750;
    }
    
    //绑定数据
    self.labelUserName.text=comment.name;
    self.labelContent.text=comment.content;
    self.labelTime.text=comment.date;
    [self.buttonOO setTitle:[NSString stringWithFormat:@"OO %ld",(long)comment.vote_positive] forState:UIControlStateNormal];
    [self.buttonXX setTitle:[NSString stringWithFormat:@"XX %ld",(long)comment.vote_negative] forState:UIControlStateNormal];
    if(comment.parentCommentsArray.count>0){
        self.subCommentArray=comment.parentCommentsArray;
        self.floorView.dataSource=self;
    }else{
        self.subCommentArray=nil;
    }
}

#pragma mark -LTFloorViewDataSource
-(UIView *)floorView:(LTFloorView *)floorView subFloorViewAtIndex:(NSInteger)index{
    UIView *view=nil;
     Comments *comment=self.subCommentArray[index];
    view=[[[NSBundle mainBundle] loadNibNamed:@"SubCommentView" owner:self options:nil] firstObject];
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
