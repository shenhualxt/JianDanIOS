//
//  LeftMenuController.m
//  JianDan
//
//  Created by 刘献亭 on 15/8/28.
//  Copyright © 2015年 刘献亭. All rights reserved.
//

#import "LeftMenuController.h"
#import "LeftMenu.h"
#import "LeftMenuCell.h"
#import "UIViewController+MMDrawerController.h"
#import "FreshNews.h"
#import "Picture.h"
#import "AppDelegate.h"
#import "SettingController.h"

@interface LeftMenuController ()

@property(nonatomic, strong) NSMutableArray *menuArray;

@end

@implementation LeftMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindingTableView];
    [self addSettingButton];
}

- (void)bindingTableView {
    self.tableView.backgroundColor = [UIColor darkGrayColor];
    RACCommand *menuCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *turple) {
        AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
        NSIndexPath *indexPath = turple.second;
        [delegate replaceContentViewController:indexPath.row];
        return [RACSignal empty];
    }];
    [CETableViewBindingHelper bindingHelperForTableView:self.tableView sourceSignal:RACObserve(self, menuArray) selectionCommand:menuCommand templateCellClass:[LeftMenuCell class]];
}

- (void)addSettingButton {
    CGFloat height=60;  CGFloat width=240;
    CGFloat y=SCREEN_HEIGHT-height-64;
    UIButton *settingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, y, width,height)];
    [self.tableView addSubview:settingButton];
    UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0, y, width, 1)];
    line.backgroundColor=RGBA(0, 0, 0, 0.3);
    [self.tableView addSubview:line];
    settingButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIEdgeInsets contentEdgeInsets = settingButton.contentEdgeInsets;
    contentEdgeInsets.left = 30;
    settingButton.contentEdgeInsets = contentEdgeInsets;
    UIEdgeInsets imageEdgeInsets = settingButton.imageEdgeInsets;
    imageEdgeInsets.left = -15;
    settingButton.imageEdgeInsets = imageEdgeInsets;
    [settingButton setTitle:@"设置" forState:UIControlStateNormal];
    [settingButton setImage:[UIImage imageNamed:@"ic_settings_white_24dp"] forState:UIControlStateNormal];
    [settingButton setBackgroundImage:[CommonUtils createImageWithColor:RGBA(255, 255, 255, 0.6)] forState:UIControlStateHighlighted];
    [[settingButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        MMDrawerController *drawerController = self.mm_drawerController;
        [drawerController.navigationController pushViewController:[SettingController new] animated:YES];
    }];
}

- (NSMutableArray *)menuArray {
    if (!_menuArray) {
        _menuArray = [NSMutableArray array];
        NSArray * imageNameArray = @[@"ic_explore_white_24dp", @"ic_mood_white_24dp", @"ic_local_florist_white_24dp", @"ic_chat_white_24dp", @"ic_movie_white_24dp"];
        NSArray * menuNameArray = @[@"新鲜事", @"无聊图", @"妹子图", @"段子", @"小电影"];

        for (int i = 0; i < [menuNameArray count]; ++i) {
            LeftMenu *menu = [LeftMenu menuWithImageName:imageNameArray[i] menuName:menuNameArray[i]];
            [_menuArray addObject:menu];
        }
    }
    return _menuArray;
}

@end
