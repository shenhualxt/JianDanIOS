//
//  CommentCell.h
//  LTFloorViewDemo
//
//  Created by 刘献亭 on 15/9/15.
//  Copyright (c) 2015年 刘献亭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEReactiveView.h"
#import "LTFloorView.h"

@interface CommentsCell : UITableViewCell<CEReactiveView,LTFloorViewDelegate,LTFloorViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *labelUserName;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet LTFloorView *floorView;

@property (weak, nonatomic) IBOutlet UIButton *buttonOO;
@property (weak, nonatomic) IBOutlet UIButton *buttonXX;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userNameWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *labelContent;

@property(strong,nonatomic) NSArray *subCommentArray;

@end
